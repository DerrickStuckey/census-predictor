## Predictor data normalization

# load data
Practicum_FinalVersion <- read.csv("~/Desktop/GW/Practicum/census-predictor/prepared_data/Practicum_FinalVersion.csv", stringsAsFactors=FALSE)

Practicum_Predictors <- subset(Practicum_FinalVersion, 
                               select=c(SS_recip, IRS_returns, rent_201501, homeprice, valuechange_5year, com_elecrate, ind_elecrate, res_elecrate, beds, gas_stations, fastfood,	towers,	care_centers,	home_daycare,	farmers_markets,	walmart,	target,	cvs,	home_depot,	lowes,	whole_foods,	basspro,	starbucks,
                                        beds_avg,  gas_stations_avg,	fastfood_avg,	towers_avg,	care_centers_avg,	home_daycare_avg,	farmers_markets_avg,	walmart_avg,	target_avg,	cvs_avg,	home_depot_avg,	lowes_avg,	whole_foods_avg,	basspro_avg,	starbucks_avg,	SS_recip_sum,	IRS_returns_sum,	rent_sum,	homeprice_sum,
                                        SS_recip_avg,  IRS_returns_avg,	rent_avg,	homeprice_avg))

Practicum_Predictor_Flags <- subset(Practicum_FinalVersion,
                          select=c(SS_imputed,IRS_imputed,rent_imputed,homeprice_imputed,valchange_imputed))

# normalize the numeric predictors
Practicum_Predictors_Normalized <- data.frame(scale(Practicum_Predictors))

# add back in the flags
Practicum_Predictors_Normalized <- cbind(Practicum_Predictors_Normalized, Practicum_Predictor_Flags)

#scale both latitude and longitude by the same amount so as not to distort
latlonsd <- (sd(Practicum_FinalVersion$latitude) + sd(Practicum_FinalVersion$longitude)) / 2
meanlat <- mean(Practicum_FinalVersion$latitude)
meanlon <- mean(Practicum_FinalVersion$longitude)
Practicum_Predictors_Normalized$latitude <- (Practicum_FinalVersion$latitude - meanlat) / latlonsd
Practicum_Predictors_Normalized$longitude <- (Practicum_FinalVersion$longitude - meanlon) / latlonsd

# add back in zip code for a key
Practicum_Predictors_Normalized$zipCode <- Practicum_FinalVersion$zipCode

#save as a csv
write.csv(Practicum_Predictors_Normalized, file="../prepared_data/Practicum_Predictors_Normalized.csv",
          row.names=FALSE,quote=FALSE)
