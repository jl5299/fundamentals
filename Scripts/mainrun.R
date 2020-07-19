library(dplyr)
# Load Compustat data
RawCompustatData <- read.table("./Data/AllDataCompustat.csv", sep = ",", header = TRUE, quote ="")

# Load CRSP data for Beta / Returns
RawCrspReturnsBetaData <- read.table("./Data/AllDataReturnsBeta.csv", sep = ",", header = TRUE, quote ="")

# Load CRSP data for share price and number of shares outstanding
RawCrspPriceSharesData <- read.table("./Data/AllPriceSharesCRSP.csv", sep = ",", header = TRUE, quote ="")

# Load Linking Data
linkTable <- read.table("./Data/linkCrspCompustat.csv", sep = ",", header = TRUE, quote ="")
linkTable <- rename(linkTable, PERMNO = LPERMNO, CUSIP = cusip, GVKEY = gvkey)

# FOR DIFFERENT YEARS... RUN BELOW
# SELECT YEAR FOR EACH
year <- 1987

compustatData <- subset(RawCompustatData, substr(RawCompustatData$POINTDATE, 0, 4) == year)
crspReturnsBetaData <- subset(RawCrspReturnsBetaData, substr(RawCrspReturnsBetaData$DATE, 0, 4) <= year)
crspPriceSharesData <- subset(RawCrspPriceSharesData, substr(RawCrspPriceSharesData$date, 0, 4) == year)

# ------------------------ COMPUSTAT DATA -------------------------
# Remove Data Codes
compustatData <- select(compustatData, !contains("_dc"))
# Normalize prep for CUSIP and Date, removing extra columns
compustatData <- rename(compustatData, Date = POINTDATE, CUSIP = cusip)
# Remove all non EOY data points - throwing out dates that don't end with 1231
compustatData <- compustatData[ which(substr(compustatData$Date, 5, 8) == "1231"),]
# Remove all NAs
compustatData <- na.omit(compustatData)
# Remove all financial companies (SIC codes 60-69)
compustatData <- subset(compustatData, !(sic %in% 60:69))
# Remove all non NYSE, AMEX, NASDAQ
compustatData <- subset(compustatData, exchg %in% 1:3)
# Remove if negative total assets
compustatData <- subset(compustatData, ATQh > 0)


# Remove duplicate CUSIPS
compustatData <- compustatData[!duplicated(compustatData$CUSIP), ]
# Fix CUSIPS in Compustat Data
# compustatData <- mutate(compustatData, CUSIP = substr(CUSIP,0,8))

compustatDataTEMP1 <- left_join(compustatData, linkTable, by = "GVKEY", all = FALSE, copy = FALSE, keep = FALSE)
compustatDataTEMP <- left_join(compustatDataTEMP1, linkTable, by = "CUSIP.x", all = FALSE)
compustatDataTEMP <- na.omit(compustatDataTEMP)



# ------------------------ CRSP RETURNS/BETA DATA -------------------------
# Remove unnecessary columns
crspReturnsBetaData <- select(crspReturnsBetaData, RET, TICKER, PERMNO, DATE)
# Normalize prep for CUSIP and Date, removing extra columns
crspReturnsBetaData <- rename(crspReturnsBetaData, Date = DATE)
# Remove if missing data
crspReturnsBetaData <- subset(crspReturnsBetaData, !(is.na(crspReturnsBetaData$TICKER) | is.na(crspReturnsBetaData$Date) 
                                                    | crspReturnsBetaData$TICKER == "" | crspReturnsBetaData$Date == ""))


# ------------------------ CRSP PRICE/SHARES DATA -------------------------
# Normalize prep for CUSIP and Date, removing extra columns
crspPriceSharesData <- rename(crspPriceSharesData, Date = date)
crspPriceSharesData <- select(crspPriceSharesData, -RET, -SHRCLS)
# Remove if missing data & share price < 5
crspPriceSharesData <- subset(crspPriceSharesData, !(is.na(crspPriceSharesData$TICKER) | is.na(crspPriceSharesData$Date) 
                                                    | crspPriceSharesData$TICKER == "" | crspPriceSharesData$Date == ""
                                                    | crspPriceSharesData$PRC < 5 | is.na(crspPriceSharesData$SHROUT)))


# ------------------ FUNDAMENTALDATA - MERGE & REMOVE DATA THAT DOESN'T HAVE ALL REQUIREMENTS ACROSS DATASETS -------------------
# Match with CRSP Data using CUSIP
fundamentalMerge <- merge(crspPriceSharesData, compustatDataTEMP, by = c("PERMNO", "Date"), all = FALSE)

# Remove row from fundamentalMerge if data not also in returns data
fundamentalMerge <- subset(fundamentalMerge, TICKER %in% crspReturnsBetaData$TICKER)

# Make capitalization column
fundamentalMerge <- mutate(fundamentalMerge, capital = fundamentalMerge$SHROUT * fundamentalMerge$PRC)

# ---------------- FORMAT RETURNS DATA INTO COLUMNAR FORM WITH COLS OF SECURITIES AND ROWS OF HISTORICAL RETURNS -----------------



# ------------------------ EXPORT AS CSV -------------------------

# Send fundamentalMerge data table to Matlab for regression
write.csv(fundamentalMerge, paste0("./Data/OrganizedData/",year,"Fundamentals.csv"), row.names = FALSE)

# Send crspReturnsBetaData data table to Matlab for regression
write.csv(crspReturnsBetaData, paste0("./Data/OrganizedData/",year,"Returns.csv"), row.names = FALSE)
