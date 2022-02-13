# known-locations 0.0.4

* Added `wrcc_PM2.5_sites_1000`
* Updated `wrcc_PM2.5_sites_1000` for archival locations.
* Updated to latest operational `airnow_PM2.5_sites`.
* Added missing addresses and elevations to `airnow_PM2.5_sites`.
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
