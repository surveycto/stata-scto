clear all
	set trac off
	
	*insert below the directory to which you cloned the stata-scto repository
	local scto_repo ""
	
	
	**Install the command. See https://github.com/surveycto/scto for 
	* methods to install unreleased versions of this command
	ssc install scto, replace

	*folder locals
	local ado "`scto_repo'/src/ado"
	local testfolder "`scto_repo'/testfiles/sctomedia"
	
	
	*Create the folders needed in the output folder if they do not already exist
	
	local output1 "`testfolder'/data_1/testresults"

	if regexm(c(os),"Windows")==1 {
			cap confirm file "`output1'/nul"
	}
				
	else if regexm(c(os),"Mac")==1 {
			cap confirm file "`output1'"
	}
				
	if _rc == 601 {
		mkdir "`output1'"
	}

	local output2 "`testfolder'/data_2/testresults"

	if regexm(c(os),"Windows")==1 {
			cap confirm file "`output2'/nul"
	}
				
	else if regexm(c(os),"Mac")==1 {
			cap confirm file "`output2'"
	}
				
	if _rc == 601 {
		mkdir "`output2'"
	}

	*Use locals to enable/disable which tests to run.
	local run_data_1 1
	local run_data_2 1
	
***************************************

if `run_data_1' == 1 {

	*Run tests on data 1.
	local data sctomedia_testdata_1
	
	import delimited "`testfolder'/data_1/sctomedia_testdata_1_WIDE.csv"

	*Run the command. This command will rename and organize the media files stored in text_audit, which is a textaudit field.
	//The 'id' is the unique identifier.
	//The 'survey_region', 'survey_country' and 'survey_city' are the region, country and city of the interview, respectively.
	//This code will:
	//1) Copy all media files in "`testfolder'/sctomedia_test_1/media" matching the names stored in 'text_audit'
	//2) Inside `output1', create one folder for each survey_region and store the media files accordingly
	//3) Rename all media files according to the sequence: `id'_`survey_country'_`survey_city'

	sctomedia text_audit, id(id) ///
						by(survey_region) ///
						vars(survey_country survey_city) ///
						media("`testfolder'/data_1/media") ///
						output("`output1'")

clear						
}

***************************************

if `run_data_2' == 1 {

	*Run tests on data 2.
	local data sctomedia_testdata_2
	
	import delimited "`testfolder'/data_2/sctomedia_testdata_2_WIDE.csv"

	*Run the command. This command will rename and organize the media files stored in animal_image, which is an image field.
	//The 'id' is the unique identifier. However, the 'id' has duplicates, so resolve() is required to be able to distinguish these duplicate observations.
	//The 'name' is the name of the respondent.
	//This code will:
	//1) Copy all media files in "`testfolder'/sctomedia_test_2/media" matching the names stored in 'animal_image'
	//2) Store these media files in "`output2'"
	//3) Rename all media files according to the sequence: `id'_`key'_`name' for duplicate observations, and `id'_`name' for non-duplicate observations

	sctomedia animal_image, id(id) ///
						vars(name) ///
						media("`testfolder'/data_2/media") ///
						output("`output2'") ///
						resolve(key)					

	clear
}

***************************************
