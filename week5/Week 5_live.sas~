%let dirdata=/folders/myshortcuts/SAS_part/Week 5/; * possible SAS Studio access;
%let dirSASmacros=/folders/myshortcuts/SAS_part/Week 5/; * possible SAS Studio access;
libname perm "&dirdata"; * for reading in some SAS data sets;
*************************************
******** SAS Macro Variables ******** 
*************************************;

* Macro Variables */

/* We define these with %let.*/

/* See some examples above, e.g. 
%let dirdata=/folders/myshortcuts/SAS_part/Week 5/; 
More: */
%let firstDayOfTerm=8/26/14;
%let names=Smith Valdez Li;
%let names=  Smith Valdez Li Baker  ;
%put &names;
	* new definition overrides old one;
	* (leading and trailing blanks here are trimmed);
%let num1=3;
%let num2=5;
%let sumA=num1 + num2;
%let surprise=; * a null value is allowed;
/* You reference macro variables by preceding 
	the name with an & (ampersand) */

/* You can display macro variables in the SAS
	log with %put: */
libname perm "&dirdata"; * for reading in some SAS data sets;
%put &dirdata;
%put &sumA;
%let sumA=&num1 + &num2;
%put &sumA;
%put &firstDayOfTerm;
%put _user_;
%put &sysdate9;
%put _automatic_;

proc print data=perm.profits;run;

/* We have lots of SAS data sets stored in the perm
	library. Let's define a macro variable to 
	access one of them... */

%let dsn=profits;
proc print data=perm.&dsn;run;

%let silly=fits;
proc print data=perm.pro&silly;run;
%let lib=perm.;  * Note that I included the "." in the def'n;
proc print data=&lib&dsn;run;



proc print data=&libprofits;run;

/* I want this to be resolved into perm.profits, but 
	SAS has no way of knowing where the macro variable
	stops and the regular text begins.

	To solve this problem, SAS uses a "." to denote
	the end of a macro-variable reference.

	Note: The "." is *not* part of the text! It only
	serves as a delimiter. Let's try it: */

proc print data=&lib.profits;run;

***********************************;
%put &lib;
%let lib=perm; * redefined: it now has no . ;

proc print data=&lib..profits;run;
/* A "." after a macro variable is always treated
	as a delimiter, even it is not needed as a delimiter: */

%put &lib&dsn;
%put &lib.&dsn;
%put The library is &lib, and the name is &dsn;
%put The library is &lib., and the name is &dsn;
*****************************************************;
/* So far, we used macro variables to represent
	a small string of text. And this is usually
	how macro variables are used. However,
	they can be more complex. Here's an example */

%let p5=%str(proc print data=_last_ (obs=5);run;);
/* %str is a *macro function*. In this example,
	this function let's us use ";" as part of
	the macro-variable definition: */

%put &p5;
data expenses;
	infile "&dirdata.expensesArray.csv" 
		dlm="," DSD firstobs=2 termstr=CRLF;
	length ResortName $26 Resort $8;
	input ResortName Resort OffSeason1-OffSeason6;
run;

&p5;

/* in fact, because the closing ";" is part of the macro
	definition, this next line works fine--no semicolon
	is needed. */
&p5
************************;
%let p5a=%str(
	title "Listing of first 5 records from library &lib, member &dsn,";
	title2 "on &sysday, &sysdate..";
	proc print data=&lib..&dsn (obs=5);run;
	title;
);

&p5a
****************************************;
%let sumB = &num1 + &num2;
%put num1=&num1 sumB=&sumB; * a reminder;

* Will this work? Think about it before you try it;

proc print data=perm.profits (firstobs=&num1 obs=&sumB);run;
proc print data=perm.profits (firstobs=&num1 obs=%eval(&sumB));run;


