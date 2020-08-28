---
Title: "Portfolio Optimization using Agnostic Fundamental Analysis"
Author: "Justin Law"
Version: "1.0.0"
---
# Fundamentals
Research project with Professor Benjamin Gillen

Resources:
Agnostic Fundamental Analysis Works:
https://papers.ssrn.com/sol3/papers.cfm?abstract_id=2802478

# Study Design
**Main Data Source: wrds data** 
https://wrds-www.wharton.upenn.edu/

**Data Requirements:**
- 1 year
- GVKEY
- Active Companies Only
- Number of quarters back to include = 0
- Search the entire database
- Extra varaibles and parameters selected: 
  -   H  ACOQ ACTQ AOQ APQ ATQ CEQQ CHEQ DLTTQ DOQ DVPQ DVQ IBADJQ IBCOMQ IBQ ICAPTQ LCOQ LCTQ LOQ LTQ NIQ NOPIQ PIQ PPENTQ PSTKQ PSTKRQ SALEQ SEQQ TEQQ TXTQ XIDOQ 
- csv
- default order

**Fundamental Data Requirements:**
- CRSP’s monthly stock file as the only common equity share class of a U.S. Corporation (10 and 11)
- Listed in NYSE, AMEX, or Nasdaq-nms (exchange codes 1-3)
- Share price > 5
- Positive number of shares outstanding
- Posses Standard Industry Classification (SIC) not in financial services (codes 60-69)
- Market cap = Number of shares outstanding times its price per share
- Sometimes adjustments are made to account for the number of trade-able (free-float) shares

**Bartram/Grinblatt** - 310 return months (Friday Feb 27, march 1987 - Friday Nov 30, december 2012)
**Gillen/Law** - 360 return months 1987 - 2017

**CRSP DATA QUERIES AND SPECIFICATIONS**
**CRSP Monthly Price Data:** "Shares outstanding, price, return" - CRSP Monthly Stock
- Share Price
- Number of shares outstanding
**CRSP Returns Data:** "Returns, Beta" - CRSP Beta Suite by WRDS (Beta)
- Ticker Symbol
- CUSIP
- Price close monthly
- Monthly total return
- Annual market beta 
- All stocks listed in NYSE, AMEX, and NASDAQ
- Share price > $5
**Compustat Fundamental Accounting Factors Data:** "Compustat - AnnualData" - Compustat Point in Time Complete History - US

The data we had access to didn't specify the share classes, differing in procedure from Bartram Grinblatt -- they took only common euqity share classes of US corporations (10 and 11). Ignoring this specification should be alright - majority of stocks that are listed in NYSE, NASDAQ, and AMEX should provide the same results.

**Fama French Data:** http://mba.tuck.dartmouth.edu/pages/faculty/ken.french/data_library.html#BookEquity
**To add:** Mkt_RF, SMB, HML, Mom, ST-Rev, LT_Rev, CMA, RMW
**Industry classification, portfolios:** 38 Industry Portfolios: http://mba.tuck.dartmouth.edu/pages/faculty/ken.french/data_library.html#BookEquity
**Industry sic keys: ** http://mba.tuck.dartmouth.edu/pages/faculty/ken.french/Data_Library/det_38_ind_port.html
**SUE:** quarterly unexpected earnings suprised based on rolling seasonal random walk model (Livnat et al. p185)

# MATLAB
Resource - Pseudocode from Professor Gillen
