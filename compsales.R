library(dplyr)
zillow = read.csv("zillowcomps.csv")
redfin = read.csv("redfincomps.csv")
print(head(zillow))
print(head(redfin))
compsales = left_join(zillow, redfin, by="Address")
print(head(compsales))
compsales = compsales %>%
  mutate(Zestimate=Estimate.x, RedfinEstimate=Estimate.y, Sold=Sold.x, SoldR=Sold.y) %>%
  select(c('Address','Sold','BR','BA','Lot','YearBuilt','Zestimate','SoldR','SQFT','DateSold','RedfinEstimate','InWorksheet'))
print(head(compsales))
