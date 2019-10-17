%let dirdata=/folders/myshortcuts/SAS_part/Week 5/; * possible SAS Studio access;
%let dirSASmacros=/folders/myshortcuts/SAS_part/Week 5/; * possible SAS Studio access;
libname perm "&dirdata"; * for reading in some SAS data sets;


/* This week:
	Two big, and related, topics:
		1. SAS Macro Variables
		2. SAS Macros (or SAS Macro Programs)
	Along the way...
		3. SAS Macro Functions, Macro Statements, ... */

*************************************
******** SAS Macro Variables ******** 
*************************************;

* Macro Variables */

/* We define these with %let.*/

/* See some examples above, e.g. 
%let dirdata=/folders/myfolders/; *
More: */

%let firstDayOfTerm=8/26/14;
%let names=Smith Valdez Li;
%let names=  Smith Valdez Li Baker  ;
	* new definition overrides old one;
	* (leading and trailing blanks here are trimmed);
%let num1=3;
%let num2=5;
%let sumA=num1 + num2;
%let surprise=; * a null value is allowed;
/* These all define *global* macro variables. 
	Any macro variable defined in "open code"
	(a statement that is outside a macro definition)
	is global--that is, it can be used anywhere
	in your code.
	
	Macro variables that are defined within
	a *macro program* (we will talk about 
	what this means soon) are *local* by default.
	We will not consider such macro variables
	that are defined with %let, but we will
	consider such macro variables that are
	defined as arguments within macro programs. */

/* You reference macro variables by preceding 
	the name with an & (ampersand) */

/* You can display macro variables in the SAS
	log with %put: */

%put &dirdata;
	
/* When SAS looks up the text corresponding
	to a macro variable, and finds it, then
	"SAS has resolved the macro variable". So,
	here, SAS has resolved the dirdata
	macro variable. If not, you will be told
	that it didn't: */

%put &dirdasa;

/* %put can also use regular text: */

%put The directory where most of the data exists is &dirdata;


/* You have used %put in your earlier Projects. For example: */

%put q1b;




* Question: What will print if we execute
* %put sumA;



*   *********** Stop 1a ***********;

















* Question: What will print if we execute
* %put &sumA;



*   *********** Stop 1b ***********;
















* Question: Can you define a macro variable, say sumB,
*	so that it contains the values of the macro variables
*	num1 + num2?




*   *********** Stop 1c ***********;

















/* To do this, we need to *resolve* num1 and num2 
    in the definition: */

%let sumB=&num1 + &num2;

* Question: if we %put this new macro variable,
	what will be printed? ;




*   *********** Stop 1e ***********;














%put &sumB;



/* All macro variables contain *text*. Not numbers,
	not dates -- only text */

%put &firstDayOfTerm; * text;
%put &num1; *text;


/* What is "text"? It's as if you had typed in 
	that information at the keyboard. Technically,
	from SAS help: "The value of a macro variable is 
	simply a string of characters." */

/* You can see a listing of all the macro variables
	you created with the following: */

%put _user_;

* Questions?;




*   *********** Stop 2 ***********;








/* Where are these macro variables stored??
	Not in any SAS data set!

	I think of these macro variables as 
	"data that floats above the SAS data sets":
	* Data in SAS data sets--can only be accessed
		by accessing that data set.
	* (global) macro variables--can be accessed
		from anywhere in SAS. */
		
			

			
/*	Technically, whenever the SAS System is invoked
	(started up), a *global symbol table* is created.

	This is where all of your global macro variables are
	being stored (really, it's just some place in the 
	computer's memory.) */


/* In fact, when SAS is invoked, it first creates a
	number of *automatic* or *system-defined* macro variables.
	Most of these are probably not of much use to you,
	but some may be:

	SYSDATE  date of SAS invocation (DATE7.)
	SYSDATE9 date of SAS invocation (DATE9.)
	SYSDAY   day of the week of SAS invocation
	SYSLAST   name of most recently created SAS 
   	       data set in the form libref.name. 
      	    If no data set has been created,
         	 the value is _NULL_. */

