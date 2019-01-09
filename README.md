# Stata package with SurveyCTO related utility functions

This repo includes the code for a commands that are developed by SurveyCTO and its community of users.

## Installation

**[NOT YET REALEASED]** The easiest way to install this package of commands and keep it up to date is to type `ssc install scto` in Stata. This pacakage requires Stata 13 or newer.

**[POSSIBLE ONCE REPO IS PUBLIC]** An alternative to SSC is to install this package directly from the files in this repository. If you want to install the version of the package in the master bracnh, simply use the code below. If you want to install the files from another branch than the master branch, simply replace _master_ in the URL below with the name of the branch you want to install from. 
```
    cap net uninstall scto
    net install scto , from("https://raw.githubusercontent.com/kbjarkefur/scto/master/src") replace
```

**[THIS WORKS ALREADY NOW]** If you are not able to run `net install` from your computer, then you can download a .zip file with the content of this repository, extract it, and then replace the URL with the file location of the _src_ folder where you extracted the content of the .zip file.

## Content

Currently there are two commands in this repo. Both of them are related to processing of sensor stream data outputted from SurveyCTO Surveys.

* **sctostreamcsv** - reads sensor stream csv files and calculates statistics for each time period used when collecting the sensor stream. This command can be used to see which part of the questionnaire was done in a context that was quiet, dark etc.
* **sctostreamsum** - reads sensor stream csv files and calculates statistics for each submission and saves them all in a .dta file that can merged with the main survey data.

## Contributions
Contributions and feedback of all sort is very much welcomed. Please feel free to submit a pull request with your own contributions, or open up a new issue on this page with a feature request, bug report or anything similar. You can also send an email with your feedback to the email address below.

---

### **License**
The **scto** package is developed under MIT license. See http://adampritchard.mit-license.org/ or see [the `LICENSE` file](https://github.com/kbjarkefur/scto/blob/master/LICENSE) for details.

### **Main Contact**
SurveyCTO ([info@surveycto.com](mailto:info@surveycto.com))
