%let dirdata=/folders/myshortcuts/SAS_part/week 4/;
libname perm "&dirdata"; * for reading in some SAS data sets;

/* There are basically two ways to reshape data in SAS:
	1. PROC TRANSPOSE
	2. DATA step, often using an ARRAY statement

	We will first focus on PROC TRANSPOSE.

	This can perform many of the same tasks that the 
		melt/dcast pair can do. However:
	1. The *thinking* is very different.
	2. The *syntax* (of the SAS code) is very different.
	3. (To me, at least) The operations to perform are 
		not as natural.
	4. (From what I see) There is no emphasis on what 
		is a "good shape" for data to have. (Compare this
		to the "tidy data" idea.)

	To be fair to SAS, I'd say PROC TRANSPOSE is similar
	to R's reshape function, with respect to items 1-3.
	And it is only because of one contributor (Wickham)
	that I am mentioning *any* of these 4 items.

	I'd say what I have found useful is that:
	A. PROC TRANSPOSE initially wants to transpose 
		the entire data set.
	B. If you do not want your data fully transposed
		(we usually don't) then we often wind up
		transposing it in BY groups.

/* OK! First the idea, then some examples */

/* From TransposeAndAlternatives046-2007.pdf, in Readings.

PROC TRANSPOSE SPECIFICATION IN THREE EASY QUESTIONS
(I added some notes to this...)

PROC TRANSPOSE is controlled by three specification statements:
	the ID statement, the VAR statement and the BY
	statement. The variables in these statements can found as follows:

	1. Which variable in the input data set contains (after formatting!)
		the variable names (columns) of the output data set?

	This variable is specified in the ID statement. 

	(Note: you can use one or more variables here, just as you can in R. We will examine this below.)
	
	From the question itself, this variable (or variables) must have a 
	*unique value* in each observation (or per BY group) after 
	formatting, because variable names must be unique.

	(SAS will try to fix any names that violate variable-name rules.
	But if the ID variable is numeric you should attach a prefix to
	its value, This prefix is declared in
	the PROC statement with the PREFIX= option.)
	

	2. Which variable(s) (columns) in the input data set contain the 
		values to be transposed?

	These variables are declared in the VAR statement, and these
	variable names become values of a new column (var) in the o/p.
	Default name is _NAME_, but it's better to assign your own name
	with the option NAME= in the PROC statement.

	If the VAR statement is left out, then all numeric variables which do not 
	as yet have any other task (i.e. declared in an ID or BY statement) 
	will be transposed. But it's a good idea to do this explicitly.

	
	3. For which group of observations is the value of the ID variable
		unique (forms a 'block' to be transposed)?

	This group of observations is designated in the BY statement. 
	The presence of the BY statement means that the data set will 
	not be transposed as a whole, but transposing will take place per BY group.*/

/*First data set: balances*/

data balances;
	infile "&dirdata.balances.csv" dsd firstobs=2;
	input customer $ checking savings mortgage credit_card;
run;
proc print data=balances;run;

/* Example 1. A simple transpose */

/* NOTE: We will *not* start with "melting" the SAS data set.
	We simply reshape it from its current state to another state */

/*	\ we want the rows to be columns and we
	want the columns to be rows */

/*	1. Which variable in the input data set contains (after formatting!)
		the variable names (columns) of the output data set?

		This variable is specified in the ID statement. 


	2. Which variable(s) (columns) in the input data set contain the 
		values to be transposed?

		These variables are declared in the VAR statement */


* Question: For this problem, what is the ID var? The VAR var(s)?;



*   *********** Stop 1 ***********;



















/* Well, we want to transpose, so we want
	1. The values in the var *customer* to become columns names.
		This makes customer the ID var
	2. The columns named checking--credit_card to become
		The values in a (new) var.
		This makes these columns the VAR vars. */

proc transpose data=balances out=balances2;
	id customer;
	var checking--credit_card;
run;
proc print;run;

/* Instead of _NAME_, we can assign a different name 
	with the NAME option. Let's do that.
*/
proc transpose data=balances out=balances2 name=account;
	id customer;
	var checking--credit_card;
run;
proc print;run;


/* Example 2. "Melting" the SAS data set */
proc print data=balances;run; * a reminder;

/* Let's say we want to "melt" the SAS data set. 
	(This is just an exercise. Whether this would be
	useful in SAS is another question.)

	So, we want 
	1. *customer* to remain as a column
	2. A new column that contains checking, ..., credit_card
		as values
	3. A new column that contain the numeric values

	The SAS way to think about this:
	a. Look at the Smith row of data. We really want to 
		transpose the rest of this row (from 1x4 to 4x1). Yes?
	b. We want to transpose the Jones row in the same way.
	c. That is, we want to transpose "BY customer" */

