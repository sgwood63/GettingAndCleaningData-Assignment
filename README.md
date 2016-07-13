# Coursera Getting and Cleaning Data Assignment

## Assignment Goal

The assignment is to prepare tidy data that can be used for later analysis.

The data being analyzed was collected from the accelerometers from the Samsung Galaxy S smartphone. A full description is available at the site where the data was obtained:

http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones

Here are the data for the project:

https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip

The assignment work is captured in one R script called run_analysis.R that does the following:

1. Merges the training and the test sets to create one data set.
2. Extracts only the measurements on the mean and standard deviation for each measurement.
3. Uses descriptive activity names to name the activities in the data set
4. Appropriately labels the data set with descriptive variable names.
5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

## File Overview

This document, README.md, describes `run_analysis.R`.

When the run_analysis.R is executed in R, it will create a `data` subdirectory where data will be downloaded, worked on and output- into `data/output`

There is a separate file, Codebook.md, in this repository that describes:
* variables
* data
* transformations or work that performed to clean up the data

## run_analysis.R Code Overview: functions, variables and script 

Relies on: library(data.table)

### Functions

Detailed documentation is in the `run_analysis.R` script.

* getFull_UCI_HAR_DataTable

** Produces the full Data Table for the Assignment
** Loads reference data - activity types, observation -> subject id, feature (metric) types in observations
** Executes getUCI_HAR_DataTable for "tidy" test and train data sets
** Returns merged result

* getUCI_HAR_SubjectActivitySummaryDataTable

** Uses the result
**Produces The UCI HAR data set, summarized by subjectId and activity type

* getUCI_HAR_DataTable

** Produces the "tidy" data table for UCI HAR test or train data
** called by getFull_UCI_HAR_DataTable
** Loads data files, merges with reference and other data
** Reduces columns of observation columns to mean and std (standard deviation) only


### Script

Executed when `run_analysis.R` is loaded (source("run_analysis.R"))

* Downloads source data from InterWeb and unzips it
* Executes getFull_UCI_HAR_DataTable and getUCI_HAR_SubjectActivitySummaryDataTable functions against the downloaded data
* Creates CSV files as output: into data/output

### Variables left in Global Environment

* UCI_HAR_DataTable: data.table
* UCI_HAR_Subject_Activity: data.table
* UCI_HAR_DataTableCSV: path and file name
* UCI_HAR_SummaryDataTableCSV: path and file name
* working variables


