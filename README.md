# Project Details

Using Telecommunication data of students to predict the Relationship Type. The telecommunication data has been gathered from the following link: [https://sites.nd.edu/nethealth/communication-event-data/](https://sites.nd.edu/nethealth/communication-event-data/)

The original telecommunication file has nearly 60.5 million rows and stored in local MS-SQL, where data preprocessing was performed to filter irrelevant entries. This included filtereing all blank calls, empty text messages, or group messages.

The SQL files `CommunicationEventAnalysis.sql` and `CommunicationEventAnalysis.sql` contain the required scripts for data preprocessing. Basic EDA was performed on this data [`EDA.ipynb`].

The relevant telecom events were placed in `CommunicationEventsSELECTIVE.csv`. All the events in this file were then separated into different CSV files, each corresponding to an egoid-alterid pair [`creatingCSV_pairs.ipynb`]. These files were stored in the `telecomData_egoid_alterid` folder, with the format `{egoid}_{alterid}.csv`. 

For each of these files, a Hawkes power-law kernel fitting was performed to obtain the required parameters for each relationship using the caller data [COMPLIED_POWER_LAW_RESULTS.csv].

The [https://sites.nd.edu/nethealth/network-survey-data/](https://sites.nd.edu/nethealth/network-survey-data/) network survey data was used to label the data and determine the relationship between each egoid-alterid pair.

After obtaining the Hawkes parameters for each relationship and the labels[hawkes-networksurveyCOMPLETE.csv], various machine learning models were trained on this data.

