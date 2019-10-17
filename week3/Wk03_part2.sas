%let dirdata=/folders/myfolders/; * possible SAS Studio access--
* Use one of these, or create a new one as needed;
%let dirOUT=/folders/myfolders/;
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

options nocenter; * to left-align the output;

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

/*	1. stacking two (or more, here and below) data sets
		a. Same variables in both */

/* We now want to combine (concatenate) these */

/* How do you think we might do this in SAS? */



/************ Stop 1 ************/






























/* Structure: "data outfile; set infile1 infile2;run;" */
data regularB;
	set regular1 regular2;
run;
proc print;run;



/*	1. stacking two (or more, here and below) data sets
		b. Not same variables in both */
		
/* Now suppose that instead of Shoe_More.dat file, we 
	instead had that info + initial sales year in a file: */

DATA regular2P;
   INFILE "&dirdata.Shoe_More_andYear.dat";
   INPUT Style $ 1-15 ExerciseType $ RegularPrice FirstYear;
RUN;
title;proc print;run;


/* We want to stack (concatenate) these:
	regular1 and regular2P */

/* What do you think the o/p data set will look like?
	a. error generated?
	b. missing FirstYear for regular1?
 */



/************ Stop 2 ************/











data regularBP;
	set regular1 regular2P;
run;
proc print;run;



/* Now suppose that instead of Shoe_More_andYear.dat
	(see regular2P data set), we had two text files:
	a. Shoe_More.dat (from before: see regular2)
	b. Shoe_More_YearOnly.dat that contains only the 
		Year info */
		
/* First, let's read in this new file*/
DATA regular2Y;
   INFILE "&dirdata.Shoe_More_YearOnly.dat";
   INPUT FirstYear;
RUN;
proc print;run;
proc print data=regular2;run; * if reminder is needed;


/*
	3. parallel merging of two data sets */
	
/* We now want to add Year (in regular2Y) to
	the other variables (in regular2).
	
	How do you think we might do this in SAS? */



/************ Stop 3 ************/































DATA regular2P_ver2;
	merge regular2 regular2Y;
run;
proc print;run;

* a check;
proc compare base=regular2P compare=regular2P_ver2;run;


/* Do you think this type of merge is a good idea 
	in practice? Be able to defend your answer. */


/************ Stop 4 ************/







/*	4. one-to-one merging of two data sets */

	
/* Consider regular1 again: */

proc print data=regular1;run; * to help you remember...;

/* Suppose the store wanted to give (possibly) different discounts
	to each of these styles. Here is the DATA step to read those in */

DATA disc_style;
   INFILE "&dirdata.Disc_Style.dat";
   INPUT Style $ 1-15 Discount;
RUN;
proc print;run;


/* Questions:
	1. What do we want to do with the two data sets regular1 and Disc_Style?
		That is, what needs to be done if you were doing this "by hand"?
	2. Do you see any issues if you were doing this "by hand"?
	3. SAS question: what might we need to do first with the 
		two individual SAS data sets before we tried to combine them? */


/************ Stop 5 ************/

































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

* So, what happens when there is no match?;




/* actual (useful) merge */

data discounted_style;
	merge regular1 disc_style;
	by style;
	if discount=. then discount=0;
	DiscountPrice=round(RegularPrice*(1-discount),.01);
run;
proc print;run;


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

* 3. Merge totals with the original data set;
/* Note: this is simply another many-to-one merge. However, 
	in this merge, the "one" file is based on summary measures
	from the "many" file. (Compare to earlier many-to-one merge) */
	
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


/************ Stop 7 ************/








/*	5. many-to-one merging of two data sets
		c. (not a merge) second statistical-summary example */


/* (LSB 6.7 example, with some modifications) */

/* Similar problem to before, but now
	a. with "style" instead of "exercise type";
	b. percent of *total*, not percent within style 
		(which also would not make sense: only one record/style) */
	
/*The district manager has supplied you with the N of different shoes
	sold in the last quarter, and wants to you produce a report showing,
	for each style, those N's and their percent sold *among all styles* */

/* Question:
	1. What makes the SAS approach to the problem different from
		the last problem? */


/************ Stop 8 ************/













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

/* Contrast this report to one in TLSB 6.7. Which looks better?
	It's good to give some thought to how to present your work. */


/* Question:
	1. Why didn't we have to use a 
			RETAIN GrandTotal;
		statement in the DATA step above? 
		Don't all var's get initialized to missing for each 
		loop of the DATA step? */


/************ Stop 9 ************/





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


/************ Stop 10 ************/








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

