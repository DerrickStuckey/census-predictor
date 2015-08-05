## attempt at neural network model for 2010 population
install.packages("neuralnet")
library(neuralnet)
source("../utils/census_utils.R")
source("../utils/crossval_utils.R")

# load predictors
Practicum_Predictors_Normalized <- read.csv("../../prepared_data/Practicum_Predictors_Normalized.csv", stringsAsFactors=FALSE)

# load targets
Practicum_Targets <- read.csv("../../prepared_data/Practicum_Targets.csv", stringsAsFactors=FALSE)

# carve out holdout data
Model_Target_Data <- Practicum_Targets[Practicum_Targets$partition==1,]
Test_Target_Data <- Practicum_Targets[Practicum_Targets$partition==0,]

# join the two
# Practicum_Data_Full <- merge(Practicum_Targets,Practicum_Predictors_Normalized,by="zipCode")

# construct model dataset for population
Pop_Model_Target_Data <- subset(Model_Target_Data, select=c(zipCode,pop_2010))
Pop_Model_Data <- merge(Pop_Model_Target_Data,Practicum_Predictors_Normalized,by="zipCode",
                        all.x=TRUE,all.y=FALSE)

# construct training/validation datasets from non-holdout data
set.seed(11235)
Pop_Model_Data_Shuffled <- shuffle(Pop_Model_Data)
training <- select_training(Pop_Model_Data_Shuffled,5,1)
validation <- select_validation(Pop_Model_Data_Shuffled,5,1)

nnetfit <- neuralnet(pop_2010~SS_recip + IRS_returns, training, hidden=0,
          rep=10, err.fct="sse", linear.output=FALSE)

# TODO get preds
