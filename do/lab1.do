capture log close
log using "lab1", smcl replace
//_1
version 14
* Chunk 1 
local a = "Fundamentals of statistical modeling."
di "`a'"

* Chunk 2
local a = "statistical modeling"
di "Fundamentals of `a'."

* Chunk 3
local a = "Fundamentals of"
local b = "statistical"
local c = "modeling."
di "`a' `b' `c'"

* Chunk 4
local a = "Fundamentals"
local b = "`a' of"
local c = "`b' statistical"
local d = "`c' modeling."
di "`d'"

* Chunk 5
di exp(2) * exp(-2)

* Chunk 6
local a = "exp(2)"
local b = "exp(-2)"
di `a' * `b'

* Chunk 7
local a = "2"
local b = "exp(`a')"
local c = "exp(-`a')"
di `b' * `c'

* Chunk 8
sysuse auto, clear
describe

local yvar = "weight"
local xvars = "length mpg"
local xvars2 = "price"
regress `yvar' `xvars' `xvars2'
//_2
version 14
use https://raw.githubusercontent.com/anddis/fsm/master/data/lab1.dta, clear
//_3
local f = "normalden(y_n, {mu}, {sigma})"
mlexp (ln(`f'))
//_4
local sigma = "exp({theta})"
local f = "normalden(y_n, {mu}, `sigma')"
mlexp(ln(`f'))

di exp(_b[/theta])
//_5
gen fhat_y_n = normalden(y_n, _b[/mu], exp(_b[/theta]))
tw (hist y_n) (line fhat_y_n y_n, sort), name(y_n, replace)
graph export y_n.png, replace
//_6
gen Fhat_y_n = normal((y_n - _b[/mu])/exp(_b[/theta]))
cumul y_n, gen(sampleF_y_n)

// This is what -cumul- does under the hood
// sort y_n
// gen sampleF_y_n = sum(_cons)
// su sampleF_y_n
// replace sampleF_y_n = sampleF_y_n / r(max)

tw (line sampleF_y_n Fhat_y_n y_n, connect(J l) sort), name(Fy_n, replace)
graph export Fy_n.png, replace
//_7
local f = "gammaden({alpha}, {beta}, 0, y_g)"
mlexp(ln(`f'))
//_8
gen fhat_y_g = gammaden(_b[/alpha], _b[/beta], 0, y_g)
tw (hist y_g) (line fhat_y_g y_g, sort), name(y_g, replace)
graph export y_g.png, replace
//_9
local f = "betaden({alpha}, {beta}, y_b)"
mlexp(ln(`f'))
//_10
gen fhat_y_b = betaden(_b[/alpha], _b[/beta], y_b)
tw (hist y_b) (line fhat_y_b y_b if inrange(y_b, .01, .99), sort), name(y_b, replace)
graph export y_b.png, replace
//_11
local f = "{lambda}*exp(-y_e * {lambda})"
mlexp(ln(`f'))
//_12
gen fhat_y_e = _b[/lambda] * exp(-y_e * _b[/lambda])
tw (hist y_e) (line fhat_y_e y_e, sort), name(y_e, replace)
graph export y_e.png, replace
//_13
local f = "chi2den({k}, y_c)"
mlexp(ln(`f'))
//_14
gen fhat_y_c = chi2den(_b[/k], y_c)
tw (hist y_c) (line fhat_y_c y_c, sort), name(y_c, replace)
graph export y_c.png, replace
//_^
log close
