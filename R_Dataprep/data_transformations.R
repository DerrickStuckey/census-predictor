## Data transformations

PracticumData <- read.csv("~/Downloads/PracticumData.csv", stringsAsFactors=FALSE)

# replace NA's w/ appropriate values
PracticumData$Beds[is.na(PracticumData$Beds)] <- 0
PracticumData$count_fastfood[is.na(PracticumData$count_fastfood)] <- 0
# Social Security recipients? (only a few NA's)

# 2010 population
hist(PracticumData$X2010pop)
logpop = log(PracticumData$X2010pop)
hist(logpop)

# percent white
hist(PracticumData$percwhite)
xformed_white <- 1 - log(1 - PracticumData$percwhite)
hist(xformed_white)

# percent black
hist(PracticumData$percblack)
log_percblack <- log(PracticumData$percblack)
hist(log_percblack)

# percent Asian
hist(PracticumData$percasian)
log_percasian <- log(PracticumData$percasian)
hist(log_percasian)

# 2010 social security recipients
hist(PracticumData$X2010.SSrecip)
log_ssrecip <- log(PracticumData$X2010.SSrecip)
hist(log_ssrecip)

# IRS_rtrns
hist(PracticumData$IRS_rtrns)
log_irsreturns <- log(PracticumData$IRS_rtrns)
hist(log_irsreturns)

# Care Centers
hist(PracticumData$careCenters)
log_careCenters <- log(PracticumData$careCenters)
hist(log_careCenters)

# Fast Food counts
hist(PracticumData$count_fastfood)
log_fastfood <- log(PracticumData$count_fastfood)
hist(log_fastfood)

# Hospital Beds
hist(PracticumData$Beds)
log_hosp_beds <- log(PracticumData$Beds)
hist(log_hosp_beds)

# towers (cell towers?)
hist(PracticumData$towers)
log_towers <- log(PracticumData$towers)
hist(log_towers)

# gas stations
hist(PracticumData$gasStations)
log_gas_stations <- log(PracticumData$gasStations)
hist(log_gas_stations)


