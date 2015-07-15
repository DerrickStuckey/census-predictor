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
