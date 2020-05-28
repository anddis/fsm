capture log close
log using "lab4", smcl replace
//_1
version 14
use https://raw.githubusercontent.com/anddis/fsm/master/data/lab4_1.dta, clear
run https://raw.githubusercontent.com/anddis/fsm/master/do/mlci.do
//_2
stset y, fail(d)
sts graph, by(x) cens(single) name(km, replace) 
graph export km.png, replace
//_3
local lambda = "exp({theta})"
local G = "(log(y)-({beta0}+{beta1}*x))/`lambda'"
local g = "1/(`lambda'*y)"
local f = "exp(-(`G'))/((1+exp(-(`G')))^2)*`g'"
local S = "1-1/(1+exp(-(`G')))"
mlexp ((d==1)*ln(`f') + (d==0)*ln(`S'))
mlci exp /beta1
mlci exp /theta
//_4
gen fhat_y1 = exp(-((ln(y)-(_b[/beta0]+_b[/beta1]*x))/exp(_b[/theta])))/((1+exp(-(ln(y)-(_b[/beta0]+_b[/beta1]*x))/exp(_b[/theta])))^2)*1/(exp(_b[/theta])*y)
tw (line fhat_y1 y, sort), name(p1, replace) by(x) ylabel(0(0.1)0.3)
graph export p1.png, replace
//_5
gen Shat_y1 = 1-1/(1+exp(-((ln(y)-(_b[/beta0]+_b[/beta1]*x))/exp(_b[/theta]))))
sts graph, by(x) name(km1, replace) addplot((line Shat_y1 y if x == 0, sort) ///
(line Shat_y1 y if x == 1, sort))
graph export km1.png, replace
//_6
rcsgen y, gen(V) dgen(v) df(2)
local lambda = "exp({theta})"
local G = "(log(y)+{eta1}*y+{eta2}*V2-({beta0}+{beta1}*x))/`lambda'"
local g = "(1/y+{eta1}+{eta2}*v2)/`lambda'"
local f = "exp(-(`G'))/((1+exp(-(`G')))^2)*`g'"
local S = "1-1/(1+exp(-(`G')))"
mlexp ((d==1)*ln(`f') + (d==0)*ln(`S'))
mlci exp /beta1
mlci exp /theta

test  [eta1]_cons [eta2]_cons
//_7
gen fhat_y2 = exp(-((ln(y)+_b[/eta1]*y+_b[/eta2]*V2-(_b[/beta0]+_b[/beta1]*x))/exp(_b[/theta])))/((1+exp(-(ln(y)+_b[/eta1]*y+_b[/eta2]*V2-(_b[/beta0]+_b[/beta1]*x))/exp(_b[/theta])))^2)*(1/y+_b[/eta1]+_b[/eta2]*v2)/(exp(_b[/theta]))
tw (line fhat_y1 fhat_y2 y, sort), name(p3, replace) by(x) ylabel(0(0.1)0.3) legend(rows(1))
graph export p2.png, replace
//_8
gen Shat_y2 = 1-1/(1+exp(-(ln(y)+_b[/eta1]*y+_b[/eta2]*V2-(_b[/beta0]+_b[/beta1]*x))/exp(_b[/theta])))
sts graph, by(x) name(km2, replace) addplot((line Shat_y1 Shat_y2 y if x == 0, sort) ///
(line Shat_y1 Shat_y2 y if x == 1, sort))
graph export km2.png, replace
//_9
local k = "exp({theta})"
local G = "`k'*log(y)+{beta0}+{beta1}*x"
local g = "(`k'/y)"
local H = "exp(`G')"
local h = "`H'*`g'"
mlexp ((d==1)*(ln(`h')-`H') + (d==0)*(-`H'))
//_10
gen fhat_y3 = exp(ln(exp(exp(_b[/theta])*log(y)+_b[/beta0]+_b[/beta1]*x)*(exp(_b[/theta])/y))-exp(exp(_b[/theta])*log(y)+_b[/beta0]+_b[/beta1]*x))
tw (line fhat_y1 fhat_y2 fhat_y3 y, sort), name(p3, replace) by(x) ylabel(0(0.1)0.3) legend(rows(1))
graph export p3.png, replace
//_11
local k = "exp({theta})"
local G = "`k'*log(y)+{eta1}*y+{eta2}*V2+{beta0}+{beta1}*x"
local g = "(`k'/y+{eta1}+{eta2}*v2)"
local H = "exp(`G')"
local h = "`H'*`g'"
mlexp ((d==1)*(ln(`h')-`H') + (d==0)*(-`H'))

test  [eta1]_cons [eta2]_cons
//_12
gen fhat_y4 = exp(ln(exp(exp(_b[/theta])*log(y)+_b[/eta1]*y+_b[/eta2]*V2+_b[/beta0]+_b[/beta1]*x)*(exp(_b[/theta])/y+_b[/eta1]+_b[/eta2]*v2))-exp(exp(_b[/theta])*log(y)+_b[/eta1]*y+_b[/eta2]*V2+_b[/beta0]+_b[/beta1]*x))
tw (line fhat_y1 fhat_y2 fhat_y3 fhat_y4 y, sort), name(p4, replace) by(x) ylabel(0(0.1)0.3) legend(rows(1))
graph export p4.png, replace
//_13
gen Shat_y4 = exp(-exp(exp(_b[/theta])*log(y)+_b[/eta1]*y+_b[/eta2]*V2+_b[/beta0]+_b[/beta1]*x))
sts graph, by(x) name(km3, replace) addplot((line Shat_y1 Shat_y2 Shat_y4 y if x == 0, sort) ///
(line Shat_y1 Shat_y2 Shat_y4 y if x == 1, sort)) legend(cols(4))
graph export km3.png, replace
//_14
gen hhat_y4 = exp(exp(_b[/theta])*log(y)+_b[/eta1]*y+_b[/eta2]*V2+_b[/beta0]+_b[/beta1]*x) * ///
(exp(_b[/theta])/y+_b[/eta1]+_b[/eta2]*v2)
tw (line hhat_y4 y  if x == 0, sort) (line hhat_y4 y  if x == 1, sort), ///
yscale(log) name(p5, replace)
graph export p5.png, replace
//_15
cap net install stpm2, from(http://fmwww.bc.edu/RePEc/bocode/s)
stpm2 x, df(3) scale(h) noorthog nolog
di e(ln_bhknots)

gen double z = log(y)
rcsgen z, gen(z_rcs) dgen(z_d_rcs) knots(-2.465104022491821 .223943231484774 1.641711472984396 3.091360584567398)
local G = "{eta0}*z+{eta1}*z_rcs2+{eta2}*z_rcs3+{beta0}+{beta1}*x"
local g = "({eta0}+{eta1}*z_d_rcs2+{eta2}*z_d_rcs3)"
local H = "exp(`G')"
local h = "`H'*`g'"
mlexp ((d==1)*ln(`h')-`H'), from(eta0=1 eta1=0 eta2=0 beta0=0 beta1=0)
//_^
log close
