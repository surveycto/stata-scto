# Stata package with SurveyCTO related utility functions

This repo Stata commands was developed to work with data collected using [SurveyCTO](https://www.surveycto.com)'s data collection software.

## Content

This Stata package includes four commands related to processing data outputted from SurveyCTO Surveys:

* **sctoapi** - downloads SurveyCTO data in JSON format via the API. The data is then converted and saved in CSV and DTA (optional) formats. Optionally, it also downloads media files which are saved in a subfolder named 'media'. (_if you're running into errors with the command, follow these_ [_troubleshooting steps_](https://github.com/surveycto/stata-scto/wiki/General-troubleshooting))
* **sctomedia** - creates copies of SurveyCTO media files in a specified folder with user-friendly names constructed from values stored in your dataset. This includes images, audio, video and text media files. This command can also optionally organize such files into a folder structure, also named using values stored in your data.
* **sctostreamcsv** - reads sensor stream csv files and calculates statistics for each time period used when collecting the sensor stream. This command can be used to see which part of the questionnaire was done in a context that was quiet, dark etc.
* **sctostreamsum** - reads sensor stream csv files and calculates statistics for each submission and saves them all in a .dta file that can merged with the main survey data. This allows you to get all the features from the *sensor_statistics* field even after the data collection as long as you used the *sensor_stream* field for the sensor you are interested in.
* **sctorezone** - shifts time zones of *time* and *datetime* fields collected by SurveyCTO and formatted by SurveyCTO .do file templates.

## Installation
This package requires Stata 13 or newer (**sctoapi** requires Stata 14 or newer).

The easiest way to install this package of commands and keep it up to date is to type `ssc install scto` in Stata. Keep the files up to date by running `adoupdate` regularly, and follow the instructions if any of your installed packages are out of date.

### Installation alternatives to SSC
An alternative to SSC is to install this package directly from the files in this repository. This should not be the preferred method for most users as the only advantage of this method compared to `ssc install scto` is that it allows you to install a version of the _scto_ package from another branch in this repo where we are developing features not yet published on SSC. This is only relevant to users that are helping us to test out new features.

If you want to install the version of the package in the master branch, simply use the code below. You rarely want to do that, as that is the same as installing the commands using `ssc install scto`. If you want to install the files from another branch than the master branch, simply replace _master_ in the URL below with the name of the branch you want to install from.
```
    cap net uninstall scto
    net install scto , from("https://raw.githubusercontent.com/surveycto/scto/master/src") replace
```
If you are not able to run `net install` from your computer, then you can download a .zip file with the content of this repository, extract it, and then replace the URL with the file location of the _src_ folder where you extracted the content of the .zip file. Make sure that you are in the branch you want to install beofre you downaload the .zip archive, otherwise you will get the _master_ branch version, which you can install much easier using `ssc install scto`.

## Contributions
Contributions and any type of feedback is welcomed. Please feel free to submit a pull request with your own contributions, or open up a new issue on this page with a feature request, bug report or anything else. You can also send an email with your feedback to the email address below.

---

### **License**
The **scto** package is developed under Apache License 2.0. See http://www.apache.org/licenses/LICENSE-2.0 or see [the `LICENSE` file](https://github.com/surveycto/scto/blob/master/LICENSE) for details.

### **Main Contact**
SurveyCTO ([support@surveycto.com](mailto:support@surveycto.com))
