The `run_analysis.R` script performs the data preparation and then followed by the 5 steps required as described in the course project’s definition. It contains the following variables

`"activity" "subject" "tBodyAcc-mean()-X" "tBodyAcc-mean()-Y" "tBodyAcc-mean()-Z" "tBodyAcc-std()-X" "tBodyAcc-std()-Y" "tBodyAcc-std()-Z" "tGravityAcc-mean()-X" "tGravityAcc-mean()-Y" "tGravityAcc-mean()-Z" "tGravityAcc-std()-X" "tGravityAcc-std()-Y" "tGravityAcc-std()-Z" "tBodyAccJerk-mean()-X" "tBodyAccJerk-mean()-Y" "tBodyAccJerk-mean()-Z" "tBodyAccJerk-std()-X" "tBodyAccJerk-std()-Y" "tBodyAccJerk-std()-Z" "tBodyGyro-mean()-X" "tBodyGyro-mean()-Y" "tBodyGyro-mean()-Z" "tBodyGyro-std()-X" "tBodyGyro-std()-Y" "tBodyGyro-std()-Z" "tBodyGyroJerk-mean()-X" "tBodyGyroJerk-mean()-Y" "tBodyGyroJerk-mean()-Z" "tBodyGyroJerk-std()-X" "tBodyGyroJerk-std()-Y" "tBodyGyroJerk-std()-Z" "tBodyAccMag-mean()" "tBodyAccMag-std()" "tGravityAccMag-mean()" "tGravityAccMag-std()" "tBodyAccJerkMag-mean()" "tBodyAccJerkMag-std()" "tBodyGyroMag-mean()" "tBodyGyroMag-std()" "tBodyGyroJerkMag-mean()" "tBodyGyroJerkMag-std()" "fBodyAcc-mean()-X" "fBodyAcc-mean()-Y" "fBodyAcc-mean()-Z" "fBodyAcc-std()-X" "fBodyAcc-std()-Y" "fBodyAcc-std()-Z" "fBodyAccJerk-mean()-X" "fBodyAccJerk-mean()-Y" "fBodyAccJerk-mean()-Z" "fBodyAccJerk-std()-X" "fBodyAccJerk-std()-Y" "fBodyAccJerk-std()-Z" "fBodyGyro-mean()-X" "fBodyGyro-mean()-Y" "fBodyGyro-mean()-Z" "fBodyGyro-std()-X" "fBodyGyro-std()-Y" "fBodyGyro-std()-Z" "fBodyAccMag-mean()" "fBodyAccMag-std()" "fBodyBodyAccJerkMag-mean()" "fBodyBodyAccJerkMag-std()" "fBodyBodyGyroMag-mean()" "fBodyBodyGyroMag-std()" "fBodyBodyGyroJerkMag-mean()" "fBodyBodyGyroJerkMag-std()"`


## 1. Download the dataset
Download dataset to a folder called `DATA`  
`if(!file.exists('./DATA')) {dir.create('./DATA')}
fileURL <- 'https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip'
download.file(fileURL, destfile = './DATA/downloaded.zip')`

## 2. Assign each data to variables
561 column, tells each variable name  
`features <- read.table('./DATA/features.txt')`  

7352 observations, values for each 561 variables  
`X_train <- read.table('./DATA/train/X_train.txt')`  
7352 observations, tells wich activity it is (1~6)  
`y_train <- read.table('./DATA/train/y_train.txt')`  

7352 observations, values for each 561 variables  
`X_test <- read.table('./DATA/test/X_test.txt')`  
7352 observations, tells wich activity it is (1~6)  
`y_test <- read.table('./DATA/test/y_test.txt')` 

activity 1~6 -> actual name 름 ex. WALKING, WALKING_UPSTAIRS  
`activity_labels <- read.table('./DATA/activity_labels.txt')` 

## 3. Merge 'train' & 'test' into a single dataset
`X <- rbind(X_train, X_test)
y <- rbind(y_train, y_test)`

## 4. Extract only variables with 'mean()' or 'std()'
locations of variables we are interested in (numeric vector)  
`mean_std_vars <- grep('-mean\\(\\)|-std\\(\\)', features$V2)
library(dplyr)
X_new <- select(X, mean_std_vars) # choose the 66 variables`

## 5. Add variable 'activity' to name the activities of each observation
`X_new <- mutate(X_new, activity = activity_labels[y[,1],]$V2)`

## 6. Change variable names into descriptive names (ex. 'V1' -> 'tBodyAcc-mean()-X')
`names(X_new) <- c(as.character(features[mean_std_vars,]$V2), 'activity')`

## 7. Make new tidy dataset with the average of each variable for each activity and each subject
`subject_train <- read.table('./DATA/train/subject_train.txt')
subject_test <- read.table('./DATA/test/subject_test.txt')
subject <- rbind(subject_train, subject_test)
X_new <- mutate(X_new, subject = subject$V1)
by_activity_subject <- X_new %>%
	group_by(activity, subject) %>%
	summarize_at(vars(-group_cols()), mean)`
  
## 8. Export into `TidyData.txt` with `row.names=FALSE`
`write.table(by_activity_subject, "TidyData.txt", row.name=FALSE)`
