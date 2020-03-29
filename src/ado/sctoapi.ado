*!Version 2.0 27MAR2020 SurveyCTO support@surveycto.com

/* Developed by IPA (Innovations for Poverty Action) and SurveyCTO
  This program downloads SurveyCTO data in JSON format via the API. The data
  is then converted and saved in CSV and DTA (optional) format. Optionally,
  it also downloads media files which are saved in an `outputfolder' subfolder named 'media'.
*/

program define sctoapi, rclass

	syntax anything(name=formids id="formid(s)"), ///
		SERVER(string)      	/// SurveyCTO servername
		USERname(string)    	/// SurveyCTO username
		PASSword(string)	/// SurveyCTO password
		DATE(string)		/// Date Parameter in UTC
		OUTPUTfolder(string)   	/// location to download json to
		[KEY(string)]		/// Private Key for Encrypted forms
		[MEDIA(namelist)]   	/// flag to download media files
		[DTAFILE]		/// flag to download a .dta file	
		[REPlace]

	preserve
	
	qui {
	local url= "https://`server'.surveycto.com/api/v2/forms"

	if mi("`outputfolder'") {
		local outputfolder = "."
	}
	else if !mi("`outputfolder'") {
		if regexm("`outputfolder'", "\.$"){
 			local outputfolder = substr("`outputfolder'", 1, length("`outputfolder'") - 1)
 		}
	}

	
	foreach formid in `formids' {

	*Code for unencrypted forms
		if mi("`key'") {
	
		nois di `"Downloading `formid' from {browse "https://`server'.surveycto.com":`server'} in WIDE format..."'

			local filename = "`formid'" + ".json"

			!curl -s "`url'/data/wide/json/`formid'?date=`date'" ///
				-u `username':`password' ///
				--output "`outputfolder'/`filename'" 

			tempname jsondata observation datapoint	
			scalar `jsondata' = fileread("`outputfolder'/`filename'")
			
			if `jsondata' != "[]" {
			noisily di "Download of `formid' data complete."
			noisily di ""
			noisily di "Import dataset..."

			local i 0
			while ustrregexm(`jsondata',`"\{([^\}]+)"') == 1 {
				set obs `++i'
				scalar `observation' = ustrregexs(1)
				scalar `jsondata' = usubinstr(`jsondata',`observation',"",1)
				while ustrregexm(`observation',`""([a-zA-Z_][a-zA-Z0-9_]+)":("[^\"]*"|null)"') == 1 {
					scalar `datapoint' = ustrregexs(0)
					local varname = ustrregexs(1)
					local value = ustrregexs(2)
					local value = usubinstr(`"`value'"',`"""',"",.)
					cap gen `varname' = ""
					replace `varname' = `"`value'"' in `i'
					replace `varname' = "" if `varname' == "null"
					scalar `observation' = usubinstr(`observation',`datapoint',"",1)
			}
		}
		
		if !mi("`dtafile'") {
			local statafilename = "`outputfolder'" + "/" + "`formid'" + ".dta"
			save `statafilename', replace
		
		noisily di "Export of `formid' .dta file complete."
		noisily di ""
		}
		
		local csvfilename = "`outputfolder'" + "/" + "`formid'" + "_WIDE.csv"
		export delimited using `csvfilename', replace
		
		noisily di "Export of `formid' CSV file complete."
		noisily di ""
		
		}

				if "`media'" != "" {
				
					local mediafolder = "`outputfolder'" + "/media"
					
					
					import delimited using `csvfilename', clear
					foreach var in `media' {
						cap confirm variable `var'
						if !_rc {
							sctoapi_media `var', ///
								username(`username') ///
								password(`password') ///
								path(`mediafolder')
						}
					}
				}
			}
		*Code for encrypted forms
		else {
		
		nois di `"Decrypting and Downloading `formid' from {browse "https://`server'.surveycto.com":`server'} in JSON format (WIDE)..."'

			local filename = "`formid'" + ".json"

				!curl -s "`url'/data/wide/json/`formid'?date=`date'" ///
					-u `username':`password' ///
					-F "private_key=@`key'" ///
					--output "`outputfolder'/`filename'"

			tempname jsondata observation datapoint	
			scalar `jsondata' = fileread("`outputfolder'/`filename'")
			
			if `jsondata' != "[]" {
			noisily di "Download complete."
			noisily di ""
			noisily di "Import dataset..."

			local i 0
			while ustrregexm(`jsondata',`"\{([^\}]+)"') == 1 {
				set obs `++i'
				scalar `observation' = ustrregexs(1)
				scalar `jsondata' = usubinstr(`jsondata',`observation',"",1)
				while ustrregexm(`observation',`""([a-zA-Z_][a-zA-Z0-9_]+)":("[^\"]*"|null)"') == 1 {
					scalar `datapoint' = ustrregexs(0)
					local varname = ustrregexs(1)
					local value = ustrregexs(2)
					local value = usubinstr(`"`value'"',`"""',"",.)
					cap gen `varname' = ""
					replace `varname' = `"`value'"' in `i'
					replace `varname' = "" if `varname' == "null"
					scalar `observation' = usubinstr(`observation',`datapoint',"",1)
			}
		}
		
		if !mi("`dtafile'") {
			local statafilename = "`outputfolder'" + "/" + "`formid'" + ".dta"
			save `statafilename', replace
		
		noisily di "Export of .dta file complete."
		noisily di ""
		}
		
		local csvfilename = "`outputfolder'" + "/" + "`formid'" + "_WIDE.csv"
		export delimited using `csvfilename', replace
		
		noisily di "Export of CSV file complete."
		noisily di ""
		
		}

				if "`media'" != "" {
				
					local mediafolder = "`outputfolder'" + "/media"
					
					import delimited using `csvfilename', clear
					foreach var in `media' {
						cap confirm variable `var'
						if !_rc {
							sctoapi_media `var', ///
								username(`username') ///
								password(`password') ///
								key(`key') ///
								path(`mediafolder')
						}
					}
				}
			}
	
	clear
	
	}
		noisily di "API Download complete!"
	}
	
	restore
