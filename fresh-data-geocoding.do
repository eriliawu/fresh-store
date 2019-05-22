* assemble dataset for fresh store study
* AY 2012-2016

clear all
set more off

*** assemble output files
cd "C:\Users\wue04\Box Sync\fresh"
forvalues i=12/13 {
	import delimited raw-output\dist`i'_new.csv, clear
	keep name incidentid total
	gen year=20`i'
	compress
	save data\dist`i'.dta, replace
}
.
forvalues i=14/16 {
	import delimited raw-output\dist`i'.csv, clear
	keep name incidentid total
	gen year=20`i'
	compress
	save data\dist`i'.dta, replace
}
.
forvalues i=12/15 {
	append using data\dist`i'.dta
	erase data\dist`i'.dta
}
.
rename inci id
rename total dist
tab year
split name, p(" - ")
drop name name1
rename name2 name
compress
save data\dist_all_years.dta, replace
erase data\dist16.dta

*** clean student xy
forvalues i=12/13 {
	import delimited data\s`i'_new.csv, clear
	rename xcoo x
	rename ycoo y
	compress
	save data\xy`i'.dta, replace
}
.
import delimited data\unique_xy.csv, clear
sort id
*tab year
replace id=id-300491 if year==2014
replace id=id-601214 if year==2015
compress
append using xy12.dta
append using xy13.dta
merge m:1 id year using data\dist_all_years.dta
drop id _merge
save data\dist-to-xy.dta, replace
erase data\dist_all_years.dta
erase data\xy12.dta
erase data\xy13.dta

*** link to newid
use "S:\Restricted Data\Geocoding\AP\newid ap coordinates 2012.dta", clear
forvalues i=13/16 {
	append using "S:\Restricted Data\Geocoding\AP\newid ap coordinates 20`i'.dta"
}
.
keep newid year xcoo ycoo
rename xcoo x
rename ycoo y
destring x y, replace
drop if missing(x)|missing(y)
compress
merge m:1 x y year using data\dist-to-xy.dta
drop _merge
save "S:\Personal\hw1220\fresh\data\fresh-data_2012-2016_geocoding.dta", replace

bys year: tab name if dist<=528
