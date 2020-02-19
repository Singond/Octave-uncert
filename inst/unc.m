classdef unc
	properties (Access = private)
		value = 0;
		uncert = 0;
	endproperties

	methods
		## Create a new number with uncertainty
		function u = unc(value, uncert)
			## Validate arguments
			if (nargin == 0)
				error("unc: no argument given");
			elseif (nargin == 1)
				uncert = 0;
			elseif (nargin > 2)
				error("unc: too many arguments");
			endif
			if (!isnumeric(value) || isnumeric(uncert))
				error("'value' and 'uncert' must be numeric");
			endif
			## Perform a simple binary operation to check if the arrays
			## are broadcastable to the same size
			try
				bsxfun(@eq, value, uncert);
			catch
				error("'value' and 'uncert' must be broadcastable to same size");
			end_try_catch

			u.value = value;
			u.uncert = uncert;
		endfunction

		function d = disp(o)
			s = sprintf("%g +- %g\n", o.value, o.uncert);
			s = s(1:end-1);
			if (nargout == 0)
				disp(s);
			else
				d = s;
			endif
		endfunction

		function sum = plus(a, b)
			sum = unc(a.value + b.value, hypot(a.uncert, b.uncert));
		endfunction

		function r = horzcat(a, b)
			r = unc([a.value b.value], [a.uncert b.uncert]);
		endfunction

		function r = vertcat(a, b)
			r = unc([a.value; b.value], [a.uncert; b.uncert]);
		endfunction
	endmethods
endclassdef
