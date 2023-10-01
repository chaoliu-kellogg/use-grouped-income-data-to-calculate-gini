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

**# Method 2: use formula #
gcollapse (mean) W = income [aw = pop], by(county) merge
bys county: gegen totalpop = sum(pop)
gen share = pop / totalpop
tempfile tmp
save `tmp', replace

rename * *1
rename county1 county
joinby county using `tmp'
gen aux = abs(income1 - income) * share * share1 / (2 * W1)
bys county: gegen gini = sum(aux)
gduplicates drop county, force
keep county gini
save "gini_method2.dta", replace
timer off 1
timer list 1