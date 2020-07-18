library(dplyr)
year <- 1987
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


# Remove if missing data
crspReturnsBetaData = subset(crspReturnsBetaData, !(is.na(crspReturnsBetaData$TICKER) | is.na(crspReturnsBetaData$DATE) 
                                             | crspReturnsBetaData$TICKER == "" | crspReturnsBetaData$DATE == ""))

# Remove if missing data & share price < 5
crspPriceSharesData = subset(crspPriceSharesData, !(is.na(crspPriceSharesData$TICKER) | is.na(crspPriceSharesData$date) 
                                             | crspPriceSharesData$TICKER == "" | crspPriceSharesData$date == ""
                                             | crspPriceSharesData$PRC < 5 | is.na(crspPriceSharesData$SHROUT)))

# Normalize prep for CUSIP and Date, removing extra columns
filteredData = rename(filteredData, Date = POINTDATE, CUSIP = cusip)
crspReturnsBetaData = rename(crspReturnsBetaData, Date = DATE)
crspPriceSharesData = rename(crspPriceSharesData, Date = date)
crspPriceSharesData = select(crspPriceSharesData, -RET)

# Remove all non EOY data points - throwing out dates that don't end with 1231
filteredData = filteredData[ which(substr(filteredData$Date, 5, 8) == "1231"),]

# Fix CUSIPS in Compustat Data
filteredData = mutate(filteredData, CUSIP = substr(CUSIP,0,8))

# Remove duplicate CUSIPS
filteredData = filteredData[!duplicated(filteredData$CUSIP), ]

# Match with CRSP Data using CUSIP
#crspMerge <- merge(crspReturnsBetaData, crspPriceSharesData, by = c("TICKER", "Date","PERMNO"), all = FALSE)
# REWRITTEN SO PRICE SHARES GO WITH FILTEREDDATA AND RETURNS IS ALONE IN COLUMNAR FORM - RE-DO RETURNS QUERY
fundamentalMerge <- merge(crspPriceSharesData, filteredData, by = c("CUSIP", "Date"), all = FALSE)

# Remove row from fundamentalMerge if data not also in returns data
fundamentalMerge = subset(fundamentalMerge, TICKER %in% crspReturnsBetaData$TICKER)

# Make capitalization column
fundamentalMerge = mutate(fundamentalMerge, capital = fundamentalMerge$SHROUT * fundamentalMerge$PRC)

# Send fundamentalMerge data table to Matlab for regression
write.csv(fundamentalMerge, "./Data/OrganizedData/1987Fundamentals.csv", row.names = FALSE)

# Send crspReturnsBetaData data table to Matlab for regression
write.csv(crspReturnsBetaData, "./Data/OrganizedData/1987Returns.csv", row.names = FALSE)