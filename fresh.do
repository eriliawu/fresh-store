* student AP addresses

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

forvalues i=14/17 {
	use "S:\Restricted Data\Geocoding\AP\newid ap coordinates 20`i'.dta", clear
	drop WA2_AP WA2_Bin
	rename WA2_X x
	rename WA2_Y y
	rename WA2_BBL bbl
	compress
	save newid_xy`i'.dta
}
.

forvalues i=12/16 {
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
save student-level-dist.dta, replace
cd "C:\Users\wue04\Box Sync\fresh\data"
erase dist_allyears.dta
erase dist_allyears_withxy.dta

********************************************************************************
************ assemble fitnessgram data *****************************************
********************************************************************************
use "S:\Restricted Data\Fitnessgram\Panel\2009-2017 obesitymeasures JB - 11-13-18.dta", clear


