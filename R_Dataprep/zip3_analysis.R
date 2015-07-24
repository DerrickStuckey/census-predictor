## compute some demographic stats based on zip-3

# load main data set
PracticumData <- read.csv("../prepared_data/PracticumDataFull.csv", stringsAsFactors=FALSE)

# find duplicate zip codes
dupzips <- PracticumData$zipCode[duplicated(PracticumData$zipCode)]
# for each duplicated zip code, keep the entry w/ higher population


# drop last 2 digits of zip code to obtain zip-3
#PracticumData$zip3 <- as.integer(PracticumData$zipCode / 100)

# convert all percentages to counts
CountsOnlyData <- subset(PracticumData, 
                         select=c(X2010pop, X2010.SSrecip, IRS_rtrns, Beds, gasStations, 
                                  count_fastfood, towers, careCenters, homeDaycare,
                                  f_markets, walmart_stores, target_stores, CVSstores, 
                                  home_depot_count, lowes_count, whole_foods_count,
                                  basspro_count, starbucks_count, zipCode))

# load raw race count data
pop_race_zip_derrick <- read.csv("~/Desktop/GW/Practicum/census-predictor/prepared_data/pop_race_zip_derrick.csv", stringsAsFactors=FALSE)
pop_race_zip_slim <- subset(pop_race_zip_derrick, select=-c(Population))

# merge race count data
CountsWithRace <- merge(CountsOnlyData, pop_race_zip_slim, by.x="zipCode")


# aggregate each column by summing over zip-3
Zip3Data <- aggregate(CountsOnlyData, by=list(PracticumData$zip3), FUN=sum)
