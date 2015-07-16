## Merge Age/Gender data into full practicum data csv

PracticumData <- read.csv("~/Downloads/PracticumData.csv", stringsAsFactors=FALSE)

pop_age_gender_zip_clean <- read.csv("../prepared_data/pop_age_gender_zip_clean.csv", stringsAsFactors=FALSE)

# Merge by matching zip code and state (some zip codes cross state lines)
merged_data <- merge(PracticumData, pop_age_gender_zip_clean, 
                     by.x=c("zipCode","stateCode"), by.y=c("ZipCode","stateCode"))

View(merged_data)

# find duplicates
# dupzips <- PracticumData$zipCode[duplicated(PracticumData$zipCode)]

# duplicates due to zip codes crossing state lines
#dupdata <- PracticumData[PracticumData$zipCode %in% dupzips,]

write.csv(merged_data, file="../prepared_data/PracticumDataFull.csv", row.names=FALSE, quote=FALSE)

## import Bass Pro locations and merge
basspro <- read.csv("~/Desktop/GW/Practicum/census-predictor/prepared_data/basspro.csv", stringsAsFactors=FALSE)
names(basspro)[2] <- "basspro_count"

merged_basspro <- merge(merged_data, basspro, 
                        by.x="zipCode", by.y="ZipCode", all.x=TRUE, all.y=FALSE)

#replace N/A's w/ 0 for basspro location counts
merged_basspro$basspro_count[is.na(merged_basspro$basspro_count)] <- 0

write.csv(merged_basspro, file="../prepared_data/PracticumDataFull.csv", row.names=FALSE, quote=FALSE)


