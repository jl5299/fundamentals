library(dplyr)
# Load data in
fileData <- read.table("./Data/1987Data.csv", sep = ",", header = TRUE, quote ="")
head(fileData)

# Check Data
summary(fileData)
str(fileData)

# Remove Data Codes
tidyData <- select(fileData, !contains("_dc"))

# Remove all NAs
removeNA <- na.omit(tidyData)

filteredData <- filter(removeNA, SIC )