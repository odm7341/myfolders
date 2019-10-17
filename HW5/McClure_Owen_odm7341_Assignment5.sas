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



