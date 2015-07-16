## Data transformations

PracticumData <- read.csv("../prepared_data/PracticumDataFull.csv", stringsAsFactors=FALSE)

# replace NA's w/ appropriate values in base PracticumData dataframe
PracticumData$Beds[is.na(PracticumData$Beds)] <- 0
PracticumData$count_fastfood[is.na(PracticumData$count_fastfood)] <- 0
# Social Security recipients? (only a few NA's)

# transform proportions to percentages
PracticumData$percwhite <- PracticumData$percwhite*100
PracticumData$percblack <- PracticumData$percblack*100
PracticumData$percasian <- PracticumData$percasian*100
PracticumData$perchispanic <- PracticumData$perchispanic*100
PracticumData$percbachelors <- PracticumData$percbachelors*100
PracticumData$percgraddegree <- PracticumData$percgraddegree*100

## re-save the dataframe
write.csv(PracticumData, file="../prepared_data/PracticumDataFull.csv", row.names=FALSE, quote=FALSE)

## initialize transformed dataframe
PracticumDataTransformed <- data.frame("zipCode"=PracticumData$zipCode,
                                       "stateCode"=PracticumData$stateCode,
                                       "state"=PracticumData$state)

## define smoothed log transform to avoid log(0)
smoothed_log <- function(x) { log(x+1) }

## Target Data Transformations

# 2010 population
hist(PracticumData$X2010pop)
PracticumDataTransformed$log_pop = smoothed_log(PracticumData$X2010pop)
hist(PracticumDataTransformed$log_pop)

# medhhsincome
hist(PracticumData$medhhsincome)
PracticumDataTransformed$log_medhhsincome <- smoothed_log(PracticumData$medhhsincome)
hist(PracticumDataTransformed$log_medhhsincome)

# percent white
hist(PracticumData$percwhite)
PracticumDataTransformed$xformed_white <- 100 - smoothed_log(100 - PracticumData$percwhite)
# PracticumDataTransformed$xformed_white <- 100 - log(100 - PracticumData$percwhite)
hist(PracticumDataTransformed$xformed_white)

# percent black
hist(PracticumData$percblack)
PracticumDataTransformed$log_percblack <- log(PracticumData$percblack)
hist(PracticumDataTransformed$log_percblack) #still somewhat skewed 
# NOTE: contains some -INF values

# percent Asian
hist(PracticumData$percasian)
PracticumDataTransformed$log_percasian <- log(PracticumData$percasian)
hist(PracticumDataTransformed$log_percasian)
# NOTE: contains some -INF values

# percent Hispanic
hist(PracticumData$perchispanic)
PracticumDataTransformed$log_perchispanic <- log(PracticumData$perchispanic)
hist(PracticumDataTransformed$log_perchispanic)
# NOTE: contains some -INF values

# percent w/ bachelor's degree
hist(PracticumData$percbachelors)
PracticumDataTransformed$log_percbachelors <- smoothed_log(PracticumData$percbachelors)
hist(PracticumDataTransformed$log_percbachelors)

# percent w/ grad degree
hist(PracticumData$percgraddegree)
PracticumDataTransformed$log_percgraddegree <- smoothed_log(PracticumData$percgraddegree)
hist(PracticumDataTransformed$log_percgraddegree)

# proportion male
hist(PracticumData$prop_male)
PracticumDataTransformed$prop_male <- PracticumData$prop_male # no change

# proportion female
hist(PracticumData$prop_female)
PracticumDataTransformed$prop_female <- PracticumData$prop_female # no change

# proportion under 20
hist(PracticumData$prop_0_to_19)
summary(PracticumData$prop_0_to_19)
PracticumDataTransformed$prop_0_to_19 <- PracticumData$prop_0_to_19 # no change

# proportion 20-39
hist(PracticumData$prop_20_to_39)
summary(PracticumData$prop_20_to_39)
PracticumDataTransformed$prop_20_to_39 <- PracticumData$prop_20_to_39 # no change

# proportion 40-59
hist(PracticumData$prop_40_to_59)
summary(PracticumData$prop_40_to_59)
PracticumDataTransformed$prop_40_to_59 <- PracticumData$prop_40_to_59 # no change

