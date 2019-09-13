*! version 1.0 31JAN2019 SurveyCTO support@surveycto.com

cap program drop 	sctostreamsum
	program define 	sctostreamsum

qui {
	syntax , 								///
		/*required options*/				///
		mediafolder(string)					///
		outputfolder(string)				///
											///
		/*optional options*/ 				///
		[ 									///
		SENsors(string) 					///
		replace								///
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

	version 13.0

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
		noi di as error "{pstd}The {it:scto} package is not installed correctly. Type {inp:ssc install scto, replace} to reinstall the package, or go to {browse www.github.com/surveycto/scto:this package GitHub repository} for other options to re-install the package.{p_end}"
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

	*TODO: Make it possible to set by user
	local outputFilename  "sctostreamstats.dta"

	*******************************************
	*
	*	Test user input
	*
	*******************************************

	**************
	*This function test that the folders exist and that they are not the same
	sctotestfolder,	name1("mediafolder")  folder1("`mediafolder'") ///
					name2("outputfolder") folder2("`outputfolder'")


	*******************************************
	*
	*	Create a list of the sensors needed
	*
	*******************************************

	local valid_sensorPrefixes LL SL SP MV
	local sensors = trim(itrim(upper("`sensors'")))

	*Test that prefixes in the sensor option are all valid prefixes
	foreach sensorPrefix of local sensors {

		*Test if this prefix is valid
		if `:list sensorPrefix in valid_sensorPrefixes' == 0 {

			di as error "{phang}The sensor file prefix `sensorPrefix' used in sensors(`sensors') is not a valid sensor prefix. The valid prefixes are LL for light level, SL for sound level, SP for sound pitch and MV for movement.{p_end}"
			error 198
			exit

		}
	}

	*Add these sensor to whatever sensors added in the sensor() option
	if "`llbetween'" != ""							 local sensors "`sensors' LL"
	if "`slbetween'" != "" | "`quiet'" != ""		 local sensors "`sensors' SL"
	if "`spbetween'" != ""							 local sensors "`sensors' SP"
 	if "`mvbetween'" != "" | "`moving'`still'" != "" local sensors "`sensors' MV"

	** No stats options used. This would mean that the command does nothing, so it
	*  throws an error as that does not make sense for what this command is intended for.
	if "`sensors'" == "" {

		di as error "{phang}You must specify at least one statistic to be calculated or include at least one sensor in the option {inp:sensor{}}, otherwise there is no point of running this command. See the help file for possible stats options you can use.{p_end}"
		error 198
		exit
	}

	**Remove duplicates added from multiple options, for
	* example using both sensor(MV) and mvbetween()
	local sensors : list uniq sensors

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

			if "`sensorPrefix'" == "LL" local errorstring "the option llbetween()"
			if "`sensorPrefix'" == "SL" local errorstring "either of the options slbetween() or quiet"
			if "`sensorPrefix'" == "SP" local errorstring "the option spbetween()"
			if "`sensorPrefix'" == "MV" local errorstring "either of the options mvbetween(), still or moving"

			di as error "{phang}There are no files with the sensor prefix `sensorPrefix' in the outputfolder() and those file are needed when using `errorstring'.{p_end}"
			error 198
			exit
		}
	}

	*******************************************
	*
	*	Set up file to merge the different
	*	sensors to. Later to be appended to
	*	the main file
	*
	*******************************************

	tempfile fileToMergeTo

	**Create a local to tell which is the first
	* sensor loop as then there is no file to
	* merge to yet.
	local firstMerge = 1

	*******************************************
	*
	*	Set up the file to append rows to. Either
	*	from previously outputted file or start new
	*
	*******************************************

	tempfile fileToAppendTo

	*Test if the outputted mergefile already exist
	cap confirm file "`outputfolder'/`outputFilename'"

	*File exist and should not be replaces
	if !_rc & "`replace'" == "" {

		*The file exist and should not be replaced. New submissions should be added to the already existing file
		use "`outputfolder'/`outputFilename'"

		*Test that the merge file has the variable key needed to merge on
		cap confirm variable key
		if _rc {

			*There is no variable key. The data set must have been altered. The data set can be alatered as long as the key variable remains the same
			noi di as error `"{phang}The file [`outputFilename'] in the outputfolder(`outputfolder') folder was not generated by this command or was modified and do no longer have the variable {it:key}. This file can therefore not be used by the command. Use the option {inp:replace} to replace this file. When you replace the file this command re-reads all csv stream files and process them again."'
			error 693
			exit
		}

		*Save the merge file in a tempory file used to add new observations to
		save `fileToAppendTo'

		*List of all the keys already processed, keys in this local will be skipped
		levelsof key, local(already_processed_keys) clean
	}

	*The dta file either does not exist or should be replaced. So start from an empty file
	else {

		*Start from an empty file
		clear
		save `fileToAppendTo' , emptyok

		*There are no keys already in the data set, i.e. no keys will be skipped
		local already_processed_keys ""

	}

	*******************************************
	*
	*	Prepare and run the calculations for all files in each sensor
	*
	*******************************************

	foreach sensorPrefix of local sensors {

		*
		if "`sensorPrefix'" == "LL" local sensorName "Light Level"
		if "`sensorPrefix'" == "SL" local sensorName "Sound Level"
		if "`sensorPrefix'" == "SP" local sensorName "Sound Pitch"
		if "`sensorPrefix'" == "MV" local sensorName "Movement"

		noi di ""
		noi di "{pstd}Reading files in relation to `sensorName' (`sensorPrefix') files.{p_end}"


		*Create a tempfile to which the obs for this sensor stream
		*will be appended to. This file will then be merged to the
		*other sensor files, and then the merged file will be appended
		*to any observations previously saved to disk.
		clear
		tempfile sensorAppend`sensorPrefix'
		save `sensorAppend`sensorPrefix'', emptyok

		********************************
		* Prepare stats calculations
		* specific to this sensor stream

		*Create a lower case version of the prefix local
		local lowCase_prefix	= lower("`sensorPrefix'")

		*Initiate some locals to be used below
		local btwnnames ""
		local btwncount   0

		*Create a list of the standardized category options that will be used for this sensor
		local calcoptions "" //reset for each sensor
		*Sound level
		if "`sensorPrefix'" == "SL" & "`quiet'"  != "" local calcoptions "`calcoptions' quiet"
		*Movement
		if "`sensorPrefix'" == "MV" & "`still'"  != "" local calcoptions "`calcoptions' still"
		if "`sensorPrefix'" == "MV" & "`moving'" != "" local calcoptions "`calcoptions' moving"

		local btwnstr ""
		*If the between option is used for this prefix then
		if "``lowCase_prefix'between'" != "" {

			*Parse the string for this option and generate and test the new varname and the conditional equation based on the min and max values used
			parsebetween , prefix(`sensorPrefix') between_options("``lowCase_prefix'between'") usednames("`usednames'")

			*Store the number of categories
			local btwnstr 	"`r(btwn)'"

			*Store the btwn names to the calcoptions vars
			local btwnnames "`r(btwnnames)'"

			*Number of between var
			local btwncount `r(btwncount)'

			*Loop over all vars and create name and label locals
			forvalues btwnnum = 1/`btwncount' {
				local btwnname`btwnnum'		"`r(btwnname`btwnnum')'"
				local btwnlabels`btwnnum'	"`r(btwnlabels`btwnnum')'"
			}
		}

		*Combine these variables to one local as they will be used in the same way
		local catvars "`calcoptions' `btwnnames'"


		********************************
		* Loop over all files for this sensor_stream
		* and prepare the stats

		*Counter for showing progress in result window
		local counter 0

		*Loop over all files for this sensor
		foreach filecsv of local files`sensorPrefix' {

			*Output progress in result window
			local ++counter

			*Test that the file name is on expected format
			test_file_name , filename("`filecsv'")

			*Get file from file key. Do not process this csv file if this obs have already been processed
			local filekey = "uuid:" + substr("`filecsv'", 4,36)

			*Prepare output progress
			local filecount_output "File `counter' out of `count_files`sensorPrefix'' `sensorPrefix' files."

			*Test if file has already been outputted, and if so, if it should be replaced
			if (`:list filekey in already_processed_keys') {

				*Output progress report
				noi di "{pstd}`filecount_output' Observation already exists in .dta file and is therefore skipped.{p_end}"
			}
			else {

				*Output progress report
				noi di "{pstd}`filecount_output' Reading stream output and generate file in output folder.{p_end}"

				*Reads the csv file and adds the statistics
				sctocalculatestats, file("`mediafolder'/`filecsv'") btwnstr("`btwnstr'") dta `calcoptions'

				*Collapse to get similar stats as in sensor_statistics
				collapse 	(count)		`sensorPrefix'_period_obs	= count				///
							(sum) 		`sensorPrefix'_raw_obs		= count				///
							(min) 		`sensorPrefix'_min 			= min				///
							(max) 		`sensorPrefix'_max 			= max				///
							(sd) 		`sensorPrefix'_sd			= mean 				///
							(median)	`sensorPrefix'_median		= mean 				///
							(mean)  	`sensorPrefix'_mean			= mean				///
										`sensorPrefix'_period		= period			///
							`catvars' , by(key)

				*Label default vars
				label var `sensorPrefix'_mean 			"The mean of all time period means in `sensor_level`sensorPrefix''"
				label var `sensorPrefix'_period 		"The sensor streams observation length in `sensor_level`sensorPrefix''"
				label var `sensorPrefix'_period_obs 	"Number of time period observations for `sensor_level`sensorPrefix''"
				label var `sensorPrefix'_raw_obs 		"Number of raw recordings for `sensor_level`sensorPrefix''"
				label var `sensorPrefix'_min 			"The minimum of all time period means in `sensor_level`sensorPrefix''"
				label var `sensorPrefix'_max			"The maximum of all time period means in `sensor_level`sensorPrefix''"
				label var `sensorPrefix'_sd				"The standard deviation of all time period means in `sensor_level`sensorPrefix''"
				label var `sensorPrefix'_median			"The median of all time period means in `sensor_level`sensorPrefix''"

				*Label pct_categories vars
				if `:list posof "pct_quiet" in calcoptions'  label var pct_quiet 	"% (in decimals) of quiet time periods in `sensor_level`sensorPrefix''"
				if `:list posof "pct_still" in calcoptions'  label var pct_still 	"% (in decimals) of still time periods in `sensor_level`sensorPrefix''"
				if `:list posof "pct_moving" in calcoptions' label var pct_moving 	"% (in decimals) of moving time periods in `sensor_level`sensorPrefix''"

				*Loop over each between var and label them. If no between vars, then btwncount is 0.
				forvalues btwnnum = 1/`btwncount' {
					label variable `btwnname`btwnnum'' "`btwnlabels`btwnnum''"
				}

				*Set variable order
				order key `sensorPrefix'_period `sensorPrefix'_mean

				*Append this observation for the tempfile for this stream
				append using `sensorAppend`sensorPrefix''
				save `sensorAppend`sensorPrefix'', replace
			}
		}

		********************************
		* If there are any observations
		* processed, then add them to the
		* the data set


		if _N > 0 {

			********************************
			* First check if there are multiple time periods for this
			* sensor, if there are more than one, then suffix _p1, _p5
			* etc. where the number is the period lenght in seconds.

			*Test if key is unique. It is only unique if there is only one period
			*duration per observations. Not that one dureation for half the sample
			*and another duration for the other half if ok.
			cap isid key
			if _rc { //key is not unique

				*Get a local of all period lenghts used
				levelsof `sensorPrefix'_period , local("periods")

				ds key, not
				local periodvars `r(varlist)'

				*Loop over each period
				foreach period of local periods {
					preserve

						*Keep only observations for this period
						keep if `sensorPrefix'_period == `period'

						*loop over all variables to be renamed
						foreach var of local periodvars {

							*suffix _p + the perdiod to all varnames
							rename `var' `var'_p`period'
						}

						*Save these observations in a tempfile and crete a list of these tempfiles
						tempfile thismergefile
						save 	`thismergefile'
						local mergefiles `mergefiles' `thismergefile'

					restore
				}

				*Prepare to merge back all observations.
				keep key 						//keep only the var key
				bysort key: keep if _n == 1		//keep only one of each observations

				*Loop over the list of tempfiles and merge them back to main dat set where key is now unique
				foreach mergefile of local mergefiles {
					merge 1:1 key using `mergefile', nogen
				}
			}

			********************************
			* Now when the key is unique in the data set and no
			* matter how many periods there was per sensor for
			* any observation, there is now only one row per
			* submission. Merge this sensor to the other sensors.

			*Merging this sensor to other sensors
			if `firstMerge' == 1 {

				*If this was the first sensor in the sensor
				*loop create file for the first time, then
				*update local so it is not done again
				save `fileToMergeTo'
				local firstMerge = 0

			}
			else {

				*Merge the sensor of this sensor loop to
				*the already processed sensors.
				merge 1:1 key using `fileToMergeTo', nogen
				save `fileToMergeTo', replace
			}
		}
	}


	*******************************************
	*
	*	Save data to disk
	*
	*******************************************

	*Test if there were any new observations.
	if `firstMerge' == 1 {

		noi di ""
		noi di "{phang}Command ran successfully but all observations are already in the .dta file was found, so no new observations added to the data set.{p_end}"

		use `fileToAppendTo', clear
	}
	else {

		*Output result of command
		count
		noi di ""
		noi di "{phang}Command ran successfully and `r(N)' new observations not already in the .dta file were found and were added to the data set: `outputfolder'/`outputFilename'.{p_end}"

		* Append to the data set already on disk. This
		* tempfile is empty if there were no file on disk already.
		append using `fileToAppendTo'

		*Label key variable
		label variable key "Uniqe submission ID key string to use to merge with respondent data"

		*Save file size if possible
		compress

		*Save merge file
		save "`outputfolder'/`outputFilename'", replace

	}
}
end
