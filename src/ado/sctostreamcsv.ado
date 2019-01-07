
cap program drop 	sctostreamcsv
	program define 	sctostreamcsv

qui {
	syntax , 								///
		/*required options*/				///
		mediafolder(string)					///
		outputfolder(string)				///
											///
		/*optional options*/ 				///
		[ 									///
		replace								///
		keyvar								///
											///
		/*pct_categories equivalences*/		///
		quiet								///
		still								///
		moving								///
											///
		/*pct_between equivalences*/		///
		LLBETween(string)					///
		SLBETween(string)					///
		SPBETween(string)					///
		MVBETween(string)					///
		]

	//noi di "syntax ok"
	pause on

	preserve
	clear

	*******************************************
	*
	*	Import SCTO functions
	*
	*	This section emulates what the import
	*	command does in f.ex. javascrip, python etc.
	*
	*******************************************

	*This segment of code imports the utility functions for these commands
	capture findfile sctofunctions.do
	if (_rc == 0) {
		*If file is found, run it to load all functions in memory
		run "`r(fn)'"
	}
	else {
		*File does not exist
		noi di as error "Reinstall package"
		// Say that the package should be re-installed using ssc intall sctotools
		error 198
		exit
	}

	*******************************************
	*
	*	Prepare locals used in command
	*
	*******************************************

	*The list of expected variables each sensor_stream data set
	local expected_varlist second count mean min max sd fieldname

	*List of names that are taken, it will be updated throughout the command as names are taken
	local usednames `expected_varlist'

	*******************************************
	*
	*	Test user input
	*
	*******************************************

	**************
	*This function test that the folders exist and that they are not the same folder
	sctotestfolder,	name1("mediafolder")  folder1("`mediafolder'") ///
					name2("outputfolder") folder2("`outputfolder'")


	*******************************************
	*
	*	Create a list of the sensors needed
	*
	*******************************************

	if "`llbetween'" != ""							 local sensors "`sensors' LL"
	if "`slbetween'" != "" | "`quiet'" != ""		 local sensors "`sensors' SL"
	if "`spbetween'" != ""							 local sensors "`sensors' SP"
 	if "`mvbetween'" != "" | "`moving'`still'" != "" local sensors "`sensors' MV"

	** No stats options used. This would mean that the command does nothing, so it
	*  throws an error as that does not make sense for what this command is intended for.
	if "`sensors'" == "" {

		di as error "{phang}At least one stats option must be used. See the help file for possible stats options you can use.{p_end}"
		error 198
		exit
	}


	*******************************************
	*
	*	Create list of files required for the sensors used
	*
	*******************************************


	*List all outputted files for each sensor_stream
	foreach sensorPrefix of local sensors {

		*List all files with this prefix in the media folder
		local files`sensorPrefix' : dir "`mediafolder'" files "`sensorPrefix'_*.csv" , respectcase

		*Local that counts the number of with this prefix
		local count_files`sensorPrefix' : list sizeof files`sensorPrefix'

		*Throw error if no files exist for the stream requred given stats options specified
		if `count_files`sensorPrefix'' == 0 {

			if "`sensorPrefix'" == LL local errorstring "the option llbetween()"
			if "`sensorPrefix'" == LL local errorstring "either of the options slbetween() or quiet"
			if "`sensorPrefix'" == SP local errorstring "the option spbetween()"
			if "`sensorPrefix'" == MV local errorstring "either of the options mvbetween(), still or moving"

			di as error "{phang}There are no files with the sensor prefix `sensorPrefix' in the outputfolder() and those file are needed when using `errorstring'.{p_end}"
			error 198
			exit
		}
	}

	*******************************************
	*
	*	Prepare and run the calculations for all files in each sensor
	*
	*******************************************

	foreach sensorPrefix of local sensors {

		********************************
		* Prepare stats calculations
		* specific to this sensor stream

		*Create a lower case version of the prefix local
		local lowCase_prefix	= lower("`sensorPrefix'")

		*Make a local with which standardized category options that were used
		if "`sensorPrefix'" == "SL" & "`quiet'"  != "" local calcoptions "`calcoptions' quiet"
		if "`sensorPrefix'" == "MV" & "`still'"  != "" local calcoptions "`calcoptions' still"
		if "`sensorPrefix'" == "MV" & "`moving'" != "" local calcoptions "`calcoptions' moving"

		local btwnstr ""
		*If the between option is used for this prefix then
		if "``lowCase_prefix'between'" != "" {

			*Parse the string for this option and generate and test the new varname and the conditional equation based on the min and max values used
			parsebetween , prefix(`lowCase_prefix') between_options("``lowCase_prefix'between'") usednames("`usednames'")

			*Store the number of categories
			local btwnstr 	"`r(btwn`count')'"
		}


		********************************
		* Loop over all files for this sensor_stream
		* and prepare the stats

		*List of all files already outputted for this Sensor. Used to speed up re-running this command as data comes in
		local outcvs`sensorPrefix' : dir "`outputfolder'" files "`sensorPrefix'_*.csv" , respectcase

		*Counter for showing progress in result window
		local counter 0

		*Loop over all files
		foreach filecsv of local files`sensorPrefix' {

			*Output progress in result window
			local ++counter


			*Test if file has already been outputted, and if so, if it should be replaced
			if (`:list filecsv in outcvs`sensorPrefix'' & "`replace'" == "") {

				noi di "{pstd}File `counter' out of `count_files`sensorPrefix'' `sensorPrefix' files already exist and is skipped.{p_end}"
			}
			else {

				noi di "{pstd}Reading file `counter' out of `count_files`sensorPrefix'' `sensorPrefix' files.{p_end}"

				*Reads the csv file and adds the statistics
				sctocalculatestats, file("`mediafolder'/`filecsv'") btwnstr("`btwnstr'") csv `keyvar' `calcoptions'

				*Outsheet the csv file with the newly calculated stats
				outsheet using "`outputfolder'/`filecsv'", replace

				noi di "{pmore}Sensor statistics calculations were added to file `filecsv' which was then saved to the outputfolder().{p_end}"

			}
		}
	}

	restore
}

end
