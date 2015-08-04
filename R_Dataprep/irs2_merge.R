## IRS data merge

# load predictors
Practicum_Predictors_Normalized <- read.csv("../../prepared_data/Practicum_Predictors_Normalized.csv", stringsAsFactors=FALSE)

# load targets (for state code)
Practicum_Targets <- read.csv("~/Desktop/GW/Practicum/census-predictor/prepared_data/Practicum_Targets.csv")

# add state_code to predictors
ZipState <- subset(Practicum_Targets, select=c(zipCode,state_code))
Practicum_Predictors_Normalized <- merge(Practicum_Predictors_Normalized, ZipState, by="zipCode")

# load additional IRS data
IRS2 <- read.csv("~/Desktop/GW/Practicum/census-predictor/raw_data/IRS2.csv", stringsAsFactors=FALSE)

# merge IRS2 data w/ current predictors
IRS_merged <- merge(Practicum_Predictors_Normalized, IRS2, by.x=c("zipCode","state_code"),
                by.y=c("zipCode","fips"), all.x=TRUE, all.y=FALSE)

# impute values for IRS2 data by avg.
mean_avgDependents <- mean(IRS_merged$avgDependents,na.rm=TRUE)
IRS_merged$avgDependents[is.na(IRS_merged$avgDependents)] <- mean_avgDependents

mean_avgJointRtrns <- mean(IRS_merged$avgJointRtrns,na.rm=TRUE)
IRS_merged$avgJointRtrns[is.na(IRS_merged$avgJointRtrns)] <- mean_avgJointRtrns

mean_avgChldTxCred <- mean(IRS_merged$avgChldTxCred,na.rm=TRUE)
IRS_merged$avgChldTxCred[is.na(IRS_merged$avgChldTxCred)] <- mean_avgChldTxCred

mean_avgUnemp <- mean(IRS_merged$avgUnemp,na.rm=TRUE)
IRS_merged$avgUnemp[is.na(IRS_merged$avgUnemp)] <- mean_avgUnemp

mean_avgFrmRtrns <- mean(IRS_merged$avgFrmRtrns,na.rm=TRUE)
IRS_merged$avgFrmRtrns[is.na(IRS_merged$avgFrmRtrns)] <- mean_avgFrmRtrns

mean_avgTaxes <- mean(IRS_merged$avgTaxes,na.rm=TRUE)
IRS_merged$avgTaxes[is.na(IRS_merged$avgTaxes)] <- mean_avgTaxes

# remove erroneous columns
IRS_merged <- subset(IRS_merged, select=-c(index,X))

summary(is.na(IRS_merged))

# scale IRS2 data
IRS_merged$avgDependents <- scale(IRS_merged$avgDependents)
IRS_merged$avgJointRtrns <- scale(IRS_merged$avgJointRtrns)
IRS_merged$avgChldTxCred <- scale(IRS_merged$avgChldTxCred)
IRS_merged$avgUnemp <- scale(IRS_merged$avgUnemp)
IRS_merged$avgFrmRtrns <- scale(IRS_merged$avgFrmRtrns)
IRS_merged$avgTaxes <- scale(IRS_merged$avgTaxes)

# save the results
write.csv(IRS_merged, file="../../prepared_data/Practicum_Predictors_Normalized.csv",
          row.names=FALSE,quote=FALSE)

