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

# Fix CUSIPS in Compustat Data
filteredData = mutate(filteredData, CUSIP = substr(CUSIP,0,8))

# Match with CRSP Data using CUSIP
crspMerge <- merge(crspReturnsBetaData, crspPriceSharesData, by = c("TICKER", "Date","PERMNO"), all = FALSE)

finalMerge <- merge(crspMerge, filteredData, by = c("CUSIP", "Date"), all = FALSE)

# Send finalMerged data table to Matlab for regression
write.csv(finalMerge, "./Data/OrganizedData/1987Data.csv", row.names = FALSE)

