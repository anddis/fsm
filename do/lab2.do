capture log close
log using "lab2", smcl replace
//_1
version 14
use https://raw.githubusercontent.com/anddis/fsm/master/data/lab2.dta, clear
run https://raw.githubusercontent.com/anddis/fsm/master/do/mlci.do
//_2
cap net install http://fmwww.bc.edu/RePEc/bocode/r/rcsgen.pkg
//_3
hist y, bin(50) name(p1, replace) 
graph export p1.png, replace
//_4
gen log_y = log(y)
hist log_y, bin(50) name(p2, replace) 
graph export p2.png, replace
//_5
local f = "gammaden(exp({theta1}), exp({theta2}), 0, y)"
mlexp (log(`f'))
mlci exp /theta1
mlci exp /theta2
//_6
gen fhat_y = gammaden(exp(_b[/theta1]), exp(_b[/theta2]), 0, y)
tw (hist y, bin(50)) (line fhat_y y, sort), name(p3, replace) legend(rows(1))
graph export p3.png, replace
//_7
local sigma = "exp({theta})"
local G = "(log(y) - {mu}) / `sigma'"
local g = "(1 / y / `sigma')"
local f = "normalden(`G')*`g'"
mlexp (log(`f'))
mlci exp /theta
//_8
gen fhat_y2 = normalden((log(y) - _b[/mu]) / exp(_b[/theta]))*(1 / y / exp(_b[/theta]))
tw (hist y, bin(50)) (line fhat_y fhat_y2 y, sort), name(p4, replace) legend(rows(1))
graph export p4.png, replace
//_9
local sigma = "exp({theta})"
local G = "(log(y)+{eta}*log(y)^2 - {mu}) / `sigma'"
local g = "(1 + {eta}*2*log(y)) / (`sigma'*y)"
local f = "normalden(`G')*`g'"
mlexp (log(`f'))
mlci exp /theta
//_10
gen fhat_y3 = normalden((log(y)+_b[/eta]*log(y)^2 - _b[/mu])/exp(_b[/theta])) * ///
 (1+_b[/eta]*2*log(y)) / (exp(_b[/theta]) * y)
tw (hist y, bin(50)) (line fhat_y fhat_y2 fhat_y3 y, sort), name(p5, replace) legend(rows(1))
graph export p5.png, replace
//_11
rcsgen log_y, gen(V) dgen(v) df(3)
local sigma = "exp({theta})"
local G = "(log(y)+{eta1}*V2+{eta2}*V3-{mu})/`sigma'"
local g = "(1+{eta1}*v2+{eta2}*v3)/(`sigma'*y)"
local f = "normalden(`G')*`g'"
mlexp (log(`f'))
mlci exp /theta

test  [eta1]_cons [eta2]_cons
//_12
gen fhat_y4 = normalden((log(y)+_b[/eta1]*V2+_b[/eta2]*V3 - _b[/mu])/exp(_b[/theta])) * ///
 (1+_b[/eta1]*v2+_b[/eta2]*v3) / (exp(_b[/theta]) * y)
tw (hist y, bin(50)) (line fhat_y fhat_y2 fhat_y3 fhat_y4 y, sort), name(p6, replace) legend(rows(1))
graph export p6.png, replace
//_13
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
//_14
local G = "sqrt(y)"
local g = "(0.5 / sqrt(y))"
local f = "gammaden(exp({theta1}),exp({theta2}),0,`G')*`g'"
mlexp (log(`f'))
mlci exp /theta1
mlci exp /theta2
//_15
gen fhat_y5 = gammaden(exp(_b[/theta1]), exp(_b[/theta2]), 0, sqrt(y))*(.5 / sqrt(y))
tw (hist y, bin(50)) (line fhat_y fhat_y2 fhat_y3 fhat_y4 fhat_y5 y, sort), name(p8, replace) legend(rows(1))
graph export p8.png, replace
//_^
log close