%put &sysdate9;


/* If you want to see all of these: */
%put _automatic_;

/* You can also use %put _all_ to see both 
	user and automatic macro variables ... */







**** Concatenating Macro variables with other text ****;


/* We often want to combine macro-variable text
	with either regular text or with other 
	macro-variable text. Let's see how to do this.
	We'll use the profits data set from last week--
	I've now stored it as a permanent SAS data 
	set: */

options nocenter; * used to push o/p to the left--helps let me
  make more windows available;
proc print data=perm.profits;run;

/* We have lots of SAS data sets stored in the perm
	library. Let's define a macro variable to 
	access one of them... */

%let dsn=profits;

/* Here we concatenate regular-text/macro-variable-text: */

proc print data=perm.&dsn;run;

/* the "&" is all SAS needs to figure things out. 
	Here's a silly example */

%let silly=fits;
proc print data=perm.pro&silly;run;

/* Next, we concatenate macro-variable-text/macro-variable-text*/

%let lib=perm.;  * Note that I included the "." in the def'n;
proc print data=&lib&dsn;run;


/* Again the (second) "&" is all SAS needs to figure things out. */


/* Next, we concatenate macro-variable-text/regular-text: */


/* I hope you can see that this will be problematic: */

proc print data=&libprofits;run;

/* I want this to be resolved into perm.profits, but 
	SAS has no way of knowing where the macro variable
	stops and the regular text begins.

	To solve this problem, SAS uses a "." to denote
	the end of a macro-variable reference.

	Note: The "." is *not* part of the text! It only
	serves as a delimiter. Let's try it: */

proc print data=&lib.profits;run;

/* Also, I'd say it's more standard to define 
	a library macro variable without the . (careful:
	there are two different kinds of .'s now under discussion.)  */

%put &lib;
%let lib=perm; * redefined: it now has no . ;

proc print data=&lib..profits;run;
	* The first . is the delimiter. The second . is 
		part of the regular text;


/* A "." after a macro variable is always treated
	as a delimiter, even it is not needed as a delimiter: */

%put &lib&dsn;
%put &lib.&dsn;
%put The library is &lib, and the name is &dsn;
%put The library is &lib., and the name is &dsn;

/* However, I believe the convention is to not use
	the "." unless it is actually needed. /*

*   *********** Stop 2b ***********;


**** Using macro variables in quoted strings ****;

/* This rule is easy. 
	If you want to resolve a macro variable in 
	a quoted string, use a double-quote; if not,
	use a single-quote: */

%put "The library of interest is &lib..";
%put 'The library of interest is &lib..';
/* Here is a more useful example. Note that a "," is OK
	text after the macro variable name, because
	the name cannot include a ","--so, there is no need
	for a "." */
title "Listing from library &lib, member &dsn,";
title2 "on &sysday, &sysdate..";
proc print data=&lib..&dsn;run;
title;


/* Another example. */
proc print data=&lib..&dsn (firstobs=&num1 obs=&num2);run;




/* We've used two of the above ideas *many* times in
	this course: */

* From week 4: ;
data expenses;
	infile "&dirdata.expensesArray.csv" 
		dlm="," DSD firstobs=2 termstr=CRLF;
	length ResortName $26 Resort $8;
	input ResortName Resort OffSeason1-OffSeason6;
run;

* Question. What two ideas on macro variables
	are used here?;
* Using the "." as a delimiter, and using double quotes 
	to resolve the macro variables;


/**** NOTE:
		macro variables can make code *much* easier to maintain.
		Here, without &dirdata, 
		1. You would need to type in the same directory
			name each time you ran a data step to
			read in a text file.
		2. If you wanted to change the directory name,
			you'd need to find/replace it for all occurrences.
		
****/
/* SAS has macro variables that "float above"
	SAS data sets. 
	In SAS, I needed to define dirdata as a macro 
	variable so I could use it across data steps.

*/

	
**** Macro functions: some examples ****;

/* So far, we used macro variables to represent
	a small string of text. And this is usually
	how macro variables are used. However,
	they can be more complex. Here's an example */

