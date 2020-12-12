*———————————————————————————————————————————————————*
*													*
*				信贷与GDP关系研究do				*
*													*
*———————————————————————————————————————————————————*

*					数据说明
*
*	由于本文没有提供直接数据，因此采用了世界银行数据库的数据
*	Loan数据以Indicator：净国内信贷（现价本币单位）
*	GDP数据以Indicator：GDP（现价本币单位）
*	切换路径代码省略，自行切换路径或打开数据


*	导入数据与生成基础数据，log(GDP)与log(Loan)
use gdp_loan.dta, clear
set scheme s1color
format %ty year
tsset year
gen lngdp = log(gdp)
gen lnloan = log(loan)

*	ln图
twoway(tsline lngdp lnloan), ///
	xtitle("年份") 


*	H-P滤波对于ln周期性的检验
hprescott lnloan, stub(lnloan_HP)
hprescott lngdp, stub(lngdp_HP)
*		H-P滤波对于周期性的作图
twoway(tsline lngdp_HP_lngdp_1 lnloan_HP_lnloan_1), ///
	title("H-P滤波的周期性检验") ///
	xtitle("年份")
	
*		H-P滤波后的趋势性作图
twoway(tsline lngdp_HP_lngdp_sm_1 lnloan_HP_lnloan_sm_1), ///
	xtitle("年份") 

*	VAR分析的补充作用
varsoc lngdp lnloan
varbasic lngdp lnloan, lags(3)
varstable, graph

*	一阶差分稳定性
gen d1loan = D.loan 
gen d1gdp = D.gdp
gen d1lngdp = D.lngdp
gen d1lnloan = D.lnloan

*	VECM分析
qui vec lngdp lnloan, lags(3) rank(1)
vecstable, graph

*	VECM预测分析
qui vec lngdp lnloan if year < 2010 & year >1985, lags(2) rank(1)
fcast compute f_, step(10) replace
fcast graph f_lngdp f_lnloan, observed lpattern("_")

*	作图过程
twoway line gdp loan year, ///
	lpattern(solid dash) ///
	title("信贷余额与国内生产总值的历史成分") ///
	xtitle("年份") ///

*	稳健性检验
*		利用VAR模型检验对于采取了控制后的影响
qui varsoc lngdp lnloan pctgrothcap pctprivateloan pctstkmkttrade officalfxr 
varbasic lngdp lnloan pctgrothcap pctprivateloan pctstkmkttrade officalfxr, lags(3)
varstable, graph
