%let dirdata=/folders/myshortcuts/SAS_part/Week 4/; * possible SAS Studio access--
* Use one of these, or create a new one as needed;
%let dirOUT=/folders/myshortcuts/SAS_part/Week 4/;
/* This week's main topic: Combining Data Sets
	1. stacking two (or more, here and below) data sets
		a. Same variables in both
		b. Not same variables in both
	2. (Not done here: interleaving two data sets)
	3. parallel merging of two data sets
	4. one-to-one merging of two data sets
	5. many-to-one merging of two data sets
		a. standard example
		b. first statistical-summaries example
		c. (not a merge) second statistical-summary example
		d. (aside) multiple SET statements
	6. merge examples--joins (SQL terminology):
		a. outer join
		b. left join
		c. right join
		d. inner join
	7. merge examples--output options
		a. one, two, three, ... data sets
	8. many-to-many merging of two data sets
	9. (Not done here: updating a master data set with transactions. All yours.)
  10. (Can use in combining too, but not done in
		 these examples) detecting and using 
		 the first and last records of a BY group.
*/
/* Use the LSB 6.5 shoe example as the basis, with a number
   of extensions */

/* Read in two data sets on shoes. They contain
	similar content, but were entered at two
	different points in time.

	Note: the first data set is from LSB's book.
	The second one was created for these exercises. */
DATA regular1;
   INFILE "&dirdata.Shoe.dat";
   INPUT Style $ 1-15 ExerciseType $ RegularPrice;
RUN;

title;proc print;run;

/************** Note **************
 In these examples, I will use a *very excessive*
 number of PROC prints to let you keep seeing what
 is in the many data sets we will be looking at.

 In practice, this would rarely be done. If it were
 done at all with most real data (large data sets), 
 it would only be done on occasion, and probably
 just for the first few records.
 ************** Note **************/

DATA regular2;
   INFILE "&dirdata.Shoe_More.dat";
   INPUT Style $ 1-15 ExerciseType $ RegularPrice;
RUN;
proc print;run;
/* Structure: "data outfile; set infile1 infile2;run;" */
data regularB;
	set regular1 regular2;
	run;
/* First, let's read in this new file*/
DATA regular2P;
   INFILE "&dirdata.Shoe_More_andYear.dat";
   INPUT Style $ 1-15 ExerciseType $ RegularPrice FirstYear;
RUN;
title;proc print;run;

data regularBP;
	set regular1 regular2P;
run;
proc print;run;

DATA regular2Y;
   INFILE "&dirdata.Shoe_More_YearOnly.dat";
   INPUT FirstYear;
RUN;
proc print;run;
proc print data=regular2;run; * if reminder is needed;


DATA regular2P_ver2;
	merge regular2 regular2Y;
run;
proc print;run;

* a check;
proc compare base=regular2P compare=regular2P_ver2;run;

******************************************************************;
proc print data=regular1;run; * to help you remember...;

/* Suppose the store wanted to give (possibly) different discounts
	to each of these styles. Here is the DATA step to read those in */

DATA disc_style;
   INFILE "&dirdata.Disc_Style.dat";
   INPUT Style $ 1-15 Discount;
RUN;
proc print;run;

proc sort data = regular1;
   by Style;
run;

proc sort data = disc_style;
   by Style;
run;

/* First: example of simple merge--no other code added */
data discounted_style;
	merge regular1 disc_style;
	by style;
run;
proc print;run;

/* actual (useful) merge */

data discounted_style;
	merge regular1 disc_style;
	by style;
	if discount=. then discount=0;
	DiscountPrice=round(RegularPrice*(1-discount),.01);
run;
proc print;run;
***********************************************;
/*	5. many-to-one merging of two data sets
		a. standard example */

		
/* Next, let's consider a different discount scenario.
	To make it simpler to advertise, the store has decided
	to set the discount by Exercise Type (running, walking, ...) instead.
	Here is the file with the discounting they plan to do.
	They want to apply this discounting to the larger
	data set of shoes.*/

data disc_exertype;
   infile "&dirdata.Disc_ExerType.dat";
   input ExerciseType $ Discount;
run;
proc print;run;

* larger data set: ;
proc print data=regularB;run; * if you want a reminder;

proc print data=regularB;run; * if you want a reminder;

/* Question:
	1. What do think will happen when we do a merge here with regularB? 
		(Can you "see" what the merged file will look like?) */


/************ Stop 6a ************/






proc sort data = regularB;
   by ExerciseType;
run;

proc sort data = disc_exertype;
   by ExerciseType;
run;

/* example of simple merge: no other code added */
data discounted_exertype;
	merge regularB disc_exertype;
	by ExerciseType;
run;
proc print;run;


/* actual (useful) merge */

data discounted_exertype;
	merge regularB disc_exertype;
	by ExerciseType;
	if discount=. then discount=0;
	DiscountPrice=round(RegularPrice*(1-discount),.01);
run;
proc print;run;
****************************************;
/*	5. many-to-one merging of two data sets
		b. first statistical-summaries example */

/* (LSB 6.6 example, with some modifications) */

