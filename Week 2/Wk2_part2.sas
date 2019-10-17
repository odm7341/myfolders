/* This week's main topics:
	1. More on Arrays
	2. Sorting, Printing, and Summarizing Your Data */


/* Use one of these, or create a new one as needed;*/
%let dirdata=/folders/myfolders/; * possible SAS Studio access--
                                    see FirstSasStudioSession.doc for details;

/* More on Arrays
	(more deeply than in Sec 3.11 of TLSB5) */

/* A SAS array: a group of related variables that are already defined in a DATA step. */
/* Note: the meaning of "array" in SAS is different from the 
		meaning of "array" in R (and in most other computer languages)*/

/* The use of arrays may allow us to simplify our SAS processing. 
	We can use arrays to help read and analyze repetitive data with 
	a minimum of coding. An array and a loop can make the program smaller
	and easier to read. */

/* The following examples are from Arrays_AdventuresIn_Tutorial_2007.pdf */

/* Example 1: you first read in a SAS data set of 6 kinds of 
  offseason rates at 11 hotels */
data expenses;
	infile "&dirdata.expensesArray.csv" dlm="," DSD firstobs=2;
	length ResortName $26 Resort $8;
	input ResortName Resort OffSeason1-OffSeason6;
		* (Please recall what the "-" means in this line);
run;

proc print; run;

/* You want to find the seasonal rates, which are 25% greater 
   than the offseason rates */
/* The first solution requires a lot of typing */
data SeasonalRates1;
	set expenses;
	Seasonal1 = OffSeason1*1.25;
	Seasonal2 = OffSeason2*1.25;
	Seasonal3 = OffSeason3*1.25;
	Seasonal4 = OffSeason4*1.25;
	Seasonal5 = OffSeason5*1.25;
	Seasonal6 = OffSeason6*1.25;
	format OffSeason1 - OffSeason6 seasonal1 - seasonal6 dollar9.2;
run;

/* To solve this problem using an array, you must first establish the correspondence between
	1. one array name and the existing variables, OffSeason1 - OffSeason6
	2. a second array name and the new variables, Seasonal1 - Seasonal6. 
	You then use a DO loop to iterate through the arrays.
*/

data work.SeasonalRates2;
	set expenses;
	drop i; * This variable is used in the do loop, but is not wanted in the SAS data set;
	array offseason{6} Offseason1 - Offseason6;
	array seasonal{6} Seasonal1 - Seasonal6;
	do i=1 to 6;
		seasonal{i} = offseason{i}*1.25;
	end;
	format OffSeason1 - OffSeason6 seasonal1 - seasonal6 dollar9.2;
run;

proc print;run;

proc compare base=SeasonalRates1 compare=SeasonalRates2;run;
/******* Stop 1 ************/

/* Questions? */


/* This next DATA step shows that:
   1. you can use a shorter way of writing the names if they have the form X1-Xn
   2. you can use a * and the DIM function instead of the actual N of varnames 
*/

data work.SeasonalRates3;
	set expenses;
	drop i;
	array Offseason{6}; * associates this with the vars Offseason1 - Offseason6;
	array seasonal{*} Seasonal1 - Seasonal6; * The "*" does implicit numbering;
	do i=1 to dim(seasonal); * use of dim function;
		seasonal{i} = offseason{i}*1.25;
	end;
	format OffSeason1 - OffSeason6 seasonal1 - seasonal6 dollar9.2;
run;

proc compare base=SeasonalRates1 compare=SeasonalRates3;run;


/* The array method, compared to the "a lot of typing method",
    1. Is just as easy with 600 offseason rates as 6. 
		This is *much* better than writing almost the same line of
		code 6 times--or 600!
	2. Is less error-prone.
	3. Is easier to read.
	4. Also, writing 6 (or 600) lines of code says "I am a hack at programming".
		This is *not* an impression you want to leave!
*/


/* Do you think the seasonal rates are really exactly correct ? */

/* For the DATA step that produced SeasonalRates3,
   would an error be generated in the last DATA step if we used
	"array seasonal{*} Seasonal1 - Seasonal5;" instead of 
	"array seasonal{*} Seasonal1 - Seasonal6;" ?
*/


