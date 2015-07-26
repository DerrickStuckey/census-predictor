## knn predictive model

# load data
PracticumDataWithLocs <- read.csv("../prepared_data/PracticumDataWithLocs.csv", stringsAsFactors=FALSE)

# split into training, test
population_by_zip_train <- read.csv("../prepared_data/population_by_zip_train.csv")
nonholdout_data <- PracticumDataWithLocs[PracticumDataWithLocs$zipCode %in% population_by_zip_train$zipCode,]
nrows <- nrow(nonholdout_data)
train_idx <- sample(nrows,nrows*0.8)
training_data <- nonholdout_data[train_idx,]
validation_data <- nonholdout_data[-train_idx,]

# select only predictor vars
# PredictorVars <- subset(PracticumDataWithLocs, 
#                         select=c(homeprice_201501,rent_201501,valuechange_5year
#                                  com_elecrate,ind_elecrate,res_elecrate,Beds,gasStations,
#                                  count_fastfood,towers,careCenters,homeDay))
PredictorVars <- training_data[,63:87]
PredictorVars <- subset(PredictorVars, select=-c(primaryState,primaryStateCode))

# remove NA lat/lons
NnaPredictorVars <- PredictorVars[!is.na(PredictorVars$latitude),]

#remove Zillow data which is often NA
NnaPredictorVars <- NnaPredictorVars[,4:23]

# scale data
ScaledData <- scale(NnaPredictorVars)

kmeans_fit <- kmeans(ScaledData,centers=4)

## try knn w/ just lat/lon
library(FNN)
#calc percent white
training_data$percwhite <- training_data$White / training_data$X2010pop * 100
validation_data$percwhite <- validation_data$White / validation_data$X2010pop * 100
#remove NA lat/lons
training_data_nna <- training_data[!is.na(training_data$latitude) & 
                                     !is.na(training_data$percwhite),]
validation_data_nna <- validation_data[!is.na(validation_data$latitude) & 
                                         !is.na(validation_data$percwhite),]
#select only lat/lon vars from train, validation data
ziploc_train <- subset(training_data_nna,select=c(latitude,longitude))
ziploc_val <- subset(validation_data_nna,select=c(latitude,longitude))
#train knn
knn_white <- knn.reg(train=ziploc_train,test=ziploc_val,y=training_data_nna$percwhite,k=5)
knn_white <- knn.reg(train=ziploc_train,y=training_data_nna$percwhite,k=5)

knn_white_preds <- knn_white$pred


