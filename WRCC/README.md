# WRCC

The US Forest Service [AirFire](https://portal.airfire.org) Group processes
real-time air quality data from [WRCC](https://wrcc.dri.edu/cgi-bin/smoke.pl). This 
data is used in research projects and on-line tools such as the 
[Fire & Smoke Map](https://fire.airnow.gov).

The `wrcc_PM2.5_sites_1000.csv` _"known locations"_ file is queried and updated
during data processing and contains the most complete version of the spatial 
metadata associated with WRCC monitoring sites.

## Instructions

Use `addOpenCageInfo.R` first to obtain the latest version of the AirNow 
locations table.

Walk through this script a chunk at a time.

Then do the same with `addMissingElevation.R`.



