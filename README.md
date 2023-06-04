# A-Data-Cleaning-Project-with-R
The dataset I have chosen, has been produced through the IATI (International Aid Transparency Initiative) query builder. The IATI Datastore provides data on development and humanitarian spending and projects that address poverty and crises across all over the world.
The query builder, finds data published by organisations from governments, development finance institutions and UN agencies to NGOs, foundations and the private sector and it allows you to build specific dataset focused on the information you are interested in. The data is published according to the IATI Standard: a set of rules and guidance for sharing useful, open data.
The dataset I have built through the query builder and that is going to be analysed - iatidatastore-iatistandard-2021-06-06T15_59_08.csv - shows the spending on projects that address only education, all over the world.
I have included all of the provider organisations available (so from governments, NGOs and the private sector). In more detail, the dataset combines spending on Basic Education, Secondary Education, Post-Secondary Education and any other unspecified Education Level, undertaken by a number of organisations worldwide.
The dataset is a CSV file, 24.2 MB big and comprises of 28.493 lines (including the titles) and 41 columns and it shows transactions from the period 1984 to now 2021.  I have chosen this dataset because I was interested in understanding who the primary recipients of the transactions which address education in their development and humanitarian spending are, and if the spending has changed in any way (increased, decreased or remained the same) during the time frame (1984-2021) and, finally, in what exact activities or programs were these transactions devolved to.

# Data preparation and exploratory analysis
We are going to open the provided Rstudio file titled “CW1_R” in R. This file has the full source script and each code has been commented to ensure clarity and readability.
It is best to run the codes in sections (or line by line, if you prefer). The sections are highlighted by these characters “------". There are 12 sections in the script.

Let’s follow the script and start with section #1 where I have reported a list of packages and libraries that will be used for this dataset preparation. These need to be run before we start with the uploading of the dataset into R.

To upload the dataset, please move to section #2 where I have first found my current working directory with getwd() and then set it with setwd() – please, always remember to do these steps on your own computer and to update this part of the codes “C:/Users/patie/OneDrive/Documents/” with your own directory!

I have loaded the dataset into a data frame called education_spending_df, reading it as a csv.
By analysing the structure of the data frame, we see that it comprises of 28492 observations and 41 variables and a variety of data types for each column.

In more detail and in order, column A of the table (to use the column letters, it may be helpful looking at the original Cvs file as well), represents the iati_identifier, which is the specific alpha numeric code that IATI utilizes to identify the specific activity, column B shows the reporting organization reference (that is the reference for that particular organization who has published the data).
Columns C and D, the title_narrative and the activity_description_narrative, correspondently return data that include the text that the providers have assigned to each activity (or transaction).
Columns E and F the activity (or transaction) recipient country code and the activity (or transaction) recipient region code are self-explanatory. The activity_sector_code in Column G, shows a column that includes 3 to 5 Digit Sector Codes (these are all codes related to the Education sector, which I had already pre-selected in the query builder).
Columns from H to AI refers to information on the transactions. In more detail, we can see the transaction reference number (H), transaction_humanitarian (I): this column informs you of whether a transaction is flagged as being humanitarian (1 Yes) or not (0 No); column transaction_type (J) - returns codes that describes the type of transaction. Columns K to P are self-explanatory.
Column Q, the transaction_provider_org_ref, for incoming funds this is the organisation from which the transaction originated. Please note that IATI explicitly says that if this value is omitted, then the reporting organization (column B) is assumed.
Moving on, column R and S still provide info on transaction with column S being the transaction provider organisation type, which refers to the organisation type of the providers of the transactions (they can be government, NGO, private sector or others). Column T shows the transaction provider organization narrative text. 
From column U to X the focus is on the receiver point of view, with: the transaction receiver org reference, transaction receiver organisation receiver activity id, transaction receiver org type and transaction receiver org narrative. Column Y, transaction_disbursement_channel_code, is actually empty and column Z transaction_sector_vocabulary it is not of interest for this analysis.
Columns from AA to AI show the transaction_sector_code (education sector), transaction_recipient_country_code, transaction_recipient_region_code, transaction_flow_type_code, transaction_finance_type_code, transaction_aid_type_code, transaction_aid_type_vocabulary, transaction_tied_status_code and transaction_description_narrative.

