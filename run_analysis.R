# run_analysis.R; 
# setwd("./GettingAndCleaningData/Assignments/Project2")

# Set the data, test and training folders:
dataDir <- "./GACD_data/UCI HAR Dataset";
trDir <- paste(dataDir, "train", sep="/");
tstDir <- paste(dataDir, "test", sep="/");

library(data.table);

# First, load the features into a vector
feats <- read.table(paste(dataDir, 'features.txt', sep = '/'), stringsAsFactors=FALSE);

# Select  only the measurements on the mean and standard deviation.
subFeats <- subset(feats, grepl("-mean()",feats$V2) | grepl("-std()",feats$V2));

# now read the data: Test set
XTest <- read.table(paste(tstDir, "X_test.txt",sep="/"));
# retain only the columns we need:
XTest <- XTest[, subFeats$V1];
yTest <- read.table(paste(tstDir, "y_test.txt",sep="/"));
subjTest <- read.table(paste(tstDir, "subject_test.txt",sep="/"));
# change some column names:
colnames(subjTest) <- c("subject");
colnames(yTest) <- c("activityID");
colnames(XTest) <- subFeats$V2;

# now bind these three parts
XTest <- cbind(subjTest, yTest, XTest);

# and do the same for the training data
XTraining <- read.table(paste(trDir, "X_train.txt",sep="/"));
# retain only the columns we need:
XTraining <- XTraining[, subFeats$V1];
yTraining <- read.table(paste(trDir, "y_train.txt",sep="/"));
subjTraining <- read.table(paste(trDir, "subject_train.txt",sep="/"));
# change some column names:
colnames(subjTraining) <- c("subject");
colnames(yTraining) <- c("activityID");
colnames(XTraining) <- subFeats$V2;

# now bind these three parts
XTraining <- cbind(subjTraining, yTraining, XTraining);

# concatenate the two data sets into one
dataSet <- rbind(XTest, XTraining, use.names = TRUE);
# now add the activity labels for the activityIDs
# for this, I load the activity labels into a data frame and do a merge on the activityID column.
activityLabels <- read.table(paste(dataDir, 'activity_labels.txt', sep = '/'), stringsAsFactors=FALSE);
colnames(activityLabels) <- c("activityID", "activity");
dataSet <- merge(dataSet, activityLabels, by.x = "activityID");

tidyData <- aggregate(dataSet, by=list(dataSet$subject, dataSet$activity), FUN = mean); 
# the above call will give warnings because of the activity column which can't be coerced to numeric. I remove it from the final data set. And also do some renaming.
tidyData$activity <- NULL;
tidyData$activityID <- NULL;
tidyData$subject <- NULL;

names(tidyData)[names(tidyData) == 'Group.1'] <- 'subject';
names(tidyData)[names(tidyData) == 'Group.2'] <- 'activity';

# save the file
write.table(tidyData, "pr_assignment_2_tidy_data.txt", row.names=FALSE);
print("File \'pr_assignment_2_tidy_data.txt\' created in the working directory!");

# final cleanup
remove(XTest, XTraining, subjTest, subjTraining, yTest, yTraining);
remove(feats, subFeats);
remove(activityLabels);
remove(tidyData, dataSet, dataDir, trDir, tstDir);

# That's all, folks!
print("That's all, folks!");
