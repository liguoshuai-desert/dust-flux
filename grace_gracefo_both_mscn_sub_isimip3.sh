#!/bin/bash
#GSFC
#selname
cdo -z zip -selname,lwe_thickness gsfc.glb_.200204_202406_rl06v2.0_obp-ice6gd_halfdegree.nc GSFC_GRACE_GRACE-FO_RL06v2_Mascons_all-corrections.nc
cdo -z zip -selname,land_mask gsfc.glb_.200204_202406_rl06v2.0_obp-ice6gd_halfdegree.nc GSFC_GRACE_GRACE-FO_RL06v2_Mascons_LandMask.nc
#经度从0到360更改为-180到180
cdo -z zip -sellonlatbox,-180,180,90,-90 GSFC_GRACE_GRACE-FO_RL06v2_Mascons_all-corrections.nc GSFC_GRACE_GRACE-FO_RL06v2_Mascons_all-corrections_sellonlatbox.nc
cdo -z zip -sellonlatbox,-180,180,90,-90 GSFC_GRACE_GRACE-FO_RL06v2_Mascons_LandMask.nc GSFC_GRACE_GRACE-FO_RL06v2_Mascons_LandMask_sellonlatbox.nc
#将lat : -89.75 to 89.75 by 0.5 degrees_north更改为lat : 89.75 to -89.75 by -0.5 degrees_north
cdo -z zip -invertlat GSFC_GRACE_GRACE-FO_RL06v2_Mascons_all-corrections_sellonlatbox.nc GSFC_GRACE_GRACE-FO_RL06v2_Mascons_all-corrections_sellonlatbox_invertlat.nc
cdo -z zip -invertlat GSFC_GRACE_GRACE-FO_RL06v2_Mascons_LandMask_sellonlatbox.nc GSFC_GRACE_GRACE-FO_RL06v2_Mascons_LandMask_sellonlatbox_invertlat.nc
#对纬度翻转后的GSFC进行陆地掩膜
cdo -z zip -setctomiss,0 GSFC_GRACE_GRACE-FO_RL06v2_Mascons_LandMask_sellonlatbox_invertlat.nc GSFC_GRACE_GRACE-FO_RL06v2_Mascons_LandMask_sellonlatbox_invertlat_setctomiss.nc
cdo -z zip -mul GSFC_GRACE_GRACE-FO_RL06v2_Mascons_all-corrections_sellonlatbox_invertlat.nc GSFC_GRACE_GRACE-FO_RL06v2_Mascons_LandMask_sellonlatbox_invertlat_setctomiss.nc GSFC_GRACE_GRACE-FO_RL06v2_Land_Mascons_all-corrections_sellonlatbox_invertlat.nc
cdo -z zip -setmissval,-99999 GSFC_GRACE_GRACE-FO_RL06v2_Land_Mascons_all-corrections_sellonlatbox_invertlat.nc GSFC_GRACE_GRACE-FO_RL06v2_Land_Mascons_all-corrections_sellonlatbox_invertlat_setmissval.nc
#将GSFC的单位cm换算为mm
cdo -z zip -mulc,10 GSFC_GRACE_GRACE-FO_RL06v2_Land_Mascons_all-corrections_sellonlatbox_invertlat_setmissval.nc GSFC_GRACE_GRACE-FO_RL06v2_Land_Mascons_all-corrections_sellonlatbox_invertlat_setmissval_mulc.nc
#对GSFC进行monmean, 因为某一月可能存在两个产品
cdo -z zip -monmean GSFC_GRACE_GRACE-FO_RL06v2_Land_Mascons_all-corrections_sellonlatbox_invertlat_setmissval_mulc.nc GSFC_GRACE_GRACE-FO_RL06v2_Land_Mascons_all-corrections_sellonlatbox_invertlat_setmissval_mulc_monmean.nc
#选择GSFC对应月份
cdo -z zip -seldate,2002-04-01,2019-12-31 GSFC_GRACE_GRACE-FO_RL06v2_Land_Mascons_all-corrections_sellonlatbox_invertlat_setmissval_mulc_monmean.nc GSFC_GRACE_GRACE-FO_RL06v2_Land_Mascons_all-corrections_sellonlatbox_invertlat_setmissval_mulc_monmean_seldate.nc
#匹配CSR和GSFC的日期后，GSFC需删除2011-11-05,2015-05-02
cdo -z zip -delete,date=2011-11-05,2015-05-02 GSFC_GRACE_GRACE-FO_RL06v2_Land_Mascons_all-corrections_sellonlatbox_invertlat_setmissval_mulc_monmean_seldate.nc GSFC_GRACE_GRACE-FO_RL06v2_Land_Mascons_all-corrections_sellonlatbox_invertlat_setmissval_mulc_monmean_seldate_delete.nc
#输出netCDF文件中数据的存储类型由F64(双精度)转换为F32(单精度)
cdo -b F32 copy GSFC_GRACE_GRACE-FO_RL06v2_Land_Mascons_all-corrections_sellonlatbox_invertlat_setmissval_mulc_monmean_seldate_delete.nc GSFC_GRACE_GRACE-FO_RL06v2_Land_Mascons_all-corrections_sellonlatbox_invertlat_setmissval_mulc_monmean_seldate_delete_copy.nc

#CSR
#使用纬度翻转后的陆地掩膜提取CSR
cdo -z zip -setctomiss,0 CSR_GRACE_GRACE-FO_RL06_Mascons_v02_LandMask_sellonlatbox_invertlat.nc CSR_GRACE_GRACE-FO_RL06_Mascons_v02_LandMask_sellonlatbox_invertlat_setctomiss.nc
cdo -z zip -mul CSR_GRACE_GRACE-FO_RL0603_Mascons_all-corrections_settaxis_sellonlatbox.nc CSR_GRACE_GRACE-FO_RL06_Mascons_v02_LandMask_sellonlatbox_invertlat_setctomiss.nc CSR_GRACE_GRACE-FO_RL0603_Land_Mascons_all-corrections_settaxis_sellonlatbox.nc
cdo -z zip -setmissval,-99999 CSR_GRACE_GRACE-FO_RL0603_Land_Mascons_all-corrections_settaxis_sellonlatbox.nc CSR_GRACE_GRACE-FO_RL0603_Land_Mascons_all-corrections_settaxis_sellonlatbox_setmissval.nc
#将mascons的单位cm换算为mm
cdo -z zip -mulc,10 CSR_GRACE_GRACE-FO_RL0603_Land_Mascons_all-corrections_settaxis_sellonlatbox_setmissval.nc CSR_GRACE_GRACE-FO_RL0603_Land_Mascons_all-corrections_settaxis_sellonlatbox_setmissval_mulc.nc
#对CSR进行monmean, 因为某一月可能存在两个产品
cdo -z zip -monmean CSR_GRACE_GRACE-FO_RL0603_Land_Mascons_all-corrections_settaxis_sellonlatbox_setmissval_mulc.nc CSR_GRACE_GRACE-FO_RL0603_Land_Mascons_all-corrections_settaxis_sellonlatbox_setmissval_mulc_monmean.nc
#选择CSR对应月份
cdo -z zip -seldate,2002-04-01,2019-12-31 CSR_GRACE_GRACE-FO_RL0603_Land_Mascons_all-corrections_settaxis_sellonlatbox_setmissval_mulc_monmean.nc CSR_GRACE_GRACE-FO_RL0603_Land_Mascons_all-corrections_settaxis_sellonlatbox_setmissval_mulc_monmean_seldate.nc
#匹配CSR和GSFC的日期后，CSR需删除2018-10-31
cdo -z zip -delete,date=2018-10-31 CSR_GRACE_GRACE-FO_RL0603_Land_Mascons_all-corrections_settaxis_sellonlatbox_setmissval_mulc_monmean_seldate.nc CSR_GRACE_GRACE-FO_RL0603_Land_Mascons_all-corrections_settaxis_sellonlatbox_setmissval_mulc_monmean_seldate_delete.nc
#将0.25度CSR重投影成0.5度,与0.5度GSFC相匹配
cdo -z zip -remapbil,GSFC_GRACE_GRACE-FO_RL06v2_Land_Mascons_all-corrections_sellonlatbox_invertlat_setmissval_mulc_monmean_seldate_delete_copy.nc CSR_GRACE_GRACE-FO_RL0603_Land_Mascons_all-corrections_settaxis_sellonlatbox_setmissval_mulc_monmean_seldate_delete.nc CSR_GRACE_GRACE-FO_RL0603_Land_Mascons_all-corrections_settaxis_sellonlatbox_setmissval_mulc_monmean_seldate_delete_remapbil.nc

#集成平均
cdo -z zip -ensmean CSR_GRACE_GRACE-FO_RL0603_Land_Mascons_all-corrections_settaxis_sellonlatbox_setmissval_mulc_monmean_seldate_delete_remapbil.nc GSFC_GRACE_GRACE-FO_RL06v2_Land_Mascons_all-corrections_sellonlatbox_invertlat_setmissval_mulc_monmean_seldate_delete_copy.nc BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean.nc
cdo -z zip -ensstd CSR_GRACE_GRACE-FO_RL0603_Land_Mascons_all-corrections_settaxis_sellonlatbox_setmissval_mulc_monmean_seldate_delete_remapbil.nc GSFC_GRACE_GRACE-FO_RL06v2_Land_Mascons_all-corrections_sellonlatbox_invertlat_setmissval_mulc_monmean_seldate_delete_copy.nc BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd.nc

