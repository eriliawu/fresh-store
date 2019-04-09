* analyze data for fresh store study
* AY 2012-2016

clear all
set more off

cd "C:\Users\wue04\Box Sync\fresh"
use "S:\Personal\hw1220\fresh\data\fresh-data_2012-2016.dta", replace

* by year
forvalues i=12/16 {
	tab obese if dist<=1320 & year==20`i'
	tab obese if (dist>1320|missing(dist)) & year==20`i'
}
.