* Question: What is the ID var now? What is the VAR var(s) now?;



*   *********** Stop 2a ***********;


















/* Well the VAR vars are the same as before: checking--credit_card
		These are the columns we want to transpose.
	However, in these (extreme) case there is no ID var--we want
		all of the numbers to be in one column. (See?)*/

/* As always, if we want to do a PROC with a BY, we first need
		to do a PROC SORT with a BY ... */

proc sort data=balances out=temp1; 
	* out=temp1 to preserve the original data set for our exercises;
	by customer;
run;

proc transpose data=temp1 out=balances_melt name=account;
	var checking--credit_card;
	by customer;
run;
proc print data=balances_melt;run;

/* Not a good default name (COL1)--easiest way to fix for this case is
	in the PROC statement, using
	out=balances_melt (rename=(col1=amount)) */

* Questions?

*   *********** Stop 2b ***********;







/* Example 3. With the *type* variable added */

/* Let's add the *type* variable as a way to subset the *account*
	variable, and put result into a new SAS data set.*/

/* (DATA step issue) I want to put the var names in their natural order. 
	To do this in SAS, we need to use a "trick" 
	(as discussed earlier in the course): use a RETAIN
	statement before the SET statement for those vars you want to list
	first. (Note that *type* is a new var, and RETAIN apparently does
	not require that we declare type as either numeric or character. 
	This is good, as it makes the coding a little more natural.) */

data balances_melt2;
	retain customer type;
	set balances_melt;
	length type $11;
	if account in ("checking" "savings") then
		type="assets"; else type="liabilities";
run;
proc print data=balances_melt2;run;

/* Using this SAS data wet we want to:
	Transpose the data set, keeping type and variable as the way it is, but the values of customer
	variable (John and Smith) will now becomes columns.*/

* Question: 
		What is the ID var now?
		What is the VAR var(s) now?
		What is the BY var(s) now?

	(Note that these answers depend not only on how we
		want the shape of the *output* data set to be
		but also on the shape of the *input* data set.
		In R, the answer only depends of the shape of
		the output data set--the input data set was
		in a canonical (standard) form, the melted form.)
		


*   *********** Stop 2c ***********;


















* Solutions. Is this what you found?
	If not, try it with your solution and see
	what the resulting data set looks like.;

proc sort data=balances_melt2 out=temp2;
	by type account;
run;

proc transpose data=temp2 out=temp2a;
	id customer;
	by type account;
run;
proc print data=temp2a;run;

/* Now customer and variable are columns, the values of variable type (assets and liabilities) will become new columns
 */

proc sort data=balances_melt2 out=temp3;
	by customer account;
run;
proc print data=temp3; run;

proc transpose data=temp3 out=temp3a;
	id type;
	by customer account;
run;
proc print data=temp3a;run;

/* Let's see what happens if the the combination of the var's 
	in the ID and BY statements do *not* uniquely identify a row.
	Customer stays as a column, but only specify that the value of type (assets and liabilities) to be become columns.
 */

/* No need for PROC sort--temp3 is "BY customer" */

proc transpose data=temp3 out=temp3b;
	id type;
	by customer;
run;

/* So, PROC TRANSPOSE produces an error message. That's
	OK. This PROC was designed *only* to reshape. */



/* Here is a scary way to override this: the LET option */
proc transpose data=temp3 out=temp3b let;
	id type;
	by customer;
run;
proc print data=temp3b;run;
/* As SAS help explains, with LET, PROC TRANSPOSE "transposes the 
	observation that contains the last occurrence of a particular 
	ID value within the data set or BY group." */

* Question: do you think it would normally be 
	a good idea to use LET?;
		


*   *********** Stop 3 ***********;

























* The answer to that question should be obvious...;





/* Example 4. Getting summary data, then reshaping
	First get the summary of data (sum, number counts or you can get mean median...)
	Output a separate table of the summary of data. 
	Transpose this summary table into a wide format data set. 
	Then combine (merge) with the result of previous step. 
	We have a new data set and has extra columns of summary data. 
*/

proc print data=balances_melt2;run;

* First, find the sum and N of accounts for each customer and type
	(easier in the melted form: yes? And easier to extend to more 
	complex problems?) ;
proc means data=balances_melt2 noprint;
	by customer type; * in correct order...;
	var col1;
	output out=temp4 (drop=_type_ _freq_) sum=sum n=n;
run;
data temp4;
	set temp4;
	sum=round(sum);
