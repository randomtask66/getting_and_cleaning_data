#Create directory and unzip files
if(!file.exists("./data")){dir.create("./data")}
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(url, destfile = "./data/dataset.zip")
if (!file.exists("UCI HAR Dataset")) { 
        unzip("./data/dataset.zip") 
}
library(data.table)
library(RCurl)

#Load activity data
activity <- read.table("UCI HAR Dataset/activity_labels.txt")
activity[,2] <- as.character(activity[,2])
colnames(activity) <- c("factor","activity")

#Load features and clean column titles
features <- read.table("UCI HAR Dataset/features.txt")
features[,2] <- as.character(features[,2])
features[,2] <- gsub('-mean', 'Mean', features[,2])
features[,2] <- gsub('-std', 'Std', features[,2])
features[,2] <- gsub('-()', '', features[,2])

#Create vector of desired columns
measurements <- grep(".*Mean.*|.*Std.*",features[,2])
measurementNames <- features[measurements,2]

#Load training data
training <- read.table("UCI HAR Dataset/train/X_train.txt")
trainActivities <- read.table("UCI HAR Dataset/train/Y_train.txt")
trainSubjects <- read.table("UCI HAR Dataset/train/subject_train.txt")
train <- cbind(training, trainActivities,trainSubjects)

#Load testing data
testing <- read.table("UCI HAR Dataset/test/X_test.txt")
testActivities <- read.table("UCI HAR Dataset/test/Y_test.txt")
testSubjects <- read.table("UCI HAR Dataset/test/subject_test.txt")
test <- cbind(testing, testActivities, testSubjects)

#Combine datasets, filter for desirec columns and assign appopriate colunm names
fullSet <- rbind(train, test)
desiredCols <- c(measurements,562, 563)
filterSet <- fullSet[,desiredCols]
colnames(filterSet) <- tolower(c(measurementNames, "Activity", "Subject"))
#merge(filterSet, activity, by.x=activity,by.y=factor)

#Create a tidy data set that contains theaverage of each variable for each activity and each subject.
library(plyr)
tidySet <- ddply(filterSet, c("subject","activity"), numcolwise(mean))
write.table(tidySet, "tidySet.txt")