Finally, columns AJ to AP show a series of columns not of interest for this analysis. 

We can definitely say that this dataset is very rich of information, but many columns present data that is not of use for our analysis; the dataset also has a very high number of empty cells.
For the sole purpose of this coursework, many columns will be deleted to avoid both overwhelming unnecessary information and redundancy of the information and to produce a clear dataset for the final modelling. What I am trying to achieve, is to present a data frame that shows information focused specifically on the transaction, the recipient organisation and on the provider organisation.
To achieve this, in the next passages, columns will be deleted but also merged between one another (some of them also decoded) to provide a more concise and easy to understand data frame.
The deletion of the unnecessary columns has been done using <- subset, as shown in the script in section #2.
To better understand which are the columns that have been deleted and the reasons of their deletion, please refer to the summary below:

<img width="467" alt="image" src="https://github.com/Pat5c/R-_-A-Data-Cleaning-Project-with-R/assets/124057584/32ceec27-9ec3-4ae3-bfc5-f771693418c3">

For the now 18 columns left, we are going to do some decoding and merging.
Following the script, please run section #3.
We start with decoding column transaction_provider_org_ref.
To decode this column, the IATI website provides a decode file (called “Provider organization reference.csv”) that shows for each of the provider transaction organisation reference code (transaction_provider_org_ref) the matching provider organisation name. Please note that this file, however, offers the old list with the old references’ codes: IATI has yet to provide an updated provider organization reference file. We won’t, therefore, be able to have a comprehensive provider organisation name column in order to model the data.


Proceeding with the data preparation, what we want to do here is to upload this csv file as provider_organization_reference_df (please remember to use your own directory) and lookup the values in column transaction_provider_org_ref, against the main data frame education_spending_df, at the same column.
To achieve this, I have created a lookuptable with my new file and a maintable with the original data frame.
I have then matched the column of interest from both the tables (transaction_provider_org_ref).
What this does, is create c which is a data frame with the same length of the maintable (28492 observations) with the 2 columns of the lookup file (transaction_provider_org_ref & provider_org_name).
Once I have c, what is left to do is to blend the second column of c (provider_org_name) with the main data frame (education_spending_df) using cbind.
The output will be a new data frame (which I have called blended) with 19 columns as the new column provider_org_name has been appended at the last position.
Next step is to merge together the 2 existing columns transaction_provider_org_ref & reporting_org_ref.
We are merging these 2 columns together because, as stated above, we know that if the value of column transaction_provider_org_ref is omitted, then the reporting_org_ref is assumed (and the other way round).
For the sake of simplicity, I want to have all of this information inside a unique column: this will mean that together with this merge, we are also going to add to the merge the newly created column provider_org_name (which in fact decodes the transaction_provider_org_ref column).

Following the script, at section #4, I am going to merge the 2 existent columns in blended with the paste() function, the data will be separated by the underscore symbol. I am then going to merge this newly created merged column with the earlier created provider_org_name column, with paste () again.
This new column has been named org_provider_ok and it looks like this:
XM-DAC-41121_CH-4_Swiss Agency for Development and Co-	(row 110)
Where the values are:
reporting_org_ref_transaction_provider_org_ref _ provider_org_name
As anticipated, the column in not very informative because: we do not have enough information to decode the identity of the providers and do further modelling. However, I have decided to still keep this column because it still provides some indications on who the providers may actually be.
Lastly, I am deleting all of the columns that I don’t need any more, using subset().




Proceeding with this merging activity, following and running part #5 of the script, we are now going to merge together (with paste()) the existing columns: activity_recipient_country_code and transaction_recipient_country_code in data frame blended as the information is repetitive.
Again, I will be using the separator "_". This merged column will be then merged again with column transaction_receiver_org_ref to create a unique column.
The finally created merged column, called activity_Transaction_recipient_countrycode, is now appended into data frame blended.
Finally, removing the columns I do not need with subset(), as shown in the script.

