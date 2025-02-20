# -*- coding: utf-8 -*-
"""
Created on Sat Jan 25 16:49:46 2025

Modified to use STL (Seasonal Trend decomposition using Loess) for seasonal decomposition.
Added skipping of the first and last period//2 time steps when saving trend components to avoid edge effects.
Removed parallelization of row processing.
Added creation of regression output directory.

主要流程：
1. 从 directory 中读取所有符合 pattern 的 GeoTIFF 文件，并按日期排序 (get_sorted_file_list)。
2. 将这些多时序影像堆叠为 (time, height, width) 的三维数组 (read_geotiff_stack)。
3. 逐像素执行 STL 分解，提取每个像素的时间序列趋势 (perform_stl_decomposition)。
4. 将结果 trend_stack 存储到 output_trend_directory 下，跳过前后 period//2 帧 (save_trend_components)。
5. 将 trend_stack 拆分成 (pixels, time)，对每个像素执行线性回归 (process_pixel_regression)，
   得到像素级别的斜率(annual)、斜率标准误(annual)和 p 值。
6. 最终分别输出斜率、标准误、p 值的栅格 GeoTIFF。
"""

import rasterio
import numpy as np
import glob
import os
from tqdm import tqdm
from datetime import datetime
import statsmodels.api as sm
from statsmodels.tsa.seasonal import STL
from multiprocessing import Pool, cpu_count


def get_sorted_file_list(directory, pattern='gsfc_mscn_sub_watergap_*.tif'):
    """
    获取指定目录下匹配模式的所有文件，并按日期排序。

    参数:
        directory (str): 文件所在目录。
        pattern (str): 文件匹配模式。

    返回:
        list: 按日期排序的文件路径列表。
        list: 对应的日期列表。
    """
    file_pattern = os.path.join(directory, pattern)
    files = glob.glob(file_pattern)
    if not files:
        raise FileNotFoundError(f"No files found in {directory} with pattern {pattern}")

    def extract_date(file_path):
        base = os.path.basename(file_path)
        # 假设文件名格式为：gsfc_mscn_sub_watergap_YYYYMMDD.tif
        date_str = base.replace('gsfc_mscn_sub_watergap_', '').replace('.tif', '')
        try:
            date = datetime.strptime(date_str, "%Y%m%d")
            return date
        except ValueError:
            raise ValueError(f"Filename {base} does not match supported date format YYYYMMDD.")

    files_sorted = sorted(files, key=extract_date)
    dates_sorted = [extract_date(f) for f in files_sorted]
    return files_sorted, dates_sorted


def convert_dates_to_numeric(dates, ref_date=datetime(1970, 1, 1)):
    """
    将日期转换为自参考日期以来的天数，用于后续做回归。

    参数:
        dates (list of datetime): 日期列表。
        ref_date (datetime): 参考日期。

    返回:
        np.ndarray: 数值形式的日期（天数）。
    """
    numeric_dates = np.array([(date - ref_date).days for date in dates], dtype=np.float64)
    return numeric_dates


def read_geotiff_stack(file_list, nodata=None):
    """
    读取一系列GeoTIFF文件并堆叠为一个 (time, height, width) 的三维数组。

    参数:
        file_list (list): GeoTIFF文件路径列表。
        nodata (float, optional): 无效数据值。若为None，则自动从文件中读取。

    返回:
        tuple: (堆叠的3D数组, 元数据)
    """
    with rasterio.open(file_list[0]) as src:
        meta = src.meta.copy()
        width = src.width
        height = src.height
        crs = src.crs
        transform = src.transform
        # 若没传入 nodata，则从源文件读取
        nodata = src.nodata if nodata is None else nodata
        dtype = 'float64'  # 统一使用float64

    num_files = len(file_list)
    stack = np.empty((num_files, height, width), dtype=np.float64)

    print("读取所有GeoTIFF文件并堆叠...")
    for idx, file in enumerate(tqdm(file_list, desc="读取文件")):
        with rasterio.open(file) as src:
            data = src.read(1).astype(np.float64)
            if nodata is not None:
                data[data == nodata] = np.nan
            stack[idx, :, :] = data

    return stack, meta


def perform_stl_decomposition(y, period=12, seasonal=13):
    """
    对单个像素的时间序列 y 执行STL分解，提取趋势分量。
    不进行任何插值处理，若包含 NaN 则 STL 可能会报错或返回异常。
    
    参数:
        y (np.ndarray): 时间序列数据 (一维)。
        period (int): 季节性周期，如月度数据时为12。
        seasonal (int): STL中季节性平滑的窗口大小。

    返回:
        np.ndarray: 趋势组分。
    """
    try:
        stl = STL(y, period=period, seasonal=seasonal, robust=True)
        result = stl.fit()
        trend = result.trend.astype(np.float64)  # 转为 float64
        return trend
    except Exception as e:
        print(f"STL季节性分解失败: {e}")
        return np.full_like(y, np.nan, dtype=np.float64)


