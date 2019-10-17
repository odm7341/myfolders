/* You may wish to run this with line numbers showing for ease of referencing work.
    In SAS 9.3, 9.4: click on Tools, options, enhanced editor, (under general tab) 
    show line numbers.
    In SAS Studio: this is the default (but can be toggled with a right click). */


/* You may want to keep only the original file, without changes. But more likely 
    you will also want to copy/paste it, e.g., to create 
    a file that you can change. Note that the line numbers in the original file 
    will be preserved */


* The below shows different ways to read in data; * <- This is a comment;
* A line that begins with "*", ends with a semicolon;

/* Entering text between these key sequences 
  ("forward slash *" up to "* forward slash"
   is another way to create a comment */

/* To execute one or more lines of code, highlight them with your 
   mouse and then submit that code.
   In SAS for Windows: click the "running" icon, or click Run->Submit, 
      or simply hit F8. 
      Use F9 to see a list of function-key meanings.
   In SAS Studio: click the "running" icon, or hit F3. 
 */

    *** IF YOU DO NOT HIGHLIGHT THE CODE YOU WISH TO SUBMIT, THEN SAS
        WILL EXECUTE *EVERY* LINE OF CODE IN THE FILE. THIS IS NOT NORMALLY
	    WHAT YOU WANT TO DO!! ***

/* To undo some changes you make, use CTRL-Z. To redo those undo's, use CTRL-Y. 
   This is a standard Windows shortcut
   and works for both SAS for Windows and SAS Studio. */


* First, we will read data from the file cars93subfree.txt;

/* %let is an example of a macrovariable--to be discussed later. 
    (You need to change to the directory name where the "cars93" files files below 
     have been stored--
     one of these %let statements may work, or you may need to create a new one) */
* ONLY EXECUTE ONE OF THESE, OR ENTER IN A NEW ONE YOURSELF *;
%let dirdata=/folders/myfolders/Week1/; * possible SAS Studio access--
                                   see FirstSasStudioSession.doc for details;
%let dirdata=/folders/myshortcuts/611/data/; * possible SAS Studio access. What I use;
* an example of a SAS DATA step;
/* It is always a good idea to open the text data file in a text editor before you open
it in SAS.
*/
data cars93ff1; 
  infile "&dirdata.cars93subfree.txt" firstobs=2 /*termstr=CRLF*/; 
  input Manufacturer $ Type $ Price MPG_city MPG_highway Horsepower Origin $;
run;


* Now let's look at each line of this DATA step in more detail;

/* cars93ff1 is the name of the SAS Data Set where the data 
   will be stored during this session */
data cars93ff1; 
/* In the next line, the filename is cars93subfree.txt. firstobs=2 causes the 
     first line in the file to be skipped.
     You may need to use termstr=CRLF if you are accessing Windows files 
	   in a Unix environment.
     This option will work in Windows as well, but it is redundant, 
	   so should not be included.;
    **** SAS Unix Users **** 
     Again: you may need to add this termstr=CRLF option. That is:
     infile "&dirdata.cars93subfree.txt" firstobs=2 termstr=CRLF; */
  infile "&dirdata.cars93subfree.txt" firstobs=2; 
* So the above is the same as 
   infile "D:\coursesSem\611\data\cars93subfree.txt" firstobs=2;
  *(The "." is used after "&dirdata" to let SAS know where the macrovariable name ends);
* The advantage of using a macrovariable is that its definition 
   only needs to be changed
   in one place to update all of the references to this directory below;

* The $ after a var name means that var is a character variable. 
   Otherwise it is a numeric variable. These are the only two kind of variables that SAS supports.;
  input Manufacturer $ Type $ Price MPG_city MPG_highway Horsepower Origin $;
run; * This forces the DATA step to end and to be run. 
       It is not the only way to force the DATA step to run, but it is a good way...;