Moving onto section #6, we are now going to decode column transaction_humanitarian and substitute the numbers 0 and 1 with No and Yes. Furthermore, we want to replace any empty cell (with a space or without) with the sentence "Not provided".
To achieve these changes, as shown in the script, I am using:
blended$transaction_humanitarian[blended$transaction_humanitarian %in%c("0")]<-"No" and replacing the objects in the speech marks with the items I want to replace and the replacement.

In section #7 we are now going to decode the transaction_type column with the descriptions in the file Transaction Type.cvs, doing a job similar to the one we did in section #5.
First of all, let’s upload the file into data frame transaction_type_df (as usual please update your directory).
As we can see, the file has 3 columns. What we want to do, before starting with the decoding and merging actions, is to actually merge the 2 columns name and description together, so we can work with only 2 columns. This is done again with paste(). The unnecessary columns are then dropped with subset().
Now we are ready to lookup this table against the maintable and get d, a dataframe with the same length of the maintable and with the looked-up values of the lookuptable.
Lastly, we are going to blend this newly created data frame (by only the second column name_desciption) to the main data frame blended and then drop all of the unnecessary columns.

Moving onto section #8, we are also going to decode column transaction_provider_org_type with file “Organisation type.csv”. As earlier, uploading the file into a data frame, creating the lookup and main tables.
Matching the organisation references in the maintable and lookuptable to get data frame e.
Blending the second column of this lookuptable e$name (which I’ve renamed transaction_name_description) with the blended using cbind. Finally, dropping all of the unnecessary columns.


In section #9 we are going to decode column transaction_receiver_org_type as well, using the file: “Organisation type – Copy”. Again, uploading the file with the right directory, creating the lookup and main table. Creating f which matches the organisation references in the maintable and lookuptable.
Then blending the second column of f, to the blended data frame, finally dropping the unnecessary columns.

Now that we have done all of the merging, decoding and blending we are going to tidy up the blended data frame. In section #10 I am going to check how many NAs values are there in the whole data frame with is.na (the number is 60252).
I will replace these values with the words “Not provided” as I’ve decided I do not want NAs in this dataset.
Same logic is going to be applied to the empty cells, as shown in the code.
Characters “__” and “_NA” are also going to be removed using lapply and function.
Please note that in column activity_description_narrative, some words are in French and are presented with special characters. I have decided to leave them as they are as the column in itself is only descriptive (and I do not speak French).

In section #11 I am going to check and fix all of the types of this final data frame, setting as numeric the columns with integers (I am using sapply).
Now that I have done this, an error message appears saying that there are “NAs that have been introduced by coercion”. I found these NAs and they appear to be in numeric column transaction_usd_conversion_rate. What I do is then simply replace them with a 0.
I am then setting as date the column transaction_date_iso_date.
Checking everything again with str(): now everything seems to be in the proper type!
Last but not least, I want to rename the columns’ titles with more comprehensive descriptions. I do that with rename() and finally I reorder my data frame in  a more logical order, using the dplyr library with select().
My blended data frame is now renamed Education_Spending_df and is much simpler and understandable.

Dataframe Education_Spending_df shows the IATI identifier codes and the activity descriptions in the first 2 columns.  From the third column until the 9th the focus is on the transaction: the third column tells us if the transaction is humanitarian or not, we have then the transaction value, currency, USD conversion rate, USD value and finally the transaction description and date.
The 10th column shows the provider organisation reference and description while the column next to it the receiver organisation’s country code, followed by the text narrative for both provider and receiver and finally, their types. In the next stage, I am planning to model the data in order to provide insights on the transactions, by analysing it with statistics (mean, max, min etc) and capturing changes in the transaction values, over the time (the columns Transaction_USD_value & Transaction_date will be used to achieve this). I also want to show how many of these transactions are humanitarian or non-humanitarian (using column Humanitarian_transaction_Y_N) and create for all the above, clean visualisations which may help to show hidden trends or interesting patterns.  
I am also planning to produce visualizations to show which are the main recipient countries of these transactions and (using column Receiver_organisation_countrycode) and what types of organizations are they (using column Receiver_organization_type).
Finally, it would also be really interesting to be able to predict future spending of the providers: is education going to be a sector that provider organisation will still want to fund in the future, at this rate? 
