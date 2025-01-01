#!/usr/local/bin/python
# -*- coding: utf-8 -*-

#Author: Feihu Hu and Guoshuai Li
# Contact: GUOSHUAI Li  <liguoshuai@outlook.com> <liguoshuai@lzb.ac.cn>
# Copyright (C) 2025

import os
import re
import numpy as np
from osgeo import gdal
import pandas as pd
#from gdalconst import *
from osgeo import osr,gdalconst
import scipy.stats as stat
from statsmodels.tsa.seasonal import seasonal_decompose
import datetime
import time

"""
修改以下文件夹
"""
#输入数据文件夹
inputdir='isimip3'
#输出原始数据csv，周期组分，趋势组分，残差成分
outcsv='D:\\GRACE\\mscn\\tellus_grace_csr_mascon_grid_rl0602\\isimip3_result\\outcsv'
if os.path.exists(outcsv):
    pass
else:
    os.makedirs(outcsv)
#生成趋势组分的影像
outtiff='D:\\GRACE\\mscn\\tellus_grace_csr_mascon_grid_rl0602\\isimip3_result\\outtiff'
if os.path.exists(outtiff):
    pass
else:
    os.makedirs(outtiff)
#趋势组分影像的线性回归输出
regression='D:\\GRACE\\mscn\\tellus_grace_csr_mascon_grid_rl0602\\isimip3_result\\regression'
if os.path.exists(regression):
    pass
else:
    os.makedirs(regression)


def ReadGeoTiff(file):
    ds = gdal.Open(file)
    band = ds.GetRasterBand(1)
    data_arr = band.ReadAsArray()
    [Ysize, Xsize] = data_arr.shape
    return data_arr, Ysize, Xsize

def GetGeoInfo(FileName):
    SourceDS = gdal.Open(FileName,gdal.GA_ReadOnly)
    GeoT = SourceDS.GetGeoTransform()
    Projection = osr.SpatialReference()
    Projection.ImportFromWkt(SourceDS.GetProjectionRef())
    return GeoT, Projection

def CreateGeoTiff(Name, Array, xsize, ysize, GeoT, Projection):
    gdal.AllRegister()
    driver = gdal.GetDriverByName('GTiff')
    DataType = gdal.GDT_Float32
    NewFileName = Name + '.tif'
    DataSet = driver.Create(NewFileName, xsize, ysize, 1, DataType)
    DataSet.SetGeoTransform(GeoT)
    DataSet.SetProjection(Projection.ExportToWkt())
    DataSet.GetRasterBand(1).WriteArray(Array)
    outBand = DataSet.GetRasterBand(1)
    outBand.FlushCache()
    return NewFileName

def CaltimeS(date1, date2):
   date1=time.strptime(date1,"%Y-%m-%d %H:%M:%S")
   date2=time.strptime(date2,"%Y-%m-%d %H:%M:%S")
   date1=datetime.datetime(date1[0],date1[1],date1[2],date1[3],date1[4],date1[5])
   date2=datetime.datetime(date2[0],date2[1],date2[2],date2[3],date2[4],date2[5])
   date=date2-date1
   return date.days

datearray=[]
dataarray=[]
trenddata=[]
seasonaldata=[]
residdata=[]
Lin_slp_all=[]
Lin_intp_all=[]
Lin_p_value_all=[]
Lin_se_all=[]
indexdate=[]
days=[]
alltrend=[]

list = os.listdir(inputdir)
for i in range(0, len(list)):
    infile = os.path.join(inputdir, list[i])
    if re.search('.tif$', infile):
        #修改文件名称下划线分割的长度，在tif之前的列数，从0开始计数
        date = re.split(r'\.', re.split(r'_', infile)[4])[0]
        [data, Ysize, Xsize] = ReadGeoTiff(infile)
        datadf=pd.DataFrame(data)

        #可将Taklimankan_Desert_v11_small_boundary_csr_sub_isimip3_修改为具体输入数据文件头名称
        datadf.to_csv(outcsv+'\\csr_mscn_sub_isimip3_'+date+'.csv',sep=',')

        data = np.asarray(np.squeeze(np.reshape(data, [1, Ysize * Xsize])))
        data[data < -100000000] = -99999
        datearray.append(date)
        dataarray.append(data)
df = pd.DataFrame(dataarray,index=datearray)


#原始数据文件名称orginal.csv，可以修改
df.to_csv(outcsv+'\\orginal.csv')

