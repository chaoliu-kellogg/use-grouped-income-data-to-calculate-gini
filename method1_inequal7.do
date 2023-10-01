//Using grouped income data to calculate Gini coefficient
clear all
set more off
timer clear 1
timer on 1

cd "C:\Users\ccerl\Dropbox\inequality and housing\gini_notes"
use "grouped_income.dta", clear
/*
county: location id
income: income level
pop: number of people with this income level
*/

**# Method 1: use inequal7 #1
gen gini = ""
glevelsof county, local(county)
foreach location of local county {
	inequal7 income [aw = pop] if county == `location'
	replace gini = r(gini) if county == `location'
}
gduplicates drop county, force
destring gini, replace force
keep county gini
save "gini_method1.dta", replace
timer off 1
timer list 1