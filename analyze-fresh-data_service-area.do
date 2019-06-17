* analyze data for fresh store study
* AY 2012-2016

clear all
set more off

cd "C:\Users\wue04\Box Sync\fresh"
use "S:\Personal\hw1220\fresh\data\fresh-data_2012-2016_service-area.dta", clear

* set up sample
tab grade
global sample !missing(zbmi) & !missing(obese) & !missing(female) & !missing(age) ///
	& !missing(ethnic) & grade>=0 & grade<=12 & !missing(x) & !missing(y)
count if $sample
tab year if $sample

* store coverage, by year
bys year: tab name if nearest==1 & $sample
bys year: tab name if nearest==3 & $sample
bys year: tab name if nearest==2 & $sample
