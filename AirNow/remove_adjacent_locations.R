# NOTE:  Modify this script to review/fix the AirNow sites metadata

# Use a web service to add missing elevation data

library(MazamaLocationUtils)

collectionDir <- "AirNow"
collectionName <- "airnow_PM2.5_sites"
collectionFile <- paste0(collectionName, ".rda")

# ----- Load locationTbl -------------------------------------------------------

download.file(
  file.path("http://data-monitoring_v2-c1.airfire.org/monitoring-v2/known-locations", collectionFile),
  destfile = file.path(".", collectionDir, collectionFile)
)

setLocationDataDir(file.path(".", collectionDir))

locationTbl <- table_load(collectionName)
dim(locationTbl)

# ----- Review adjacent locations ----------------------------------------------

adjacent_kl <-
  locationTbl %>%
  table_findAdjacentLocations(distanceThreshold = 200) # 500 is the actual separation we use

dim(adjacent_kl)

# Two monitors in Calgary are only a block apart
# If nrow(adjacent_kl) > 2, review the map

map <-
  adjacent_kl %>%
  MazamaLocationUtils::table_leaflet(
    extraVars = c("locationName", "fullAQSID"),
    jitter = 0
  )

print(map)

# ----- Locations to drop ------------------------------------------------------

# # On 2022-06-24
# #
# badIDs <- c(
#   # WA
#   "24b0630dd9172719", "e5e99ca178f6d64f",
#   # ID
#   "050c072f785cb04e", "d9f18e7e26345545", "580b864f1681e771",
#   # MT
#   "568543b5c1111269", "fa05005f5f5efce6", "88012c644e170bbf", "187785449a618d35",
#   "7a5c7dde2f6d1f3c", "df6fe072b07ccc1e", "f1c8dd86ac25fc04",
#   "098028d299d3e481", "2aedd5fafa437b49", "58a2a6677afcaea4", "c957f9c32fe216ab",
#   "6dd2a29eb764f74a", "5aa00546fd1aafac",
#   # CO
#   "46ed85d07143ac67", "c854c682530bd367", "744d24b68d77ff1a", "d479597d1fed0e35",
#   "1c14ad5f4ff26212", "79fff39e81bfe8d6", "9a7450e3740874b8", "2c898228e4750e93",
#   "6594e05e882c2c1e", "314b19e68edd334b", "5b3ad26675d6970b", "7e5bf9eea184ff89",
#   "9036a9c3c45254a7", "7c1458584104316e", "10aa4f99d52fc652", "3fbea29d3b2825cc",
#   "7f73bc9b5ff17800", "dc610b5edbf8e840", "5c81ace512698f75", "1d9ebbf36ad8f8a6",
#   "d4ba731653a47dfe", "7c038c83361aa832", "7e50870e3cf69977",
#   "a3f555482c0e8820", "63d3f7ba71f73c9a", "f289e227483bbd99", "c4f49d7e7e852b1f",
#   "f196fee1dcd7ffa8",
#   # NE
#   "35b464e3056d56b5",
#   # NC
#   "2eb559219bc308bb", "8332e910af4396cb", "0aa33a10a871c4ff", "fee696ab7a09c6bc",
#   "afbd465e0396304c",
#   # FL
#   "ffea85166ce0bdf3",
#   # MS
#   "9212ad7989b26e21",
#   # NM
#   "f7ea46edb11e0cb6", "810b87d7451043b3", "0052f455d9a37014", "6263e890a1814894",
#   "5048112275dd7118", "e765d87cb0539ac2", "28214a184d0d1ce0", "be7b0fc03fa8fa67",
#   "7fcd82c324dda94f", "9db176c3978c8d6f", "bb8b42cf3adf73ce",
#   "05d6425a631f7bd7",
#   "4f8c400cc2131261", "6ea8c10a71c6fcbc",
#   "521ded3adae07413", "e606600e6df6fd7d",
#   # Nogales, Mexico
#   "f47941f061210f6e",
#   # NV
#   "0b06752f2b3a6c11",
#   # OR
#   "cf9d14baeeaf120e", "e2b1634a0cf7d694", "b12fe38e4a810aa5", "207037b3eb92420e",
#   "b77d4fd9658c03b8",
#   # CA
#   "048b65dc5aaba52f",
#   "0b937c7f11aa0ed7", "0c7a302b370234f7",
#   "0e09788a93d10536", "0e406771eaf2cc22",
#   "0ef849d61380f717", "0f97b509df047cc3", "114fbc6a8f3c5c41", "127c58e7c5b194a4",
#   "13f12a891e48fcf6", "179d8b0a67b592c7",
#   "183c77ba87124f6d", "191b8895559c8dc9", "19da84fb67e926af", "1a0d87cc05e7be03",
#   "1a8b1c9243eb9e39", "1d5152f63cace493",
#   "2550f458b3f0ffd6", "2616a29c3b699886",
#   "279e24b62a592bb1", "2cf6983e34910de5", "2f8abb5559da95fd",
#   "3270750a2b5ccb8b", "33cfd704075f12c3", "38272ca6b7362538", "3b01d3d7ac0b15d7",
#   "3e5528511a6a2b4c",
#   "443a6ef00ab9d756", "460d94ee85bf7edf", "46c4b31d8e04cd87",
#   "4b8b9ccea35d5d92",
#   "571a2ce089ac35ee", "5aa4ed7f57e0b7d8", "5d408407a0c06d64", "5e4ef42e7bad72db",
#   "5eb8af6feba88f95",
#   "620c2a2944728cf2", "66bd75850548dfd4", "6ae4bf6fecf036f7",
#   "6bd05b4345b16250", "6f234057a23d8360", "700fd2da7f9a1518",
#   "702b5ee7999ec8fc", "70b8df662eb9d472", "71bcdf39b6d635a4",
#   "77ab513f6b529b0a", "7a12a88fb8ff1812", "7d7c1f3bb63fe04f",
#   "81cb60a503bd38a8", "858eb67e1258cc54", "869d5f880be010e6", "882054fc723ae513",
#   "88b9e15ff4823f1b", "88feae047b332c85", "893c2113ecb68577", "8a24bb5536e56024",
#   "8a5dca69d49da5dc", "8ca91d2521b701d4", "8d71022ad4ccff3c", "93abdd6b7955d057",
#   "977a994d56595d7f", "9a32357f8c571fa9",
#   "9c1b4da3a71a0e2a", "9f97e750e220ace3",
#   "a56f36849142ff48", "a5e38ee5a7077e5c", "a73523417b9783c2", "a8e9a49ff74b21c3",
#   "a9f7c9f715ca744b", "adf9ba874252b97a",
#   "b4b7a08a2c98360d", "b4fa0a7bd1599c46", "b9ddf84fe4eb7048", "be1a3f08acee583c",
#   "c1a3495ee0ef9205", "c2ebda0715aeff20", "c452f0a327843805", "c6df1c142cb1927a",
#   "cec6dc2148ab7bb3", "ced9e4b23c75be67", "d108b6a3e0faba8e",
#   "d4792a7828869767", "d60ca86c8efa4a1c", "d74712017af129f8",
#   "d7c5b2e5c5e3df75", "e31043ce839a8818", "e4df9becf44e8464",
#   "e7a84984bda4eb39", "e7f43b68d9554878", "e917b0e85dcba664", "ea4a1c58009f9567",
#   "f433aa8e79efc81a", "f546db3d4c3361fe", "f59d027a64e8f063",
#   "f5dd0e6bda88fbd7", "fa719c85e0d1abc5", "fb0381cd2bd79a09",
#   "fd767f228951ac57", "d3eaebf7eba1b3ec"
# )


# # On 2022-06-28
#
# badIDs <- c(
#   # NM
#   "a5cc95dacaa954b2",
#   # MT
#   "d65023bd11de1e16",
#   # CA
#   "ac99ff93ffe38cb8", "bd644b571433095f", "0bef3590099e0682"
# )

# On 2022-08-08
#

badIDs <- c(
  # ID
  "677bb45d81f47bb6", "3a64bb0e0488e5b3",
  # CA
  "60a8ddd37911d9b5", "4c9714779b8cbe13", "26e2936f2fd2dc86", "8a049201c21aa8be",
  "671ec3d58035d34e", "44f731891be357b4"
)

locationTbl <-
  locationTbl %>%
  table_removeRecord(locationID = badIDs, verbose = TRUE)

# ----- Review adjacent locations ----------------------------------------------

adjacent_kl <-
  locationTbl %>%
  table_findAdjacentLocations(distanceThreshold = 200) # 500 is the actual separation we use

map <-
  adjacent_kl %>%
  MazamaLocationUtils::table_leaflet(
    extraVars = c("locationName", "fullAQSID"),
    jitter = 0
  )

print(map)


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