/******* Stop 1a ************/





/* Example 2: First read in a SAS data set of offseason rates */
/* This is the same data set as before, but now the offseason rates 
	(on line 1 of the file) are named more clearly */

data expenses_Plus;
	infile "&dirdata.expensesArray_Plus.csv" dlm="," DSD firstobs=2;
	length ResortName $26 Resort $8;
	input ResortName Resort RoomRate DailyFood SpaVisits RoundOfGolf HorseBackRiding ParkAdmission;
run;

proc print;run;

/* This data set contains the actual rates */

/* You have budgeted the following amounts for each of the daily expenses: 
		$175 for expense1 (room), $75 for expense2 (food), 
		$25 for expense3 (spa treatments), $35 for expense4 (a round of golf), 
		$25 for expense5 (horseback riding), and $30 for expense6 (theme park admission). 
   You want to use an array to assign these budget amounts as *initial values*
   and to determine the difference between the budgeted amounts and the actual rates.*/

/* One way to do this (a table lookup, really) is to use a combination of:
	1. The special SAS name _temporary_, which creates temporary variables to use in an array
       (This is useful only if you do not want these (temporary) variables to be written
        to the SAS data set. And we do not want to do that here.)
	2. Setting the (initial) values of variables */

data diffs;
	drop i;
	set expenses_Plus;
	array budget{6} _temporary_ (175,75,25,35,25,30);
	array expense{*} RoomRate DailyFood SpaVisits RoundOfGolf HorseBackRiding ParkAdmission;
	* or array expense{*} RoomRate--ParkAdmission;
	array Difference{6};
	do i=1 to dim(expense);
		Difference{i} = budget{i} - expense{i};
	end;
run;

proc print;run;

/* How would you change the code if you wanted to keep 
     the budgeted amounts as variables in the SAS data set?
   Suppose you wanted to put "Diff" in front of the expense variable 
     names to create Difference names. So instead of Difference1-Difference6,
     you want DiffRoomRate DiffDailyFood ... DiffParkAdmission. Is
     there a way you could write code to do this in SAS?
     (Think about it--answers given near the end of this file.) */


/******* Stop 2 ************/






/* Chapter 4 */
/* Sorting, Printing, and Summarizing Your Data */

/* Here, we will study the following:
 	1. WHERE statements to create "on the fly" subsets
 	2. PROC SORT, to sort data sets in various ways
 	3. PROC PRINT--again.
	4. FILE and PUT statements and _NULL_ to write info in a SAS data set 
 		to a text file (or to the SAS log).
 	5. PROC FORMAT--a way to *create* formats instead of just using the
 		built-in formats in SAS (e.g., DOLLAR7. or MMDDYY.)
 	6. PROC MEANS, to summarize data
 	7. PROC FREQ, for frequency tables
 	8. PROC TABULATE, which can create fairly complex tables
 	9. Using PROC FORMAT to put data into groups
 */


/* Section 4.2 */
/* WHERE statement */

/* create the initial data set */
DATA style;
   INFILE "&dirdata.Artists.dat";
   INPUT Name $ 1-21 Genre $ 23-40 Origin $ 42;
RUN;
PROC PRINT;RUN;

/* Select only Impressionism for PROC PRINT */
PROC PRINT DATA = style;
   WHERE Genre = 'Impressionism';
   TITLE 'Major Impressionist Painters';
   FOOTNOTE 'F = France N = Netherlands U = US';
RUN;
TITLE; /* this eliminates the TITLE and FOOTNOTE. Useful if you don't want them to persist */
FOOTNOTE;

/* How would you select either post-impressionist or US painters? */

/* How might you only print impressionist painters 
	if the WHERE statement did not exist? */


/********** Stop 3a ************/




/* Section 4.3 */
/* Sorting SAS data sets */

DATA marine;
   INFILE "&dirdata.Lengths.dat";
   INPUT Name $ Family $ Length @@;
RUN;

TITLE 'Whales and Sharks';
FOOTNOTE;
PROC PRINT;
RUN;

