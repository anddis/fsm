capture log close
log using "lab3_extra", smcl replace
//_1
version 14
use https://raw.githubusercontent.com/anddis/fsm/master/data/lab3_1.dta, clear
run https://raw.githubusercontent.com/anddis/fsm/master/do/mlci.do
//_2
local G = "exp((age-{mu})/exp({theta1}))"
local g = "exp((age-{mu})/exp({theta1}))/exp({theta1})"
local eta = "invlogit({theta2})"
local f = "exp(-`G')*`g'"
mlexp ((age<1)*ln(`eta') + (age>=1)*ln((1-`eta')*`f'))
mlci exp /theta1
mlci invlogit /theta2
//_3
gen fhat_age = invlogit(_b[/theta2])^(age<1) * ///
((1-invlogit(_b[/theta2]))* ///
exp(-exp((age-_b[/mu])/exp(_b[/theta1])))*exp((age-_b[/mu])/exp(_b[/theta1]))/exp(_b[/theta1]))^(age>=1)

gen u1 = invlogit(_b[/theta2]) + (1-invlogit(_b[/theta2])) * (1 - exp(-exp((age-_b[/mu])/exp(_b[/theta1])))) * (age>=1)
//_4
rcsgen age, gen(V) dgen(v) df(4)
local G = "exp((age+{eta1}*V2+{eta2}*V3+{eta3}*V4-{mu})/exp({theta1}))"
local g = "exp((age+{eta1}*V2+{eta2}*V3+{eta3}*V4-{mu})/exp({theta1}))*(1+{eta1}*v2+{eta2}*v3+{eta3}*v4)/exp({theta1})"
local eta = "invlogit({theta2})"
local f = "exp(-`G')*`g'"
mlexp ((age<1)*ln(`eta') + (age>=1)*ln((1-`eta')*`f')), from(mu=80 theta1=2 theta2=0 eta1=0 eta2=0 eta3=0)
mlci exp /theta1
mlci invlogit /theta2

test [eta1]_b[_cons] [eta2]_b[_cons] [eta3]_b[_cons]
//_5
gen fhat_age1 = invlogit(_b[/theta2])^(age<1) * ///
((1-invlogit(_b[/theta2]))* ///
exp(-exp((age+_b[/eta1]*V2+_b[/eta2]*V3+_b[/eta3]*V4-_b[/mu])/exp(_b[/theta1])))* ///
exp((age+_b[/eta1]*V2+_b[/eta2]*V3+_b[/eta3]*V4-_b[/mu])/exp(_b[/theta1]))* ///
((1+_b[/eta1]*v2+_b[/eta2]*v3+_b[/eta3]*v4)/exp(_b[/theta1])))^(age>=1)
    
gen u2 = invlogit(_b[/theta2]) + (1-invlogit(_b[/theta2])) * ///
(1 - exp(-exp((age+_b[/eta1]*V2+_b[/eta2]*V3+_b[/eta3]*V4-_b[/mu])/exp(_b[/theta1])))) * (age>=1)
//_6
tw (hist age, discrete) ///
(scatter fhat_age fhat_age1 age if age<1, sort mcol(navy maroon) msize(small small)) ///
(line fhat_age fhat_age1 age if age>=1, sort lc(navy maroon)), name(p1, replace) legend(off)
graph export p1.png, replace

qplot u1 u2, addplot(function y = x) name(p2, replace) legend(off) lc(navy maroon) ///
msize(vsmall vsmall) msym(O O)
graph export p2.png, replace

//_^
log close