# proportion 60+
hist(PracticumData$prop_60_plus)
summary(PracticumData$prop_60_plus)
PracticumDataTransformed$prop_60_plus <- PracticumData$prop_60_plus # no change

## Predictor Variable Transformations

# 2010 social security recipients
hist(PracticumData$X2010.SSrecip) #no zeros, don't need smoothed log
PracticumDataTransformed$log_ssrecip <- log(PracticumData$X2010.SSrecip)
hist(PracticumDataTransformed$log_ssrecip)

# IRS_rtrns
hist(PracticumData$IRS_rtrns) #no zeros, don't need smoothed log
PracticumDataTransformed$log_irsreturns <- log(PracticumData$IRS_rtrns)
hist(PracticumDataTransformed$log_irsreturns)

# Hospital Beds
hist(PracticumData$Beds)
PracticumDataTransformed$log_hosp_beds <- smoothed_log(PracticumData$Beds)
hist(PracticumDataTransformed$log_hosp_beds)

# gas stations
hist(PracticumData$gasStations)
PracticumDataTransformed$log_gas_stations <- smoothed_log(PracticumData$gasStations)
hist(PracticumDataTransformed$log_gas_stations) #still pretty skewed

# Fast Food counts
hist(PracticumData$count_fastfood)
PracticumDataTransformed$log_fastfood <- smoothed_log(PracticumData$count_fastfood)
hist(PracticumDataTransformed$log_fastfood) #still pretty skewed

# towers (cell towers?)
hist(PracticumData$towers)
PracticumDataTransformed$log_towers <- smoothed_log(PracticumData$towers)
hist(PracticumDataTransformed$log_towers) #still somewhat skewed

# Care Centers
hist(PracticumData$careCenters)
PracticumDataTransformed$log_careCenters <- smoothed_log(PracticumData$careCenters)
hist(PracticumDataTransformed$log_careCenters) #still pretty skewed

# Home Day Care
hist(PracticumData$homeDaycare)
PracticumDataTransformed$log_homeDaycare <- smoothed_log(PracticumData$homeDaycare)
hist(PracticumDataTransformed$log_homeDaycare) #still somewhat skewed

# com_elecrate
hist(PracticumData$com_elecrate)
PracticumDataTransformed$com_elecrate <- PracticumData$com_elecrate #no change

# ind_elecrate
hist(PracticumData$ind_elecrate)
PracticumDataTransformed$ind_elecrate <- PracticumData$ind_elecrate #no change

# com_elecrate
hist(PracticumData$res_elecrate)
PracticumDataTransformed$res_elecrate <- PracticumData$res_elecrate #no change

# farmers markets
hist(PracticumData$f_markets)
hist(smoothed_log(PracticumData$f_markets))
PracticumDataTransformed$log_f_markets <- smoothed_log(PracticumData$f_markets)
hist(PracticumDataTransformed$log_f_markets) #still pretty skewed

# walmart locations
hist(PracticumData$walmart_stores)
PracticumDataTransformed$walmart_stores <- PracticumData$walmart_stores #no change

# target_stores
hist(PracticumData$target_stores)
PracticumDataTransformed$target_stores <- PracticumData$target_stores #no change

# CVSstores
hist(PracticumData$CVSstores)
summary(PracticumData$CVSstores)
PracticumDataTransformed$CVSstores <- PracticumData$CVSstores #no change

# home_depot_count
hist(PracticumData$home_depot_count)
PracticumDataTransformed$home_depot_count <- PracticumData$home_depot_count #no change

# lowes_count	
hist(PracticumData$lowes_count)
PracticumDataTransformed$lowes_count <- PracticumData$lowes_count #no change

# whole_foods_count
hist(PracticumData$whole_foods_count)
PracticumDataTransformed$whole_foods_count <- PracticumData$whole_foods_count #no change

# bass pro locations
hist(PracticumData$basspro_count)
PracticumDataTransformed$basspro_count <- PracticumData$basspro_count #no change

# starbucks
hist(PracticumData$starbucks_count)
PracticumDataTransformed$log_starbucks <- smoothed_log(PracticumData$starbucks_count)
hist(PracticumDataTransformed$log_starbucks)

