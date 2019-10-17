/* This week, we will discuss:
   More on SAS data sets, functions, dates, 
      if-then statements, logic */
/* Macro variable dirdata for all sas files*/
%let dirdata=/folders/myfolders/Week 2/; * possible SAS Studio access--
                                    see FirstSasStudioSession.doc for details;

/* Section 3.1 */
/* Program */

/* Read in Garden.dat and make additions and changes
   with assignment statements.
   First take a look at the data file (*always* a good idea) */

DATA homegarden;
   INFILE "&dirdata.Garden.dat";
   INPUT Name $ 1-7 Tomato Zucchini Peas Grapes;
   Zone = 14; * same value for each record;
   Type = 'home'; * same value for each record. Note: Type is character with length 4;
   Zucchini = Zucchini * 10; * replaces old values with new ones;
   * Next is a sum. What will happen here when there is a missing value in Peas?;
   Total = Tomato + Zucchini + Peas + Grapes; 
   PerTom = (Tomato / Total) * 100; *Aside: SAS also has PERCENTx. formats ...;
RUN;
PROC PRINT DATA = homegarden;
   TITLE 'Home Gardening Survey';
RUN;



/* Thought experiment: In the DATA step above, what would happen if 
   you replaced the statement
     Type = 'home'; 
   with the statements
     If _n_<2 then Type='home'; else Type='garden';
*/


/********** Stop 1 ************/




/* Section 3.2 */

/* SAS has hundreds (thousands?) of functions. Here are a few */

/* Look at the INPUT statement--can you "see" the structure of
     Pumpkin_Plus3.dat even before you look at the file contents? */

DATA contest;
   INFILE "&dirdata.Pumpkin_Plus3.dat";
   INPUT Name $16. Age 3. +1 Type $1. +1 Date MMDDYY10.
         (Scr1 Scr2 Scr3 Scr4 Scr5) (4.1);
   TotScore = SUM(Scr1, Scr2, Scr3, Scr4, Scr5);
   TotScore2 = Scr1 + Scr2 + Scr3 + Scr4 + Scr5; * same as SUM function?;
   AvgScore = MEAN(Scr1, Scr2, Scr3, Scr4, Scr5);
   AvgScore2 = (Scr1 + Scr2 + Scr3 + Scr4 + Scr5)/5; * same as MEAN function?;
   DayEntered = DAY(Date);
   Type = UPCASE(Type);
RUN;
PROC PRINT DATA = contest;
   TITLE 'Pumpkin Carving Contest with Missing Data';
RUN;


/* Which sums and averages do you think would be more appropriate here?*/


/********** Stop 2 ************/




/* Sections 3.3, 3.4 -- a small listing of some character 
    and numeric (including date) functions*/

/* Section 3.5 */

/* You have already seen the use of a few if-then statements.
      Here is a bit more detail on them.
   Note: "if-then" is a standard feature in programming languages */

DATA oldcars;
   INFILE "&dirdata.Auction.dat";
   INPUT Make $ 1-13 Model $ 15-29 YearMade Seats MillionsPaid;
   * simple if-then statement;
   IF YearMade < 1890 THEN Veteran = 'Yes';
   /* An if-then statement with a *DO group*, allowing multiple
     actions to be performed. Note the DO; ... END; pairing
     that is used here. This idea is widely used in programming */
   IF Model = 'F-88' THEN DO;
      Make = 'Oldsmobile';
      Seats = 2;
   END;
RUN;

/* More complex conditions can be used in the IF part, e.g.
     IF Model = 'F-88' AND YearMade<1954 then ... */

/* AND or & can be used for "and"
   OR, |, !, can be used for "or"
   NE, ^=  (and more) can be used for "not equal"
   You can also use inequalities and logical NOT here--an example is given below */

PROC PRINT DATA = oldcars;
   TITLE 'Cars Sold at Auction';
RUN;


/* Section 3.6 */

/* Here are if-then-else statements
   Note: "if-then-else" is a standard feature in programming languages */

* Group observations by cost;

DATA homeimprovements;
   INFILE "&dirdata.Home.dat";
   INPUT Owner $ 1-7 Description $ 9-33 Cost;
   IF Cost = . THEN CostGroup = 'missing';
      ELSE IF Cost < 2000 THEN CostGroup = 'low';
      ELSE IF Cost < 10000 THEN CostGroup = 'medium';
      ELSE CostGroup = 'high';
