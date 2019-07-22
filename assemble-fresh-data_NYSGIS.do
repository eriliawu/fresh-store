* assemble dataset for fresh store study
* using service area method
* use 2014 LION map for all calculations
* AY 2012-2016

clear all
set more off

cd "C:\Users\wue04\Box Sync\fresh"

import delimited raw-output\NYS-GIS-2014\closest_allyears.csv, clear
keep name incidentid total
rename inci id
rename total dist
split name, p(" - ")
drop name name1
rename name2 name
merge 1:1 id using data\address\xy12-16_unique.dta
drop _merge id
drop if missing(x)|missing(y)
duplicates tag x y, gen(dup) //sanity check
tab dup
drop dup
compress
save data\xy_dist_allyears.dta, replace

cd "S:\Personal\hw1220\fresh\data"
forvalues i=12/16 {
	use "S:\Restricted Data\Geocoding\AP\newid ap coordinates 20`i'.dta"
	keep xcoord ycoord newid year
	compress
	save newid_xy`i'.dta, replace
}
.

forvalues i=12/15 {
	append using newid_xy`i'.dta
	erase newid_xy`i'.dta
}
.
tab year
rename xcoord x
rename ycoord y
destring x y, replace
merge m:1 x y using "C:\Users\wue04\Box Sync\fresh\data\xy_dist_allyears.dta"
order newid year
drop _merge
compress
save fresh-data_2012-2016_NYSGIS.dta, replace

erase "S:\Personal\hw1220\fresh\data\newid_xy16.dta"
erase "C:\Users\wue04\Box Sync\fresh\data\xy_dist_allyears.dta"

*** analytics
cd "C:\Users\wue04\Box Sync\fresh"
use S:\Personal\hw1220\fresh\data\fresh-data_2012-2016_NYSGIS.dta, clear

bys year: tab name if dist<=528
bys year: tab name if dist<=1320
bys year: tab name if dist<=2640













