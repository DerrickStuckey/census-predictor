## exploratory analysis of education demographics w/ neural network analysis
library(caret)
source("../utils/census_utils.R")
source("../utils/crossval_utils.R")

# load predictors
Practicum_Predictors_Normalized <- read.csv("../../prepared_data/Practicum_Predictors_Normalized.csv", stringsAsFactors=FALSE)

# load targets
Practicum_Targets <- read.csv("../../prepared_data/Practicum_Targets.csv", stringsAsFactors=FALSE)

# remove data w/o education values
Practicum_Targets <- Practicum_Targets[!is.na(Practicum_Targets$perc_bachelors),]

# carve out holdout data
Model_Target_Data <- Practicum_Targets[Practicum_Targets$partition==1,]
Test_Target_Data <- Practicum_Targets[Practicum_Targets$partition==0,]

# construct model dataset for education
Edu_Model_Target_Data <- subset(Model_Target_Data, select=c(zipCode,perc_bachelors))
Edu_Model_Data <- merge(Edu_Model_Target_Data,Practicum_Predictors_Normalized,by="zipCode",
                        all.x=TRUE,all.y=FALSE)

# shuffle data
set.seed(11235)
Edu_Model_Data_Shuffled <- shuffle(Edu_Model_Data)

training <- select_training(Edu_Model_Data_Shuffled,5,1)
validation <- select_validation(Edu_Model_Data_Shuffled,5,1)

#obtain best parameters
# my.grid <- expand.grid(.decay = c(0,0.1), .size = c(5,10))
my.grid <- expand.grid(.decay = c(0), .size = c(10)) #found best
nnet_fit <- train(perc_bachelors ~ .-zipCode-state_code, data = training,
                  method = "nnet", maxit = 50, tuneGrid = my.grid, trace = F, linout = 1)
summary(nnet_fit)
# get predictions and rsq
nnet_preds <- predict(nnet_fit, newdata=validation)
rsq_nnet <- rsq_val(nnet_preds,validation$perc_bachelors)
rsq_nnet

# R-sq of 0.5211205 obtained using maxit=50, decay=0, size=10