#prcglobwb的TWS单位是m
#对pcrglobwb进行setmissval
cdo -z zip -setmissval,-99999 pcrglobwb_cmip6-isimip3-gswp3-w5e5_image-aqueduct_historical-reference_totalWaterStorageThickness_global_monthly-average_1960_2019_basetier1.nc pcrglobwb_cmip6-isimip3-gswp3-w5e5_image-aqueduct_historical-reference_totalWaterStorageThickness_global_monthly-average_1960_2019_basetier1_setmissval.nc
#pcrglobwb的tws单位为m，乘以1000后换算成mm
cdo -z zip -mulc,1000 pcrglobwb_cmip6-isimip3-gswp3-w5e5_image-aqueduct_historical-reference_totalWaterStorageThickness_global_monthly-average_1960_2019_basetier1_setmissval.nc pcrglobwb_cmip6-isimip3-gswp3-w5e5_image-aqueduct_historical-reference_totalWaterStorageThickness_global_monthly-average_1960_2019_basetier1_setmissval_mulc.nc
#计算baseline 200401_200912
cdo -z zip -seldate,2004-01-01,2009-12-31 pcrglobwb_cmip6-isimip3-gswp3-w5e5_image-aqueduct_historical-reference_totalWaterStorageThickness_global_monthly-average_1960_2019_basetier1_setmissval_mulc.nc pcrglobwb_cmip6-isimip3-gswp3-w5e5_image-aqueduct_historical-reference_totalWaterStorageThickness_global_monthly-average_2004_2009_basetier1_setmissval_mulc.nc 
cdo -z zip -timmean pcrglobwb_cmip6-isimip3-gswp3-w5e5_image-aqueduct_historical-reference_totalWaterStorageThickness_global_monthly-average_2004_2009_basetier1_setmissval_mulc.nc pcrglobwb_cmip6-isimip3-gswp3-w5e5_image-aqueduct_historical-reference_totalWaterStorageThickness_global_monthly-average_2004_2009_basetier1_setmissval_mulc_timmean.nc
cdo -z zip -sub pcrglobwb_cmip6-isimip3-gswp3-w5e5_image-aqueduct_historical-reference_totalWaterStorageThickness_global_monthly-average_1960_2019_basetier1_setmissval_mulc.nc pcrglobwb_cmip6-isimip3-gswp3-w5e5_image-aqueduct_historical-reference_totalWaterStorageThickness_global_monthly-average_2004_2009_basetier1_setmissval_mulc_timmean.nc pcrglobwb_cmip6-isimip3-gswp3-w5e5_image-aqueduct_historical-reference_totalWaterStorageThickness_global_monthly-average_1960_2019_basetier1_setmissval_mulc_timmean_sub.nc
cdo -z zip -setname,lwe_thickness pcrglobwb_cmip6-isimip3-gswp3-w5e5_image-aqueduct_historical-reference_totalWaterStorageThickness_global_monthly-average_1960_2019_basetier1_setmissval_mulc_timmean_sub.nc pcrglobwb_cmip6-isimip3-gswp3-w5e5_image-aqueduct_historical-reference_totalWaterStorageThickness_global_monthly-average_1960_2019_basetier1_setmissval_mulc_timmean_sub_setname.nc
#remapbil到BOTH
cdo -z zip -remapbil,BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean.nc pcrglobwb_cmip6-isimip3-gswp3-w5e5_image-aqueduct_historical-reference_totalWaterStorageThickness_global_monthly-average_1960_2019_basetier1_setmissval_mulc_timmean_sub_setname.nc pcrglobwb_cmip6-isimip3-gswp3-w5e5_image-aqueduct_historical-reference_totalWaterStorageThickness_global_monthly-average_1960_2019_basetier1_setmissval_mulc_timmean_sub_setname_remapbil.nc
#选择模型对应月份(2002-04-01，2019-12-31)
cdo -z zip -seldate,2002-04-01,2019-12-31 pcrglobwb_cmip6-isimip3-gswp3-w5e5_image-aqueduct_historical-reference_totalWaterStorageThickness_global_monthly-average_1960_2019_basetier1_setmissval_mulc_timmean_sub_setname_remapbil.nc pcrglobwb_cmip6-isimip3-gswp3-w5e5_image-aqueduct_historical-reference_totalWaterStorageThickness_global_monthly-average_2002_2019_basetier1_setmissval_mulc_timmean_sub_setname_remapbil.nc
#删除BOTH对应月份delete,date=2002-06,2002-07,2003-06,2011-01,2011-06,2011-11,2012-05,2012-10,2013-03,2013-08,2013-09,2014-02,2014-07,2014-12,2015-05,2015-06,2015-10,2015-11,2016-04,2016-09,2016-10,2017-02,2017-07,2017-08,2017-09,2017-10,2017-11,2017-12,2018-01,2018-02,2018-03,2018-04,2018-05,2018-08,2018-09,2018-10
cdo -z zip -delete,date=2002-06-30,2002-07-31,2003-06-30,2011-01-31,2011-06-30,2011-11-30,2012-05-31,2012-10-31,2013-03-31,2013-08-31,2013-09-30,2014-02-28,2014-07-31,2014-12-31,2015-05-31,2015-06-30,2015-10-31,2015-11-30,2016-04-30,2016-09-30,2016-10-31,2017-02-28,2017-07-31,2017-08-31,2017-09-30,2017-10-31,2017-11-30,2017-12-31,2018-01-31,2018-02-28,2018-03-31,2018-04-30,2018-05-31,2018-08-31,2018-09-30,2018-10-31 pcrglobwb_cmip6-isimip3-gswp3-w5e5_image-aqueduct_historical-reference_totalWaterStorageThickness_global_monthly-average_2002_2019_basetier1_setmissval_mulc_timmean_sub_setname_remapbil.nc pcrglobwb_cmip6-isimip3-gswp3-w5e5_image-aqueduct_historical-reference_totalWaterStorageThickness_global_monthly-average_2002_2019_basetier1_setmissval_mulc_timmean_sub_setname_remapbil_delete.nc

#watergap的TWS单位是mm
#对watergap进行setmissval
cdo -z zip -setmissval,-99999 watergap_22d_gswp3-w5e5_histsoc_tws_monthly_1901_2019.nc4 watergap_22d_gswp3-w5e5_histsoc_tws_monthly_1901_2019_setmissval.nc
#计算baseline 200401_200912
cdo -z zip -seldate,2004-01-01,2009-12-31 watergap_22d_gswp3-w5e5_histsoc_tws_monthly_1901_2019_setmissval.nc watergap_22d_gswp3-w5e5_histsoc_tws_monthly_2004_2009_setmissval.nc
cdo -z zip -timmean watergap_22d_gswp3-w5e5_histsoc_tws_monthly_2004_2009_setmissval.nc watergap_22d_gswp3-w5e5_histsoc_tws_monthly_2004_2009_setmissval_timmean.nc
cdo -z zip -sub watergap_22d_gswp3-w5e5_histsoc_tws_monthly_1901_2019_setmissval.nc watergap_22d_gswp3-w5e5_histsoc_tws_monthly_2004_2009_setmissval_timmean.nc watergap_22d_gswp3-w5e5_histsoc_tws_monthly_1901_2019_setmissval_sub.nc
cdo -z zip -setname,lwe_thickness watergap_22d_gswp3-w5e5_histsoc_tws_monthly_1901_2019_setmissval_sub.nc watergap_22d_gswp3-w5e5_histsoc_tws_monthly_1901_2019_setmissval_sub_setname.nc
#remapbil到BOTH
cdo -z zip -remapbil,BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean.nc watergap_22d_gswp3-w5e5_histsoc_tws_monthly_1901_2019_setmissval_sub_setname.nc watergap_22d_gswp3-w5e5_histsoc_tws_monthly_1901_2019_setmissval_sub_setname_remapbil.nc
#选择模型对应月份(2002-04-01，2019-12-31)
cdo -z zip -seldate,2002-04-01,2019-12-31 watergap_22d_gswp3-w5e5_histsoc_tws_monthly_1901_2019_setmissval_sub_setname_remapbil.nc watergap_22d_gswp3-w5e5_histsoc_tws_monthly_2002_2019_setmissval_sub_setname_remapbil.nc
#删除BOTH对应月份delete,date=2002-06,2002-07,2003-06,2011-01,2011-06,2011-11,2012-05,2012-10,2013-03,2013-08,2013-09,2014-02,2014-07,2014-12,2015-05,2015-06,2015-10,2015-11,2016-04,2016-09,2016-10,2017-02,2017-07,2017-08,2017-09,2017-10,2017-11,2017-12,2018-01,2018-02,2018-03,2018-04,2018-05,2018-08,2018-09,2018-10
cdo -z zip -delete,date=2002-06-01,2002-07-01,2003-06-01,2011-01-01,2011-06-01,2011-11-01,2012-05-01,2012-10-01,2013-03-01,2013-08-01,2013-09-01,2014-02-01,2014-07-01,2014-12-01,2015-05-01,2015-06-01,2015-10-01,2015-11-01,2016-04-01,2016-09-01,2016-10-01,2017-02-01,2017-07-01,2017-08-01,2017-09-01,2017-10-01,2017-11-01,2017-12-01,2018-01-01,2018-02-01,2018-03-01,2018-04-01,2018-05-01,2018-08-01,2018-09-01,2018-10-01 watergap_22d_gswp3-w5e5_histsoc_tws_monthly_2002_2019_setmissval_sub_setname_remapbil.nc watergap_22d_gswp3-w5e5_histsoc_tws_monthly_2002_2019_setmissval_sub_setname_remapbil_delete.nc

#进行模型TWS的集成平均
cdo -z zip -ensmean pcrglobwb_cmip6-isimip3-gswp3-w5e5_image-aqueduct_historical-reference_totalWaterStorageThickness_global_monthly-average_2002_2019_basetier1_setmissval_mulc_timmean_sub_setname_remapbil_delete.nc watergap_22d_gswp3-w5e5_histsoc_tws_monthly_2002_2019_setmissval_sub_setname_remapbil_delete.nc isimip3_tws_monthly_ensmean.nc
cdo -z zip -ensstd pcrglobwb_cmip6-isimip3-gswp3-w5e5_image-aqueduct_historical-reference_totalWaterStorageThickness_global_monthly-average_2002_2019_basetier1_setmissval_mulc_timmean_sub_setname_remapbil_delete.nc watergap_22d_gswp3-w5e5_histsoc_tws_monthly_2002_2019_setmissval_sub_setname_remapbil_delete.nc isimip3_tws_monthly_ensstd.nc

