{smcl}
{* 10 Oct 2019}{...}
{hline}
help for {hi:scto}
{hline}

{title:Title}

{pstd}
{bf:scto} {hline 2} Package to provide utility functions for data collected using SurveyCTO

{marker syntax}{...}
{title:Syntax}

{pstd}
Note that {cmd:scto} package doesn't have any syntax.

{marker description}{...}
{title:Description}

{pstd}
A package containing a set of utility functions related to data collected using SurveyCTO, www.surveycto.com. Please read
the description of each below.

{marker commands}{...}
{title:Stata Commands}

{phang}
This Stata package includes four commands related to processing data outputted from SurveyCTO Surveys:

{phang}
{opt sctoapi} downloads SurveyCTO data in JSON format via the API. The data is then converted and saved in CSV and
DTA (optional) formats. Optionally, it also downloads media files which are saved in an `outputfolder' subfolder named
'media'. For more information type {cmd:help sctoapi}.

{phang}
{opt sctomedia} creates copies of SurveyCTO media files in a specified folder with user-friendly names constructed from
values stored in your dataset. This includes images, audio, video and text media files. This command can also optionally
organize such files into a folder structure, also named using values stored in your data.
For more information type {cmd:help sctomedia}.

{phang}
{opt sctostreamcsv} reads sensor stream csv files and calculates statistics for each time period used when collecting the
sensor stream. This command can be used to see which part of the questionnaire was done in a context that was quiet, dark
etc. For more information type {cmd:help sctostreamcsv}.

{phang}
{opt sctostreamsum} reads sensor stream csv files and calculates statistics for each submission and saves them all in a .dta
file that can merged with the main survey data. This allows you to get all the features from the sensor_statistics field even
after the data collection as long as you used the sensor_stream field for the sensor you are interested in. For more
information type {cmd:help sctostreamsum}.

{marker license}{...}
{title:License}

{pstd}
The scto package is developed under Apache License 2.0.

{marker contact}{...}
{title:Main Contact}

{pstd}
SurveyCTO (support@surveycto.com)
{pstd}