/* Question:
	1. The district manager has just told you that if an exercise type
		*does not appear* in the discount file, then the discount
		should be 0. However, any exercise type that *does appear 
		with a missing value* in the discount file meant that they
		hadn't decided on it when they sent you the file, but they
		have since decided that those exercise types will get a
		25% discount.

		Does the code above handle this correctly? Can you write
		code to fix this?

	2.	The other problem is the the "soccer" line should
		probably not be on the o/p data set. Ideas on how
		to fix this?   */


/************ Stop 11 ************/












/* We can solve the first problem as noted in the solutions below.
	However, we can instead use the DATA step below to explicitly 
	distinguish between the two ExerciseType=. cases
	(1. set to . when read in, or 2. created as . in the merge)
	by using the IN=  SAS data set option */

/* In addition we can use the IN= SAS data set option
	to eliminate the "soccer" line, and do so
	with clear coding: */
	
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

/* Here "(IN=in2)" creates a *temporary* SAS variable in2.
	If a record exists for a value of ExerciseType (the BY var) in 
	disc_exertype then in2=1; otherwise in2=0. We can say 
	"if in2" instead of "if in2=1" and "if NOT in2" instead of 
	"if in2=0". Of course, the same idea applies to in1. */

/* To get the idea of IN more clearly, perhaps it would be useful
   to show their values for each record. I do this here by creating
   SAS variables that are not temporary, and output all records. */

data discounted_exertypeP_inInfo;
	merge regularB (IN=in1) disc_exertypeP (IN=in2);
	by ExerciseType;
	myIn1=in1;
	myIn2=in2;
run;
proc print;run;

/* See how these values of 0 and 1 correspond to whether the  corresponding
   input SAS data set makes a contribution? */
	
/* Note that we could also get rid of the "soccer" line *for this
	data set* by using "IF regularprice=. then delete;". However
	this has the same problem we just encountered for "discount":
	this line of code does not distinguish between "not IN1" 
	and simply a missing value in the original data file */


/* Questions? */


/************ Stop 12 ************/












/* simple merges (no extra code shown) */

data outer;
	merge regularB (IN=in1) disc_exertypeP (IN=in2);
	* if in1 or in2;
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

/* Question: think about when each might be useful for this problem,
	or for other types of problems */

	
/************ Stop 14 ************/





/*	7. merge examples--output options
		a. one, two, three, ... data sets */

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
		

/* Once again, we use our friend, the IN= SAS data set option */
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

/* Notes:
	1. Multiple output data sets; (First time we have seen this)
	2. Use of IN= SAS data option on both input data sets now;
	3. Use of DROP=, KEEP=, and RENAME= SAS data set options on some output data sets.
		(First time we have seen these.)
		* Note the use of ()'s with these options.
		* You may also want to see the PROC prints without these options. */

/* Questions? */

	
/************ Stop 15 ************/






/*	8. many-to-many merging of two data sets */


/* I believe that many-to-many merging is often (always? Not sure) an
	unintentional result, based on problem data. That is,
	there should not be many-to-many merging in "good" data sets.
	But let's see what happens when this occurs. */
	
	
/* Create a new discount file for exercise type to change
	this file from a "one" to a "many" */
	
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


/************ Stop 15 ************/









/* example of a many-to-many merge */
data discounted_exertype2R;
	merge regular1 disc_exertype2R;
	by ExerciseType;
run;

/* See what prints on the SAS log about this? 
	Always read the SAS log! */

title 'Example of many-to-many merge';
proc print;run;
title;


/* If you had to guess from this small example, it
	seems that:
	1. SAS does a parallel merge for the "walking"
		records as long as both SAS data sets are
		contributing.
	2. After that, the longer-contributing data
		set gets the last value(s) from the other
		data set */


/* Question: is this what you guessed?
	If you were the programmer, would you do things
	differently ? */


/************ Stop 16 ************/







/*   10. (Can use in combining too, but not done in
		 these examples) detecting and using 
		 the first and last records of a BY group. */

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


/************ Stop 17 ************/



























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

/*	b. find the total sales "BY quarter" and merge
		that into the data set. */

proc means noprint data=sales481;
	by quarter; 
	var sales;
	output out=qsales481 (drop=_type_ _freq_) sum=QTotal;
run;

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
	* Example of using last. -- not really needed here;
	if last.quarter then do;
		* reality check;
		if abs(QCumSales - QTotal) > .01 then do;
			put 'Error: ' QCumSales= QTotal=;
			stop; * halts DATA step;
		end;
	end;
run;


/* Note use of STOP statement to halt 
	execution of DATA step */


/*	d. For each quarter, see if the accumulation 
		after 2 combinations is over 80% */
	
/* Here, we will just look at the full SAS data set... */	

title 'Quarterly Sales Pareto check';
proc print data=sales481B;run;
title;

/* Question: does the Pareto principle 
	seem to hold? */


/************ Stop 18 ************/





