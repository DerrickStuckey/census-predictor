## Impute missing Zillow Data

library(FNN)

source("./census_utils.R")

# load data
PracticumDataWithLocs <- read.csv("../prepared_data/PracticumDataWithLocs.csv", stringsAsFactors=FALSE)

# analyze amount of data w/ rent, w/ homeprice, w/ both, w/ neither
rent_no_price <- PracticumDataWithLocs[!is.na(PracticumDataWithLocs$rent_201501) & is.na(PracticumDataWithLocs$homeprice_201501),]
price_no_rent <- PracticumDataWithLocs[is.na(PracticumDataWithLocs$rent_201501) & !is.na(PracticumDataWithLocs$homeprice_201501),]
no_rent_no_price <- PracticumDataWithLocs[is.na(PracticumDataWithLocs$rent_201501) & is.na(PracticumDataWithLocs$homeprice_201501),]
nrow(rent_no_price)
nrow(price_no_rent)
nrow(no_rent_no_price)

###
### Test rent imputation
###

usable_data <- PracticumDataWithLocs

# throw out data w/ 0 population
usable_data <- usable_data[usable_data$X2010pop > 0,]

# throw out data w/ no lat/lon values
usable_data <- usable_data[!is.na(usable_data$latitude),]

# throw out data w/ no Zillow rent data
usable_data <- usable_data[!is.na(usable_data$rent_201501),]

dim(usable_data)

# further split into current training, validation data sets
nonhouldout_size <- nrow(usable_data)
training_prop <- 0.8
training_idx <- sample(nonhouldout_size,nonhouldout_size*training_prop)
training_data <- usable_data[training_idx,]
validation_data <- usable_data[-training_idx,]

# select only lat/lon vars
ziploc_only_training <- subset(training_data,select=c(latitude,longitude))
ziploc_only_validation <- subset(validation_data,select=c(latitude,longitude))

# obtain lat/lon knn validation predictions for percent white
knn_rent_loc <- knn.reg(train=ziploc_only_training,test=ziploc_only_validation,
                         y=training_data$rent_201501,k=4)
summary(knn_rent_loc$pred)
rsq_val(knn_rent_loc$pred,validation_data$rent_201501)

###
### Test homeprice imputation
###

# use full dataset, including holdout data
usable_data <- PracticumDataWithLocs

# throw out data w/ 0 population
usable_data <- usable_data[usable_data$X2010pop > 0,]

# throw out data w/ no lat/lon values
usable_data <- usable_data[!is.na(usable_data$latitude),]

# throw out data w/ no Zillow rent data
usable_data <- usable_data[!is.na(usable_data$homeprice_201501),]

dim(usable_data)

# further split into current training, validation data sets
nonhouldout_size <- nrow(usable_data)
training_prop <- 0.8
training_idx <- sample(nonhouldout_size,nonhouldout_size*training_prop)
training_data <- usable_data[training_idx,]
validation_data <- usable_data[-training_idx,]

# select only lat/lon vars
ziploc_only_training <- subset(training_data,select=c(latitude,longitude))
ziploc_only_validation <- subset(validation_data,select=c(latitude,longitude))

# obtain lat/lon knn validation predictions for homeprice
knn_rent_loc <- knn.reg(train=ziploc_only_training,test=ziploc_only_validation,
                        y=training_data$homeprice_201501,k=4)
summary(knn_rent_loc$pred)
rsq_val(knn_rent_loc$pred,validation_data$homeprice_201501)

###
### Test valchange imputation
###

# use full dataset, including holdout data
usable_data <- PracticumDataWithLocs

# throw out data w/ 0 population
usable_data <- usable_data[usable_data$X2010pop > 0,]

# throw out data w/ no lat/lon values
usable_data <- usable_data[!is.na(usable_data$latitude),]

# throw out data w/ no Zillow rent data
usable_data <- usable_data[!is.na(usable_data$valuechange_5year),]

dim(usable_data)

# further split into current training, validation data sets
nonhouldout_size <- nrow(usable_data)
training_prop <- 0.8
training_idx <- sample(nonhouldout_size,nonhouldout_size*training_prop)
training_data <- usable_data[training_idx,]
validation_data <- usable_data[-training_idx,]

# select only lat/lon vars
ziploc_only_training <- subset(training_data,select=c(latitude,longitude))
ziploc_only_validation <- subset(validation_data,select=c(latitude,longitude))

# obtain lat/lon knn validation predictions for valuechange_5year
knn_rent_loc <- knn.reg(train=ziploc_only_training,test=ziploc_only_validation,
                        y=training_data$valuechange_5year,k=4)
summary(knn_rent_loc$pred)
rsq_val(knn_rent_loc$pred,validation_data$valuechange_5year)