run;
proc print data=temp4;run;

* Second, "melt" the data set--in more usual
	language, here this means to put both numeric
	columns into 1 numeric column.;

* Question: ID var? VAR var(s)? BY var(s)?;
		


*   *********** Stop 4 ***********;




























proc transpose data=temp4 out=temp4a (rename=(col1=value)) name=variable;
	by customer type;
	var sum n;
run;
proc print data=temp4a;run;


* Third, show info in a "wide format"
customer stays as a column, value of type (asset and liability) and variable (sum and count n) become columns. 

* Question: ID var? VAR vars? BY vars?;

		


*   *********** Stop 5 ***********;

/* We'd like to change *two*
	columns from going "down" to going "across", and
	such a change is what the ID var does.

	It turns out we can do this, but to make
	the var names look nice, we should include
	a delimiter. Here's how: */

* For Jones, we want the 4x1 set of numbers to become 1x4,
	and the same is true for Smith. So, customer is our BY var
	(See? We want to transpose, by customer, from 4x1
	to 1x4) ;

proc transpose data=temp4a out=temp4b delimiter=_;
	by customer;
	id type variable;
	var value;
run;
proc print data=temp4b;run;




/* Note that we could also have combined these
	values in a data step. If you have 3 columns
	and you want to use one delimiter
	between columns 1 and 2 and a second delimiter
	between columns 2 and 3, this method would 
	be useful: */

data temp4a2; 
	set temp4a;
	type_variable=catx("_",type,variable);
run;
proc print data=temp4a2;run;

* We now have one ID var, so...;

proc transpose data=temp4a2 out=temp4c;
	by customer;
	id type_variable;
	var value;
run;
proc print data=temp4c;run;

/* Same result as in temp4b. Note that the 
	other two vars, type and variable, are
	not in the new data set (nor should 
	they be). */


* Questions?;



*   *********** Stop 6 ***********;






/* Second data set: the Pew study*/

proc contents data=perm.pew_table order=varnum; run;
proc print data=perm.pew_table;
run;

*Note: I changed the var names to be acceptable to SAS.;



*The usual questions: how? ID var? VAR var(s)? BY var(s)?

*Well, I hope by now you are realizing that when we put 
	all of the numeric data into one column that there 
	is no ID var (If there were, and that ID var
	had m distinct values--then this would
	put the numeric data into m columns. Not what we want.);

*Also (in this example) we want the data for each religion, 
	which is currently 1x10, to be transposed to 10x1.
	So, we want to transpose BY religion;

proc transpose data=perm.pew_table out=pew_melt (rename=(col1=freq)) name=income;
	by religion; * already sorted...;
	var S10k--DKR;
run;
proc print data=pew_melt(obs=12);run;


/* (Note how SAS also saves labeling information.) */

/*	This is how we could "cast" the data back to its 
		original form, including labels: */
proc transpose data=pew_melt out=temp5 (drop=_NAME_);
	by religion;
	id income;
	idlabel _LABEL_;
run;
proc print;run;
proc print label;run;
proc contents order=varnum;run;

/* 
	To begin, let's find the distribution of religions in the study:*/

* First, find the total freq for each religion.;

* (Question, for you to figure out: 
	easier to do this in the melted form or the original form?);

proc means data=pew_melt noprint;
	by religion;
	var freq;
	output out=pew_religions (drop=_type_ _freq_) sum=sum;
run;

* Second, find the grand total;
proc means data=pew_religions noprint;
	var sum;
	output out=pew_total (drop=_type_ _freq_) sum=gr_sum;
run;

* Third, combine these to get the percents;
data pew_religions;
	drop gr_sum;
	if _n_=1 then set pew_total;
	set pew_religions;
	pct=sum/gr_sum;
	format pct percent7.1; *does not look good with 5.1 or 6.1--try it;
run;
proc print data=pew_religions (obs=12);run;

** Redo for income...;
proc sort data=pew_melt out=pew_melt_IncOrd;
	by income;
run;

proc means data=pew_melt_IncOrd noprint;
	by income;
	var freq;
	output out=pew_incomes (drop=_type_ _freq_) sum=sum;
run;

data pew_incomes;
	drop gr_sum;
	if _n_=1 then set pew_total;
	set pew_incomes;
	pct=sum/gr_sum;
	format pct percent7.1; 
run;
proc print data=pew_incomes (obs=12);run;

* But note that the data is now arranged incorrectly--
	not good for presenting;

* You may want to think about:
	1. How SAS does have this problem.
	2. Whether this problem can be corrected in SAS;

* Questions?;


