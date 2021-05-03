capture log close
log using "lab2", smcl replace
//_1
version 14
use https://raw.githubusercontent.com/anddis/fsm/master/data/lab2.dta, clear
run https://raw.githubusercontent.com/anddis/fsm/master/do/mlci.do
//_2
net sj 16-3 gr42_7
net install gr42_7
//_3
cap net install http://fmwww.bc.edu/RePEc/bocode/r/rcsgen.pkg
//_4
hist y, bin(50) name(p1, replace) 
graph export p1.png, replace
//_5
gen log_y = log(y)
hist log_y, bin(50) name(p2, replace) 
graph export p2.png, replace
//_6
local f = "gammaden(exp({theta1}), exp({theta2}), 0, y)"
mlexp (log(`f'))
mlci exp /theta1
mlci exp /theta2
//_7
gen fhat_y = gammaden(exp(_b[/theta1]), exp(_b[/theta2]), 0, y)
tw (hist y, bin(50)) (line fhat_y y, sort), name(p3, replace) legend(rows(1))
graph export p3.png, replace
//_8
local sigma = "exp({theta})"
local G = "(log(y) - {mu}) / `sigma'"
local g = "(1 / y / `sigma')"
local f = "normalden(`G')*`g'"
mlexp (log(`f'))
mlci exp /theta
//_9
gen fhat_y2 = normalden((log(y) - _b[/mu]) / exp(_b[/theta]))*(1 / y / exp(_b[/theta]))
tw (hist y, bin(50)) (line fhat_y fhat_y2 y, sort), name(p4, replace) legend(rows(1))
graph export p4.png, replace
//_10
local sigma = "exp({theta})"
local G = "(log(y)+{eta}*log(y)^2 - {mu}) / `sigma'"
local g = "(1 + {eta}*2*log(y)) / (`sigma'*y)"
local f = "normalden(`G')*`g'"
mlexp (log(`f'))
mlci exp /theta
//_11
gen fhat_y3 = normalden((log(y)+_b[/eta]*log(y)^2 - _b[/mu])/exp(_b[/theta])) * ///
 (1+_b[/eta]*2*log(y)) / (exp(_b[/theta]) * y)
tw (hist y, bin(50)) (line fhat_y fhat_y2 fhat_y3 y, sort), name(p5, replace) legend(rows(1))
graph export p5.png, replace
//_12
rcsgen log_y, gen(V) dgen(v) df(3)
local sigma = "exp({theta})"
local G = "(log(y)+{eta1}*V2+{eta2}*V3-{mu})/`sigma'"
local g = "(1+{eta1}*v2+{eta2}*v3)/(`sigma'*y)"
local f = "normalden(`G')*`g'"
mlexp (log(`f'))
mlci exp /theta

test  [eta1]_cons [eta2]_cons
//_13
gen fhat_y4 = normalden((log(y)+_b[/eta1]*V2+_b[/eta2]*V3 - _b[/mu])/exp(_b[/theta])) * ///
 (1+_b[/eta1]*v2+_b[/eta2]*v3) / (exp(_b[/theta]) * y)
tw (hist y, bin(50)) (line fhat_y fhat_y2 fhat_y3 fhat_y4 y, sort), name(p6, replace) legend(rows(1))
graph export p6.png, replace
//_14
gen u_normal5 = normal((log(y)+_b[/eta1]*V2+_b[/eta2]*V3 - _b[/mu])/exp(_b[/theta]))

// Re-fit log-normal model (Exercise 3)
local sigma = "exp({theta})"
local G = "(log(y) - {mu}) / `sigma'"
local g = "(1 / y / `sigma')"
local f = "normalden(`G')*`g'"
mlexp (log(`f')) 
gen u_normal3 = normal((log(y) - _b[/mu])/exp(_b[/theta]))

qplot u_normal3 u_normal5, addplot(function y = x, lw(medthin)) name(p7, replace) ///
 msym(Oh Oh) msize(tiny tiny)
graph export p7.png, replace
//_15
local G = "sqrt(y)"
local g = "(0.5 / sqrt(y))"
local f = "gammaden(exp({theta1}),exp({theta2}),0,`G')*`g'"
mlexp (log(`f'))
mlci exp /theta1
mlci exp /theta2
//_16
gen fhat_y5 = gammaden(exp(_b[/theta1]), exp(_b[/theta2]), 0, sqrt(y))*(.5 / sqrt(y))
tw (hist y, bin(50)) (line fhat_y fhat_y2 fhat_y3 fhat_y4 fhat_y5 y, sort), name(p8, replace) legend(rows(1))
graph export p8.png, replace
//_17
use https://raw.githubusercontent.com/anddis/fsm/master/data/lab1.dta, clear
//_18
local f = "normalden(y_n, {mu}, exp({theta}))"
mlexp(ln(`f'))
mlci exp /theta

gen u_normal = normal((y_n-_b[/mu])/exp(_b[/theta]))
qplot u_normal, addplot(function y = x) name(p1, replace)
graph export p0.png, replace
//_19
local f = "exp({theta})*exp(-y_n * exp({theta}))"
mlexp(ln(`f'))
mlci exp /theta

gen u_exponential = 1-exp(-y_n * exp(_b[/theta]))
qplot u_exponential, addplot(function y = x) name(p2, replace)
graph export p00.png, replace
//_20
local eta = "invlogit({theta})"
local f = "`eta'^y_ber * (1-`eta')^(1-y_ber)"
mlexp (ln(`f'))
mlci invlogit /theta

local eta = "invlogit({theta})"
local f = "binomialp(1, y_ber, `eta')"
mlexp (ln(`f')) 
mlci invlogit /theta

logit y_ber
//_^
log close
