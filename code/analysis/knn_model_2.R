## knn predictive model 2

# load data
PracticumDataWithLocs <- read.csv("../prepared_data/PracticumDataWithLocs.csv", stringsAsFactors=FALSE)

#calc race percentages
PracticumDataWithLocs$percblack <- PracticumDataWithLocs$Black / PracticumDataWithLocs$X2010pop * 100
PracticumDataWithLocs$percwhite <- PracticumDataWithLocs$White / PracticumDataWithLocs$X2010pop * 100
PracticumDataWithLocs$percasian <- PracticumDataWithLocs$Asian / PracticumDataWithLocs$X2010pop * 100

# split into training, test
population_by_zip_train <- read.csv("../prepared_data/population_by_zip_train.csv")
nonholdout_data <- PracticumDataWithLocs[PracticumDataWithLocs$zipCode %in% population_by_zip_train$zipCode,]

## try knn w/ lat/lon, irs
library(FNN)
#remove NA lat/lons
nonholdout_data_nna <- nonholdout_data[!is.na(nonholdout_data$latitude) & 
                                     !is.na(nonholdout_data$percwhite),]

# select only lat/lon vars
ziploc_only <- subset(nonholdout_data_nna,select=c(latitude,longitude))

## k=4 seems to be the best choice

# build and test cross-val R-sq for perc white predictions
knn_white <- knn.reg(train=ziploc_only,y=nonholdout_data_nna$percwhite,k=4)
knn_white

# build and test cross-val R-sq for perc black predictions
knn_black <- knn.reg(train=ziploc_only,y=nonholdout_data_nna$percblack,k=4)
knn_black

# build and test cross-val R-sq for perc asian predictions
knn_asian <- knn.reg(train=ziploc_only,y=nonholdout_data_nna$percasian,k=4)
knn_asian

# try with small sample (20% of holdout)
sample_idx <- sample(nrow(nonholdout_data_nna),nrow(nonholdout_data_nna)*0.2)
ziploc_sample <- ziploc_only[sample_idx,]
nonholdout_sample <- nonholdout_data_nna[sample_idx,]

# build and test cross-val R-sq for perc white predictions
knn_white <- knn.reg(train=ziploc_sample,y=nonholdout_sample$percwhite,k=4)
knn_white

# build and test cross-val R-sq for perc black predictions
knn_black <- knn.reg(train=ziploc_sample,y=nonholdout_sample$percblack,k=4)
knn_black

# build and test cross-val R-sq for perc asian predictions
knn_asian <- knn.reg(train=ziploc_sample,y=nonholdout_sample$percasian,k=4)
knn_asian


