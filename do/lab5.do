capture log close
log using "lab5", smcl replace
//_1
version 14
use https://raw.githubusercontent.com/anddis/fsm/master/data/lab5_1.dta, clear
run https://raw.githubusercontent.com/anddis/fsm/master/do/mlci.do
//_2
local G = "(log(y)-{mu})/exp({theta})"
local g = "(1/exp({theta})/y)"
local eta = "invlogit({gamma0}+{gamma1}*y)"
local f1 = "normalden(`G')*`g'"
local f2 = "`eta'^(d==1)*(1-`eta')^(d==2)"
mlexp (log(`f1'*`f2')) if d != 0
mlci exp /theta
mlci invlogit /gamma0
mlci exp /gamma1
//_3
gen fhat_y = normalden((log(y) - _b[/mu]) / exp(_b[/theta]))*(1 / y / exp(_b[/theta]))
tw  (line fhat_y y, sort), name(p1, replace) legend(rows(1))

gen fhat_dy = invlogit(_b[/gamma0]+_b[/gamma1]*y) if d == 1
replace fhat_dy = 1-invlogit(_b[/gamma0]+_b[/gamma1]*y) if d == 2
tw (line fhat_dy y if d==1, sort lc(navy)) ///
(line fhat_dy y if d==2, sort lc(navy) lp(-)), ///
name(p2, replace)  legend(off) ylabel(0(0.2)1) 
graph combine p2 p1, name(c1, replace)
graph export c1.png, replace
//_4
tab d
local G = "(log(y)-{mu})/exp({theta})"
local g = "(1/exp({theta})/y)"
local eta = "invlogit({gamma0}+{gamma1}*y)"
local f1 = "normalden(`G')*`g'"
local S = "1-normal(`G')"
local f2 = "`eta'^(d==1)*(1-`eta')^(d==2)"
mlexp ((d!=0)*log(`f1'*`f2')+(d==0)*log(`S'))
mlci exp /theta
mlci invlogit /gamma0
mlci exp /gamma1
//_5
gen fhat_y2 = normalden((log(y) - _b[/mu]) / exp(_b[/theta]))*(1 / y / exp(_b[/theta]))
tw  (line fhat_y2 y, sort), name(p3, replace) legend(rows(1))

gen fhat_dy2 = invlogit(_b[/gamma0]+_b[/gamma1]*y) if d == 1
replace fhat_dy2 = 1-invlogit(_b[/gamma0]+_b[/gamma1]*y) if d == 2
tw (line fhat_dy2 y if d==1, sort lc(navy)) ///
(line fhat_dy2 y if d==2, sort lc(navy) lp(-)), ///
name(p4, replace) legend(rows(1)) legend(off) ylabel(0(0.2)1) 
graph combine p4 p3, name(c2, replace)
graph export c2.png, replace
//_6
sum y, meanonly
range y1 r(min) r(max)
gen f1 = normalden((log(y1)-_b[/mu])/exp(_b[/theta]))/exp(_b[/theta])/y1 * invlogit(_b[/gamma0]+_b[/gamma1]*y1)
gen f2 = normalden((log(y1)-_b[/mu])/exp(_b[/theta]))/exp(_b[/theta])/y1 * (1-invlogit(_b[/gamma0]+_b[/gamma1]*y1))
sort y1
gen F1 = sum(f1)*(r(max)-r(min))/(_N-1)
gen F2 = sum(f2)*(r(max)-r(min))/(_N-1)

stset y, fail(d==1)
stcrreg, compete(d==2)
predict cif1, basecif
stset y, fail(d==2)
stcrreg, compete(d==1)
predict cif2, basecif

tw (line cif1 cif2 y, sort connect(J J) lc(orange orange) lp(l -)) ///
(line F1 F2 y1, sort lc(navy navy) lp(l -)), legend(off) name(p5, replace)
graph export p5.png, replace
//_7
local G = "(log(y)-({beta0}+{beta1}*x))/exp({theta})"
local g = "(1/exp({theta})/y)"
local eta = "invlogit({gamma0}+{gamma1}*y+{gamma2}*x)"
local psi = "invlogit({delta})"
local f1 = "normalden(`G')*`g'"
local S = "1-normal(`G')"
local f2 = "`eta'^(d==1)*(1-`eta')^(d==2)"
local f3 = "`psi'^(x==1)*(1-`psi')^(x==0)"
mlexp ((d!=0)*log(`f1'*`f2')+(d==0)*log(`S')+log(`f3'))
mlci exp /beta1
mlci exp /theta

mlci exp /gamma1
mlci exp /gamma2

mlci invlogit /delta
//_8
gen fhat_dyx3 = invlogit(_b[/gamma0]+_b[/gamma1]*y+_b[/gamma2]*x) if d == 1
replace fhat_dyx3 = 1-invlogit(_b[/gamma0]+_b[/gamma1]*y+_b[/gamma2]*x) if d == 2
tw (line fhat_dyx3 y if x == 0 & d == 1, sort lc(navy)) ///
(line fhat_dyx3 y if x == 1 & d == 1, sort lc(maroon)) ///
(line fhat_dyx3 y if x == 0 & d == 2, sort lc(navy) lp(-)) ///
(line fhat_dyx3 y if x == 1 & d == 2, sort lc(maroon) lp(-)), ///
name(p6, replace) legend(rows(1)) legend(off) ylabel(0(0.2)1) 

gen fhat_yx3 = normalden((log(y) - (_b[/beta0]+_b[/beta1]*x)) / exp(_b[/theta]))*(1 / y / exp(_b[/theta]))
tw  (line fhat_yx3 y if x == 0, sort lc(navy)) ///
(line fhat_yx3 y if x == 1, sort lc(maroon)), name(p7, replace) legend(off)

gen fhat_x3 = invlogit(_b[/delta]) if x==1
replace fhat_x3 = 1-invlogit(_b[/delta]) if x==0

tw (dropline fhat_x3 x if x == 1, lc(maroon) lc(maroon) mc(maroon)) ///
(dropline fhat_x3 x if x == 0, lc(navy) lc(navy) mc(navy)), ///
name(p8, replace) legend(off) ylabel(0(0.2)1) xlabel(0 1) xscale(range(-.5 1.5))
graph combine p6 p7 p8, name(c3, replace) 
graph export c3.png, replace
//_9
use https://raw.githubusercontent.com/anddis/fsm/master/data/lab5_2.dta, clear

su ldl1 ldl2, detail

hist ldl1, xlabel(0/10) width(.25) name(s1, replace)   
hist ldl2, xlabel(0/10) width(.25) name(s2, replace) 
graph combine s1 s2, name(s0, replace) ycommon cols(1)
graph export s0.png, replace
//_10
local G = "(ldl1-{mu})/exp({theta})"
local g = "1 / exp({theta})"
local f1 = "normal({alpha}*`G')"
local f2 = "normalden(`G')*`g'"
mlexp (log(2*`f1'*`f2'))
gen fhat_ldl1 = 2*normal(_b[/alpha]*(ldl1-_b[/mu])/exp(_b[/theta]))*normalden((ldl1-_b[/mu])/exp(_b[/theta]))/exp(_b[/theta])
tw (hist ldl1, width(.25)) (line fhat_ldl1 ldl1, sort), name(s1, replace) xlabel(0/10)  legend(off) 

local G = "(ldl2-{mu})/exp({theta})"
local g = "1 / exp({theta})"
local f1 = "normal({alpha}*`G')"
local f2 = "normalden(`G')*`g'"
mlexp (log(2*`f1'*`f2'))
gen fhat_ldl2 = 2*normal(_b[/alpha]*(ldl2-_b[/mu])/exp(_b[/theta]))*normalden((ldl2-_b[/mu])/exp(_b[/theta]))/exp(_b[/theta])
tw (hist ldl2, width(.25)) (line fhat_ldl2 ldl2, sort), name(s2, replace) xlabel(0/10) legend(off)

graph combine s1 s2, name(p6, replace) ycommon cols(1)
graph export p6.png, replace
//_11
local f1 = "normal({alpha1}*(ldl1-{beta1})/exp({theta1}))"
local f2 = "normalden((ldl1-{beta1})/exp({theta1}))/exp({theta1})" 

local f3 = "normal({alpha2: _cons ldl1}*(ldl2-{beta2: _cons ldl1})/exp({theta2: _cons ldl1}))"
local f4 = "normalden((ldl2-{beta2:})/exp({theta2:}))/exp({theta2:})"

// The code above is equivalent to the (probably more familar) code below, but it's more compact 
// and easier to read. The output of the code above is easier to read, too.
// local f3 = "normal(({alpha20}+{alpha21}*ldl1)*(ldl2-({beta20}+{beta21}*ldl1))/exp({theta20}+{theta21}*ldl1))"
// local f4 = "normalden((ldl2-({beta20}+{beta21}*ldl1))/exp({theta20}+{theta21}*ldl1))/exp({theta20}+{theta21}*ldl1)"

mlexp(log(2*`f1'*`f2') + log(2*`f3'*`f4'))
mlexp, coeflegend // Display the legend for the model's coefficients, so that we know how to reference them
//_12
tw (scatter ldl2 ldl1, msize(tiny) msym(Oh)), name(p7, replace) 
graph export p7.png, replace

gen fhat_y2 = 2 * normal((_b[alpha2:_cons]+_b[alpha2:ldl1]*2)*(ldl2-(_b[beta2:_cons]+_b[beta2:ldl1]*2))/exp((_b[theta2:_cons]+_b[theta2:ldl1]*2))) * ///
normalden((ldl2-(_b[beta2:_cons]+_b[beta2:ldl1]*2))/exp((_b[theta2:_cons]+_b[theta2:ldl1]*2)))/exp((_b[theta2:_cons]+_b[theta2:ldl1]*2))

gen fhat_y3 = 2 * normal((_b[alpha2:_cons]+_b[alpha2:ldl1]*3)*(ldl2-(_b[beta2:_cons]+_b[beta2:ldl1]*3))/exp((_b[theta2:_cons]+_b[theta2:ldl1]*3))) * ///
normalden((ldl2-(_b[beta2:_cons]+_b[beta2:ldl1]*3))/exp((_b[theta2:_cons]+_b[theta2:ldl1]*3)))/exp((_b[theta2:_cons]+_b[theta2:ldl1]*3))

gen fhat_y5 = 2 * normal((_b[alpha2:_cons]+_b[alpha2:ldl1]*5)*(ldl2-(_b[beta2:_cons]+_b[beta2:ldl1]*5))/exp((_b[theta2:_cons]+_b[theta2:ldl1]*5))) * ///
normalden((ldl2-(_b[beta2:_cons]+_b[beta2:ldl1]*5))/exp((_b[theta2:_cons]+_b[theta2:ldl1]*5)))/exp((_b[theta2:_cons]+_b[theta2:ldl1]*5))

tw (line fhat_y2 fhat_y3 fhat_y5 ldl2, sort lc(blue purple red)), name(p8, replace) legend(rows(1))
graph export p8.png, replace
//_^
log close
