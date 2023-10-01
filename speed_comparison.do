//speed comparison of two methods
clear all
set more off
cd "C:\Users\ccerl\Dropbox\inequality and housing\gini_notes"

tempname method1
postfile `method1' num_c run_time1 using "time_method1.dta", replace

**# Method 1: use inequal7 #1
forv i = 100(100)3000 {
	
	timer clear 1
	timer on 1
	use "grouped_income.dta", clear
	keep if county <= `i'
	gen gini = ""
	glevelsof county, local(county)
	foreach location of local county {
		inequal7 income [aw = pop] if county == `location'
		replace gini = r(gini) if county == `location'
	}
	gduplicates drop county, force
	destring gini, replace force
	keep county gini
	timer off 1
	timer list
	post `method1' (`i') (r(t1))
	

}
postclose `method1'


**# Method 2: use formula #
tempname method2
postfile `method2' num_c run_time2 using "time_method2.dta", replace

forv i = 100(100)3000 {

	timer clear 1
	timer on 1
	use "grouped_income.dta", clear
	keep if county <= `i'
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
	timer off 1
	timer list
	post `method2' (`i') (r(t1))
}
postclose `method2'

**# plot #
use "time_method1", clear
merge 1:1 num_c using "time_method2", keep(3) nogen
twoway (connected run_time1 num_c) (connected run_time2 num_c), title(Speed Comparison) plotregion(style(none)) xscale(line fextend) yscale(line fextend) xtitle(Number of Counties) ytitle(Time) xlabel(0(500)3000) legend(ring(0) pos(10) row(2) order(1 "Method 1" 2 "Method 2"))
graph export "speed.png", as(png) replace



