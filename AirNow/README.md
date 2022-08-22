
# AirNow Known Locations

Last Updated _2022-08-22_

---- 

The US Forest Service [AirFire](https://portal.airfire.org) Group processes
real-time air quality data from [AirNow](https://portal.airfire.org). This 
data is used in research projects and on-line tools such as the 
[Fire & Smoke Map](https://fire.airnow.gov).

The `airnow_PM2.5_sites.csv` _"known locations"_ file is queried and updated
during data processing and contains the most complete version of the spatial 
metadata associated with AirNow monitoring sites.

## Instructions

Use `00_removeAdjacentLocations.R` to check that there are no "adjacent" 
locations. There shouldn't be.

Then use `01_addOpenCageInfo.R` to obtain the latest version of the AirNow 
locations table.

Walk through this script a chunk at a time.

Then do the same with `02_addMissingElevation.R`.