end

program define sctoapi_media, rclass
	/* This program assists in downloading the media attachment files 
	   for a SurveyCTO form using the API */

	syntax varname [if] [in], ///
		USERname(string)      /// SurveyCTO username/// SurveyCTO servername
		PASSword(string)      /// SurveyCTO password
		PATH(string)          /// location to download media files to
		[KEY(string)]		///Private key for encrypted forms

	qui{
	cap which parallel 
	if _rc {
		net install parallel, from("https://raw.github.com/gvegayon/parallel/master/") replace
		mata mata mlib index
	}

	if regexm(c(os),"Windows")==1 {
			cap confirm file "`path'/nul"
	}
				
	else if regexm(c(os),"Mac")==1 {
			cap confirm file "`path'"
	}
				
	if _rc == 601 {
		mkdir "`path'"
	}
	
	local regex_ta "TA_[A-Za-z0-9\-]*.csv"
	local regex_image "([0-9]*[.](jpg|png|jpeg|tif|tiff|gif|png|jif|jfif|jp2|jpx|j2k|j2c|fpx|pcd|pdf|bmp|psd|ai|eps|svg|ps|drw))"
	local regex_video "([0-9]*[.](mp4|webm|mkv|flv|vob|ogv|ogg|drc|mng|avi|mov|qt|wmv|yuv|rm|rmvb|asf|mp4|m4p|m4v|mpg|mp2|mpeg|mpe|mpv|mpg|mpeg|m2v|m4v|svi|3gp|3g2|mxf|roq|nsv))"
	local regex_aa "AA_[A-Za-z0-9_\-]*.[a-z0-9]*"
	local regex_comment "Comments-[A-Za-z0-9\-]*.csv"

	tempvar files
	qui gen `files' = regexs(1) if regexm(`varlist', "(`regex_ta'|`regex_image'|`regex_video'|`regex_aa'|`regex_comment')")	
	
	noisily di _col(5) "Downloading `=_N' media files in image..."

	if mi("`key'") {
		forval i = 1/`=_N' {
			local url = `varlist'[`i']
			local file = `files'[`i']
			local output = "`path'" + "/" + "`file'"
		
		if !mi("`url'") {
		
		if regexm(c(os),"Windows")==1 {
			cap confirm file "`path'/`file'/nul"
			if _rc {
				scalar PROCEXEC_HIDDEN = 1
				!curl -s `url' -u `username':`password' --output `output'
				scalar pid = r(pid)
			}
		}
		
		else if regexm(c(os),"Mac")==1 {
			cap confirm file "`path'/`file'"
			if _rc {
				scalar PROCEXEC_HIDDEN = 1
				!curl -s `url' -u `username':`password' --output `output'
				scalar pid = r(pid)
			}
		}
		
		}
		noisily di _col(5) "`i'/`=_N'..." _continue
		noisily di _newline
		
		}
		
	noisily di "Media Export complete."
	drop `files'
	
	}
	
	else {
	
	forval i = 1/`=_N' {
		local url = `varlist'[`i']
		local file = `files'[`i']
		local output = "`path'" + "/" + "`file'"
		
		if !mi("`url'") {
		
		if regexm(c(os),"Windows")==1 {
			cap confirm file "`output'/nul"
				if _rc {
					scalar PROCEXEC_HIDDEN = 1
					!curl -s `url' -u `username':`password' -F "private_key=@`key'" --output `output'
					scalar pid = r(pid)
				}
		}
				
		else if regexm(c(os),"Mac")==1 {
			cap confirm file "`output'"
				if _rc {
					scalar PROCEXEC_HIDDEN = 1
					!curl -s "`url'" -u `username':`password' -F "private_key=@`key'" --output `output'
					scalar pid = r(pid)
				}
		}
		
		}
		
		noisily di _col(5) "`i'/`=_N'..." _continue
		noisily di _newline

		}
		
	noisily di "Media Export complete."
	drop `files'
	}
	
	}

end
