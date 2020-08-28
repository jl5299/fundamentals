# Checkpoint 5: August 28th

**Back-test optimized portfolio to determine viability**

..................................................................................
This component of the project is an extension of part 4 in that portfolio optimization backtesting results from part 4's portfolio construction. From the optimized portfolios from each year's of analysis starting in 1987 and endig 2017, we show through backtesting the feasability of agnostic fundamental analysis in constructing portfolios to exploit the reversion of mispriced assets. In particular, this backtesting selects the most extreme quartiles of assets in expected overperformance and underperformance to allow for more targeted reversion alpha-taking.

Through similar tools as other backtesting platforms such as Quantopian, we are able to analyze the performance of our portfolio from a holistic standpoint. In particular, the key performance variables that we care about are alpha, beta, sharpe, and maximum drawdown.

I decided to complete this component manually, tracking returns data of the next year for our selected top and bottom quartile assets. This allowed us to stay true to our crude approach. Ultimately, we discovered that this method of portfolio optimization doesn't provide outperformance. However, based on the work I've done up until now and the successes in finding residuals to represent mispricing estimated market caps, I hope that a more refined method of portfolio asset weighting -- that is still simple -- will show outperformance in our selected portfolio. For now, I will submit this project to CMC having done analysis up to this point. However, I look forward to continuing this research project with Professor Gillen to refine our portfolio optimization.