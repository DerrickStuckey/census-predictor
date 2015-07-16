## Prepare and merge Starbucks data

starbucks <- read.csv("~/Desktop/GW/Practicum/census-predictor/raw_data/All_Starbucks_Locations_in_the_US.csv", stringsAsFactors=FALSE)

View(starbucks)

starbucks$ZipCode <- as.numeric(substr(starbucks$Zip,0,5))

starbucks_counts <- aggregate(starbucks$ZipCode, by=list(starbucks$ZipCode), FUN=length)
names(starbucks_counts) <- c("zipCode","starbucks_count")

PracticumData <- read.csv("../prepared_data/PracticumDataFull.csv", stringsAsFactors=FALSE)

merged_data <- merge(PracticumData, starbucks_counts, by="zipCode", all.x=TRUE, all.y=FALSE)

merged_data$starbucks_count[is.na(merged_data$starbucks_count)] <- 0

write.csv(merged_data, file="../prepared_data/PracticumDataFull.csv", row.names=FALSE, quote=FALSE)
