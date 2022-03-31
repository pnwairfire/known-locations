[![DOI](https://zenodo.org/badge/445637007.svg)](https://zenodo.org/badge/latestdoi/445637007)

# Known Locations

This repository contains _"known locations"_ files providing spatial metadata 
for monitoring sites used in air quality and other stationary, 
environmental-monitoring activities.

These files are largely generated and maintained using the 
**[MazamaLocationUtils](https://github.com/MazamaScience/MazamaLocationUtils)**
R package.

Metadata generated with **MazamaLocationUtils** are manually corrected and 
further enhanced using R scripts in this repository.

The goal is to maintain a set of accurate, high-value datasets that 
provide data analysts spatial metadata associated with point locations without 
having to use any spatial analysis software.

# Collections

Known locations are gathered into _"collections"_ associated with a specific
measurement effort. As of March 31, 2022, current collections contain sites where 
air quality monitoring devices are located. For the AIRSIS and WRCC collections
of mobile monitors, a `distanceThreshold` a `distanceThreshold` of 1000 meters
was chosen as a reasonable dividing line between "repositioning at an
existing location" and "redeploying to a new location".

## AirNow

AirNow site locations are obtained from https://www.airnowapi.org and are used
without any QC. Some sites in this collection may be quite close together.

 [AirNow PM2.5 sites](airnow_PM2.5_sites.html)
 
AIRSIS site locations are generated during the processing of AIRSIS data and
use a `distanceThreshold` of 1000 meters.

[AIRSIS PM2.5 sites](airsis_PM2.5_sites.html)

WRCC site locations are generated during the processing of WRCC data and use
a `distanceThreshold` of 1000 meters.

[WRCC PM2.5 sites](airnow_PM2.5_sites.html)

----

This project is supported through funding from the US Forest Service.

