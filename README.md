# High Frequency Project: Estimation of Stock-Bond Correlation using High Frequency Data with Application to a Risk-Targeted Risk Parity Portfolio

We study the empirical accuracy of a variety of estimators of asset price 
variation (realized measures) constructed from high frequency data and compare 
them using forecast comparison analysis which include the Superior Predictive 
Ability (SPA) of [Hansen (2005)](http://www-siepr.stanford.edu/workp/swp05003.pdf) and the Equal Predictive 
Ability (EPA) testing approach of [Diebold \& Mariano 
(1995)](https://amstat.tandfonline.com/doi/abs/10.1080/07350015.1995.10524599) and [West (1996)](https://www.jstor.org/stable/2171956?seq=1#metadata_info_tab_contents). 
We find the best estimator which have the lowest empirical loss under the 
"literature-preferred" proxy (a Realized Covariance sampled on a five minute 
frequency, RCov_{5min}) utilizing 
[Patton (2011)](https://www.sciencedirect.com/science/article/pii/S0304407610002551) data-based ranking method in conjunction with the best results obtained from the comparison analyses. This estimator is then used in a bivariate Risk-Targeted Equally-weighted Risk Contribution (RTERC) portfolio containing 
ETF's for U.S. stocks and bonds where it is compared to a benchmark portfolio. The conclusion is threefold. First, our results determine that no estimator could vastly outperform the Threshold Realized Covariance on a one minute sampling scheme (ThreshCov_{1min}) 
as noted from the main analysis together with the average empirical loss. Furthermore we find little evidence that any of the estimators significantly outperform the 
"literature-preferred"  RCov_{5min}, with the exception of ThreshCov_{1min} 
and ThreshCov_{5min} together with the Modulated Realized Covariance on a one second sampling scheme (that is, MRC_{1sec}). Second, we observe that non noise-robust estimators sampled at minute frequencies seems to provide much of the benefits of high frequency data without exposing the estimators to microstructure noise, and the empirical accuracy only slightly increases (on average) when considering noise-robust estimators on second frequencies. Finally, we find evidence that constructing the RTERC portfolio 
using the best performing realized measure, ThreshCov_{1min} (high frequency 
portfolio) yields better overall results in contrast to the "industry standard" 
being a portfolio constructed from a daily covariance estimator, RCov_{daily} 
(benchmark portfolio). The high frequency portfolio reduces the vol of vol and 
is closer to the risk-target while also reducing the likelihood of very 
negative returns. In conclusion the high frequency portfolio is much more 
stable against strong fluctuations in the correlation estimates contrary to the 
benchmark portfolio. 

## Code

The folder "Matlab datacleaner" contains a Matlab script capable of cleaning raw NYSE TAQ data using [Barndorff-Nielsen et al. (2009)](https://onlinelibrary.wiley.com/doi/10.1111/j.1368-423X.2008.00275.x) outputted as a .csv file.  

The dataCleanFunc.R contains functions neccesary to clean the .csv file outputted from the Matlab script in the same repository. It converts the .csv file into .xts objects with correctly specified timestamps. 

projectfunctions.R contains all of the (modified or original) functions used throughout the project. Some of the measures were inspired from the package [highfrequency](http://highfrequency.herokuapp.com/) but were modified for different purposes. 

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details