RUN;
PROC PRINT DATA = homeimprovements;
   TITLE 'Home Improvement Cost Groups';
RUN;

/* Question. What is the length of the CostGroup variable? 
   (Try to figure this out from the code. Then check your answer. 
    What does this suggest about performing such if-then-else statements?)*/


/********** Stop 3 ************/





/* Section 3.7 */

/* Example of a *subsetting IF* statement.*/
   


* Choose only comedies;
DATA comedy;
   INFILE "&dirdata.Shakespeare.dat";
   INPUT Title $ 1-26 Year Type $;
   IF Type = 'comedy';
   /* Recall  From TLSB5, 1.4, that the DATA step has a built-in loop.
      The subsetting IF statement says to continue on in the loop
      only if the condition is met. This fact, and the fact that
      there is an implicit OUTPUT statement at the end of the loop means that,
      if you don't meet the IF condition, then the record will not be
      written to the SAS data set */
RUN;
PROC PRINT DATA = comedy;
   TITLE 'Shakespearean Comedies';
RUN;





/* Section 6.1 (extra--not in book order...) */

/* In all of our SAS examples so far, we have used *one* DATA step to
   1. Read in data from a text file.
   2. Possibly, create new variables or modify old ones
      (assignment statements and maybe other statements as well, e.g. IF-THEN)
   3. Possibly, only keep a subset of the observations from the text file
      (subsetting IF, or IF-THEN DELETE, or IF-THEN OUTPUT) 
   
 
/* Example: store all of the data from Shakespeare.dat into a SAS data set, and
   only then create a SAS data set of just comedies. In this way, we preserve the
   original data set */

DATA ShakespeareAll;
   INFILE "&dirdata.Shakespeare.dat";
   INPUT Title $ 1-26 Year Type $;
RUN;

DATA comedy2;
   SET ShakespeareAll;
   IF Type = 'comedy';
RUN;

/* Note: we use the SET statement to read in a SAS data set */

PROC compare base=comedy compare=comedy2;
RUN;

/* We can instead modify the same data set.
   This example also shows the END= option, 
   and more functions and use of logic */

DATA ShakespeareAll;
   SET ShakespeareAll END=eof;
	   /* *END* is a keyword; *END=* is an option in the 
	      SET (or INFILE) statement. When the last record is read
	      here, then eof (a variable name of your choice) is set to 1 
	      (which is a logical TRUE in SAS); otherwise it is set to 0
	      (logical FALSE). This var is not written out to the SAS data set */
   LENGTH TypeAbb $4 Group $5;
   TypeAbb=substr(Type,1,4); * substr is used to get a "substring";
		/* syntax:
		      substr(CharVar,starting position, length)
		   NOT
		      substr(CharVar,starting position, ending position)
		   You can also use 
		      substr(CharVar,starting pos) : extracts up to the last
			      non-blank character in the string */
   IF not(TypeAbb="come" OR TypeAbb="roma") then Group="heavy"; 
      else Group="light";
   IF (eof) then put 'Last title in the data set is ' Title; *written to the log*;
RUN;

Title 'More on Shakespeare';
PROC PRINT; RUN;
Title ;

/********** Stop 3a ************/




/* Section 3.8 */

/* Example of SAS Dates.
   We have done this a little bit already, but here is a simple example
     that tries to show 
	 1. How dates are stored *internally* in SAS
	 2. What an informat does (read *in* a human-style date, 
	    stores it internally)
	 3. What a format does (takes an internal date, writes it *out* 
	    in a human-style date--really, whatever you request)
*/
   
Data dateTest;
   input d1 MMDDYY8. +1 d2 DATE9.; 
     * informats (these could instead be used in an INFORMAT statement);
   d1f=d1;
   d2f=d2;
   d3f=d2;
   format d1f DATE9. d2f WORDDATE. d3f MMDDYY8.; * formats;
   datalines;
01111960 12JAN1960
01011961 01MAR2013
;

proc print;
run;

proc print;
   format d1f 9.0 d1 WEEKDATE.;
run;


/* 1. How was "01111960" read in correctly?
   2. How is it stored internally in the SAS data set?
   3. How was it printed out?
*/


/********** Stop 4 ************/



/* Here is the example from TLSB */

