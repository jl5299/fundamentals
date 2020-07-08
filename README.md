---
Title: "Portfolio Optimization using Crude Fundamental Analysis"
Author: "Justin Law"
---
# Fundamentals
Research project with Professor Benjamin Gillen

Resources:
Agnostic Fundamental Analysis Works


# Study Design
**wrds data : https://wrds-www.wharton.upenn.edu/**

**compustat data:**
Saved Query -- "Compustat - AnnualData" - Compustat Point in Time Complete History - US

Get Data ->
- 1 year
- GVKEY
- Active Companies Only
- Number of quarters back to include = 0
- Search the entire database
- Extra varaibles and parameters selected: 
  -   H  ACOQ ACTQ AOQ APQ ATQ CEQQ CHEQ DLTTQ DOQ DVPQ DVQ IBADJQ IBCOMQ IBQ ICAPTQ LCOQ LCTQ LOQ LTQ NIQ NOPIQ PIQ PPENTQ PSTKQ PSTKRQ SALEQ SEQQ TEQQ TXTQ XIDOQ 
- csv
- default order

310 return months (Friday Feb 27, march 1987 - Friday Nov 30, december 2012)

Be in CRSP’s monthly stock file as the only common equity share class of a U.S. Corporation (10 and 11)
Listed in NYSE, AMEX, or Nasdaq-nms (exchange codes 1-3)
Share price > 5, positive number of shares outstanding
Posses Standard Industry Classification (SIC) not in financial services (codes 60-69)
Market cap = Number of shares outstanding times its price per share
Sometimes adjustments are made to account for the number of trade-able (free-float) shares


**crsp data:**
Saved Query -- "Shares outstanding, price, return" - CRSP Monthly Stock
Saved Query -- "Returns, Beta" - CRSP Beta Suite by WRDS (Beta)

- Ticker Symbol
- CUSIP
- Price close monthly
- Monthly total returnh

Share Price, Number of Shares outstanding, Monthly stock return, and annual market beta for all stocks listed in NYSE, AMEX, and NASDAQ with share price > $5

1) Share Price / Number of shares outstanding
2) Returns / Beta

**fama french data:** 
Industry classification, portfolios - 38 Industry Portfolios: http://mba.tuck.dartmouth.edu/pages/faculty/ken.french/data_library.html#BookEquity
Industry sic keys:
http://mba.tuck.dartmouth.edu/pages/faculty/ken.french/Data_Library/det_38_ind_port.html
To add:
Mkt_RF, SMB, HML, Mom, ST-Rev, LT_Rev, CMA, RMW

**SUE - quarterly unexpected earnings suprised based on rolling seasonal random walk model (Livnat et al. p185)**


.............................................................................................
# MATLAB
Resource - Pseudocode from Professor Gillen

.............................................................................................

