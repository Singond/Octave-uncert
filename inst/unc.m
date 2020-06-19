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
			if (!isnumeric(value) || !isnumeric(uncert))
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

		## TODO: Make private
		function d = dispcol(o)
			v = o.value(:);
			u = o.uncert(:);
			if (isscalar(u))
				u = u(ones(size(v)));
			endif
			s = disp([v u]);                   # Format uniformly
			ss = strsplit(strtrim(s));         # Split into individual numbers
			vstr = ss(1:2:end);                # Values (as strings)
			ustr = ss(2:2:end);                # Uncertainties (as strings)
			lv = max(cellfun("length", vstr)); # Length of longest value
			lu = max(cellfun("length", ustr)); # Length of longest uncertainty
			fmt = sprintf("%%%ds +- %%%ds", lv, lu);
			oneline = sprintf(fmt, [vstr; ustr]{:}); # Format as one line
			d = reshape(oneline, lv + lu + 4, [])';  # To multirow char matrix
		endfunction

		function d = disp(o)
			if (nargout == 0)
				disp(o.dispcol());
			else
				d = o.dispcol();
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
