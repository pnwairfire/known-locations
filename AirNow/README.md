# AirNow

The US Forest Service [AirFire](https://portal.airfire.org) Group processes
real-time air quality data from [AirNow](https://portal.airfire.org). This 
data is used in research projects and on-line tools such as the 
[Fire & Smoke Map](https://fire.airnow.gov).

The `airnow_PM2.5_sites.csv` _"known locations"_ file is queried and updated
during data processing and contains the most complete version of the spatial 
metadata associated with AirNow monitoring sites.

## Instructions

Use `addOpenCageInfo.R` first to obtain the latest version of the AirNow 
locations table.

Walk through this script a chunk at a time.

Then do the same with `addMissingElevation.R`.

