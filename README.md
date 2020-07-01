---
title: "Portfolio Optimization using Crude Fundamental Analysis"
author: "Justin Law"
---
# Fundamentals
Research project with Professor Benjamin Gillen

Resources:
Agnostic Fundamental Analysis Works


# Study Design
wrds data : https://wrds-www.wharton.upenn.edu/
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


crsp data : http://crsp.org/files/ccm_data_guide_0.pdf
