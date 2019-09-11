

/********************************************************************************

	These are functions used across SCTO commands in the sctotools package


********************************************************************************/


**Funtion to test that a folder exist. If two folders are passed as arguments, then
* both are tested that they exist, in addition to testing that they are not the same folder.
cap program drop 	sctotestfolder
	program define 	sctotestfolder

	syntax , ///
		folder1(string)  /// The folder path
		name1(string) 	 /// The folder name to be used in the error message
		[folder2(string) name2(string)] // Same as above but for optional second folder

	di "sctotestfolder syntax ok"

	*Set number of folders in syntax
	local numFolds 1
	if "`folder1'" != "" local numFolds 2

	*Test that each folder exist
	forvalues fNum = 1/`numFolds' {

		*Forward and back slash means the same but are not the same in string comparison
		local folder`fNum'	= subinstr("`folder`fNum''" , "\", "/", .)

		*Test that the folder exists
		mata : st_numscalar("r(dirExist)", direxists("`folder`fNum''"))
		if `r(dirExist)' == 0 {

			noi di as error `"{phang}The folder in `name`fNum''(`folder`fNum'') does not exist. You must enter the full path. For example, on most Windows computers it starts with {it:C:} and on most Mac computers with {it:/user/}.{p_end}"'
			error 693
			exit
		}
	}

	*If two folders specified, thest that they are not the same
	if `numFolds' == 2 & trim(lower("`folder1'")) == trim(lower("`folder2'")) {

		di as error "{phang}The `name1'(`folder1') folder may not be the same folder as the `name2'(`folder2') folder.{p_end}"
		error 198
		exit
	}

end



cap program drop 	test_file_name
	program define 	test_file_name, rclass

	qui {
		syntax, filename(string)

		if (regexm("`filename'","[A-Z][A-Z]_[a-z0-9][a-z0-9][a-z0-9][a-z0-9][a-z0-9][a-z0-9][a-z0-9][a-z0-9]-[a-z0-9][a-z0-9][a-z0-9][a-z0-9]-[a-z0-9][a-z0-9][a-z0-9][a-z0-9]-[a-z0-9][a-z0-9][a-z0-9][a-z0-9]-[a-z0-9][a-z0-9][a-z0-9][a-z0-9][a-z0-9][a-z0-9][a-z0-9][a-z0-9][a-z0-9][a-z0-9][a-z0-9][a-z0-9]_PERIOD_[a-z0-9]+.csv") != 1) {

			noi di as error `"{phang}The file name [`filename'] is not on the expected format. the format SurveyCTO's server gives to these filem names are [XX_xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx_PERIOD_0+.csv] where X is any upper case letter, x is any lower case letter or any digit, and 0+ any number of digitis.{p_end}"'
			error 693
			exit
		}
	}

end