DATA librarycards;
   INFILE "&dirdata.Library.dat" TRUNCOVER; * (What does TRUNCOVER do?);
   INPUT Name $11. + 1 BirthDate MMDDYY10. +1 IssueDate ANYDTDTE10.
      DueDate DATE11.;
   DaysOverDue = TODAY() - DueDate;  * The TODAY() function;
      * (The () is needed so that TODAY is recognized as a function);
   CurrentAge = INT(YRDIF(BirthDate, TODAY(), 'AGE')); * What does YRDIF do? INT?;
   IF IssueDate > '01JAN2012'D THEN NewCard = 'yes';
RUN;
PROC PRINT DATA = librarycards;
   FORMAT Issuedate MMDDYY8. DueDate WEEKDATE17.;
   TITLE 'SAS Dates with and without Formats';
RUN;

/* What might be a more appropriate way to write this code:
   DaysOverDue = TODAY() - DueDate; 
*/

/* What value does NewCard get when the IF condition on 
   that line is not satisfied? Why? (This is discussed in
   this week's assignments. Search the assignments for "PDV") */


/********** Stop 4a ************/
/* Section 3.10 */
/* Program */

* Using RETAIN and sum statements to find most runs and total runs;
DATA gamestats;
   INFILE "&dirdata.Games.dat";
   INPUT Month 1 Day 3-4 Team $ 6-25 Hits 27-28 Runs 30-31;
   RETAIN MaxRuns;
   MaxRuns = MAX(MaxRuns, Runs);
   RunsToDate + Runs;
RUN;

PROC PRINT DATA = gamestats;
   TITLE "Season's Record to Date";
RUN;


/* Please see listing. The results are obtained because:
   1. The RETAIN statement "saves" the last value of MaxRuns
      (and by default sets its initial value to .);
   2. This is why 
        MaxRuns = MAX(MaxRuns, Runs);
      accumulates MaxRuns correctly;
   3. "RunsToDate" looks a bit stranger. The line
        RunsToDate + Runs;
      is a shorter (but maybe confusing?) way in SAS to write
        RETAIN RunsToDate 0; * sets initial value to 0;
        RunsToDate = SUM(RunsToDate, Runs);

Note: this provides a way in SAS to use the data from 
  record n - 1 in record n.

*/


/********** Stop 5 ************/







/* Section 3.11*/
/* Program */

* Change all 9s to missing values;

/* Note: We are really not going to look at the 
     ARRAY statement and interactive DO loops until
     next week. I am only including this here so
     that, in the following exercise, you can
     see examples of how to use shortcuts
     for lists of variable names */
     
DATA songs;
   INFILE "&dirdata.KBRK.dat";
   INPUT City $ 1-15 Age wj kt tr filp ttr;
   ARRAY song (5) wj kt tr filp ttr;
   DO i = 1 TO 5;
      IF song(i) = 9 THEN song(i) = .;
   END;
RUN;

   /* ARRAY song (5) wj kt tr filp ttr;
        This ARRAY statement means that
        song(1) is associate with wj, song(2) with kt, 
        and so on. song(1), song(2), ... are *not* SAS variables. */

   /* The "DO i = 1 to 5;" is called an iterative DO statement */


PROC PRINT DATA = songs;
   TITLE 'KBRK Song Survey';
RUN;


/* Section 3.12 */
/* Program */      


DATA songs2;
   INFILE "&dirdata.KBRK.dat";
   INPUT City $ 1-15 Age wj kt  tr filp ttr;
   ARRAY new (5) Song1 - Song5;
   ARRAY old (5) wj -- ttr;
   DROP i;
   DO i = 1 TO 5;
      IF old(i) = 9 THEN new(i) = .;
         ELSE new(i) = old(i);
   END;
   AvgScore = MEAN(OF Song1 - Song5);
   run;

   /* ARRAY new (5) Song1 - Song5; 
	     one hyphen, with variable names ending in numbers
        Song1-Song5 is the same as Song1 Song2 Song3 Song4 Song5; */

   /* ARRAY old (5) wj -- ttr;
        two hyphens: those two var's plus all the var's "in between":
        wj--ttr is the same as wj kt  tr filp ttr.
        Be careful! This depends on the var ordering in
        the SAS data set. */

	/* DROP i;
	    The index variable i (and all variables you read in or create) 
	    will be included in the SAS data set by default.
	    You can use the DROP or KEEP statements to only save a subset
	    of the variables 

	   Please look at the difference between subsetting *observations* 
	   (DELETE or subsetting IF statements) and subsetting *variables*
	   (DROP or KEEP statements) */

PROC PRINT DATA = songs2;
   TITLE 'KBRK Song Survey 2';
RUN;





/********** Stop 6 ************/