* Sort, then print, the data;
PROC SORT DATA = marine OUT = seasort NODUPKEY;
   BY Family DESCENDING Length;
RUN;

TITLE 'Whales and Sharks, sorted';
PROC PRINT DATA = seasort;
RUN;


/* The BY statement in PROC SORT sorts the data
	into *BY groups* 
		Here there is only one observation per BY group because
   of the NODUPKEY (NO DUPlicate KEYs) option, where *key* refers
   to the variables that we sort on.
		How many are in the BY groups without this option
	and using only "BY Family;" for sorting? */

/* Would you normally use the NODUPKEY option?
	When might you want to use it? 
   (I don't believe I've ever used it in practice.) */

/* What happens if you don't use the OUT= option? */


/********** Stop 3b ************/




/* Section 4.4 */
/* More sorting options*/

/* The ASCII sort order: blank, numerals, uppercase letters, lowercase letters
	 	Here are two ways to modify these */

DATA addresses;
   INFILE "&dirdata.Mail.dat";
   INPUT Name $6. Street $18. City $9. State $6.;
RUN;

TITLE 'Addresses, not Sorted';
PROC PRINT;
RUN;

PROC SORT DATA = addresses OUT = sortone 
      SORTSEQ = LINGUISTIC (NUMERIC_COLLATION = ON);
   BY Street;
RUN;

PROC PRINT DATA = sortone;
   TITLE 'Addresses Sorted by Street';
RUN;

PROC SORT DATA = addresses OUT = sorttwo 
      SORTSEQ = LINGUISTIC (STRENGTH = PRIMARY);
   BY State;
RUN;

PROC PRINT DATA = sorttwo;
   TITLE 'Addresses Sorted by State';
RUN;

/* Does the o/p of the last PROC PRINT seem OK?
   What if you did the sort BY STATE NAME instead? */



/********** Stop 4 ************/






/* Section 4.5 */
/* Some notes on PROC PRINT */

DATA sales;    
   INFILE "&dirdata.CandySales.dat"; 
   INPUT Name $ 1-11 Class @15 DateReturned MMDDYY10. CandyType $ Quantity;
   Profit = Quantity * 1.25;
RUN;

PROC SORT DATA = sales;
   BY Class;
RUN;

PROC PRINT DATA = sales;
   BY Class;
   SUM Profit;
   VAR Name DateReturned CandyType Profit;
   TITLE 'Candy Sales for Field Trip by Class';
RUN;


/* The data must be sorted "BY Class" to use "BY Class" in 
		PROC PRINT. (What happens if it isn't?)
	What does the BY statement do here? */

/* What does the SUM statement do? */

/* What variable doesn't look like it was printed very well?
		What are two separate ways to fix this problem? */


/* Section 4.6 */
/* Using formats in PROC PRINT */

PROC PRINT DATA = sales;
   VAR Name DateReturned CandyType Profit;
   FORMAT DateReturned DATE9. Profit DOLLAR6.2;
   TITLE 'Candy Sale Data Using Formats';
RUN;

/* If we plan to use these formats whenever we look
	at the sales data set, do you think there is a 
	better place to format these two variables? */


/********** Stop 5 ************/




/* Section 4.8 */
/* Using PROC FORMAT to create custom formats */

DATA carsurvey;
   INFILE "&dirdata.Cars.dat";
   INPUT Age Sex Income Color $;
RUN;

TITLE 'Survey Results'; 
PROC PRINT;RUN;

PROC FORMAT;
   VALUE gender 1 = 'Male'
                2 = 'Female';
   VALUE agegroup 13 -< 20 = 'Teen'
                  20 -< 65 = 'Adult'
                  65 - HIGH = 'Senior';
   VALUE $col  'W' = 'Moon White'
               'B' = 'Sky Blue'
               'Y' = 'Sunburst Yellow'
               'G' = 'Rain Cloud Gray';
run;

/* See how gender and agegroup are defined as numeric formats
		and col as a character format (includes "$") ? */

* Print data using user-defined and standard (DOLLAR8.) formats;
PROC PRINT DATA = carsurvey;
   FORMAT Sex gender. Age agegroup. Color $col. Income DOLLAR8.;
   TITLE 'Survey Results Printed with User-Defined Formats';
