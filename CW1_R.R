#STUDENT ID:TG0104

#1
------------------------------------
#Install the packages I will be using
install.packages ("data.table")
library(data.table)
install.packages("plyr") #to use the rename function
library(dplyr)

#2
-----------------------------#R1 Correctly loads data
#Find out name of current working directory with getwd()
getwd()
#Set work directory -> PLEASE USE YOUR OWN WORK DIRECTORY!
setwd("C:/Users/patie/OneDrive/Documents")
#Load data as a data frame. PLEASE REMEMBEER TO USE YOUR OWN DIRECTORY!
education_spending_df <- read.csv("C:/Users/patie/OneDrive/Documents/iatidatastore-iatistandard-2021-06-06T15_59_08.csv")
#Let's look at the data frame
View(education_spending_df)
#Now let's look at the structure of the data frame 
str(education_spending_df)
#Let's do more exploring. Let's check the few first lines of the table
head(education_spending_df)
#I am now going to delete all of the columns that I will not need for my analysis
education_spending_df <- subset(education_spending_df, select = -c(title_narrative,activity_recipient_region_code,activity_sector_code,transaction_ref,transaction_value_date,transaction_provider_org_provider_activity_id,transaction_receiver_org_receiver_activity_id,transaction_disburstment_channel_code,transaction_sector_vocabulary,transaction_sector_code,transaction_recipient_region_code:default_humanitarian))
#Let's have a look at the table now, that only the columns I want to keep are left
View(education_spending_df)

#3
--------------------------------------
#I now going to decode column "transaction_provider_org_ref" with the file "Provider organization reference"
#First, I'll upload this file -> PLEASE REMEMBER TO USE YOUR OWN DIRECTORY!
provider_organization_reference_df <- read.csv("C:/Users/patie/OneDrive/Documents/Provider organization reference.csv")
#Let's have a look at it:
View(provider_organization_reference_df)
#I am now going to look up the values in this new dataframe against my education_spending_df maintable dataframe.
#The values to look up, will be the ones in column transaction_provider_org_ref (present in both the dataframes).
#The output will be the creation of a vector of the same length of the main dataframe (education_spending_df)
#This vector will then be blended to the maintable as a column (and it will show the values in the second column of file Provider organization reference)
#First creating my maintable and lookuptable data frames
lookuptable<-data.frame(provider_organization_reference_df)
maintable<-data.frame(education_spending_df)
#Matching and looking up the provider_organization_reference_df references in both the maintable and in the lookuptable into a new data frame
c <- lookuptable[match(maintable$transaction_provider_org_ref, lookuptable$transaction_provider_org_ref), ]
#Blending the newly created data frame (c) - but picking up only the second column provider_org_name, to my initial main data frame
provider_org_name <-c$provider_org_name
provider_org_name
blended <- cbind(education_spending_df,provider_org_name)
#Now my main data frame (which I have renamed as blended) has 19 columns: the provider_org_name column has been appended at the last position
View(blended)

#4
----------------------------------
#For the column reporting_org_ref, we know that if this value is omitted, then the transaction_provider_org_ref is assumed.
#Given that we've now created and added column provider_org_name. I am now going to merge these 3 columns (reporting_org_ref, transaction_provider_org_ref and provider_org_name) into a single colum to avoid redundant information.
#Starting with merging the 2 columns reporting_org_ref, transaction_provider_org_ref (the separator"_" will be used)
blended$org_provider <- paste(blended$reporting_org_ref, blended$transaction_provider_org_ref, sep="_")
#Let's have a look at the updated main data frame: column org_provider has been created as a result of the merge.
View(blended)
#I now go and merge the newly created column with provider_org_name column and call my new column simply: org_provider_ok
blended$org_provider_ok <- paste(blended$org_provider, blended$provider_org_name, sep="_")
#I am now going to drop columns provider_org_name, org_provider, reporting_org_ref & transaction_provider_org_ref as we do not need them anymore.
blended <- subset(blended, select = -c(org_provider, reporting_org_ref, transaction_provider_org_ref, provider_org_name))
View(blended)

#5
--------------------------------------------
#I am now going to merge columns: activity_recipient_country_code and transaction_recipient_country_code as the information is redundant, always using the separator "_", into a column called activity_Transaction_recipient_countrycode.
blended$activity_Transaction_recipient_countrycode <- paste(blended$activity_recipient_country_code, blended$transaction_recipient_country_code, sep="_")
blended$activity_Transaction_recipient_countrycode
#I am now going to merge this newly created column also with transaction_receiver_org_ref as the information is redundant.
blended$activity_Transaction_recipient_countrycode <- paste(blended$activity_Transaction_recipient_countrycode, blended$transaction_receiver_org_ref, sep="_")
#Let's now drop the columns activity_recipient_country_code, transaction_receiver_org_ref  and transaction_recipient_country_code as we do not need them anymore.
blended <- subset(blended, select = -c(activity_recipient_country_code, transaction_recipient_country_code, transaction_receiver_org_ref))
#Let's have a look at the data frame
View(blended)