%let sumD=%eval(&num1+&num2-1); * or directly on &sumB;
%put sumB=&sumB sumD=&sumD;
****************************;
%put num1=&num1 sumD=&sumD; 
%let num1=8;
%put num1=&num1 sumD=&sumD; 
%let num1=3; * (test is over, so let's reset to the original value.);
/* &sumD is still 7. So it seems (and is true) that
	SAS defines macro variables
	"by value". This distinction can be important
	in writing programs that use macro variables. */
	/* %eval does *integer arithmetic*. Examples: */

%put %eval(&num1+&num2);
%put sum=%eval(4+2);

/* It also performs logical arithmetic */

%put &num1 &num2;
%put results=%eval(&num1 gt &num2);

/* It is often used to update index counters.
	For example: */

%let i=5;
* some SAS code;
%let i=%eval(&i+1);
%put Now, i=&i;  
	
	/* But... */

%let num3=1.6;
%put &num1 &num2 &num3;
%put %eval(&num1+&num2+&num3);

%let num4=8/5; * same as 1.6??;
%put %eval(&num1+&num2+&num4); * &num4 works (no error), but is truncated to 1;
%put %eval(&num1+&num2+&num4+&num4+&num4+&num4+&num4); 
	* Each &num4 is truncated to 1, so answer is 3+5+5(1)=13, not 3+5+5(8/5)=16;
/* Here is a relatively new SAS macro function--
	this performs floating-point arithmetic: */
%put %sysevalf(&num1+&num2+&num3);
***********************************;
%put &p5a; 

&p5a; * but we don't see these when we *invoke* the macro variable;

/* To see the actual code when we invoke the 
	macro variable, we can use the SYMBOLGEN (symbol generation)
	option: */
options symbolgen;
&p5a
options nosymbolgen;
**********************************;

/* Suppose we want to: 
	1. list only the data for the current quarter number
		in our profits data set
	2. Enter the current date and make that date information 
		look a bit nicer in the SAS data set
	3. put the data set name in upper case
		(a SAS tradition...) */

%put &lib &dsn;
proc print data=&lib..&dsn;run; * a reminder;

	data temp;
		set &lib..&dsn;
		dateInvoke="&sysdate9"d;
		format dateInvoke yymmdd10.;
		mNow=month(dateInvoke); 
		qNow=floor(1+(mNow-0.5)/3);
		if qtr=qNow;
	run;
	* (The "d" after a quoted date (as text, and in 
		the DATE9. format, ddMMMyyyy,) converts the 
		text to a (numeric) date variable);

	* This is for you, to see the full contents of temp ;
	proc print data=temp;run;

	* This might be the actual report: ;
	title "(%substr(&sysdate9,6,4)) Listing of all data from current quarter number";
	title2 "library %upcase(&lib), member %upcase(&dsn).";
	proc print data=temp;
		by qtr;
		var year profit;
	run;
	title;
*******************************************;
/* Example 1. Two simple macros. */

/* Before we had:
		%let p5=%str(proc print data=_last_ (obs=5);run;);
	Let's convert this into a SAS macro. */

* But first, to make this example a bit more instructive,
	let's set perm.profits to be the _LAST_ data set: ;
options _last_=perm.profits;

/* Macro definition: */
%macro p5m;
	proc print data=_last_ (obs=5);
	run;
%mend;
%p5m;

/* define macro */

%macro p5am;
	title "Listing of first 5 records from library &lib, member &dsn,";
	title2 "on &sysday, &sysdate..";
	proc print data=&lib..&dsn (obs=5);run;
	title;
%mend;

/* execute macro */
%p5am;
*****************************;
%macro p5m2(nobs);
	proc print data=_last_ (obs=&nobs);
	run;
%mend p5m2;
%p5m2(7);
%p5m2;
*********************************;

/* Next, let's add another parameter to 
	identify the SAS data set. */

%macro p5m2(dsn, nobs);
	proc print data=&dsn (obs=&nobs);
	run;
%mend p5m2;

%put &dsn; 
	* a reminder of the global macro variable dsn;

* execute one line at a time;
%p5m2(_last_,4)
%p5m2(perm.profits,4)
%p5m2(work.expenses,5)
************************************;
%macro p5m3(data=_LAST_, nobs=5);
	proc print data=&data (obs=&nobs);
	run;
%mend p5m3;

%macro p5m4(data, nobs);
	proc print data=&data (obs=&nobs);
	run;
%mend p5m4;
%p5m4(_LAST_,4)

/* Notes:
	1. A keyword parameter has "name=default_value"
		syntax
	2. Because of the default values,
		the macro might run without arguments.
	3. (Also, a default value, as for other
		macro variables, can be null.) 
 */

* execute the code below one line at a time;
%p5m3
%p5m3()
/* This also works. I will let you
	figure out why. */

%p5m3(data=_LAST_,4)

%p5m3(data=expenses)

%p5m3(_LAST_,4)


**** Looping in Macros ****;

/* Example 3. More complex Macros--looping. */



/* The SAS data set perm.x1x500Only contains 100 records
	of 500 variables. */

%p5m3(data=perm.x1x500Only,nobs=2)

/* Macro definition */
%macro getsubsums1(start=1, stop=500, by=1, 
			ip=perm.x1x500Only, op=);
	data &op;
		set &ip;
		keep %do i=&start %to &stop %by &by; x&i %end;;
	run; 
%mend;


* Question: can you figure out what this macro is doing?
	Please try.;
options mprint;
%getsubsums1(start=10, stop=20, by=2)
%macro getsubsumsTest(start=1, stop=500, by=1, 
			ip=perm.x1x500Only, op=);
	data &op;
		set &ip;
		keep %do i=&start %to &stop %by &by; x&i %end;
	run; 
%mend;

/* macro still gets defined. But ... */

%getsubsumsTest(start=10, stop=20, by=2)
************************************;
%macro getsubsumsTest(start=1, stop=500, by=1, 
				ip=perm.x1x500Only, op=);
	data &op;
		set &ip;
		keep %do i=&start %to &stop %by &by x&i %end;;
	run; 
%mend;



/* Now let's suppose we add an unneeded semicolon,
	here after the x&i: */
		
%macro getsubsumsTest(start=1, stop=500, by=1, ip=perm.x1x500Only, op=);
	data &op;
		set &ip;
		keep %do i=&start %to &stop %by &by; x&i; %end;;
	run; 
%mend;
*********************************************;
* Here is a macro with 4 positional parameters;
%macro getKeepList(prefix,start,stop,by);
	keep %do i=&start %to &stop %by &by; &prefix&i %end;
%mend;

* So, this macro will generate code, but the code
	only has meaning inside of a DATA step:; 

data temp;
	set perm.x1x500Only;
	if _n_=10 then stop;
	%getKeepList(x,4,20,4);
run;
proc print;run;
******************************;
/* Suppose we not only want to keep a subset of x1-x500;
	we also want to calculate their sum. */


/* Macro definition */

/* Note: if I want to keep x4 x8 x12, then I want a 
	later line of code to read as
		xsum=sum(x4, x8, x12);
	Note that I need commas--but not at the end (a "boundary problem"); */


%macro getsubsums2(start=1, stop=500, by=1, 
				ip=perm.x1x500Only, op=);
	data &op;
		set &ip;
		keep xsum %do i=&start %to &stop %by &by; x&i %end;;
	xsum=sum(%do i=&start %to &stop %by &by; 
				x&i %if(&i>=&stop) %then; %else ,; %end;);
	run; 
%mend;
%getsubsums2(start=10, stop=20, by=2)
/* Look at MPRINT ... */

proc print;run;

**** Searching for the i-th element in a string ****;

/* Example 4. Using %SCAN. */

/* Syntax for %SCAN, using an example. */

%put &names;
%put %scan(&names,1);
%put %scan(&names,3);
%put %scan(&names,5);
/* Suppose we want to create separate SAS
	data sets for 1 or more quarters of the
	profits data. (This is just a simple example 
	to show you an idea.) */

/* Macro definition */
/* Macro definition */

%macro getQtrs(qtrs=, ip=perm.profits, opPrefix=qtr);
	%let i=1;
	%let qtri=%scan(&qtrs,&i);
	%do %while (&qtri ne %str());
	/* %do %while (%scan(&qtrs,&i) ne)
			also works, but %str() makes the
			intent clearer. */
		data &opPrefix&qtri;
				set &ip;
			if qtr=&qtri;
		run;
		%let i=%eval(&i+1);
		%let qtri=%scan(&qtrs,&i);
	%end;
%mend;

%getQtrs(qtrs=1 3 4, opPrefix=QtrProfits)
***************************************************;
**** Converting a data value to a macro-variable value ****;

/* We know how to convert a macro variable's value
	to a variable's value in a data step. Example:
		X=&num1;
	Now, let's see how to convert a the value of a variable
	in a data step into a macro variable's value.
		In fact, we will see how to convert even more
	general values in a macro variable. */

/* Example: we want to store the total profits in
	perm.profits in a macro variable, as well as
	storing some additional information on the range of
	data available. We also want to store 
	the current date, but in a nicer format than
	&SYSDATE's. */

/* 1. Find the total profits. (There are lots of ways 
		to do this in SAS, of course. I'll just do it 
		within a data step.)
	2. Store the value in a macro variable. (This must
		be done in a data step.) Store some
		other information as well in other macro variables.
	3. Also store today's date in a macro variable.
		I will do this both in a data step, and 
		again outside of it, to show both methods. */
		data _null_;
	retain sumP;
	set perm.profits end=eof;
	if _n_=1 then do;
		call symput('y1',year);
		call symput('q1',qtr);
	end;
	sumP+profit;
	if eof then do;
		call symput('y2',year);
		call symput('q2',qtr);
		call symput('sumProfit',sumP);
		sumPNice=put(sumP,dollar7.);
		call symput('sumProfitNice',sumPNice);
		thisDay=put(date(),worddate18.);
		call symput('tdDate1',thisDay);
	end;
run;

/* call symput('xyz',abc)
	stores the value of abc into the macrovariable xyx

	SYMPUT is a "DATA Step Call Routine for Macros" 
	(You have seen some other call routines last week,
		using regex in SAS.)*/

/* We can also use another macro function to access
	many "normal" SAS functions outside of a data step,
	as you will see in one of titles below */

title "Based on data from Q&q1 &y1 to Q&q2 &y2:";
title2 "Total profits are &sumProfitNice.. Great work, everyone!";
title3 "Report produced &tdDate1 (%sysfunc(date(),mmddyy8.)).";
proc print data=perm.profits;run;
title;


/* Note the use of %sysfunc here... */

/* Note: there is a space between Q and 1 (and Q and 4)
	because of the default format of the numeric var qtr. */

%include "&dirSASmacros.Week6_macroEx.sas"/source2;