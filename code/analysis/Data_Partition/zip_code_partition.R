## Train/Test split for full practicum project
## Testing data will be held for later use

# read in population data
pop <- read.csv("../../../prepared_data/population_by_zip.csv")

# convert zip code values to strings and pad with zeros
library(stringr)
pop$zipCode <- str_pad(as.character(pop$zipCode), 5, pad="0")

#View(pop)
data_size <- nrow(pop)
train_size <- data_size*0.8

set.seed(11235)
trainindex <- sample(data_size, train_size, replace=FALSE)
training <- pop[trainindex,]
holdout <- pop[-trainindex,]

write.csv(training, "../../../prepared_data/population_by_zip_train.csv", row.names=FALSE)
write.csv(holdout, "../../../prepared_data/population_by_zip_holdout.csv", row.names=FALSE)

