setwd(".../Documents/GWU/practicum/FinalData")
data <- read.csv("CorrelationData.csv")

#correlations between variables
library(corrplot)
m=cor(data,use="pairwise.complete.obs")
corrplot(m, method="square")
