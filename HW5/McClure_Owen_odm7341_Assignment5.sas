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

%macro p5m3(data=_LAST_, nobs=5);
	proc print data=&data (obs=&nobs);
	title "First &nobs listings of dataset &data, with lastname &lname from &state";
	var date receiver amount;
	run;
%mend p5m3;

%p5m3(nobs = 3);

*d;

%macro donor(lname=, state=, data=_LAST_, nobs=5);
	data &lname&state
		set &data;
		if state = "&state";
		if upcase(LastNamePart) = upcase("&lname");
		zip = substr(zip,2,6);
		
	proc print data=&data (obs=&nobs);
		title "First &nobs listings of dataset &lname&state, created from &data using &lname from &state";
		var date receiver amount;
		run;		
%mend donor;

%donor(lname=Church, state=MA, data=save.churchdata)


	





