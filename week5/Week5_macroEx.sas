%macro repeat(text,n);
%do i=1 %to &n;
	%put &text;
%end;
%mend;