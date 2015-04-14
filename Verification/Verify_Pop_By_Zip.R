## Compare two datasets of population count by zip code

population_by_zip <- read.csv("~/Desktop/GW/Practicum/census-predictor/prepared_data/population_by_zip.csv", stringsAsFactors=FALSE)
pop_zip_derrick <- read.csv("~/Desktop/GW/Practicum/census-predictor/prepared_data/pop_zip_derrick.csv", stringsAsFactors=FALSE)

#make names easier to use
names(pop_zip_derrick) <- c("pop","stateCode","zipCode")
names(population_by_zip)[2] <- "pop"

#first verify both datasets are the same size
nrow(population_by_zip)
nrow(pop_zip_derrick)

#ensure each zip code is numeric for sorting
population_by_zip$zipCode <- as.numeric(population_by_zip$zipCode)
pop_zip_derrick$zipCode <- as.numeric(pop_zip_derrick$zipCode)

#sort each by zip code
population_by_zip <- population_by_zip[order(zip),]
pop_zip_derrick <- pop_zip_derrick[order(zip),]

#test whether any zip codes don't match up
zip_diffs <- population_by_zip$zipCode != pop_zip_derrick$zipCode
summary(zip_diffs)

#test whether any population entries don't match
pop_diffs <- population_by_zip$pop != pop_zip_derrick$pop
summary(pop_diffs)

