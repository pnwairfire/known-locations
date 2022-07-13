# An example of replacing a record in the known locations table with a better
# location from the AirNow sites table.
#
# Example:  A temporary monitor is replaced with a permanent one.

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

# ----- Load and Review --------------------------------------------------------

download.file(
  file.path("http://data-monitoring_v2-c1.airfire.org/monitoring-v2/known-locations", collectionFile),
  destfile = file.path(".", collectionDir, collectionFile)
)

setLocationDataDir(file.path(".", collectionDir))

locationTbl <- table_load(collectionName)
dim(locationTbl)

# ----- Check for duplicate locationIDs ----------------------------------------

# NOTE:  We support duplicate locationIDs for AirNow because it is possible for

# NOTE:    1) two different fullAQSIDs to share the same locationID
# NOTE:    2) two different locationIDs to share the same fullAQSID

# Sanity check: both of these should be FALSE
any(is.na(locationTbl$fullAQSID))
any(duplicated(paste0(locationTbl$locationID, "_", locationTbl$fullAQSID)))

duplicateIDs <- locationTbl$locationID[duplicated(locationTbl$locationID)]
print(length(duplicateIDs)) # zero is what we hope for

if ( length(duplicateIDs) > 0 ) {

  duplicatesTbl <-
    locationTbl %>%
    dplyr::filter(locationID %in% duplicateIDs)

  duplicatesTbl %>%
    dplyr::select(locationID, fullAQSID, locationName) %>%
    dplyr::arrange(locationID) %>%
    View()

}

# ----- Replace ---------------------------------

# NOTE:  As of 2022-07-12, the airnow_locationTbl has a Crescent City location
# NOTE:  associated with 840MMNPS1028. This has been recently replaced with
# NOTE:  permanent monitor 840060150007.
# NOTE:
# NOTE:  These two locations are within the same block and we want to remove
# NOTE:  the old record and add the new one.

airnow_sites <-
  AirMonitorIngest::airnow_getSites() %>%
  dplyr::filter(parameterName == "PM2.5") %>%
  dplyr::filter(status == "Active")

airnow_sites %>%
  MazamaLocationUtils::table_leaflet(extraVars = c("AQSID", "fullAQSID"))

# Pull out the single site to create a new record for
new_site <-
  airnow_sites %>%
  dplyr::filter(fullAQSID == "840060150007")

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
    countryCode = .data$airnow_countryFIPS,
    stateCode = .data$airnow_stateAbbreviation,
    countyName = .data$airnow_countyName
  )

# Fix/add columns

# countyName casing
new_location$countyName <-
  stringr::str_to_title(new_location$countyName)

# add timezones
new_location$timezone <-
  MazamaSpatialUtils::getTimezone(
    new_location$longitude,
    new_location$latitude,
    # NOTE:  EPA has monitors from US, Canada, Mexico, Puerto Rico, Virgin Islands and Guam
    countryCodes = c("US", "CA", "MX", "PR", "VI", "GU"),
    useBuffering = TRUE
  )


locationTbl <- dplyr::bind_rows(locationTbl, new_location)

locationTbl %>%
  MazamaLocationUtils::table_leaflet(extraVars = c("AQSID", "fullAQSID"))

# Now remove the old location
locationTbl <-
  locationTbl %>%
  MazamaLocationUtils::table_removeRecord(locationID = "ed9ef0350e0d73e7")

locationTbl %>%
  MazamaLocationUtils::table_leaflet(extraVars = c("AQSID", "fullAQSID"))

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


# NOTE:  Now you should walk through addOpenCageInfo.R