RUN;

/* Note the "." in the *use* of the format, but *not* in its definition
		SAS uses the "." in a word to recognize it as a format */	

/* The ability to format in SAS can make it very easy to produce
      a listing with the "look" you desire. */



/* Section 4.9 */
/* Write a "report" with FILE and PUT statements */

/* First, define a directory to write the report. 
		Use one of these, or create a new one as needed;

* possible SAS Studio access--
                                    see FirstSasStudioSession.doc for details;
*/
%let dirOUT=/folders/myfolders/; 

%put &dirout; * your o/p directory, listed in the log;

DATA _NULL_;
   INFILE "&dirdata.CandySales.dat";
   INPUT Name $ 1-11 Class @15 DateReturned MMDDYY10. CandyType $ Quantity;
   Profit = Quantity * 1.25;
   FILE "&dirOUT.Student.txt" PRINT;
   TITLE;
   PUT @5 'Candy sales report for ' Name 'from classroom ' Class
     // @5 'Congratulations!  You sold ' Quantity 'boxes of candy'
     / @5 'and earned ' Profit DOLLAR6.2 ' for our field trip.';
   PUT _PAGE_;
RUN;


/* _NULL_ --> no SAS data set is created.
	FILE --> write PUT statements to a file (not to the SAS log)
	PRINT --> include additional CR/LF (from "/") and 
         FF ("form feed"--page skips from
         "PUT _PAGE_") in the file. */


/********** Stop 6 ************/




/* Section 4.10 */
/* PROC MEANS to get summary measures */

/* Note: I am using a slightly larger data set than the
	Flowers.dat data in TLSB to make the results a bit clearer */

DATA fsalesP;
   INFILE "&dirdata.Flowers_Plus.dat";
   INPUT CustID $ @9 SaleDate MMDDYY10. Petunia SnapDragon Marigold;
   Month = MONTH(SaleDate);
run;

PROC SORT DATA = fsalesP;
   BY Month; 
RUN;

TITLE;
PROC PRINT;RUN;

* Calculate default summaries by Month for flower sales;
PROC MEANS DATA = fsalesP MAXDEC = 2;
   BY Month;
   VAR Petunia SnapDragon Marigold;
   TITLE 'Summary of Flower Sales by Month';
RUN;

/* Default summaries: N, Mean, sd, Min, Max */
/* Note that this gives nicely formatted, compact output
	(We will compare this to later output) */

/* Note that this is another use of the BY statement--separate 
	summaries for each BY group */

/* NOTE THE PARADIGM HERE:
		1. Read in the data
		2. Do a SORT, BY
		3. Do a PROC, BY (before we did PROC PRINT, BY. Here it is PROC MEANS, BY.)
	YOU WILL SEE THIS OVER AND OVER IN YOUR SAS WORK*/


/* Section 9.3 */
/* Another example of PROC Means */


DATA booklengths;    
   INFILE "&dirdata.Picbooks.dat";
   INPUT NumberOfPages @@;
RUN;
/* Please look at the raw data file. Then please remember what @@ does:
	1. For every loop through the DATA step the INPUT statement will 
		read in only the next value on the line (because only one variable 
      name appears in the INPUT statement).
	2. At the end of each loop, there is an implicit OUTPUT statement,
		so that value gets written to the SAS data set.
	3. At the end of each loop "the line is held". That is, for the next
		loop the next value on that same line will be read (unless there are 
      no values left; in that case, SAS will go to the next line.) */
		
/* Question: what would happen if you used
		INPUT NumberOfPages @;
	instead? How about
		INPUT NumberOfPages;
	Can you figure this out before you test it out? 
	Can you figure this out well enough that you don't need to test it out? */
	


*Produce summary statistics;
PROC MEANS DATA=booklengths N MEAN MEDIAN CLM ALPHA=.10;
   TITLE 'Summary of Picture Book Lengths';
RUN;

/* Here the summaries were specified in the PROC MEANS statement.
	However, no var statement was given, so the default--all numeric vars--
	was used */


