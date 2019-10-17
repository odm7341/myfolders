/* You may wish to run this with line numbers showing for ease of referencing work.
        In SAS 9.3, 9.4: click on Tools, options, enhanced editor, (under general tab) 
    show line numbers.
    In SAS Studio: this is the default (but can be toggled with a right click). */

/* You may wish to do this each week, but I will not remind you to do this again. */

/* You may want to keep the original file without changes, and copy/paste, e.g.,  to create 
    a file that you can change. This will preserve line numbers in the original file. */

* ONLY EXECUTE ONE OF THESE, OR ENTER IN A NEW ONE YOURSELF *;
* F8 or Run/Submit in PC SAS, F5 or similar in SAS Studio: Make sure you highlight only
    the code you want to run, or else SAS will run ALL of the code !! ;
%let dirdata=/folders/myfolders/HW1/; * possible SAS Studio access--
                                    see FirstSasStudioSession.doc for details;

/* The data we have read in so far has mostly used LIST style, e.g. 
     input Manufacturer $ Type $ Price MPG_city MPG_highway Horsepower Origin $;
  Here, we will use COLUMN style--see LSB 2.6. (There are 3 styles for input. 
    The 3rd one is FORMATTED. Different styles can be used in one INPUT statement) */

/* First, please look at the data file cars93subfw.txt in a text editor */

data cars93fw;
	infile "&dirdata.cars93subfw.txt";
	*infile "&dirdata.cars93subfw.txt" termstr=CRLF; *SAS in Unix, maybe;
	length Type $8;
	input Manufacturer $ 6-15 Type $16-22 Price 23-26 MPG_city 29-30
	        MPG_highway 31-32 Horsepower 33-35 Origin $ 36-42;
run;

/* "6-15" indicates the columns for reading in the data. Use a $ for character
  data (OK, but not needed if var has already been defined as character,
    for example in a LENGTH statement).
  Also, "6-15" is 10 char's long, so this assigns that *character* var to length 10 
     (if the var has not been assigned a length in a LENGTH statement).*/

/* What is the length of Price? */

/* What are two ways that you can verify that Manufacturer has length 10 and 
   origin has length 7 (not length 8) */

/* Predict what would happen if the 
     length Type $8;
   line of code was moved after the input statement.*/

/* Now try it. What happened? Were you correct? */

/* Now try it again, with an "obvious" change? What happened? Did you predict this? */


/********** Stop 1 ************
    This signals a place for you to stop and reflect, to see if you can answer
    any questions you have so far, and to write down the questions you still have.
    Perhaps you will be able to answer these later. Or perhaps you will post them.
*/









/* (I supplied answers to the Stop 1 questions near the bottom of this file.
   But please don't look at these until you have given some thought to the problem
   and, hopefully, figured out the solutions yourself.) */



/* LSB 2.7 Reading in Data using formatted style */

** Pumpkin_Plus.dat. This is the pumpkin.dat data, but with an extra column of data, for interest;
**  First open Pumpkin_Plus.dat in a text editor to see what is in this file;

  /* The next line of code prints out the macrovariable in the log--
     you can use this to verify the value of a macrovariable */
%put &dirdata; 

* Create a SAS data set named contest;
* Read the file Pumpkin_Plus.dat using formatted input;

/* Note that EVERY format in SAS ends with a ".". If you do not include the "."
   either an error will occur that you will be told about, or an unseen error will 
   occur. */

/* Again, first look at the file in a text editor. In particular, does anything 
  look wrong? Will this be "caught"? */

DATA contest;
   INFILE "&dirdata.Pumpkin_Plus.dat";
   *INFILE "&dirdata.Pumpkin_Plus.dat" termstr=CRLF; *SAS in Unix?;
   INPUT Name $16. Age 3. +1 Type $1. +1 Date MMDDYY10.
         (Score1 Score2 Score3 Score4 Score5) (4.1) Cost COMMA7.;
RUN;

* Print the data set to make sure the file was read correctly;
PROC PRINT DATA = contest;
RUN;

/* So, the "2,70" was read in as 270. The SAS algorithm worked as it was programmed to do,
   but a likely data entry error has just passed through into the SAS data set */