* The data is stored in the SAS data set cars93ff. More precisely, in WORK.cars93ff, 
*  where WORK is a specially-named library (a pointer to a Windows directory 
   either directly or (SAS Studio) indirectly.
*  This is a temporary library--the file will be erased when you end your SAS session;

* Now print the results (SAS PC--goes to the Results Viewer window by default). 
*   The printing is done using a PROC (procedure) step;

proc print data=cars93ff1;
run;

/*
*** Note: each step in SAS is either 
      1. a DATA step, or 
      2. a PROC step.
    There are some other features, such as OPTION statements, 
	  macrovariables and macros, but it is useful to think of 
	  DATA and PROC steps as forming the basis of most 
      of your work in SAS.


/********** Stop 1 ************
This signals a place for you to stop and reflect, to see if you can answer
any questions you have so far, and to write down the questions you still have.
Perhaps you will be able to answer these later. Or perhaps you will post them.
*/



/*
* The results of PROC PRINT are shown in the OUTPUT ore RESULTS VIEWER window.
* What is "wrong" here? Please figure this out before you proceed.
 

* Alternatively, (SAS in Windows) let's see this SAS data set using VIEWTABLE.
   click on Explorer (look at bottom left), then Libraries 
  (lists the Active Libraries), then double-click Work, then double-click Cars93ff.
   The results should appear in the VIEWTABLE window.

* Or (SAS Studio), in the left window, click on Libraries. Under WORK, 
  you should find Cars93ff. Double-click on it.

* Next, (SAS in Windows) right-click on Manufacturer, then column attributes. 
* Or (SAS Studio) under Columns, click on Manufacturer. Its attributes 
    should appear below it.
*   What is the length? (In bytes--each character requires one byte)
*   Do you see why "Chevrolet", for example, did not get fully stored?

* Now do the same with the var Price. Note that its length is also 8 bytes, but 
  this has a more subtle meaning for numeric vars.

*/

* Now we will redo this, but making the Manufacturer var a better length 
  (it is 8 characters by default);
* Note: the lines between "data cars93ff2" and "run" are indented only to make 
  the DATA step easier to read--it is the semicolons that separate one SAS
  statement from the next one;

data cars93ff2;
  infile "&dirdata.cars93subfree.txt" firstobs=2;
  length Manufacturer $10;
  input Manufacturer $ Type $ Price MPG_city MPG_highway Horsepower Origin $;
run;

* Did this run correctly? You should check by ALWAYS looking at the LOG window 
  after you run a step! 
* (In SAS in Windows only) Now fix the problem here by closing the VIEWTABLE window 
  and rerunning;

* The following PROC provides information about the DESCRIPTOR portion 
  (but not the DATA portion) of a SAS data set;

proc contents data=cars93ff2;
run;


/*
*** Note: SAS basically stores information either in
      1. SAS data sets
      2. macrovariables
    We have seen example of both of these.
*** In most cases, it will be useful to think of the "real data" as being 
    stored in SAS data sets
    and "special or other information" stored in macrovariables.
*/
 

/********** Stop 2 ************/





* Next, here is how to read in data that is entered directly (not stored in a file)
    --note the changes in code from before;
data cars93ffRaw;
  length Manufacturer $10;
  input Manufacturer $ Type $ Price MPG_city MPG_highway Horsepower Origin $;
  datalines;
Buick Midsize 15.7 22 31 110 USA
Buick Large 23.7 16 25 180 USA
Cadillac Midsize 40.1 16 25 295 USA
Chevrolet Sporty 15.1 19 28 160 USA
Chrylser Large 18.4 20 28 153 USA
Dodge Small 9.2 29 33 92 USA
Dodge Small 11.3 23 29 93 USA
Dodge Van 19 17 21 142 USA
Eagle Small 12.2 29 33 92 USA
Eagle Large 19.3 20 28 214 USA
Ford Small 10.1 23 30 127 USA
Ford Compact 11.3 22 27 96 USA
Ford Midsize 20.2 21 30 140 USA
Geo Sporty 12.5 30 36 90 non-USA
Lexus Midsize 28 18 24 185 non-USA
Mazda Small 8.3 29 37 82 non-USA
Mazda Sporty 32.5 17 25 255 non-USA
Nissan Compact 15.7 24 30 150 non-USA
Oldsmobile Compact 13.5 24 31 155 USA
Pontiac Small 9 31 41 74 USA
; * This semicolon forces the data reading to stop and for the DATA step to be run;


* We can compare the two SAS data sets to verify that both have the 
   same var's and the var's values in each are equal;
proc compare base=cars93ff2 compare=cars93ffraw ;
run;


/* *** Next...
* From TLSB, 1.4 (please read). The DATA step's built-in loop:
     Basically, SAS loops through the DATA step line-by-line, 
     for observation 1, then for obs 2, and so on.
* At the end of the i-th loop through the DATA step, SAS by default writes 
     obs i out to the SAS data set.
* Here are some examples to make this clearer */

* 1. Stopping the looping partway through. 
     SAS has a built-in variable in the DATA step named _n_. It is equal to 1
     for the first loop, 2 for the second loop, and so on.

     This next DATA step will only send the first 6 records to the SAS data set.
     (We will discuss IF THEN statements later.) The STOP feature does 
	    just what it says.;

data cars93ff3;
  infile "&dirdata.cars93subfree.txt" firstobs=2;
  length Manufacturer $10;
  input Manufacturer $ Type $ Price MPG_city MPG_highway Horsepower Origin $;
  n=_n_; * create a new var for the SAS data set;
  if _n_ > 6 then stop;
run;
* The SAS log will indicate that this data set has 6 observations;

proc print;run; 
  * Notes: 
    a. more than one statement can be on a line. 
    b. Not specifying a data set uses the last one created;

* 2. Implicitly, each loop of the data step ends by outputting
        the observation to the data set.
     This feature is overridden whenever an explicit OUTPUT statement 
	    is in the DATA step;

data cars93ff4;
  infile "&dirdata.cars93subfree.txt" firstobs=2;
  length Manufacturer $10;
  input Manufacturer $ Type $ Price MPG_city MPG_highway Horsepower Origin $;
  n=_n_;
  if _n_ > 6 and _n_ <=10 then output;
run;
* Only rows 7, 8, 9, 10 of the original file are written to the SAS data set;

proc print;run;

* 3. Only output Dodge cars. 
    Note: the DATA step is still reading in all the data--that is looping 20 times;

data cars93ff4;
  infile "&dirdata.cars93subfree.txt" firstobs=2;
  length Manufacturer $10;
  input Manufacturer $ Type $ Price MPG_city MPG_highway Horsepower Origin $;
  n=_n_;
  if  Manufacturer="Dodge" then output;
run;

proc print;run;
* Only rows 6, 7, 8, meet the output criterion;

/* End of the cars93... work */


/********** Stop 3 ************/





* This is data from TLSB 2.15, but I am reading it differently from what is 
   in the book:
   1. Take a look at the Bands.csv file 
      (open this in a text editor, to see what the file really looks like. 
       Opening this in Excel does not show the correct structure).
   2. This is in csv (comma separated value) format. Look at it carefully. 
       What do you see?
   3. We will not read in the date as a date, at least not this week.;
   



DATA music;
  infile "&dirdata.Bands.csv" DLM = ',' DSD MISSOVER /*termstr=CRLF*/; 
     * please learn about these options in TLSB;
  length Band_Name $30 Gig_Date $10;
  input Band_Name Gig_Date Eight_PM Nine_PM Ten_PM Eleven_PM;
RUN;


* Now, there is another way to read in data in common formats: PROC IMPORT.
  See TLSB, 2.16. This includes the ability to:
   1. Determine variable types (character, numeric, and possibly dates)
   2. Determine variable lengths for character vars
   3. Handle other features--see TLSB for details;

/* Note: if you are using SAS on Unix, use DATAFILE="&dirdata.Bands2_Plus.csv"
   instead.  We will discuss why in the HW */
   
PROC IMPORT DATAFILE ="&didataB.Bands2.csv" OUT = music2 REPLACE;
RUN;

/* (Look at the difference in real and cpu time between the earlier 
   DATA step and PROC IMPORT. This is due to the extra overhead needed. 
   Also look at the log to see what PROC IMPORT
   is actually doing "behind the scenes".) */

proc compare base=music compare=music2;run;
/* What differences do you see? Please look! Note: I had to first make sure that 
   the var names in both SAS data sets were equal. If two var names do not match, 
   no comparison between that pair can be made */



/********** Stop 4 ************/




