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
import delimited raw-output\service-area\s12.csv, clear
drop if name==" "
keep id x y name frombreak tobreak
duplicates tag id, gen(dup)
tab dup //no student has access to two stores
tab frombreak
split name, p(" : ")
drop from tobreak dup name
rename name1 name
label define distance 1 "0 - 528" 2 "528 - 1320" 3 "1320 - 2640"
encode name2, gen(nearest) label(dsitance)




********************************************************************************
************ link xy to newid **************************************************
********************************************************************************

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
merge 1:1 newid year using student-level-dist.dta
save student-level-dist-fg.dta, replace
erase student-level-dist.dta
}
.

********************************************************************************
************ link to student demo data *****************************************
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
gen year=2016
rename lunch poor
compress
save demo16.dta, replace

forvalues i=12/15 {
	append using demo`i'.dta
	erase demo`i'.dta
}
.
label var ell "English language learner"
compress
drop if missing(newid)|missing(year)
merge 1:1 newid year using student-level-dist-fg.dta
drop _merge 
drop female_fg bds age_mo
order newid year bdsnew eng_home grade age x y bbl weight_kg-bmipct ///
	female zmath-sped poor ethnic
sort newid year
drop if missing(newid)|missing(year)|newid=="."
compress
save fresh-data_2012-2016.dta, replace
erase student-level-dist-fg.dta
erase demo16.dta
erase unique_xy.dta
}
.

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

********************************************************************************
************ re-compute 12/13 data *********************************************
********************************************************************************
*** extract unique xy coordinates
*** from new-geocoded data, stamped 2019
cd "C:\Users\wue04\Box Sync\fresh\data"
use "S:\Restricted Data\Geocoding\AP\newid ap coordinates 2012.dta", clear
keep year xcoord ycoord
duplicates drop x ycoord, force
drop if missing(xcoord)|missing(ycoord)
gen id=_n
compress
export delimited s12_new1.csv, replace

use "S:\Restricted Data\Geocoding\AP\newid ap coordinates 2013.dta", clear
keep year xcoord ycoord
duplicates drop x ycoord, force
drop if missing(xcoord)|missing(ycoord)
gen id=_n
compress
export delimited s13_new.csv, replace

*** connect distance output to unique xy coordinates (id)
cd "C:\Users\wue04\Box Sync\fresh\data"
forvalues i=12/13 {
	import delimited "C:\Users\wue04\Box Sync\fresh\raw-output\dist`i'_new.csv", clear
	keep incidentid total name
	split name, p(" - ")
	drop name name1
	rename name2 name
	rename inci id
	rename total dist
	gen year=20`i'
	compress
	save s`i'_clean.dta, replace
}
.
append using s12_clean.dta
save s12_13_clean.dta, replace
erase s12_clean.dta
erase s13_clean.dta

*** connect unique xy coordinates to all students
forvalues i=12/13 {
	import delimited s`i'_new.csv, clear
	save s`i'_new.dta, replace
}
.
append using s12_new.dta
merge 1:1 id year using s12_13_clean.dta
count
rename xcoo x
rename ycoo y
drop _merge
rename  dist dist2
rename name name2
compress
drop id
save s1213_xy_dist.dta, replace
erase s12_new.dta
erase s13_new.dta
erase s12_13_clean.dta

merge 1:m x y year using "S:\Personal\hw1220\fresh\data\fresh-data_2012-2016.dta"
drop if _mer==1
drop _mer
sum dist2
foreach var in dist name {
	replace `var'2=`var' if year==2014|year==2015|year==2016
}
.
compress
save "fresh-data_2012-2016_replace.dta", replace

*** replace 2013 data yet again
cd "C:\Users\wue04\Box Sync\fresh"
import delimited raw-output\dist13_re-run.csv, clear
keep name incidentid total
rename inci id
rename total dist
split name, p(" - ")
drop name name1
rename name2 name
compress
save data\temp13.dta, replace

import delimited "H:\Personal\food environment paper 1\students' addresses\unique_xy13.csv", clear
merge m:1 id using data\temp13.dta
drop id _merge
rename dist dist13
compress
merge 1:m x y year using "S:\Personal\hw1220\fresh\data\fresh-data_2012-2016_replace.dta"


erase data\temp13.dta













