# SSC Meta Description
See instructions for the content in this file here: http://repec.org/bocode/s/sscsubmit.html

This is the information that will show when typing `ssc describe scto` in Stata and on the ideas.repec.org page that will be created once we publish the first version. See, as an example, `ssc describe ietoolkit` and https://ideas.repec.org/c/boc/bocode/s458137.html.

When updating this information at any point in the future, send the content of the 5 sections (Title, Description, Keywords, Required Stata Version and Author and Email) to Kit Baum when you are updating the package. Just copy the raw text to the body of the email.

If you are not updating this meta information when updating the files in the `scto` package, then you do not have to submit this information with the files.

***

### Title
SCTO - Module to provide utility functions for data collected using SurveyCTO

### Description
The scto Stata package is a set of utility functions related to data collected using SurveyCTO, www.surveycto.com. Currently the package includes four commands that help with downloading data (sctoapi), organizing media files (sctomedia) and processing sensor stream data files (sctostreamsum & sctostreamcsv) captured during surveys conducted using SurveyCTO. The first downloads forms' data in JSON and converts it into CSV and DTA (optional), the second creates copies of media files in a folder structure with user-friendly names constructed from values stored in your dataset, while the other process sensor stream data (recordings of light level, sound level and pitch, and movement), aggregates it, leaving you with a dataset that can be merged with the main survey data, and calculate statistics for each time period throughout each interview. These commands are developed by the team at SurveyCTO.

### Keywords
* data collection
* CAPI
* mobile surveys
* fieldwork
* ODK
* SurveyCTO
* survey data
* sensor data
* media files
* RESTful API

### Required Stata Version      
Stata 13

### Author and Email
* Author: SurveyCTO
* Support: email support@surveycto.com

***
Do not send anything from below this line.

### What are keywords?
This is an explanation to the keywords used below. I do not know how frequently they are used, but this is a list of keywords that are searchable. So if you search on _field work_ (but I do not know where you do that search) you should find this command as it is one of the keywords.