#BOTH减去模型,对应沙子变化
cdo -z zip -sub BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean.nc isimip3_tws_monthly_ensmean.nc BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub.nc
#将等效水深换算为等效沙厚, 需要除以归一化后的沙子密度1.54g/cm3(沙子容重1.58g/cm3除以水容重1.025g/cm3)
cdo -z zip -divc,1.54 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub.nc BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc

#拆分
cdo -z zip -seldate,2002-04-01,2002-04-30 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20020418.nc
cdo -z zip -seldate,2002-05-01,2002-05-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20020510.nc
cdo -z zip -seldate,2002-08-01,2002-08-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20020816.nc
cdo -z zip -seldate,2002-09-01,2002-09-30 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20020916.nc
cdo -z zip -seldate,2002-10-01,2002-10-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20021016.nc
cdo -z zip -seldate,2002-11-01,2002-11-30 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20021116.nc
cdo -z zip -seldate,2002-12-01,2002-12-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20021216.nc
cdo -z zip -seldate,2003-01-01,2003-01-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20030116.nc
cdo -z zip -seldate,2003-02-01,2003-02-28 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20030215.nc
cdo -z zip -seldate,2003-03-01,2003-03-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20030316.nc
cdo -z zip -seldate,2003-04-01,2003-04-30 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20030416.nc
cdo -z zip -seldate,2003-05-01,2003-05-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20030511.nc
cdo -z zip -seldate,2003-07-01,2003-07-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20030716.nc
cdo -z zip -seldate,2003-08-01,2003-08-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20030816.nc
cdo -z zip -seldate,2003-09-01,2003-09-30 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20030916.nc
cdo -z zip -seldate,2003-10-01,2003-10-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20031016.nc
cdo -z zip -seldate,2003-11-01,2003-11-30 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20031116.nc
cdo -z zip -seldate,2003-12-01,2003-12-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20031216.nc
cdo -z zip -seldate,2004-01-01,2004-01-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20040107.nc
cdo -z zip -seldate,2004-02-01,2004-02-29 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20040217.nc
cdo -z zip -seldate,2004-03-01,2004-03-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20040316.nc
cdo -z zip -seldate,2004-04-01,2004-04-30 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20040416.nc
cdo -z zip -seldate,2004-05-01,2004-05-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20040516.nc
cdo -z zip -seldate,2004-06-01,2004-06-30 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20040616.nc
cdo -z zip -seldate,2004-07-01,2004-07-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20040716.nc
cdo -z zip -seldate,2004-08-01,2004-08-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20040816.nc
cdo -z zip -seldate,2004-09-01,2004-09-30 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20040916.nc
cdo -z zip -seldate,2004-10-01,2004-10-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20041016.nc
cdo -z zip -seldate,2004-11-01,2004-11-30 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20041116.nc
cdo -z zip -seldate,2004-12-01,2004-12-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20041216.nc
cdo -z zip -seldate,2005-01-01,2005-01-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20050116.nc
cdo -z zip -seldate,2005-02-01,2005-02-28 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20050215.nc
cdo -z zip -seldate,2005-03-01,2005-03-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20050316.nc
cdo -z zip -seldate,2005-04-01,2005-04-30 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20050416.nc
cdo -z zip -seldate,2005-05-01,2005-05-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20050516.nc
cdo -z zip -seldate,2005-06-01,2005-06-30 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20050616.nc
cdo -z zip -seldate,2005-07-01,2005-07-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20050716.nc
cdo -z zip -seldate,2005-08-01,2005-08-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20050816.nc
cdo -z zip -seldate,2005-09-01,2005-09-30 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20050916.nc
cdo -z zip -seldate,2005-10-01,2005-10-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20051016.nc
cdo -z zip -seldate,2005-11-01,2005-11-30 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20051116.nc
cdo -z zip -seldate,2005-12-01,2005-12-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20051216.nc
cdo -z zip -seldate,2006-01-01,2006-01-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20060116.nc
cdo -z zip -seldate,2006-02-01,2006-02-28 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20060215.nc
cdo -z zip -seldate,2006-03-01,2006-03-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20060316.nc
cdo -z zip -seldate,2006-04-01,2006-04-30 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20060416.nc
cdo -z zip -seldate,2006-05-01,2006-05-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20060516.nc
cdo -z zip -seldate,2006-06-01,2006-06-30 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20060616.nc
cdo -z zip -seldate,2006-07-01,2006-07-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20060716.nc
cdo -z zip -seldate,2006-08-01,2006-08-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20060816.nc
cdo -z zip -seldate,2006-09-01,2006-09-30 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20060916.nc
cdo -z zip -seldate,2006-10-01,2006-10-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20061016.nc
cdo -z zip -seldate,2006-11-01,2006-11-30 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20061116.nc
cdo -z zip -seldate,2006-12-01,2006-12-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20061216.nc
cdo -z zip -seldate,2007-01-01,2007-01-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20070116.nc
cdo -z zip -seldate,2007-02-01,2007-02-28 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20070214.nc
cdo -z zip -seldate,2007-03-01,2007-03-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20070316.nc
cdo -z zip -seldate,2007-04-01,2007-04-30 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20070416.nc
cdo -z zip -seldate,2007-05-01,2007-05-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20070516.nc
cdo -z zip -seldate,2007-06-01,2007-06-30 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20070616.nc
cdo -z zip -seldate,2007-07-01,2007-07-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20070716.nc
cdo -z zip -seldate,2007-08-01,2007-08-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20070816.nc
cdo -z zip -seldate,2007-09-01,2007-09-30 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20070916.nc
cdo -z zip -seldate,2007-10-01,2007-10-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20071016.nc
cdo -z zip -seldate,2007-11-01,2007-11-30 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20071116.nc
cdo -z zip -seldate,2007-12-01,2007-12-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20071216.nc
cdo -z zip -seldate,2008-01-01,2008-01-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20080116.nc
cdo -z zip -seldate,2008-02-01,2008-02-29 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20080215.nc
cdo -z zip -seldate,2008-03-01,2008-03-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20080316.nc
cdo -z zip -seldate,2008-04-01,2008-04-30 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20080416.nc
cdo -z zip -seldate,2008-05-01,2008-05-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20080516.nc
cdo -z zip -seldate,2008-06-01,2008-06-30 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20080616.nc
cdo -z zip -seldate,2008-07-01,2008-07-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20080716.nc
cdo -z zip -seldate,2008-08-01,2008-08-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20080816.nc
cdo -z zip -seldate,2008-09-01,2008-09-30 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20080916.nc
cdo -z zip -seldate,2008-10-01,2008-10-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20081016.nc
cdo -z zip -seldate,2008-11-01,2008-11-30 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20081116.nc
cdo -z zip -seldate,2008-12-01,2008-12-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20081216.nc
cdo -z zip -seldate,2009-01-01,2009-01-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20090116.nc
cdo -z zip -seldate,2009-02-01,2009-02-28 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20090215.nc
cdo -z zip -seldate,2009-03-01,2009-03-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20090316.nc
cdo -z zip -seldate,2009-04-01,2009-04-30 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20090416.nc
cdo -z zip -seldate,2009-05-01,2009-05-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20090516.nc
cdo -z zip -seldate,2009-06-01,2009-06-30 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20090616.nc
cdo -z zip -seldate,2009-07-01,2009-07-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20090716.nc
cdo -z zip -seldate,2009-08-01,2009-08-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20090816.nc
cdo -z zip -seldate,2009-09-01,2009-09-30 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20090916.nc
cdo -z zip -seldate,2009-10-01,2009-10-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20091016.nc
cdo -z zip -seldate,2009-11-01,2009-11-30 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20091116.nc
cdo -z zip -seldate,2009-12-01,2009-12-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20091216.nc
cdo -z zip -seldate,2010-01-01,2010-01-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20100116.nc
cdo -z zip -seldate,2010-02-01,2010-02-28 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20100215.nc
cdo -z zip -seldate,2010-03-01,2010-03-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20100316.nc
cdo -z zip -seldate,2010-04-01,2010-04-30 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20100416.nc
cdo -z zip -seldate,2010-05-01,2010-05-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20100516.nc
cdo -z zip -seldate,2010-06-01,2010-06-30 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20100616.nc
cdo -z zip -seldate,2010-07-01,2010-07-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20100716.nc
cdo -z zip -seldate,2010-08-01,2010-08-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20100816.nc
cdo -z zip -seldate,2010-09-01,2010-09-30 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20100916.nc
cdo -z zip -seldate,2010-10-01,2010-10-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20101016.nc
cdo -z zip -seldate,2010-11-01,2010-11-30 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20101116.nc
cdo -z zip -seldate,2010-12-01,2010-12-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20101214.nc
cdo -z zip -seldate,2011-02-01,2011-02-28 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20110218.nc
cdo -z zip -seldate,2011-03-01,2011-03-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20110316.nc
cdo -z zip -seldate,2011-04-01,2011-04-30 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20110416.nc
cdo -z zip -seldate,2011-05-01,2011-05-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20110516.nc
cdo -z zip -seldate,2011-07-01,2011-07-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20110718.nc
cdo -z zip -seldate,2011-08-01,2011-08-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20110816.nc
cdo -z zip -seldate,2011-09-01,2011-09-30 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20110916.nc
cdo -z zip -seldate,2011-10-01,2011-10-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20111018.nc
cdo -z zip -seldate,2011-12-01,2011-12-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20111226.nc
cdo -z zip -seldate,2012-01-01,2012-01-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20120117.nc
cdo -z zip -seldate,2012-02-01,2012-02-29 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20120215.nc
cdo -z zip -seldate,2012-03-01,2012-03-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20120315.nc
cdo -z zip -seldate,2012-04-01,2012-04-30 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20120405.nc
cdo -z zip -seldate,2012-06-01,2012-06-30 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20120616.nc
cdo -z zip -seldate,2012-07-01,2012-07-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20120716.nc
cdo -z zip -seldate,2012-08-01,2012-08-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20120816.nc
cdo -z zip -seldate,2012-09-01,2012-09-30 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20120913.nc
cdo -z zip -seldate,2012-11-01,2012-11-30 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20121118.nc
cdo -z zip -seldate,2012-12-01,2012-12-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20121216.nc
cdo -z zip -seldate,2013-01-01,2013-01-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20130116.nc
cdo -z zip -seldate,2013-02-01,2013-02-28 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20130214.nc
cdo -z zip -seldate,2013-04-01,2013-04-30 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20130421.nc
cdo -z zip -seldate,2013-05-01,2013-05-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20130516.nc
cdo -z zip -seldate,2013-06-01,2013-06-30 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20130616.nc
cdo -z zip -seldate,2013-07-01,2013-07-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20130716.nc
cdo -z zip -seldate,2013-10-01,2013-10-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20131016.nc
cdo -z zip -seldate,2013-11-01,2013-11-30 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20131116.nc
cdo -z zip -seldate,2013-12-01,2013-12-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20131216.nc
cdo -z zip -seldate,2014-01-01,2014-01-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20140109.nc
cdo -z zip -seldate,2014-03-01,2014-03-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20140317.nc
cdo -z zip -seldate,2014-04-01,2014-04-30 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20140416.nc
cdo -z zip -seldate,2014-05-01,2014-05-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20140516.nc
cdo -z zip -seldate,2014-06-01,2014-06-30 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20140613.nc
cdo -z zip -seldate,2014-08-01,2014-08-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20140816.nc
cdo -z zip -seldate,2014-09-01,2014-09-30 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20140916.nc
cdo -z zip -seldate,2014-10-01,2014-10-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20141016.nc
cdo -z zip -seldate,2014-11-01,2014-11-30 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20141116.nc
cdo -z zip -seldate,2015-01-01,2015-01-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20150122.nc
cdo -z zip -seldate,2015-02-01,2015-02-28 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20150215.nc
cdo -z zip -seldate,2015-03-01,2015-03-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20150316.nc
cdo -z zip -seldate,2015-04-01,2015-04-30 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20150416.nc
cdo -z zip -seldate,2015-07-01,2015-07-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20150715.nc
cdo -z zip -seldate,2015-08-01,2015-08-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20150816.nc
cdo -z zip -seldate,2015-09-01,2015-09-30 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20150914.nc
cdo -z zip -seldate,2015-12-01,2015-12-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20151223.nc
cdo -z zip -seldate,2016-01-01,2016-01-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20160116.nc
cdo -z zip -seldate,2016-02-01,2016-02-29 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20160214.nc
cdo -z zip -seldate,2016-03-01,2016-03-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20160316.nc
cdo -z zip -seldate,2016-05-01,2016-05-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20160520.nc
cdo -z zip -seldate,2016-06-01,2016-06-30 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20160616.nc
cdo -z zip -seldate,2016-07-01,2016-07-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20160715.nc
cdo -z zip -seldate,2016-08-01,2016-08-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20160821.nc
cdo -z zip -seldate,2016-11-01,2016-11-30 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20161127.nc
cdo -z zip -seldate,2016-12-01,2016-12-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20161224.nc
cdo -z zip -seldate,2017-01-01,2017-01-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20170121.nc
cdo -z zip -seldate,2017-03-01,2017-03-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20170331.nc
cdo -z zip -seldate,2017-04-01,2017-04-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20170424.nc
cdo -z zip -seldate,2017-05-01,2017-05-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20170514.nc
cdo -z zip -seldate,2017-06-01,2017-06-30 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20170610.nc
cdo -z zip -seldate,2018-06-01,2018-06-30 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20180616.nc
cdo -z zip -seldate,2018-07-01,2018-07-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20180710.nc
cdo -z zip -seldate,2018-11-01,2018-11-30 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20181113.nc
cdo -z zip -seldate,2018-12-01,2018-12-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20181216.nc
cdo -z zip -seldate,2019-01-01,2019-01-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20190115.nc
cdo -z zip -seldate,2019-02-01,2019-02-28 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20190213.nc
cdo -z zip -seldate,2019-03-01,2019-03-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20190316.nc
cdo -z zip -seldate,2019-04-01,2019-04-30 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20190416.nc
cdo -z zip -seldate,2019-05-01,2019-05-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20190516.nc
cdo -z zip -seldate,2019-06-01,2019-06-30 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20190616.nc
cdo -z zip -seldate,2019-07-01,2019-07-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20190716.nc
cdo -z zip -seldate,2019-08-01,2019-08-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20190816.nc
cdo -z zip -seldate,2019-09-01,2019-09-30 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20190916.nc
cdo -z zip -seldate,2019-10-01,2019-10-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20191016.nc
cdo -z zip -seldate,2019-11-01,2019-11-30 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20191116.nc
cdo -z zip -seldate,2019-12-01,2019-12-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_20191216.nc
#分解
#cdo splitsel,1 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensmean_sub_divc.nc both_mscn_sub_isimip3_

