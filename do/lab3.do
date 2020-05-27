capture log close
log using "lab3", smcl replace
//_1
version 14
use https://raw.githubusercontent.com/anddis/fsm/master/data/lab3_1.dta, clear
run https://raw.githubusercontent.com/anddis/fsm/master/do/mlci.do
//_2
hist age, width(1) name(p0, replace)
graph export p0.png, replace
//_3
local G = "exp((age-{mu})/exp({theta}))"
local g = "exp((age-{mu})/exp({theta}))/exp({theta})"
local f = "exp(-`G')*`g'"
mlexp(ln(`f'))
mlci exp /theta
//_4
gen fhat_age = exp(-exp((age-_b[/mu])/exp(_b[/theta])))*exp((age-_b[/mu])/exp(_b[/theta]))/exp(_b[/theta])
tw (hist age, width(1)) (line fhat_age age, sort), name(p1, replace) legend(off)
graph export p1.png, replace
//_5
local G = "exp((age-{mu})/exp({theta1}))"
local g = "exp((age-{mu})/exp({theta1}))/exp({theta1})"
local eta = "invlogit({theta2})"
local f = "exp(-`G')*`g'"
mlexp ((age<1)*ln(`eta') + (age>=1)*ln((1-`eta')*`f'))
mlci exp /theta1
mlci invlogit /theta2
//_6
gen fhat_age2 = invlogit(_b[/theta2])^(age<1) * ///
((1-invlogit(_b[/theta2]))* ///
exp(-exp((age-_b[/mu])/exp(_b[/theta1])))*exp((age-_b[/mu])/exp(_b[/theta1]))/exp(_b[/theta1]))^(age>=1)
tw (hist age, width(1)) (scatter fhat_age2 age if age<1, sort msiz(small) lc(maroon)) ///
(line fhat_age2 age if age>=1, sort lc(maroon)), name(p2, replace) legend(off)
graph export p2.png, replace
//_7
hist age100, discrete name(p00, replace)
graph export p00.png, replace
//_8
gen d = (age < 100)
local G = "exp((age100-{mu})/exp({theta1}))"
local g = "exp((age100-{mu})/exp({theta1}))/exp({theta1})"
local f = "exp(-`G')*`g'"
local S = "exp(-`G')"
local eta = "invlogit({theta2})"
mlexp ((age<1)*ln(`eta') + (age>=1)*ln((1-`eta')*((`f')^(d==1) * (`S')^(d==0))))
mlci exp /theta1
mlci invlogit /theta2
//_9
gen fhat_age3 = invlogit(_b[/theta2])^(age<1) * ///
((1-invlogit(_b[/theta2]))* ///
exp(-exp((age-_b[/mu])/exp(_b[/theta1])))*exp((age-_b[/mu])/exp(_b[/theta1]))/exp(_b[/theta1]))^(age>=1)
tw (hist age100, width(1)) (scatter fhat_age3 age if age<1, sort msize(small) lc(maroon)) ///
(line fhat_age3 age if age>=1, sort lc(maroon)), name(p20, replace) legend(off)
graph export p20.png, replace
//_10
gen age100_plus_1 = age100 + 1
local Sy = "exp(-exp((age100-{mu})/exp({theta1})))"
local Su = "exp(-exp((age100_plus_1-{mu})/exp({theta1})))"
local eta = "invlogit({theta2})"
mlexp ((age<1)*ln(`eta') + (age>=1)*ln((1-`eta')*(`Sy'-`Su')^(d==1) * (`Sy')^(d==0)))
mlci exp /theta1
mlci invlogit /theta2
//_11
use https://raw.githubusercontent.com/anddis/fsm/master/data/lab3_2.dta, clear

tab y
hist y, width(1) name(p000, replace)
graph export p000.png, replace
//_12
local beta = "invlogit({theta1})"
local lambda = "exp({theta2})"
local f = "(y==0)*ln(`beta'+(1-`beta')*poissonp(`lambda',0))+(y>0)*ln((1-`beta')*poissonp(`lambda',y))"
mlexp (`f')
mlci invlogit /theta1
mlci exp /theta2
//_13
gen fhat_y = exp((y==0)*ln(invlogit(_b[/theta1])+(1-invlogit(_b[/theta1]))*poissonp(exp(_b[/theta2]),0))+ ///
(y>0)*ln((1-invlogit(_b[/theta1]))*poissonp(exp(_b[/theta2]),y)))
tw (hist y, width(1)) (line fhat_y y, sort connect(J)), name(p3, replace)
graph export p3.png, replace
//_14
local beta = "invlogit({theta1})"
local a = "exp({theta2})"
local b = "exp({theta3})"
local f = "(y==0)*ln(`beta'+(1-`beta')*gammap(`a',1/`b'))+(y>0)*ln((1-`beta')*(gammap(`a',(y+1)/`b')-gammap(`a',y/`b')))"
mlexp (`f')
mlci invlogit /theta1
mlci exp /theta2
mlci exp /theta3
//_15
gen fhat_y2 = exp((y==0)*ln(invlogit(_b[/theta1])+(1-invlogit(_b[/theta1]))*gammap(exp(_b[/theta2]),1/exp(_b[/theta3])))+ ///
(y>0)*ln((1-invlogit(_b[/theta1]))*(gammap(exp(_b[/theta2]),(y+1)/exp(_b[/theta3]))-gammap(exp(_b[/theta2]),y/exp(_b[/theta3])))))
tw (hist y, width(1)) (line fhat_y fhat_y2 y, sort connect(J J)), name(p4, replace) legend(off)
graph export p4.png, replace
//_16
gen N = _N
bysort y: gen n = _N
gen obs_p = n / N
tabstat obs_p fhat_y fhat_y2, by(y) nototal format(%4.3f)
//_17
use https://raw.githubusercontent.com/anddis/fsm/master/data/lab3_1.dta, clear
gen d = (age < 100)

mata
mata clear

X = st_data(., ("age", "age100", "d" ))

void model3(todo, beta, ll, S, H) {
mu = beta[1]
sigma = exp(beta[2])
eta = invlogit(beta[3])
    
external X
age = X[., 1]
age100 = X[., 2]
d = X[., 3]
    
G = exp((age100 :- mu) :/ sigma)
g = exp((age100 :- mu) :/ sigma) :/ sigma
f = exp(-G) :* g
S = exp(-G)
    
ll = colsum((age:<1) :* ln(eta) :+ (age:>=1) :* ln((1:-eta) :* ((f):^(d:==1) :* (S):^(d:==0))))
}

S = optimize_init()
optimize_init_evaluator(S, &model3())
optimize_init_params(S, (100, log(10), logit(.5)))
b = optimize(S)
se = sqrt(diagonal(invsym(-optimize_result_Hessian(S))))

b', se 
end
//_^
log close