%let p5=%str(proc print data=_last_ (obs=5);run;);

/* %str is a *macro function*. In this example,
	this function let's us use ";" as part of
	the macro-variable definition: */

%put &p5;

* let's try it: ;
&p5;

/* in fact, because the closing ";" is part of the macro
	definition, this next line works fine--no semicolon
	is needed. */
&p5



/** Here is another example, one that uses
	other macro variables; */

%let p5a=%str(
	title "Listing of first 5 records from library &lib, member &dsn,";
	title2 "on &sysday, &sysdate..";
	proc print data=&lib..&dsn (obs=5);run;
	title;
);

&p5a


* Questions?;
*   *********** Stop 4 ***********;

%let sumB = &num1 + &num2;
%put num1=&num1 sumB=&sumB; * a reminder;

* Will this work? Think about it before you try it;

proc print data=perm.profits (firstobs=&num1 obs=&sumB);run;





















/* to convert this "3 + 5" into its corresponding value of "8",
	we can use the %eval macro function: */

proc print data=perm.profits (firstobs=&num1 obs=%eval(&sumB));run;

/* Macro functions, like macro variables,
	"float above" the "normal part of SAS"--the DATA steps and 
	PROC steps. We can use them anywhere in our code. Examples: */

%let sumD=%eval(&num1+&num2-1); * or directly on &sumB;
%put sumB=&sumB sumD=&sumD;


/* Aside: Does SAS define macro variables "by value"
	or "by reference"? */

/* If SAS defines macro variables "by value" then
	&sumD is simply equal to 7. In particular, this
	means that if we later change the value of &num1 or
	&num2 that the value of &sumD still remains 7.

	However, if SAS defines macro variables "by reference"
	then &sumD is equal to the current value of 
	%eval(&num1+&num2-1). In particular, this
	means that if we later change the value of &num1, say
	from 3 to 8, that the value of &sumD would change 
	from 7 to 12. 

	Let's test this out. */

%put num1=&num1 sumD=&sumD; 
%let num1=8;
%put num1=&num1 sumD=&sumD; 

/* &sumD is still 7. So it seems (and is true) that
	SAS defines macro variables
	"by value". This distinction can be important
	in writing programs that use macro variables. */

