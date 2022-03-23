# qvr_processing
A function to process and clean QVR data using R.

## Background
QVR (short for Query, View, Report) is an internal database used for tracking, reporting, and analyzing research project applications and awards at the US National Institutes of Health (NIH). QVR data is frequently exported and used for analysis and evaluation at NIH, but QVR's export data structure often requires extensive preprocessing to transform it into a usable format for analysis. Some multi-value fields, like Prinipal Investigator names and Program Class Codes, are often split over multiple lines, while other fields are duplicated across the multiple lines. Other fields like award status return administrative codes ("A", "TP", "W", etc.) instead of cleaner Yes/No values.

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
The function has six major steps. 

First, it removes any completely duplicated rows in the data frame using the `unique()` function. 

Second, if a single document has data spread over multiple rows, it collapses that data into a single semicolon-delimited string. To do this, it first splits the data into a list of data frames (one data frame for each document) using the column specified in the `doc_id` argument (which defaults to "Appl.Id", which is how that column typically is read in to R). Next, it finds which data frames have multiple rows for the same `doc_id`. Next, it finds which columns within those data frames  have non-identical data in its rows (i.e., data spread over multiple rows). For each identified column, it then pastes the unique values for each document together into semicolon-delimited text strings. Finally, it creates a new version of the data frame with one row per `doc_id` and replaces the identified column values with the newly created semicolon-delimited versions.

Third, if the data frame has the necessary columns, it adds a series of new "Y/N" columns for animal subjects, human subjects, clinical trial, and award status. It checks the given status codes against a list of known status codes to return a flag indicating if the award has the field or not. So an award that includes human subjects would be marked as "Y" in the added `is_human` column. 

Fourth, it replaces awkward column names like "Awd.Tot.Cost.." from the original QVR data with more R-friendly versions like "awd_tot_cost". 

Fifth, it replaces all cells in the data frame that have a value of "-" with NA. 

And finally, it removes any columns that consist entirely of NA values. QVR will often inlcude extra commas at the end of lines, which are read into R as being empty columns, so the function removes them.

## Extensions
At the moment, this function has only been tested on data sets from QVR that include an Appl ID column, but in principle it could be used to collapse data on other unique identifiers (like Investigator Profile IDs, ORCID IDs, or FOA numbers) or used on other data sets with different document IDs by changing the `doc_id` argument. 
