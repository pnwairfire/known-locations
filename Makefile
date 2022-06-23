################################################################################
# Makefile for deploying updated known locations files
#
#

# Configurable parameters
AWS_KNOWN_LOCATIONS_DIR=/data/monitoring-v2/known-locations

deploy_airnow: 
	cp AirNow/airnow_PM2.5_sites.rda $(AWS_KNOWN_LOCATIONS_DIR)/
	cp AirNow/airnow_PM2.5_sites.csv $(AWS_KNOWN_LOCATIONS_DIR)/

deploy_airsis: 
	cp AIRSIS/airsis_PM2.5_sites_1000.rda $(AWS_KNOWN_LOCATIONS_DIR)/
	cp AIRSIS/airsis_PM2.5_sites_1000.csv $(AWS_KNOWN_LOCATIONS_DIR)/

deploy_wrcc: 
	cp WRCC/wrcc_PM2.5_sites_1000.rda $(AWS_KNOWN_LOCATIONS_DIR)/
	cp WRCC/wrcc_PM2.5_sites_1000.csv $(AWS_KNOWN_LOCATIONS_DIR)/

copy_to_docs:
	cp AirNow/airnow_PM2.5_sites.html ./docs
	cp AIRSIS/airsis_PM2.5_sites.html ./docs
	cp WRCC/wrcc_PM2.5_sites.html ./docs