%let num1=3; * (test is over, so let's reset to the original value.);

*** stop 4a ***;

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

/* Note: we often use macro variables 
	that are numbers as indices in loops (see below). 
	Here, as I noted, %EVAL is what we use if we 
	"manually" need to update the index value. */

*** stop 4b ***;


**** Displaying the actual code ****;
/* 		In SAS, with macro variables, SAS first
		resolves the macro variable(s), then
		*generates* the actual code,
		and then executes it. */

/* We can see this code in the SAS  log 
	if we use the SYMBOLGEN option: */

/* But first, here is a reminder of how we 
	defined the p5a macro variable:
%let p5a=%str(
	title "Listing of first 5 records from library &lib, member &dsn,";
	title2 "on &sysday, &sysdate..";
	proc print data=&lib..&dsn (obs=5);run;
	title;
);
*/

* Note that all macro variable references are resolved here (%put);
%put &p5a; 

&p5a; * but we don't see these when we *invoke* the macro variable;

/* To see the actual code when we invoke the 
	macro variable, we can use the SYMBOLGEN (symbol generation)
	option: */
options symbolgen;
&p5a
options nosymbolgen;


* Questions?;



*   *********** Stop 5 ***********;








**** More Macro functions ****;

/* There are many macro functions. We will look
	at two more of them here. */

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

	/* macro functions:
		%substr. Like the "normal" substr, but operates on macro variables.
		%upcase. Like the "normal" upcase, but operates on macro variables.
		(As of SAS version 9.4, there is also a %lowcase function, which is like the "normal" lowcase function, but for macro variables.) 

		By now, perhaps *you* are also thinking of these 
		macro variables, and their functions, as 
		"floating above" our normal work in SAS?*/



* Questions?;



*   *********** Stop 6 ***********;










****************************
******** SAS Macros ******** 
****************************;


/* Well, macro variables are very useful in SAS,
	but they have some limitations. For example,
	1. It is pretty awkward when one macro variable
		relies on the definition of a few other ones,
		like the p5a macro variable. This can be even 
		more awkward because SAS define macro variables 
		"by value", not "by reference".
	2. If we want to write more sophisticated
		and flexible code, storing all those lines
		of code inside of a %str function is 
		not very clean.

	For these reasons and more, we will now discuss
	SAS macros. We'll start with some simple examples
	and then look at more complex ones. */



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

/* Notes:
	1. We begin with %macro
	2. We also define the name of the macro in this statement;
	3. We define the macro in the following text;
	4. We end the definition with %mend;
		(For clarity, an option is to include the macro name
		again at the end of the definition. Here we would write 
		   %mend p5m; )
*/

/* Macro execution: */
%p5m;


/* Note:
	1. The "&" is gone--that's for macro variables.
		Instead we use "%" to call the macro */


/* Next, let's change the following code into a macro:

%let p5a=%str(
	title "Listing of first 5 records from library &lib, member &dsn,";
	title2 "on &sysday, &sysdate..";
	proc print data=&lib..&dsn (obs=5);run;
	title;
);

*/

* Question: Please try to convert this into a macro named p5am,
	and then execute the macro.;





*   *********** Stop 7a ***********;
























/* define macro */

%macro p5am;
	title "Listing of first 5 records from library &lib, member &dsn,";
	title2 "on &sysday, &sysdate..";
	proc print data=&lib..&dsn (obs=5);run;
	title;
%mend p5am;

/* execute macro */
%p5am;



* Questions?;





*   *********** Stop 7b ***********;


/* Example 2. Macros with arguments. */

/* The two macros we looked worked fine. However:
	1. The first one only does one thing:
		prints out the first five records of
		the SAS data set associated with _last_.
	2. The second one is more flexible, but
		relies on previously-defined macro
		variables.
	Let's see how to address both of these
	shortcomings by using *parameters* --   */

/* Let's first generalize the p5m macro
	to use a number other than "5".*/

/* Macro definition: */

/* The macro below now includes a *parameter*,
		nobs
	This turns out to define a *local* macro variable.
	It can be used only within the p5m2
	macro.
*/

%macro p5m2(nobs);
	proc print data=_last_ (obs=&nobs);
	run;
%mend p5m2;

/* Execute the following 3 lines of code one 
   line at time. Again, note that a ; is not 
	required--this is a macro call,
	not a SAS statement */
%p5m2(7)
%p5m2(2)
%p5m2; 
	/* This generates an error--no parameter
		was supplied. Note--without the ; here,
		there is no error. SAS would just be
		waiting for more info. For example,
		execute the following 3 lines of code one line at a time,
		and look at the log for each line: */

/*	Note the following idea applies to PC SAS but
	not to SAS Studio (The reason appears to 
	be that every submisstion to SAS
    Studio is treated as a complete 
	submission, so errors get generated instead.) */

%p5m2

(3)

/* See? 

*   *********** Stop 8a ***********;


	By the way, I will almost guarantee that 
	at some point in learning macros, you will
	either have an unfinished macro definition
	or an unfinished macro execution. SAS will be
	waiting patiently for you to finish, and 
	you will be pulling your hair out wondering
	why SAS is not responding to your commands.
	(If this gets you hopelessly lost, just save your
	work, exit SAS, and then start SAS again.)*/


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

* What is the current value of macro variable dsn?;
%put &dsn; 
/* This value did not change. This dsn is in the *global
	symbol table*. The dsn we used in %p5m2
	was local to only that macro (it is in 
	a *local symbol table*. It is local to only that macro).
	   This is analogous to arguments in R functions--yes? 
	This is another way that a *parameter* in a SAS macro is like
	an *argument* in a R function. It is local only to that function.*/

/* The parameters above are called *positional parameters*. 
	If we have two positional parameters then we need two values,
	and in the correct order (positions) */

* Questions?;



*   *********** Stop 8b ***********;







/* Another way to express parameters is by
	using *keyword parameters*. Again, this is similar to R.
	An example: */

%macro p5m3(data=_LAST_, nobs=5);
	proc print data=&data (obs=&nobs);
	run;
%mend p5m3;

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

/* no arguments supplied, so ";" is 
	needed--see earlier note for why.
	Well, at least this is true for SAS PC.
	
	However, this appears to run in
	SAS Studio (The reason appears to 
	be that every submisstion to SAS
    Studio is treated as a complete 
	submission) */

%p5m3()
/* This also works. I will let you
	figure out why. */

%p5m3(data=perm.profits,nobs=4)

%p5m3(data=expenses)

%p5m3(_last_,4)
	* error--see log for why;


* Questions?;



*   *********** Stop 8c ***********;











**** Executing a SAS macro writes (generates) code ****;


/* This is *very important* to understand--
	Remember that I said I think of macro variables
	as "floating above the SAS data sets".
	Well, I think of SAS macros as 
	"floating above normal SAS". Not just 
	the SAS data sets, but
	above the code that *generates*
	things like SAS data sets or PROC output.

	To see this, let's use another option,
	MPRINT. */

options mprint; * OK, keep your eye on the SAS log.;

%p5m3(data=perm.profits,nobs=4)

%p5m3(data=expenses)

/* See? This is actually *writing* code (and then 
	executing it).

	And if you don't see this now, you soon will...
	
	"options mprint" just lets you *see* the code that is
	being written. It is being written whether or not 
	you use MPRINT to have it displayed in the log!
	
*/


* Questions?;



*   *********** Stop 8d ***********;



**** Looping in Macros ****;

/* Example 3. More complex Macros--looping. */



/* The SAS data set perm.x1x500Only contains 100 records
	of 500 variables. */

%p5m3(data=perm.x1x500Only,nobs=2)


/* let's define a macro that will take data such as this
	and only keep a patterned subset of x1-x500.

	Note: From this example you will see that	 
	using a macro is one way that you may be able to 
	have more control over a long list of variable names.

	Note that such a task is trivial in R--variable 
	names are just a character vector, so are simple to
	modify, subset, and so one. But this is 
	difficult in SAS--variable names are not
	values (unless we use PROC TRANSPOSE on them for a bit...),
	so they can be annoying to work with. You have 
	seen this already but make sure you understand
	this. Make sure you *really* understand this.*/

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



*   *********** Stop 9a ***********;








/* Macro execution */

%getsubsums1(start=10, stop=20, by=2)
/* Make sure you look at the SAS log (MPRINT option
	is still on) to see the code that was generated */

proc print;run;
/* OK, now we are really getting into the power of macros! */

/* Remember how "forgiving" SAS can be? In week 1, it 
	corrected our "inpux x y" with only a warning
	("WARNING: Assuming the symbol INPUT was misspelled as inpux.").
	Well, don't expect this when you write macros.
	(Which is actually good--if you make a mistake, do you 
	really want some computer algorithm to guess what you
	meant to write?)

	
	This means that you need to know how write macros correctly
	--if not, expect errors. And keep in mind that there are
	several kinds of errors. These include:
	1. An error that (a) will not let the macro run.
		(Syntax error--common name: see, for example, section 1.3 of http://greenteapress.com/thinkpython/html/thinkpython002.html)
	2. An error that will (a) let the macro run but
		(b) cause an error in executing the SAS
		code that the macro generated.
		(Runtime error)
	3. An error that will (a) let the macro run and
		(b) will run the SAS code that the macro generated
		but (c) will not do what you intended to do.
		(Semantic error)
	The last error is the most dangerous!



	Next, let's look at the syntax for this code:

	keep %do i=&start %to &stop %by &by; x&i %end;  ;
                                     (a)       (b)(c)

	1. There is a %do-%to-%by-%end combination here.
		This looks similar to the do-to-by-end combination in normal
		code (including the optional %by). However,
		we are now using this to *write* code (and anywhere
		in SAS). By comparison, the do-to-by-end combination 
		is already code, and can be used only in a DATA step.
	2. The index value i becomes a local macro variable.
		Note that it is "i" in the %do, but then "&i" later
		for referencing.
	3. The values for start, stop, and by could have been
		normal numbers (e.g. 2, 10, 4). However, for the 
		flexibility I wanted, I made these macro arguments.
	4. (This point is the most subtle.) There are really two
		different type of ";" here:
		a. Those that belong to %do-%to-%by-%end. These are needed
			but will *not* appear in the generated code.
		b. Those that do not belong to %do-%to-%by-%end. This
			are standard semicolons and will appear in the 
			generated code.
		If you don't keep track of these, your code will
		likely not be generated correctly. So please be
		able to distinguish these two types of semicolons.
	5. In our example, the semicolons labeled (a) and (b)
		belong to %do-%to-%by-%end; the one labeled (c) does not--
		that one will show up as semicolon in the resulting SAS code. */


* Questions?;



*   *********** Stop 9b ***********;

/* Let's drop semicolon (c) to find out what happens: */

%macro getsubsumsTest(start=1, stop=500, by=1, 
			ip=perm.x1x500Only, op=);
	data &op;
		set &ip;
		keep %do i=&start %to &stop %by &by; x&i %end;
	run; 
%mend;

/* macro still gets defined. But ... */

%getsubsumsTest(start=10, stop=20, by=2)

/* See the code that is generated? We are still
	in the middle of the DATA step; the code is
	written to keep the x's we wanted, but
	also a variable named run. 
	Let's put in a real run statement to 
	see what happens. (MPRINT is a good option
	to turn on when you are testing macros!) */

/* (By the way, here is an example where SAS
	is waiting patiently for us to finish
	our DATA step. Without MPRINT, we would 
	probably be pretty confused by now. */

run;

/* Well, the forgiving part of SAS showed up 
	after all! But this problem should be spotted
	and fixed. 

	Now let's try skipping the first semicolon instead: */
		
%macro getsubsumsTest(start=1, stop=500, by=1, 
				ip=perm.x1x500Only, op=);
	data &op;
		set &ip;
		keep %do i=&start %to &stop %by &by x&i %end;;
	run; 
%mend;

/* macro error is generated. ("Compiled"--
	a standard software term.) */

/* Now let's suppose we add an unneeded semicolon,
	here after the x&i: */
		
%macro getsubsumsTest(start=1, stop=500, by=1, ip=perm.x1x500Only, op=);
	data &op;
		set &ip;
		keep %do i=&start %to &stop %by &by; x&i; %end;;
	run; 
%mend;

/* defined OK */



* Question: what will happen when we try to execute this?
	In particular what code will be generated and 
	why will this create a problem? 



*   *********** Stop 9c ***********;

%getsubsumsTest(start=10, stop=20, by=2)


/* See the MPRINT output. Did you figure this out
		ahead of time? If not, can you see
		the problem from the MPRINT o/p? */



/* Here is the problem: the generated code is
   data ;
   set perm.x1x500Only;
   keep x10;
   x12;
   x14;
   x16;
   x18;
   x20;
   ;
   run;

This is not what we want. */


/* Note: 
	A number of macro features, such as %do-%to-%by-%end,
	can *only* be used in macro definitions. As the Macro 
	reference manual says of such features, these are part of the
	"Macro Language Statements Used in Macro Definitions Only" 
*/


**** Macros generate code. But they only fully execute 
	the code when you specify it. ****;

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

* Again, make sure you look at the SAS log  
	with option MPRINT to see what code gets generated;

* Questions?; 



*   *********** Stop 9d ***********;



**** A bit more looping in Macros ****;

/* Example 4. More complex Macros--two sets of loops. */



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

/* As you can see, we now have a %if-%then-%else combination. 
	This has the same similarities to, and difference from, if-then-else
	as was noted above for %do-%to-%by-%end and do-to-by-end */

* Questions: can you figure out what this code is doing? Please try.;
 



*   *********** Stop 10a ***********;

















%getsubsums2(start=10, stop=20, by=2)
/* Look at MPRINT ... */

proc print;run;


/* Once again, we need to be very careful with the two kinds of 
	semicolons:

	xsum=sum(%do i=&start %to &stop %by &by; x&i %if(&i>=&stop) %then; %else ,; %end;) ;
                                          (a)                       (b)      (c)   (d)(e)


	(a) and (d) are part of %do-%to-%by-%end, 
		so these do *not* get generated in the code.

	Similarly (b) and (c) are part of the %if-%then-%else combination,
				so these do *not* get generated in the code either.

	Only (e) is a "real" semicolon.

	Also note the subtlety here--the %then phrase has nothing following it
	except for a semicolon--this means that when &i>=&stop then don't
	generated any extra code. Otherwise (see %else), generate a comma.

	Also, note the ")" after the %end. This is 
		simply the closing parenthesis of "sum(".

*/
 


/* Note that this code, as written, is not "robust". It 
	only works when the stop value is found exactly in
	the loop: */

%getsubsums2(start=10, stop=20, by=4)

/* You see what the problem is--yes?

	So, it's fine for use by the person who wrote the
	code, but it would not be good to distribute the
	macro as written. */


* Questions?;


*   *********** Stop 10d ***********;

















**** Searching for the i-th element in a string ****;

/* Example 4. Using %SCAN. */

/* Syntax for %SCAN, using an example. */

%put &names;
%put %scan(&names,1);
%put %scan(&names,3);
%put %scan(&names,5);

/* See? */


* Questions?;


*   *********** Stop 11a ***********;




/* Suppose we want to create separate SAS
	data sets for 1 or more quarters of the
	profits data. (This is just a simple example 
	to show you an idea.) */

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

/* Please see the code that this generated:
	4 lines for each loop X 3 loops = 12 lines.
	Please make sure you "get" this idea:
	that the macro *writes* code */


/* See SAS help for more information on %scan
	and related *macro functions*, and also
	for %do-%while-%end and related  
	*macro statements* .*/

/* From SAS help, here is information on a
	*macro statement* :

		%DO %WHILE (expression);
		text and macro program statements
		%END;

	expression: can be any macro expression that resolves 
	to a logical value. The macro processor evaluates the 
	expression at the *top* of each iteration. The expression 
	is true if it is an integer other than zero. The expression 
	is false if it has a value of zero. If the expression resolves 
	to a null value or to a value containing non-numeric characters, 
	the macro processor issues an error message.

	Note that the expression must be placed in parentheses. */


* Questions?;


*   *********** Stop 11b ***********;









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





/* The section we just did is not designed to make you an expert in
	the SYMPUT subroutine or the %SYSFUN macro, but to
	show you some ways that these may be used.

	There are many other macro features in SAS. See
	SAS help and other references for more information.*/

* Questions?



   *********** Stop 12 ***********;


















**** Defining macros from code in other files ****;

/* Here, we have been defining macros in our SAS code itself.

	But it is pretty common to have a set of macros that 
	you may wish to use in a number of different SAS
	sessions. If so, you can write the code that defines
	one (or more) of them in a file (typically with extension
	.sas). Then you simply %include that file in your
	session. As you know,
		%include fname;
	reads in and runs the code in fname. */


**** Defining macros from code in other files ****;

/* Here, we have been defining macros in our SAS code itself.

	But it is pretty common to have a set of macros that 
	you may wish to use in a number of different SAS
	sessions. If so, you can write the code that defines
	one (or more) of them in a file (typically with extension
	.sas). Then you simply %include that file in your
	session. As you know,
		%include fname;
	reads in and runs the code in fname. */

/* For example, I wrote code to define the macro 
	%repeat in Wk13_macroEx.sas. Here I will read in
	and execute that code. I will also use the 
	source2 option to display the file's contents
	in the SAS log: */
	
/* Define the macro by reading in (and executing)
	the code in the Wk13_macroEx.sas file*/

%include "&dirSASmacros.Week6_macroEx.sas"/source2;
	
/* Please see the SAS log to see the file's contents. */



/* Execute the macro */

%repeat(**** The end of Week 13 code! ****,10)
* See o/p in SAS log;






































