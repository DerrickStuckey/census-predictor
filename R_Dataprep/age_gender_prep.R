## Prepare Age/Gender data

pop_age_gender_zip <- read.csv("../raw_data/pop_age_gender_zip.csv", stringsAsFactors=FALSE)

## compute Female total population
pop_age_gender_zip$Female_Total <- pop_age_gender_zip$Total_Population - pop_age_gender_zip$Male_Total

## compute total for various age groups
pop_age_gender_zip$X0_to_19 <- pop_age_gender_zip$Male.....Under.5.years + pop_age_gender_zip$Female.....Under.5.years + 
  pop_age_gender_zip$Male.....5.to.9.years + pop_age_gender_zip$Female.....5.to.9.years + 
  pop_age_gender_zip$Male.....10.to.14.years + pop_age_gender_zip$Female.....10.to.14.years + 
  pop_age_gender_zip$Male.....15.to.17.years + pop_age_gender_zip$Female.....15.to.17.years +
  pop_age_gender_zip$Male.....18.and.19.years + pop_age_gender_zip$Female.....18.and.19.years

pop_age_gender_zip$X20_to_39 <- pop_age_gender_zip$Male.....20.years + pop_age_gender_zip$Female.....20.years + 
  pop_age_gender_zip$Male.....21.years + pop_age_gender_zip$Female.....21.years + 
  pop_age_gender_zip$Male.....22.to.24.years + pop_age_gender_zip$Female.....22.to.24.years +
  pop_age_gender_zip$Male.....25.to.29.years + pop_age_gender_zip$Female.....25.to.29.years + 
  pop_age_gender_zip$Male.....30.to.34.years + pop_age_gender_zip$Female.....30.to.34.years +
  pop_age_gender_zip$Male.....35.to.39.years + pop_age_gender_zip$Female.....35.to.39.years

pop_age_gender_zip$X40_to_59 <- pop_age_gender_zip$Male.....40.to.44.years + pop_age_gender_zip$Female.....40.to.44.years + 
  pop_age_gender_zip$Male.....45.to.49.years + pop_age_gender_zip$Female.....45.to.49.years +
  pop_age_gender_zip$Male.....50.to.54.years + pop_age_gender_zip$Female.....50.to.54.years + 
  pop_age_gender_zip$Male.....55.to.59.years + pop_age_gender_zip$Female.....55.to.59.years

pop_age_gender_zip$X60_plus <- pop_age_gender_zip$Total_Population - pop_age_gender_zip$X0_to_19 -
  pop_age_gender_zip$X20_to_39 - pop_age_gender_zip$X40_to_59

pop_age_gender_clean <- data.frame("ZipCode"=pop_age_gender_zip$zip.code.tabulation.area,
                                   "Total_Population"=pop_age_gender_zip$Total_Population,
                                   "Male_Total"=pop_age_gender_zip$Male_Total,
                                   "Female_Total"=pop_age_gender_zip$Female_Total,
                                   "X0_to_19"=pop_age_gender_zip$X0_to_19,
                                   "X20_to_39"=pop_age_gender_zip$X20_to_39,
                                   "X40_to_59"=pop_age_gender_zip$X40_to_59,
                                   "X60_plus"=pop_age_gender_zip$X60_plus)

write.csv(pop_age_gender_clean, file="../prepared_data/pop_age_gender_zip_clean.csv", row.names=FALSE, quote=FALSE)