#误差传递
cdo -z zip -sqr BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd.nc BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr.nc
cdo -z zip -sqr isimip3_tws_monthly_ensstd.nc isimip3_tws_monthly_ensstd_sqr.nc
cdo -z zip -enssum BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr.nc isimip3_tws_monthly_ensstd.nc BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum.nc
cdo -z zip -sqrt BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum.nc BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt.nc
cdo -z zip -divc,1.54 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt.nc BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc
#拆分
cdo -z zip -seldate,2002-04-01,2002-04-30 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20020418.nc
cdo -z zip -seldate,2002-05-01,2002-05-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20020510.nc
cdo -z zip -seldate,2002-08-01,2002-08-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20020816.nc
cdo -z zip -seldate,2002-09-01,2002-09-30 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20020916.nc
cdo -z zip -seldate,2002-10-01,2002-10-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20021016.nc
cdo -z zip -seldate,2002-11-01,2002-11-30 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20021116.nc
cdo -z zip -seldate,2002-12-01,2002-12-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20021216.nc
cdo -z zip -seldate,2003-01-01,2003-01-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20030116.nc
cdo -z zip -seldate,2003-02-01,2003-02-28 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20030215.nc
cdo -z zip -seldate,2003-03-01,2003-03-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20030316.nc
cdo -z zip -seldate,2003-04-01,2003-04-30 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20030416.nc
cdo -z zip -seldate,2003-05-01,2003-05-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20030511.nc
cdo -z zip -seldate,2003-07-01,2003-07-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20030716.nc
cdo -z zip -seldate,2003-08-01,2003-08-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20030816.nc
cdo -z zip -seldate,2003-09-01,2003-09-30 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20030916.nc
cdo -z zip -seldate,2003-10-01,2003-10-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20031016.nc
cdo -z zip -seldate,2003-11-01,2003-11-30 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20031116.nc
cdo -z zip -seldate,2003-12-01,2003-12-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20031216.nc
cdo -z zip -seldate,2004-01-01,2004-01-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20040107.nc
cdo -z zip -seldate,2004-02-01,2004-02-29 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20040217.nc
cdo -z zip -seldate,2004-03-01,2004-03-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20040316.nc
cdo -z zip -seldate,2004-04-01,2004-04-30 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20040416.nc
cdo -z zip -seldate,2004-05-01,2004-05-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20040516.nc
cdo -z zip -seldate,2004-06-01,2004-06-30 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20040616.nc
cdo -z zip -seldate,2004-07-01,2004-07-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20040716.nc
cdo -z zip -seldate,2004-08-01,2004-08-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20040816.nc
cdo -z zip -seldate,2004-09-01,2004-09-30 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20040916.nc
cdo -z zip -seldate,2004-10-01,2004-10-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20041016.nc
cdo -z zip -seldate,2004-11-01,2004-11-30 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20041116.nc
cdo -z zip -seldate,2004-12-01,2004-12-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20041216.nc
cdo -z zip -seldate,2005-01-01,2005-01-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20050116.nc
cdo -z zip -seldate,2005-02-01,2005-02-28 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20050215.nc
cdo -z zip -seldate,2005-03-01,2005-03-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20050316.nc
cdo -z zip -seldate,2005-04-01,2005-04-30 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20050416.nc
cdo -z zip -seldate,2005-05-01,2005-05-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20050516.nc
cdo -z zip -seldate,2005-06-01,2005-06-30 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20050616.nc
cdo -z zip -seldate,2005-07-01,2005-07-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20050716.nc
cdo -z zip -seldate,2005-08-01,2005-08-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20050816.nc
cdo -z zip -seldate,2005-09-01,2005-09-30 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20050916.nc
cdo -z zip -seldate,2005-10-01,2005-10-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20051016.nc
cdo -z zip -seldate,2005-11-01,2005-11-30 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20051116.nc
cdo -z zip -seldate,2005-12-01,2005-12-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20051216.nc
cdo -z zip -seldate,2006-01-01,2006-01-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20060116.nc
cdo -z zip -seldate,2006-02-01,2006-02-28 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20060215.nc
cdo -z zip -seldate,2006-03-01,2006-03-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20060316.nc
cdo -z zip -seldate,2006-04-01,2006-04-30 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20060416.nc
cdo -z zip -seldate,2006-05-01,2006-05-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20060516.nc
cdo -z zip -seldate,2006-06-01,2006-06-30 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20060616.nc
cdo -z zip -seldate,2006-07-01,2006-07-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20060716.nc
cdo -z zip -seldate,2006-08-01,2006-08-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20060816.nc
cdo -z zip -seldate,2006-09-01,2006-09-30 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20060916.nc
cdo -z zip -seldate,2006-10-01,2006-10-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20061016.nc
cdo -z zip -seldate,2006-11-01,2006-11-30 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20061116.nc
cdo -z zip -seldate,2006-12-01,2006-12-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20061216.nc
cdo -z zip -seldate,2007-01-01,2007-01-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20070116.nc
cdo -z zip -seldate,2007-02-01,2007-02-28 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20070214.nc
cdo -z zip -seldate,2007-03-01,2007-03-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20070316.nc
cdo -z zip -seldate,2007-04-01,2007-04-30 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20070416.nc
cdo -z zip -seldate,2007-05-01,2007-05-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20070516.nc
cdo -z zip -seldate,2007-06-01,2007-06-30 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20070616.nc
cdo -z zip -seldate,2007-07-01,2007-07-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20070716.nc
cdo -z zip -seldate,2007-08-01,2007-08-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20070816.nc
cdo -z zip -seldate,2007-09-01,2007-09-30 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20070916.nc
cdo -z zip -seldate,2007-10-01,2007-10-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20071016.nc
cdo -z zip -seldate,2007-11-01,2007-11-30 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20071116.nc
cdo -z zip -seldate,2007-12-01,2007-12-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20071216.nc
cdo -z zip -seldate,2008-01-01,2008-01-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20080116.nc
cdo -z zip -seldate,2008-02-01,2008-02-29 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20080215.nc
cdo -z zip -seldate,2008-03-01,2008-03-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20080316.nc
cdo -z zip -seldate,2008-04-01,2008-04-30 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20080416.nc
cdo -z zip -seldate,2008-05-01,2008-05-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20080516.nc
cdo -z zip -seldate,2008-06-01,2008-06-30 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20080616.nc
cdo -z zip -seldate,2008-07-01,2008-07-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20080716.nc
cdo -z zip -seldate,2008-08-01,2008-08-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20080816.nc
cdo -z zip -seldate,2008-09-01,2008-09-30 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20080916.nc
cdo -z zip -seldate,2008-10-01,2008-10-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20081016.nc
cdo -z zip -seldate,2008-11-01,2008-11-30 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20081116.nc
cdo -z zip -seldate,2008-12-01,2008-12-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20081216.nc
cdo -z zip -seldate,2009-01-01,2009-01-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20090116.nc
cdo -z zip -seldate,2009-02-01,2009-02-28 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20090215.nc
cdo -z zip -seldate,2009-03-01,2009-03-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20090316.nc
cdo -z zip -seldate,2009-04-01,2009-04-30 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20090416.nc
cdo -z zip -seldate,2009-05-01,2009-05-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20090516.nc
cdo -z zip -seldate,2009-06-01,2009-06-30 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20090616.nc
cdo -z zip -seldate,2009-07-01,2009-07-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20090716.nc
cdo -z zip -seldate,2009-08-01,2009-08-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20090816.nc
cdo -z zip -seldate,2009-09-01,2009-09-30 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20090916.nc
cdo -z zip -seldate,2009-10-01,2009-10-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20091016.nc
cdo -z zip -seldate,2009-11-01,2009-11-30 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20091116.nc
cdo -z zip -seldate,2009-12-01,2009-12-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20091216.nc
cdo -z zip -seldate,2010-01-01,2010-01-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20100116.nc
cdo -z zip -seldate,2010-02-01,2010-02-28 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20100215.nc
cdo -z zip -seldate,2010-03-01,2010-03-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20100316.nc
cdo -z zip -seldate,2010-04-01,2010-04-30 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20100416.nc
cdo -z zip -seldate,2010-05-01,2010-05-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20100516.nc
cdo -z zip -seldate,2010-06-01,2010-06-30 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20100616.nc
cdo -z zip -seldate,2010-07-01,2010-07-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20100716.nc
cdo -z zip -seldate,2010-08-01,2010-08-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20100816.nc
cdo -z zip -seldate,2010-09-01,2010-09-30 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20100916.nc
cdo -z zip -seldate,2010-10-01,2010-10-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20101016.nc
cdo -z zip -seldate,2010-11-01,2010-11-30 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20101116.nc
cdo -z zip -seldate,2010-12-01,2010-12-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20101214.nc
cdo -z zip -seldate,2011-02-01,2011-02-28 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20110218.nc
cdo -z zip -seldate,2011-03-01,2011-03-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20110316.nc
cdo -z zip -seldate,2011-04-01,2011-04-30 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20110416.nc
cdo -z zip -seldate,2011-05-01,2011-05-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20110516.nc
cdo -z zip -seldate,2011-07-01,2011-07-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20110718.nc
cdo -z zip -seldate,2011-08-01,2011-08-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20110816.nc
cdo -z zip -seldate,2011-09-01,2011-09-30 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20110916.nc
cdo -z zip -seldate,2011-10-01,2011-10-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20111018.nc
cdo -z zip -seldate,2011-12-01,2011-12-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20111226.nc
cdo -z zip -seldate,2012-01-01,2012-01-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20120117.nc
cdo -z zip -seldate,2012-02-01,2012-02-29 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20120215.nc
cdo -z zip -seldate,2012-03-01,2012-03-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20120315.nc
cdo -z zip -seldate,2012-04-01,2012-04-30 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20120405.nc
cdo -z zip -seldate,2012-06-01,2012-06-30 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20120616.nc
cdo -z zip -seldate,2012-07-01,2012-07-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20120716.nc
cdo -z zip -seldate,2012-08-01,2012-08-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20120816.nc
cdo -z zip -seldate,2012-09-01,2012-09-30 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20120913.nc
cdo -z zip -seldate,2012-11-01,2012-11-30 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20121118.nc
cdo -z zip -seldate,2012-12-01,2012-12-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20121216.nc
cdo -z zip -seldate,2013-01-01,2013-01-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20130116.nc
cdo -z zip -seldate,2013-02-01,2013-02-28 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20130214.nc
cdo -z zip -seldate,2013-04-01,2013-04-30 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20130421.nc
cdo -z zip -seldate,2013-05-01,2013-05-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20130516.nc
cdo -z zip -seldate,2013-06-01,2013-06-30 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20130616.nc
cdo -z zip -seldate,2013-07-01,2013-07-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20130716.nc
cdo -z zip -seldate,2013-10-01,2013-10-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20131016.nc
cdo -z zip -seldate,2013-11-01,2013-11-30 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20131116.nc
cdo -z zip -seldate,2013-12-01,2013-12-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20131216.nc
cdo -z zip -seldate,2014-01-01,2014-01-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20140109.nc
cdo -z zip -seldate,2014-03-01,2014-03-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20140317.nc
cdo -z zip -seldate,2014-04-01,2014-04-30 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20140416.nc
cdo -z zip -seldate,2014-05-01,2014-05-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20140516.nc
cdo -z zip -seldate,2014-06-01,2014-06-30 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20140613.nc
cdo -z zip -seldate,2014-08-01,2014-08-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20140816.nc
cdo -z zip -seldate,2014-09-01,2014-09-30 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20140916.nc
cdo -z zip -seldate,2014-10-01,2014-10-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20141016.nc
cdo -z zip -seldate,2014-11-01,2014-11-30 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20141116.nc
cdo -z zip -seldate,2015-01-01,2015-01-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20150122.nc
cdo -z zip -seldate,2015-02-01,2015-02-28 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20150215.nc
cdo -z zip -seldate,2015-03-01,2015-03-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20150316.nc
cdo -z zip -seldate,2015-04-01,2015-04-30 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20150416.nc
cdo -z zip -seldate,2015-07-01,2015-07-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20150715.nc
cdo -z zip -seldate,2015-08-01,2015-08-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20150816.nc
cdo -z zip -seldate,2015-09-01,2015-09-30 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20150914.nc
cdo -z zip -seldate,2015-12-01,2015-12-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20151223.nc
cdo -z zip -seldate,2016-01-01,2016-01-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20160116.nc
cdo -z zip -seldate,2016-02-01,2016-02-29 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20160214.nc
cdo -z zip -seldate,2016-03-01,2016-03-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20160316.nc
cdo -z zip -seldate,2016-05-01,2016-05-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20160520.nc
cdo -z zip -seldate,2016-06-01,2016-06-30 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20160616.nc
cdo -z zip -seldate,2016-07-01,2016-07-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20160715.nc
cdo -z zip -seldate,2016-08-01,2016-08-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20160821.nc
cdo -z zip -seldate,2016-11-01,2016-11-30 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20161127.nc
cdo -z zip -seldate,2016-12-01,2016-12-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20161224.nc
cdo -z zip -seldate,2017-01-01,2017-01-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20170121.nc
cdo -z zip -seldate,2017-03-01,2017-03-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20170331.nc
cdo -z zip -seldate,2017-04-01,2017-04-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20170424.nc
cdo -z zip -seldate,2017-05-01,2017-05-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20170514.nc
cdo -z zip -seldate,2017-06-01,2017-06-30 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20170610.nc
cdo -z zip -seldate,2018-06-01,2018-06-30 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20180616.nc
cdo -z zip -seldate,2018-07-01,2018-07-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20180710.nc
cdo -z zip -seldate,2018-11-01,2018-11-30 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20181113.nc
cdo -z zip -seldate,2018-12-01,2018-12-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20181216.nc
cdo -z zip -seldate,2019-01-01,2019-01-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20190115.nc
cdo -z zip -seldate,2019-02-01,2019-02-28 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20190213.nc
cdo -z zip -seldate,2019-03-01,2019-03-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20190316.nc
cdo -z zip -seldate,2019-04-01,2019-04-30 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20190416.nc
cdo -z zip -seldate,2019-05-01,2019-05-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20190516.nc
cdo -z zip -seldate,2019-06-01,2019-06-30 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20190616.nc
cdo -z zip -seldate,2019-07-01,2019-07-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20190716.nc
cdo -z zip -seldate,2019-08-01,2019-08-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20190816.nc
cdo -z zip -seldate,2019-09-01,2019-09-30 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20190916.nc
cdo -z zip -seldate,2019-10-01,2019-10-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20191016.nc
cdo -z zip -seldate,2019-11-01,2019-11-30 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20191116.nc
cdo -z zip -seldate,2019-12-01,2019-12-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_20191216.nc

