# Coding_Challenge

As title says, Coding Challenge it's about facing a problem and trying to solve this. 
In this case, let's imagine that we are at 27/11/2017, we are on CyberMonday. An eCommerce mobile application is emitting stream of json format tagging messages containing behavioural
information as consumers use the app.

## Functional description

### What information the application can give us?

We make the assumption that all catched EVENTS are made by logged users.

A logged user can..
* make log-in
* browse product categories
* view product details 
* view recommended products
* add to shopping cart
* make a purchase
* create own product design
* add product to fav list
* make a refund
* make log-out

### Ok but.. what is there to do with all that information?

The eCommerce company owning the app would like to:
1) Reliably capture the incoming message stream where there could be large fluctuations in the number of messages being received at a given time
2) Queue the data for further processing
3) Parse the data to tabular structures
4) Forward the data to tables in a data warehouse for analysis and reporting teams


## Technical description

If we are going to analyze information about CyberMonday 24-hours, we will have: 

### Sources
The application would generate 24 json files. One per hour. However, we are going to load information only for first one hour (00.00 am - 01.00 am) like a proof of concept. Therefore, we will have 1 JSON file and XML file too. We will work with XML file as data source. This file has been built manually trying to be as real as possible. It contains all information about different events (aka actions) that one user can do on App: make_login, view_product, add_to_cart, make_purchase...

### Staging
A ETL process parses the XML data and store it in different tabular CSV files in a normalized way: events_20171127000000.csv, products_20171127000000.csv, actions_20171127000000.csv, users_20171127000000.csv

### Target

As last step, it moves all CSV information files to a MySQL database (called `Coding.challenge`) where a datawarehouse tables have been designed as a BI traditional star model. First we load dimension tables (user_dim, action_dim, product_dim) and second the facts (events_fact table).


## Deployment

### Prerrequisites

* To be in Windows environment (Disclamer: the solution has not been proved in Linux/Unix Environments)
* Pentaho Data Integrator (The development is made with 7.1 version)
* MySQL Server 5.7 or above as a target system
* A SMTP Server where you are able to connect :) (if not you cannot send email notifications when ETL process finishes)

### Installing

Firstable, you have to copy all this Folder Structure to C:\ :

![alt text](http://staticforms.net/ftp/img/estructura_carpetas.PNG "Folder Structure")


Second, if you have a MySQL Server and a root database user then you must execute the file "ddl_coding_challenge_MySQL.sql". For that, you must assure that bin folder of your MySQL Server Installation is embededd in PATH environment system variable. Only then you will be able to execute this command via Windows Command Line):

```
mysql -u <MySQLuser> -p < C:\Coding_Challenge\AdrianMartinezMolina\Resources\Target\MySQL\ddl_coding_challenge_MySQL.sql
```

Third, you can open all Pentaho files ("C:\Coding_Challenge\AdrianMartinezMolina\PDI Batch Process") in PDI.

```
0_Coding_Challenge.kjb
```

The main job and the only one you must execute. This job executes the following transformations: 1_XML_to_CSV.ktr, 2_CSV_to_MySQL_DIMENSIONS.ktr, 3_CSV_to_MySQL_FACTS.ktr.
It also handles the final email notification regarding of the process finishes successful or not.

```
1_XML_to_CSV.ktr
```

This is the step where the XML file (events_xml_20171127000000.xml) is used as source to generate CSV files located in "..\Resources\Staging\csv\". Basically, the transformation generates 5 minded CSV files to ease the loading towards database tables.

```
2_CSV_to_MySQL_DIMENSIONS.ktr
```

Once we have generated all those CSV files, we need to turn over to Dimension Target tables (user_dim, action_dim, product_dim). We have designed dimensions thinking about reporting. That is to say, we have generated surrogated keys (user_key, action_key, product_key) in dimensions and we have put together products and their categories to able to work with herarchies.

```
3_CSV_to_MySQL_FACTS.ktr
```
By last, we fill fact table (events_fact) from "events_xml_20171127000000.xml" file. 

```
4_CSV_to_MySQL_FACTS_ERROR_HANDLING.ktr
```
As a demonstration, we have created a new transformation almost identical than 3_CSV_to_MySQL_FACTS.ktr but this one handles incorrect records deriving them to its appropiate error file (i.e: located in "..\Resources\Error_files\users_20171127000000.err" or "..\Resources\Error_files\actions_20171127000000.err"). Since the dimension information tables is filled by the same file than facts, it is impossible to reproduce this use case without a manipulated XML file called "events_xml_20171127000000_error_handling.xml".


## Running a test

You only have to click on play button of PDI job: "\PDI Batch Process\0_Coding_Challenge.kjb".  That's all.

```
Notes:
1. If you want to try to receive Email Notifications when ETL process finishes, it is mandatory to set these parameters:
* P_EMAIL_DEST_ADDR
* P_EMAIL_SENDER_ADDR
* P_EMAIL_SMTP_SERVER
* P_EMAIL_STMP_SERVER_PORT
* P_EMAIL_AUTH_USER

2. If you want to try the errors management, you must set the following parameter to TRUE:
* P_ERROR_HANDLING_FLAG
```

## Future Things to Test

* make partitioning by hour of event (event_fact)
* test with P_CONTENT_DATE parameter to run the process every hour (actual solution is prepared to this)

## Author

* **Adrian Martinez** - *Initial work*
