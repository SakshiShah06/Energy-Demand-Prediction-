# Energy Demand Prediction
Predicting residential energy demand from house characteristics and weather patterns using linear regression and Bayesian modeling
## Overview
This project predicts hourly residential energy consumption across South Carolina 
counties by combining house-level characteristics with local weather data. It covers the full data science 
pipeline from raw data extraction to predictive modeling and interactive 
visualization.

## Data & Methods
We worked with a large-scale housing dataset containing thousands of residential 
buildings across multiple South Carolina counties. Since each house required its 
own energy file, we performed web scraping to programmatically fetch and link 
each building's hourly energy records with its static house profile and county-level 
weather data. All data was stored and processed in Parquet format using the Arrow 
library in R.

Exploratory analysis examined how energy usage varies by square footage, number 
of bedrooms, number of occupants, heating and cooling setpoints, outdoor 
temperature, humidity, time of day, and month of year — visualized through 
boxplots, treemaps, scatter plots, and distribution charts.

## Modeling
We built and compared three regression models:
- **Model 1:** Standard linear regression on raw energy consumption
- **Model 2:** Linear regression on log-transformed energy consumption
- **Model 3:** Log-transformed linear regression excluding county as a predictor
- **Model 4:** Bayesian regression using Stan with hierarchical priors for month 
  and time-of-day effects

Models were evaluated on a held-out test set using Mean Absolute Error (MAE) 
and Root Mean Squared Error (RMSE). The log-transformed model outperformed the 
standard linear model due to the right-skewed distribution of energy consumption.

## Shiny Dashboard
An interactive Shiny app allows users to explore energy consumption trends across 
different house types, counties, and weather conditions without writing any code.

## Files
- `energy_analysis.Rmd` — Full analysis: data wrangling, EDA, and regression models
- `shiny_app.R` — Interactive Shiny dashboard

## Tools & Languages
R, tidyverse, caret, ggplot2, Shiny, Arrow, Stan
