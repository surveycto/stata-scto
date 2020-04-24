{smcl}
{* *! version 2.0 24APR2020, developed by William Blackmon (wblackmon@poverty-action.org)}{...}
{hline}
help for {hi:sctorezone}
{hline}
{title:Title}

{phang}
{cmd:sctorezone} {hline 2} shifts time zones of SurveyCTO {it:datetime} and {it:time}
fields.

{marker syntax}{...}

{title:Syntax}

{p 8 10 2}
{cmd:sctorezone} 
shift {ifin}
{cmd:, force} [{opth o:nly(varlist)} | {opth e:xclude(varlist)}]

{pstd}
The {it:shift} parameters indicates how much to shift your {it:datetime} and/or {it:time} fields.
Shift can be formatted for {cmd:manual} or {cmd:automatic} re-zoning:

{pstd}
{bf:      - Manual:} set the number of hours to shift {it:datetime} and {it:time}
variables forwards ({cmd:+}) or backwards ({cmd:-}). For example, {it:sctorezone +5.5, force}
or {it:sctorezone -3, force}.

{pstd}
{bf:      - Automatic:} include a {browse "https://docs.surveycto.com/02-designing-forms/01-core-concepts/03zb.field-types-calculate.html":{it:calculate} field}
in your form design that calculates
the data collector’s time zone at the start time of the survey: {it:format-date-time(${starttime}, '%Y-%b-%e %H:%M:%S')}.
When exporting data, this field won’t be shifted because all {it:calculate} fields are considered strings or numbers,
not {it:datetime} or {it:time} fields,
regardless of their content. You can then use this {it:calculate} field in the command to shift all {it:datetime} and {it:time}
fields to the same time zone of the data collector’s device, e.g., {it:sctorezone starttime_calculate, force}.
This command will calculate the difference between the exported {it:starttime} and {it:starttime_calculate} fields,
and shift time zones accordingly.

{* Using -help bcstats- as a template.}{...}
{synoptset 23 tabbed}{...}
{synopthdr}
{synoptline}
{p2coldent:* {opth o:nly(varlist)}}shift time zone {opt only()} for these variables.{p_end}
{p2coldent:* {opth e:xclude(varlist)}}shift time zone for all {it:datetime} and {it:time}
variables, {opt except} for these variables.{p_end}
{p2coldent:* {bf:force}}the {it:force} option is required as a reminder that 
data in {it:time} and {it:datetime} variables will be overwritten.{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}The {bf:force} option is required. Either {opt only()} or 
{opt exclude()} may be included, or neither.{p_end}

{marker description}{...}
{title:Description}

{pstd}
SurveyCTO exports {it:datetime} and {it:time} fields relative to the
{browse "https://docs.surveycto.com/05-exporting-and-publishing-data/01-overview/09.data-format.html": time zone of the exporting computer},
not the time zone of the data-collection device. {cmd:sctorezone} is a great tool
to shift these fields back to the time zone where the data was collected. This command
changes the time zones of {it:datetime} fields formatted according to the
{browse "https://docs.surveycto.com/05-exporting-and-publishing-data/01-overview/11.using-stata.html":SurveyCTO .do file template},
i.e., in %tc format, and {it:time} fields using SurveyCTO standard format (e.g. "12:34:56 PM").
Unless the {it: only} or {it:exclude} option is specified, all variables in %tc format 
and all string variables following SurveyCTO's standard time format will be 
shifted.

{marker options}{...}
{title:Options}

{phang}
{bf: force} is required as a reminder that data in {it:time} and {it:datetime} variables 
will be overwritten.

{phang}
{opth o:nly(varlist)} specifies that the time zone should only be shifted for
{it:datetime} and {it:time} variables included in the {it:varlist}.

{phang}
{opth e:xclude(varlist)} specifies that the time zone should be shifted for 
all {it:datetime} and {it:time} variables except for those included in the {it:varlist}.

{pstd}
If {it:only} is specified, {it:exclude} cannot be specified. If neither are specified,
all {it:time} and {it:datetime} variables will be shifted.

{marker examples}{...}
{title:Examples}

{pstd}{cmd: Example 1}{p_end}
{pstd}{cmd:sctorezone} -3, only(starttime) force

{pstd}In this example, sctorezone manually shifts ({opt only}) the variable {it:starttime} backward three hours.

    {hline}
{pstd}{cmd: Example 2}{p_end}
{pstd}{cmd:sctorezone} +5.5, exclude(timefield) force

{pstd}In this example, sctorezone manually shifts ({opt only}) all {it:datetime} and {it:time} variables forward five and a half hours,
{opt excluding} the variable named "timefield".

    {hline}
{pstd}{cmd: Example 3}{p_end}
{pstd}{cmd:sctorezone} starttime_calculate, force

{pstd}In this example, sctorezone automatically shift times of all {it:datetime} and {it:time}
variables according to the string variable {it:starttime_calculate}, which is a SurveyCTO
calculate field with the following calculation expression:
{it: format-date-time(${starttime}, '%Y-%b-%e %H:%M:%S')}.

{marker author}{...}
{title:Author}

{phang}
This command was developed by William Blackmon (wblackmon@poverty-action.org), Research Manager at IPA. You
can see this command's repository on {browse www.github.com/surveycto/stata-scto:Github}.{p_end}
{phang}
