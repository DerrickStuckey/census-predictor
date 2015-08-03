## Compute percentages for target variables

Practicum_FinalVersion <- read.csv("~/Desktop/GW/Practicum/census-predictor/prepared_data/Practicum_FinalVersion.csv", stringsAsFactors=FALSE)

# compute race percentages
# Practicum_FinalVersion$percwhite <- Practicum_FinalVersion$race_white / Practicum_FinalVersion$pop_2010
# Practicum_FinalVersion$percblack <- Practicum_FinalVersion$race_black / Practicum_FinalVersion$pop_2010
# Practicum_FinalVersion$percasian <- Practicum_FinalVersion$race_asian / Practicum_FinalVersion$pop_2010
# Practicum_FinalVersion$percmultiple <- Practicum_FinalVersion$race_multiple / Practicum_FinalVersion$pop_2010
# Practicum_FinalVersion$percother <- Practicum_FinalVersion$race_other / Practicum_FinalVersion$pop_2010
# Practicum_FinalVersion$perchawaiian.pacific <- Practicum_FinalVersion$race_hawaiian.pacific / Practicum_FinalVersion$pop_2010
# Practicum_FinalVersion$percamerican.indian <- Practicum_FinalVersion$race_american.indian / Practicum_FinalVersion$pop_2010

# compute degree percentages
# Practicum_FinalVersion$percbachelors <- Practicum_FinalVersion$bachelors_degree / Practicum_FinalVersion$pop_2010
# Practicum_FinalVersion$percgraddegree <- Practicum_FinalVersion$grad_degree / Practicum_FinalVersion$pop_2010

# compute gender percentages
Practicum_FinalVersion$perc_male <- Practicum_FinalVersion$male_total * 100 / Practicum_FinalVersion$pop_2010
Practicum_FinalVersion$perc_female<- Practicum_FinalVersion$female_total * 100 / Practicum_FinalVersion$pop_2010

# calculate age group percentages (both genders)
Practicum_FinalVersion$perc_under18 <- ((Practicum_FinalVersion$male_under.18 + 
                                           Practicum_FinalVersion$female_under.18) 
                                        * 100 / Practicum_FinalVersion$pop_2010)

Practicum_FinalVersion$perc_18_to_24 <- ((Practicum_FinalVersion$male_18.to.24 + 
                                           Practicum_FinalVersion$female_18.to.24) 
                                        * 100 / Practicum_FinalVersion$pop_2010)

Practicum_FinalVersion$perc_25_to_34 <- ((Practicum_FinalVersion$male_25.to.34 + 
                                            Practicum_FinalVersion$female_25.to.34) 
                                         * 100 / Practicum_FinalVersion$pop_2010)

Practicum_FinalVersion$perc_35_to_44 <- ((Practicum_FinalVersion$male_35.to.44 + 
                                            Practicum_FinalVersion$female_35.to.44) 
                                         * 100 / Practicum_FinalVersion$pop_2010)

Practicum_FinalVersion$perc_45_to_54 <- ((Practicum_FinalVersion$male_45.to.54 + 
                                            Practicum_FinalVersion$male_45.to.54) 
                                         * 100 / Practicum_FinalVersion$pop_2010)

Practicum_FinalVersion$perc_55_to_64 <- ((Practicum_FinalVersion$male_55.to.64 + 
                                            Practicum_FinalVersion$male_55.to.64) 
                                         * 100 / Practicum_FinalVersion$pop_2010)

Practicum_FinalVersion$perc_65_and_over <- ((Practicum_FinalVersion$male_65.and.over + 
                                            Practicum_FinalVersion$male_65.and.over) 
                                         * 100 / Practicum_FinalVersion$pop_2010)

# select only target variables
Practicum_Target_Vars <- subset(Practicum_FinalVersion, 
                                select=-c(SS_recip, IRS_returns, rent_201501, homeprice, valuechange_5year, com_elecrate, ind_elecrate, res_elecrate, beds, gas_stations, fastfood,  towers,	care_centers,	home_daycare,	farmers_markets,	walmart,	target,	cvs,	home_depot,	lowes,	whole_foods,	basspro,	starbucks,
                                         beds_avg,  gas_stations_avg,	fastfood_avg,	towers_avg,	care_centers_avg,	home_daycare_avg,	farmers_markets_avg,	walmart_avg,	target_avg,	cvs_avg,	home_depot_avg,	lowes_avg,	whole_foods_avg,	basspro_avg,	starbucks_avg,	SS_recip_sum,	IRS_returns_sum,	rent_sum,	homeprice_sum,
                                         SS_recip_avg,  IRS_returns_avg,	rent_avg,	homeprice_avg,SS_imputed,IRS_imputed,rent_imputed,homeprice_imputed,valchange_imputed,latitude,longitude,
                                         beds_sum, gas_stations_sum,  fastfood_sum,	towers_sum,	care_centers_sum,	home_daycare_sum,	farmers_markets_sum,	walmart_sum,	target_sum,	cvs_sum,	home_depot_sum,	lowes_sum,	whole_foods_sum,	basspro_sum,	starbucks_sum))

# convert imputed target vars back to NA
Practicum_Target_Vars$med_income[Practicum_Target_Vars$med_income_imputed == 1] <- NA
Practicum_Target_Vars <- subset(Practicum_Target_Vars, 
                                select=-c(bachelors_degree_avg,bachelors_degree_sum,
                                          grad_degree_avg,grad_degree_avg,
                                          med_income_imputed,bachelors_imputed,
                                          grad_imputed))

write.csv(Practicum_Target_Vars, file="../prepared_data/Practicum_Targets.csv",
          row.names=FALSE,quote=FALSE)
