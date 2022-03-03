********************************************************************************
* name: baker_all.do
* author: scott cunningham (baylor)
* description: extending borusyak example
* last updated: february 12, 2022
********************************************************************************

clear
capture log close

use "https://github.com/scunning1975/mixtape/raw/master/baker.dta", clear

** Construct five examples

* 1. Estimation with did_imputation of Borusyak et al. (2021)
did_imputation y id year treat_date, autosample 

* 2. Estimation with did_multiplegt of de Chaisemartin and D'Haultfoeuille (2020)
did_multiplegt y id year treat, breps(10) cluster(state) 

* 3. Estimation with csdid of Callaway and Sant'Anna (2020)
csdid y, ivar(id) time(year) gvar(treat_date) notyet

* 4.  Estimation with eventstudyinteract of Sun and Abraham (2020)

drop if year>=2004
sum treat_date
gen lastcohort = treat_date==r(max) // dummy for the latest- or never-treated cohort
forvalues l = 0/5 {
	gen L`l'event = time_til==`l'
}
forvalues l = 1/14 {
	gen F`l'event = time_til==-`l'
}
drop F1event // normalize K=-1 (and also K=-15) to zero
eventstudyinteract y L*event F*event, vce(cluster id) absorb(id year) cohort(treat_date) control_cohort(lastcohort)

* 5. TWFE OLS estimation. 
reghdfe Y F*event L*event, a(i t) cluster(i)

