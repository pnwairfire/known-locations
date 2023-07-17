# NOTE:  Modify this script to fix one field at a time

# Use a web service to add missing elevation data

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

table_leaflet(locationTbl)

# ===== SINGLE RECORD NEEDS UPDATING ===========================================

if ( FALSE ) {

  # # 280590006 Needs to change from Temporary to Permanent
  #
  # locationID <-
  #   locationTbl %>%
  #   dplyr::filter(AQSID == "280590006") %>%
  #   dplyr::pull("locationID")
  #
  # locationTbl <- table_updateSingleRecord(
  #   locationTbl,
  #   locationList = list(
  #     locationID = locationID,
  #     airnow_monitorType = "Permanent"
  #   )
  # )

  # location "  locationID <- "277ce1415feb3537" has old AirNow info
  locationID <- "277ce1415feb3537"

  locationTbl[locationTbl$locationID == "277ce1415feb3537", "locationName"] <- "USFS 1077"
  locationTbl[locationTbl$locationID == "277ce1415feb3537", "AQSID"] <- ""
  locationTbl[locationTbl$locationID == "277ce1415feb3537", "fullAQSID"] <- ""
  locationTbl[locationTbl$locationID == "277ce1415feb3537", "airnow_stationID"] <- ""
  locationTbl[locationTbl$locationID == "277ce1415feb3537", "airnow_siteCode"] <- ""
  locationTbl[locationTbl$locationID == "277ce1415feb3537", "airnow_monitorType"] <- "Temporary"
  locationTbl[locationTbl$locationID == "277ce1415feb3537", "airnow_status"] <- ""

  # Review fixed locations
  locationTbl %>%
    dplyr::filter(locationID == !!locationID) %>%
    MazamaLocationUtils::table_leaflet(
      extraVars = c("locationName", "fullAQSID"),
      jitter = 0
    )

  locationTbl %>%
    dplyr::filter(locationID == !!locationID) %>%
    dplyr::glimpse()

}

# ===== NAMES THAT NEED UPDATING ===============================================

if ( FALSE ) {

  badLocationIDs <- c("277ce1415feb3537")

  # Review bad locations
  locationTbl %>%
    dplyr::filter(locationID %in% !!badLocationIDs) %>%
    MazamaLocationUtils::table_leaflet(
      extraVars = c("locationName", "fullAQSID"),
      jitter = 0
    )

  locationTbl[locationTbl$locationID == "277ce1415feb3537", "locationName"] <- "USFS 1077"

  # Review fixed locations
  locationTbl %>%
    dplyr::filter(fullAQSID == badNameIDs) %>%
    MazamaLocationUtils::table_leaflet(
      extraVars = c("locationName", "fullAQSID"),
      jitter = 0
    )

  # ----- Save the table -------------------------------------------------------

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

}

# ===== LOTS OF MISSING NAMES ==================================================

if ( FALSE ) {

  uniqueOnlyTbl <-
    locationTbl %>%
    dplyr::select(locationID, fullAQSID)

  hasNameTbl <-
    locationTbl %>%
    dplyr::filter(!is.na(locationName))

  missingNameTbl <-
    locationTbl %>%
    dplyr::filter(is.na(locationName))

  dim(hasNameTbl)
  dim(missingNameTbl)

  # NOTE:  If there are no records with missing addresses, you can stop here.

  # Review
  if ( nrow(missingNameTbl) > 0 ) {

    missingNameTbl %>%
      table_leaflet(
        extraVars = c("locationName", "fullAQSID", "address"),
        jitter = 0
      )

  }

  # Update locationTbl directly

  # 2022-10-17
  missingNameTbl <-
    missingNameTbl %>%
    table_updateSingleRecord(list(locationID = "02cd0512f806e0b3", locationName = "Lihue, Kauai")) %>%
    table_updateSingleRecord(list(locationID = "587be29d277b5f50", locationName = "Kona - Kuakini Highway")) %>%
    table_updateSingleRecord(list(locationID = "ac464d275d7d1665", locationName = "Naalehu")) %>%
    table_updateSingleRecord(list(locationID = "5d3c0e71e00d36c0", locationName = "Pahoa")) %>%
    table_updateSingleRecord(list(locationID = "987cbfc3201b0c1a", locationName = "Red Bluff")) %>%
    table_updateSingleRecord(list(locationID = "5eb8f452a9146f31", locationName = "Aberdeen - Williams St.")) %>%
    table_updateSingleRecord(list(locationID = "09af87e9725e6e1a", locationName = "Ft. Benning - Arbonne St.")) %>%
    table_updateSingleRecord(list(locationID = "688cb0571eaed441", locationName = "Dallas - Bexar St.")) %>%
    table_updateSingleRecord(list(locationID = "ac129bc88abef963", locationName = "Albuquerque - Alameda Rd.")) %>%
    table_updateSingleRecord(list(locationID = "1ba704d9f448bd0a", locationName = "Albuquerque - Williams St.")) %>%
    table_updateSingleRecord(list(locationID = "20964517ad55550f", locationName = "Delta Public Library")) %>%
    table_updateSingleRecord(list(locationID = "5dbabe2bfe557b60", locationName = "Black Oak Lodge")) %>%
    table_updateSingleRecord(list(locationID = "1c6cc4784b7d8dad", locationName = "Kokanee Rd.")) %>%
    table_updateSingleRecord(list(locationID = "0d72360824473e2a", locationName = "Badger Pass Lodge")) %>%
    table_updateSingleRecord(list(locationID = "c68d9c5b09aec1b7", locationName = "Antioch")) %>%
    table_updateSingleRecord(list(locationID = "2fb60a7ada35647f", locationName = "Bothe Napa Valley Park")) %>%
    table_updateSingleRecord(list(locationID = "018923aa466ba8bf", locationName = "Brooks")) %>%
    table_updateSingleRecord(list(locationID = "a19fde350d055a8c", locationName = "Sacramento - 5th St.")) %>%
    table_updateSingleRecord(list(locationID = "127e996697f9731c", locationName = "Sacramento - Solons Alley")) %>%
    table_updateSingleRecord(list(locationID = "be63451fea552e9a", locationName = "Georgetown")) %>%
    table_updateSingleRecord(list(locationID = "49fa6c3a7b263a3d", locationName = "S. Lake Tahoe - Oakland Ave.")) %>%
    table_updateSingleRecord(list(locationID = "e532e726e974c2d4", locationName = "Elk Mtn. Rd.")) %>%
    table_updateSingleRecord(list(locationID = "bdf67b1e536bcb2f", locationName = "Willows")) %>%
    table_updateSingleRecord(list(locationID = "69239db34adfaa1f", locationName = "Happy Camp - Buckhorn Road"))

  # ----- Combine two halves ---------------------------------------------------

  updatedLocationTbl <-
    dplyr::bind_rows(hasNameTbl, missingNameTbl)

  # Use original ordering
  locationTbl <-
    uniqueOnlyTbl %>%
    dplyr::left_join(updatedLocationTbl, by = c("locationID", "fullAQSID"))

  # Sanity check: should be TRUE
  identical(uniqueOnlyTbl$locationID, locationTbl$locationID)

  # Review
  locationTbl %>% MazamaLocationUtils::table_leaflet(extraVars = "locationName")

  # ----- Save the table -------------------------------------------------------

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

}

