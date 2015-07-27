## knn predictive model 2

# load data
PracticumDataWithLocs <- read.csv("../prepared_data/PracticumDataWithLocs.csv", stringsAsFactors=FALSE)

#calc race percentages
PracticumDataWithLocs$percblack <- PracticumDataWithLocs$Black / PracticumDataWithLocs$X2010pop * 100
PracticumDataWithLocs$percwhite <- PracticumDataWithLocs$White / PracticumDataWithLocs$X2010pop * 100
PracticumDataWithLocs$percasian <- PracticumDataWithLocs$Asian / PracticumDataWithLocs$X2010pop * 100

# use only non-holdout data
population_by_zip_train <- read.csv("../prepared_data/population_by_zip_train.csv")
nonholdout_data <- PracticumDataWithLocs[PracticumDataWithLocs$zipCode %in% population_by_zip_train$zipCode,]

# throw out data w/ no values for race demographics
nonholdout_data <- nonholdout_data[!is.na(nonholdout_data$percwhite) &
                                     !is.na(nonholdout_data$percblack) &
                                     !is.na(nonholdout_data$percasian),]

# further split into current training, validation data sets
nonhouldout_size <- nrow(nonholdout_data)
training_prop <- 0.8
training_idx <- sample(nonhouldout_size,nonhouldout_size*training_prop)
training_data <- nonholdout_data[training_idx,]
validation_data <- nonholdout_data[-training_idx,]

## function to find R-sq for predictions
rsq_val <- function(preds, actuals) {
  sst <- sum((actuals - mean(actuals))^2)
  sse <- sum((actuals - preds)^2)
  return (1 - sse/sst)
}

## build knn models w/ lat/lon vars only
library(FNN)
#remove NA lat/lons
training_data_withlat <- training_data[!is.na(training_data$latitude),]
validation_data_withlat <- validation_data[!is.na(validation_data$latitude),]

# select only lat/lon vars
ziploc_only_training <- subset(training_data_withlat,select=c(latitude,longitude))
ziploc_only_validation <- subset(validation_data_withlat,select=c(latitude,longitude))

## k=4 seems to be the best choice

# obtain lat/lon knn validation predictions for percent white
knn_white_loc <- knn.reg(train=ziploc_only_training,test=ziploc_only_validation,
                     y=training_data_withlat$percwhite,k=4)
summary(knn_white_loc$pred)
rsq_val(knn_white_loc$pred,validation_data_withlat$percwhite)

# obtain lat/lon knn validation predictions for percent black
knn_black_loc <- knn.reg(train=ziploc_only_training,test=ziploc_only_validation,
                     y=training_data_withlat$percblack,k=4)
summary(knn_black_loc$pred)
rsq_val(knn_black_loc$pred,validation_data_withlat$percblack)

# obtain lat/lon knn validation predictions for percent asian
knn_asian_loc <- knn.reg(train=ziploc_only_training,test=ziploc_only_validation,
                     y=training_data_withlat$percasian,k=4)
summary(knn_asian_loc$pred)
rsq_val(knn_asian_loc$pred,validation_data_withlat$percasian)

## obtain knn predictions using other predictors
retail_only_training <- subset(training_data, 
                               select=c(starbucks_count, count_fastfood, whole_foods_count,
                                        walmart_stores, target_stores, home_depot_count,
                                        lowes_count, basspro_count, f_markets))

knn_

  
#   Zip3Data$starbucks_count + Zip3Data$count_fastfood + 
#   Zip3Data$whole_foods_count + Zip3Data$walmart_stores + Zip3Data$target_stores


