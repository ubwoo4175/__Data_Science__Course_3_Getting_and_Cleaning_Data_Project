if(!file.exists('./DATA')) {dir.create('./DATA')}
fileURL <- 'https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip'
download.file(fileURL, destfile = './DATA/downloaded.zip')

# column이 561개임. 각각의 변수명 알려주는 파일
features <- read.table('./DATA/features.txt')

# observation 7352개인데 각각에서 측정/계산된 561개의 variable에 대한 수치
X_train <- read.table('./DATA/train/X_train.txt')
# observation 7352개인데 각각 어떤 activity인지 (1~6)
y_train <- read.table('./DATA/train/y_train.txt')


# observation 7352개인데 각각에서 측정/계산된 561개의 variable에 대한 수치
X_test <- read.table('./DATA/test/X_test.txt')
# observation 7352개인데 각각 어떤 activity인지 (1~6)
y_test <- read.table('./DATA/test/y_test.txt')

# activity 1~6의 실제 영어 이름 ex. WALKING, WALKING_UPSTAIRS
activity_labels <- read.table('./DATA/activity_labels.txt')



# ----------------------------------------------------
# Step 1. Merge 'train' & 'test' into a single dataset
# ----------------------------------------------------

X <- rbind(X_train, X_test)
y <- rbind(y_train, y_test)

# -------------------------------------------------------
# Step 2. Extract only variables with 'mean()' or 'std()'
# -------------------------------------------------------

# 관심있는 variable들의 위치 (numeric vector)
mean_std_vars <- grep('-mean\\(\\)|-std\\(\\)', features$V2)

library(dplyr)
X_new <- select(X, mean_std_vars) # 우리가 관심있는 variable 66개만 봄

# --------------------------------------------------------------------------
# Step 3. Add variable 'activity' to name the activities of each observation
# --------------------------------------------------------------------------

X_new <- mutate(X_new, activity = activity_labels[y[,1],]$V2)

# --------------------------------------------------------------------------------------
# Step 4. Change variable names into descriptive names (ex. 'V1' -> 'tBodyAcc-mean()-X')
# --------------------------------------------------------------------------------------

names(X_new) <- c(as.character(features[mean_std_vars,]$V2), 'activity')

# --------------------------------------------------------------------------------------
# Step 5. Make new tidy dataset with the average of each variable for each activity and each subject
# --------------------------------------------------------------------------------------
subject_train <- read.table('./DATA/train/subject_train.txt')
subject_test <- read.table('./DATA/test/subject_test.txt')
subject <- rbind(subject_train, subject_test)

X_new <- mutate(X_new, subject = subject$V1)

by_activity <- X_new %>%
	group_by(activity) %>%
	summarize_at(vars(-group_cols(), -subject), mean)

by_subject <- X_new %>%
	group_by(subject) %>%
	summarize_at(vars(-group_cols(), -activity), mean)

by_activity_subject <- X_new %>%
	group_by(activity, subject) %>%
	summarize_at(vars(-group_cols()), mean)