#both_mascons_std, 将等效水深换算为等效沙厚, 需要除以归一化后的沙子密度1.54g/cm3(沙子容重1.58g/cm3除以水容重1.025g/cm3)
cdo -z zip -divc,1.54 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd.nc BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc
#拆分
cdo -z zip -seldate,2002-04-01,2002-04-30 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20020418.nc
cdo -z zip -seldate,2002-05-01,2002-05-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20020510.nc
cdo -z zip -seldate,2002-08-01,2002-08-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20020816.nc
cdo -z zip -seldate,2002-09-01,2002-09-30 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20020916.nc
cdo -z zip -seldate,2002-10-01,2002-10-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20021016.nc
cdo -z zip -seldate,2002-11-01,2002-11-30 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20021116.nc
cdo -z zip -seldate,2002-12-01,2002-12-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20021216.nc
cdo -z zip -seldate,2003-01-01,2003-01-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20030116.nc
cdo -z zip -seldate,2003-02-01,2003-02-28 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20030215.nc
cdo -z zip -seldate,2003-03-01,2003-03-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20030316.nc
cdo -z zip -seldate,2003-04-01,2003-04-30 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20030416.nc
cdo -z zip -seldate,2003-05-01,2003-05-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20030511.nc
cdo -z zip -seldate,2003-07-01,2003-07-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20030716.nc
cdo -z zip -seldate,2003-08-01,2003-08-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20030816.nc
cdo -z zip -seldate,2003-09-01,2003-09-30 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20030916.nc
cdo -z zip -seldate,2003-10-01,2003-10-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20031016.nc
cdo -z zip -seldate,2003-11-01,2003-11-30 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20031116.nc
cdo -z zip -seldate,2003-12-01,2003-12-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20031216.nc
cdo -z zip -seldate,2004-01-01,2004-01-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20040107.nc
cdo -z zip -seldate,2004-02-01,2004-02-29 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20040217.nc
cdo -z zip -seldate,2004-03-01,2004-03-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20040316.nc
cdo -z zip -seldate,2004-04-01,2004-04-30 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20040416.nc
cdo -z zip -seldate,2004-05-01,2004-05-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20040516.nc
cdo -z zip -seldate,2004-06-01,2004-06-30 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20040616.nc
cdo -z zip -seldate,2004-07-01,2004-07-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20040716.nc
cdo -z zip -seldate,2004-08-01,2004-08-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20040816.nc
cdo -z zip -seldate,2004-09-01,2004-09-30 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20040916.nc
cdo -z zip -seldate,2004-10-01,2004-10-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20041016.nc
cdo -z zip -seldate,2004-11-01,2004-11-30 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20041116.nc
cdo -z zip -seldate,2004-12-01,2004-12-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20041216.nc
cdo -z zip -seldate,2005-01-01,2005-01-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20050116.nc
cdo -z zip -seldate,2005-02-01,2005-02-28 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20050215.nc
cdo -z zip -seldate,2005-03-01,2005-03-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20050316.nc
cdo -z zip -seldate,2005-04-01,2005-04-30 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20050416.nc
cdo -z zip -seldate,2005-05-01,2005-05-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20050516.nc
cdo -z zip -seldate,2005-06-01,2005-06-30 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20050616.nc
cdo -z zip -seldate,2005-07-01,2005-07-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20050716.nc
cdo -z zip -seldate,2005-08-01,2005-08-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20050816.nc
cdo -z zip -seldate,2005-09-01,2005-09-30 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20050916.nc
cdo -z zip -seldate,2005-10-01,2005-10-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20051016.nc
cdo -z zip -seldate,2005-11-01,2005-11-30 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20051116.nc
cdo -z zip -seldate,2005-12-01,2005-12-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20051216.nc
cdo -z zip -seldate,2006-01-01,2006-01-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20060116.nc
cdo -z zip -seldate,2006-02-01,2006-02-28 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20060215.nc
cdo -z zip -seldate,2006-03-01,2006-03-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20060316.nc
cdo -z zip -seldate,2006-04-01,2006-04-30 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20060416.nc
cdo -z zip -seldate,2006-05-01,2006-05-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20060516.nc
cdo -z zip -seldate,2006-06-01,2006-06-30 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20060616.nc
cdo -z zip -seldate,2006-07-01,2006-07-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20060716.nc
cdo -z zip -seldate,2006-08-01,2006-08-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20060816.nc
cdo -z zip -seldate,2006-09-01,2006-09-30 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20060916.nc
cdo -z zip -seldate,2006-10-01,2006-10-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20061016.nc
cdo -z zip -seldate,2006-11-01,2006-11-30 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20061116.nc
cdo -z zip -seldate,2006-12-01,2006-12-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20061216.nc
cdo -z zip -seldate,2007-01-01,2007-01-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20070116.nc
cdo -z zip -seldate,2007-02-01,2007-02-28 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20070214.nc
cdo -z zip -seldate,2007-03-01,2007-03-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20070316.nc
cdo -z zip -seldate,2007-04-01,2007-04-30 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20070416.nc
cdo -z zip -seldate,2007-05-01,2007-05-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20070516.nc
cdo -z zip -seldate,2007-06-01,2007-06-30 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20070616.nc
cdo -z zip -seldate,2007-07-01,2007-07-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20070716.nc
cdo -z zip -seldate,2007-08-01,2007-08-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20070816.nc
cdo -z zip -seldate,2007-09-01,2007-09-30 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20070916.nc
cdo -z zip -seldate,2007-10-01,2007-10-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20071016.nc
cdo -z zip -seldate,2007-11-01,2007-11-30 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20071116.nc
cdo -z zip -seldate,2007-12-01,2007-12-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20071216.nc
cdo -z zip -seldate,2008-01-01,2008-01-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20080116.nc
cdo -z zip -seldate,2008-02-01,2008-02-29 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20080215.nc
cdo -z zip -seldate,2008-03-01,2008-03-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20080316.nc
cdo -z zip -seldate,2008-04-01,2008-04-30 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20080416.nc
cdo -z zip -seldate,2008-05-01,2008-05-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20080516.nc
cdo -z zip -seldate,2008-06-01,2008-06-30 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20080616.nc
cdo -z zip -seldate,2008-07-01,2008-07-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20080716.nc
cdo -z zip -seldate,2008-08-01,2008-08-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20080816.nc
cdo -z zip -seldate,2008-09-01,2008-09-30 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20080916.nc
cdo -z zip -seldate,2008-10-01,2008-10-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20081016.nc
cdo -z zip -seldate,2008-11-01,2008-11-30 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20081116.nc
cdo -z zip -seldate,2008-12-01,2008-12-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20081216.nc
cdo -z zip -seldate,2009-01-01,2009-01-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20090116.nc
cdo -z zip -seldate,2009-02-01,2009-02-28 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20090215.nc
cdo -z zip -seldate,2009-03-01,2009-03-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20090316.nc
cdo -z zip -seldate,2009-04-01,2009-04-30 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20090416.nc
cdo -z zip -seldate,2009-05-01,2009-05-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20090516.nc
cdo -z zip -seldate,2009-06-01,2009-06-30 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20090616.nc
cdo -z zip -seldate,2009-07-01,2009-07-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20090716.nc
cdo -z zip -seldate,2009-08-01,2009-08-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20090816.nc
cdo -z zip -seldate,2009-09-01,2009-09-30 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20090916.nc
cdo -z zip -seldate,2009-10-01,2009-10-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20091016.nc
cdo -z zip -seldate,2009-11-01,2009-11-30 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20091116.nc
cdo -z zip -seldate,2009-12-01,2009-12-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20091216.nc
cdo -z zip -seldate,2010-01-01,2010-01-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20100116.nc
cdo -z zip -seldate,2010-02-01,2010-02-28 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20100215.nc
cdo -z zip -seldate,2010-03-01,2010-03-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20100316.nc
cdo -z zip -seldate,2010-04-01,2010-04-30 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20100416.nc
cdo -z zip -seldate,2010-05-01,2010-05-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20100516.nc
cdo -z zip -seldate,2010-06-01,2010-06-30 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20100616.nc
cdo -z zip -seldate,2010-07-01,2010-07-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20100716.nc
cdo -z zip -seldate,2010-08-01,2010-08-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20100816.nc
cdo -z zip -seldate,2010-09-01,2010-09-30 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20100916.nc
cdo -z zip -seldate,2010-10-01,2010-10-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20101016.nc
cdo -z zip -seldate,2010-11-01,2010-11-30 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20101116.nc
cdo -z zip -seldate,2010-12-01,2010-12-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20101214.nc
cdo -z zip -seldate,2011-02-01,2011-02-28 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20110218.nc
cdo -z zip -seldate,2011-03-01,2011-03-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20110316.nc
cdo -z zip -seldate,2011-04-01,2011-04-30 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20110416.nc
cdo -z zip -seldate,2011-05-01,2011-05-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20110516.nc
cdo -z zip -seldate,2011-07-01,2011-07-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20110718.nc
cdo -z zip -seldate,2011-08-01,2011-08-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20110816.nc
cdo -z zip -seldate,2011-09-01,2011-09-30 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20110916.nc
cdo -z zip -seldate,2011-10-01,2011-10-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20111018.nc
cdo -z zip -seldate,2011-12-01,2011-12-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20111226.nc
cdo -z zip -seldate,2012-01-01,2012-01-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20120117.nc
cdo -z zip -seldate,2012-02-01,2012-02-29 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20120215.nc
cdo -z zip -seldate,2012-03-01,2012-03-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20120315.nc
cdo -z zip -seldate,2012-04-01,2012-04-30 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20120405.nc
cdo -z zip -seldate,2012-06-01,2012-06-30 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20120616.nc
cdo -z zip -seldate,2012-07-01,2012-07-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20120716.nc
cdo -z zip -seldate,2012-08-01,2012-08-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20120816.nc
cdo -z zip -seldate,2012-09-01,2012-09-30 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20120913.nc
cdo -z zip -seldate,2012-11-01,2012-11-30 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20121118.nc
cdo -z zip -seldate,2012-12-01,2012-12-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20121216.nc
cdo -z zip -seldate,2013-01-01,2013-01-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20130116.nc
cdo -z zip -seldate,2013-02-01,2013-02-28 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20130214.nc
cdo -z zip -seldate,2013-04-01,2013-04-30 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20130421.nc
cdo -z zip -seldate,2013-05-01,2013-05-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20130516.nc
cdo -z zip -seldate,2013-06-01,2013-06-30 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20130616.nc
cdo -z zip -seldate,2013-07-01,2013-07-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20130716.nc
cdo -z zip -seldate,2013-10-01,2013-10-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20131016.nc
cdo -z zip -seldate,2013-11-01,2013-11-30 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20131116.nc
cdo -z zip -seldate,2013-12-01,2013-12-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20131216.nc
cdo -z zip -seldate,2014-01-01,2014-01-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20140109.nc
cdo -z zip -seldate,2014-03-01,2014-03-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20140317.nc
cdo -z zip -seldate,2014-04-01,2014-04-30 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20140416.nc
cdo -z zip -seldate,2014-05-01,2014-05-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20140516.nc
cdo -z zip -seldate,2014-06-01,2014-06-30 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20140613.nc
cdo -z zip -seldate,2014-08-01,2014-08-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20140816.nc
cdo -z zip -seldate,2014-09-01,2014-09-30 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20140916.nc
cdo -z zip -seldate,2014-10-01,2014-10-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20141016.nc
cdo -z zip -seldate,2014-11-01,2014-11-30 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20141116.nc
cdo -z zip -seldate,2015-01-01,2015-01-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20150122.nc
cdo -z zip -seldate,2015-02-01,2015-02-28 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20150215.nc
cdo -z zip -seldate,2015-03-01,2015-03-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20150316.nc
cdo -z zip -seldate,2015-04-01,2015-04-30 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20150416.nc
cdo -z zip -seldate,2015-07-01,2015-07-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20150715.nc
cdo -z zip -seldate,2015-08-01,2015-08-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20150816.nc
cdo -z zip -seldate,2015-09-01,2015-09-30 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20150914.nc
cdo -z zip -seldate,2015-12-01,2015-12-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20151223.nc
cdo -z zip -seldate,2016-01-01,2016-01-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20160116.nc
cdo -z zip -seldate,2016-02-01,2016-02-29 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20160214.nc
cdo -z zip -seldate,2016-03-01,2016-03-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20160316.nc
cdo -z zip -seldate,2016-05-01,2016-05-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20160520.nc
cdo -z zip -seldate,2016-06-01,2016-06-30 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20160616.nc
cdo -z zip -seldate,2016-07-01,2016-07-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20160715.nc
cdo -z zip -seldate,2016-08-01,2016-08-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20160821.nc
cdo -z zip -seldate,2016-11-01,2016-11-30 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20161127.nc
cdo -z zip -seldate,2016-12-01,2016-12-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20161224.nc
cdo -z zip -seldate,2017-01-01,2017-01-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20170121.nc
cdo -z zip -seldate,2017-03-01,2017-03-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20170331.nc
cdo -z zip -seldate,2017-04-01,2017-04-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20170424.nc
cdo -z zip -seldate,2017-05-01,2017-05-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20170514.nc
cdo -z zip -seldate,2017-06-01,2017-06-30 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20170610.nc
cdo -z zip -seldate,2018-06-01,2018-06-30 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20180616.nc
cdo -z zip -seldate,2018-07-01,2018-07-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20180710.nc
cdo -z zip -seldate,2018-11-01,2018-11-30 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20181113.nc
cdo -z zip -seldate,2018-12-01,2018-12-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20181216.nc
cdo -z zip -seldate,2019-01-01,2019-01-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20190115.nc
cdo -z zip -seldate,2019-02-01,2019-02-28 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20190213.nc
cdo -z zip -seldate,2019-03-01,2019-03-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20190316.nc
cdo -z zip -seldate,2019-04-01,2019-04-30 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20190416.nc
cdo -z zip -seldate,2019-05-01,2019-05-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20190516.nc
cdo -z zip -seldate,2019-06-01,2019-06-30 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20190616.nc
cdo -z zip -seldate,2019-07-01,2019-07-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20190716.nc
cdo -z zip -seldate,2019-08-01,2019-08-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20190816.nc
cdo -z zip -seldate,2019-09-01,2019-09-30 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20190916.nc
cdo -z zip -seldate,2019-10-01,2019-10-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20191016.nc
cdo -z zip -seldate,2019-11-01,2019-11-30 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20191116.nc
cdo -z zip -seldate,2019-12-01,2019-12-31 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_divc.nc both_mascons_std_20191216.nc

