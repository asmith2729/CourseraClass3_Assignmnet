
#SECTION ONE - download and unzip
#Download the file and save into the working directory
download.file(url = "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip", destfile="Dataset.zip")
#Unizips the file and places the results in the working directory. 
unzip("Dataset.zip", exdir="Week4Data")



#SECTION TWO - load dataframes
#Read in the files needed as dataframes from the folder unzipped above
actv_labels <- read.csv(".\\Week4Data\\UCI HAR Dataset\\activity_labels.txt", sep ='', header=FALSE, col.names = c("Actv_Cd","Actv_Desc")) #activity_labels.txt
features <- read.csv(".\\Week4Data\\UCI HAR Dataset\\features.txt", sep ='', header=FALSE, col.names = c("Feat_Cd","Feat_Desc"))

subject_train <- read.csv(".\\Week4Data\\UCI HAR Dataset\\train\\subject_train.txt", sep ='', header=FALSE, col.names = c("Subj_Id"))
subject_test <- read.csv(".\\Week4Data\\UCI HAR Dataset\\test\\subject_test.txt", sep ='', header=FALSE, col.names = c("Subj_Id"))

actv_train <- read.csv(".\\Week4Data\\UCI HAR Dataset\\train\\Y_train.txt", sep ='', header=FALSE, col.names=c("Activity"))
actv_test <- read.csv(".\\Week4Data\\UCI HAR Dataset\\test\\Y_test.txt", sep ='', header=FALSE, col.names=c("Activity"))

data_train <- read.csv(".\\Week4Data\\UCI HAR Dataset\\train\\X_train.txt", sep ='', header=FALSE)
data_test <- read.csv(".\\Week4Data\\UCI HAR Dataset\\test\\X_test.txt", sep ='', header=FALSE)
#Add'l step to name the columns of the 'data_train' and 'data_test' dataframes
#This should eventually satisfy the criteria in Step4 even though I'm doing it early in the script
datacolnames <- features[,2]
colnames(data_train) <- datacolnames
colnames(data_test) <- datacolnames


##SECTION THREE - Combine the data sets
#Use column bind to creates a combined dataframe for all 3 train dfs and all 3 test dfs. Then add a "Type" column to each in order to track 
#Train vs Test data
alltrain<-cbind(subject_train,actv_train,data_train)
alltest<-cbind(subject_test,actv_test,data_test)
alltrain$Type<-"train"
alltest$Type<-"test"
#use rbind to combine the two datasets
#This should satisfy the criteria for Step1
all<-rbind(alltrain, alltest)


#Creates a vector of columns I want to keep. 
#First, retain the Subj_Id and Activity, then find and append all the columns that contain 'mean' or 'std' in the column name
outcols<- c("Subj_Id","Activity")
outcols <- append(outcols, grep("mean|std", names(all), value=T))
#Second, filter the combined test and train df to return only the columns found in 'outcols'
#This should satisfy the criteria for Step2
meanstd_df<-all[outcols]
#Third, use gsub to remove all parantheses from the column names of meanstd_df.  This will enable using sqldf in upcoming steps
colnames(meanstd_df)<-gsub("\\()", "", outcols)


#Using sqldf, join the descriptions of each activity in actv_labels to the actvity code in meanstd_df
library (sqldf)
step4 <- sqldf("SELECT a.Actv_Desc, ms.* FROM meanstd_df ms INNER JOIN actv_labels a on ms.Activity=a.Actv_Cd")
#drop the column called "Activity" since we have description now
step4 <- subset(step4, select=-c(Activity))
#This should satisfy the critera for Step3 and Step4



#SECTION FOUR - Summarize and output the results
#Use the aggregate function to group by Subj_Id and Actv_Desc and take the mean of all the remaining columns
#This should satisfy the criteria for Step5
step5<-aggregate(step4[,3:81], list (Subject_Id=step4$Subj_Id, Activity_Description=step4$Actv_Desc),mean)
write.csv(step5,"Week4_Assignment_ACSmith.csv",  row.names=FALSE)

