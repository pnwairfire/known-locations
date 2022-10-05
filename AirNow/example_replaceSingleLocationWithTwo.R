# NOTE:  Modify this script to update/add a location
#
# NOTE:  On 2002-10-03, I got a message from Stuart that CARB was complaining
# NOTE:  about monitor MMCA82062 appearing twice -- once at the AIRSIS location
# NOTE:  (correct) and once at the AirNow location (incorrect).
# NOTE:
# NOTE:  Turns out there is a separate AirNow location two blocks away associated
# NOTE:  with MMCA81044 and the data ingest process found that as the "nearest location"
# NOTE:
# NOTE:  So we need to modify the contents of this location and add a new one.

# Use a web service to add missing elevation data

library(MazamaSpatialUtils)
MazamaSpatialUtils::setSpatialDataDir("~/Data/Spatial")
MazamaSpatialUtils::loadSpatialData("EEZCountries.rda")
MazamaSpatialUtils::loadSpatialData("OSMTimezones.rda")
MazamaSpatialUtils::loadSpatialData("NaturalEarthAdm1.rda")
MazamaSpatialUtils::loadSpatialData("USCensusCounties.rda")

library(MazamaLocationUtils)
collectionDir <- "AirNow"
collectionName <- "airnow_PM2.5_sites"
collectionFile <- paste0(collectionName, ".rda")

library(AirMonitor)
library(AirMonitorIngest)

# ----- Load and Review sites --------------------------------------------------

airnow_sites <-
  AirMonitorIngest::airnow_getSites() %>%
  dplyr::filter(parameterName == "PM2.5") %>%
  dplyr::filter(status == "Active")

airnow_sites %>%
  MazamaLocationUtils::table_leaflet(
    jitter = 0,
    extraVars = c("fullAQSID", "AQSID", "siteName")
  )

# MMCA81044 is at longitude = -123.677044, latitude = 41.047508

# MMCA82062 (and three others) are at longitude = -123.675156, latitude = 41.047175


# ----- Load and Review locationTbl --------------------------------------------

download.file(
  file.path("http://data-monitoring_v2-c1.airfire.org/monitoring-v2/known-locations", collectionFile),
  destfile = file.path(".", collectionDir, collectionFile)
)

setLocationDataDir(file.path(".", collectionDir))

locationTbl <- table_load(collectionName)
dim(locationTbl)

# ----- Fix AQSID and fullAQSID for existing location

# Hoopa
# longitude = -123.677044, latitude = 41.047508

locationTbl %>%
  MazamaLocationUtils::table_filterByDistance(
    longitude = -123.677044,
    latitude = 41.047508,
    distanceThreshold = 1000
  ) %>%
  MazamaLocationUtils::table_leaflet(
    jitter = 0,
    extraVars = c("fullAQSID", "AQSID", "locationName")
  )

# NOTE:  fullAQSID and AQSID are incorrect

locationTbl <-
  MazamaLocationUtils::table_updateSingleRecord(
    locationTbl,
    locationList = list(
      locationID = "952fd68fa4e772c5",
      fullAQSID = "840MMCA81044",
      AQSID = "MMCA81044"
    )
  )

# Review

locationTbl %>%
  MazamaLocationUtils::table_leaflet(
    jitter = 0,
    extraVars = c("fullAQSID", "AQSID", "locationName")
  )

# Good

# ----- Add new location for MMCA82062 -----------------------------------------

# Pull out the single site to create a new record for
new_site <-
  airnow_sites %>%
  dplyr::filter(fullAQSID == "840MMCA82062")

dplyr::glimpse(new_site)

# Create a new "location"
new_location <-

  new_site %>%

  MazamaLocationUtils::table_initializeExisting(
    countryCodes = c("CA", "US", "MX", "PR", "VI", "GU"),
    distanceThreshold = 100,
    measure = "geodesic",
    verbose = FALSE
  ) %>%

  # Rename all existing columns with "airnow_"
  dplyr::rename_all(~ gsub("^", "airnow_", .x)) %>%

  dplyr::select(-c("airnow_locationName")) %>%

  # Rename columns
  dplyr::rename(
    AQSID = .data$airnow_AQSID,
    fullAQSID = .data$airnow_fullAQSID,
    locationID = .data$airnow_locationID,
    locationName = .data$airnow_siteName,
    longitude = .data$airnow_longitude,
    latitude = .data$airnow_latitude,
    elevation = .data$airnow_elevation,
    countryCode = .data$airnow_countryCode,
    stateCode = .data$airnow_stateCode,
    countyName = .data$airnow_countyName
  )

# Fix/add columns

# # countyName casing
# new_location$countyName <-
#   stringr::str_to_title(new_location$countyName)
#
# # add timezones
# new_location$timezone <-
#   MazamaSpatialUtils::getTimezone(
#     new_location$longitude,
#     new_location$latitude,
#     # NOTE:  EPA has monitors from US, Canada, Mexico, Puerto Rico, Virgin Islands and Guam
#     countryCodes = c("US", "CA", "MX", "PR", "VI", "GU"),
#     useBuffering = TRUE
#   )


locationTbl <- dplyr::bind_rows(locationTbl, new_location)

# Review

locationTbl %>%
  MazamaLocationUtils::table_filterByDistance(
    longitude = -123.677044,
    latitude = 41.047508,
    distanceThreshold = 1000
  ) %>%
  MazamaLocationUtils::table_leaflet(
    jitter = 0,
    extraVars = c("fullAQSID", "AQSID", "locationName")
  )





# ----- Save the table ---------------------------------------------------------

table_save(
  locationTbl,
  collectionName = collectionName,
  backup = FALSE,
  outputType = "csv"
)

table_save(
  locationTbl,
  collectionName = collectionName,
  backup = FALSE,
  outputType = "rda"
)