/* Finally, we will us a technique to write the SAS data set
	sales481 into a format that can be read into R. 
	(There are various ways to do this, including writing, and
	then reading, a csv file. No one option seems "best".) */

/***** Note to SAS Web Editor Users (if there are any):
	This does not appear to create a SAS xport file in
	the SAS Web Editor. However, that is OK. The SAS
	xport file will be available to you on myCourses
	(and in Labshare for local students) *****/
	
/***** Note to SAS Studio Users:
	This should work. However, the SAS
	xport file this creates will be available to you 
	on myCourses and in Labshare  *****/

/***** Note to local SAS users:
	This should work. However, the SAS
	xport file this creates will be available to you 
	on myCourses and in Labshare  *****/
	
	
	
/* First, we use a libname statement */

libname for_R xport "&dirOUT.sales481.xpt";

/* Notes:
	1. We are using the option "xport" on the libname statement.
	2. We are also referencing a file name here
	(&dirdata.sales481.xpt) instead of a directory
	name (e.g. &dirdata) as we have done for "regular"
	libname statements. */

/* Second, create a SAS xport file. This is a binary (text-unreadable)
	file that has SAS-data-set information stored in it in a way 
	that some other packages, including R, can read in. */

data for_R.sales481 ; 
	* Here, sales481 is the name of the SAS data set that is stored inside
		the sales481.xpt file. If I used "data for_R.mysales",
		then mysales would be the name of the SAS data set stored
		inside the sales481.xpt file. However, it seems to make sense
		to give the SAS data set and the xport file the same name ...;
	set sales481;
run;

/* We have now created a file named sales481.xpt in the &dirdata
	directory that contains the sales481 SAS-data-set information.
	We will later read this file in R to construct a data frame. */






/* Answers to some questions */

/* Question, Stop 4: Do you think this type of merge is a good idea 
	in practice? Be able to defend your answer.
This is *not* a good idea in practice. There is no check for whether
we are really merging the correct records with each other. (What
additional information would you want in the YearOnly file
to ensure that the merge was done correctly?
*/



/* Questions, Stop 5:
	1. What do we want to do with the two data sets regular1 and Disc_Style?
		That is, what needs to be done if you were doing this "by hand"?
	We want to combine, or *merge* them, and then figure out the new prices.
	2. Do you see any issues if you were doing this "by hand"?
	Two of the styles have no discount information
	3. SAS question: what might we need to do first with the 
		two individual SAS data sets?
	Just like for PROCs, we will probably need to sort the data set first */
/* Question, Stop 8:
	1. What makes the SAS approach to the problem different from
		the last problem? 
	In the last problem (summaries by exercise type), we joined the
	original data with the summary data with a "merge ...; by ExerciseType;"
	Here, we have nothing to merge by. (We could add an artificial variable
	say JUNK, that has constant value, say "all" across all the records, 
	and then do PROC MEANS by JUNK, and MERGE by JUNK, but "fooling SAS"
	is really not recommended here */
/* Question, Stop 9:
	1. Why didn't have to use a 
			RETAIN GrandTotal;
		statement in the DATA step above? 
		Don't all var's get initialize to missing for each 
		loop of the DATA step?
	See TLSB, 6.7 */
/* Question, Stop 11:
	1. The district manager has told you that if an exercise type
		does not appear in the discount file, then the discount
		should be 0. However, any exercise that type does appear 
		in the discount file with a missing value meant that they
		hadn't decided on it when they sent you the file, but they
		have since decided that those exercise types will get a
		25% discount.

		Does the code above handle this correctly? Can you write
		code to fix this?
	The code does not work--it gives a 0% discount to running
	type instead of 25%
	
	One way to fix this would be to include a 
	"IF Discount=. THEN Discount=0.25;" statement when reading 
	in the discount data. 

	However, we will see a different way to do this in code. Which
	one is "better" in a real problem may depend on other considerations;
	and sometimes only one of these ways is even feasible. 
	
	2.	The other problem is the the "soccer" line should
		probably not be on the o/p data set. Ideas on how
		to fix this?

	A solution is given in the code after this question */

/* Questions, stop 16:
	1. What does the Pareto principle 
		predict would happen here, approximately?
		(If you don't what this principle is,
		find out.)
	It would say that about 80% of sales are
	done by about 20% of the 7 combinations. If
	so, we should see that 80% of sales are reached
	by the first 2 (29%) largest-contributing
	combinations.
	2. How could we create a new variable in
		the data that would show whether
		this principle holds?
	We could 
	a. sort the data "BY quarter descending sales"
	b. find the total sales "BY quarter" and merge
		that into the data set.
	c.	then, for each quarter, accumulate the total
		sales and, using total sales for the quarter,
		calculate percents.
	d. For each quarter, see if the accumulation 
		after 2 combinations is over 80% */
