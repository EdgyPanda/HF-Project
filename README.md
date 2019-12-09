# High Frequency Project: Estimation of Stock-Bond Correlation using High Frequency Data with Application to a Risk-Targeted Risk Parity Portfolio

We estimate the Stock-Bond correlation using high frequency data and apply it to a Risk-Targeted Risk Parity portfolio. An extensive analysis has been made in order to provide the most accurate realized measure in our given set of realized estimators. 

## Code

The folder "Matlab datacleaner" contains a Matlab script capable of cleaning raw NYSE TAQ data using [Barndorff-nielsen et al (2009)](https://onlinelibrary.wiley.com/doi/10.1111/j.1368-423X.2008.00275.x) outputted as a .csv file.  

The dataCleanFunc.R contains functions neccesary to clean the .csv file outputted from the Matlab script in the same repository. It converts the .csv file into .xts objects with correctly specified timestamps. 

projectfunctions.R contains all of the (modified or original) functions used throughout the project. Some of the measures were inspired from the package [highfrequency](http://highfrequency.herokuapp.com/) but were modified for different purposes. 

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details