def perform_linear_regression(x, y):
    """
    对自变量 x 和因变量 y 执行线性回归，返回 (斜率, 斜率的标准误, p值)。
    """
    if np.all(np.isnan(y)) or np.all(np.isnan(x)):
        return (np.nan, np.nan, np.nan)

    mask = ~np.isnan(x) & ~np.isnan(y)
    if np.sum(mask) < 2:
        return (np.nan, np.nan, np.nan)

    x_valid = x[mask]
    y_valid = y[mask]

    X = sm.add_constant(x_valid)
    try:
        model = sm.OLS(y_valid, X)
        results = model.fit()
        slope = results.params[1]
        slope_se = results.bse[1]
        p_value = results.pvalues[1]
        return (slope, slope_se, p_value)
    except Exception as e:
        print(f"线性回归失败: {e}")
        return (np.nan, np.nan, np.nan)


def process_pixel_decomposition(args):
    """
    处理单个像素的STL分解，返回趋势分量。
    用于并行化时的函数，但当前版本串行即可。
    """
    y, period = args
    trend = perform_stl_decomposition(y, period=period)
    return trend


def process_pixel_regression(args):
    """
    处理单个像素的线性回归，对 trend 做回归。

    参数:
        args (tuple): (trend_1d_array, numeric_date_array)

    返回:
        tuple: (斜率×365, 斜率标准误×365, p值)
    """
    trend, numeric_date = args
    if np.all(np.isnan(trend)):
        return (np.nan, np.nan, np.nan)

    # 移除NaN值
    mask = ~np.isnan(trend) & ~np.isnan(numeric_date)
    if np.sum(mask) < 2:
        return (np.nan, np.nan, np.nan)

    trend_valid = trend[mask]
    date_valid = numeric_date[mask]

    slope, slope_se, p_value = perform_linear_regression(date_valid, trend_valid)
    # 将日速率乘以365得到年度变化率
    slope_annual = slope * 365 if not np.isnan(slope) else np.nan
    slope_se_annual = slope_se * 365 if not np.isnan(slope_se) else np.nan
    return (slope_annual, slope_se_annual, p_value)


