library(reshape2)

filename <- "getdata_dataset.zip"

if (!file.exists(filename)){
  fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip "
  download.file(fileURL, filename, method="curl")
}  
if (!file.exists("UCI HAR Dataset")) { 
  unzip(filename) 
}

# Step 1: Loading the activity labels and features
activityL <- read.table("UCI HAR Dataset/activity_labels.txt")
activityL[,2] <- as.character(activityL[,2])
features <- read.table("UCI HAR Dataset/features.txt")
features[,2] <- as.character(features[,2])

# Step 2: Extract only the data on mean and standard deviation
featuresWant <- grep(".*mean.*|.*std.*", features[,2])
featuresWant.names <- features[featuresWant,2]
featuresWant.names = gsub('-mean', 'Mean', featuresWant.names)
featuresWant.names = gsub('-std', 'Std', featuresWant.names)
featuresWant.names <- gsub('[-()]', '', featuresWant.names)


# Step 3: Load the datasets
train <- read.table("UCI HAR Dataset/train/X_train.txt")[featuresWant]
trainActivities <- read.table("UCI HAR Dataset/train/Y_train.txt")
trainSubjects <- read.table("UCI HAR Dataset/train/subject_train.txt")
train <- cbind(trainSubjects, trainActivities, train)

test <- read.table("UCI HAR Dataset/test/X_test.txt")[featuresWant]
testActivities <- read.table("UCI HAR Dataset/test/Y_test.txt")
testSubjects <- read.table("UCI HAR Dataset/test/subject_test.txt")
test <- cbind(testSubjects, testActivities, test)

# Step 4:Merge datasets and add labels
allData <- rbind(train, test)
colnames(allData) <- c("subject", "activity", featuresWant.names)

# Step 5: Turn activities & subjects into factors
allData$activity <- factor(allData$activity, levels = activityL[,1], labels = activityL[,2])
allData$subject <- as.factor(allData$subject)

allData.melted <- melt(allData, id = c("subject", "activity"))
allData.mean <- dcast(allData.melted, subject + activity ~ variable, mean)
# Step 6 : Write the tidy data
write.table(allData.mean, "tidy.txt", row.names = FALSE, quote = FALSE)