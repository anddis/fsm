capture program drop mlci
program define mlci
	di %9.0g `1'(_b[`2']) "   95% CI:" %9.0g `1'(_b[`2']-invnormal(.975)*_se[`2']) "," %9.0g `1'(_b[`2']+invnormal(.975)*_se[`2'])
end
