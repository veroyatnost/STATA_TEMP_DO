* 初始化
cls
clear
drop _all
use PanelDataCPIA.dta

* 调整数据格式
reshape long price dc do pi pgdp pops s,i("region") j(year)
egen id = group(region) 

* 取对数数据
gen lnprice = log(price)
gen lndc = log(dc)
gen lndo = log(do)
gen lnpi = log(pi)
gen lnpgdp = log(pgdp) 
gen lnpops = log(pops)
gen lns = log(s)

* 设置面板计量
xtset id year


* 基本统计量
asdoc sum lnprice lndc lndo lnpi lnpgdp lnpops lns, save(results/sums.doc) title(Summary)

* 作图
// twoway line price year, by(region)  scheme(plotplain)

* 单位根检验（其他略）
xtunitroot llc lnprice , trend
xtunitroot ht lnprice , trend
xtunitroot breitung lnprice , trend

* 随机效应检验
qui xtreg lnprice lndc lndo lnpi lnpgdp lnpops lns,re
xttest0
qui xtreg lnprice lndc lndo lnpi lnpgdp lnpops lns D.lnprice D.lndc D.lndo D.lnpi D.lnpgdp D.lnpops D.lns, re
asdoc xttest0, save(results/randomTest.doc) title(Random Effect Test)

* 豪斯曼检验
qui xtreg lnprice lndc lndo  ,re
est store re
qui xtreg lnprice lndc lndo  , fe
est store fe
hausman fe re
asdoc hausman fe re, save(results/hausman.doc) title(Hausman Test), replace



* 面板模型

qui xtreg lnprice lndc lndo, re
est store e2

qui xtreg lnprice lndc lndo lnpi lnpgdp lnpops lns, re
est store e3

qui xtreg lnprice lndc lndo, fe
est store e4

qui xtreg lnprice lndc lndo lnpi lnpgdp lnpops lns, fe
est store e5

* 序列相关检验
asdoc xtserial lnprice lndc lndo lnpi lnpgdp lnpops lns, save(results/serialTest.doc) title(serial Test)

qui xtreg lnprice lndc lndo lnpi lnpgdp lnpops lns D.lnprice D.lndc D.lndo D.lnpi D.lnpgdp D.lnpops D.lns, fe
est store e6

* 异方差检验
asdoc xttest3, save(results/hetek.doc)

* 使用稳健回归
qui xtreg lnprice lndc lndo lnpi lnpgdp lnpops lns D.lnprice D.lndc D.lndo D.lnpi D.lnpgdp D.lnpops D.lns, fe r
est store e7

* 结果输出
reg2docx e2 e3 e4 e5 e6 e7 using result.docx, ///
	ar2(%9.2f) b(%9.3f) t(%7.2f) r2(%9.3f) ///
	title("Results") replace
