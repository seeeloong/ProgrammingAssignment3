# ProgrammingAssignment3

Explanation for run_analysis.R code

## Step 1: Import data
### 1.1 read the files into R
```
test_X <-read.table("./UCI HAR Dataset/test/X_test.txt")
test_y <-read.table("./UCI HAR Dataset/test/y_test.txt")
test_subject <- read.table("./UCI HAR Dataset/test/subject_test.txt")
train_X <- read.table("./UCI HAR Dataset/train/X_train.txt")
train_y <- read.table("./UCI HAR Dataset/train/y_train.txt")
train_subject <- read.table("./UCI HAR Dataset/train/subject_train.txt")
```
these codes import 6 data files to R

### 1.2 Import labels (feature, activity)
In order to use "feature.txt" as column names and match "activity_labels.txt" with activities, the 2 files are also imported to with the following codes:
```
# read "feature"
feature<-read.table("./UCI HAR Dataset/features.txt")
# transpose feature for later merging
feature<-t(feature[,2])
#read "activity label"
activity<-read.table("./UCI HAR Dataset/activity_labels.txt")
# make a list of activity for later matching
activity<-unlist(list(activity[,2]))
```

## Step 2: Combine all data
### 2.1 Combine the data using rbind and cbind
```
# Activate dplyr
library(dplyr)
# combine columns
test_combine<-cbind(test_subject, test_y, test_X)
train_combine <- cbind(train_subject, train_y, train_X)
# combine test and train data (rows)
combine<-rbind(test_combine, train_combine)
```
### 2.2 Rename the columns
Rename each columns using table "feature", that is transposed in step 1.2
```
# rename column for later extraction
for(i in 3:563){
  names(combine)[i] = feature[i-2]
  names(combine)[1] = "Subject_ID"
  names(combine)[2] = "Activity"
}
```

## Step 3: Extract columns and match activity index
### 3.1 Find column names that include "mean()" or "std()" and select them
```
# select columns with "mean", "std"
combine_select<-select(combine, c(1,2, grep("mean[()]|std[()]", names(combine))))
```
### 3.2 Match activity index
In each row, the activity index is matched with the activity list extracted in step 1.2
```
# match activity labels to column "activity"
for(i in 1:nrow(combine_select)){
  combine_select$Activity[i] <- activity[as.integer(combine_select$Activity[i])]
}
```

## Step 4: Rename Columns with descriptive names
### 4.1 Extract names of columns from the table
```
list_names<-names(combine_select)
```
### 4.2 Replace the names in the list
Using the names extracted in 4.1 (i.e. list_names), change them correspondingly:
```
# replace "-" with space
list_names<- gsub("-"," ", list_names)
# remove "()"
list_names<- gsub("[()]","", list_names)
# replace the beginning "t" with "time"
list_names<- gsub("^[t]","time ", list_names)
# replace the beginning "f" with "freq"
list_names<- gsub("^[f]", "freq ", list_names)
```
### 4.3 Change the names in the table
```
for(i in 1:ncol(combine_select)){
  names(combine_select)[i] = list_names[i]
}
```

## Step 5: Tidy up the data
### 5.1 group the data with subject_id and activity
```
combine_group<- combine_select %>%
  group_by(Subject_ID, Activity) %>%
  arrange(Subject_ID, Activity)
```
### 5.2 Summarize the data with the mean
```
combine_sum<-summarize_each(combine_group,mean)
```

## Step 6: Export the data
```
write.table(combine_sum,file="tidydata.txt",row.names=FALSE)
```