for j in range(0, df.columns.size):
    decomposition = seasonal_decompose(df[j], period=12)
    trend=decomposition.trend
    seasonal=decomposition.seasonal
    resid=decomposition.resid
    trenddata.append(trend)
    seasonaldata.append(seasonal)
    residdata.append(resid)
allcomdata=np.array(trenddata).T
allseasondata=np.array(seasonaldata).T
allresiddata=np.array(residdata).T

decomdataframe=pd.DataFrame(allcomdata,index=datearray)
seasondataframe=pd.DataFrame(allseasondata,index=datearray)
residdataframe=pd.DataFrame(allresiddata,index=datearray)




#提取投影和仿射变换信息，选数据中其中一个获取投影即可
example='C:\\Users\\liguo\\PycharmProjects\\csr0602\\isimip3\\csr_mscn_sub_isimip3_20020418.tif'


[data, Ysize, Xsize] = ReadGeoTiff(example)
[GeoT, Projection] = GetGeoInfo(example)
for index,trendda in decomdataframe.iterrows():
    trendda = np.array(trendda)
    if np.isnan(trendda).any():
        continue
    else:
        decom = np.reshape(trendda, [Ysize, Xsize])

        #其中Taklimankan_Desert_v11_small_boundary_csr_sub_isimip3_trend_component_可以自己修改
        outfile=outtiff+'\\csr_mscn_sub_isimip3_trend_component_'+index
        CreateGeoTiff(outfile, decom, Xsize, Ysize, GeoT, Projection)
        indexdate.append(index)

'''
修改以下文件
'''
#trend_component.csv为趋势组分的结果
decomdataframe.to_csv(outcsv+'\\trend_component.csv',sep=',')
seasondataframe.to_csv(outcsv+'\\seasonal_component.csv',sep=',')
residdataframe.to_csv(outcsv+'\\random_component.csv',sep=',')


print('trend decomposition success')
print('------------------------------------')
print('begin regression')


for index,trendda in decomdataframe.iterrows():
    trendda = np.array(trendda)
    if np.isnan(trendda).any():
        continue
    else:
        regeressiondate=index[0]+index[1]+index[2]+index[3]+'-'+index[4]+index[5]+'-'+index[6]+index[7]+' '+'00:00:00'

        basedate='1900-01-01 00:00:00'

        distancedays=CaltimeS(basedate,regeressiondate)
        days.append(distancedays)
        alltrend.append(trendda)
trendframe=pd.DataFrame(alltrend)



for k in range(0, trendframe.columns.size):
    lin_slp, lin_intp, lin_r, lin_p, lin_se = stat.linregress(days,trendframe[k].values)

    if lin_slp==0:
        Lin_slp_all.append(-99999)
    else:
        Lin_slp_all.append(lin_slp * 3650)

    if lin_intp < -30000000.0:
        Lin_intp_all.append(-99999)
    else:
        Lin_intp_all.append(lin_intp * 3650)

    if lin_p==1:
        Lin_p_value_all.append(-99999)
    else:
        Lin_p_value_all.append(lin_p)

    if lin_se == 0:
        Lin_se_all.append(-99999)
    else:
        Lin_se_all.append(lin_se * 3650)


RegressionData={"Lin_slp_all":Lin_slp_all,"Lin_intp_all":Lin_intp_all,"Lin_p_value_all":Lin_p_value_all,"Lin_se_all":Lin_se_all}
RegressionDataFrame = pd.DataFrame(RegressionData)


#\Regression.csv为趋势组分的线性回归结果
RegressionDataFrame.to_csv(regression+'\\Regression.csv')


Lin_slp = np.reshape(Lin_slp_all, [Ysize, Xsize])
outfile1=regression+'\\Lin_slp_all'
CreateGeoTiff(outfile1, Lin_slp, Xsize, Ysize, GeoT, Projection)
Lin_intp = np.reshape(Lin_intp_all, [Ysize, Xsize])
outfile2=regression+'\\Lin_intp_all'
CreateGeoTiff(outfile2, Lin_intp, Xsize, Ysize, GeoT, Projection)
Lin_p_value = np.reshape(Lin_p_value_all, [Ysize, Xsize])
outfile3=regression+'\\Lin_p_value_all'
CreateGeoTiff(outfile3, Lin_p_value, Xsize, Ysize, GeoT, Projection)
Lin_se = np.reshape(Lin_se_all, [Ysize, Xsize])
outfile4=regression+'\\Lin_se_all'
CreateGeoTiff(outfile4, Lin_se, Xsize, Ysize, GeoT, Projection)
print('------------------------------------')
print('regression success')
