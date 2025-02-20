# -*- coding: utf-8 -*-
"""
Created on Sat Jan 25 11:27:37 2025

Script to perform weighted seasonal decomposition on GeoTIFF files, extract trend components,
save trend components to a separate folder with date-based filenames, perform weighted linear regression on the trend,
and save the regression results (slope, slope standard error, and p-value) as separate GeoTIFFs.
Additionally, the slope and slope standard error are multiplied by 365.

Author: Guoshuai Li
"""

import rasterio
import numpy as np
import glob
import os
from tqdm import tqdm
from datetime import datetime
import statsmodels.api as sm
from multiprocessing import Pool, cpu_count

def get_sorted_file_pairs(mean_dir, std_dir, mean_prefix='trend_', std_prefix='both_mscn_sub_isimip3_std_', suffix='.tif'):
    """
    从不同目录中获取成对的mean和std文件，并按日期排序。
    
    参数:
        mean_dir (str): mean文件所在目录路径。
        std_dir (str): std文件所在目录路径。
        mean_prefix (str): mean文件的前缀。
        std_prefix (str): std文件的前缀。
        suffix (str): 文件后缀，默认为'.tif'。
        
    返回:
        list of tuples: 每个元组包含一对(mean_file, std_file)。
    """
    mean_pattern = os.path.join(mean_dir, f"{mean_prefix}*{suffix}")
    std_pattern = os.path.join(std_dir, f"{std_prefix}*{suffix}")
    
    mean_files = sorted(glob.glob(mean_pattern))
    std_files = sorted(glob.glob(std_pattern))
    
    # 提取日期并创建std文件字典
    def extract_date(file_path, prefix, suffix):
        base = os.path.basename(file_path)
        date_str = base.replace(prefix, '').replace(suffix, '')
        return date_str
    
    std_files_dict = {extract_date(f, std_prefix, suffix): f for f in std_files}
    
    # 创建文件对列表
    file_pairs = []
    for mean_file in mean_files:
        date_str = extract_date(mean_file, mean_prefix, suffix)
        std_file = std_files_dict.get(date_str)
        if std_file:
            file_pairs.append((mean_file, std_file))
        else:
            print(f"警告：未找到对应的std文件 for {mean_file}")
    
    print(f"找到 {len(file_pairs)} 对mean和std文件。")
    return file_pairs

def extract_numeric_date(file_path, mean_prefix='trend_', suffix='.tif'):
    """
    从文件路径中提取日期字符串并转换为数值（自某一参考日期以来的天数）。
    
    参数:
        file_path (str): 文件路径。
        mean_prefix (str): mean文件的前缀。
        suffix (str): 文件后缀，默认为'.tif'。
        
    返回:
        int: 自参考日期以来的天数。
    """
    base = os.path.basename(file_path)
    date_str = base.replace(mean_prefix, '').replace(suffix, '')
    try:
        date = datetime.strptime(date_str, "%Y%m%d")
        # 选择一个参考日期，例如1970-01-01
        ref_date = datetime(1970, 1, 1)
        delta = date - ref_date
        return delta.days
    except ValueError:
        print(f"错误：无法解析日期字符串 '{date_str}' 从文件 '{file_path}'")
        return np.nan

def perform_weighted_linear_regression_statsmodels(y, x, weights):
    """
    使用statsmodels执行加权线性回归，返回截距、斜率、斜率的标准误差和斜率的p值，并将截距、斜率和斜率的标准误差乘以365。
    
    参数:
        y (np.ndarray): 因变量数组。
        x (np.ndarray): 自变量数组。
        weights (np.ndarray): 权重数组。
        
    返回:
        tuple: (截距*365, 斜率*365, 斜率的标准误差*365, 斜率的p值)
    """
    X = sm.add_constant(x)  # 添加截距项
    try:
        model = sm.WLS(y, X, weights=weights)
        results = model.fit()
        intercept = results.params[0] * 365
        slope = results.params[1] * 365
        slope_se = results.bse[1] * 365
        slope_pvalue = results.pvalues[1]
        return intercept, slope, slope_se, slope_pvalue
    except Exception as e:
        print(f"加权线性回归失败: {e}")
        return (np.nan, np.nan, np.nan, np.nan)

def process_pixel(args):
    """
    处理单个像素的回归。
    
    参数:
        args (tuple): 包含y值、x值和权重的元组。
        
    返回:
        tuple: (截距*365, 斜率*365, 斜率的标准误差*365, 斜率的p值)
    """
    y, x, weights = args
    mask = ~np.isnan(y) & ~np.isnan(weights)
    if np.sum(mask) < 2:
        return (np.nan, np.nan, np.nan, np.nan)
    
    y_valid = y[mask]
    x_valid = x[mask]
    weights_valid = weights[mask]
    
    intercept, slope, slope_se, slope_pvalue = perform_weighted_linear_regression_statsmodels(y_valid, x_valid, weights_valid)
    return (intercept, slope, slope_se, slope_pvalue)

