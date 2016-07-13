
library(data.table)

#############################################################
#
# function: get_Full_UCI_HAR_DataTable
#
# get complete UC HAR data set
#   Arguments:
#       directory: where the UCI HAR Dataset is: reference data, test and train subdirectories
#                   defaults to 'UCI HAR Dataset' subdirectory of project
#
#   Returns:
#       data.table: tidy data set

# usage: UCI_HAR_DataSet <- getFull_UCI_HAR_DataSet()
# 

getFull_UCI_HAR_DataTable <- function(directory = 'UCI HAR Dataset') {

  # Reference data
  
  # activityLabels:  data.table. activity labels, keyed by the activity id
  activityLabels <- read.table(paste0(directory, '/activity_labels.txt'),
                               col.names = c('activityId', 'activity'), colClasses = c('factor', 'factor'))
  
  activityLabels <- data.table(activityLabels, key = c('activityId'))
  
  # features: the names of the observation features (values). 561 of them
  #             will be used to name the feature columns from the observation files
  features <- read.table(paste0(directory, '/features.txt'), col.names = c('featureId', 'feature'), 
                         colClasses = c('integer', 'character'))
  
  features <- data.table(features, key = c('featureId'))
  
  # featuresColClasses, featuresColClasses: Column names and classes for loading feature files
  #                     we want to focus on mean and standard deviation features
  #                     which have names containing '-mean()' and '-std()'
  #                     The colNames are updated to not look like expressions
  
  featuresColNames <- ifelse(grepl("std\\()|mean\\()", features$feature), 
                             ifelse(grepl("-std\\()-", features$feature), sub("-std\\()-", "_Std_", features$feature),
                                    ifelse(grepl("-mean\\()-", features$feature), sub("-mean\\()-", "_Mean_", features$feature),
                                           ifelse(grepl("std\\()", features$feature), sub("std\\()", "_Std", features$feature),
                                                  ifelse(grepl("mean\\()", features$feature), sub("mean\\()", "_Mean", features$feature),
                                                         features$feature)))), features$feature)
  
  # this vector has to be the same length as the number of columns in the file
  # NULL indicates the column will be skipped on the read
  featuresColClasses <- ifelse(grepl("std\\()|mean\\()", features$feature), "numeric", "NULL")
  
  trainDataSet <- getUCI_HAR_DataTable(directory, activityLabels, featuresColNames, featuresColClasses, 'train')

  testDataSet <- getUCI_HAR_DataTable(directory, activityLabels, featuresColNames, featuresColClasses, 'test')

  # merge the 2 data tables to get the final result
  rbind(trainDataSet, testDataSet)
  
}

#############################################################
#
# function: getUCI_HAR_SubjectActivitySummaryDataTable
#
# The UCI HAR data set, summarized by subjectId and activity type

#   Arguments:
#       UCI HAR Dataset: A UCI HAR Dataset from get_Full_UCI_HAR_DataSet()
#
#   Returns:
#       data.table: UCI HAR Dataset aggregated by subject and activity

# usage: UCI_HAR_DataSet <- getFull_UCI_HAR_DataSet()
#        UCI_HAR_Subject_Activity <- get_UCI_HAR_SubjectActivityAggregatedResult(UCI_HAR_DataSet)
# 

getUCI_HAR_SubjectActivitySummaryDataTable <- function(fullResult) {
  
  resultCopy <- fullResult

  # remove columns from the original full result that are not to be aggregated
  resultCopy[, c("population", "observation", "activityId") := NULL]

  agg <- aggregate(. ~ subjectId + activity, 
            data = resultCopy, 
            mean)
  
  # rename the features to add "_Mean" to them
  newColNames <- ifelse(grepl("subjectId|activity", colnames(agg)), colnames(agg), paste0(colnames(agg),'_Mean'))
  setnames(agg, newColNames)
  
  agg
}

#############################################################
#
# function: getUCI_HAR_DataTable
#
# Process a UCI HAR data file (test or train) and return a "tidy" data table
#
#   Arguments:
#       directory: character. where the UCI HAR Dataset is: reference data, test and train subdirectories
#       activityLabels: data.table. reference data from UCI HAR
#       featuresColNames: data.table. names of features for the X data. reference data from UCI HAR
#       featuresColClasses: data.table. column types of features for the X data.
#                           columns to be skipped are "NULL". reference data from UCI HAR
#       dataSetType: character. sub directory of main UCI HAR directory
#
#   Returns:
#       data.table: tidy data set

