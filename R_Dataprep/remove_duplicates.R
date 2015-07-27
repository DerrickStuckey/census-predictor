## Consolidate duplicate zip codes (which cross state lines) into single zip codes

# load main data set
PracticumData <- read.csv("../prepared_data/PracticumDataFull.csv", stringsAsFactors=FALSE)

# compute counts for other percentage variables, weighted sum by population
PracticumData$countbachelors <- PracticumData$percbachelors * PracticumData$X2010pop
PracticumData$countgraddegree <- PracticumData$percgraddegree * PracticumData$X2010pop

# extract columns representing counts
CountsOnlyData <- subset(PracticumData, 
                         select=c(X2010pop, X2010.SSrecip, IRS_rtrns, zipCode, 
                                  stateCode, countbachelors, countgraddegree))

# load raw race count data
pop_race_zip_derrick <- read.csv("../raw_data/pop_race_zip_derrick.csv", stringsAsFactors=FALSE)
pop_race_zip_slim <- subset(pop_race_zip_derrick, select=-c(Population,Total_Race_Count))

# merge race count data
CountsWithRace <- merge(CountsOnlyData, pop_race_zip_slim, 
                        by.x=c("zipCode","stateCode"),
                        by.y=c("zip.code.tabulation.area","state"))

# load raw age data
pop_age_gender_zip <- read.csv("../raw_data/pop_age_gender_zip.csv", stringsAsFactors=FALSE)
pop_age_gender_zip_slim <- subset(pop_age_gender_zip, select=-c(Population,Total_Population))

# merge age, gender data
FullCountsData <- merge(CountsWithRace, pop_age_gender_zip_slim, 
                        by.x=c("zipCode","stateCode"),
                        by.y=c("zip.code.tabulation.area","state"))

# compute counts for other percentage variables, weighted sum by population
# PracticumData$countbachelors <- PracticumData$percbachelors * PracticumData$X2010pop
# PracticumData$countgraddegree <- PracticumData$percgraddegree * PracticumData$X2010pop
# DegreeData <- data.frame("zipCode"=PracticumData$zipCode,
#                          "stateCode"=PracticumData$stateCode,
#                          "countbachelors"=)

zipCodes <- FullCountsData$zipCode
FullCountsData <- subset(FullCountsData, select=-c(zipCode,stateCode))

# aggregate by zip code
CountsDataAgged <- aggregate(FullCountsData, by=list(zipCodes), FUN=sum, na.rm=FALSE)
names(CountsDataAgged)[names(CountsDataAgged)=="Group.1"] <- "zipCode"

### Compute primary state for each zip code ###

# sort by population descending
SortedData <- PracticumData[order(PracticumData$X2010pop, decreasing=TRUE),]

# find duplicate zip codes (index of 2nd entry for each duplicate)
dupindices <- duplicated(SortedData$zipCode)

DedupedData <- SortedData[!dupindices,]

primaryZipMap <- data.frame("zipCode"=DedupedData$zipCode,
                            "stateCode"=DedupedData$stateCode,
                            "state"=DedupedData$state)

# write.csv(primaryZipMap, file="../prepared_data/zip_with_primary_state.csv",
#           row.names=FALSE, quote=FALSE)

### For variables not corresponding to population counts, ###
### take the value from the zip/state
### entry corresponding to the primary state for that zip code 

PrimaryStateData <- subset(DedupedData, select=c(zipCode,medhhsincome,homeprice_201501,
                                                 rent_201501,valuechange_5year,
                                                 com_elecrate, ind_elecrate, res_elecrate,
                                                 Beds, gasStations, 
                                                 count_fastfood, towers, careCenters, homeDaycare,
                                                 f_markets, walmart_stores, target_stores, CVSstores, 
                                                 home_depot_count, lowes_count, whole_foods_count,
                                                 basspro_count, starbucks_count))
PrimaryStateData$primaryState <- DedupedData$state
PrimaryStateData$primaryStateCode <- DedupedData$stateCode

FinishedData <- merge(CountsDataAgged, PrimaryStateData, by="zipCode")

# compute percentages from counts
FinishedData$percbachelors <- FinishedData$countbachelors / FinishedData$X2010pop
FinishedData$percgraddegree <- FinishedData$countgraddegree / FinishedData$X2010pop
FinishedData$percblack <- FinishedData$Black / FinishedData$X2010pop * 100
FinishedData$percwhite <- FinishedData$White / FinishedData$X2010pop * 100
FinishedData$percasian <- FinishedData$Asian / FinishedData$X2010pop * 100

#write the finished data
write.csv(FinishedData, file="../prepared_data/PracticumDataDedupedZips.csv",
          row.names=FALSE, quote=FALSE)