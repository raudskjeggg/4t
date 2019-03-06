library(dplyr)
zillow = read.csv("zillowcomps.csv")
redfin = read.csv("redfincomps.csv")
compsales = left_join(zillow, redfin, by="Address")
compsales = compsales %>%
  mutate(Zestimate=Estimate.x, RedfinEstimate=Estimate.y, Sold=Sold.x, SoldR=Sold.y) %>%
  select(c('Address','Sold','BR','BA','Lot','YearBuilt','Zestimate','SoldR','SQFT','DateSold','RedfinEstimate','InWorksheet'))
for (colname in c('Sold', 'SoldR', 'SQFT', 'Lot', 'Zestimate', 'RedfinEstimate', 'BR', 'BA', 'YearBuilt')) {
  compsales[[colname]] <- as.numeric(gsub('[^0-9]', '', compsales[[colname]]))
}
print(head(compsales))
compsales$ZDev = abs(compsales$Zestimate-compsales$Sold)
compsales$RFDev = abs(compsales$RedfinEstimate-compsales$Sold)
print(paste("Z miss:", mean(compsales$ZDev, na.rm = TRUE)))
print(paste("RedFin miss:", mean(compsales$RFDev, na.rm = TRUE)))
