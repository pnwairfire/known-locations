# NOTE:  Run this script once only to add AirNow "Inactive" sites to an existing
# NOTE:  known locations table

library(MazamaSpatialUtils)
library(MazamaLocationUtils)

# MazamaSpatialUtils
MazamaSpatialUtils::setSpatialDataDir("~/Data/Spatial")

MazamaSpatialUtils::loadSpatialData("EEZCountries.rda")
MazamaSpatialUtils::loadSpatialData("OSMTimezones.rda")
MazamaSpatialUtils::loadSpatialData("NaturalEarthAdm1.rda")
MazamaSpatialUtils::loadSpatialData("USCensusCounties.rda")

collectionDir <- "AirNow"
collectionName <- "airnow_PM2.5_sites"
collectionFile <- paste0(collectionName, ".rda")

distanceThreshold <- 500

# ----- Load and Review --------------------------------------------------------

download.file(
  file.path("http://data-monitoring_v2-c1.airfire.org/monitoring-v2/known-locations", collectionFile),
  destfile = file.path(".", collectionDir, collectionFile)
)

setLocationDataDir(file.path(".", collectionDir))

locationTbl <- table_load(collectionName)
dim(locationTbl)

# ----- Load sites data --------------------------------------------------------

all_airnow_sites <- AirMonitorIngest::airnow_getSites()

airnow_sites <-

  # Start with airnow_sites
  all_airnow_sites %>%

  # Filter for our specified parameter
  dplyr::filter(.data$parameterName == "PM2.5") %>%

  # Filter for non-"Active" sites
  dplyr::filter(.data$status != "Active") %>%

  # Remove records with missing longitude or latitude
  dplyr::filter(
    is.finite(.data$longitude),
    is.finite(.data$latitude),
    .data$longitude != 0,
    .data$latitude != 0
  ) %>%

  # Filter for North America
  dplyr::filter(.data$GMTOffsetHours < 0) %>%
  dplyr::filter(.data$latitude > 15.0) %>%
  dplyr::filter(.data$longitude < -50.0) %>%

  # Add locationID
  dplyr::mutate(
    locationID = MazamaLocationUtils::location_createID(.data$longitude, .data$latitude)
  ) %>%

  # Remove duplicate locations (No way of discerning which record is better)
  dplyr::distinct(.data$locationID, .keep_all = TRUE)

# > dplyr::glimpse(airnow_sites, width = 75)
# Rows: 499
# Columns: 23
# $ stationID         <chr> "000030311", "000031001", "CC0040103", "0000501…
# $ AQSID             <chr> "000030311", "000031001", "000040103", "0000501…
# $ fullAQSID         <chr> "124000030311", "124000031001", "124CC0040103",…
# $ parameterName     <chr> "PM2.5", "PM2.5", "PM2.5", "PM2.5", "PM2.5", "P…
# $ monitorType       <chr> "Permanent", "Permanent", "Permanent", "Permane…
# $ siteCode          <chr> "0311", "1001", "0103", "0103", "0105", "0109",…
# $ siteName          <chr> "SYDNEY", "Sable Island", "FREDERICTON", "Saint…
# $ status            <chr> "Inactive", "Inactive", "Inactive", "Inactive",…
# $ agencyID          <chr> "NS1", "NS1", "NB1", "CN4", "QC2", "CN4", "QC2"…
# $ agencyName        <chr> "Canada-Nova Scotia1", "Canada-Nova Scotia1", "…
# $ EPARegion         <chr> "CA", "CA", "CA", "CA", "CA", "CA", "CA", "CA",…
# $ latitude          <dbl> 46.14250, 43.93310, 45.95780, 45.64810, 45.5008…
# $ longitude         <dbl> -60.17280, -59.90390, -66.64750, -73.49970, -73…
# $ elevation         <dbl> NA, NA, NA, 14.0, 45.1, 46.4, 27.1, 21.0, 39.3,…
# $ GMTOffsetHours    <dbl> -4, -4, -4, -5, -5, -5, -5, -5, -5, -5, -5, -5,…
# $ countryFIPS       <chr> "CA", "CA", "CA", "CA", "CA", "CA", "CA", "CA",…
# $ CBSA_ID           <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,…
# $ CBSA_Name         <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,…
# $ stateAQSCode      <chr> "00", "00", "00", "00", "00", "00", "00", "00",…
# $ stateAbbreviation <chr> "CC", "CC", "CC", "CC", "CC", "CC", "CC", "CC",…
# $ countyAQSCode     <chr> "003", "003", "004", "005", "005", "005", "005"…
# $ countyName        <chr> "NOVA SCOTIA", "NOVA SCOTIA", "NEW BRUNSWICK", …
# $ locationID        <chr> "955f389243cb4f31", "3f85429b502eb4b5", "51c193…

# ----- Match unknown sites --------------------------------------------------

# NOTE:  Here we match sites whose locationID is not found in locationTbl
# NOTE:  to the closest site within distanceThreshold meters. We save any
# NOTE:  currently unknown sites that have a match and add them back to
# NOTE:  airnow_sites. We then apply dplyr::distinct() to maintain only one
# NOTE:  record per locationID. In the case of duplicated locationIDs, the
# NOTE:  previously unknown sites will be retained as they will be found first.

# NOTE:  We may sometimes lose some location information that was manually
# NOTE:  updated (e.g. locationName) but there appears to be no easy fix for that.

# Inactive sites that are at the same location as an Active site
known_inactive_sites  <-
  airnow_sites %>%
  dplyr::filter(.data$locationID %in% locationTbl$locationID)

