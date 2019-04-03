* student AP addresses

clear all
set more off

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
save data\unique_xy.dta, replace
drop if missing(x)|missing(y)|missing(year)
gen id=_n
export delimited "C:\Users\wue04\Box Sync\fresh\data\unique_xy.csv", replace
