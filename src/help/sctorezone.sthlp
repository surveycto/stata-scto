{smcl}
{* *! version 1.0 13APR2020, developed by William Blackmon (wblackmon@poverty-action.org)}{...}
{hline}
help for {hi:sctorezone}
{hline}
{title:Title}

{phang}
{cmd:sctorezone} {hline 2} shifts time zones of SurveyCTO {it:time} and {it:datetime} 
fields.

{marker syntax}{...}

{title:Syntax}

{p 8 10 2}
{cmd:sctorezone} 
shift {ifin}
{cmd:, force} [{opth o:nly(varlist)} | {opth e:xclude(varlist)}]

{pstd}
where {it:shift} indicates how to shift the {it:time/datetime} variables. {it:shift}
can be formatted for {it:manual} or {it:automatic} re-zoning:

{pstd}
{bf:      - Manual:} set the number of hours to shift {it:time/datetime} variables 
forwards (if you download west of data collection) or backwards (if you download
east of data collection). Use the format: plus/minus sign number, for example
{it:ctorezone +4, force} or {it:ctorezone -3, force}.

{pstd}
{bf:      - Automatic:} You can set up automatic time zone shifting if you 
include a calculate field in your SurveyCTO form with this expression: 
{it: format-date-time(${starttime}, '%Y-%b-%e %H:%M:%S')}. This creates a string
version of the {it:starttime} variable which will not be shifted to the 
downloader's time zone during export. If you included this calculate field, 
include its name here, for example {it:ctorezone starttime_string}. This will 
automatically shift all {it:time/datetime} variables based on the difference between
the {it:starttime} variable (which is exported in the downloader's time zone) 
and the string version of starttime (which is exported in the collector's time 
zone). This option works best if the data collection or downloading takes 
place in more than one time zone. 


{* Using -help bcstats- as a template.}{...}
{synoptset 23 tabbed}{...}
{synopthdr}
{synoptline}
{p2coldent:* {opth o:nly(varlist)}}shift time zone {opt only()} for these variables
{p_end}
{p2coldent:* {opth e:xclude(varlist)}}shift time zone for all {it:time/datetime} 
variables {opt except} for these variables{p_end}
{p2coldent:* {bf:force}}the {it:force} option is required as a reminder that 
data in {it:time} and {it:datetime} variables will be overwritten{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}The {bf:force} option is required. Either {opt only()} or 
{opt exclude()} may be included, or neither.{p_end}

{marker description}{...}
{title:Description}

{pstd}
SurveyCTO exports {it:time} and {it:datetime} fields relative to the
{browse "https://docs.surveycto.com/05-exporting-and-publishing-data/01-overview/09.data-format.html":
time zone of the exporting computer – not the time zone of the data-collection device}.
{cmd:sctorezone} is a great tool to shift these fields back to the time zone where
the data was collected. This command changes the time zones for {it:datetime} fields formatted
according to the SurveyCTO .do file template, i.e., in %tc format, and
{it:time} fields using SurveyCTO standard format (e.g. "12:34:56 PM"). Unless 
the {it: only} or {it:exclude} option is specified, all variables in %tc format 
and all string variables following SurveyCTO's standard time format will be 
shifted.

{marker options}{...}
{title:Options}

{phang}
{bf: force} is required as a reminder that data in {it:time} and {it:datetime} variables 
will be overwritten.

{phang}
{opth o:nly(varlist)} specifies that the time zone should only be shifted for 
the included {it:varlist}. If {it:only} is specified,
{it:exclude} cannot be specified. If neither are specified, all {it:time} and 
{it:datetime} variables will be shifted.

{phang}
{opth e:xclude(varlist)} specifies that the time zone should only be shifted for 
all {it:time} and {it:datetime} variables except those included in the
included {it:varlist}. If {it:exclude} is specified, 
{it:only} cannot be specified. If neither are specified, all {it:time} and {it:datetime}
variables will be shifted.

{marker examples}{...}
{title:Examples}

{pstd}{cmd: Example 1}{p_end}
{pstd}{cmd:sctorezone} +3, only(starttime) force

{pstd}In this example, sctorezone manually shifts ({opt only}) the variable {it:starttime} forward three hours.

    {hline}
{pstd}{cmd: Example 2}{p_end}
{pstd}{cmd:sctorezone} starttime_str, force

{pstd}In this example, sctorezone automatically shift times of all {it:datetime/time}
variables according to the string variable {it:starttime_str}, which is a SurveyCTO
calculate field with the following calculation expression:
{it: format-date-time(${starttime}, '%Y-%b-%e %H:%M:%S')}.

{marker author}{...}
{title:Author}

{phang}
This command was developed by William Blackmon (wblackmon@poverty-action.org), Research Manager at IPA. You
can see this command's repository on {browse www.github.com/surveycto/stata-scto:Github}.{p_end}
{phang}
