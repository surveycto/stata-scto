*!Version 2.0 23APR2020 SurveyCTO support@surveycto.com

/* Developed by William Blackmon (wblackmon@poverty-action.org) - IPA (Innovations for Poverty Action)
  This program shifts time zones for specified time or datetime fields collected by SurveyCTO.
*/

cap program drop sctorezone
program sctorezone
	syntax anything(id="time zone shift or starttime variable" name=shift) [if] [in], force [Only(varlist) | Exclude(varlist)]
	
 	* break "shifted" into direction (+ or -) and hours
	
		// is "shift" in manual or automatic form?
		cap confirm string variable `shift'
		if _rc == 0 loc shifttype = "automatic"
		if _rc >  0 loc shifttype = "manual"
		
		tempvar shifttime
	
		// manual: +/-X
		if "`shifttype'" == "manual" {
			if substr("`shift'",1,1)!="+" & substr("`shift'",1,1)!="-" {
				di as error "Shift must either be a string variable or in the form '+3' or '-4'."
				error 1			
			}

			loc direction = substr("`shift'", 1, 1)
			gen `shifttime' = real(subinstr("`shift'","`direction'", "", 1))
			if "`direction'" == "-" qui replace `shifttime' = `shifttime'*-1 
			cap assert !mi(`shifttime')
			if _rc > 0 {
				di as error "Shift must either be a string variable or in the form '+3' or '-4'."
				error 1				
			}
		}
		
		// automatic: starttime variable
		if "`shifttype'" == "automatic" {
			cap assert !mi(`shift')
			if _rc > 0 {
				di as error "Shift variable must never be missing."
				error 1
			}
			tempvar localraw
			tempvar shiftraw
			gen double `localraw' = clock(`shift', "YMDhms")
			gen double `shiftraw' = `localraw' - starttime
			gen double `shifttime' = `shiftraw'/60/60/1000
		}
	
	* error handling
		// input both `only' and `exclude'
		if "`only'"!="" & "`exclude'"!="" {
			di as error `"Use the "only" or "exclude" options (or neither), not both."'
			error 1
		}
		
		// shift issues
		qui count if mi(`shifttime')
		if r(N)>0 {
			di as error "Shift must either be a string variable which is never missing or in the form '+3' or '-4'."
			error 1
		}
		qui count if `shifttime'<=-24 | `shifttime'>=24
		if r(N)>0 {
			di as error "Time zone shift must be in hours, between +/-24 (exclusive)."
			error 1
		}
	
	
	* create varlists that will have their time zones adjusted
	
		// normal (no only or exclude options used)
		if "`only'`exclude'"=="" {
			unab all : _all
		}

		// only option used
		if "`only'" != "" {
			unab all : `only'
		}
		
		
		// exclude option used
		if "`exclude'" != "" {
			unab all : _all
			loc all = " `all' "
			foreach var of varlist `exclude' {
				loc all = subinstr("`all'", " `var' ", " ", 1)
			}
		}
		
		// create separate varlists for each type: time and datetime
			
			// time: string variable that always ends in " AM" or " PM" if not missing
			qui ds `all', has(type string)
			if "`r(varlist)'" != "" {
				foreach var of varlist `r(varlist)' { // loop over all string variables
					cap: assert mi(`var') | strmatch(`var',"*:??:?? ?M") // must always be missing or follow SCTO time format
					if _rc == 0 {
						qui count if mi(`var') // don't change if always missing
						if r(N)<`=_N' loc tvars = "`tvars' `var'" // add to list of time variables
					}
				}
			}
			
			// datetime: uses the tc variable format
			qui ds `all', has(format %tc*)
			loc dtvars = r(varlist)
			if "`dtvars'"=="." loc dtvars = ""
	
	* adjust time zone of time variables
		if "`tvars'" != "" {
		foreach var of varlist `tvars' {
				qui {
					if regexm(string(`shifttime'),"[.][0-9]$") {
						tempvar secs
						gen `secs' = substr(`var', -5,2) // in "12:34:56 AM", just "56"
						tempvar rawmins
						gen `rawmins' = substr(`var', -8,2) // in "12:34:56 AM", just "34"
						tempvar shiftmins
						gen `shiftmins'= real(substr(string(`shifttime'),-1,1))*6
						if "`direction'" == "-" qui replace `shiftmins' = `shiftmins'*-1
						tempvar mins
						gen `mins' = real(`rawmins') + `shiftmins'
						replace `mins' = `mins' - 60 if `mins'>=60
						replace `mins' = `mins' + 60 if `mins'<0
						tostring `mins', force replace
						replace `mins' = "0" + `mins' if strlen(`mins')==1
						tempvar rawhours
						gen `rawhours' = real(subinstr(substr(`var',1,2),":","",1)) // hours only, 1-12
						tempvar shifthours
						gen `shifthours'= real(substr(string(`shifttime'), 1, strpos(string(`shifttime'), ".")-1))
						replace `rawhours' = `rawhours' + 12 if substr(`var',-2,.)=="PM" & `rawhours'<12 // changing 1PM-11PM to 13-23
						replace `rawhours' = `rawhours' + `shifthours' // time zone shift
						replace `rawhours' = `rawhours' - 24 if `rawhours'>=24 // if shift moves time to the next day, remove 24 hours
						replace `rawhours' = `rawhours' + 24 if `rawhours'<0 // if shift moved time to the previous day, add 24 hours
						tempvar hours12 // hours component of shifted time, 1-12
						gen `hours12' = `rawhours'
						replace `hours12' = `rawhours'-12 if `rawhours'>12 // changing 13-23 back to 1PM-11:PM
						replace `var' = string(`hours12') + ":" + `mins' + ":" + `secs' + " " if !mi(`var') // adding in formatting
						replace `var' = `var' + "AM" if `rawhours'<12 & !mi(`var') // add AM if raw hours between 0-11
						replace `var' = `var' + "PM" if `rawhours'>=12 & !mi(`var') // add PM if raw hours between 12-23
					}
					else if regexm(string(`shifttime'),"[.][0-9]$")==0 {
						tempvar minsecs
						gen `minsecs' = substr(`var', -8,5) // in "12:34:56 AM", just "34:56"
						tempvar rawhours
						gen `rawhours' = real(subinstr(substr(`var',1,2),":","",1)) // hours only, 1-12
						replace `rawhours' = `rawhours' + 12 if substr(`var',-2,.)=="PM" & `rawhours'<12 // changing 1PM-11PM to 13-23
						replace `rawhours' = `rawhours' + `shifttime' // time zone shift
						replace `rawhours' = `rawhours' - 24 if `rawhours'>=24 // if shift moves time to the next day, remove 24 hours
						replace `rawhours' = `rawhours' + 24 if `rawhours'<0 // if shift moved time to the previous day, add 24 hours
						tempvar hours12 // hours component of shifted time, 1-12
						gen `hours12' = `rawhours'
						replace `hours12' = `rawhours'-12 if `rawhours'>12 // changing 13-23 back to 1PM-11:PM
						replace `var' = string(`hours12') + ":" + `minsecs' + " " if !mi(`var') // adding in formatting
						replace `var' = `var' + "AM" if `rawhours'<12 & !mi(`var') // add AM if raw hours between 0-11
						replace `var' = `var' + "PM" if `rawhours'>=12 & !mi(`var') // add PM if raw hours between 12-23
					}
			}
		}
	}
		
		
	* adjust time zone of datetimetime variables
	if "`dtvars'" != "" {
		foreach var of varlist `dtvars' {
			qui replace `var' = `var' + `shifttime'*60*60*1000 
		}
	}

	* display results
		loc numvars = wordcount("`tvars' `dtvars'")
		if `numvars'==0 di "No variables have been shifted."
		if `numvars'>0 {
			di "The following variable(s) have been shifted: `tvars' `dtvars'"
			qui levelsof `shifttime', loc(shiftlevels)
			foreach sh of local shiftlevels {
				qui count if `shifttime' == `sh' 
				loc s
				loc fb "backwards"
				if `sh'>0 loc fb "forwards"
				loc abssh = abs(`sh')
				if `abssh'>1 loc s = "s"
				if `sh'!=0 di "- `r(N)' observations shifted `fb' by `abssh' hour`s'."
				if `sh'==0 di "- `r(N)' observations not shifted."
			}
		}
end