/* (What does the SAS algorithm do with COMMA7. that is "smart"? What does it do that is "dumb"?
    You can play around with this if you want. No answers supplied) */

/* See LSB 2.7 for more details on these informats */
/* Note on SAS terminology: 
    "informat" is the format used to read *in* the data. 
	"format" is the format used to print *out* the data */

/* Now look at Pumpkin_Plus2.dat in a text editor. What has changed here?--
   You just need to look at the last var.
   (I also added a number of variations from the original data set)
*/

/* Next, try to read this file into a SAS data set. */
DATA contest2;
   INFILE "&dirdata.Pumpkin_Plus2.dat";
   *INFILE "&dirdata.Pumpkin_Plus2.dat" termstr=CRLF; *SAS in Unix?;
   INPUT Name $16. Age 3. +1 Type $1. +1 Date MMDDYY10.
         (Score1 Score2 Score3 Score4 Score5) (4.1) Cost COMMA7.;
RUN;

proc print data=contest2;run;

/* What is the problem here? */
/* Do not look farther down until you have thought about this */

/********** Stop 1a *************/



























/* First, please open the SAS data set WORK.CONTEST2: in (left panel) Libraries, Work */

/* The basic problem is that "Cost COMMA7." is expecting the Cost data 
   to be
   that was read 7 characters long, from the end of the last column number in. 
      For the first record " $1,200" (including the leading
   blank) is 7 characters, and this number was read in correctly
      For the second record " $13,000" is 8 characters, 
   but only the first 7 were read in
      For the fourth record " $50" is only 4 characters long
   Because of this, and because of how SAS is programmed, SAS
      tried to read the next 3 characters on the next line!
   This is why lines like the following appear in the the SAS log--make sure you always read the log!
     "NOTE: SAS went to a new line when INPUT statement reached past the end of a line"
   But the next line contained alphabetic text (next person's name) instead of digits
     so an error was generated (and that next line did not get read in at all.)

/* One way to fix this: Use an INFORMAT statement instead of placing the informat
     on the INPUT line. This is very useful; however, it is only discussed in 
     footnote 9, p. 49, in LSB. Use of an INFORMAT statement is what we will do next.
*/

DATA contest3;
   INFILE "&dirdata.Pumpkin_Plus2.dat";
   *INFILE "&dirdata.Pumpkin_Plus2.dat" termstr=CRLF; *SAS in Unix?;
   informat Cost COMMA7.;
   INPUT Name $16. Age 3. +1 Type $1. +1 Date MMDDYY10.
         (Score1 Score2 Score3 Score4 Score5) (4.1) Cost;
RUN;

proc print data=contest3;run;

/* Why does this work? Because the programmers at SAS decided to make the INFORMAT
     format behave differently than a format in the INPUT statement. Again, see footnote 9.
     The reason this makes sense is that in
         INPUT ... Cost COMMA7.;
     Cost is being read in using FORMATTED style, and this specifically says to read 
     in the next 7 columns.
     But in
         informat Cost COMMA7.;
         INPUT ... Cost;
     Cost is being read in using LIST style, and this says to read 
     in the next string (using space delimiters) into memory (or "buffer"), 
     and only then apply the COMMA7. format to what is in the buffer.
*/

/* Please be able to explain how SAS interprets these two DATA steps differently */


/* A second way to fix this: Use a colon modifier. (LSB 2.10). 
   For reading in the data, this is equivalent to using the INFORMAT statement */

DATA contest4;
   INFILE "&dirdata.Pumpkin_Plus2.dat";
   *INFILE "&dirdata.Pumpkin_Plus2.dat" termstr=CRLF; *SAS in Unix?;
   INPUT Name $16. Age 3. +1 Type $1. +1 Date MMDDYY10.
         (Score1 Score2 Score3 Score4 Score5) (4.1) Cost :COMMA7.;
RUN;

/* Why is SAS reading in the cost data with more than 7 characters in contest3 and contest4,
   but not for contest2 ?? */

proc print data=contest4;run;
proc compare base=contest3 compare=contest4;run;

