{smcl}
{* 4 December 2019}{...}
{hline}
help for {hi:sctoapi}
{hline}

{title:Title}

{p 8 15 2}
{bf:sctoapi} {hline 2} downloads SurveyCTO data via API

{marker syntax}{...}
{title:Syntax}

{p 8 15 2}
{cmd:sctoapi} {it:formids} {help if:[if]} {help in:[in]}, {cmd:server}({it:servername}) {cmdab:user:name}({it:username})
{cmdab:pass:word}({it:password}) {cmd:date}({it:unixtimestamp}) {cmdab:output:folder}({it:folder_path})
[{cmd:key}({it:file_path})] [{cmd:media}({it:varlist})] [dtafile]

{pstd}
Alternatively, type {it:db sctoapi} to run the command via a dialog box or click {dialog sctoapi:here}.


{synoptset 25}{...}
{synopthdr}
{synoptline}
{synopt :{opt server(servername)}} Specifies the SurveyCTO Server name.{p_end}
{synopt :{opt user:name(username)}} Specifies the SurveyCTO Username.{p_end}
{synopt :{opt pass:word(password)}} Specifies the SurveyCTO password.{p_end}
{synopt :{opt date(unixtimestamp)}} Specifies the date (UTC time) from which data collected will be downloaded. It can be
a timestamp in seconds or milliseconds.{p_end}
{synopt :{opt output:folder(folder_path)}} Destination folder of export files.{p_end}
{synopt :{opt key(file_path)}} Specifies the file of the Private Key. [For
{browse "https://docs.surveycto.com/02-designing-forms/02-additional-topics/06.encrypting.html":encrypted forms}] {p_end}
{synopt :{opt media(varlist)}} Specifies the media variables to export.{p_end}
{synopt :{opt dtafile}} If specified, a .dta file will be generated and saved in the Destination folder.{p_end}
{synoptline}
{p2colreset}{...}


{marker description}{...}
{title:Description}

