
	clear all
	set trac off

	* List of users
	if c(username) == "kbrkb" {
		global scto_repo "C:\Users\kbrkb\Documents\GitHub\scto"
		global outfolder "C:\Users\kbrkb\OneDrive\Documents\Work\SurveyCTO\scto_package\test_outputs"
	}

	**Copy these lines of code and paste it above in the list of users. To get
	* the value to put in the first "" type - di c(username) - in Stata.
	if c(username) == "" {
		global scto_repo "" //path to where the repo is cloned
		global outfolder "" //path to output folder.
	}
	
	**Install the command. See https://github.com/surveycto/scto for 
	* methods to install unreleased versions of this command
	ssc install scto
	
	*folder globals
	global ado 			"$scto_repo/src/ado"
	global testfolder  	"$scto_repo/testfiles"
	
	*Create the folders needed in the output folder if they do not already exist
	foreach datafolder in data_1 data_2 data_3 data_4 {
		mata : st_numscalar("r(dirExist)", direxists("${outfolder}/`datafolder'"))
		if `r(dirExist)' == 0 {
		    mkdir "${outfolder}/`datafolder'"
		}
	}
	
	*Use locals to enable/disable which tests to run.
	local run_data_1 1
	local run_data_2 1
	local run_data_3 1
	local run_data_4 1
	
***************************************

if `run_data_1' == 1 {

	*Run tests on data 1.
	local data data_1

	*Run the command. Comment in the options.
	sctostreamsum , 	mediafolder("${testfolder}/`data'/media")  ///
						outputfolder("${outfolder}/`data'")	 ///
						llbetween(lightbetween[100 1000])  ///
						sensors("SL sp MV") replace


	*Run the command. Comment in the options.
	sctostreamcsv , 	mediafolder("${testfolder}/`data'/media")  ///
						outputfolder("${outfolder}/`data'")	 ///
						llbetween(lightbetween[100 1000])
						
}

***************************************

if `run_data_2' == 1 {

	*Run tests on data 2.
	local data data_2

	*This data set has two time periods for sound pitch. 1 second and 10 seconds

	*Run the command. Comment in the options.
	sctostreamsum , 	mediafolder("${testfolder}/`data'/media")  ///
						outputfolder("${outfolder}/`data'")	 ///
						llbetween(lightbetween[100 1000])  ///
						sensors("SL sp MV")


	*Run the command. Comment in the options.
	sctostreamcsv , 	mediafolder("${testfolder}/`data'/media")  ///
						outputfolder("${outfolder}/`data'")	 ///
						spbetween(highpitch[100 ?])
						
}

***************************************

if `run_data_3' == 1 {

	*Run tests on data 3.
	local data data_3

	*This data set has two time periods for sound pitch. 1 second and 10 seconds
	*This data does not have all stream files for all observations. Not all has MV sensors, not all has both 1 sec and 10 sec etc.

	*Run the command. Comment in the options.
	sctostreamsum , 	mediafolder("${testfolder}/`data'/media")  ///
						outputfolder("${outfolder}/`data'")	 ///
						llbetween(lightbetween[100 1000])  ///
						sensors("SL sp MV")


	*Run the command. Comment in the options.
	sctostreamcsv , 	mediafolder("${testfolder}/`data'/media")  ///
						outputfolder("${outfolder}/`data'")	 ///
						spbetween(highpitch[100 ?])
						
}

***************************************

if `run_data_4' == 1 {

	*Run tests on data 4.
	local data data_4

	*This data set has two time periods for sound pitch. 1 second and 10 seconds
	*This data does not have all stream files for all observations. Not all has MV sensors, not all has both 1 sec and 10 sec etc.

	**********************************************
	** THESE FILES ARE EXPECTED TO RUN INTO ERRORS
	**********************************************	
	
	*Run the command. Comment in the options.
	sctostreamsum , 	mediafolder("${testfolder}/`data'/media")  ///
						outputfolder("${outfolder}/`data'")	 ///
						spbetween(highpitch[100 ?]) replace


	*Run the command. Comment in the options.
	sctostreamcsv , 	mediafolder("${testfolder}/`data'/media")  ///
						outputfolder("${outfolder}/`data'")	 ///
						spbetween(highpitch[100 ?]) replace

}
