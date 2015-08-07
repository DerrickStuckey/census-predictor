## add percent_children variable

Practicum_Targets <- read.csv("../../prepared_data/Practicum_Targets.csv", stringsAsFactors=FALSE)

PracticumData_NoPR4 <- read.csv("~/Downloads/PracticumData_NoPR4.csv", stringsAsFactors=FALSE)

Children_Data <- subset(PracticumData_NoPR4, select=c(percchildren, zipCode, X2010pop, stateCode))

Children_Merged <- merge(Practicum_Targets, Children_Data,
                         by.x=c("zipCode","state_code"),
                         by.y=c("zipCode","stateCode"),
                         all.x=TRUE,all.y=FALSE)

# Children_Merged_NNA <- Children_Merged[!is.na(Children_Merged$percchildren),]

write.csv(Children_Merged, file="../../prepared_data/Practicum_Targets.csv",
          row.names=FALSE, quote=FALSE)