
# AIRSIS Known Locations

Last Updated _2022-08-22_

---- 

The US Forest Service [AirFire](https://portal.airfire.org) Group processes
real-time air quality data from [AIRSIS](http://<provider>.airsis.com/). This 
data is used in research projects and on-line tools such as the 
[Fire & Smoke Map](https://fire.airnow.gov).

The `airsis_PM2.5_sites.csv` _"known locations"_ file is queried and updated
during data processing and contains the most complete version of the spatial 
metadata associated with AIRSIS monitoring sites.

## Instructions

Use `01_addOpenCageInfo.R` first to obtain the latest version of the AirNow 
locations table.

Walk through this script a chunk at a time.

Then do the same with `02_addMissingElevation.R`.


