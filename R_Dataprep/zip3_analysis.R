## compute some demographic stats based on zip-3

# load deduped-zip data set
PracticumDataDeduped <- read.csv("../prepared_data/PracticumDataDedupedZips.csv", 
                                 stringsAsFactors=FALSE)

# drop last 2 digits of zip code to obtain zip-3
PracticumDataDeduped$zip3 <- floor(PracticumDataDeduped$zipCode / 100)

# remove un-summable columns
CountsOnlyData <- subset(PracticumDataDeduped, 
                         select=-c(primaryState,primaryStateCode,
                                   medhhsincome,homeprice_201501,
                                   rent_201501,valuechange_5year,
                                   com_elecrate, ind_elecrate, res_elecrate,
                                   zipCode, zip3))

# aggregate each column by summing over zip-3
Zip3Data <- aggregate(CountsOnlyData, by=list(PracticumDataDeduped$zip3), FUN=sum)
names(Zip3Data)[names(Zip3Data)=="Group.1"] <- "zip3"

write.csv(Zip3Data, "../prepared_data/PracticumDataZip3.csv",
          row.names=FALSE, quote=FALSE)