def save_trend_components(trend_stack, meta, output_directory, dates, period=12):
    """
    将趋势组分 trend_stack 按时间步另存为 GeoTIFF 文件，跳过前后 period//2 个时间步，避免边缘效应。

    参数:
        trend_stack (np.ndarray): 形状 (time, height, width) 的趋势组分数据。
        meta (dict): GeoTIFF 元数据 (rasterio)。
        output_directory (str): 输出文件夹。
        dates (list of datetime): 与 trend_stack 对应的日期列表。
        period (int): 季节性周期，用于计算需要跳过的时间步。
    """
    if not os.path.exists(output_directory):
        os.makedirs(output_directory)
        print(f"创建趋势组分输出文件夹: {output_directory}")

    num_time = trend_stack.shape[0]
    start_idx = period // 2
    end_idx = num_time - (period // 2)

    print(f"总时间步数: {num_time}")
    print(f"跳过前后 {period//2} 个时间步，保存的时间步范围: {start_idx} ~ {end_idx - 1}")

    print("保存趋势组分到GeoTIFF文件...")
    saved_count = 0
    skipped_count = 0
    for idx in tqdm(range(num_time), desc="保存趋势文件"):
        # 跳过前后 period//2 个时间步
        if idx < start_idx or idx >= end_idx:
            skipped_count += 1
            continue

        trend = trend_stack[idx, :, :]

        # 更新元数据
        trend_meta = meta.copy()
        trend_meta.update(dtype='float64', count=1)

        # 构建输出文件名，包含日期
        date_str = dates[idx].strftime("%Y%m%d")
        trend_filename = os.path.join(output_directory, f"trend_{date_str}.tif")

        try:
            with rasterio.open(trend_filename, 'w', **trend_meta) as dst:
                dst.write(trend.astype(np.float64), 1)
            saved_count += 1
        except Exception as e:
            print(f"保存文件 {trend_filename} 时出错: {e}")

    print(f"共保存 {saved_count} 个趋势组分文件到 {output_directory}")
    print(f"共跳过 {skipped_count} 个时间步")


def main():
    # 1) 设置目录和输出路径
    directory = 'D:/GRACE/gsfc_mascons_rl06v2/watergap/'  # 放置多时序TIF文件的目录
    output_trend_directory = 'D:/GRACE/gsfc_mascons_rl06v2/watergap_result/trend_components/'  # 趋势组分输出文件夹
    output_slope_path = 'D:/GRACE/gsfc_mascons_rl06v2/watergap_result/regression/trend_slope.tif'
    output_slope_se_path = 'D:/GRACE/gsfc_mascons_rl06v2/watergap_result/regression/trend_slope_se.tif'
    output_pvalue_path = 'D:/GRACE/gsfc_mascons_rl06v2/watergap_result/regression/trend_pvalue.tif'

    # 2) 确保回归输出目录存在
    regression_output_dirs = [
        os.path.dirname(output_slope_path),
        os.path.dirname(output_slope_se_path),
        os.path.dirname(output_pvalue_path)
    ]
    for dir_path in regression_output_dirs:
        if not os.path.exists(dir_path):
            os.makedirs(dir_path)
            print(f"创建回归输出文件夹: {dir_path}")

    # 3) 获取排序后的文件列表和日期
    try:
        file_list, dates = get_sorted_file_list(directory)
    except Exception as e:
        print(f"错误：{e}")
        return

    # 将日期转换为数值
    numeric_dates = convert_dates_to_numeric(dates)

    # 4) 读取并堆叠所有GeoTIFF文件
    try:
        data_stack, meta = read_geotiff_stack(file_list)
    except Exception as e:
        print(f"错误读取GeoTIFF文件：{e}")
        return

    num_time, height, width = data_stack.shape
    print(f"数据堆叠形状: 时间={num_time}, 高度={height}, 宽度={width}")

    # 5) 提取趋势组分（逐像素执行STL）
    print("执行STL季节性分解，提取趋势分量...")
    trend_stack = np.empty_like(data_stack)
    period = 12
    half_period = period // 2
    trend_stack[:half_period, :, :] = np.nan
    trend_stack[-half_period:, :, :] = np.nan
    total_pixels = height * width
    with tqdm(total=total_pixels, desc="STL分解进度") as pbar:
        for i in range(height):
            for j in range(width):
                y = data_stack[:, i, j]
                # 如果这里包含 NaN，STL 可能会直接报错或返回全 NaN
                # 不再做任何插值处理
                trend = perform_stl_decomposition(y, period=12, seasonal=13)
                trend_stack[:, i, j] = trend
                pbar.update(1)

    # 6) 保存趋势组分到指定文件夹（跳过前后 period//2 时间步）
    save_trend_components(trend_stack, meta, output_trend_directory, dates, period=12)

    # 7) 准备对趋势做回归分析
    print("准备回归分析数据...")
    # (time, height, width) -> (time, pixels)
    trend_flat = trend_stack.reshape(num_time, -1)
    # 再转置为 (pixels, time)
    trend_flat_transposed = trend_flat.T

    # 构造回归输入
    regression_args = [(trend_flat_transposed[p], numeric_dates)
                       for p in range(trend_flat_transposed.shape[0])]

    # 8) 多进程或串行执行回归
    print("使用多进程执行回归...")
    with Pool(processes=cpu_count()) as pool:
        regression_results = list(tqdm(pool.imap(process_pixel_regression, regression_args),
                                       total=len(regression_args), desc="回归进度"))

    # 9) 整理回归输出：斜率、标准误、p值
    slopes_annual, slopes_se_annual, p_values = zip(*regression_results)
    slopes_annual = np.array(slopes_annual).reshape(height, width).astype(np.float64)
    slopes_se_annual = np.array(slopes_se_annual).reshape(height, width).astype(np.float64)
    p_values = np.array(p_values).reshape(height, width).astype(np.float64)

    # 10) 保存回归结果为GeoTIFF
    meta.update(dtype='float64', count=1)

    # 斜率
    print("保存斜率结果为GeoTIFF...")
    try:
        with rasterio.open(output_slope_path, 'w', **meta) as dst:
            dst.write(slopes_annual, 1)
        print(f"线性回归斜率已保存到 {output_slope_path}")
    except Exception as e:
        print(f"保存斜率GeoTIFF时出错: {e}")

    # 斜率标准误
    print("保存斜率的标准误差结果为GeoTIFF...")
    try:
        with rasterio.open(output_slope_se_path, 'w', **meta) as dst:
            dst.write(slopes_se_annual, 1)
        print(f"线性回归斜率的标准误差已保存到 {output_slope_se_path}")
    except Exception as e:
        print(f"保存斜率标准误差GeoTIFF时出错: {e}")

    # p 值
    print("保存 p 值结果为GeoTIFF...")
    try:
        with rasterio.open(output_pvalue_path, 'w', **meta) as dst:
            dst.write(p_values, 1)
        print(f"线性回归 p 值已保存到 {output_pvalue_path}")
    except Exception as e:
        print(f"保存 p 值GeoTIFF时出错: {e}")


if __name__ == "__main__":
    main()
