classdef unc
	properties (Access = private)
		value = 0;
		uncert = 0;
	endproperties

	methods
		function u = unc(value, uncert)
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
