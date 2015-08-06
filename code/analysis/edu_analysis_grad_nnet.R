## Neural Net Grad Degree

source("../utils/census_utils.R")
source("../utils/crossval_utils.R")
library(caret)

# load predictors
Practicum_Predictors_Normalized <- read.csv("../../prepared_data/Practicum_Predictors_Normalized.csv", stringsAsFactors=FALSE)

# TODO add SS/IRS ratio as predictor

# load targets
Practicum_Targets <- read.csv("../../prepared_data/Practicum_Targets.csv", stringsAsFactors=FALSE)

# remove data w/o education values
Practicum_Targets <- Practicum_Targets[!is.na(Practicum_Targets$perc_graddegree),]

# carve out holdout data
Model_Target_Data <- Practicum_Targets[Practicum_Targets$partition==1,]
Test_Target_Data <- Practicum_Targets[Practicum_Targets$partition==0,]

# construct model dataset for education
Edu_Model_Target_Data <- subset(Model_Target_Data, select=c(zipCode,perc_graddegree))
Edu_Model_Data <- merge(Edu_Model_Target_Data,Practicum_Predictors_Normalized,by="zipCode",
                        all.x=TRUE,all.y=FALSE)

# shuffle data
set.seed(11235)
Edu_Model_Data_Shuffled <- shuffle(Edu_Model_Data)


training <- select_training(Edu_Model_Data_Shuffled,5,1)
validation <- select_validation(Edu_Model_Data_Shuffled,5,1)

#obtain best parameters
my.grid <- expand.grid(.decay = c(0,0.1), .size = c(5,10))
nnet_fit <- train(perc_graddegree ~ .-zipCode-state_code, data = training,
                  method = "nnet", maxit = 50, tuneGrid = my.grid, trace = F, linout = 1)
summary(nnet_fit)
# get predictions and rsq
nnet_preds <- predict(nnet_fit, newdata=validation)
rsq_nnet <- rsq_val(nnet_preds,validation$perc_graddegree)
rsq_nnet

# best parameters: decay 0, size 10: rsq 0.5901005

# test validation prediction performance for various #'s of iterations
# k=5
# iters <- seq(1,k,by=1)
# iter_vals <- c(20,50)
# rsq_vals <- rep(NA,k)
# for (iter in iters) {
#   iter_val <- iter_vals[iter]
#   iter_val <- 50
#   my.grid <- expand.grid(.decay = c(0), .size = c(10))
#   nnet_fit <- train(perc_graddegree ~ .-zipCode-state_code, data = training,
#                     method = "nnet", maxit = iter_val, tuneGrid = my.grid, trace = F, linout = 1)
#   
#   # get predictions and rsq
#   nnet_preds <- predict(nnet_fit, newdata=validation)
#   rsq_nnet <- rsq_val(nnet_preds,validation$perc_graddegree)
#   rsq_nnet
#   rsq_vals[iter] <- rsq_nnet
# }

# plot(iters,rsq_vals)