cap program drop 	sctocalculatestats
	program define 	sctocalculatestats, rclass

		syntax, file(string) [ btwnstr(string) quiet still moving dta csv keyvar]

			noi di "sctocalculatestats syntax ok!"

			*Import file data
			import delimited "`file'", clear

			*Test that the sensor stream file is on acceptable format
			test_data_format, filename("`file'")

			*The list of expected variables each sensor_stream data set
			local expected_varlist second count mean min max sd fieldname

			*Test that the file has all the variables expected
			cap confirm variable `expected_varlist'
			if _rc {

				noi di as error "{phang}The file `filecsv' does not have all of the variables [`expected_varlist'] that are expected in a sensor_stream output file.p_end}"
				error 198
				exit
			}

			*Reversed file name (this is a work around to allow code to work Stata versions <14)
			local fileReverse = strreverse("`file'")
			local forwSlsh = strpos("`fileReverse'","/")
			local backSlsh = strpos("`fileReverse'","\")

			*If only one type of slash used the other is zero and will make
			*the min() function incorrectly pick the 0 index in next step
			if `backSlsh' == 0 local backSlsh = `forwSlsh'
			if `forwSlsh' == 0 local forwSlsh = `backSlsh'

			*Get only the file name out of the file path
			local lastslash_fromRight = min(`forwSlsh',`backSlsh')
			local lastslash_fromLeft = strlen("`file'") - `lastslash_fromRight' + 2
			local filename = substr("`file'",`lastslash_fromLeft',.)

			*Get the filename without sensor prefix and file extension
			local filename_noext = substr(subinstr("`filename'",".csv", "", .),4,.)

			*Find the first underscore that splits the key and period number
			local first_undscore = strpos("`filename_noext'","_")

			*Get submission key from file name and add "uuid:" to match format on server
			local key = "uuid:" + substr("`filename_noext'",1,`first_undscore' -1)	//-1 to not include underscore

			*Get period length from file name,
			local period_from_filename = substr("`filename_noext'",`first_undscore' + 1, .) 		//+1 to not include underscore

			*Find the first underscore that splits the key and period number
			local second_undscore = strpos("`period_from_filename'","_")
			local period = substr("`period_from_filename'",`second_undscore' + 1, .)

			*Period and key only relevant for dta file (key is in csv file name)
			if "`dta'" != "" {

				*Extract key and period indication from file name and generate variable with that info
				gen key 	= "`key'"
				gen period 	= `period'

				*Order these vars to the front
				order key period

			}

			*Key variable is option in csv output as it takes space
			if "`csv'" != "" & "`keyvar'" != "" {

				*Extract key from file name and generate variable with that info
				gen key 	= "`key'"

				*Order these vars to the front
				order key `periodvar'
			}

			**********************
			*Calculate pct_categories equivalences variables

			*If option quiet is used generate var quiet
			if "`quiet'"  != "" {
				gen quiet = (mean < 25) & !missing(mean) //No values should be missing given current sensor_stream output, but good to include if that changes
				//label variable quiet "Time period has sound level below 25dB" //Not needed as outputted in csv where labels are not included
				local catvars "`catvars' pct_quiet = quiet"
			}

			*If option quiet is used generate var quiet
			if "`still'"  != "" {
				gen still = (mean < 0.15) & !missing(mean) //No values should be missing given current sensor_stream output, but good to include if that changes
				//label variable still "Time period has movement less than 0.25 m/s^2" //Not needed as outputted in csv where labels are not included
				local catvars "`catvars' pct_still = still"
			}

			*If option quiet is used generate var quiet
			if "`moving'" != ""{
				gen moving = (mean > 1.5) & !missing(mean) //No values should be missing given current sensor_stream output, but good to include if that changes
				//label variable moving "Time period has movement greater than 2 m/s^2" //Not needed as outputted in csv where labels are not included
				local catvars "`catvars' pct_moving = moving"
			}



			**********************
			*Calculate pct_between equivalences variables
			local counter = 0

			*Loop over all btwn varaibles. If no between option, then the btwnstring is empty, then the loop is skipped
			while ("`btwnstr'" != "" & `counter' < 1000) {

				local openindex  = strpos("`btwnstr'","[")
				local closeindex = strpos("`btwnstr'","]")

				local betweenname 	= substr("`btwnstr'", 1 ,`openindex' - 1)
				local betweeneq 	= substr("`btwnstr'", `openindex' + 1,`closeindex' - `openindex' - 1)

				gen `betweenname' = (`betweeneq')

				local btwnstr = trim(substr("`btwnstr'", `closeindex' + 1 , .))
				local ++counter
			}

end

** Test that the file has the correct format
cap program drop 	test_data_format
	program define 	test_data_format, rclass

	syntax , filename(string)


	****************************
	* Test that all expected variables exist

	*Create a list of all variables in the choice sheet
	ds
	local vars_in_this_file `r(varlist)'

	local expected_vars "second count mean min max sd fieldname"

	*Test that all required vars are actually in the survey sheets
	if `: list expected_vars in vars_in_this_file' == 0 {

		*Generate a list of the vars missing and display error
		local missing_vars : list expected_vars - vars_in_this_file
		noi di as error "{phang}The file [`filename'] does not have all the variables required. The variable(s) [`missing_vars'] are missing. Either download the file again, or remove the file.{p_end}"
		error 688
	}

	****************************
	* Test that there are observations in the data set
	if _N == 0 {
		noi di as error "{phang}The file [`filename'] does not have any observations. Either download the file again, or remove the file.{p_end}"
		error 688
	}

end



**This function parse the strings that are passed as values in
* the options llbetween(), mvbetween(), slbetween() and spbetween()
* and turn them into code that makes sense to Stata.
cap program drop 	parsebetween
	program define 	parsebetween, rclass

	syntax , prefix(string) between_options(string) usednames(string)

	*Create a lower case version of the prefix local
	local lc_prefix	= lower("`prefix'")

	*Remove excessive white space
	local btwn_list = trim(itrim("`between_options'"))

	*Start the counter
	local counter = 0

	*Parse through btwn_list and stop when it is empty (with a break for the unlikely case of infinite loops)
	while ("`btwn_list'" != "" & `counter' < 1000) {

		*Count the number of categories
		local ++counter

		*Get the index of the first square and the first round open bracket
		local opensquare = strpos("`btwn_list'","[")
		local openround  = strpos("`btwn_list'","(")

		*If there is no more open square or round index, set it to an index larger than any possible real index
		if `opensquare' == 0 	local opensquare = strlen("`btwn_list'") + 1
		if `openround' == 0 	local openround = strlen("`btwn_list'") + 1

		*Get the index of the first square and the first round closed bracket
		local closesquare = strpos("`btwn_list'","]")
		local closeround  = strpos("`btwn_list'",")")

		*If there is no more closed square or round index, set it to an index larger than any possible real index
		if `closesquare' == 0 	local closesquare = strlen("`btwn_list'") + 1
		if `closeround' == 0 	local closeround = strlen("`btwn_list'") + 1

		*Set the index of the first open bracket and first closed bracket regardless of square or round
		local openindex 	= min(`opensquare' ,`openround')
		local closeindex 	= min(`closesquare',`closeround')

		*Parse the individual components of the string for this between var
		local catvarname 	= substr("`btwn_list'", 1, `openindex' -1)
		local minbracket 	= substr("`btwn_list'", `openindex', 1)
		local minmaxstr 	= substr("`btwn_list'", `openindex' +1, (`closeindex' - `openindex') - 1 )
		local min			: word 1 of `minmaxstr'
		local max			: word 2 of `minmaxstr'
		local maxbracket 	= substr("`btwn_list'", `closeindex', 1)

		*Test that catvarname is a valid new name
		cap confirm new variable `catvarname'
		if _rc {

			di as error "{phang}The varname {it:`catvarname'} used in {inp:`lc_prefix'between(`between_options')} is not a valid varname, already in use or the varname is not immideatly followed by a ( or a [ sign.{p_end}"
			error 198
			exit
		}

		*Test that names are not already used in any other options
		if `:list catvarname in usednames' != 0 {

			di as error "{phang}The varname {it:`catvarname'} in {inp:`catvarname'`minbracket'`minmaxstr'`maxbracket'}  was already used for this sensor_stream or in another option. Names may not be duplicates across sensor streams or across options as all sensor varaibles are merged into one data set. Names may also not be the same name as a variable name used in any option with the prefix pct_.{p_end}"
			error 198
			exit
		}

		* Add name to list of used names
		local usednames "`usednames' pct_`catvarname' `catvarname'"

		if `:word count `minmaxstr'' > 2 | `=strpos("`minmaxstr'","(")' != 0 | `=strpos("`minmaxstr'","[")' != 0 {

			di as error "{phang}The value in {inp:`catvarname'`minbracket'`minmaxstr'`maxbracket'} used in {inp:`lc_prefix'between(`between_options')} is not enclosed properly. It must be enclosed in round or square brackets, like (), (], [) or []{p_end}"
			error 198
			exit
		}

		*Test that min and max are valid numbers
		foreach value in min max {
			cap confirm number ``value''
			if _rc {

				*The value is not a valid number, test if it is ? that is also valid
				if "``value''" == "?" {
					*The value is valid input but not a number
					local `value'num = 0
				}
				else {
					*The value is not a valid input
					di as error "{phang}The `value'imum value in {inp:`catvarname'`minbracket'`minmaxstr'`maxbracket'} used in {inp:`lc_prefix'between(`between_options')} is not a valid value. It must be a number or a question mark.{p_end}"
					error 198
					exit
				}
			}
			else {

				*The value is a valid number
				local `value'num = 1

				*Prepare the sign to use in the conditional statement for the valid number
				if "`value'" == "min" {
					local sqrbracket "["
					local rndbracket "("
					local rndsign ">"
					local sqrsign ">="
				}
				else {
					local sqrbracket "]"
					local rndbracket ")"
					local rndsign "<"
					local sqrsign "<="
				}

				*Prepare the sign to use based on square or round bracket
				if "``value'bracket'" == "`rndbracket'" {
					local `value'sign "`rndsign'"
					local `value'lbl  "(excl)"
				}
				else if "``value'bracket'" == "`sqrbracket'" {
					local `value'sign "`sqrsign'"
					local `value'lbl  "(incl)"
				}
				else {
					di as error "{phang}The value in {inp:`catvarname'`minbracket'`minmaxstr'`maxbracket'} used in {inp:`lc_prefix'between(`between_options')} must be enclosed in round or square brackets, like (), (], [) or [].{p_end}"
					error 198
					exit
				}
			}
		}

		*Prepare the conditional equation to be returned
		if `minnum' + `maxnum' == 0 {

			*Both min and max are ? which is not allowed
			di as error "{phang}There is no valid value in {inp:`catvarname'`minbracket'`minmaxstr'`maxbracket'} used in {inp:`lc_prefix'between(`between_options')}. Both values may not be a question mark.{p_end}"
			error 198
			exit
		}
		else if `minnum' + `maxnum' == 2 {

			*Both min and max are valid numbers

			*Test that min is smaller than max
			if `min' >= `max' {
				di as error "{phang}In {inp:`catvarname'`minbracket'`minmaxstr'`maxbracket'} used in {inp:`lc_prefix'between(`between_options')} the miniumum value is greater or equal to the maximum value which is not allowed.{p_end}"
				error 198
				exit
			}

			*Prepare the equation
			local cond_equ "mean `minsign' `min' & mean `maxsign' `max'"

			*Prepare part of variable label
			local label_values "between `min' `minlbl' and `max' `maxlbl'"
		}
		else if `minnum' == 1 {
			*Min is a valid number and max is a question marks, prepare equation with only min
			local cond_equ "mean `minsign' `min'"

			*Prepare part of variable label
			local label_values "between `min' `minlbl' and `max' `maxlbl'"

			*Prepare part of variable label
			local label_values "greater than `min' `minlbl'"
		}
		else if `maxnum' == 1 {
			*Max is a valid number and min is a question marks, prepare equation with only max
			local cond_equ "mean `maxsign' `max'"

			*Prepare part of variable label
			local label_values "less than `max' `maxlbl'"
		}

		*Return the varname and the conditional equation
		local btwn	"`btwn' `catvarname'[`cond_equ' & !missing(mean)]"

		*For .dta file, return the labels and the names
		return local btwnname`counter'		"`catvarname'"
		return local btwnlabels`counter'	"% (in decimals) `label_values' in `prefix'"

		local catvarnames "`catvarnames' `catvarname'"

		*Remove the part of the btwn_list string just parsed and repeat the while loop if applicable
		local btwn_list = trim(substr("`btwn_list'", `closeindex' + 1 , .))
	}

	*Return a string to be parsed where each var is on format: varname[mean < 25 & mean > 35 & !missing(mean)]
	return local btwn "`btwn'"

	*Return the number of between categories and the updated list of used names
	return local btwncount `counter'
	return local btwnnames = itrim(trim("`catvarnames'"))
	return local usednames "`usednames'"

end
