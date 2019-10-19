%let dirdata=/folders/myfolders/project/;

LIBNAME save "&dirdata";

/************ q1a **************/
%put "q1a";

data snow1;
  infile "&dirdata.Pr1Snowfall1.csv" DLM = ',' DSD MISSOVER;
  tot = 0;
  drop i tot;
  retain year Season Sep Oct Nov Dec Jan Feb Mar Apr May Total;
  input Season $ Sep Oct Nov Dec Jan Feb Mar Apr May Total;
  year = substr(Season, 1, 4);
  year = input(year, comma4.);
  array mon{10} Sep--Total;
  do i=1 to 10;
		if mon{i} = 'T' then mon{i} = 0;
		tot = tot + mon{i};
  end;
  if mod(year,1) = 0;
  if tot > 0 and Total > 0;
run;

title "q1a";
Footnote "q1a";
proc contents; run;
proc print; run;

%put "q1a";


/************ q1b **************/
%put "q1b";

data _null_;
	call symput('lastobs',put(lastobs,best.));
	set snow1 nobs=lastobs;
run;
%put &lastobs full years of snowfall data;

%put "q1b";


/************ q1c **************/
%put "q1c";

data snow2;
  infile "&dirdata.Pr1Snowfall2.csv" DLM = ',' DSD MISSOVER;
  tot = 0;
  drop i tot;
  retain year Season Sep Oct Nov Dec Jan Feb Mar Apr May Total;
  input Season $ Sep Oct Nov Dec Jan Feb Mar Apr May Total;
  year = substr(Season, 1, 4);
  year = input(year, comma4.);
  array mon{10} Sep--Total;
  do i=1 to 10;
		if mon{i} = 'T' then mon{i} = 0;
		tot = tot + mon{i};
  end;
  if mod(year,1) = 0;
  if tot > 0 and Total > 0;
run;

title "q1c";
Footnote "q1c";
proc contents; run;
proc print; run;


data _null_;
	call symput('lastobs',put(lastobs,best.));
	set snow2 nobs=lastobs;
run;
%put &lastobs full years of snowfall data;

%put "q1c";


