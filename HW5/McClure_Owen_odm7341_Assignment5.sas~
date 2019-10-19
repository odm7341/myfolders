%let dirdata=/folders/myfolders/HW5/;

LIBNAME save "&dirdata";

/********* 1 ***********/
*a;

%macro pam(lib=WORK, dsn=_LAST_, obs=5);
	title "Listing of first &obs records from library &lib, member &dsn,";
	*title2 "on &sysday, &sysdate..";
	proc print data=&lib..&dsn (obs=&obs);run;
	title;
%mend pam;

%pam(lib=save, dsn=tb2000, obs=8);


%macro pam2(lib=WORK, dsn=_LAST_, obs=5, fobs=1);
	title "Listing of first &obs records starting at &fobs from library &lib, member &dsn,";
	proc print data=&lib..&dsn (FIRSTOBS=&fobs obs=%sysevalf( (&obs + &fobs)-1  ));run;
	title;
%mend pam2;


%pam2(lib=save, dsn=tb2000, obs=3, fobs=11);

/********* 2 ***********/

*a / c;
proc contents data=save.churchdata order=varnum;
run;

%let lname = Churchill;
%let state = VA;

data chruchdatasub;
	set save.churchdata;
	if state = "&state";
	if upcase(LastNamePart) = upcase("&lname");
	zip = substr(zip,2,6);
	
proc print data=chruchdatasub; run;

*b / c;

%macro p5m3(data=_LAST_, nobs=5, vars=date receiver amount);
	proc print data=&data (obs=&nobs);
	title "First &nobs listings of dataset &data, with lastname &lname from &state";
	var &vars;
	run;
%mend p5m3;

%p5m3(nobs = 5);

*d;

%macro donor(lname=, state=, data=_LAST_, nobs=5, vars=);
	data &lname&state;
		set &data;
		if state = "&state";
		if upcase(LastNamePart) = upcase("&lname");
		zip = substr(zip,2,6);
		
	proc print data=&lname&state (obs=&nobs);
		title "First &nobs listings of dataset &lname&state, created from &data";
		var &vars;
		run;		
%mend donor;

*e;

%donor(lname=Churchill, state=VA, data=save.churchdata, vars=date receiver amount);

%donor(lname=Churchill, state=PA, data=save.churchdata, vars=date receiver amount);

/********* 3 ***********/

*a;

data _null_;
	retain sumP;
	set save.profits end=eof;
	if _n_=1 then do;
		call symput('y1',year);
		****changed to symputx so that the macrovariable is trimmed****************;
		call symputx('q1',qtr);
	end;
	sumP+profit;
	if eof then do;
		call symput('y2',year);
		****changed to symputx so that the macrovariable is trimmed****************;
		call symputx('q2',qtr);
		call symput('sumProfit',sumP);
		sumPNice=put(sumP,dollar7.);
		call symput('sumProfitNice',sumPNice);
		thisDay=put(date(),worddate18.);
		call symput('tdDate1',thisDay);
	end;
run;

*******Added the . after the variables to that SAS knows its a delimimator**************;
title "Based on data from Q&q1. &y1 to Q&q2. &y2:";
title2 "Total profits are &sumProfitNice.. Great work, everyone!";
title3 "Report produced &tdDate1 (%sysfunc(date(),mmddyy8.)).";
proc print data=save.profits;run;
title;




