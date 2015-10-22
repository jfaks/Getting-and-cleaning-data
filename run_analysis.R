#####################################################################################################
#librarys
library(plyr)
library(dplyr)
#####################################################################################################

#####################################################################################################
#"global" varibles
destfile = "./data/assignmentdata.zip"
fileUrl = "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
#####################################################################################################


#####################################################################################################
#Set working directry where import files are
#assuming folder structure is intact
#change to whereever
if(!file.exists("./tempdata")) {dir.create("./tempdata")}
download.file(fileUrl, destfile = destfile)
unzip(destfile, exdir = "./data")

#Import files
#activity labels
activityNames <- read.table("./data/UCI HAR Dataset/activity_labels.txt", sep = '', header = FALSE, col.names = c("Test_label","Test_label_name"))


#####################################################################################################
#varibale names
varNames <- read.table("./data/UCI HAR Dataset/features.txt", sep = '', header = FALSE, strip.white = TRUE)
#varNames <- read.table(file.choose(), sep = '', header = FALSE, strip.white = TRUE)
varNames <- t(varNames)
varNames <- varNames[2,]
#####################################################################################################


#####################################################################################################
#testdata
assignTest <- read.table("./data/UCI HAR Dataset/test/X_test.txt", sep = '', header = FALSE, strip.white = TRUE, col.names = varNames)
#assignTest <- read.table(file.choose(), sep = '', header = FALSE, strip.white = TRUE, col.names = varNames)

#test subjects
subjectsTest <- read.table("./data/UCI HAR Dataset/test/Subject_test.txt", sep = '', header = FALSE, col.names = "Test_subject")
#subjectsTest <- read.table(file.choose(), sep = '', header = FALSE, col.names = "Test_subject")

#test labels
subjectsLabels <- read.table("./data/UCI HAR Dataset/test/y_test.txt", sep = '', header = FALSE , col.names = "Test_label")

# bind columns
assignTestdataTotal <- cbind(subjectsTest,subjectsLabels,assignTest)

#traindata
assignTrain <- read.table("./data/UCI HAR Dataset/train/X_train.txt", sep = '', header = FALSE, strip.white = TRUE, col.names = varNames)

#test subjects
subjectsTrain <- read.table("./data/UCI HAR Dataset/train/Subject_train.txt", sep = '', header = FALSE, col.names = "Test_subject")

#test labels
subjectsLabels <- read.table("./data/UCI HAR Dataset/train/y_train.txt", sep = '', header = FALSE , col.names = "Test_label")

# bind columns
assignTraindataTotal <- cbind(subjectsTrain,subjectsLabels,assignTrain)
#####################################################################################################


#####################################################################################################
#bind datasets to one, i.e both Test and train in same
assignTotal <- rbind(assignTestdataTotal,assignTraindataTotal)

#Subset data fot only mean or stddev
# All columnnamnes with the name -mean or -std choosen
# but columns where only that variable is used, like angle variables are excluded 
# as those are of a different type 
varNames <- cbind(c("Test_subject","Test_Label",varNames))
colIndex <- c(1,2,grep('-mean|-std',varNames))

subTotal <- select(assignTotal, colIndex)


#Join to get activity names
activitySub <- merge(subTotal,activityNames,by.x = "Test_label", by.y = "Test_label")
activitySub <- select(activitySub, -(Test_label))
#####################################################################################################

#####################################################################################################
##Group data by activity and Subject
#and then summarize by mean


activitySummarized <- activitySub %>% group_by(Test_subject,Test_label_name) %>%  summarise_each(funs(mean))

#write file to WD
write.table(activitySummarized,"GetnCleandtaAssignTidy.txt", row.names = FALSE)

#####################################################################################################

#####################################################################################################
#cleanup
rm(activityNames)
rm(varNames)
rm(assignTest)
rm(subjectsLabels)
rm(subjectsTest)
rm(assignTrain)
rm(subjectsTrain)
rm(assignTotal)
rm(subTotal)
rm(colIndex)
rm(assignTestdataTotal)
rm(assignTraindataTotal)
rm(activitySub)


#remove data folder
unlink("tempdata", recursive = TRUE, force = TRUE)
#####################################################################################################