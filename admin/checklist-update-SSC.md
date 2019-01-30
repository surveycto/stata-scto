# Checklist for submitting new versions to SSC

*Copy the list below to an issue when starting the process of publishing a new version of ietoolkit*

- [ ] 1. **Merge to *develop*** - Merge all branches with the changes that should be included in the new version first to the `master` branch.
- [ ] 2. **Update version and date** - Update the version number and date in all ado-files and all dates in all help files. See section below for details.
- [ ] 3. **Create a .zip file** - Create a .zip file with all ado-files and help files in the **ado** and **help**. Do not include the folders, just the files in those folders.
- [ ] 4. **Email Prof. Baum** - Email the .zip file to kit.baum@bc.edu.
    - If any commands are added or deleted, make note of that in the email.
    - If any meta information needs to be updated, include it according to the instructions here in that email.
- [ ] 5. **Draft release note** - Go to the [release notes](https://github.com/kbjarkefur/scto/releases) and draft a new release note for the new version. Link to the issues [issues](https://github.com/kbjarkefur/scto/issues) solved in this release.
- [ ] 6. **Wait for publication confirmation** - Do not proceed pass this step until Prof. Baum has confirmed that the new version is uploaded to the servers.
- [ ] 7. **Publish release note** - Once the new version is up on SSC, publish the release note.
- [ ] 8. **Close issues** - Close the issues which fix is now published on the SSC server.

### Version number and dates in ado-files and help files.

The version number is on the format `number.number` where the first number is incremented if it is a major release. If the first number is incremented the second number is reset to 0. If it is not a major release, then the first number is left unchanged and the second number is incremented.

Version number and date in ado-file. Change both version number and date. Make sure that this line is the very first line in the ado-file.
```
*! version 1.0 31JAN2019  SurveyCTO sales@surveycto.com

	capture program drop sctostreamsum
	program sctostreamsum
```

Date at the top of the help file. Change only the date, there is no version number in the help file.
```
{smcl}
{* 31 Jan 2019}{...}
{hline}
help for {hi:sctostreamsum}
{hline}
```
