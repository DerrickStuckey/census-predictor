## merge location data

# load location data
zipcode_locs <- read.csv("../raw_data/zipcode_latlon.csv", stringsAsFactors=FALSE)
more_zipcode_locs <- read.csv("../raw_data/zipcode_locs_scraped.csv", stringsAsFactors=FALSE)
names(more_zipcode_locs)[1] <- "zip"

# construct dataframe w/ only relevant variables
zipcode_locs_slim <- subset(zipcode_locs, select=c(zip,latitude,longitude))

zipcode_locs_slim <- rbind(zipcode_locs_slim, more_zipcode_locs)

PracticumDataDeduped <- read.csv("../prepared_data/PracticumDataDedupedZips.csv", stringsAsFactors=FALSE)

# merge the data
merged <- merge(PracticumDataDeduped, zipcode_locs_slim, by.x="zipCode",by.y="zip",
                all.x=TRUE, all.y=FALSE)

write.csv(merged, file="../prepared_data/PracticumDataWithLocs.csv",
          row.names=FALSE, quote=FALSE)