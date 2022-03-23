# qvr_processing
A function to process and clean QVR data using R.

## Background
QVR (short for Query, View, Report) is an internal database used for tracking, reporting, and analyzing research project applications and awards at the US National Institutes of Health (NIH). QVR data is frequently exported and used for analysis and evaluation at NIH, but QVR's export data structure often requires extensive preprocessing to transform it into a usable format for analysis. Some multi-value fields, like PI names and PCC codes, are often split over multiple lines, while other fields are duplicated across the multiple lines. Other fields like award status return two-character codes ("A", "TP", "W", etc.) instead of cleaner Yes/No values.

The `process_qvr_data()` function attempts to automate this preprocessing phase and transform the QVR data into a more "R-friendly" analytical format. It takes a data frame of the raw QVR data as its primary input and returns a cleaned and reformatted data frame of the same data with one record per row. 

## Usage
To use the function on a .csv file exported from QVR, first read the file into R with the `read.csv()` function

```r
appls <- read.csv("my_application_data.csv", stringsAsFactors = FALSE)
```

and then load the `process_qvr_data()` function with `source()`

```r
source("qvr_processing.r")
```

Finally, run the `process_qvr_data()` function on `appls`

```r
appls <- process_qvr_data(appls)
```

## How it works
The function has six major steps. First, it removes any completely duplicated rows in the data frame using the `unique()` function. Second, it finds all of the columns that have data split over multiple rows and collapses the unique values from those rows for each document ID into a single semicolon-delimeted field. Third, if the data frame has the relevant columns, it adds a series of new "Y/N" columns for animal subjects, human subjects, clinical trial, and award status. Fourth, it transforms awkward column names like "Awd.Tot.Cost.." from the original QVR data with more R-friendly versions like "awd_tot_cost". Fifth, it replaces all cells in the data frame that a value of "-" with NA values. And finally, it removes any columns that consist entirely of NA values, which are sometimes added to the QVR export. 