/* Note that 
  1. All variables are equal for all observations. Good!
  2. However, one variable contains different attributes. Why?
  3. Also (not noted in PROC CONTENTS) the variables in the two SAS data sets
     are in different orders. Figure out why this happened, and keep it in mind
     for future work in SAS. */


/********** Stop 2 ************/





/* Section 2.9 */

* Here is a data set that is more difficult to read in.;

/* Create a SAS data set named nationalparks;
     Read the data file NatPark.dat (open first in a text editor to see it...).
     Here, you will *mix* input styles to read it in. */

* Note that:
  1. ParkName is read in with COLUMN style
  2. State and Year are read in with LIST style
  3. Acreage is read with FORMATTED style, prefaced by the column pointer @40;

* Use one of these or create one, as needed;
%let dirdata=/folders/myfolders/; * possible SAS Studio access;

DATA nationalparks1;
   INFILE "&dirdata.NatPark.dat";
*   INFILE "&dirdata.NatPark.dat" termstr=CRLF; *SAS in Unix?;
   INPUT ParkName $ 1-22 State $ Year @40 Acreage COMMA9.;
RUN;

DATA nationalparks2;
   INFILE "&dirdata.NatPark.dat";
   INPUT ParkName $ 1-22 State $ Year Acreage:COMMA9.;
RUN;

proc compare base=nationalparks1 compare=nationalparks2;
run;


PROC PRINT DATA = nationalparks;
RUN;

PROC CONTENTS DATA = nationalparks;
RUN;

/* What is the length of the character variables? See what is happening here? */


/********** Stop 3 ************/






/* Section 2.10 */

/* Here is a data set that is even more difficult to read in.*/

/* This makes use of a more sophisticated @ pointer. 
   (As usual, open the data first in a text editor so you can see what is in the file.) */
DATA canoeresults;
  INFILE "&dirdata.Canoes.dat";
*  INFILE "&dirdata.Canoes.dat" termstr=CRLF; * SAS in Unix?;
  INPUT  @'School:' School $ @'Time:' RaceTime :STIMER8.;
RUN;
PROC PRINT DATA = canoeresults;
  TITLE "Concrete Canoe Men's Sprint Results";
RUN;


/* What information in the data file was not read into the SAS data set? 
   Would it be easy to read that in? Why or why not*/


/********** Stop 4 ************/




/* Section 2.11 */

* Input one observation from more than one line of data;

/* Create a SAS data set named highlow.
     Read the data file using line pointers, where "/" goes to the next line 
     and "#3" goes to the 3rd line from where the line pointer began 
     in that loop of the DATA step */

/* Again, open the data file in a text editor first... */

DATA highlow;
   INFILE "&dirdata.Temperature.dat";
   *INFILE "&dirdata.Temperature.dat" termstr=CRLF; *SAS in Unix?;
   INPUT City $ State $ 
         / NormalHigh NormalLow
         #3 RecordHigh RecordLow;
RUN;

PROC PRINT DATA = highlow;
   TITLE 'High and Low Temperatures for July';
RUN;


/* Here, we read in the data sequentially. Is it possible to read it backwards
   instead? For example, read in line 3, then line 2, then line 1? */

/* Could you instead read these data in with 3 INPUT statements? If so, this
   might be useful. For example, suppose that for certain states the line 2 and line 
   data are reversed. If so, we could use IF-THEN statements (to be covered later)
   to decide how to read in the later lines. */

/* (no solutions supplied--please try this on your own to see what works.) */



/********** Stop 5 ************/




/* Section 2.12 */

* Input more than one observation from each line of data;
* (This is the "reverse problem" from what we just did, yes?);

/* A trailing @@ "holds the line". A trailing @ "holds the line" as well (see next example)
   The difference is that:
      * the @ will "release the line" at the *end* of the loop in a DATA step 
        (or if there is a later INPUT statement that does not end in a @ or @@).
      * the @@ will continue to "hold the line" *past the end* of the loop in a DATA step 
        (unless there is a later INPUT statement that does not end in a @@).
   Both will stop doing this when they run out of data */

/* Look at the Precipitation.dat file in a text editor to see why the @@ is needed here */
    