# usage: trainDataSet <- getUCI_HAR_DataTable(directory, activityLabels, featuresColNames, featuresColClasses, 'train')
# 

getUCI_HAR_DataTable <- function(directory, activityLabels, featuresColNames, featuresColClasses, dataSetType) {
  print(paste("creating tidy data set from", directory, "and data set type:", dataSetType))

  # Activities: The activity for an observation. Reference data referred to in other data.
  
  Activities <- read.table(paste0(directory, '/', dataSetType, '/y_', dataSetType, '.txt'),
                                col.names = c('activityId'), colClasses = c('factor'))
  
  # Adding columns
  
  # observation = row number in file
  Activities$observation <- 1:nrow(Activities)
  
  # population = dataSetType (for when we merge with the other dataset )
  #               observations will be unique by population and observation
  Activities$population <- as.factor(dataSetType)
  
  Activities <- data.table(Activities, key = c('activityId'))
  
  # Observations: data.table.
  #   merged Activities and activityLabels on the activityId to get coded activities
  
  Observations <- merge(Activities, activityLabels)
  
  remove(Activities)
  
  # beyond here, we will be merging data into observations based on the observation id
  setkey(Observations, observation)
  
  # Subjects: The subject id for an observation
  
  Subjects <- read.table(paste0(directory, '/', dataSetType, '/subject_', dataSetType, '.txt'),
                                     col.names = c('subjectId'))
                              
  Subjects$observation <- 1:nrow(Subjects)
  
  Subjects <- data.table(Subjects, key = c('observation'))
  
  # add the subjectIds to the observations
  Observations <- merge(Observations, Subjects)
  remove(Subjects)
  
  # now the features for the observations
  # we are getting a subset of the features - see colClasses
  
  Features <- read.table(paste0(directory, '/', dataSetType, '/X_', dataSetType, '.txt'),
                              col.names = featuresColNames,
                              colClasses = featuresColClasses)
  Features$observation <- 1:nrow(Features)
  
  Features <- data.table(Features, key = c('observation'))
  
  # add the featrures to the observations
  Observations <- merge(Observations, Features)
  remove(Features)
  
  Observations
}

#####################################################

# get zip from InterWeb

dataSetURL <- 'https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip'
dataDirectory <- 'data'

if (!dir.exists(dataDirectory)) {
  dir.create(dataDirectory, recursive = TRUE)
}

dataSetZip <- 'UCI_HAR_DataSet.zip'
dataSetFullPath <- paste0(dataDirectory, '/', dataSetZip)

# unzip it

if (!file.exists(dataSetFullPath)) {
  download.file(dataSetURL, destfile=dataSetFullPath)
  
  dateDownloaded <- date()
  print(paste('downloaded', dataSetFullPath, 'at', dateDownloaded))
} else {
  print(paste('used exising zip file at', dataSetFullPath))
}

datasetDirectory <- paste0(dataDirectory, '/UCI HAR Dataset')

if (!dir.exists(datasetDirectory)) {
  unzip(dataSetFullPath, exdir = dataDirectory)
} else {
  print(paste('used exising UCI HAR dataset directory at', datasetDirectory))
}

outputDirectory <- paste0(dataDirectory,'/output')

if (!dir.exists(outputDirectory)) {
  dir.create(outputDirectory, recursive = TRUE)
}

# process the train and test data

UCI_HAR_DataTable <- getFull_UCI_HAR_DataTable(datasetDirectory)
print("Generated detailed UCI HAR Data Table")

# save it to CSV

UCI_HAR_DataTableCSV <- paste0(outputDirectory, '/UCI_HAR_tidy.csv')
write.csv(UCI_HAR_DataTable, file=UCI_HAR_DataTableCSV)
print(paste("Generated detailed UCI HAR Data Table CSV: ", UCI_HAR_DataTableCSV))

# summarize by subject and activity

UCI_HAR_Subject_Activity <- getUCI_HAR_SubjectActivitySummaryDataTable(UCI_HAR_DataTable)
print("Generated Subject and Activity summary UCI HAR Data Table")

UCI_HAR_SummaryDataTableCSV <- paste0(outputDirectory, '/UCI_HAR_SubjectAcivity_Summary.csv')
write.csv(UCI_HAR_Subject_Activity, file=UCI_HAR_SummaryDataTableCSV)
print(paste("Generated summary UCI HAR Data Table CSV: ", UCI_HAR_SummaryDataTableCSV))
