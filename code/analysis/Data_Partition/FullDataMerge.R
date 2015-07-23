## Split data into predictors, target vars

PracticumData <- read.csv("~/Desktop/GW/Practicum/census-predictor/prepared_data/PracticumDataFull.csv", stringsAsFactors=FALSE)
PracticumDataTransformed <- read.csv("~/Desktop/GW/Practicum/census-predictor/prepared_data/PracticumDataTransformed.csv", stringsAsFactors=FALSE)

#load training, holdout zip code sets
population_by_zip_train <- read.csv("~/Desktop/GW/Practicum/census-predictor/prepared_data/population_by_zip_train.csv", stringsAsFactors=FALSE)
population_by_zip_holdout <- read.csv("~/Desktop/GW/Practicum/census-predictor/prepared_data/population_by_zip_holdout.csv", stringsAsFactors=FALSE)

#construct slim train dataframe w/ just keys, partition flag
train_partition <- data.frame("zipCode"=population_by_zip_train$zipCode,
                              "stateCode"=population_by_zip_train$stateCode)
train_partition$partition <- "train"

#construct slim holdout dataframe w/ just keys, partition flag
holdout_partition <- data.frame("zipCode"=population_by_zip_holdout$zipCode,
                              "stateCode"=population_by_zip_holdout$stateCode)
holdout_partition$partition <- "holdout"

zip_partitions <- rbind(train_partition, holdout_partition)

View(zip_partitions)

# add partition flags to each dataset by merging
PracticumDataFlagged <- merge(PracticumData, zip_partitions)
PracticumDataTransformedFlagged <- merge(PracticumDataTransformed, zip_partitions)

write.csv(PracticumDataFlagged, file="../prepared_data/PracticumDataFull.csv",
          row.names=FALSE, quote=FALSE)


