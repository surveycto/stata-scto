/*******************************

	This file is not needed for anyone who is only installing the scto
	package using "ssc install scto". If you want to update the files
	you have installed with "ssc install scto" by typing "adoupdate scto"
	or "ssc install scto, replace"

	If you have used an alternative way to install the scto package and
	that is now causing errors when trying to install it again, then run
	this file. Run it multiple times until it says file not found for
	all files.

*********************************/
foreach file in sctostreamcsv.ado sctostreamcsv.sthlp sctostreamsum.ado sctostreamsum.sthlp sctofunctions.do {

	capture findfile `file'
	if (_rc == 0) {
		rm "`r(fn)'"
		noi di "File `r(fn)' was removed"
	}
	else {
		noi di "File `file' not found, so not need to reomve"
	}
}
