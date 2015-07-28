### KNN with full loc data

source("./census_utils.R")

BestPracticumData <- read.csv("../prepared_data/BestDataYet.csv", stringsAsFactors=FALSE)

# use only non-holdout data
population_by_zip_train <- read.csv("../prepared_data/population_by_zip_train.csv")
nonholdout_data <- PracticumDataWithLocs[BestPracticumData$zipCode %in% population_by_zip_train$zipCode,]

# throw out data w/ 0 population
nonholdout_data <- nonholdout_data[nonholdout_data$X2010pop > 0,]

# throw out data w/ no values for race demographics
racedemodata <- nonholdout_data[!is.na(nonholdout_data$percwhite) &
                                     !is.na(nonholdout_data$percblack) &
                                     !is.na(nonholdout_data$percasian),]

# further split into current training, validation data sets
racedemodata_size <- nrow(racedemodata)
training_prop <- 0.8
training_idx <- sample(racedemodata_size,racedemodata_size*training_prop)
training_data <- racedemodata[training_idx,]
validation_data <- racedemodata[-training_idx,]

## build knn models w/ lat/lon vars only

# select only lat/lon vars
ziploc_only_training <- subset(training_data,select=c(latitude,longitude))
ziploc_only_validation <- subset(validation_data,select=c(latitude,longitude))

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

###
### KNN model for percent bachelors degrees
###

# throw out data w/ no values for percent bachelors
degreedata <- nonholdout_data[!is.na(nonholdout_data$percbachelors) &
                                  !is.na(nonholdout_data$percgraddegree),]

# further split into current training, validation data sets
degreedata_size <- nrow(degreedata)
training_prop <- 0.8
training_idx <- sample(degreedata_size,degreedata_size*training_prop)
training_data <- degreedata[training_idx,]
validation_data <- degreedata[-training_idx,]

## build knn models w/ lat/lon vars only

# select only lat/lon vars
ziploc_only_training <- subset(training_data,select=c(latitude,longitude))
ziploc_only_validation <- subset(validation_data,select=c(latitude,longitude))

# obtain lat/lon knn validation predictions for percent with bachelors degree
knn_bachelors_loc <- knn.reg(train=ziploc_only_training,test=ziploc_only_validation,
                             y=training_data$percbachelors,k=4)
summary(knn_bachelors_loc$pred)
rsq_val(knn_bachelors_loc$pred,validation_data$percbachelors)

# obtain lat/lon knn validation predictions for percent with graduate degree
knn_graddegree_loc <- knn.reg(train=ziploc_only_training,test=ziploc_only_validation,
                             y=training_data$percgraddegree,k=4)
summary(knn_graddegree_loc$pred)
rsq_val(knn_graddegree_loc$pred,validation_data$percgraddegree)

###
### KNN model for median household income
###

# throw out data w/ no values for percent bachelors
incomedata <- nonholdout_data[!is.na(nonholdout_data$medhhsincome),]

# further split into current training, validation data sets
incomedata_size <- nrow(incomedata)
training_prop <- 0.8
training_idx <- sample(incomedata_size,incomedata_size*training_prop)
training_data <- incomedata[training_idx,]
validation_data <- incomedata[-training_idx,]

## build knn models w/ lat/lon vars only

# select only lat/lon vars
ziploc_only_training <- subset(training_data,select=c(latitude,longitude))
ziploc_only_validation <- subset(validation_data,select=c(latitude,longitude))

# obtain lat/lon knn validation predictions for income
knn_income_loc <- knn.reg(train=ziploc_only_training,test=ziploc_only_validation,
                             y=training_data$medhhsincome,k=4)
summary(knn_income_loc$pred)
rsq_val(knn_income_loc$pred,validation_data$medhhsincome)



