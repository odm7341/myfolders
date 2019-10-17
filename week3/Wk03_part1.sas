* Examples from 10.3-10.5 of TLSB and an additional example;
* Examples of generating regular patterns of numbers;


%let dirdata=/folders/myfolders/; * possible SAS Studio access--
                                    see FirstSasStudioSession.doc for details;

%let dirOUT=/folders/myfolders/; * possible SAS Studio access--
                                    see FirstSasStudioSession.doc for details;

 
 /* Chapter 10 */

/* Section 10.3 */

/* First Program */

* Create permanent SAS data set;

LIBNAME travel "&dirOUT";
DATA travel.golf;
   INFILE "&dirdata.Golf.dat";
   INPUT CourseName $18. NumberOfHoles Par Yardage GreenFees;
RUN;

/* Second Program */

* Create Tab-delimited file from this new SAS data set;
PROC EXPORT DATA = travel.golf OUTFILE = "&dirOUT.Golf.txt" REPLACE;
RUN;


/* Section 10.4 */

/* Second Program */

* Create Microsoft Excel file';

/*** Note: In SAS 9.4, DBMS=Excel, DBMS=xls, and DBMS=xlsx all worked on PC SAS ***/
/*** (In SAS 9.3, only DBMS=xls worked.) ***/

PROC EXPORT DATA=travel.golf OUTFILE = "&dirOUT.Golf.xls" DBMS=xls REPLACE;
RUN;


/* Section 10.5 */


/* Second Program */
* Create text file using a DATA step;
* Note how we can use formats, pointers, and text in the PUT statement;

DATA _NULL_;
   SET travel.golf;
   FILE "&dirOUT.Newfile.dat";
   PUT CourseName 'Golf Course' @32 GreenFees DOLLAR7.2 @40 'Par ' Par;
RUN;



/*** This next example is not in TLSB.
 *** This writes a tab-delimited file.
 *** Such a file can be copy-pasted or dragged into Excel.
 *** However, this file can also be 
     a. copy-pasted into Word, where you can use Insert-->Table-->...
        to convert in to a Word Table
     b. dragged into Word, where it becomes an Excel object */

* Remember that '09'x is a tab character;

DATA _NULL_;
   SET travel.golf;
   FILE "&dirOUT.NewfileTab.txt";
   PUT CourseName 'Golf Course' '09'x GreenFees DOLLAR7.2 '09'x 'Par ' Par;
RUN;



/* Generating regular patterns:
   an example */


/* This example generate 60 elements, containing 3 blocks of 20.
In each block, you have 4 1's, 4 2's, 4 3's, 4 4's, and 4 5's.
This is the nested loop. You can read this code from outer loop.
Time number 1: x has value 1, "output" 4 times, x has value 2, "output" 4 times...etc*/
data x;
	drop times each;
	do times=1 to 3;
		do x=1 to 5;
			do each=1 to 4;
				output;
			end;
		end;
	end;
run;
* Please make sure you see the importance of the OUTPUT statement and where it has been placed.;
/* This example is similar to the previous one. By using "by" statement in the loop, instead of going
1 2 3 4 5 6 7 8 9, you are iterating every other number: 1 3 5 7 9 */

data y;
	drop times each;
	do times=1 to 4;
		do y=1 to 9 by 2;
			do each=1 to 3;
				output;
			end;
		end;
	end;
run;

* put into one data set (we will cover "merge" later in the course);

data xy;
	merge x y;
run;