#6
---------------------------------------------------
#Let's now decode column transaction_humanitarian and substitute the numbers (0 and 1) with No and Yes. Any other empty cell with a space or without will be replaced with the sentence "Not provided"
blended$transaction_humanitarian[blended$transaction_humanitarian %in%c("0")]<-"No"
blended$transaction_humanitarian[blended$transaction_humanitarian %in%c("1")]<-"Yes"
blended$transaction_humanitarian[blended$transaction_humanitarian %in%c("")]<-"Not provided"
blended$transaction_humanitarian[blended$transaction_humanitarian %in%c(" ")]<-"Not provided"
View(blended)

#7
-----------------------------------------
#Decoding the transaction_type column with the descriptions in the file Transaction Type. First uploading this file: PLEASE REMEMBEER TO USE YOUR OWN DIRECTORY!
transaction_type_df <- read.csv("C:/Users/patie/OneDrive/Documents/Transaction Type.csv")
#Let's have a look at it:
View(transaction_type_df)
#To make the following steps easier, I am going to merge the 2 columns in this file "name" and "description" together, into a column called name_description, separating the value with "_"
transaction_type_df$name_description <- paste(transaction_type_df$name, transaction_type_df$description, sep="_")
#Let's now drop the columns name and description which I don't need anymore
transaction_type_df <- subset(transaction_type_df, select = -c(name, description))
View(transaction_type_df)
#My data set is now ready to be used in the lookuptable:
#Creating my maintable and lookuptable data frames for the lookup I will be doing:
lookuptable1<-data.frame(transaction_type_df)
maintable1<-data.frame(blended)
#Matching the organisation references in the maintable and lookuptable
d <- lookuptable1[match(maintable1$transaction_type, lookuptable1$transaction_type), ]
#Blending the newly created detaframe (d) by only column name_description to my initial main dataframe (blended)
transaction_name_description <-d$name_description
blended <- cbind(blended, transaction_name_description)
#Finally dropping the column I do not need anymore: transaction_type
blended <- subset(blended, select = -c(transaction_type))
# Now my dataset has 15 columns, the transaction_name_description column has been appended at the last position
View(blended)

#8
---------------------------------------------
#The same decoding procedure is going to be done to column transaction_provider_org_type 
#Decoding the transaction_provider_org_type column with the descriptions in the file Organisation type.
#First uploading this file: PLEASE REMEMBEER TO USE YOUR OWN DIRECTORY!
transaction_provider_org_type_df <- read.csv("C:/Users/patie/OneDrive/Documents/Organisation type.csv")
#Let's have a look at it:
View(transaction_provider_org_type_df)
#Creating my maintable and lookuptable data frames for the lookup I will be doing
lookuptable2<-data.frame(transaction_provider_org_type_df)
maintable2<-data.frame(blended)
#Matching the organisation references in the maintable and lookuptable
e <- lookuptable2[match(maintable2$transaction_provider_org_type, lookuptable2$transaction_provider_org_type), ]
#Blending the newly created detaframe (e) by only column name to my initial main dataframe (blended). Calling my new column: transaction_provider_org_type_description
transaction_provider_org_type_description <-e$name
blended <- cbind(blended, transaction_provider_org_type_description)
#Finally dropping the column I do not need anymore: transaction_provider_org_type
blended <- subset(blended, select = -c(transaction_provider_org_type))
#Let's have a look at the dataframe
View(blended)

#9
----------------------------------------------------
#Lastly, I am going to decode column transaction_receiver_org_type as well, using the  file: Organisation type - Copy
#First uploading this file: PLEASE REMEMBEER TO USE YOUR OWN DIRECTORY!
transaction_receiver_org_type_df <- read.csv("C:/Users/patie/OneDrive/Documents/Organisation type - Copy.csv")
#Let's have a look at it:
View(transaction_receiver_org_type_df)
#Creating my maintable and lookuptable data frames for the lookup I will be doing
lookuptable3<-data.frame(transaction_receiver_org_type_df)
maintable3<-data.frame(blended)
#Matching the organisation references in the maintable and lookuptable
f <- lookuptable3[match(maintable3$transaction_receiver_org_type, lookuptable3$transaction_receiver_org_type), ]
#Blending the newly created detaframe (e) by only column name to my initial main dataframe (blended). Calling my new column: transaction_provider_org_type_description
transaction_receiver_org_type_description <-f$name
blended <- cbind(blended, transaction_receiver_org_type_description)
#Finally dropping the column I do not need anymore: transaction_provider_org_type
blended <- subset(blended, select = -c(transaction_receiver_org_type))
View(blended)

