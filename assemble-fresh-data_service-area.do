* assemble dataset for fresh store study
* using service area method
* AY 2012-2016

clear all
set more off

********************************************************************************
************ extract unique xy, AY12-16 ****************************************
********************************************************************************
{ //extract unique xy coords, AY12-16
* make master files of all unique xy coordinates, 12-16
* by year, make xy-newid files
cd "C:\Users\wue04\Box Sync\fresh"

* AY12 and 13
forvalues i=12/16 {
	use "S:\Restricted Data\Geocoding\AP\newid ap coordinates 20`i'.dta", clear
	rename xcoo x
	rename ycoo y
	rename WA2_BBL bbl
	keep year newid x y bbl
	compress
	save data\address\newid`i'.dta, replace
}
.

forvalues i=12/15 {
	append using data\address\newid`i'.dta
	*erase data\address\newid`i'.dta
}
.
destring x y, replace
drop if missing(x)|missing(y)|missing(newid)
tab year //sanity check
compress
save data\address\newid12-16.dta, replace
erase data\address\newid16.dta

drop bbl newid
duplicates drop x y year, force
bys year: gen id=_n
compress
save data\address\xy12-16.dta, replace
export delimited data\address\xy12-16.csv, replace
}
.

********************************************************************************
************ link raw distance output to xy coords *****************************
********************************************************************************
forvalues i=12/16 {
	import delimited raw-output\service-area\s`i'.csv, clear
	drop if name==" "
	keep id x y name year
	rename year year
	duplicates tag id, gen(dup)
	tab dup //no student has access to two stores
	drop id dup
	compress
	save data\xy-distance`i'.dta, replace
}
.

forvalues i=12/15 {
	append using data\xy-distance`i'.dta
	erase data\xy-distance`i'.dta
}
.

split name, p(" : ")
encode name2, gen(nearest) label(dsitance)
drop name name2
rename name1 name
compress

merge 1:m x y year using data\address\newid12-16.dta
drop _merge
compress
save S:\Personal\hw1220\fresh\data\newid_distance_12-16.dta, replace
erase data\xy-distance16.dta

********************************************************************************
************ assemble fitnessgram data *****************************************
********************************************************************************
{ //link to fitnessgram data
cd "S:\Personal\hw1220\fresh\data"
use "S:\Restricted Data\Fitnessgram\Panel\2009-2017 obesitymeasures JB - 11-13-18.dta", clear
drop if year<=2011|year==2017
keep newid year bds female age_mo_round weight_kg height_cm hasbmi zbmi sevobese ///
	obese overweight underweight fgcoverage bmipct
rename female female_fg
label var female "female indicator from fitnessgram file"
compress
drop if missing(newid)|missing(year)
save newid-fg.dta, replace
}
.

********************************************************************************
************ assemble demo data *****************************************
********************************************************************************
{ //link demographic data
forvalues i=12/15 {
	local j=`i'-1
	use "S:\AnalyticFiles\Student Level Files Stata\y20`j'`i'f.dta", clear
	keep newid zmath zread sex grade ethnic bdsnew ell swd lanothrengl ///
		poor age
	tab sex
	replace sex="1" if sex=="F"
	replace sex="0" if sex=="M"
	destring sex, replace
	rename sex female
	tab grade
	replace grade=0 if grade==98
	rename ethnic2 ethnic
	rename swd sped
	label var sped "special ed"
	rename lanothrengl eng_home
	label var eng_home "1=home language not english"
	rename age age
	gen year=20`i'
	compress
	save demo`i'.dta, replace
}
.
	
use "S:\AnalyticFiles\Student Level Files Stata\y201516f.dta", clear
keep newid zmath zread sex grade ethnic bdsnew ell swd lanothrengl ///
	lunch age
tab sex
replace sex="1" if sex=="F"
replace sex="0" if sex=="M"
destring sex, replace
rename sex female
tab grade
replace grade=0 if grade==98
rename ethnic2 ethnic
rename swd sped
label var sped "special ed"
rename lanothrengl eng_home
label var eng_home "1=home language not english"
rename age age
rename lunch poor
gen year=2016
compress
save demo16.dta, replace

forvalues i=12/15 {
	append using demo`i'.dta
	erase demo`i'.dta
}
.
label var ell "English language learner"
drop if missing(newid)|missing(year)
compress
save newid-demo12-16.dta, replace
erase demo16.dta
}
.

*** assemble distance, fitnessgram, demographics
merge 1:1 newid year using newid_distance_12-16.dta
drop _merge
drop if missing(newid)|missing(year)|newid=="."
merge 1:1 newid year using newid-fg.dta
drop _merge
drop if missing(newid)|missing(year)|newid=="."
compress
save fresh-data_2012-2016_service-area.dta, replace
erase newid-demo12-16.dta
erase newid_distance_12-16.dta
erase  newid-fg.dta

********************************************************************************
************ add 2010 census tract info ****************************************
********************************************************************************
* extract unique xy coordinates between 12-16
* spatial join with 2010 census tract shapefile
{
cd "C:\Users\wue04\Box Sync\fresh\data"
import delimited unique_xy.csv, clear
drop year id
duplicates drop x y, force
compress
save xy14-16.dta, replace
forvalues i=12/13 {
	import delimited "H:\Personal\food environment paper 1\students' addresses\unique_xy`i'.csv", clear
	drop year id
	duplicates drop x y, force
	save xy`i'.dta, replace
}
.
append using xy12.dta
append using xy14-16.dta
duplicates drop x y, force
drop if missing(x)|missing(y)
compress
export delimited unique_xy12-16.csv, replace

erase xy14-16.dta
erase xy12.dta
erase xy13.dta
}
.

********************************************************************************
************ add 2010 census tract info to master data *************************
********************************************************************************
cd "C:\Users\wue04\Box Sync\fresh\data"
import delimited 2010ct_students.txt, clear
tab county state
drop if state!="36"
keep x y geo_id
rename geo_id ct2010
unique(x y)
merge 1:m x y using "S:\Personal\hw1220\fresh\data\fresh-data_2012-2016.dta"
label var ct2010 "census tract number 2010"
compress
save "S:\Personal\hw1220\fresh\data\fresh-data_2012-2016.dta", replace