/********** Stop 7 ************/

/* Section 4.11 */
/* PROC MEANS, output to a SAS data set
		and with finer control of the summaries */

/* using sales data set from earlier */
PROC SORT DATA = fsalesP;
   BY CustID;
run;

* As a reminder ... ;
title;
proc print;run;

* Calculate means by CustomerID, output sum and mean to new data set;
PROC MEANS NOPRINT DATA = fsalesP;
   BY CustID;
   VAR Petunia SnapDragon Marigold;
   OUTPUT OUT = totals  
      MEAN(Petunia SnapDragon Marigold) = MeanP MeanSD MeanM
      SUM(Petunia SnapDragon Marigold) = Petunia SnapDragon Marigold;
run;

PROC PRINT DATA = totals;
   TITLE 'Sum of Flower Data over Customer ID';
   FORMAT MeanP MeanSD MeanM 3.;
RUN;

/* Note the automatic vars _TYPE_ and _FREQ_
	It will be good to learn what these mean. */

/* Also, please learn the difference between 
	the BY and CLASS statements--see TLSB */


/********** Stop 7a ************/



/* Next (and this is *not* in TLSB) 
	let's revisit our first PROC MEANS example: 
		PROC MEANS DATA = fsalesP MAXDEC = 0;
   		BY Month;
   		VAR Petunia SnapDragon Marigold;
   		TITLE 'Summary of Flower Sales by Month';
		RUN;
	Default summaries: N, Mean, sd, Min, Max
	Note that this give nicely formatted, compact output */

/* Now, let's calculate these again, but store these in a SAS data set*/

/* Note: if we want means of all vars we can just use this shortcut
			MEAN = MeanP MeanSD MeanM
	instead of the
			MEAN(Petunia SnapDragon Marigold) = MeanP MeanSD MeanM
	used earlier */

PROC SORT DATA = fsalesP;
   BY Month;
run;
			
PROC MEANS DATA = fsalesP NOPRINT;
	BY Month;
	VAR Petunia SnapDragon Marigold;
		output out=fsalesPSumm
		n = nP nSD nM
		MEAN = MeanP MeanSD MeanM
		std = stdP stdSD stdM
		min = minP minSD minM
		max = maxP maxSD maxM;
RUN;

/* I hope you understand the value of storing these summaries in a SAS
		data set: they are available for further processing. Very
		important for real-world problems! In fact, almost all of
		my PROC MEANS are "PROC MEANS... NOPRINT; ... ;OUTPUT OUT= ..." */

title 'Long Summary of Flower Sales by Month';
proc print data=fsalesPSumm;run;

/* We have the same summaries as before, but now the printout looks pretty ugly.
	Is there a simple way to rearrange this in SAS back to the 2 3x5
	layouts used in the earlier PROC PRINT (2 months, 3 var's, 5 summary measures).
	I don't think so. We will compare this to R next week. */

/* Also, what happens when you want summaries of 30 variables instead of 3?
	Do we need to type out all the output var names, like we did here? */


/*	Note: if we have lots of vars but only one summary measure we could do
	this (I'll pretend that 3 vars is a lot here--but note that this would
	work just as easily for 3000 vars): */

PROC MEANS DATA = fsalesP NOPRINT;
	BY Month;
	VAR Petunia--Marigold; * *but only* if the vars are sequential ;
		output out=fsalesPMeanSumm (drop=_TYPE_ _FREQ_)
		MEAN =;
RUN;

title 'Quick method to get all means';
proc print data=fsalesPMeanSumm;run;


/********** Stop 7b ************/

/* Section 4.12 */
/* Counting frequencies with PROC FREQ */

DATA orders;
   INFILE "&dirdata.Coffee.dat";
   INPUT Coffee $ Window $ @@; 
	   * Type of coffee ordered, and either drive-in (d) or walk-up (w) window;
RUN;

Title 'Coffee/Window data';
PROC PRINT;run;

* Print tables for Window and Window by Coffee;
TITLE 'Summary of Coffee/Window data';
PROC FREQ DATA = orders;
   TABLES Window  Window * Coffee;
RUN;