{pstd}
{cmd:sctoapi} downloads SurveyCTO data in JSON format
via the {browse "https://support.surveycto.com/hc/en-us/articles/360033156894-REST-API-documentation":API}
(you'll need a SurveyCTO account to see the content of the link). The data is then converted and saved
in CSV and DTA (optional) format. Optionally, it also downloads media files which are saved in
an `outputfolder' subfolder named 'media' - you'll then be able to run the {help sctomedia:sctomedia} command
to rename and relocate your media files, if needed. For a more user-friendly way to run the sctoapi command, and
to ensure that the password is hidden and not saved in any log, you can use the dialog box for the
command (type {it:db sctoapi} or click {dialog sctoapi:here}).

{marker options}{...}
{title:Options}

{phang}
{opt server(servername)} specifies the name of the SurveyCTO server where the form data is stored.

{phang}
{opt user:name(username)} specifies a username with permission to download data from the SurveyCTO server specified.

{phang}
{opt pass:word(password)} specifies the password of the username.

{phang}
{opt date(unixtimestamp)} specifies the date parameter of the request. It should be specified in UTC time and can follow
one of the following formats: 1) A timestamp in seconds (e.g. 1444694400), 2) A timestamp in milliseconds (the value is
treated in milliseconds when 13 (or more) digits are specified - e.g. 1444694400000). 3) A specific string
representation (e.g. Oct%2013%2C%202015%2000%3A00%3A00%20AM). Convert your dates into unix time stamps with an
{browse www.unixtimestamp.com/:online converter} or bypass and request all data by specifying 0, but be mindful
of the rate limiting. For more information, visit
our {browse "https://support.surveycto.com/hc/en-us/articles/360033156894-REST-API-documentation":API documentation}
(you'll need a SurveyCTO account to see the content of the link).

{phang}
{opt output:folder(folder_path)} specifies the main destination folder path. If media is specified, media files will be saved
in the sub-folder 'media' within the output folder.

{phang}
{opt key(file_path)} specifies the file path of the Private Key. This is only required
for {browse docs.surveycto.com/02-designing-forms/02-additional-topics/06.encrypting.html:encrypted forms}.

{phang}
{opt media(varlist)} specifies the SurveyCTO form media fields you want to download and save
in "`outputfolder'/media", including
{browse "https://docs.surveycto.com/02-designing-forms/01-core-concepts/03ze.field-types-audio-audit.html":audio audits},
{browse "https://docs.surveycto.com/02-designing-forms/01-core-concepts/03zd.field-types-text-audit.html":text audits},
{browse "https://docs.surveycto.com/02-designing-forms/01-core-concepts/03m.field-types-image.html":images},
{browse "https://docs.surveycto.com/02-designing-forms/01-core-concepts/03n.field-types-audio.html":audio},
and {browse "https://docs.surveycto.com/02-designing-forms/01-core-concepts/03o.field-types-video.html":video}.

{phang}
{opt dtafile} saves a .dta file in the output folder, if specified.

{marker examples}{...}
{title:Examples}

{pstd}Note that only Users with permission to 'Download Form data' will be able to run this command successfully.{p_end}

{pstd}All Examples will use the following local as folder path:{p_end}
{phang2}{cmd:. local} destination "C:/Users/username/Documents"{p_end}

   {hline}
{pstd}{cmd: Example 1}{p_end}

{pstd}{cmd:sctoapi} testform, server(scto) username(support@surveycto.com) password(1234) date(1546344000) output(`destination')

{pstd}In this example, the sctoapi command is being run to download the data from the form with ID 'testform', deployed in
the server 'scto'. We're using the credentials of the user 'support@surveycto.com' with password '1234'. This code
will trigger the following actions:{p_end}
{phang2}{cmd:.} Fetch testform data submitted after Jan 1, 2019 in WIDE format{p_end}
{phang2}{cmd:.} Save the data in `destination' in JSON and CSV format{p_end}

   {hline}
{pstd}{cmd: Example 2}{p_end}

{pstd}{cmd:sctoapi} testform, server(scto) username(support@surveycto.com) password(1234) date(1546344000) output(`destination') media(textaudit) dtafile

{pstd}In this example, the sctoapi command is being run to download the data from the form with ID 'testform', deployed
in the server 'scto'. We're using the credentials of the user 'support@surveycto.com' with password '1234'. This code
will trigger the following actions:{p_end}
{phang2}{cmd:.} Fetch testform data submitted after Jan 1, 2019 in WIDE format{p_end}
{phang2}{cmd:.} Save the data in `destination' in JSON, CSV and DTA format{p_end}
{phang2}{cmd:.} Fetch media files collected in the field named 'textaudit' and save them in `destination'/media{p_end}

   {hline}
{pstd}{cmd: Example 3}{p_end}

{pstd}{cmd:sctoapi} encrypted_form, server(scto) username(support@surveycto.com) password(1234)
date(1546344000) output(`destination') key(C:\Users\username\Downloads\Encrypted_Form_PRIVATEDONOTSHARE.pem)

{pstd}In this example, the sctoapi command is being run to download the data from the form with ID 'encrypted_form', deployed
in the server 'scto'. We're using the credentials of the user 'support@surveycto.com' with password '1234'. This code
will trigger the following actions:{p_end}
{phang2}{cmd:.} Fetch encrypted_form data submitted after Jan 1, 2019 in WIDE format{p_end}
{phang2}{cmd:.} Decrypt encrypted_form data using the private key saved in the
file "C:\Users\username\Downloads\Encrypted_Form_PRIVATEDONOTSHARE.pem".{p_end}
{phang2}{cmd:.} Save the data in `destination' in JSON and CSV format{p_end}

    {hline}
{marker author}{...}
{title:Author}

{phang}
This command is the {browse www.surveycto.com:SurveyCTO} version of a pre-existing resource for Stata users created by Innovations
for Poverty Action (IPA). Both resources achieve the same aims, but this version has been tailored for more general use, compared
to the specific requirements of IPA projects. You can see this command's repository
on {browse www.github.com/surveycto/stata-scto:Github}.{p_end}
{phang}
