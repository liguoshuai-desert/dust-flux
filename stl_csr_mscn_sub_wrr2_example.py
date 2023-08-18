#!/usr/local/bin/python
# -*- coding: utf-8 -*-

import os
import re
import numpy as np
import gdal
import pandas as pd
from gdalconst import *
from osgeo import osr
import scipy.stats as stat
from statsmodels.tsa.seasonal import seasonal_decompose
import datetime
import time

"""
revise following files
"""
#input data files
inputdir='wrr2'
#output original csv data, cycle component, trend component and residual component
outcsv='D:\\GRACE\\mscn\\tellus_grace_csr_mascon_grid_rl06_v2\\wrr2_result\\outcsv'
if os.path.exists(outcsv):
    pass
else:
    os.makedirs(outcsv)
#generate tiff of trend component
outtiff='D:\\GRACE\\mscn\\tellus_grace_csr_mascon_grid_rl06_v2\\wrr2_result\\outtiff'
if os.path.exists(outtiff):
    pass
else:
    os.makedirs(outtiff)
#output linear regression of trend component
regression='D:\\GRACE\\mscn\\tellus_grace_csr_mascon_grid_rl06_v2\\wrr2_result\\regression'
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
    SourceDS = gdal.Open(FileName,GA_ReadOnly)
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
        #revise split underline lengths of file names
        date = re.split(r'\.', re.split(r'_', infile)[4])[0]
        [data, Ysize, Xsize] = ReadGeoTiff(infile)
        datadf=pd.DataFrame(data)

        #for example, revise Taklamankan_Desert_v11_small_boundary_csr_sub_wrr2_ into other file-heads of specific data
        datadf.to_csv(outcsv+'\\csr_mscn_sub_wrr2_'+date+'.csv',sep=',')

        data = np.asarray(np.squeeze(np.reshape(data, [1, Ysize * Xsize])))
        data[data < -100000000] = -99999
        datearray.append(date)
        dataarray.append(data)
df = pd.DataFrame(dataarray,index=datearray)


#original data file name (orginal.csv)
df.to_csv(outcsv+'\\orginal.csv')

for j in range(0, df.columns.size):
    decomposition = seasonal_decompose(df[j], freq=12)
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




#extract information of project and affine transformation, choose one data-file
example='C:\\Users\\liguo\\PycharmProjects\\grace06v2mscn\\csr\\wrr2\\csr_mscn_sub_wrr2_20020418.tif'


[data, Ysize, Xsize] = ReadGeoTiff(example)
[GeoT, Proj] = GetGeoInfo(example)
for index,trendda in decomdataframe.iterrows():
    trendda = np.array(trendda)
    if np.isnan(trendda).any():
        continue
    else:
        decom = np.reshape(trendda, [Ysize, Xsize])

        #revise Taklimankan_Desert_v11_small_boundary_csr_sub_wrr2_trend_component_
        outfile=outtiff+'\\csr_mscn_sub_wrr2_trend_component_'+index
        CreateGeoTiff(outfile, decom, Xsize, Ysize, GeoT, Proj)
        indexdate.append(index)

'''
revise following files
'''
#trend_component.csv is results of trend component
decomdataframe.to_csv(outcsv+'\\trend_component.csv',sep=',')
seasondataframe.to_csv(outcsv+'\\seasonal_component.csv',sep=',')
residdataframe.to_csv(outcsv+'\\random_component.csv',sep=',')


print 'trend decomposition success'
print '------------------------------------'
print 'begin regression'


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
        Lin_se_all.append(lin_se*3650)


RegressionData={"Lin_slp_all":Lin_slp_all,"Lin_intp_all":Lin_intp_all,"Lin_p_value_all":Lin_p_value_all,"Lin_se_all":Lin_se_all}
RegressionDataFrame = pd.DataFrame(RegressionData)


#\Regression.csv is linear regression results of trend component
RegressionDataFrame.to_csv(regression+'\\Regression.csv')


Lin_slp = np.reshape(Lin_slp_all, [Ysize, Xsize])
outfile1=regression+'\\Lin_slp_all'
CreateGeoTiff(outfile1, Lin_slp, Xsize, Ysize, GeoT, Proj)
Lin_intp = np.reshape(Lin_intp_all, [Ysize, Xsize])
outfile2=regression+'\\Lin_intp_all'
CreateGeoTiff(outfile2, Lin_intp, Xsize, Ysize, GeoT, Proj)
Lin_p_value = np.reshape(Lin_p_value_all, [Ysize, Xsize])
outfile3=regression+'\\Lin_p_value_all'
CreateGeoTiff(outfile3, Lin_p_value, Xsize, Ysize, GeoT, Proj)
Lin_se = np.reshape(Lin_se_all, [Ysize, Xsize])
outfile4=regression+'\\Lin_se_all'
CreateGeoTiff(outfile4, Lin_se, Xsize, Ysize, GeoT, Proj)
print '------------------------------------'
print 'regression success'
