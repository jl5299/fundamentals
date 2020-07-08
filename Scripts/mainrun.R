library(dplyr)
# Load data in
compustatData <- read.table("./Data/1987DataCompustat.csv", sep = ",", header = TRUE, quote ="")
head(compustatData)

# Check Data
summary(compustatData)
str(compustatData)

# Remove Data Codes
tidyData <- select(compustatData, !contains("_dc"))

# Remove all NAs
removeNA <- na.omit(tidyData)

# Remove all financial companies (SIC codes 60-69)
filteredData = subset(removeNA, !(sic %in% 60:69))

# Remove all non NYSE, AMEX, NASDAQ
filteredData = subset(filteredData, exchg %in% 1:3)

# Load CRSP data for Beta / Returns
crspReturnsBetaData <- read.table("./Data/1987ReturnsBetaCRSP.csv", sep = ",", header = TRUE, quote ="")

# Load CRSP data for share price and number of shares outstanding
crspPriceSharesData <- read.table("./Data/1987PriceSharesCRSP.csv", sep = ",", header = TRUE, quote ="")

# Normalize prep for CUSIP and Date
filteredData = mutate(filteredData, Date = POINTDATE, CUSIP = cusip)
crspReturnsBetaData = mutate(crspReturnsBetaData, Date = DATE)
crspPriceSharesData = mutate(crspPriceSharesData, Date = date)

# Match with CRSP Data using CUSIP
crspMerge <- merge(crspPriceSharesData, crspReturnsBetaData, by.x = "TICKER", by.y = "Date", all = TRUE)
finalMerge <- merge(filteredData, crspMerge, by.x = "CUSIP", by.y = "Date", all = TRUE)

# Send finalMerged data table to Matlab for regression






