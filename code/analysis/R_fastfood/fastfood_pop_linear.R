## Compare fast food locations and population by US zip code
## uses 2010 census population stats and 2007 fast food stats

# read in population data
pop <- read.csv("../../../prepared_data/population_by_zip.csv")

# read in fast food location data
ff <- read.csv("../../../raw_data/fastfoodmaps_locations_2007.csv")

# make zip code column names match
names(ff)[names(ff) == "Zip.Code"] <- "zipCode"

# obtain counts of restaurants per zip code
ff_counts <- aggregate(x=ff$Index, by=list("zipCode" = ff$zipCode), FUN=length)
names(ff_counts)[2] <- "ff_count"

# merge by zip code (left join)
merged_df <- merge(pop,ff_counts,by="zipCode",all.x=TRUE,all.y=FALSE)

# set all missing values for fast food count to 0
merged_df$ff_count[is.na(merged_df$ff_count)] <- 0

# build linear regression model
lm_fit <- lm(X2010pop ~ ff_count, data=merged_df)

summary(lm_fit)
