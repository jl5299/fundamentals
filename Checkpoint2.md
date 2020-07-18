# Checkpoint 2: August 3rd, 1 week

**Transfer data to Matlab, code up regression – regressing market cap on fundamental characteristics and capture residuals**

..................................................................................

This part was a lot more fun to complete because I had the base knowledge necessary to execute basic tasks in MATLAB and R by this point -- the MATLAB component was slightly more challenging because I didn't take my coursera classes in this language, but Professor Gillen's guidance really helped. Also, seeing that MATLAB is far more concise of a language and is only used for the analysis components, I simply referred to google for syntactic errors and fixes.

Transferring this data to MATLAB was quite easy as I simply used the same write.csv package -- the reciprocal of how I read in data -- to export my final merged, cleaned, and normalized dataset into a CSV. I found other ways to link MATLAB and R, but for the purpose of this project, I decided to go with exporting to CSV for its simplicity.

Coding up the regression itself was quite challenging because 1) I didn't know the MATLAB syntax and 2)I didn't know how to do a multi-regression. Professor Gillen's boiler plate code helped a lot and a few extra sessions allowed me to confirm that I had the right data and complete the correct and accurate analysis required.

My first attempt at coding the regression revealed a lot of issues with my underlying data normalization. My lack of understanding of the statistical theory behind the regression proved challenging here as I had to re-normalize my data based on fundamental factors and returns -- separating the two from my previous approach which combined them in one table. Upon fixing this issue, my regression still showed wildly incorrect probabilitys for log residuals, which should be the percentage difference from ideal market capitalization. This highlighted an issue in market capitalization calculations, which I had left unlogged.

I've finally checked and confirmed all my work up to this point, and am confident I will be able to push onwards accurately. Although I have distinct checkpoints for various parts of the project, I now expect, as I should have with all coding projects, a lot of overlap between the sections as I debug small issues in my code.