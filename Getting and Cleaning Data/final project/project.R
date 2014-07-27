# script to produce tidy data set for UCI HAR Dataset
#
datadir <- c( "data/UCI HAR Dataset/" )
traindir <- paste(datadir,"train/", sep="")
testdir <- paste(datadir,"test/",sep="")

# now read files
subject_train <- read.table(paste(traindir,"subject_train.txt",sep=""),sep=" ")
x_train <- read.table(paste(traindir,"X_train.txt",sep=""), quote="\"")
y_train <- read.table(paste(traindir,"y_train.txt",sep=""), sep=" ")
subject_test <- read.table(paste(testdir,"subject_test.txt",sep=""),sep=" ")
x_test <- read.table(paste(testdir,"X_test.txt",sep=""), quote="\"")
y_test <- read.table(paste(testdir,"y_test.txt",sep=""), sep=" ")

features <- read.table(paste(datadir,"features.txt",sep=""), quote="\"")

## 1. Merges the training and the test sets to create one data set
## 4. Appropriately labels the data set with descriptive variable names.
## NOTE: 1 and 4 are complete in this section

# add an indicator flag for train or test (0/1), subject #,activity #, measurements
learning <- rep(0,length(subject_train))
train.df <- cbind(,subject_train,y_train,x_train)

test.df <- cbind(rep(1,length(subject_test)),subject_test,y_test,x_test)
features[,2] <- as.character(features[,2])
# form the col names and cleanup invalid characters
# notice the .mean extensions given for the column names. 
# This is for filtering mean and std columns

cnames <- c("learning.mean", "subject.mean", "activity.mean", features[,2])
cnames <- gsub("\\(\\)",".",cnames)
cnames <- gsub("\\.$","",cnames)
cnames <- gsub("\\)$","",cnames)
cnames <- gsub("\\-",".",cnames)
cnames <- gsub("\\,",".",cnames)
cnames <- gsub("\\(",".",cnames)
cnames <- gsub("\\-",".",cnames)
cnames <- gsub("\\.\\.",".",cnames)
cnames <- gsub("\\)","",cnames)
cnames.df <- data.frame(cnames)
names(train.df) <- cnames
names(test.df) <- cnames
# check if names have duplicates
duplicateIndicator <- duplicated(cnames)
if (sum(duplicateIndicator) >0)
  print("WARNING: Column names have duplicats. However none are mean or std. So OK")
DF.step1 <- rbind(train.df, test.df)

# 2. Extracts only the measurements on the mean and standard deviation 
#    for each measurement.
colnum.match <- grep("mean|std", names(DF.step1))
DF <- DF.step1[,colnum.match]
# cleanup column names after extracting mean and std columns
names(DF)[1:3] <- c("learning","subject","activity")

# 3. Uses descriptive activity names to name the activities in the data set
factivity <- factor(DF$activity, 
                   labels=c("WALKING","WALKING_UPSTAIRS","WALKING_DOWNSTAIRS","SITTING","STANDING","LAYING"))
DF$activity <- factivity
# TIDY DATA SET COMPLETE

# 5. Creates a second, independent tidy data set with the average of each variable for 
#   each activity and each subject.
mSubjects <- unique(DF$subject)
mActivity <- unique(DF$activity)
tidy.mean <- apply(expand.grid(mSubjects, mActivity),1,
      function(x) sapply(DF[DF$subject==x[1] & DF$activity==x[2] ,4:82],mean))
tidy.mean <- as.data.frame(tidy.mean)
tidy.matrix <- as.matrix(tidy.mean)
tidy.matrix <- t(tidy.matrix)
tidy.cnames <- rownames(tidy.mean)
tidy.mean.df <- as.data.frame(tidy.matrix)
names(tidy.mean.df) <- tidy.cnames
tidy.x <- as.data.frame(apply(expand.grid(mSubjects, mActivity),1,
      function(x) cbind(x[1], x[2])))
tidy.x <- as.data.frame(t(as.matrix(tidy.x)))
tidy.mean.df <- as.data.frame(cbind(tidy.x, tidy.mean.df))
names(tidy.mean.df)[1:2] <- c("subject","activity")
tidy.mean.df <- tidy.mean.df[!is.nan(tidy.mean.df[,4]),]
write.table(DF, file=paste(datadir,"tidy_df.txt",sep=""), row.names=FALSE)
write.table(tidy.mean.df,file=paste(datadir,"tidy_mean_df.txt",sep=""), row.names=FALSE)