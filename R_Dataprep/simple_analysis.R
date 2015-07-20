## Some simple exploratory models

# load data
PracticumData <- read.csv("~/Desktop/GW/Practicum/census-predictor/prepared_data/PracticumDataFull.csv", stringsAsFactors=FALSE)
PracticumDataTransformed <- read.csv("~/Desktop/GW/Practicum/census-predictor/prepared_data/PracticumDataTransformed.csv", stringsAsFactors=FALSE)

## scatter plots of population vs SS recips, IRS returns
#unscaled
plot(PracticumData$X2010.SSrecip, PracticumData$X2010pop)
plot(PracticumData$IRS_rtrns, PracticumData$X2010pop)

#log-scaled
plot(PracticumDataTransformed$log_irsreturns, PracticumDataTransformed$log_pop)
plot(PracticumDataTransformed$log_ssrecip, PracticumDataTransformed$log_pop)
## end scatter plots of population vs SS recips, IRS returns

## residuals for log and untransformed population vs SS recips, IRS returns
pop_mod_ssirs <- lm(X2010pop ~ X2010.SSrecip + IRS_rtrns, 
                       data=PracticumData)
summary(pop_mod_ssirs)
ss_irs_na_idx <- is.na(PracticumDataTransformed$log_ssrecip) | is.na(PracticumDataTransformed$log_irsreturns)
plot(PracticumData$X2010pop[!ss_irs_na_idx], pop_mod_ssirs$residuals)

log_pop_mod_ssirs <- lm(log_pop ~ log_ssrecip + log_irsreturns, 
                    data=PracticumDataTransformed)
summary(log_pop_mod_ssirs)
ss_irs_na_idx <- is.na(PracticumDataTransformed$log_ssrecip) | is.na(PracticumDataTransformed$log_irsreturns)
plot(PracticumDataTransformed$log_pop[!ss_irs_na_idx], log_pop_mod_ssirs$residuals)
## end residuals for log and untransformed population vs SS recips, IRS returns

log_pop_mod_full <- lm(log_pop ~ log_ssrecip + log_irsreturns +
                     log_gas_stations + log_fastfood + log_careCenters + 
                     log_hosp_beds + log_towers + log_homeDaycare + log_starbucks + 
                     home_depot_count + lowes_count + whole_foods_count, 
                   data=PracticumDataTransformed)
summary(log_pop_mod_full)
ss_irs_na_idx <- is.na(PracticumDataTransformed$log_ssrecip) | is.na(PracticumDataTransformed$log_irsreturns)
plot(PracticumDataTransformed$log_pop[!ss_irs_na_idx], log_pop_mod_full$residuals)

pop_mod_nogov <- lm(log_pop ~ log_gas_stations + log_fastfood + log_careCenters + 
                       log_hosp_beds + log_towers + log_homeDaycare + log_starbucks + 
                       home_depot_count + lowes_count + whole_foods_count, 
                     data=PracticumDataTransformed)

white_mod_simple <- lm(xformed_white ~ log_gas_stations + log_fastfood + log_careCenters + 
                         log_hosp_beds + log_towers + log_homeDaycare + log_starbucks + 
                         home_depot_count + lowes_count + whole_foods_count, 
                       data=PracticumDataTransformed)

# take subset of data where log_percblack is not negative infinity
DataBlackFinite <- PracticumDataTransformed[!is.infinite(PracticumDataTransformed$log_percblack),]

black_mod_simple <- lm(log_percblack ~ log_gas_stations + log_fastfood + log_careCenters + 
                         log_hosp_beds + log_towers + log_homeDaycare + log_starbucks + 
                         home_depot_count + lowes_count + whole_foods_count, 
                       data=DataBlackFinite)

## look at residuals to determine whether log-scaling is appropriate


