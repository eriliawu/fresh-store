* assemble dataset for fresh store study
* AY 2012-2016

clear all
set more off

********************************************************************************
************ extract unique xy, AY14-16 ****************************************
********************************************************************************
{ //extract unique xy coords, AY14-16
cd "S:\Personal\hw1220\fresh"

forvalues i=14/16 {
	use "S:\Restricted Data\Geocoding\AP\newid ap coordinates 20`i'.dta", clear
	rename WA2_XCoordinate x
	rename WA2_YCoordinate y
	rename WA2_BBL bbl
	keep year newid x y bbl
	compress
	save xy`i'.dta, replace
}
.

forvalues i=14/15 {
	append using xy`i'.dta
	erase xy`i'.dta
}
.
compress
save xy14-16.dta
erase xy16.dta

keep x y year
duplicates drop x y year, force
drop if missing(x)|missing(y)|missing(year)
gen id=_n
save "C:\Users\wue04\Box Sync\fresh\data\unique_xy.dta", replace
export delimited "C:\Users\wue04\Box Sync\fresh\data\unique_xy.csv", replace
}
.

********************************************************************************
************ link raw distance output to xy coords *****************************
********************************************************************************
{ //link distance output ArcGIS to XY coords
cd "C:\Users\wue04\Box Sync\fresh"
foreach i in 12 14 15 16 {
	import delimited raw-output\dist`i'.csv, clear
	keep incidentid total_length name
	rename incident id
	rename total dist
	gen year=20`i'
	compress
	save data\dist`i'.dta, replace
}
.

import delimited raw-output\dist13.csv, clear
keep incidentid total_length name
rename incident id
rename total dist
gen year=2013
drop if dist>5280
compress
save data\dist13.dta, replace

foreach i in 12 14 15 16 {
	append using data\dist`i'.dta
	erase data\dist`i'.dta
}
.
save data\dist_allyears.dta, replace
erase data\dist13.dta

import delimited data\unique_xy.csv, clear
bys year: gen id2=_n
rename id id3
rename id2 id
rename id3 id2
compress
save data\unique_xy14-16.dta, replace

forvalues i=12/13 {
	import delimited "H:\Personal\food environment paper 1\students' addresses\unique_xy`i'.csv", clear
	compress
	save data\unique_xy`i'.dta
}
.
append using data\unique_xy14-16.dta
append using data\unique_xy12.dta
compress
save data\unique_xy_allyears.dta, replace
erase data\unique_xy12.dta
erase data\unique_xy13.dta
erase data\unique_xy14-16.dta

merge 1:1 id year using data\dist_allyears.dta
drop id* _merge
label var name "nearest fresh store"
label var dist "dist to nearest fresh store"
compress
save data\dist_allyears_withxy.dta, replace
erase data\unique_xy_allyears.dta
}
.

********************************************************************************
************ link xy to newid **************************************************
********************************************************************************
{ //link xy to newid
cd "S:\Personal\hw1220\fresh\data"
use "S:\Restricted Data\Geocoding\AP\newid ap coordinates 2012.dta", clear
drop WA2_L* res_boro zip
rename xcoord x
rename ycoord y
rename WA2_BBL bbl
compress
save newid_xy12.dta, replace

use "S:\Restricted Data\Geocoding\AP\newid ap coordinates 2013.dta", clear
drop WA2_L* res*
rename xcoord x
rename ycoord y
rename WA2_BBL bbl
compress
save newid_xy13.dta, replace

forvalues i=14/16 {
	use "S:\Restricted Data\Geocoding\AP\newid ap coordinates 20`i'.dta", clear
	drop WA2_AP WA2_Bin
	rename WA2_X x
	rename WA2_Y y
	rename WA2_BBL bbl
	compress
	save newid_xy`i'.dta
}
.

forvalues i=12/15 {
	append using newid_xy`i'.dta
	erase newid_xy`i'.dta
}
.
drop WA2*
destring x y, replace
merge m:1 x y year using "C:\Users\wue04\Box Sync\fresh\data\dist_allyears_withxy.dta"
drop if missing(newid)
compress
drop _merge
label var newid ""
label var bbl "GBAT BBL"
label var x "home x coordinate"
label var y "home y coordinate"
save "S:\Personal\hw1220\fresh\data\student-level-dist.dta", replace

cd "C:\Users\wue04\Box Sync\fresh\data"
erase dist_allyears.dta
erase dist_allyears_withxy.dta
erase newid_xy17.dta
}
.

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
