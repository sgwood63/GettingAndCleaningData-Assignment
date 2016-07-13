# Coursera Getting and Cleaning Data Assignment

## Assignment Goal

The assignment is to prepare tidy data that can be used for later analysis.

The data being analyzed was collected from the accelerometers from the Samsung Galaxy S smartphone. A full description is available at the site where the data was obtained:

http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones

Here are the data for the project:

https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip

The assignment work is captured in one R script called `run_analysis.R` to produce the results.

## The Data

The experiments have been carried out with a group of 30 volunteers within an age bracket of 19-48 years. Each person performed six activities (WALKING, WALKING_UPSTAIRS, WALKING_DOWNSTAIRS, SITTING, STANDING, LAYING) wearing a smartphone (Samsung Galaxy S II) on the waist. Using its embedded accelerometer and gyroscope, we captured 3-axial linear acceleration and 3-axial angular velocity at a constant rate of 50Hz. The experiments have been video-recorded to label the data manually. The obtained dataset has been randomly partitioned into two sets, where 70% of the volunteers was selected for generating the training data and 30% the test data. 

The sensor signals (accelerometer and gyroscope) were pre-processed by applying noise filters and then sampled in fixed-width sliding windows of 2.56 sec and 50% overlap (128 readings/window). The sensor acceleration signal, which has gravitational and body motion components, was separated using a Butterworth low-pass filter into body acceleration and gravity. The gravitational force is assumed to have only low frequency components, therefore a filter with 0.3 Hz cutoff frequency was used. From each window, a vector of features was obtained by calculating variables from the time and frequency domain.

For each record contains:
=========================

* Triaxial acceleration from the accelerometer (total acceleration) and the estimated body acceleration.
* Triaxial Angular velocity from the gyroscope. 
* A 561-feature vector with time and frequency domain variables. 
* Its activity label. 
* An identifier of the subject who carried out the experiment.

The downloaded dataset includes the following files:
====================================================

* 'README.txt'

* 'features_info.txt': Shows information about the variables used on the feature vector.

* 'features.txt': List of all features.

* 'activity_labels.txt': Links the class labels with their activity name.

The following files are available for the train data. There are equivalent files for the 'test' data. 

* 'train/X_train.txt': Training results for all features.

* 'train/y_train.txt': Training labels.

* 'train/subject_train.txt': Each row identifies the subject who performed the activity for each window sample. Its range is from 1 to 30. 

* 'train/Inertial Signals': directory of data used to generate the features. The files in the Inertial Signals directories are summarized in the test/train directories and do not need to be processed.


Data Notes: 
===========
* Features are normalized and bounded within [-1,1].
* Each feature vector is a row on the text file.

## Data License

Use of this dataset in publications must be acknowledged by referencing the following publication [1] 

[1] Davide Anguita, Alessandro Ghio, Luca Oneto, Xavier Parra and Jorge L. Reyes-Ortiz. Human Activity Recognition on Smartphones using a Multiclass Hardware-Friendly Support Vector Machine. International Workshop of Ambient Assisted Living (IWAAL 2012). Vitoria-Gasteiz, Spain. Dec 2012

This dataset is distributed AS-IS and no responsibility implied or explicit can be addressed to the authors or their institutions for its use or misuse. Any commercial use is prohibited.

Jorge L. Reyes-Ortiz, Alessandro Ghio, Luca Oneto, Davide Anguita. November 2012.

## Processing

### 1. Merges the training and the test sets to create one data set and
### 3. Uses descriptive activity names to name the activities in the data set

* subject_{test | train}.txt: row # = observation id, value = subject id for that observation id
* y_{test | train}.txt: row # = observation id, value = id of activity (in activity_labels.txt) for that observation id
* X_{test | train}.txt: row # = observation id, values = 561 features for that observation id

Consolidate across the 3 files for test and train, and then consolidate into a data.table labeling each row as:
* row id
* test/train
* subject id
* activity label

### 2. Extracts only the measurements on the mean and standard deviation for each measurement.

