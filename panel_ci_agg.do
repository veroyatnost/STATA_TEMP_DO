////clear
////cls

////use data/panel.dta, replace
reshape long pgdp cia cap ilit pat pct3rd urban highway, i("地区") j(year)
rename 地区 Area
egen id = group(Area)
gen cia2 = cia^2
gen lnpgdp = log(pgdp)
gen lncap = log(cap)
gen lnilit = log(ilit)
gen lnpat = log(pat)

sum
*	面板數據
xtset id year

*	Pooldata
*	无CIA^2与控制项
qui xtreg lnpgdp cia, vce(robust)
est store basic

*	Pooldata
*	无控制项
qui xtreg lnpgdp cia cia2, vce(robust)
est store sqrbasic

*	Pooldata
qui xtreg lnpgdp cia cia2 lncap lnilit pat pct3rd urban highway, vce(robust)
est store poolmodel

*	Fixed
*	无CIA^2与控制项
qui xtreg lnpgdp cia, fe vce(robust)
est store febasic

*	Fixed
*	无控制项
qui xtreg lnpgdp cia cia2, fe vce(robust)
est store fesqrbasic

*	Fixed 
qui xtreg lnpgdp cia cia2 lncap lnilit pat pct3rd urban highway, fe vce(robust) 
est store femodel

*	結果輸出
reg2docx basic sqrbasic poolmodel febasic fesqrbasic femodel using result.docx, replace
