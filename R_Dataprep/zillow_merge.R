## merge Zillow data with full Practicum Data set

# load Zillow data
medianHomePrice <- read.csv("../raw_data/medianHomePrice.csv", stringsAsFactors=FALSE)
medianRentIndex <- read.csv("../raw_data/medianRentIndex.csv", stringsAsFactors=FALSE)
ValueChange5yr <- read.csv("../raw_data/ValueChange5yr.csv", stringsAsFactors=FALSE)

# load practicum data
PracticumData <- read.csv("~/Desktop/GW/Practicum/census-predictor/prepared_data/PracticumDataFull.csv", stringsAsFactors=FALSE)

homeprice_slim <- data.frame("zipCode"=medianHomePrice$RegionName,
                             "homeprice_201501"=medianHomePrice$X2015.01)

rent_slim <- data.frame("zipCode"=medianRentIndex$RegionName,
                        "rent_201501"=medianRentIndex$X2015.01)

valuechange_slim <- data.frame("zipCode"=ValueChange5yr$RegionName,
                               "valuechange_5year"=ValueChange5yr$X5Year)

merged_1 <- merge(PracticumData, homeprice_slim, by="zipCode", all.x=TRUE, all.y=FALSE)

merged_2 <- merge(merged_1, rent_slim, by="zipCode", all.x=TRUE, all.y=FALSE)

merged_3 <- merge(merged_2, valuechange_slim, by="zipCode", all.x=TRUE, all.y=FALSE)

write.csv(merged_3, "../prepared_data/PracticumDataFull.csv",
          row.names=FALSE, quote=FALSE)