Focus on a subset of features (columnsin the X_{test | train}.txt with names containing '-mean()' and '-std()'

Examples from features.txt

column id, name

1 tBodyAcc-mean()-X
2 tBodyAcc-mean()-Y
3 tBodyAcc-mean()-Z
4 tBodyAcc-std()-X
5 tBodyAcc-std()-Y
6 tBodyAcc-std()-Z

41 tGravityAcc-mean()-X
42 tGravityAcc-mean()-Y
43 tGravityAcc-mean()-Z
44 tGravityAcc-std()-X
45 tGravityAcc-std()-Y
46 tGravityAcc-std()-Z
...

201 tBodyAccMag-mean()
202 tBodyAccMag-std()

214 tGravityAccMag-mean()
215 tGravityAccMag-std()

227 tBodyAccJerkMag-mean()
228 tBodyAccJerkMag-std()

### 4. Appropriately labels the data set with descriptive variable names.

The 'mean' and 'std' feature names look like R expressions, so they were converted to mixed case (camel case), removing () and -.

> str(UCI_HAR_DataTable)
Classes ‘data.table’ and 'data.frame':	10299 obs. of  71 variables:
 $ observation               : int  1 2 3 4 5 6 7 8 9 10 ...
 $ activityId                : Factor w/ 6 levels "1","2","3","4",..: 5 5 5 5 5 5 5 5 5 5 ...
 $ population                : Factor w/ 2 levels "train","test": 1 1 1 1 1 1 1 1 1 1 ...
 $ activity                  : Factor w/ 6 levels "LAYING","SITTING",..: 3 3 3 3 3 3 3 3 3 3 ...
 $ subjectId                 : int  1 1 1 1 1 1 1 1 1 1 ...
 $ tBodyAcc_Mean_X           : num  0.289 0.278 0.28 0.279 0.277 ...
 $ tBodyAcc_Mean_Y           : num  -0.0203 -0.0164 -0.0195 -0.0262 -0.0166 ...
 $ tBodyAcc_Mean_Z           : num  -0.133 -0.124 -0.113 -0.123 -0.115 ...
 $ tBodyAcc_Std_X            : num  -0.995 -0.998 -0.995 -0.996 -0.998 ...
 $ tBodyAcc_Std_Y            : num  -0.983 -0.975 -0.967 -0.983 -0.981 ...
 $ tBodyAcc_Std_Z            : num  -0.914 -0.96 -0.979 -0.991 -0.99 ...
 

### 5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

Average (mean) each feature in the main result, aggregating by subject and activity type.
Change the column names to add 'Mean' at the end to not mix them up with the original feature values.

> str(UCI_HAR_Subject_Activity)
'data.frame':	180 obs. of  68 variables:
 $ subjectId                      : int  1 2 3 4 5 6 7 8 9 10 ...
 $ activity                       : Factor w/ 6 levels "LAYING","SITTING",..: 1 1 1 1 1 1 1 1 1 1 ...
 $ tBodyAcc_Mean_X_Mean           : num  0.222 0.281 0.276 0.264 0.278 ...
 $ tBodyAcc_Mean_Y_Mean           : num  -0.0405 -0.0182 -0.019 -0.015 -0.0183 ...
 $ tBodyAcc_Mean_Z_Mean           : num  -0.113 -0.107 -0.101 -0.111 -0.108 ...
 $ tBodyAcc_Std_X_Mean            : num  -0.928 -0.974 -0.983 -0.954 -0.966 ...
 $ tBodyAcc_Std_Y_Mean            : num  -0.837 -0.98 -0.962 -0.942 -0.969 ...
 $ tBodyAcc_Std_Z_Mean            : num  -0.826 -0.984 -0.964 -0.963 -0.969 ...
 $ tGravityAcc_Mean_X_Mean        : num  -0.249 -0.51 -0.242 -0.421 -0.483 ...
 $ tGravityAcc_Mean_Y_Mean        : num  0.706 0.753 0.837 0.915 0.955 ...
 $ tGravityAcc_Mean_Z_Mean        : num  0.446 0.647 0.489 0.342 0.264 ...
 $ tGravityAcc_Std_X_Mean         : num  -0.897 -0.959 -0.983 -0.921 -0.946 ...
 $ tGravityAcc_Std_Y_Mean         : num  -0.908 -0.988 -0.981 -0.97 -0.986 ...
 $ tGravityAcc_Std_Z_Mean         : num  -0.852 -0.984 -0.965 -0.976 -0.977 ...
 
