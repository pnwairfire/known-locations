# NOTE:  Run this script first, checking as you go. Then run the elevation script.

# Use a web service to add missing elevation data

library(MazamaLocationUtils)

collectionDir <- "AirNow"
collectionName <- "airnow_PM2.5_sites"
collectionFile <- paste0(collectionName, ".rda")

# ----- Load and Review --------------------------------------------------------

download.file(
  file.path("https://airfire-data-exports.s3.us-west-2.amazonaws.com/monitoring/v2/known-locations", collectionFile),
  destfile = file.path(".", collectionDir, collectionFile)
)

setLocationDataDir(file.path(".", collectionDir))

locationTbl <- table_load(collectionName)
dim(locationTbl)

# NOTE:  START HERE AFTER RUNNING 00_removeAdjacentLocations
#
# ----- Review duplicate locationIDs -------------------------------------------

rm(adjacent_kl)

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

# ----- Subset and retain ordering ---------------------------------------------

uniqueOnlyTbl <-
  locationTbl %>%
  dplyr::select(locationID, fullAQSID)

if ( !"address" %in% names(locationTbl) )
  locationTbl$address <- as.character(NA)

hasAddressTbl <-
  locationTbl %>%
  dplyr::filter(!is.na(address))

missingAddressTbl <-
  locationTbl %>%
  dplyr::filter(is.na(address))

dim(uniqueOnlyTbl)
dim(hasAddressTbl)
dim(missingAddressTbl)

# NOTE:  If there are no records with missing addresses, you can stop here.

# Review
if ( nrow(missingAddressTbl) > 0 ) {

  missingAddressTbl %>%
    table_leaflet(
      extraVars = c("fullAQSID", "elevation", "address"),
      jitter = 0
    )

}

# ----- Add OpenCage info ------------------------------------------------------

source("global_vars.R")
Sys.setenv("OPENCAGE_KEY" = OPENCAGE_API_KEY)

missingAddressTbl <- table_addOpenCageInfo(
  missingAddressTbl,
  replaceExisting = TRUE,
  retainOpenCage = FALSE,
  verbose = FALSE
)

# OR, if the above fails:

if ( FALSE ) {

  recordList <- list()

  for ( i in seq_len(nrow(missingAddressTbl)) ) {

    if ( i %% 10 == 0 )
      message(sprintf("Working on %d of %d...", i, nrow(missingAddressTbl)))

    singleRecord <- dplyr::slice(missingAddressTbl, i)

    result <- try({
      recordList[[i]] <- table_addOpenCageInfo(
        singleRecord,
        replaceExisting = TRUE,
        retainOpenCage = FALSE,
        verbose = FALSE
      )
    }, silent = TRUE)

    if ( "try-error" %in% class(result) ) {
      warn(sprintf("Failed to get openCage info for record #%d", i))
      recordList[[i]] <- singleRecord
    }

  }

  missingAddressTbl <- dplyr::bind_rows(recordList)

}

# Review
missingAddressTbl %>%
  table_leaflet(
    extraVars = c("elevation", "address"),
    jitter = 0
  )

# ----- Combine two halves -----------------------------------------------------

updatedLocationTbl <-
  dplyr::bind_rows(hasAddressTbl, missingAddressTbl)

# Use original ordering
locationTbl <-
  uniqueOnlyTbl %>%
  dplyr::left_join(updatedLocationTbl, by = c("locationID", "fullAQSID"))

# Sanity check: should be TRUE
identical(uniqueOnlyTbl$locationID, locationTbl$locationID)

# Review
###locationTbl %>% MazamaLocationUtils::table_leaflet(extraVars = "address")

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


# NOTE:  Now you should walk through 02_addMissingElevation.R