def main_parallel():
    # 设置目录路径
    mean_dir = 'D:/GRACE/both_mascons_rl06/isimip3_result/trend_components/'  # 替换为实际mean文件目录路径
    std_dir = 'D:/GRACE/both_mascons_rl06/isimip3_result/trend_components_std/'    # 替换为实际std文件目录路径
    
    # 设置输出目录路径
    output_dir = 'D:/GRACE/both_mascons_rl06/isimip3_result/regression_weighted/'
    
    # 如果输出目录不存在，则创建
    os.makedirs(output_dir, exist_ok=True)
    
    # 定义输出文件路径
    output_slope_path = os.path.join(output_dir, 'trend_slope.tif')  
    output_slope_se_path = os.path.join(output_dir, 'trend_slope_se.tif')  
    output_pvalue_path = os.path.join(output_dir, 'trend_pvalue.tif')  
    
    # 获取成对的文件列表
    file_pairs = get_sorted_file_pairs(mean_dir, std_dir)
    
    if not file_pairs:
        print("未找到任何成对的mean和std文件。请检查文件路径和命名模式。")
        return
    
    num_files = len(file_pairs)
    
    # 提取所有日期并转换为数值
    numeric_dates = []
    for mean_file, _ in file_pairs:
        numeric_date = extract_numeric_date(mean_file)
        numeric_dates.append(numeric_date)
    
    # 检查是否有无效的日期
    numeric_dates = np.array(numeric_dates, dtype=np.float32)
    valid_dates_mask = ~np.isnan(numeric_dates)
    
    if np.sum(valid_dates_mask) < 2:
        print("有效的日期数量不足以进行回归。")
        return
    
    # 使用有效的日期
    numeric_dates = numeric_dates[valid_dates_mask]
    
    # 使用有效的文件对
    valid_file_pairs = [pair for idx, pair in enumerate(file_pairs) if valid_dates_mask[idx]]
    num_valid_files = len(valid_file_pairs)
    
    # 读取第一个文件以获取地理信息
    with rasterio.open(valid_file_pairs[0][0]) as src:
        meta = src.meta.copy()
        width = src.width
        height = src.height
        transform = src.transform
        crs = src.crs
        nodata = src.nodata
        dtype = 'float32'  # 使用float32存储结果
    
    # 初始化3D数组用于存储所有mean和std数据
    means_stack = np.empty((num_valid_files, height, width), dtype=np.float32)
    stds_stack = np.empty((num_valid_files, height, width), dtype=np.float32)
    
    print("读取所有mean和std文件...")
    for idx, (mean_file, std_file) in enumerate(tqdm(valid_file_pairs, desc="读取文件")):
        with rasterio.open(mean_file) as src_mean:
            mean_data = src_mean.read(1).astype(np.float32)
            if nodata is not None:
                mean_data[mean_data == nodata] = np.nan
            means_stack[idx, :, :] = mean_data
        
        with rasterio.open(std_file) as src_std:
            std_data = src_std.read(1).astype(np.float32)
            if nodata is not None:
                std_data[std_data == nodata] = np.nan
            stds_stack[idx, :, :] = std_data
    
    # 使用转换后的日期作为x轴
    x = numeric_dates  # shape (num_valid_files,)
    
    # 初始化结果数组
    slope_result = np.full((height, width), np.nan, dtype=np.float32)
    slope_se_result = np.full((height, width), np.nan, dtype=np.float32)  # 存储斜率的标准误差
    slope_pvalue_result = np.full((height, width), np.nan, dtype=np.float32)  # 存储斜率的p值
    
    # Reshape for parallel processing
    y = means_stack.reshape(num_valid_files, -1)  # shape (time, pixels)
    std = stds_stack.reshape(num_valid_files, -1)  # shape (time, pixels)
    
    # 计算权重
    weights = 1 / (std ** 2)  # shape (time, pixels)
    
    # 处理无穷大和NaN值
    weights[np.isinf(weights)] = 0
    weights = np.where(np.isnan(weights), 0, weights)
    
    # 准备并行处理的输入
    args = [(y[:, idx], x, weights[:, idx]) for idx in range(y.shape[1])]
    
    # 使用多进程池并行处理
    print("执行加权线性回归（并行）...")
    with Pool(processes=cpu_count()) as pool:
        results = list(tqdm(pool.imap(process_pixel, args), total=len(args), desc="回归进度"))
    
    # 分离结果
    _, slope, slope_se, slope_pvalue = zip(*results)
    
    # Reshape结果为2D数组
    slope_result = np.array(slope).reshape(height, width).astype(np.float32)
    slope_se_result = np.array(slope_se).reshape(height, width).astype(np.float32)
    slope_pvalue_result = np.array(slope_pvalue).reshape(height, width).astype(np.float32)
    
    # 更新元数据以保存结果，波段数设为1
    slope_meta = meta.copy()
    slope_meta.update(count=1, dtype='float32')
    
    slope_se_meta = meta.copy()
    slope_se_meta.update(count=1, dtype='float32')
    
    pvalue_meta = meta.copy()
    pvalue_meta.update(count=1, dtype='float32')
    
    # 保存斜率 GeoTIFF
    print("保存斜率结果为GeoTIFF...")
    try:
        with rasterio.open(output_slope_path, 'w', **slope_meta) as dst:
            dst.write(slope_result, 1)
        print(f"斜率已保存到 {output_slope_path}")
    except Exception as e:
        print(f"保存斜率GeoTIFF时出错: {e}")
    
    # 保存斜率的标准误差 GeoTIFF
    print("保存斜率的标准误差结果为GeoTIFF...")
    try:
        with rasterio.open(output_slope_se_path, 'w', **slope_se_meta) as dst:
            dst.write(slope_se_result, 1)
        print(f"斜率的标准误差已保存到 {output_slope_se_path}")
    except Exception as e:
        print(f"保存斜率标准误差GeoTIFF时出错: {e}")
    
    # 保存 p 值 GeoTIFF
    print("保存p值结果为GeoTIFF...")
    try:
        with rasterio.open(output_pvalue_path, 'w', **pvalue_meta) as dst:
            dst.write(slope_pvalue_result, 1)
        print(f"p值已保存到 {output_pvalue_path}")
    except Exception as e:
        print(f"保存p值GeoTIFF时出错: {e}")

if __name__ == "__main__":
    main_parallel()
