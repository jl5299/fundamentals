# Checkpoint 4: August 21st

**Implement Mean variance Optimizer using captured residuals from Grinblatt paper theory and our variance covariance matrix**

..................................................................................

This part of the project was the simplest to execute because of the work we put in previously to organize our data in the correct matrix formats. There were no extra data wrangling steps required and as such, this component of my overall research project can be seen as an extension of parts 1-3.

Analysis of this part of the project requires a close examination of the Matlab script -- part 3. In about 10 elegant lines of code, Matlab determines the posterior mean returns from the factor model through our part 3 construction of benchmark risk premiums in the variance-covarinace matrix, calculates the posterior covariance matrix in relation to the factor models to produce Posterior betas, and allows us to construct a portfolio of optimal assets given their fundamental factors.