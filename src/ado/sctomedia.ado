
*!Version 1.0 01AUG2019 SurveyCTO support@surveycto.com

/* 	Developed by IPA (Innovations for Poverty Action) and SurveyCTO
	
	This program creates copies of SurveyCTO media files in a specified folder
	with user-friendly names constructed from values stored in your dataset.
	This includes images, audio, video and text media files.
	This command can also optionally organize such files into a folder structure, also named using values stored in your data. 

*/

program define sctomedia

	syntax varname(string) 		/*media variable*/								///
		[if] [in], 				/*Conditions*/									///
		[BY(varlist)] 			/*Variables for sorting media files*/			///
		id(varname) 			/*ID variable*/									///
		vars(varlist)			/*Variable to add in the media name*/			///
		MEDIAfolder(string) 	/*Data Source Folder*/							///
		OUTPUTfolder(string) 	/*Media Destination Folder*/					///
		[RESolve(varname)]		/*Required if id var has dups*/
	
	qui {
		
		tempvar uid_dup fname mf_valid mf_miss ext
		
		/***********************************************************************
		Check syntax, source and destination folders
		***********************************************************************/
	
		// Check that dataset has observations
		if (_N==0) {
			noi di as err "No observations in the dataset"
			err 2000
		}
			
		// Check that media variable contains at least one non missing value
		cap assert mi(`varlist')
			if !_rc {
				noi di as err "`varlist' has all missing values"
				err 2000
			}
		
		// Preserve original dataset
		preserve
		
		// Apply [in] and [if] condition		
		if !mi("`in'") {
			keep `in'
		}
		
		if !mi("`if'") { 
			keep `if' 
		}
		
		// Drop observations without media
		drop if mi(`varlist')
		
		// Check that id variable is unique
		cap isid `id'
			if _rc == 459 {
				noi di in red "{p} Warning: The variable `id' does not uniquely identify observations with non missing values for `varlist' {smcl}"
				duplicates tag `id', gen (`uid_dup')
				
				if !mi("`resolve'") {
					cap isid `id' `resolve'
					
                    if !_rc {
						noi di "{p} Media files with duplicate `id' will be resolved using the variable `resolve' {smcl}"

						decap `resolve'
					}
					
					else {
						noi di as err "{p} Resolve error: The variables `id' and `resolve' do not uniquely identify observations with non missing values for `varlist' {smcl}"
						exit 459
					}
				}
				
				// Stop and insist the user to specify option resolve
				else {
					noi di as err "resolve() option is required. Type 'help sctomedia' for more information about this option."
					exit 198
				}
			}
			
			else {
				gen `uid_dup' = 0
			}
			
		decap `id'
				
		// Check that source and destination folders exist
		foreach path in "`mediafolder'" "`outputfolder'" {
			if regexm(c(os),"Windows")==1 {
				cap confirm file "`path'/nul"
			}
			
			else if regexm(c(os),"Mac")==1 {
				    cap confirm file "`path'"
			}
			
			if _rc == 601 {
				di in red "Folder `path' not found"
				exit 601
			}
		}
		
		
		// Check that the variables in vars are 3 or less
		if !mi("`vars'") {
			local varscount: word count `vars'
			if `varscount' > 3 {	
				noi di in red "Too many variables specified with option vars: Max is 3"
				exit 103
			}

			forval varsnum = 1/`varscount' {
				local nvar: word `varsnum' of `vars'
				
				// Check that the vars() vars have no missing values and warn user if otherwise
				cap assert !mi(`nvar') if !mi(`varlist')
					if _rc {
						noi di in red "Warning: `nvar' has missing values. Some Media Files will be renamed with missing values."
					}
				
					decap `nvar'
			}

		}		
		
		// Check that the variables in by are 3 or less
		if !mi("`by'") {
			local bycount: word count `by'
			if `bycount' > 3 {	
				noi di in red "Too many variables specified with option by: Max is 3"
				exit 103
			}

			forval bynum = 1/`bycount' {
				local fvar: word `bynum' of `by'
				
				// Check that the by() vars have no missing values and warn user if otherwise
				cap assert !mi(`fvar') if !mi(`varlist')
					if _rc {
						noi di in red "Warning: `fvar' has missing values. Some Media Files will be logged into a 'Missing' folder"
					}
				
					decap `fvar'
			}

		}		
		
		noi di in green "This might take a while, please wait ..."

		/***********************************************************************
		Create Destination subfolders using the varlist in option BY
		***********************************************************************/

		gen `fname' = ""
		
		// Set the folder destination path as destination for media if by() is not specified
		if mi("`by'") {
			replace `fname' = "`outputfolder'"
		}
		
		// Else Create Folder Names from var1 in by()
		else {
		
			local fvar1: word 1 of `by'
			tostring `fvar1', force replace
			replace `fvar1'="" if `fvar1'=="."
			levelsof `fvar1', missing local(fvar1_levels)
			
				foreach level in `fvar1_levels' {
					
					if missing("`level'") {
						
                        if regexm(c(os),"Windows")==1 {
							cap confirm file "`outputfolder'/Missing/nul"
						}
						
						else if regexm(c(os),"Mac")==1 {
							 cap confirm file "`outputfolder'/Missing"
						}
						
                        if _rc == 601 {
							mkdir "`outputfolder'/Missing"
						}
						
                        replace `fname' = "`outputfolder'/Missing"
						
						if `bycount' >= 2 {
							local fvar2: word 2 of `by'
							tostring `fvar2', force replace
							replace `fvar2'="" if `fvar2'=="."
							levelsof `fvar2' if `fvar1' == "`level'", missing local (fvar2_levels)
							foreach level2 in `fvar2_levels' {
								
								if missing("`level2'") {
									
                                    if regexm(c(os),"Windows")==1 {
										cap confirm file "`outputfolder'/Missing/Missing/nul"
									}
								
									else if regexm(c(os),"Mac")==1 {
										cap confirm file "`outputfolder'/Missing/Missing"
									}
										
                                    if _rc == 601 {
										mkdir "`outputfolder'/Missing/Missing"
									}
									
                                    replace `fname' = "`outputfolder'/Missing/Missing"
								
									
									if `bycount' ==3 {
										local fvar3: word 3 of `by'
										tostring `fvar3', force replace
										replace `fvar3'="" if `fvar3'=="."
										levelsof `fvar3' if `fvar2' == "`level2'" & `fvar1' == "`level'", missing local (fvar3_levels)
										foreach level3 in `fvar3_levels' {
								
											if missing("`level3'") {
											
												if regexm(c(os),"Windows")==1 {
													cap confirm file "`outputfolder'/Missing/Missing/Missing/nul"
												}
											
												else if regexm(c(os),"Mac")==1 {
												    cap confirm file "`outputfolder'/Missing/Missing/Missing"
												}
												
												if _rc == 601 {
													mkdir "`outputfolder'/Missing/Missing/Missing"
												}
											
												replace `fname' = "`outputfolder'/Missing/Missing/Missing"
											}
										
											else {
										
												if regexm(c(os),"Windows")==1 {
													cap confirm file "`outputfolder'/Missing/Missing/`level3'/nul"
												}
											
												else if regexm(c(os),"Mac")==1 {
														cap confirm file "`outputfolder'/Missing/Missing/`level3'"
												}
											
												if _rc == 601 {
													mkdir "`outputfolder'/Missing/Missing/`level3'"
												}
						
												replace `fname' = "`outputfolder'/Missing/Missing/`level3'" if `fvar3' == "`level3'"	
											}
										}
									}
								}
											
								else {
									
                                    if regexm(c(os), "Windows")==1 {
										cap confirm file "`outputfolder'/Missing/`level2'/nul"
									}
									
									else if regexm(c(os),"Mac")==1 {
											cap confirm file "`outputfolder'/Missing/`level2'"
									    }
									
                                    if _rc == 601 {
										mkdir "`outputfolder'/Missing/`level2'"
									}
									
                                    // Replace fname with destination path
									replace `fname' = "`outputfolder'/Missing/`level2'" if `fvar2' == "`level2'"
									
										if `bycount' ==3 {
											local fvar3: word 3 of `by'
											tostring `fvar3', force replace
											replace `fvar3'="" if `fvar3'=="."
											levelsof `fvar3' if `fvar2' == "`level2'" & `fvar1' == "`level'", missing local (fvar3_levels)
											foreach level3 in `fvar3_levels' {
								
												if missing("`level3'") {
												
													if regexm(c(os), "Windows")==1 {
														cap confirm file "`outputfolder'/Missing/`level2'/Missing/nul"
													}
												
													else if regexm(c(os),"Mac")==1 {
														cap confirm file "`outputfolder'/Missing/`level2'/Missing"
													}
												
													if _rc == 601 {
														mkdir "`outputfolder'/Missing/`level2'/Missing"
													}
											
													replace `fname' = "`outputfolder'/Missing/`level2'/Missing" if `fvar2' == "`level2'"
												}
												
												else {
											
													if regexm(c(os), "Windows")==1 {
														cap confirm file "`outputfolder'/Missing/`level2'/`level3'/nul"
													}
												 
													else if regexm(c(os),"Mac")==1 {
														cap confirm file "`to'/Missing/`level2'/`level3'"
													}
												
													if _rc == 601 {
														mkdir "`outputfolder'/Missing/`level2'/`level3'"
													}
													
													replace `fname' = "`outputfolder'/Missing/`level2'/`level3'" if `fvar2' == "`level2'" & `fvar3' == "`level3'"	
												}
									        }
								        }			
							    }		
						    }
					    }
				    }
					
					else {
					
						if regexm(c(os), "Windows")==1 {
							cap confirm file "`outputfolder'/`level'/nul"
						}
						
						else if regexm(c(os),"Mac")==1 {
							 cap confirm file "`outputfolder'/`level'"
						}
						
                        if _rc == 601 {
							mkdir "`outputfolder'/`level'"
						}
					
						// Replace fname with destination path
						replace `fname' = "`outputfolder'/`level'" if `fvar1' == "`level'"
						
				
						// Create subfolders from var 2 in by()
						if `bycount' >= 2 {
							local fvar2: word 2 of `by'
							tostring `fvar2', force replace
							replace `fvar2'="" if `fvar2'=="."
							levelsof `fvar2' if `fvar1' == "`level'", missing local (fvar2_levels)
							foreach level2 in `fvar2_levels' {
								
								if missing("`level2'") {
									
									if regexm(c(os), "Windows")==1 {
										cap confirm file "`outputfolder'/`level'/Missing/nul"
									}
								
									else if regexm(c(os),"Mac")==1 {
										cap confirm file "`outputfolder'/`level'/Missing"
									}
									
									if _rc == 601 {
										mkdir "`outputfolder'/`level'/Missing"
									}
								
									replace `fname' = "`outputfolder'/`level'/Missing" if `fvar1' == "`level'"
								
									if `bycount' ==3 {
										local fvar3: word 3 of `by'
										tostring `fvar3', force replace
										replace `fvar3'="" if `fvar3'=="."
										levelsof `fvar3' if `fvar2' == "`level2'" & `fvar1' == "`level'", missing local (fvar3_levels)
										foreach level3 in `fvar3_levels' {
											
											if missing("`level3'") {
									
												if regexm(c(os), "Windows")==1 {
													cap confirm file "`outputfolder'/`level'/Missing/Missing/nul"
												}
												
												else if regexm(c(os),"Mac")==1 {
													cap confirm file "`outputfolder'/`level'/Missing/Missing"
												}
									
												if _rc == 601 {
													mkdir "`outputfolder'/`level'/Missing/Missing"
												}
									
												replace `fname' = "`outputfolder'/`level'/Missing/Missing" if `fvar1' == "`level'"
												}
										
											else {
											
												if regexm(c(os), "Windows")==1 {
													cap confirm file "`outputfolder'/`level'/Missing/`level3'/nul"
												}
											    
												else if regexm(c(os),"Mac")==1 {
												    cap confirm file "`outputfolder'/`level'/Missing/`level3'"
											    }
												
												if _rc == 601 {
													mkdir "`outputfolder'/`level'/Missing/`level3'"
												}
											
												replace `fname' = "`outputfolder'/`level'/Missing/`level3'" if `fvar1' == "`level'" & `fvar3' == "`level3'"
											}
										}
									}
								}
								
								else {
								
									if regexm(c(os),"Windows")==1 {
										cap confirm file "`outputfolder'/`level'/`level2'/nul"
									}
									
									else if regexm(c(os),"Mac")==1 {
										cap confirm file "`outputfolder'/`level'/`level2'"
									}
										
                                    if _rc == 601 {
										mkdir "`outputfolder'/`level'/`level2'"
									}
							
									// Replace fname with destination path
									replace `fname' = "`outputfolder'/`level'/`level2'" if `fvar2' == "`level2'" & `fvar1' == "`level'"

									// Create subfolders from var3 in by()
								
									if `bycount' ==3 {
										local fvar3: word 3 of `by'
										tostring `fvar3', force replace
										replace `fvar3'="" if `fvar3'=="."
										levelsof `fvar3' if `fvar2' == "`level2'" & `fvar1' == "`level'", missing local (fvar3_levels)
										foreach level3 in `fvar3_levels' {
											
											if missing("`level3'") {
												
												if regexm(c(os),"Windows")==1 {
													cap confirm file "`outputfolder'/`level'/`level2'/Missing/nul"
												}
												
												else if regexm(c(os),"Mac")==1 {
													cap confirm file "`outputfolder'/`level'/`level2'/Missing"
												}
													
                                                if _rc == 601 {
													mkdir "`outputfolder'/`level'/`level2'/Missing"
												}
													
												// Replace fname with destination path
                                                replace `fname' = "`outputfolder'/`level'/`level2'/Missing" if `fvar2' == "`level2'" & `fvar1' == "`level'"
											}
												
											else {
												
												if regexm(c(os),"Windows")==1 {
													cap confirm file "`outputfolder'/`level'/`level2'/`level3'/nul"
												}
											
												else if regexm(c(os),"Mac")==1 {
													cap confirm file "`outputfolder'/`level'/`level2'/`level3'"
											    }
												
                                                if _rc == 601 {
													mkdir "`outputfolder'/`level'/`level2'/`level3'"
												}
											
												// Replace fname with destination path
												replace `fname' = "`outputfolder'/`level'/`level2'/`level3'" if `fvar3' == "`level3'" & ///
												`fvar2' == "`level2'" & `fvar1' == "`level'"
											}
										}
									}
								}
							}
						}
					}
				}
		}
		
			/*******************************************************************
			Log Media Files into respective folders
			*******************************************************************/
		
			gen `mf_valid' = substr(`varlist', 1, 5) == "media"
			
			// remove "media/" from the media name
			if strpos(`varlist', "media\") {
				replace `varlist' = subinstr(`varlist', "media\", "", .)
			}
			
			else if strpos(`varlist', "media/") {
				replace `varlist' = subinstr(`varlist', "media/", "", .)
			}
			
			// generate tempvar ext to hold the extension for each media file
			gen `ext' = substr(`varlist', -(strpos(reverse(`varlist'), ".")), .)
			
			local nvar1: word 1 of `vars'
			local nvar2: word 2 of `vars'
			local nvar3: word 3 of `vars'
			local mf_track 0
			local uid_track 0
			local mf_miss_track	0											
			gen int `mf_miss' = 0
			
			local N = _N
			forval mf = 1/`N' {
				local mf_copy = `mf_valid'[`mf']
				if `mf_copy' == 1 {
					local mf_id = `id'[`mf']
					local mf_nvar1 = `nvar1'[`mf']
					local mf_nvar2 = `nvar2'[`mf']
					local mf_nvar3 = `nvar3'[`mf']
					local mf_sav = `fname'[`mf']
					local mf_file = `varlist'[`mf']			
					local mf_dup = `uid_dup'[`mf']
					local mf_ext = `ext'[`mf']
							
					if `mf_dup' == 0 {
					
						if `varscount' == 1 {
							cap confirm file "`mf_sav'/`mf_id'_`mf_nvar1'`mf_ext'"
						
							if _rc == 601 {
								cap copy "`mediafolder'/`mf_file'" "`mf_sav'/`mf_id'_`mf_nvar1'`mf_ext'", replace														
								
								if _rc == 601 {
									replace `mf_miss' = 1 if `id' == "`mf_id'" & `varlist' == "`mf_file'"
									local ++mf_miss_track
								}
								
								else if !_rc {
									local ++mf_track
								}
							}
						}

								
						else if `varscount' == 2 {
							cap confirm file "`mf_sav'/`mf_id'_`mf_nvar1'_`mf_nvar2'`mf_ext'"
								
							if _rc == 601 {
								cap copy "`mediafolder'/`mf_file'" "`mf_sav'/`mf_id'_`mf_nvar1'_`mf_nvar2'`mf_ext'", replace
								
								if _rc == 601 {
									replace `mf_miss' = 1 if `id' == "`mf_id'" & `varlist' == "`mf_file'"
									local ++mf_miss_track
								}
		
								else if !_rc {
									local ++mf_track
								}
							}
						}

								
						else if `varscount' ==3 {
							cap confirm file "`mf_sav'/`mf_id'_`mf_nvar1'_`mf_nvar2'_`mf_nvar3'`mf_ext'"
									
							if _rc == 601 {
								cap copy "`mediafolder'/`mf_file'" "`mf_sav'/`mf_id'_`mf_nvar1'_`mf_nvar2'_`mf_nvar3'`mf_ext'", replace
									
								if _rc == 601 {
									replace `mf_miss' = 1 if `id' == "`mf_id'" & `varlist' == "`mf_file'"
									local ++mf_miss_track
								}
			
								else if !_rc {
									local ++mf_track
								}
							}
						}
					}
							
					else {
					
						local uid_key = `resolve'[`mf'] 
							
							if `varscount' == 1 {
								cap confirm file "`mf_sav'/`mf_id'_`uid_key'_`mf_nvar1'`mf_ext'"
						
								if _rc == 601 {
									copy "`mediafolder'/`mf_file'" "`mf_sav'/`mf_id'_`uid_key'_`mf_nvar1'`mf_ext'", replace
									local ++uid_track

								}
							}

								
							else if `varscount' == 2 {
								cap confirm file "`mf_sav'/`mf_id'_`uid_key'_`mf_nvar1'_`mf_nvar2'`mf_ext'"
								
								if _rc == 601 {
									copy "`mediafolder'/`mf_file'" "`mf_sav'/`mf_id'_`uid_key'_`mf_nvar1'_`mf_nvar2'`mf_ext'", replace
									local ++uid_track
								}
							}

							else if `varscount' == 3 {
								cap confirm file "`mf_sav'/`mf_id'_`uid_key'_`mf_nvar1'_`mf_nvar2'_`mf_nvar3'`mf_ext'"
									
								if _rc == 601 {
									copy "`mediafolder'/`mf_file'" "`mf_sav'/`mf_id'_`uid_key'_`mf_nvar1'_`mf_nvar2'_`mf_nvar3'`mf_ext'", replace
									local ++uid_track
								}
							}
					}
				}
			}

			noi di in green "`mf_track' Media Files Logged"
			if `uid_track' > 0 {
				noi di "`uid_track' Media Files Duplicate on `id'. Differences resolved using variable `resolve'"
			}
		
			tempfile mf_temp
			save `mf_temp', replace
			
			drop if `mf_valid'
			if _N > 0 {
		
				noi di as result _N as text in red " missing media file(s) from SurveyCTO server"
				noi di "id" _column(20)
			
				local N = _N
				forval mf = 1/`N' {
				
					local mf_id = `id'[`mf']
					noi di "`mf_id'" _column(20)
				}
			
			}
			
			use `mf_temp', clear
			drop if !`mf_miss' | mi(`mf_miss')
			if _N > 0 {
				noi di as result _N as text in red " missing media files from directory (`mediafolder')"
				noi di "id" _column(20)
				
				local N = _N
				forval mf = 1/`N' {
				
					local mf_id = `id'[`mf']
					noi di "`mf_id'" _column(20)
				}
		
			}
			
		restore
	}
		
end

program decap 

qui {
	
	// Remove char ":", "/", "\", "|", "*", "?", "<", ">" if vars in id, by, vars or resolve are strings			
	args tmp_dv

	cap confirm string var `tmp_dv'
		if !_rc {
			replace `tmp_dv' = subinstr(`tmp_dv', "/", "", .)
			replace `tmp_dv' = subinstr(`tmp_dv', "\", "", .)
			replace `tmp_dv' = subinstr(`tmp_dv', ":", "", .)
			replace `tmp_dv' = subinstr(`tmp_dv', "|", "", .)
			replace `tmp_dv' = subinstr(`tmp_dv', "*", "", .)
			replace `tmp_dv' = subinstr(`tmp_dv', "<", "", .)
			replace `tmp_dv' = subinstr(`tmp_dv', ">", "", .)
			replace `tmp_dv' = subinstr(`tmp_dv', "?", "", .)
		}
	}
	
end