DATA rainfall;
   INFILE "&dirdata.Precipitation.dat";
   *INFILE "&dirdata.Precipitation.dat" termstr=CRLF; *SAS in Unix?;
   INPUT City $ State $ NormalRain MeanDaysRain @@;
RUN;

PROC PRINT DATA = rainfall;
   TITLE 'Normal Total Precipitation and';
   TITLE2 'Mean Days with Precipitation for July';
RUN;

/* Predict what happens if you use a trailing @ instead. 
   Predict what happens if you simply remove the trailing @@ */
/* Predict what would happen in these two scenarios if instead the file has this structure:
      Nome AK 2.5 15 Miami FL 6.75 18
      Raleigh NC . 12 
*/



/* Section 2.13 */


* Use a trailing @, then delete surface streets from the data set;
DATA freeways;
   INFILE "&dirdata.Traffic.dat";
   *INFILE "&dirdata.Traffic.dat" termstr=CRLF; *SAS in Unix?;
   INPUT Type $ @; 
	   * read in Type in list format and then ("@") "hold the line";
   IF Type = 'surface' THEN DELETE; 
	   * the DELETE statement also ends this loop of the data step;
   INPUT Name $ 9-38 AMTraffic PMTraffic; 
	   * continue reading the line from the pointer position;
RUN;

PROC PRINT DATA = freeways;
   TITLE 'Traffic for Freeways';
RUN;


/********** Stop 6 ************/




/* Section 2.14 is not done here, but you should review it */

/* Section 2.17 */

/* Program (data must be read from a spreadsheet) */
%let dirExcel=/folders/myfolders/; * possible SAS Studio access;

/*   
   Please see FirstSasWebSession.doc for a reminder on how to upload a file
*/
   

PROC IMPORT DATAFILE = "&dirExcel.OnionRing.xls" DBMS=XLS OUT = sales;
RUN;
  /* Note how var names are "corrected" here: PROC IMPORT is trying to help the user
     (Such "help" is often good--but not always!) */

PROC PRINT DATA = sales;
title;
RUN;


/********** Stop 7 ************/




/* Section 2.18 */
/* Temporary vs. Permanent SAS data sets*/

/* Temporary--SAS data set goes into the WORK library. Such files are deleted when you exit SAS
   Permanent--SAS data set goes into a library you specify, usually with a LIBNAME statement. 
              Such files are not deleted when you exit SAS. But they are just like any other
              files: you may delete them later, outside of SAS. So, "permanent" is really not the 
              best description of these files! */

/* First Program */
/* We will create a trivial SAS data set. Note that we don't need to read data
   in from a file or from "datalines" to create a SAS data set.
   This data set is just used to illustrate an idea. */

DATA distance; 
   Miles = 26.22;
   Kilometers = 1.61 * Miles;
RUN;

/* This SAS data set goes into the WORK library. 
   SAS PC. Click on Explorer, then--at Libraries level--right-click on Work, 
      then click on Properties to see where this file is temporarily stored on your PC */

PROC PRINT DATA = distance; * same as DATA=work.distance;
RUN;

/* Second Program */

* Create the association between a library and a directory;

* You will need to create a directory for your PC! ;
%let mySASfiles='/folders/myfolders/sasEx/'; * possible SAS Studio access;
   ** (You will need to have the sub-folder sasEx on your PC for this to work) **;
* Make an association between the SAS internal name of your choice (here, Bikes--up to)
  8 characters long--and the actual directory name;
LIBNAME Bikes &mySASfiles;

DATA Bikes.distance; 
   Miles = 26.22;
   Kilometers = 1.61 * Miles;
RUN;

/* Verify this data set exists in your directory. 
      What is its actual file name?
      Is it a binary or text file? 
      (This can be figured out only if this file is on a PC. 
       Web Editor folks: you can download this file to your PC if you want to...)*/

PROC PRINT DATA = Bikes.distance;
RUN;


/********** Stop 8 ************/





/* Section 2.19 */

/* First Program */

/* In the next statement you could use another directory on 
   your PC instead of &mySASfiles. 
   (However, because I am just doing this only as an exercise, 
	 I will put all of these SAS files 
    into the same directory.) */

