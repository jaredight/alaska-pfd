/*
Jared Wright
jaredwright217@gmail.com
This .do file creates a graph of Alaska's PFD dividend over time alongside the unemployment rate in Alaska.
*/

clear all
cd "C:\Users\jaredmw2\Documents\CTL_analysis"

* Clean unemployment rate data
use unemp_rate.dta, clear
rename laust020000000000003a unemp_rate
gen year = year(date(observation_date, "YMD"))
keep year unemp_rate 
save unemp_rate_clean.dta, replace

* Clean CPI data from 1984 to 2021
use cpi_1984_2021.dta, clear
rename cuusa427sa0 cpi
gen date = date(observation_date, "YMD")
format date %td
keep if month(date) == 7
gen year = year(date)
keep year cpi
save cpi_1984_2021_clean.dta, replace

* Clean CPI data from 1960 to 1986
use cpi_1960_1986.dta, clear
rename cuura427sa0 cpi
gen date = date(observation_date, "YMD")
format date %td
keep if month(date) == 7
gen year = year(date)
keep year cpi
save cpi_1960_1986_clean.dta, replace

* Clean PFD data
use pfd, clear
replace dividendamount = subinstr(dividendamount, "$", "", .)
replace dividendamount = subinstr(dividendamount, ",", "", .)
destring dividendamount, replace
rename dividendyear year
keep year dividendamount

* Merge datasets together
merge 1:1 year using unemp_rate_clean, nogen
merge 1:1 year using cpi_1984_2021_clean.dta, nogen
merge 1:1 year using cpi_1960_1986_clean.dta, nogen update
keep if 1982 <= year & year <=2020
gen adj_dividend = 100 * dividendamount / cpi
correlate adj_dividend unemp_rate

* Create graph
label variable year "Year"
label variable adj_dividend "Inflation Adjusted PFD"
label variable unemp_rate "Unemployment Rate in Alaska"
twoway (line adj_dividend year, ytitle("Inflation Adjusted PFD (1984 USD)") yaxis(1)) (line unemp_rate year, yaxis(2)), scheme(s1color) legend(rows(2)) title("Alaskan Unemployment and PFD 1982-2020")
graph export "Alaskan Unemployment and PFD 1982-2020.jpg", replace


