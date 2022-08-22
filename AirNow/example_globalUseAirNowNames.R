# For every known location, use the AirNow siteName as the locationTbl$locationName

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

# ----- Get AirNow sites metadata ----------------------------------------------

all_airnow_sites <- AirMonitorIngest::airnow_getSites()

airnow_sites <-

  # Start with airnow_sites
  all_airnow_sites %>%

  # Filter for our specified parameter
  dplyr::filter(.data$parameterName == "PM2.5") %>%

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
  dplyr::filter(.data$longitude < -50.0)

airnow_active <- dplyr::filter(airnow_sites, .data$status == "Active")
airnow_inactive <- dplyr::filter(airnow_sites, .data$status != "Active")

# ----- Find nearest active locations ------------------------------------------

airnow_active_nearest_locations <-
  # Find locationTbl records closest to airnow_active locations
  MazamaLocationUtils::table_getNearestLocation(
    locationTbl,
    airnow_active$longitude,
    airnow_active$latitude,
    distanceThreshold = 100
  )

# ----- Copy AirNow active siteNames -------------------------------------------

site_names_active <-
  # Start with airnow_active
  airnow_active %>%
  # Fix siteName; add locationID and locationName columns
  dplyr::mutate(
    siteName = dplyr::na_if(siteName, "N/A"),
    locationID = airnow_active_nearest_locations$locationID,
    locationName = airnow_active_nearest_locations$locationName
  ) %>%
  # Filter out non-matches (i.e. location doesn't exist in locationTbl)
  dplyr::filter(!is.na(.data$locationID)) %>%
  # Pull out all columns of interest
  dplyr::select(c("locationID", "siteName", "locationName")) %>%
  # Remove duplicate locationIDs
  dplyr::distinct(.data$locationID, .keep_all = TRUE)


# Review before removing duplicates:
#
# dup_ids <- site_names_active$locationID[which(duplicated(site_names_active$locationID))]
# dplyr::filter(site_names_active, .data$locationID %in% dup_ids) %>% View()

# NOTE:  Our site_names_active tbl has the information we need to update
# NOTE:  the location tbl.

locationTbl <-
  table_updateColumn(
    locationTbl,
    columnName = "locationName",
    locationID = site_names_active$locationID,
    locationData = site_names_active$siteName,
    verbose = TRUE
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

