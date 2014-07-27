### Introduction

This project implements the R script project.R to clean the UCI HAR Dataset for wearables

The script accomplishes all the 5 key objectives required of the project. Most importantly no processing is done outside of the R-script

1. Merges the training and the test sets to create one data set.
2. Extracts only the measurements on the mean and standard deviation for each measurement. 
3. Uses descriptive activity names to name the activities in the data set
4. Appropriately labels the data set with descriptive variable names. 
5. Creates a second, independent tidy data set with the average of each variable for each activity and each subject. 

### Preparing the input data

The script assumes there is a directory named "data" in the same directory as the script.
The raw data from UCI is downloaded and unpacked in the directory "UCI HAR Dataset" maintaining the directory heirachy in the zip file

### Running the script

Once the data is loaded, the script can be run from R-Studio.

### Output files
Two output files are created in the "UCI HAR Dataset"
tidy_df.txt - this is the tidy dataset output produced by the R-script
tidy_mean_df.txt - this is the mean of each measured variable in the dataset for a unique combination of subject and activity