/* The district manager has supplied you with the N of different shoes
	sold in the last quarter, and wants you to produce a report showing,
	for each exercise type, those N's and their percent sold within exercise type */

/* Note: Be sure you understand the question, and be 
	sure you could figure this out "by hand". The computer only
	does it faster--including the wrong answer if you don't
	understand the question! */


/************ Stop 6a ************/







	

* 1. Read in sales data;
DATA shoesales;
   INFILE "&dirdata.Shoesales.dat";
   INPUT Style $ 1-15 ExerciseType $ Sales;
RUN;
PROC SORT DATA = shoesales;
   BY ExerciseType;
RUN;
proc print;run;

* 2. Summarize sales (sums) by ExerciseType (needed to get %'s within ExerciseType;
PROC MEANS NOPRINT DATA = shoesales;
   VAR Sales;
   BY ExerciseType;
   OUTPUT OUT = summarydata SUM(Sales) = Total;
RUN;

TITLE 'Summary Data Set';
PROC PRINT DATA = summarydata;
RUN;
title;

DATA shoesummary1;
   MERGE shoesales summarydata;
	drop _type_ _freq_;
   BY ExerciseType;
   Percent = Sales / Total;
   format percent percent6.;
RUN;

TITLE 'Sales Share by Type of Exercise';
PROC PRINT DATA = shoesummary1;
   BY ExerciseType;
   sumby ExerciseType;
   ID ExerciseType;
   VAR Style Sales Percent;
RUN;
title;
****************************************************;
* 1. Get grand total of sales, output to a data set;

PROC MEANS NOPRINT DATA = shoesales;
   VAR Sales;
   OUTPUT OUT = summarydata SUM(Sales) = GrandTotal;
RUN;

TITLE 'Summary Data Set';
PROC PRINT DATA = summarydata;
RUN;
title;
* 2. Combine the grand total with the original data,
	 then get percents.;
/* Please note how this is done, and how it is different from
     what we had done earlier. */
proc print data=shoesales;run; * reminder, if needed;

DATA shoesummary2;
   IF _N_ = 1 THEN SET summarydata;
	drop _type_ _freq_ grandtotal;
   SET shoesales;
   Percent = Sales / GrandTotal;
   format percent percent6.;
RUN;

proc print;run;
/* Look: This is the first time we have used multiple SET statements
	in a DATA step. */

* See why I dropped those three vars?;
	
TITLE 'Overall Sales Share';
PROC PRINT DATA = shoesummary2;
	ID Style;
	sum sales percent;
	VAR Style ExerciseType Sales Percent;
RUN;
title;
*******************************************************************;
/* Another example */
		
/* For this next exercise, let's read in a new 
	data set of exercise-type discounts */

data disc_exertypeP;
   infile "&dirdata.Disc_ExerTypeP.dat";
   input ExerciseType $ Discount;
run;

proc sort data = disc_exertypeP;
   by ExerciseType;
run;
proc print;run;

/* Question:
	1. What do think will happen when we do a merge here with regularB? 
		(Can you "see" what the merged file will look like?) */
proc sort data = regularB;
   by ExerciseType;
run;
proc print data=regularB;run; * if you want to see this one too;
/* example of simple merge: no other code added */
data discounted_exertype;
	merge regularB disc_exertypeP;
	by ExerciseType;
run;
proc print;run;


/* a second merge (similar code to what we did earlier) */

data discounted_exertypeP;
	merge regularB disc_exertypeP;
	by ExerciseType;
	if discount=. then discount=0;
	DiscountPrice=round(RegularPrice*(1-discount),.01);
run;
proc print;run;
*************************************;
data discounted_exertypeP;
	merge regularB (IN=in1) disc_exertypeP (IN=in2);
	by ExerciseType;
	if not in1 then delete;
	if discount=. then do;
		if in2 then discount=.25; 
		else discount=0;
	end;
	DiscountPrice=round(RegularPrice*(1-discount),.01);
run;
proc print;run;

data discounted_exertypeP_inInfo;
	merge regularB (IN=in1) disc_exertypeP (IN=in2);
	by ExerciseType;
	myIn1=in1;
	myIn2=in2;
run;
proc print;run;
data outer;
	merge regularB (IN=in1) disc_exertypeP (IN=in2);
	if in1 or in2;
		* this subsetting IF statement would work, but 
		  it's not needed here. (Why?);
	by ExerciseType;
run;
title 'Outer Join';proc print;run;
data left;
	merge regularB (IN=in1) disc_exertypeP (IN=in2);
	if in1;
	by ExerciseType;
run;
title 'Left Join';proc print;run;

data inner;
	merge regularB (IN=in1) disc_exertypeP (IN=in2);
	if in1 and in2;
	by ExerciseType;
run;
title 'Inner Join';proc print;run;title;

/* The district manager, who seems to be making lots of requests :-),
	wants;
	a. a report of exercise types that appear in the discount file,
		including the "missing values" (later said to be 25%) types, but
		for which there are no such shoes in your regularB file.
		For this file only, change the var name "discount" to
		"potentialDiscount".  (This would be the "soccer" record
		*for this data set*, but you need to write the code 
		more generally, of course.)
	b. a report of exercise types that do not appear in the discount
		file, but for which there are shoes in your regularB file.
		For this report, do not include discount information.
	c. a report that include all other records (the ones that truly
		merged), along with actual discounts.		*/
		data  shoesOnly 
			(drop=discount DiscountPrice)
		discountsOnly 
			(keep=ExerciseType discount rename=(discount=potentialDiscount))
		shoesAndDiscount;
	merge regularB (IN=in1) disc_exertypeP (IN=in2);
	by ExerciseType;
	if discount=. then discount=.25; 
	DiscountPrice=round(RegularPrice*(1-discount),.01);
	If in1 and not in2 then output shoesOnly;
		else if in2 and not in1 then output discountsOnly;
		else output shoesAndDiscount;
run;

title 'shoesOnly';proc print data=shoesOnly;run;
title 'discountsOnly';proc print data=discountsOnly;run;
title 'shoesAndDiscount';proc print data=shoesAndDiscount;run;
title;
*********************************;
	
/* Create a new discount file for exercise type to change
	this file from a "one" to a "many" */
proc print data=disc_exertype;run;
data disc_exertype2R;
	set disc_exertype;
	output;
	if ExerciseType="walking" then do; discount=.50;output;end;
run; * so 2 "walking" records;
proc sort data = disc_exertype2R;
   by ExerciseType;
run;
proc print; run; * again, 2 "walking" records;

proc sort data = regular1;
   by ExerciseType;
run;
proc print; run; * so 3 "walking" records;

	
/* Question: what do you think will happen
 	when the "walking" records are merged? */
*******************************************************;
/* Read in sales481.sas7bda. A sas data file*/

* make a WORK copy of sales481, i.e. work.sales481;
data sales481;
	set "&dirdata.sales481.sas7bdat";
run;

proc print data=sales481;run;

/* Note that there are 7 Store/Dept combinations,
	for each of 4 quarter */

/* For each quarter, the VP of sales is interested
	in seeing whether the Pareto principle is in
	effect for these 7 combinations */


/* Questions:
	1. What does the Pareto principle 
		predict would happen here, approximately?
		(If you don't what this principle is,
		find out.)
	2. How could we create a new variable in
		the data that would show whether
		this principle holds?


/* The Pareto principle is the 80-20 rule. To
	see if this holds here:
	a. sort the data "BY quarter descending sales"
	b. find the total sales "BY quarter" and merge
		that into the data set.
	c.	then, for each quarter, accumulate the total
		sales and, using total sales for the quarter,
		calculate percents.
	d. For each quarter, see if the accumulation 
		after 2 combinations is over 80% */

/* At this point in the course, you should be able to do
	all the steps except for (c.)--that is the step
	where we will use some new ideas */

		
		
/* a. sort the data "BY quarter descending sales" */

proc sort data=sales481;
	by quarter descending sales;
run;
proc print data=sales481;run;
/*	b. find the total sales "BY quarter" and merge
		that into the data set. */

proc means noprint data=sales481;
	by quarter; 
	var sales;
	output out=qsales481 (drop=_type_ _freq_) sum=QTotal;
run;
proc print data=qsales481;run;
/* note use of DROP= SAS data set option */

/* We are about to use FIRST. and LAST. variables.
	What are these?? 
	1. When you have a "BY X" statement in a SAS
		data set, SAS automatically generates
		two temporary variables:
		a. FIRST.X, which is equal to 1 
			for a record in which the value of X
			has just changed, and is 0 o/w.
		b. LAST.X, which is equal to 1 
			for a record that contain the last value of X
			just before it changes, and is 0 o/w.
	2. Similarly, if you have "BY X Y" SAS will 
		also generate FIRST.Y and LAST.Y
*/

* Here is an example of first. and last.;
data temp;
	set sales481;
	by quarter;
	firstQ=first.quarter;
	lastQ=last.quarter;
run;
proc print;run;
* Now, back to the task at hand;



/*	c.	then, for each quarter, accumulate the total
		sales and, using total sales for the quarter,
		calculate percents. */

data sales481B;
	merge sales481 qsales481;
	by quarter;
	retain QCumSales;
	if first.quarter then QCumSales=0;
	QCumSales + sales;
		* remember: this is the same as QCumSales=QCumSales + sales
			after a retain QCumSales 0 type statement...
			(this is an "old school" SAS statement, I'd say, but you
			should still know it.);
	QCumPct = QCumSales/QTotal;
	format QCumPct percent6.;
	/*
	* Example of using last. -- not really needed here;
	if last.quarter then do;
		* reality check;
		if abs(QCumSales - QTotal) > .01 then do;
			put 'Error: ' QCumSales= QTotal=;
			stop; * halts DATA step;
		end;
	end;
	*/
run;
proc print data=sales481B;run;

/* Note use of STOP statement to halt 
	execution of DATA step */


/*	d. For each quarter, see if the accumulation 
		after 2 combinations is over 80% */
	
/* Here, we will just look at the full SAS data set... */	

title 'Quarterly Sales Pareto check';
proc print data=sales481B;run;
title;