# Inactive sites at unknown locations
unknown_inactive_sites  <-
  airnow_sites %>%
  dplyr::filter(!.data$locationID %in% locationTbl$locationID)

# Find any nearby locations
unknown_sites_nearest_location <-
  MazamaLocationUtils::table_getNearestLocation(
    locationTbl,
    unknown_inactive_sites$longitude,
    unknown_inactive_sites$latitude,
    distanceThreshold = distanceThreshold
  )

# Sites that are distant from any known location
new_sites_indices <- which(is.na(unknown_sites_nearest_location$locationID))

new_airnow_sites <-
  unknown_inactive_sites %>%
  dplyr::slice(new_sites_indices)

# ----- Add new sites ----------------------------------------------------------

# NOTE:  Here we identify co-located pairs of sites and remove the second
# NOTE:  member of each pair.
# NOTE:
# NOTE:  table_findAdjacentDistances() generates a table like this:
# NOTE:
# NOTE:  # A tibble: 1 × 3
# NOTE:   row1  row2 distance
# NOTE:  <int> <int>    <dbl>
# NOTE:      1     2     12.0

# TODO:  What if a site appears in multiple pairs?

duplicateSiteRows <-
  MazamaLocationUtils::table_findAdjacentDistances(
    new_airnow_sites,
    distanceThreshold
  ) %>%
  dplyr::pull(.data$row2)

if ( length(duplicateSiteRows) > 0 ) {
  new_airnow_sites <-
    new_airnow_sites %>%
    dplyr::slice(-duplicateSiteRows)
}

nrow(new_airnow_sites)

# ----- Harmonize variables ----------------------------------------------------

newSites_locationTbl <-

  # Start with airnow_sites
  new_airnow_sites %>%

  # Rename all existing columns with "airnow_"
  dplyr::rename_all(~ gsub("^", "airnow_", .x)) %>%

  # Rename columns where the data exists
  dplyr::rename(
    AQSID = .data$airnow_AQSID,
    fullAQSID = .data$airnow_fullAQSID,
    locationID = .data$airnow_locationID,
    locationName = .data$airnow_siteName,
    longitude = .data$airnow_longitude,
    latitude = .data$airnow_latitude,
    elevation = .data$airnow_elevation,
    countryCode = .data$airnow_countryFIPS,     # SEE BELOW:  Convert airnow_countryFIPS to countryCode
    stateCode = .data$airnow_stateAbbreviation, # SEE BELOW:  Convert airnow_stateAbbreviation to stateCode
    countyName = .data$airnow_countyName
  ) %>%

  MazamaLocationUtils::table_addCoreMetadata()

# ----- Reorganize columns -----------------------------------------------------

# Get "airnow_" columns
airnow_columns <-
  names(newSites_locationTbl) %>%
  stringr::str_subset("airnow_.*")

# NOTE:  Include the "AQSID" columns for AirNow data
newColumns <- c(
  "AQSID",
  "fullAQSID",
  MazamaLocationUtils::coreMetadataNames,
  airnow_columns
)

# Reorder column names
newSites_locationTbl <-
  newSites_locationTbl %>%
  dplyr::select(dplyr::all_of(newColumns))

# ----- Fix/add columns --------------------------------------------------------

# * countyName casing -----

newSites_locationTbl$countyName <-
  stringr::str_to_title(newSites_locationTbl$countyName)

# * Add timezones -----

newSites_locationTbl$timezone <-
  MazamaSpatialUtils::getTimezone(
    newSites_locationTbl$longitude,
    newSites_locationTbl$latitude,
    # NOTE:  EPA has monitors from US, Canada, Mexico, Puerto Rico, Virgin Islands and Guam
    countryCodes = c("US", "CA", "MX", "PR", "VI", "GU"),
    useBuffering = TRUE
  )

# * Replace countryCodes -----

# NOTE:  Puerto Rico seems to be the only mis-assigned country code
mask <- newSites_locationTbl$timezone == "America/Puerto_Rico"
newSites_locationTbl$countryCode[mask] <- "PR"

# * Replace stateCodes -----

# NOTE:  The use of airnow_stateAbbreviation as the stateCode is only
# NOTE:  correct when the now corrected countryCode == "US".
# NOTE:  At least once, "MM" was seen as a US "stateAbbreviation"

mask <-
  ( newSites_locationTbl$countryCode != "US" ) |
  ( newSites_locationTbl$countryCode != "US" & newSites_locationTbl$stateCode == "MM" ) |
  ( is.na(newSites_locationTbl$stateCode) )

if ( any(mask) ) {
  newSites_locationTbl$stateCode[mask] <-
    MazamaSpatialUtils::getStateCode(
      newSites_locationTbl$longitude[mask],
      newSites_locationTbl$latitude[mask],
      # NOTE:  AirNow has monitors from US, Canada, Mexico, Puerto Rico, Virgin Islands and Guam
      countryCodes = c("US", "CA", "MX", "PR", "VI", "GU"),
      useBuffering = TRUE
    )
}


# * Replace countyNames -----

# NOTE:  For foreign countries, AirNow is using level-2 names, rather than
# NOTE:  level-3 names.

mask <- newSites_locationTbl$countryCode != "US"
if ( any(mask) ) {
  newSites_locationTbl$countyName[mask] <- as.character(NA)
}

# * Replace locationNames -----

# NOTE:  "N/A" was seen a few times

mask <- newSites_locationTbl$locationName == "N/A"
if ( any(mask) ) {
  newSites_locationTbl$locationName[mask] <- as.character(NA)
}

# * Combine with locationTbl -----

locationTbl <-
  dplyr::bind_rows(locationTbl, newSites_locationTbl)

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


