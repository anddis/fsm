capture log close
log using "lab2_extra", smcl replace
//_1
version 14
use https://raw.githubusercontent.com/anddis/fsm/master/data/lab2.dta, clear
run https://raw.githubusercontent.com/anddis/fsm/master/do/mlci.do
//_2
local alpha = "exp({theta1})"
local beta = "exp({theta2})"
local f = "gammaden(`alpha', `beta', 0, y)"
mlexp (ln(`f'))
mlci exp /theta1
mlci exp /theta2
//_3
di exp(_b[/theta1])*exp(_b[/theta2])
//_4
local eta = "exp({theta1})" // We constrain the mean to be strictly positive
local beta = "exp({theta2})"
local alpha = "`eta' / `beta'"
local f = "gammaden(`alpha', `beta', 0, y)"
mlexp (ln(`f')) 
mlci exp /theta1 // This gives me the MLE of eta (the mean) with 95% CI
mlci exp /theta2
//_^
log close
