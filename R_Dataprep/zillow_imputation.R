## Impute missing Zillow Data

library(FNN)

source("./census_utils.R")

# load data
PracticumDataWithLocs <- read.csv("../prepared_data/PracticumDataWithLocs.csv", stringsAsFactors=FALSE)

###
### Impute rent_201501 variable
###

usable_data <- PracticumDataWithLocs

# throw out data w/ no lat/lon values
usable_data <- usable_data[!is.na(usable_data$latitude),]

# throw out data w/ no Zillow rent data
data_with_rent <- usable_data[!is.na(usable_data$rent_201501),]
data_without_rent <- usable_data[is.na(usable_data$rent_201501),]

# select only lat/lon vars
ziploc_only_withrent <- subset(data_with_rent,select=c(latitude,longitude))
ziploc_only_withoutrent <- subset(data_without_rent,select=c(latitude,longitude))

# obtain lat/lon knn validation predictions for percent white
knn_rent_loc <- knn.reg(train=ziploc_only_withrent,test=ziploc_only_withoutrent,
                         y=data_with_rent$rent_201501,k=4)
summary(knn_rent_loc$pred)

# impute the rent and set a flag
data_without_rent$rent_201501 <- knn_rent_loc$pred
data_without_rent$rent_imputed <- 1
data_with_rent$rent_imputed <- 0

#merge the data with, without rent
full_rent_data <- rbind(data_with_rent, data_without_rent)

###
### impute homeprice_201501
###

usable_data <- full_rent_data

# throw out data w/ no Zillow homeprice data
data_with_price <- usable_data[!is.na(usable_data$homeprice_201501),]
data_without_price <- usable_data[is.na(usable_data$homeprice_201501),]

# select only lat/lon vars
ziploc_only_withprice <- subset(data_with_price,select=c(latitude,longitude))
ziploc_only_withoutprice <- subset(data_without_price,select=c(latitude,longitude))

# obtain lat/lon knn validation predictions for percent white
knn_price_loc <- knn.reg(train=ziploc_only_withprice,test=ziploc_only_withoutprice,
                        y=data_with_price$homeprice_201501,k=4)
summary(knn_price_loc$pred)

# impute the price and set a flag
data_without_price$homeprice_201501 <- knn_price_loc$pred
data_without_price$homeprice_imputed <- 1
data_with_price$homeprice_imputed <- 0

#merge the data with, without price
full_rent_price_data <- rbind(data_with_price, data_without_price)

###
### impute valuechange_5year
###

usable_data <- full_rent_price_data

# throw out data w/ no Zillow homevalchange data
data_with_valchange <- usable_data[!is.na(usable_data$valuechange_5year),]
data_without_valchange <- usable_data[is.na(usable_data$valuechange_5year),]

# select only lat/lon vars
ziploc_only_withvalchange <- subset(data_with_valchange,select=c(latitude,longitude))
ziploc_only_withoutvalchange <- subset(data_without_valchange,select=c(latitude,longitude))

# obtain lat/lon knn validation predictions for percent white
knn_valchange_loc <- knn.reg(train=ziploc_only_withvalchange,test=ziploc_only_withoutvalchange,
                         y=data_with_valchange$valuechange_5year,k=4)
summary(knn_valchange_loc$pred)

# impute the valchange and set a flag
data_without_valchange$valuechange_5year <- knn_valchange_loc$pred
data_without_valchange$valchange_imputed <- 1
data_with_valchange$valchange_imputed <- 0

#merge the data with, without valchange
full_imputed_data <- rbind(data_with_valchange, data_without_valchange)

# only save imputed values and flags
full_imputed_data <- subset(full_imputed_data, 
                            select=c(zipCode,rent_201501,rent_imputed,
                                     homeprice_201501,homeprice_imputed,
                                     valuechange_5year,valchange_imputed))

write.csv(full_imputed_data, file="../prepared_data/zillow_imputed.csv",
          row.names=FALSE, quote=FALSE)

# # impute rent for data missing lat/lon
# rentlm <- lm(rent_201501 ~ com_elecrate + ind_elecrate + res_elecrate + 
#                gasStations + count_fastfood + towers + 
#                careCenters + homeDaycare + f_markets + walmart_stores + target_stores +
#              CVSstores + home_depot_count + lowes_count + whole_foods_count + 
#                basspro_count + starbucks_count, data=data_with_rent)

# write.csv(data_without_lat$zipCode, file="../raw_data/missing_loc_zips.csv",row.names=FALSE)