LIBNAME plants &mySASfiles;

* Look at Mag.dat in a text editor to understand why this mixed input style works;

DATA plants.magnolia;
   INFILE "&dirdata.Mag.dat";
   *INFILE "&dirdata.Mag.dat" termstr=CRLF; *SAS in Unix?;
   INPUT ScientificName $ 1-14 CommonName $ 16-32 MaximumHeight
      AgeBloom Type $ Color $;
RUN;

PROC PRINT DATA = plants.magnolia;
   TITLE 'Magnolias';
RUN;



/********** Stop 9 ************/




/* Section 2.20 */

/* Earlier, we indirectly referenced a directory using a SAS library name.
   Here, we use direct referencing. And see comments in this 
	week's assignments about this.
   Again you will need to change the directory to one on your PC or Web Editor */

* SAS data set will be magnolia2 in the directory given--
   select one of these DATA statements or create your own;
*DATA 'C:\coursesSem\611\temp\magnolia2'; 
DATA '/folders/myfolders/sasEx/magnolia2'; * possible SAS Studio access;
   INFILE "&dirdata.Mag.dat";
   *INFILE "&dirdata.Mag.dat" termstr=CRLF; *SAS in Unix?;
   INPUT ScientificName $ 1-14 CommonName $ 16-32 MaximumHeight
      AgeBloom Type $ Color $;
RUN;

* Select one of these or create your own;



PROC PRINT DATA =  '/folders/myfolders/sasEx/magnolia2'; * possible SAS Studio access;
  * Could we use this instead?  PROC PRINT DATA = plants.magnolia2; ;
   TITLE 'Magnolias';
RUN;

/* What is the name of this file on your PC? */


/* Will this code run to show that the two SAS data sets are identical?*/
PROC COMPARE base=plants.magnolia compare=plants.magnolia2;run;



/********** Stop 10 ************/





/* Section 2.21 */

/* Note 
   * the use of the LABEL option at the SAS Data Set level
   * the use of the LABEL statement for the var names
   * use of both informat and format for the DoB (Date of Birth) var
   * use of trailing @@
*/

DATA funnies (LABEL = 'Comics Character Data');
   INPUT Id Name $ Height Weight DoB MMDDYY8. @@;
   LABEL Id  = 'Identification no.'
      Height = 'Height in inches'
      Weight = 'Weight in pounds'
      DoB    = 'Date of birth';
   INFORMAT DoB MMDDYY8.;
   FORMAT DoB WORDDATE18.;  * we will discuss FORMAT statements later;
   DATALINES;
53      Susie 42 41 07-11-81    54      Charlie 46 55 10-26-54
55      Calvin 40 35 01-10-81   56      Lucy 46 52 01-13-55
   ;

proc print;run;

* Use PROC CONTENTS to describe data set funnies;
PROC CONTENTS DATA = funnies;
RUN;


* Do we need "MMDDYY8." here twice? If so, why? If not, does it matter which one we use?;


/********** Stop 11 ************/



/* some Stop 1 answers */
/* What is the length of Price? */

/*** 8, not 4. Price is a *numeric( var--its length is *not* determined by
    the number of columns that were read in. That is only true for
	*character* vars. ***/

/* What are two ways that you can verify that Manufacturer has length 10 and 
   origin has length 7 (not length 8) */
/*** 1. Proc contents; run;
     2. Click on Explorer (bottom left), Libraries, Work (why?), Cars93fw,
	    then right click on Price, then Column Attributes ***/
   
   
/* Predict what would happen if the 
     length Type $8;
   line of code was moved after the input statement.*/

/*** SAS first sees Type as "Type 16-22", so it assumes it's a numeric var.
     But the later "length Type $8" tells SAS you want it to be a character
	 var. Error: you can't change the type of a var in SAS ***/
   
/* Now try it. What happened? Were you correct? */

/* Now try it again, with an "obvious" change? What happened? Did you predict this? */
/*** Well, I'm sure there are a few things you could do here. I was thinking of
     changing "Type 16-22" to "Type $ 16-22". What happened? What is the 
     length of Type? ***/