*   *********** Stop 7a ***********;





/* let's say we want to find the income  
	distribution for each religion. One objective is
	to see what the percent of "Don't know/refused" to tell
	their income are for each religion. If it varies widely,
	that is another source of concern. */

/* Well, we can do this as follows 
	(and as you should know by now!) */

data pew_melt2;
	merge pew_melt pew_religions (keep=religion sum);
	by religion;
	pctIncByRel=freq/sum;
	format pctIncByRel percent7.1;
run;
proc print data=_last_ (obs=12);run;

* let's just list out the Don't know pct for each religion;
proc print data=pew_melt2;
	where income="DKR";
	var religion income pctIncByRel;
run;

* Aside: this result could also be obtained directly in
	PROC TABULATE, and the results could be saved;
proc tabulate data=pew_melt out=pew_tableA;
	var freq;
	class religion income;
	table religion,(income all)*freq*rowpctsum*f=7.1;
run;

* However, you can see (if you haven't already) that SAS gave an
	(unwanted) label to *income* and the income levels are in
	alphabetical order (which is meaningless);
proc print data=pew_tableA (obs=12);run;
proc print data=pew_tableA (firstobs=175 obs=198);run;
	* data from PROC TABULATE is in a "melted" form. But it has some
		unwanted vars and--because of the "all" in PROC TABULATE
		--has some unwanted rows as well;
* End of Aside;



* Questions?;


*   *********** Stop 7b ***********;







/* Third data set: the Weather data*/

proc contents data=perm.weather2010 order=varnum; run;
proc print data=perm.weather2010;run;
	* Note that missing values have already been handled here;

* Let's first put all the temperature data in one column.
	Hopefully, by now you know how to write the code to do this;

proc transpose data=perm.weather2010 out=clean1 name=dayc;
	by id element year month;
	var d1-d31;
run;

** oops...;

proc transpose data=perm.weather2010 out=clean1  name=dayc;
	by id year month element; * this should work;
	var d1-d31;
run;

proc print data=_last_ (obs=50);run;


* Question: what steps should we take next to put 
	the data into a more useful form? 





*   *********** Stop 8 ***********;




















/* As before, let's first
	1. drop missing values (can't be done in PROC TRANSPOSE--
		maybe as an output option?)
	2. make day numeric (need a new var for this)
	3. use lower case for temp names
	4. convert temps to Celsius */

data clean1a;
	drop dayc;
	set clean1;
	if col1 ne .;
	dayc=tranwrd(dayc,"d",""); * note the order: x, from, to;
	day=input(dayc,3.0);
	element=lowcase(element);
	col1=col1/10;
run;
proc print data=clean1a (obs=10);run;


* Finally, let's make it tidy by having two columns for the measured variable;

* The usual question: what is the code to do this in PROC TRANSPOSE?;



*   *********** Stop 9 ***********;
























proc transpose data=clean1a out=clean2 (drop=_NAME_);
	by id year month day; * I think data is already in this order;
	id element;
run;

** but it's not... So;
proc sort data=clean1a;
	by id year month day;
run;

proc transpose data=clean1a out=clean2 (drop=_NAME_);
	by id year month day; * order should be OK;
	id element;
run;
proc print data=clean2 (obs=10);run;

/* Shouldn't we have included
	var col1;
   here? Technically, yes. However,  from SAS help
      * If you omit the VAR statement, then the TRANSPOSE procedure 
        transposes all numeric variables in the input data set that 
        are not listed in another statement. 
      * You must list character variables in a VAR statement 
        if you want to transpose them. Note: If the procedure is transposing 
        any character variable, then all transposed variables 
        will be character variables. 


/* Bring in the quarter of the year. We will use this in a plot. */

/* Oh, and I want to plot tmax-tmix and the average in a minute. 
	I can't do that directly in SAS--I need to create 
	new vars first.	So let's do that here as well */

data clean2;
	set clean2;
	quarter=ceil((month-.5)/3); * R: ceiling. SAS: ceil;
	tmaxTminDiff=tmax-tmin; * note how this is easy with tidy data...;
	tmaxTminAv=(tmax+tmin)/2; 
	label tmaxTminDiff="tmax-tmin" tmaxTminAv="(tmax+tmin)/2";
run;
proc print data=clean2 (obs=10) label;run;

proc sgplot;
	scatter x=tmaxTminAv y=tmaxTminDiff /
		group=quarter markerattrs=(symbol=circlefilled);
run;
* (colors for this style seem hard to distinguish--yes?);

/*Pretty uninteresting--very small mean temp range, I'd say.
	But tmax-tmin seems lowest in Q3: */

proc sgplot;
	scatter x=quarter y=tmaxTminDiff / 
		group=quarter markerattrs=(symbol=circlefilled);
run;


*  Questions? ;


   *********** Stop 10 ***********;





/* Finally let's pretend this is my original data 
	set and I want to reshape back to the
	format that we had started with. That is: */
proc print data=clean2 (obs=10) label;run; 
	* reminder of what we have. Pretend this is the original;

proc print data=perm.weather2010 (obs=5);run;
	* pretend this is what we want;

* Let's not worry here about Celsius vs Celsius over 10, 
	or tmin vs TMIN. But we do have to worry about days
	--we don't have the "d" with them any more. But SAS
	has a prefix argument to handle that:;

proc transpose data=clean2 out=oldone prefix=d name=element;
	by id year month;
	var tmax tmin;
	id day;
run;
proc print data=oldone (obs=5);run;

/* Not bad. However, and as you should know:
	1. The days are no longer in order
	2. Any day with no data simply does not appear 

	Let's try that SAS trick to see if we can fix both problems: */

data oldone2;
	retain id year month element d1-d31;
	set oldone;
run;
proc print data=oldone2 (obs=5);run;

/* Not quite. So, let's try this additional trick: */

data oldone2;
	retain id year month element d1-d31;
	set oldone;
	keep id year month element d1-d31;
run;
proc print data=oldone2 (obs=5);run;

/* Still no. So, let's try this additional trick, to
	actually create values for d1-d31: */

data oldone2;
	retain id year month element d1-d31;
	array dd d1-d31;  do i=1 to 31; dd(i)=.; end;
	set oldone;
	keep id year month element d1-d31;
run;
proc print data=oldone2 (obs=5);run;

/* Yes--this one worked. 

	It's not very satisfying trying to play around
	like this. But this "all 31 days" listing would 
	be useful if we had many data sets like this 
	that we needed to put into a 
	standard form for presenting. */


*  Questions? ;


   *********** Stop 11 ***********;




/* Fourth data set: the profits data*/

********* Reshaping in the Data Step with Arrays **********;

/* We'll just do a little bit of this to show you the idea./

/* We'll use a new, artificial, data set.

	(*ranuni*, below, generates pseudo-random numbers
	between 0 and 1. If we put in a positive number
	as a seed, the same sequence of random
	numbers will be produced. Useful for 
	classroom exercises, for example. Like this one.) */

data profits;
	do year=2011 to 2013;
		do qtr=1 to 4;
			profit=round(500+1000*ranuni(335813652));
			output;
		end;
	end;
run;
proc print data=profits;run;

/* Suppose I want one row for each year, and 
	want 4 columns for profits. Based on
	what we've done before, we could do
	this in PROC TRANSPOSE: */

proc transpose data=profits out=profitsWide (drop=_name_) prefix=qtr;
	by year;
	id qtr;
run;
proc print data=profitsWide;run;

/* Here is how we can do this with a DATA step
	and an array statement.
		Make sure you understand this code. */

data profitsWide2;
	retain year; * yes, I am using this trick again;
	drop qtr profit i;
	array q qtr1-qtr4;
	do i=1 to 4;
		set profits;
		if qtr ne i then do; * a modest check;
			put "Error: " qtr= i= _n_=;
			stop;
		end;
		q(i)=profit;
	end;
run;
proc print data=profitsWide2;run;
	* Same as profitsWide;

/* Note that every loop of the data step reads
	in 4 records from the input data set,
	and outputs 1 record. From long to wide. */


/* Now let's do the opposite--from wide to 
	long (back where we started) */

data profitsLong2;
	drop qtr1-qtr4;
	set profitsWide2;
	array q qtr1-qtr4;
	do qtr=1 to 4;
		profit=q(qtr); 
		* no need for a check: qtr1-qtr4 are 
			known to be in the data set;
		output;
	end;
run;

proc print data=profitsLong2;run; * long version;
proc print data=profits;run; * original data set;

/* This use of the data step and array is best 
	suited to situations 
	like this one--the var that we wanted to change
	from "down" to "across", qtr, was numeric
	and regularly spaced (see above for why this
	is nice for checking things).

	And the vars that we later wanted to change
	from "across" to "down", qtr1-qtr4,
	were of the form Name+IndexNumber (see
	above for why this is nice to have).

	The weather data was like this: d1-d31.
	The balances data was not:
		checking, savings, credit_card, mortgage 
	Still doable, I suppose, but pretty awkward.
	PROC TRANSPOSE is much nicer for that. */


* Questions?


   *********** Stop 12 ***********;