#10
---------------------------------------------------#R3: Appropriately and correctly handles missing data
#Let's clean the blended data frame a bit now
#Let's check how many NAs values are in the whole dataset
sum(is.na(blended))
#There are 60252
#Let's now replace all of the NAs with the words "Not provided"
blended[is.na(blended)]<-"Not provided"
#Let's replace also all of the empty cells in the data frame with a "Not provided":
blended[blended==""]<-"Not provided"
#Let's remove all characters "__" with nothing, for the whole dataset, using this function
blended <- data.frame(lapply(blended, function(x) {gsub("__", "", x)}))
#Let's remove all characters "_NA" as trails with nothing, (these refers to empty columns with NA value that were merged initially) for the whole dataset, using a function
blended <- data.frame(lapply(blended, function(x) {gsub("_NA", "", x)}))
#Let's have a look at the outcome
View(blended)

#11
--------------------------------------------------#R2 Correctly handles type casting
#Checking the different types now and fixing the different columns to be the right type scenario as well.
str(blended)
#transaction_date_iso_date should be a date
#transaction_value should be a number
#transaction_usd_conversion_rate should be a number           
#transaction_value_usd should be a number   
#Let's start with the numbers
col.selection <- c("transaction_value", "transaction_usd_conversion_rate","transaction_value_usd")
blended[col.selection] <- sapply(blended[col.selection], as.numeric)
#After running the above, an error message appears:
#Warning message:
#In lapply(X = X, FUN = FUN, ...) : NAs introduced by coercion
#Cheching where these NAs are
sum(is.na(blended$transaction_value))
sum(is.na(blended$transaction_usd_conversion_rate))
sum(is.na(blended$transaction_value_usd))
# There are now 13444 NAs in column transaction_usd_conversion_rate. Let's replace those with a "0":
blended$transaction_usd_conversion_rate[is.na(blended$transaction_usd_conversion_rate)]<-"0"
#Done, now let's move onto the date column transaction_date_iso_date and set the correct type to date
col.selection <- c("transaction_date_iso_date")
blended$transaction_date_iso_date <- as.Date(blended$transaction_date_iso_date, format = "%d/%m/%Y")
#Let's have a look at the structure now
str(blended)
#All in order!

#12
--------------------------------------------#R4: Conducts appropriate exploratory analysis (see also report)
#Last but not least, I want to rename the column titles with more comprehensive titles:
blended <- rename(blended, c("IATI_identifier"="iati_identifier", "Activity_description"="activity_description_narrative", "Humanitarian_transaction_Y_N"="transaction_humanitarian", "Transaction_date"="transaction_date_iso_date", "Transaction_currency"="transaction_value_currency", "Transaction_value"="transaction_value", "Transaction_USD_conversion_rate"="transaction_usd_conversion_rate", "Transaction_USD_value"="transaction_value_usd", "Provider_transaction_narrative"="transaction_provider_org_narrative_text", "Receiver_transaction_narrative"="transaction_receiver_org_narrative", "Provider_organisation"="org_provider_ok", "Receiver_organisation_countrycode"="activity_Transaction_recipient_countrycode", "Transaction_description"="transaction_name_description", "Provider_organisation_type"="transaction_provider_org_type_description", "Receiver_organisation_type"="transaction_receiver_org_type_description"))
#Let's look at the outcome
View(blended)
#And now, reordering the column in a more logic order, using dplyr. I also want to rename my dataframe blended as Education_Spending_df
Education_Spending_df = select(blended,IATI_identifier,Activity_description,Humanitarian_transaction_Y_N,Transaction_value,Transaction_currency,Transaction_USD_conversion_rate,Transaction_USD_value,Transaction_description,Transaction_date,Provider_organisation,Receiver_organisation_countrycode,Provider_transaction_narrative,Receiver_transaction_narrative,Provider_organisation_type,Receiver_organisation_type)
View(Education_Spending_df)
#Column 1 IATI_identifier: IATI identifier code
#Column 2 Activity_description: provides a description of the activity (or transaction)
#Column 3 Humanitarian_transaction_Y_N: it tells us if the transaction is humanitarian or not
#Column 4 Transaction_value: shows the value of the transaction
#Column 5 Transaction_currency: shows the currency of the transaction
#Column 6 Transaction_USD_conversion_rate: shows the transaction USD conversion rate
#Column 7 Transaction_USD_value: shows the value of the transaction in USD
#Column 8 Transaction_description: offers a description of the transaction
#Column 9 Transaction_date: shows the date of the transaction
#Column 10 Provider_organisation: specify the identity of the provider organization
#Column 11 Receiver_organisation_countrycode: shows the county code of the receiver organisation
#Column 12 Provider_transaction_narrative: shows the descriptive text of the provider for the transaction
#Column 13 Receiver_transaction_narrative: shows the descriptive text of the receiver for the transaction
#Column 14 Provider_organisation_type: specify the type (NGO, Governmente, Private etc) of the provider organization 
#Column 15 Receiver_organisation_type;  specify the type (NGO, Governmente, Private etc) of the receiver organization
