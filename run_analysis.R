# set working directory
setwd("C:/Users/CEID/Desktop/Online course/Data Science with R course/Projects In R - course 3")

# import files
test_X <-read.table("./UCI HAR Dataset/test/X_test.txt")
test_y <-read.table("./UCI HAR Dataset/test/y_test.txt")
test_subject <- read.table("./UCI HAR Dataset/test/subject_test.txt")
train_X <- read.table("./UCI HAR Dataset/train/X_train.txt")
train_y <- read.table("./UCI HAR Dataset/train/y_train.txt")
train_subject <- read.table("./UCI HAR Dataset/train/subject_train.txt")

# read feature, transpose feature table for merging
feature<-read.table("./UCI HAR Dataset/features.txt")
feature<-t(feature[,2])

# make a list of activity for later matching
activity<-read.table("./UCI HAR Dataset/activity_labels.txt")
activity<-unlist(list(activity[,2]))

# combine correspondingly
library(dplyr)
test_combine<-cbind(test_subject, test_y, test_X)
train_combine <- cbind(train_subject, train_y, train_X)
combine<-rbind(test_combine, train_combine)
# rename column for later extraction
for(i in 3:563){
  names(combine)[i] = feature[i-2]
  names(combine)[1] = "Subject_ID"
  names(combine)[2] = "Activity"
}

# select columns with "mean", "std"
combine_select<-select(combine, c(1,2, grep("mean[()]|std[()]", names(combine))))
# match activity labels to column "activity"
for(i in 1:nrow(combine_select)){
  combine_select$Activity[i] <- activity[as.integer(combine_select$Activity[i])]
}

# rename columns with descriptive names
list_names<-names(combine_select)
list_names<- gsub("-"," ", list_names)
list_names<- gsub("[()]","", list_names)
list_names<- gsub("^[t]","time ", list_names)
list_names<- gsub("^[f]", "freq ", list_names)
for(i in 1:ncol(combine_select)){
  names(combine_select)[i] = list_names[i]
}

# tidy up the data
combine_group<- combine_select %>%
  group_by(Subject_ID, Activity) %>%
  arrange(Subject_ID, Activity)
combine_sum<-summarize_each(combine_group,mean)

# export data
write.table(combine_sum,file="tidydata.txt",row.names=FALSE)
