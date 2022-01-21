# Use a web service to add missing elevation data

library(MazamaLocationUtils)

collectionDir <- "WRCC"
collectionName <- "wrcc_PM2.5_sites_1000"
collectionFile <- paste0(collectionName, ".rda")

# ----- Load and Review --------------------------------------------------------

download.file(
  file.path("http://data-monitoring_v2-c1.airfire.org/monitoring-v2/known-locations", collectionFile),
  destfile = file.path(".", collectionDir, collectionFile)
)

setLocationDataDir(file.path(".", collectionDir))

locationTbl <- table_load(collectionName)

locationTbl %>% table_leaflet()


# ----- GET OpenCage info ------------------------------------------------------

# TODO:  waiting on a fix in tidygeocoder

# locationTbl <- table_addOpenCageInfo(
#   locationTbl,
#   replaceExisting = TRUE,
#   verbose = FALSE
# )

openCageList <- list()

for ( i in seq_len(nrow(locationTbl)) ) {

  if ( (i %% 20) == 0 ) message("Working on ", i, " ...")

  openCageList[[i]] <-
    MazamaLocationUtils::location_getOpenCageInfo(
      longitude = locationTbl$longitude[i],
      latitude = locationTbl$latitude[i],
      verbose = FALSE
    )

}


openCageTbl <- dplyr::bind_rows(openCageList)

# ----- Replace values ---------------------------------------------------------

replaceExisting <- TRUE

# * countryCode -----

if ( replaceExisting ) {
  locationTbl$countryCode <- toupper(openCageTbl$components.country_code)
} else {
  mask <- is.na(locationTbl$countryCode)
  locationTbl$countryCode[mask] <- toupper(openCageTbl$components.country_code[mask])
}

# * stateCode -----

if ( replaceExisting ) {
  locationTbl$stateCode <- toupper(openCageTbl$components.state_code)
} else {
  mask <- is.na(locationTbl$stateCode)
  locationTbl$stateCode[mask] <- toupper(openCageTbl$components.state_code[mask])
}

# * countyName -----

if ( replaceExisting ) {
  locationTbl$countyName <-
    stringr::str_replace(openCageTbl$components.county, " County", "")
} else {
  mask <- is.na(locationTbl$countyName)
  locationTbl$countyName[mask] <-
    stringr::str_replace(openCageTbl$components.county[mask], " County", "")
}

# * timezone -----

if ( replaceExisting ) {
  locationTbl$timezone <- openCageTbl$annotations.timezone.name
} else {
  mask <- is.na(locationTbl$timezone)
  locationTbl$timezone[mask] <- openCageTbl$annotations.timezone.name[mask]
}

# * houseNumber -----

if ( replaceExisting ) {
  locationTbl$houseNumber <- as.character(openCageTbl$components.house_number)
} else {
  mask <- is.na(locationTbl$houseNumber)
  locationTbl$houseNumber[mask] <- as.character(openCageTbl$components.house_number[mask])
}

# * street -----

if ( replaceExisting ) {
  locationTbl$street <- as.character(openCageTbl$components.road)
} else {
  mask <- is.na(locationTbl$street)
  locationTbl$street[mask] <- as.character(openCageTbl$components.road[mask])
}

# * city -----

if ( replaceExisting ) {
  locationTbl$city <- as.character(openCageTbl$components.town)
} else {
  mask <- is.na(locationTbl$city)
  locationTbl$city[mask] <- as.character(openCageTbl$components.town[mask])
}

# NOTE:  Some OpenCage records are missing "town" but have "city" so add this
# NOTE:  where records are still missing a value
mask <- is.na(locationTbl$city)
locationTbl$city[mask] <- as.character(openCageTbl$components.city[mask])

# * city -----

if ( replaceExisting ) {
  locationTbl$zip <- as.character(openCageTbl$components.postcode)
} else {
  mask <- is.na(locationTbl$zip)
  locationTbl$zip[mask] <- as.character(openCageTbl$components.postcode[mask])
}

# * address -----

# NOTE:  'address' is not part of the core metdata but is very useful
if ( !"address" %in% names(locationTbl) )
  locationTbl$address <- as.character(NA)

if ( replaceExisting ) {
  locationTbl$address <- as.character(openCageTbl$address)
} else {
  mask <- is.na(locationTbl$address)
  locationTbl$address[mask] <- as.character(openCageTbl$address[mask])
}


# ----- Review -----------------------------------------------------------------

locationTbl %>%
  MazamaLocationUtils::table_leaflet(extraVars = "address")


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


