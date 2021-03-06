library(dplyr)
library(tidyr)
# Load Compustat data
RawCompustatData <- read.table("./Data/AllDataCompustat.csv", sep = ",", header = TRUE, quote ="")

# Load CRSP data for Beta / Returns
RawCrspReturnsBetaData <- read.table("./Data/AllDataReturnsBeta.csv", sep = ",", header = TRUE, quote ="")

# Load CRSP data for share price and number of shares outstanding
RawCrspPriceSharesData <- read.table("./Data/AllPriceSharesCRSP.csv", sep = ",", header = TRUE, quote ="")

# Load Fama French Benchmarks Data
FamaDataRaw <- read.table("./Data/FamaFactors.CSV", sep = ",", header = TRUE, quote ="")

# Load Linking Data
linkTable <- read.table("./Data/linkCrspCompustat.csv", sep = ",", header = TRUE, quote ="")
linkTable <- rename(linkTable, PERMNO = LPERMNO, CUSIP = cusip, GVKEY = gvkey)

# # ------------------------ FOR DIFFERENT YEARS... RUN BELOW# ------------------------ 
# SELECT YEAR FOR EACH
year <- 1989

compustatData <- subset(RawCompustatData, substr(RawCompustatData$POINTDATE, 0, 4) == year)
crspReturnsBetaData <- subset(RawCrspReturnsBetaData, substr(RawCrspReturnsBetaData$DATE, 0, 4) <= year)
crspPriceSharesData <- subset(RawCrspPriceSharesData, substr(RawCrspPriceSharesData$date, 0, 4) == year)
nextReturns <- subset(RawCrspReturnsBetaData, substr(RawCrspReturnsBetaData$DATE, 0,4) == (as.integer(year)+1))

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

# Match Compustat Data with link table using GVKEY, throwing out those that don't match - this gives us PERMNO
compustatData <- left_join(compustatData, linkTable, by = c("conm","tic","GVKEY"), by.y = "PERMNO", all.x = TRUE)

# Remove NAs and duplicate CUSIPS & GVKEYS
compustatData <- compustatData[!(duplicated(compustatData$CUSIP.x) | duplicated(compustatData$CUSIP.y)), ]
compustatData <- compustatData[!duplicated(compustatData$GVKEY), ]
compustatData <- na.omit(compustatData)

# ------------------------ CRSP RETURNS/BETA DATA -------------------------
# Normalize prep for CUSIP and Date, removing extra columns
crspReturnsBetaData <- rename(crspReturnsBetaData, Date = DATE)
# Remove unnecessary columns
crspReturnsBetaData <- select(crspReturnsBetaData, RET, TICKER, PERMNO, Date)
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

crspPriceSharesData <- crspPriceSharesData %>% group_by(PERMNO) %>% slice(which.max(Date))


# ------------------ FUNDAMENTALDATA - MERGE & REMOVE DATA THAT DOESN'T HAVE ALL REQUIREMENTS ACROSS DATASETS -------------------
# Match with CRSP Data using CUSIP
fundamentalMerge <- merge(compustatData, crspPriceSharesData, by = c("PERMNO"), all = FALSE)

# Remove row from fundamentalMerge if data not also in returns data
fundamentalMerge <- subset(fundamentalMerge, PERMNO %in% crspReturnsBetaData$PERMNO)

# Make capitalization column
fundamentalMerge <- mutate(fundamentalMerge, capital = fundamentalMerge$SHROUT * fundamentalMerge$PRC)

# Final check for no NAs
fundamentalMerge <- na.omit(fundamentalMerge)

# Remove broken CUIPS & other ID cols that are causing trouble in MATLAB
fundamentalMerge <- select(fundamentalMerge, -Date.y, -CUSIP.x, -CUSIP.y, -LIID, -LINKENDDT, -CUSIP)

fundamentalMerge <- fundamentalMerge[order(fundamentalMerge$TICKER),]
fundamentalMerge <- mutate(fundamentalMerge, Date = substr(fundamentalMerge$Date,0,6))
fundamentalMerge <- subset(fundamentalMerge, TICKER %in% crspReturnsBetaData$TICKER)
fundamentalMerge <- fundamentalMerge[!duplicated(fundamentalMerge$TICKER), ]
fundamentalMerge <- fundamentalMerge[!duplicated(fundamentalMerge$PERMNO), ]

# ---------------- FORMAT RETURNS DATA INTO COLUMNAR FORM WITH COLS OF SECURITIES AND ROWS OF HISTORICAL RETURNS -----------------
crspReturnsBetaData <- na.omit(crspReturnsBetaData)
crspReturnsBetaData <- subset(crspReturnsBetaData, PERMNO %in% fundamentalMerge$PERMNO)
crspReturnsBetaData <- subset(crspReturnsBetaData, TICKER %in% fundamentalMerge$TICKER)

# count distinct PERMNOs in Returns data to double check columns match rows
count(distinct(crspReturnsBetaData, PERMNO))

# transpose so that columns are equities and rows are returns
returnsOutput <- select(crspReturnsBetaData, TICKER, Date, RET) 
returnsOutput <- mutate(returnsOutput, RET = as.numeric(sub("%", "",RET,fixed=TRUE))/100)
returnsOutput <- na.omit(returnsOutput)

returnsOutput <- returnsOutput[order(returnsOutput$TICKER),]

returnsOutput <- pivot_wider(returnsOutput, names_from = TICKER, values_from = RET)
returnsOutput <- mutate(returnsOutput, Date = substr(returnsOutput$Date,0,6))

returnsOutput <- subset(returnsOutput, Date <= year)

returnsOutput <- returnsOutput[!duplicated(returnsOutput$Date), ]
returnsOutput <- returnsOutput[order(returnsOutput$Date),]
returnsOutput <- select(returnsOutput, -Date) 

# ------------------------ CHECK FAMA BENCHMARKS DATA AND NORMALIZE FOR RETURNS -------------------------
#FamaData # TODO: Make sure columns of Returns match rows of fundamentals
FamaData <- subset(FamaDataRaw, Date <= year*100)
FamaData <- FamaData[order(FamaData$Date),]
FamaData <- select(FamaData, SMB, HML, RF)

# ------------------------ REMOVE NAN COLUMNS -------------------------
emptycols <- colSums(is.na(returnsOutput)) > 250 #Tweak this number to ensure no rank deficiency error (with column of all zero returns in given time)
returnsOutput <- returnsOutput[!emptycols]
fundamentalMerge <- subset(fundamentalMerge, TICKER %in% colnames(returnsOutput))

# ------------------------ EXPORT AS CSV -------------------------
# Send fundamentalMerge data table to Matlab for regression
write.csv(fundamentalMerge, paste0("./Data/OrganizedData/","Fundamentals.csv"), row.names = FALSE)

# Send crspReturnsBetaData data table to Matlab for regression
write.csv(returnsOutput, paste0("./Data/OrganizedData/","Returns.csv"), row.names = FALSE)

# Send FamaData data table to Matlab for regression
write.csv(FamaData, paste0("./Data/OrganizedData/","FamaData.csv"), row.names = FALSE)

# Send next year's returns data table to Matlab for portfolio testing
write.csv(nextReturns, paste0("./Data/OrganizedData/","nextReturns.csv"), row.names = FALSE)