* You can use options to reduce the output, for example. See TLSB;


/********** Stop 8 ************/




/* Section 4.13 */
/* PROC TABULATE: simple example.
	Note: PROC TABULATE is *very* powerful--it can create very complex tables.
		It is worth learning how to use this well--but it is not trivial to learn. */

DATA boats;
   INFILE "&dirdata.Boats.dat";
	INPUT Name $ 1-12 Port $ 14-20 Locomotion $ 22-26 Type $ 28-30 
      Price 32-37 Length 39-41;
	* Name, Port, power, type, excursion price, length (ft) of boats;
RUN;

TITLE 'Pleasure Boats';
PROC PRINT;
RUN;

* Tabulations with 3 class var's and 3 dimensions;
PROC TABULATE DATA = boats;
   CLASS Port Locomotion Type;
   TABLE Port, Locomotion, Type;
   TITLE 'Number of Boats by Port, Locomotion, and Type';
RUN;

/* CLASS statement: the list of categorical-data variables, 
      used to split the observations into groups.
   TABLE statement: defines the table. You can have up to 3 dimensions, 
   separated by commas. The comma performs *crossing*.
			1 dimension: columns (default)
			2 dimensions: rows, columns
			3 dimensions: pages, rows, columns
	By default, the table will contain frequency counts */


* Tabulations with 3 class var's, but only 2 dimensions;

PROC TABULATE DATA = boats;
   CLASS Port Locomotion Type;
   TABLE Port, Locomotion*Type;
   TITLE 'Number of Boats by Port, Locomotion, and Type';
RUN;

/* The "*" in this case performs *nesting* (vs the commas, which perform *crossing* */


/********** Stop 9 ************/





/* Section 4.14 */
/* PROC TABULATE, with statistics (here, MEAN) */

* Tabulations with 2 dimensions and statistics;

PROC TABULATE DATA = boats;
   CLASS Locomotion Type;
   VAR Price;
   TABLE Locomotion ALL, MEAN*Price*(Type ALL);
   TITLE 'Mean Price by Locomotion and Type';
RUN;

/* VAR -- the variables on which you want to 
      perform statistics (summaries) */

/* What does the keyword ALL do? What if you remove the first one? 
     The second one? */


* You can use more than one statistic.;
PROC TABULATE DATA = boats;
   CLASS Locomotion Type;
   VAR Price;
   TABLE Locomotion ALL, (N MEAN)*Price*(Type ALL);
   TITLE 'Mean Price by Locomotion and Type';
RUN;

/* Notes:
		Commas create *crossing*
		Asterisks create *nesting*
		Spaces create *concatenation* (Examples: "N MEAN", "Type ALL") */

* Another example: Same table but rearranged;
PROC TABULATE DATA = boats;
   CLASS Locomotion Type;
   VAR Price;
   TABLE Type ALL, Price*(Locomotion ALL)*(N MEAN);
   TITLE 'Mean Price by Locomotion and Type';
RUN;

/* See how, e.g., (N MEAN) is now nested ("*") under Price*Locomotion? */

/* So, there is great flexibility here. This also means you really need
		to think about how to create the "best" table for your needs */


/********** Stop 10 ************/





/* Section 4.15 */
/* Program */

* PROC TABULATE report with some options (FORMAT, BOX, MISSTEXT);
PROC TABULATE DATA = boats FORMAT=DOLLAR9.2;
   CLASS Locomotion Type;
   VAR Price;
   TABLE Locomotion ALL, MEAN*Price*(Type ALL)
      /BOX='Full Day Excursions' MISSTEXT='none';
   TITLE;
RUN;

/* Note that the BOX and MISSTEXT option are separated from the table 
	by a "/" */



/* If you want different statistics to have different formats (pretty common)
	you apply the formats locally: */

PROC TABULATE DATA = boats ;
   CLASS Locomotion Type;
   VAR Price;
   TABLE Locomotion ALL, (MEAN*FORMAT=DOLLAR9.2 N*FORMAT=4.0)*Price*(Type ALL)
      /BOX='Full Day Excursions' MISSTEXT='none';
   TITLE;
RUN;


/********** Stop 11 ************/




