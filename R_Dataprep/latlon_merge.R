## merge location data

# load location data
zipcode_locs <- read.csv("../raw_data/zipcode_latlon.csv", stringsAsFactors=FALSE)

# construct dataframe w/ only relevant variables
zipcode_locs_slim <- subset(zipcode_locs, select=c(zip,latitude,longitude))

PracticumDataDeduped <- read.csv("../prepared_data/PracticumDataDedupedZips.csv", stringsAsFactors=FALSE)

# merge the data
merged <- merge(PracticumDataDeduped, zipcode_locs_slim, by.x="zipCode",by.y="zip",
                all.x=TRUE, all.y=FALSE)

write.csv(merged, file="../prepared_data/PracticumDataWithLocs.csv",
          row.names=FALSE, quote=FALSE)