#both_models_std
cdo -z zip -divc,1.54 isimip3_tws_monthly_ensstd.nc isimip3_tws_monthly_ensstd_divc.nc
#拆分
cdo -z zip -seldate,2002-04-01,2002-04-30 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20020418.nc
cdo -z zip -seldate,2002-05-01,2002-05-31 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20020510.nc
cdo -z zip -seldate,2002-08-01,2002-08-31 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20020816.nc
cdo -z zip -seldate,2002-09-01,2002-09-30 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20020916.nc
cdo -z zip -seldate,2002-10-01,2002-10-31 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20021016.nc
cdo -z zip -seldate,2002-11-01,2002-11-30 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20021116.nc
cdo -z zip -seldate,2002-12-01,2002-12-31 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20021216.nc
cdo -z zip -seldate,2003-01-01,2003-01-31 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20030116.nc
cdo -z zip -seldate,2003-02-01,2003-02-28 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20030215.nc
cdo -z zip -seldate,2003-03-01,2003-03-31 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20030316.nc
cdo -z zip -seldate,2003-04-01,2003-04-30 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20030416.nc
cdo -z zip -seldate,2003-05-01,2003-05-31 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20030511.nc
cdo -z zip -seldate,2003-07-01,2003-07-31 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20030716.nc
cdo -z zip -seldate,2003-08-01,2003-08-31 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20030816.nc
cdo -z zip -seldate,2003-09-01,2003-09-30 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20030916.nc
cdo -z zip -seldate,2003-10-01,2003-10-31 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20031016.nc
cdo -z zip -seldate,2003-11-01,2003-11-30 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20031116.nc
cdo -z zip -seldate,2003-12-01,2003-12-31 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20031216.nc
cdo -z zip -seldate,2004-01-01,2004-01-31 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20040107.nc
cdo -z zip -seldate,2004-02-01,2004-02-29 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20040217.nc
cdo -z zip -seldate,2004-03-01,2004-03-31 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20040316.nc
cdo -z zip -seldate,2004-04-01,2004-04-30 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20040416.nc
cdo -z zip -seldate,2004-05-01,2004-05-31 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20040516.nc
cdo -z zip -seldate,2004-06-01,2004-06-30 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20040616.nc
cdo -z zip -seldate,2004-07-01,2004-07-31 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20040716.nc
cdo -z zip -seldate,2004-08-01,2004-08-31 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20040816.nc
cdo -z zip -seldate,2004-09-01,2004-09-30 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20040916.nc
cdo -z zip -seldate,2004-10-01,2004-10-31 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20041016.nc
cdo -z zip -seldate,2004-11-01,2004-11-30 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20041116.nc
cdo -z zip -seldate,2004-12-01,2004-12-31 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20041216.nc
cdo -z zip -seldate,2005-01-01,2005-01-31 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20050116.nc
cdo -z zip -seldate,2005-02-01,2005-02-28 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20050215.nc
cdo -z zip -seldate,2005-03-01,2005-03-31 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20050316.nc
cdo -z zip -seldate,2005-04-01,2005-04-30 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20050416.nc
cdo -z zip -seldate,2005-05-01,2005-05-31 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20050516.nc
cdo -z zip -seldate,2005-06-01,2005-06-30 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20050616.nc
cdo -z zip -seldate,2005-07-01,2005-07-31 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20050716.nc
cdo -z zip -seldate,2005-08-01,2005-08-31 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20050816.nc
cdo -z zip -seldate,2005-09-01,2005-09-30 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20050916.nc
cdo -z zip -seldate,2005-10-01,2005-10-31 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20051016.nc
cdo -z zip -seldate,2005-11-01,2005-11-30 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20051116.nc
cdo -z zip -seldate,2005-12-01,2005-12-31 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20051216.nc
cdo -z zip -seldate,2006-01-01,2006-01-31 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20060116.nc
cdo -z zip -seldate,2006-02-01,2006-02-28 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20060215.nc
cdo -z zip -seldate,2006-03-01,2006-03-31 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20060316.nc
cdo -z zip -seldate,2006-04-01,2006-04-30 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20060416.nc
cdo -z zip -seldate,2006-05-01,2006-05-31 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20060516.nc
cdo -z zip -seldate,2006-06-01,2006-06-30 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20060616.nc
cdo -z zip -seldate,2006-07-01,2006-07-31 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20060716.nc
cdo -z zip -seldate,2006-08-01,2006-08-31 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20060816.nc
cdo -z zip -seldate,2006-09-01,2006-09-30 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20060916.nc
cdo -z zip -seldate,2006-10-01,2006-10-31 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20061016.nc
cdo -z zip -seldate,2006-11-01,2006-11-30 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20061116.nc
cdo -z zip -seldate,2006-12-01,2006-12-31 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20061216.nc
cdo -z zip -seldate,2007-01-01,2007-01-31 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20070116.nc
cdo -z zip -seldate,2007-02-01,2007-02-28 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20070214.nc
cdo -z zip -seldate,2007-03-01,2007-03-31 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20070316.nc
cdo -z zip -seldate,2007-04-01,2007-04-30 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20070416.nc
cdo -z zip -seldate,2007-05-01,2007-05-31 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20070516.nc
cdo -z zip -seldate,2007-06-01,2007-06-30 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20070616.nc
cdo -z zip -seldate,2007-07-01,2007-07-31 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20070716.nc
cdo -z zip -seldate,2007-08-01,2007-08-31 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20070816.nc
cdo -z zip -seldate,2007-09-01,2007-09-30 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20070916.nc
cdo -z zip -seldate,2007-10-01,2007-10-31 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20071016.nc
cdo -z zip -seldate,2007-11-01,2007-11-30 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20071116.nc
cdo -z zip -seldate,2007-12-01,2007-12-31 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20071216.nc
cdo -z zip -seldate,2008-01-01,2008-01-31 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20080116.nc
cdo -z zip -seldate,2008-02-01,2008-02-29 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20080215.nc
cdo -z zip -seldate,2008-03-01,2008-03-31 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20080316.nc
cdo -z zip -seldate,2008-04-01,2008-04-30 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20080416.nc
cdo -z zip -seldate,2008-05-01,2008-05-31 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20080516.nc
cdo -z zip -seldate,2008-06-01,2008-06-30 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20080616.nc
cdo -z zip -seldate,2008-07-01,2008-07-31 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20080716.nc
cdo -z zip -seldate,2008-08-01,2008-08-31 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20080816.nc
cdo -z zip -seldate,2008-09-01,2008-09-30 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20080916.nc
cdo -z zip -seldate,2008-10-01,2008-10-31 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20081016.nc
cdo -z zip -seldate,2008-11-01,2008-11-30 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20081116.nc
cdo -z zip -seldate,2008-12-01,2008-12-31 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20081216.nc
cdo -z zip -seldate,2009-01-01,2009-01-31 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20090116.nc
cdo -z zip -seldate,2009-02-01,2009-02-28 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20090215.nc
cdo -z zip -seldate,2009-03-01,2009-03-31 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20090316.nc
cdo -z zip -seldate,2009-04-01,2009-04-30 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20090416.nc
cdo -z zip -seldate,2009-05-01,2009-05-31 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20090516.nc
cdo -z zip -seldate,2009-06-01,2009-06-30 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20090616.nc
cdo -z zip -seldate,2009-07-01,2009-07-31 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20090716.nc
cdo -z zip -seldate,2009-08-01,2009-08-31 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20090816.nc
cdo -z zip -seldate,2009-09-01,2009-09-30 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20090916.nc
cdo -z zip -seldate,2009-10-01,2009-10-31 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20091016.nc
cdo -z zip -seldate,2009-11-01,2009-11-30 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20091116.nc
cdo -z zip -seldate,2009-12-01,2009-12-31 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20091216.nc
cdo -z zip -seldate,2010-01-01,2010-01-31 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20100116.nc
cdo -z zip -seldate,2010-02-01,2010-02-28 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20100215.nc
cdo -z zip -seldate,2010-03-01,2010-03-31 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20100316.nc
cdo -z zip -seldate,2010-04-01,2010-04-30 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20100416.nc
cdo -z zip -seldate,2010-05-01,2010-05-31 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20100516.nc
cdo -z zip -seldate,2010-06-01,2010-06-30 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20100616.nc
cdo -z zip -seldate,2010-07-01,2010-07-31 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20100716.nc
cdo -z zip -seldate,2010-08-01,2010-08-31 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20100816.nc
cdo -z zip -seldate,2010-09-01,2010-09-30 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20100916.nc
cdo -z zip -seldate,2010-10-01,2010-10-31 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20101016.nc
cdo -z zip -seldate,2010-11-01,2010-11-30 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20101116.nc
cdo -z zip -seldate,2010-12-01,2010-12-31 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20101214.nc
cdo -z zip -seldate,2011-02-01,2011-02-28 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20110218.nc
cdo -z zip -seldate,2011-03-01,2011-03-31 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20110316.nc
cdo -z zip -seldate,2011-04-01,2011-04-30 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20110416.nc
cdo -z zip -seldate,2011-05-01,2011-05-31 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20110516.nc
cdo -z zip -seldate,2011-07-01,2011-07-31 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20110718.nc
cdo -z zip -seldate,2011-08-01,2011-08-31 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20110816.nc
cdo -z zip -seldate,2011-09-01,2011-09-30 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20110916.nc
cdo -z zip -seldate,2011-10-01,2011-10-31 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20111018.nc
cdo -z zip -seldate,2011-12-01,2011-12-31 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20111226.nc
cdo -z zip -seldate,2012-01-01,2012-01-31 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20120117.nc
cdo -z zip -seldate,2012-02-01,2012-02-29 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20120215.nc
cdo -z zip -seldate,2012-03-01,2012-03-31 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20120315.nc
cdo -z zip -seldate,2012-04-01,2012-04-30 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20120405.nc
cdo -z zip -seldate,2012-06-01,2012-06-30 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20120616.nc
cdo -z zip -seldate,2012-07-01,2012-07-31 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20120716.nc
cdo -z zip -seldate,2012-08-01,2012-08-31 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20120816.nc
cdo -z zip -seldate,2012-09-01,2012-09-30 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20120913.nc
cdo -z zip -seldate,2012-11-01,2012-11-30 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20121118.nc
cdo -z zip -seldate,2012-12-01,2012-12-31 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20121216.nc
cdo -z zip -seldate,2013-01-01,2013-01-31 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20130116.nc
cdo -z zip -seldate,2013-02-01,2013-02-28 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20130214.nc
cdo -z zip -seldate,2013-04-01,2013-04-30 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20130421.nc
cdo -z zip -seldate,2013-05-01,2013-05-31 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20130516.nc
cdo -z zip -seldate,2013-06-01,2013-06-30 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20130616.nc
cdo -z zip -seldate,2013-07-01,2013-07-31 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20130716.nc
cdo -z zip -seldate,2013-10-01,2013-10-31 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20131016.nc
cdo -z zip -seldate,2013-11-01,2013-11-30 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20131116.nc
cdo -z zip -seldate,2013-12-01,2013-12-31 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20131216.nc
cdo -z zip -seldate,2014-01-01,2014-01-31 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20140109.nc
cdo -z zip -seldate,2014-03-01,2014-03-31 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20140317.nc
cdo -z zip -seldate,2014-04-01,2014-04-30 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20140416.nc
cdo -z zip -seldate,2014-05-01,2014-05-31 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20140516.nc
cdo -z zip -seldate,2014-06-01,2014-06-30 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20140613.nc
cdo -z zip -seldate,2014-08-01,2014-08-31 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20140816.nc
cdo -z zip -seldate,2014-09-01,2014-09-30 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20140916.nc
cdo -z zip -seldate,2014-10-01,2014-10-31 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20141016.nc
cdo -z zip -seldate,2014-11-01,2014-11-30 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20141116.nc
cdo -z zip -seldate,2015-01-01,2015-01-31 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20150122.nc
cdo -z zip -seldate,2015-02-01,2015-02-28 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20150215.nc
cdo -z zip -seldate,2015-03-01,2015-03-31 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20150316.nc
cdo -z zip -seldate,2015-04-01,2015-04-30 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20150416.nc
cdo -z zip -seldate,2015-07-01,2015-07-31 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20150715.nc
cdo -z zip -seldate,2015-08-01,2015-08-31 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20150816.nc
cdo -z zip -seldate,2015-09-01,2015-09-30 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20150914.nc
cdo -z zip -seldate,2015-12-01,2015-12-31 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20151223.nc
cdo -z zip -seldate,2016-01-01,2016-01-31 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20160116.nc
cdo -z zip -seldate,2016-02-01,2016-02-29 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20160214.nc
cdo -z zip -seldate,2016-03-01,2016-03-31 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20160316.nc
cdo -z zip -seldate,2016-05-01,2016-05-31 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20160520.nc
cdo -z zip -seldate,2016-06-01,2016-06-30 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20160616.nc
cdo -z zip -seldate,2016-07-01,2016-07-31 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20160715.nc
cdo -z zip -seldate,2016-08-01,2016-08-31 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20160821.nc
cdo -z zip -seldate,2016-11-01,2016-11-30 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20161127.nc
cdo -z zip -seldate,2016-12-01,2016-12-31 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20161224.nc
cdo -z zip -seldate,2017-01-01,2017-01-31 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20170121.nc
cdo -z zip -seldate,2017-03-01,2017-03-31 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20170331.nc
cdo -z zip -seldate,2017-04-01,2017-04-31 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20170424.nc
cdo -z zip -seldate,2017-05-01,2017-05-31 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20170514.nc
cdo -z zip -seldate,2017-06-01,2017-06-30 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20170610.nc
cdo -z zip -seldate,2018-06-01,2018-06-30 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20180616.nc
cdo -z zip -seldate,2018-07-01,2018-07-31 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20180710.nc
cdo -z zip -seldate,2018-11-01,2018-11-30 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20181113.nc
cdo -z zip -seldate,2018-12-01,2018-12-31 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20181216.nc
cdo -z zip -seldate,2019-01-01,2019-01-31 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20190115.nc
cdo -z zip -seldate,2019-02-01,2019-02-28 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20190213.nc
cdo -z zip -seldate,2019-03-01,2019-03-31 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20190316.nc
cdo -z zip -seldate,2019-04-01,2019-04-30 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20190416.nc
cdo -z zip -seldate,2019-05-01,2019-05-31 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20190516.nc
cdo -z zip -seldate,2019-06-01,2019-06-30 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20190616.nc
cdo -z zip -seldate,2019-07-01,2019-07-31 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20190716.nc
cdo -z zip -seldate,2019-08-01,2019-08-31 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20190816.nc
cdo -z zip -seldate,2019-09-01,2019-09-30 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20190916.nc
cdo -z zip -seldate,2019-10-01,2019-10-31 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20191016.nc
cdo -z zip -seldate,2019-11-01,2019-11-30 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20191116.nc
cdo -z zip -seldate,2019-12-01,2019-12-31 isimip3_tws_monthly_ensstd_divc.nc both_models_std_20191216.nc




#分解
#cdo splitsel,1 BOTH_GRACE_GRACE-FO_Land_Mascons_all-corrections_ensstd_sqr_enssum_sqrt_divc.nc both_mscn_sub_isimip3_std_















done
