# known-locations 0.1.0

June 23, 2022 update.

Updated all data processing components and scripts to use `fullAQSID` as the
AirNow unique identifier.

* Updated `airnow`, `airsis` and `wrcc` PM2.5 known locations tables.
* Removed some locations associated with AirNow `840MMCA83999` which has a new
cell phone-based transmitter and needs a 500m `distanceThreshold` when finding
locations. We will keep the AirNow location associated with this `fullAQSID`.

# known-locations 0.0.7

May 18, 2022 update.

* Updated `airnow`, `airsis` and `wrcc` PM2.5 known locations tables.

# known-locations 0.0.6

April 04, 2022 update.

* Updated to latest operational `wrcc_PM2.5_sites_1000`.
* Added missing addresses and elevations to `wrcc_PM2.5_sites_1000`.
* Updated to latest operational `airsis_PM2.5_sites_1000`.
* Added missing addresses and elevations to `airsis_PM2.5_sites_1000`.

# known-locations 0.0.5

March 31, 2022 update.

* Updated to latest operational `airnow_PM2.5_sites`.
* Added missing addresses and elevations to `airnow_PM2.5_sites`.

# known-locations 0.0.4

* Added `wrcc_PM2.5_sites_1000`
* Updated `wrcc_PM2.5_sites_1000` for archival locations.
* Updated to latest operational `airnow_PM2.5_sites`.
* Added missing addresses and elevations to `airsis_PM2.5_sites_1000`.
* Added missing addresses and elevations to `wrcc_PM2.5_sites_1000`.

# known-locations 0.0.3

* Guarantee that `airnow_FIPSMSACode` is <char>.
* Added addresses to `airnow_PM2.5_sites`.
* Added `airsis_PM2.5_sites_1000` with elevations.
* Updated `airsis_PM2.5_sites_1000` with OpenCage address info.

# known-locations 0.0.2

Updates to `airnow_PM2.5_sites`:

* Add `airnow_pm2.5_sites.rda` to repository.
* Manually fixed `stateCode` for sites on the border with Canada
or Mexico.
* Added USGS elevations wherever they were missing.

# known-locations 0.0.1

Initial Release with `airnow_PM2.5_sites.csv`.




2efb9a6 (HEAD -> main, origin/main) tweak:
2d62d77 updated WRCC for archival locations
c5fc9fc feat: added WRCC
eee52dc (tag: 0.0.3) updated .Rmd and .html
e6de3d9 added addresses to AirNow_PM2.5_sites
0269db9 Updated airsis_ with OpenCage address info
c2b6ae3 added airsis_PM2.5_sites_1000 w/ elevations
56c6082 fix: guarantee that airnow_FIPSMSACode is <char>
9633243 (tag: 0.0.2) version bump in NEWS.md and airnow_PM2.5_sites.html
0f16bc8 added airnow_PM2.5 elevations
e098d6b feat: adding AirNow .rda output
67d42c8 manually fixed stateCode in airnow_pm2.5_sites.csv
524fbc9 (tag: 0.0.1) first_commit