/* Section 4.16 */

* Changing headers (specific to PROC TABULATE) and 
	including formats (common to many PROC's);

PROC FORMAT;
   VALUE $typ  'cat' = 'catamaran'
               'sch' = 'schooner'
               'yac' = 'yacht';
RUN;

PROC TABULATE DATA = boats FORMAT=DOLLAR9.2;
   CLASS Locomotion Type;
   VAR Price;
   FORMAT Type $typ.;
   TABLE Locomotion='' ALL, 
      MEAN=''*Price='Mean Price by Type of Boat'*(Type='' ALL)
      /BOX='Full Day Excursions' MISSTEXT='none';
   TITLE;
RUN;

/* Notes:
		The headers for Price and Type were changed
		Using '' as the header removes that header *and* its header cells from the table*/

/* Section 4.17 */

/* A second example of this: 
    If you want to include statistics with different formats, 
	you apply the formats locally. In this example, this is 
	done for 2 VAR variables: */

PROC TABULATE DATA = boats;
   CLASS Locomotion Type;
   VAR Price Length;
   TABLE Locomotion ALL, 
      MEAN * (Price*FORMAT=DOLLAR7.2 Length*FORMAT=2.0) * (Type ALL);
   TITLE 'Price and Length by Type of Boat';
RUN;
 

/* Note that Price and Length are separated by a space, so they are concatenated */


/********** Stop 12 ************/





/* Sections 4.18 to 4.23 will not be covered in this course */

/* Section 4.24 */
/* Example of grouping data with user-defined formats */

DATA books;
   INFILE "&dirdata.LibraryBooks.dat";
   INPUT Age BookType $ @@;
RUN;

/* Our friend @@ again! */


* Define formats to group the data;
*    Note that both numeric and categorical var's may be grouped;

PROC FORMAT;
   VALUE agegpa
         0-18    = '0 to 18'
         19-25   = '19 to 25'
         26-49   = '26 to 49'
         50-HIGH = '  50+ ';
   VALUE agegpb
         0-25    = '0 to 25'
         26-HIGH = '  26+ ';
   VALUE $typ
        'bio','non','ref' = 'Non-Fiction'
        'fic','mys','sci' = 'Fiction';
RUN;

/* See the log (you always look at the log, yes?). What does
	the note about $typ mean? */



*Create a two-way table with Age grouped into four categories;
PROC FREQ DATA = books;
   TITLE 'Patron Age by Book Type: Four Age Groups';
   TABLES BookType * Age / NOPERCENT NOROW NOCOL;
   FORMAT Age agegpa. BookType $typ.;
RUN;

*Create two way table with Age grouped into two categories;
PROC FREQ DATA = books;
   TITLE 'Patron Age by Book Type: Two Age Groups';
   TABLES BookType * Age / NOPERCENT NOROW NOCOL;
   FORMAT Age agegpb. BookType $typ.;
RUN;


/* How does PROC FREQ order the categories? For example,
	why does Non-Fiction get listed before Fiction?

   Are there ways to modify this in PROC FREQ? In PROC TABULATE? */


/********** Stop 13 ************/





/* Some Stop 2 answers */

/* How would you change the code if you wanted to keep 
     the budgeted amounts as variables in the SAS data set? */

/*** Try, for example
	    array budget{6} budget1-budget6 (175,75,25,35,25,30);
     instead of 
	 	array budget{6} _temporary_ (175,75,25,35,25,30);  ***/

/* Suppose you wanted to put "Diff" in front of the expense variable 
     names to create Difference names. So instead of Difference1-Difference6,
     you want DiffRoomRate DiffDailyFood ... DiffParkAdmission. Is
     there a way you could write code to do this in SAS?
     (Think about it--answers given near the end of this file.) */

/*** There is no way to write code to do this in SAS, at least with
        what we have learned so far. The reason is that there is 
		a clear and strong distinction between the data values
		themselves (which we can easily change with coding) and the
		variable names for those data values (which we cannot).
	 (We will see later that we might be able to make these
	    changes with *macrovariables* and *macro statements* but 
		it is not a very natural thing to do) ***/




