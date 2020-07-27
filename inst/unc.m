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

		function d = disp(o)
			sigdigits = 5;              # Significant digits to display
			negv = any(o.value < 0);
			negu = any(o.uncert < 0);
			absv = abs(o.value(:));
			absu = abs(o.uncert(:));
			extremes = [min(absv) max(absv); min(absu) max(absu)];
			clear absv absu;
			# Position of first significant digit to the left of decimal point
			firstsig = floor(log10(extremes)) + 1;
			leftmostv = firstsig(1,2);
			leftmostu = firstsig(2,2);
			rightmost = min(firstsig)(1);
			widthv = 0;  # Width of the value field
			widthu = 0;  # Width of the uncertainty field
			decplaces = 0;
			if (rightmost < -10 || max(leftmostv, leftmostu) > 10)
				## Use exponential notation
				fmt = "%g +- %g";
			else
				## Use normal notation
				widthv = leftmostv;
				widthu = leftmostu;
				decplaces = max(-firstsig + sigdigits)(1);
				if (decplaces > 0)
					widthv += decplaces + 1;
					widthu += decplaces + 1;
				else
					decplaces = 0;
				endif
				## Increase width to accomodate minus sign
				if (negv)
					widthv += 1;
				endif
				if (negu)
					widthu += 1;
				endif
				fmt = sprintf("%%%d.%df +- %%%d.%df", ...
					widthv, decplaces, widthu, decplaces);
			endif

			if (isscalar(o))
				pad = 1;
			else
				pad = 3;
			endif

			if (ndims(o.value) == 2)
				rightpad = 1;   # Space to be left after last column in terminal
				outwidth = terminal_size()(2) - rightpad;
				width = widthv + widthu + 4;
				if (nargout == 0)
					o.disp2d(fmt, width, pad, outwidth);
				else
					d = o.disp2d(fmt, width, pad, outwidth);
				endif
			else
				disp(o.value);
				disp(o.uncert);
			endif
		endfunction

		function r = isscalar(a)
			r = isscalar(a.value) && isscalar(a.uncert);
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

	methods (Access = private)
		## Display an unc object if it is at most two-dimensional.
		## fmt: printf-like format of the value-uncert pair
		## width: maxuimum width of the printed fmt in characters
		## pad: number of spaces before each column (including first)
		## outwidth: width of output in characters
		## loose: use loose format
		function d = disp2d(o, fmt, width, pad, outwidth, loose)
			if (nargin < 6)
				[~, spacing] = format();
				loose = strcmp("loose", spacing);
			endif
			linesep = "\n"; # TODO: Use CRLF on Windoze?
			colwidth = pad + width;
			totcols = max(columns(o.value), columns(o.uncert));
			colsregular = min(totcols, floor(outwidth / colwidth));
			donecol = 0;     # Number of columns already processed
			if (nargout > 0)
				d = "";
			endif

			## Split the value into smaller chunks so that the displayed
			## text will fit the available width.
			## TODO: This should only happen if split_long_rows() returns true.
			while (donecol < totcols)
				tocol = min(donecol + colsregular, totcols);
				cols = tocol - donecol;
				fromcol = donecol + 1;
				## Unless the whole output fits available width,
				## print the chunk header followed by an optional blank line.
				if (donecol != 0 || tocol < totcols)
					if (fromcol == tocol)
						coltext = sprintf(" Column %d:\n", fromcol);
					elseif (fromcol+1 == tocol)
						coltext = sprintf(" Columns %d and %d:\n", fromcol, tocol);
					else
						coltext = sprintf(" Columns %d through %d:\n", fromcol, tocol);
					endif
					if (nargout == 0)
						puts(coltext);
						if (loose)
							puts(linesep);
						endif
					else
						d = [d coltext];
						if (loose)
							d = [d linesep];
						endif
					endif
				endif
				## Prepare format and rearrange data
				linefmt = [repmat([" "(ones(1, pad)) fmt], 1, cols) linesep];
				vu = zeros(rows(o.value), 2*cols);
				vu(:,1:2:end) = o.value(:,fromcol:tocol);
				vu(:,2:2:end) = o.uncert(:,fromcol:tocol);
				## Print the chunk
				if (nargout == 0)
					printf(linefmt, vu');
				else
					d = [d sprintf(linefmt, vu')];
				endif
				if (tocol < totcols)
					if (nargout == 0)
						puts(linesep);
					else
						d = [d linesep];
					endif
				endif
				## Mark processed columns
				donecol = tocol;
			endwhile
		endfunction
	endmethods
endclassdef
