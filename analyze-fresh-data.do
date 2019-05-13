* analyze data for fresh store study
* AY 2012-2016

clear all
set more off

cd "C:\Users\wue04\Box Sync\fresh"
use "S:\Personal\hw1220\fresh\data\fresh-data_2012-2016.dta", clear

* set up sample
tab grade
global sample !missing(zbmi) & !missing(obese) & !missing(female) & !missing(age) ///
	& !missing(ethnic) & grade>=0 & grade<=12 &!missing(x)
count if $sample
tab year if $sample

* by year analysis
foreach var in 528 1320 {
	gen dist`var'=(dist<=`var')
	replace dist`var'=0 if missing(dist`var')
	label var dist`var' "having a FRESH store within `var' ft."
}
.

forvalues i=12/16 {
	foreach dist in 528 1320 {
		* sample size
		bys dist`dist': count if year==20`i' & $sample
		* mean dist to FRESH
		bys dist`dist': sum dist if year==20`i' & $sample
		* zbmi, age
		foreach var in zbmi age {
			bys dist`dist': sum `var' if year==20`i' & $sample
		}
		* obese, female, race
		foreach var in obese female ethnic {
			tab `var' dist`dist' if year==20`i' & $sample, col
		}
	}
}
.
*drop dist528 dist1320

* see what stores get how many students every year
split name, p(" - ")
drop name name1
rename name2 name
label var name "nearest FRESH store"
save "S:\Personal\hw1220\fresh\data\fresh-data_2012-2016_replace.dta", replace

forvalues i=12/16 {
	tab name if year==20`i' & dist528==1 & $sample
}
.

forvalues i=12/16 {
	tab name if year==20`i' & dist1320==1 & $sample
}
.


