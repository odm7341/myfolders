
%let dirdata=/folders/myfolders/; * possible SAS Studio access;


%let dirdata2=/folders/myfolders/; * possible SAS Studio access;



* ### You will need to define dirOUT ###;
* # This will be used to write some files to your PC or the SAS server;


%let dirOUT=/folders/myfolders/; * possible SAS Studio access;


/*
####     Three main topics this week     ####

#### 1. Reading in Multiple Files        ####
#### 2. Reading Files from the Web       ####
#### 3. Creating Nicer Output            ####
####        (not just tables)            ####
*/


/* ******  Note to SAS Web Editor Users *******

For item 1, Reading in Multiple Files:
	* The SAS code was originally written under
		the assumption that the user could
		access his/her OS (Operating System)
		to get a listing of file names. When
		I tried to do this in SAS
		Web Editor in 2013, I received this message:
 			ERROR: Insufficient authorization to access PIPE.
		I am not sure if you will have the same problem
			in SAS Studio, but I am assuming you might.
		So, for these problems, I have set
		aside some code for you so you
		can read in this listing indirectly.

For item 2, Reading Files from the Web,
	* The SAS code was originally written under
		the assumption that the user could
		access the Internet to access
		the contents of some Web pages
		When I tried to do this in SAS
		Web Editor in 2013, I received this message:
			 ERROR: Connection refused.
		I am not sure if you will have the same problem
			in SAS Studio, but I am assuming you might.
		So, for these problems, I have set
		aside some code for you so you
		can read in these Web pages from
		local files.

For both cases, makes sure you see how the
	more useful method can be used in "real
	SAS." */


/* #### 1. Reading in Multiple Files ####

   ##      Simple example       ## 

# a. We want to read in all files in dirdata2 whose
# 	file names begin with "file". 
# b. We decide that we will store the information
#	from all of these file into one SAS data set.
# c. The formats of the input files are known and are
#	the same for each file.

# I will adopt a common strategy here:
#	1. Obtain the filenames from the OS (Operating System). 
#		This seems less natural to do in SAS than in other languages, 
#		but it is still pretty straightforward.
#	2. Figure out how to read in one file, to make sure 
#		that we have written the one-file code correctly.
#	3. Use some SAS method to read in all the files and handle 
#		these as desired. Here, we will store
#		all of the data in one SAS data set--the natural
#		way to do this in SAS.
#		(We will also see that we might use other SAS
#		 methods for other situations.)
*/
/* 	1a. Obtain the filenames from the OS. */

/* 	1b. Obtain the filenames from a file. */


filename fnamesRW "&dirdata.fnames.txt";

data fnames;
	length fname $20;
	infile fnamesRW truncover termstr=CRLF;
	input fname; /* read the file name from the file */
	fname=trim(left(fname)); /* trim blanks at both ends of fname*/
run;

title;
proc print;run;

* too many files--we just want the ones that start with File, so: ;
data fnames1;
	set fnames;
	if upcase(substr(fname,1,4))="FILE";
run;
proc print data=fnames1;run;

*   Questions?;



*********** Stop 1a ***********;

/*
#	2. Figure out how to read in one file, to make sure 
#		that the DATA step will do this correctly.

# First, we need to select a file to read in. Let's 
#  	pick the first one and store it in a macro
#		variable. (This shows one way to transfer information
#		in a SAS data set to another DATA step.)

# Of course, we have just typed it in, but it's better
#	to avoid this when you don't need to.
#	(And we will see that this idea will be very
#	useful later in these notes.)
*/

* This will store the name of first file in the 
    macrovariable &firstFile1, where "symput" 
    probably means "symbol put";
data _null_;
	set fnames1;
	if _n_=1 then call symput ('firstFile1',fname);
run;

%put &firstFile1;

* Let's run a test case;
data test;
	infile "&dirdata2&firstFile1" termstr=CRLF; * direct fileref;
	input ID $ Score1 Score2;
run;
proc print;run;
	* looks good;


/*
#	3. Use a SAS method to read in all the files and handle 
#		these as desired (for this case, store
#		all the data in one SAS data set--the natural
#		way to do this in SAS).
*/

/*	Look carefully at the following DATA step. 
	This is what we will be doing:
	1. Read in one record from fnames1. Now
		the filename in fname is available.
	2. Use a special infile statement that 
		creates a fileref that points to
		the full filename (in the var fullname).
	 	(This infile statement also includes
		an "end=" option.)
	3. Then use a DO WHILE loop to read in
		the data from that file, and 
		use an OUTPUT statement to 
		write out every record that it read in.
		(Then stop when that file has no more
		records to read in.)
*/

data fileSDS;
	set fnames1;
	fullname="&dirdata2"||fname; *The "||" concatenates...;
	infile fname1 filevar=fullname
		end=eof termstr=CRLF;
	do while (not eof);
		input ID $ Score1 Score2;
		output;
	end;
	put 'Finished reading ' fname=;
run;


/* Notes:
	1. We are looping as usual through the DATA
		step--3 loops because we are reading in
		3 records from fnames1.
	2. *However*, we are also "looping within the loop"--
		For FileA.dat we loop through DO WHILE 4x,
		then 3x for FileB.dat and 5x for FileC.dat.
	This is another example of the sophisticated
	nature of the DATA step in SAS.
*/

proc print;run;


*   Questions?;



*********** Stop 1b ***********;







/*
#### 1. Reading in Multiple Files ####

##      Not-So-Simple example       ##
*/



/*
# This example is more typical than the simple example,
#	but you will see the fundamental idea is the same.
#	This example is based on a real problem from a student.

#	For each of a number of files, the objective is to:
#	a.	Delete all records (rows) up to and including
#		the second record that says "EOR". You can assume
#		that "EOR" is the only information on such records.
#		(We will soon look at an example file.)
#	b.	Delete the last two rows: the third "EOR" and then "EOF".
#	c.	Count the number of rows that have been read into. 
#		the SAS data set.
#		Call the result as numR. Verify that this # is even.
#	d.	Split this single column of rows into two columns of 
#		length numR/2 (1st numR/2 numbers and 2nd 
#		numR/2 numbers). Call the first of these 
#		columns "x", and the second of these columns "y".
#	e.	Create a third column that is a function g(x, y).
#		of the first two columns. The student did not
#		tell me what this is, so let's just pretend it 
#		is  g=g(x,y)=x+y. 

# (We will skip part f in the interest of time. Instead,
# 	we will just create a SAS data set named "test".)

#	f.	Write the result to a file (numR/2 rows and 
#		3 columns--(x,y,g). Use the i/p filename
#		but with an "_op" on the end of the non-extension 
#		part. For example the i/p example filename 
#		"86570_01.txt" would become 
#		"86570_01_op.txt"� for the output. You may 
#		assume the extension is always .txt. Write this
#		to a directory named "op"� that is a subdirectory
#		of the data directory.
*/

/*  Our interest is only in this subset of files:  */
data fnames2;
	set fnames;
	if substr(fname,1,2)="86";
run;

* extract first file name again.;
data _null_;
	set fnames2;
	if _n_=1 then call symput ('firstFile2',fname);
run;

%put &firstFile2;

/*
# Question. Based on the information 
#	you have been given, how
#	do you plan to read in the file
#	and create the SAS data set? Please
#	think about how you would do this
#	before you continue. */



* Questions?; 

*#   *********** Stop 2a ***********;


/* I think this will be harder in SAS than in R:
	1. data on separate records can't naturally be split
		into two groups until we read down far enough
		to see how many records of interest are 
		in the data (all the x's and all the y's).
	2. even then, we can't directly line up x and y. */

/* Here is one approach. It is not very pretty, but 
	it works. And it requires us to only read
	in the original data one time. */

/* First pass: keep (a) the x and y records as separate records 
	(one SAS data set) and (b) a count of how many records 
	(x&y) there are altogether (a second SAS data set)*/
 
data xy (keep=xy) count(keep=n);
	retain eorCount start_read 0 n1 n;
	infile "&dirdata2&firstFile2" termstr=CRLF;
	input test $ @;
	* see if this is an "EOR" record;
	if upcase(test) = "EOR" then do;
		eorCount+1; * count the N of eor's found;
		if eorCount=2 then do;
			n1=_n_; * start counting;
			input; * end reading this line;
			start_read=1;
		end;
		else if eorCount=3 then do;
			n=_n_-n1; * n of xy records;
			if mod(n,2)=1 then do;
				put "Error: n of records, " n ", is odd";
			end;
			else do;
				output count;
			end;
			stop;
		end;
	end;
	if start_read then do;
		input @1 xy; 
			* need @1 because test already read in the var;
		output xy;
	end;
	run;

* So, we now have all the xy data in the xy SAS data set,
  and the nobs of xy data set in the count SAS data set: ;
%p(6, data=xy);
%p(5, data=count); * (only 1 record here)

* Questions?; 

*#   *********** Stop 2b ***********;





/* Second pass. Method used:
		In a SET statement, read in n,
			the total N of records in xy.
		In another SET statement, read in 
			each of n/2 x records, one for each loop
			of the DATA step.
		In a third SET statement,
			skip by the first n/2 records to start
			and then read in each of n/2 y records,
			one for each loop of the DATA step.
		Please recall that different SET statements,
			even for the same SAS data set, function
			*independently* of each other. (*not* true
			for INPUT statements.)
*/

data test;
	keep x y g;
	if _n_=1 then set count; * to get n;
	set xy;
	x=xy; * i-th x in i-th loop;
	if _n_=1 then readin_y=n/2+1; else readin_y=1;
	do i=1 to readin_y;
		set xy;
	end;
	y=xy; * for _n_=1, only n/2 + 1 record has y=xy:
				the earlier records were effectively
				skipped. So i-th y in i-th loop;
	g=x+y;
run;

/* Note that 
	1. There are 2000 records in this xy SAS data set.
	2. We loop through the data step fully 1000 times.
	3. On loop 1001, we read in the x value. But
		when we try to read in the y value, we have
		reached beyond the EOF, so the looping stops.
		In particular, the implicit OUTPUT statement
		at the bottom of the loop is not reached.
	4. As a result, 1000 x,y pairs are written
		to the SAS data set.
*/

* Graph for this one SAS data set;
proc sgplot data=test;
	refline 0;
	scatter x=x y=y;
run;


* Questions?; 


*#   *********** Stop 2c ***********;




/*
#	3. Use a SAS method to read in all the files and handle 
#		these as desired
*/


/*
# Question. How do you plan to do
#	this? Note that this problem
#	is more complex than the 
#	"simple example". In the simple
#	example, we just read in the data 
#	from each file with a simple
#	INPUT statement. Now we are
#	running through two DATA steps to do this.

#  Please: think about how you would do this
#	*before* you continue. */




* Questions?; 

*#   *********** Stop 2d ***********;







/* I decided the easiest conceptual way was to
	write a SAS macro. More specifically:
	1. Write a SAS macro to loop through
		*all* of the code above (both DATA steps)
		for each file.
	2. Create a different SAS data set
		for each loop (each input file).
	3. Then, after this loop ends, 
		concatenate all of these SAS
		data sets. */

%macro readFiles;
	/* This macro assumes 
		1. The SAS data set fnames2 exists and contains the filenames
		2. &dirdata2 exists and contains the directory 
			for the input files. */
			
	* 1. Find the n of files in fnames2 and save
		this in a macrovariable;
	* new code; *notes given so you can see what has changed;
	data _null_;
		set fnames2 end=eof;
		if eof then call symput ('nfiles', _n_);
	run;
	* end new code;
	
	* 2. Loop through the one-file code for all files.
	 	Save the SAS data set for the i-th file as test&i;
	%do i=1 %to &nfiles; * new code;
		data _null_;
			set fnames2;
			* select &i-th file, store name in macrovariable;
			if _n_=&i then call symput ('iFile2',fname); * new code;
		run;

		data xy (keep=xy) count(keep=n);
			retain eorCount start_read 0 n1 n;
			infile "&dirdata2&iFile2" termstr=CRLF; * new code;
			input test $ @;
			if upcase(test) = "EOR" then do;
				eorCount+1;
				if eorCount=2 then do;
					n1=_n_;
					input;
					start_read=1;
				end;
				else if eorCount=3 then do;
					n=_n_-n1;
					if mod(n,2)=1 then do;
						put "Error: n of records, " n ", is odd";
					end;
					else do;
						output count;
					end;
					stop;
				end;
			end;
			if start_read then do;
				input @1 xy;
				output xy;
			end;
			run;
			
		data test&i; * new code;
			length fname $30 ; * new code;
			retain fname "&iFile2" fnameIndex &i; * new code;
			keep fname fnameIndex x y g; * new code;
			if _n_=1 then set count;
			set xy;
			x=xy;
			if _n_=1 then readin_y=n/2+1; else readin_y=1;
			do i=1 to readin_y;
				set xy;
			end;
			y=xy;
			g=x+y;
		run;
	%end;

	* Concatenate all of the files;
	* new code;
	data fileList2;
		set %do i=1 %to &nfiles; test&i %end;;
	run;
	* end new code;
%mend readFiles;

options mprint;
%readFiles;
* please see the SAS log--make sure you see what
	is happening;
* (This example should make it *very* clear that macros
	generate code!);
options nomprint;

%p(5)

* Questions?; 

*#   *********** Stop 2e ***********;



* #### 2. Reading files from the Web ####;




/* ##    Simple Example     ##

# In this example, the web page itself is pure text 
#	(no HTML).

# This data set is based on abalone measurements.
# Data is from http://archive.ics.uci.edu/ml/datasets/Abalone 
#	(web links in this section: accessed 11/28/15).

# Interest in this data set was in predicting age from physical 
#	measurements. 

# The actual web page of interest here is
# 	http://archive.ics.uci.edu/ml/machine-learning-databases/abalone/abalone.data

#  This link is just simple data (no html code--we will consider 
#	the more complex case with html code in the next example). */

* We use the url option in the filename statement;
* format:
	FILENAME fileref URL 'external-file' <url-options>; 
filename uConnW "&dirdata.abalone.data";

data abalone;
	infile uConnW dsd; * do not use termstr=CRLF--file is from a UNIX system;
	input Sex $ Length Diameter Height WholeWgt ShuckedWgt VisceraWgt ShellWgt Rings;
run;

%p(10)



ods graphics / width = 8in height = 6in;
proc sgscatter data=abalone;
	matrix Length Diameter WholeWgt Rings/ 
		diagonal=(histogram kernel);
run;

* We could reorder Sex (make it integer valued,
	and then use PROC FORMAT to get the 
	names we want...). But in the interest of time,
	we will only use PROC FORMAT here;

proc format;
	value $ sexform
		"I"="Infant" "F"="Female" "M"="Male";
run;

ods graphics / width = 8in height = 3.5in;
proc sgpanel data=abalone;
	panelby Sex /columns=3;
	scatter x=Diameter y=Rings / group=Sex;
	format Sex $sexform.;
run;




* Questions?;



*********** Stop 5 ***********;
* (no Stop 3 or 4. Some missing Stop's later as well);



ods graphics / width = 8in height = 6in;
proc sgscatter data=abalone;
	matrix Length Diameter WholeWgt Rings/ 
		diagonal=(histogram kernel);
run;

* We could reorder Sex (make it integer valued,
	and then use PROC FORMAT to get the 
	names we want...). But in the interest of time,
	we will only use PROC FORMAT here;

proc format;
	value $ sexform
		"I"="Infant" "F"="Female" "M"="Male";
run;

ods graphics / width = 8in height = 3.5in;
proc sgpanel data=abalone;
	panelby Sex /columns=3;
	scatter x=Diameter y=Rings / group=Sex;
	format Sex $sexform.;
run;




* Questions?;



*********** Stop 5 ***********;
* (no Stop 3 or 4. Some missing Stop's later as well);

















*##    Web connection: More complex Example     ##;

/*
# To help you see what this example is about, please point
#	your browser to this web site (accessed 11/24/13)
# http://money.cnn.com/magazines/fortune/best-companies/2013/list/

# To see the actual text, you need to "View Source".

# In Chrome or Firefox, you can "View Source" by entering CTRL-U
#	(creates a new tab on my PC).
#	In I.E. you can click on Page...View Source (creates
#	a new window on my PC).


#	What "Wegmans" really look like on this page:
#  the HTML that created the page in the 11/24/13 access. 

#     <tr>
#       <td class="listCol1">5</td>
#       <td class="listCol2"><a href="/magazines/fortune/best-companies/2013/snapshots/5.html">Wegmans Food Markets, Inc.</a></td>
#       <td class="listCol3">43,927</td>
#       <td class="listCol4">8.3%</td>
#     </tr>

# Our interest is on extracting the data from these sets of 4 records. */

 

*  Question: Think about how you might do this in SAS;

*  assume that we can use the filenames's url option to read 
	in all of the data, and then process it.

* You may also assume that the html patterns you see 
	for Wegmans will repeat for all 100 companies.



*********** Stop 6 ***********;



/* 
#	we will likely use a two-step process:
#	1. Find a way to *locate* the 4 records for each 
#		of the 100 companies.
#	2. From these 4 records, *extract* the 4 pieces of info:
#		Rank, Name, N.Employees, JobGrowth



#	1. Find a way to locate the 4 records for each 
#		of the 100 companies.

#  Well, SAS has regex, so we can just mimic the R approach.

# For finding these sets of 4 records:
#	b. Search on something like "listCol\d". 
#		This would give all 4 of the record numbers.

# A quick check of the page shows that "listCol"
#	also appears in table headers. However, these have "th"
#	in their record instead of "td", so a simple regex will
#	succeed in finding only the records we care about.

# So, let's create the fileref, then read in the records: */


/*****       For PC SAS and SAS Studio users       *******/

filename uConn2W "&dirdata.bestcomps2013.htm";

* Read in the entire web page, but save only the records of interest;
data best2;
	keep string;
	if _n_=1 then pattern = prxparse("/td(.)+listCol/");
		* remember, this is Perl regex. We surround the regex with /'s.;
	retain pattern;
	infile uConn2W truncover; * again, do not use termstr=CRLF here;
	input string $CHAR256.;
	pos=prxmatch(pattern,string);
	if pos gt 0;
run;

* please try to see what is going on here--
    run one %p(9) at a time;
%p(9);

ods html close;
ods listing;
%p(9);  * look at log here--as you should always do! ;

ods listing close;
ods html;
%p(9);

* (This will be re-explored soon...) ;

* Questions?;



*********** Stop 7a1 ***********;









/* Notes:
	1. We want to read each entire line of 4 into different variables.
	2. To do this in SAS, you need to know the length of
		the longest line (or an upper limit on it).
		I found out the longest line on the first try of 
		 the DATA step. It is reported in the SAS log.
	3. You then need to set your string var to 
		be that length (or longer).
	4. You also need to use the TRUNCOVER option on
		the INFILE statement. If you don't, SAS will
		try to read past the end of the line on 
		"shorter" lines, leading to:
			NOTE: SAS went to a new line when INPUT statement 
				reached past the end of a line.
*/

/* Technically, we could do the following DATA steps all
	within the one DATA step above. However, it seemed
	to take a long time (15 secs?) to execute the
	DATA step above, so it seems better to get
	these records into a SAS data set first. 
	
	Also, it's often easier for data checking 
	to run a few small steps instead of one big one. */

* Questions?;



*********** Stop 7a2 ***********;









/*
#	2. From these 4 records, extract the 4 pieces of info:
#		Rank, Name, N.Employees, JobGrowth

# A reminder. Here is an example of what we have left
#       <td class="listCol1">5</td>
#       <td class="listCol2"><a href="/magazines/fortune/best-companies/2013/snapshots/5.html">Wegmans Food Markets, Inc.</a></td>
#       <td class="listCol3">43,927</td>
#       <td class="listCol4">8.3%</td>



*/

 



* Recall, we really need to see what is contained in best2 itself, so:;
proc print data=best2 (firstobs=17 obs=20);run;

/* However, PROC PRINT does not "work correctly" here
	on PC SAS, at least with its default settings.
	(It works fine on SAS Studio?).

	That is, in PC SAS, PROC PRINT is not displaying the actual contents
	of the SAS data set. The reason is that output that goes
	to the Results Viewer translates the html code.

	So what you see in that window is similar to what 
	is displayed on a web browser. This is not what 
	we want to see!

	To see this somewhat better, we can
	change to ODS listing (we will discuss ODS below). 
	This will output the results to the SAS Output window: */

/* */
data best2a4;
	retain re1 re2 re3;
	drop re1-re3;
	if _n_=1 then do;
		re1=prxparse("#>(.)+<#");
		re2=prxparse('s/<a(.)+\">//');
		re3=prxparse("s/<\/a>//");
*" (<--I put the double quote here only to make this look better in Notepad++);
	end;
	set best2;
	call prxsubstr(re1,string,start,length);
		/* start is like position in earlier example.
			length is the length of the match */
	if start gt 0 then string = substrn(string,start,length);
	* eliminate the extra text we found in going from best2a1 to best2a2;
	call prxchange(re2,-1,string,string,r_length,trunc,n_of_changes);
	* eliminate the extra text we found in going from best2a2 to best2a3;
	call prxchange(re3,-1,string,string,r_length,trunc,n_of_changes);
	* eliminate the 1st and last char's in going from best2a3 to best2a4;
	string=substr(string,2,length(string)-2);
run;


* Questions?;



*********** Stop 7d ***********;
*If you are confused by this DATA step, just continue...;






/* Confused? If you don't see what the previous DATA step is doing, here is 
   a repeat of that data step, but now including output written to
   the log for some records to help you see what is happening. */

data best2a4details;
	retain maxRecsToLog 20 re1 re2 re3 ;
	   * maxRecsToLog -- the max N of records written to the log--feel free to change this;
	drop maxRecsToLog re1-re3;
	if _n_=1 then do;
		re1=prxparse("#>(.)+<#");
		re2=prxparse('s/<a(.)+\">//');
		re3=prxparse("s/<\/a>//");
*" (<--I put the double quote here only to make this look better in Notepad++);
	end;
	set best2;
	call prxsubstr(re1,string,start,length);
		/* start is like position in earlier example.
			length is the length of the match */
	if start=0 then do; * I rewrote the start logic, but only to make it clearer;
	   put "Error. No match found in " _n_= string=;
	   stop;
	end;
	if _n_ <= maxRecsToLog then do;
	   put;
	   put "string input:  " string=;
	   put "subset to keep for re1:  " start= length=;
	end;
	* eliminate the text that is not between ">" and "<";
	string = substrn(string,start,length);
	if _n_ <= maxRecsToLog then put "string update re1:  " string=;
	* eliminate the extra text we found in going from best2a2 to best2a3;
	call prxchange(re2,-1,string,string,r_length,trunc,n_of_changes);
	if _n_ <= maxRecsToLog then put "string update re2:  " string=;
	call prxchange(re3,-1,string,string,r_length,trunc,n_of_changes);
	* eliminate the 1st and last char's in going from best2a3 to best2a4;
	if _n_ <= maxRecsToLog then put "string update re3:  " string=;
	string=substr(string,2,length(string)-2);
	if _n_ <= maxRecsToLog then put "string update final:  " string=;
run;

/* (If you want to verify that the two SAS data sets are the same
   run the next line of code:)
proc compare data=best2a4 compare=best2a4Details;run;
*/

/* Note on regex's here:
	1. In Perl the forward slash (/) is usually used as a
		delimiter. However, other delimiters may be used:
		in re1, I used the hash (#) as a delimiter 
		to show you an example.
	2. In re3, I wanted to use "<a/>". However, the "/"
		has a special meaning in Perl, so I needed to
		escape it with a "\". (This does not have
		a special meaning in plain regex, so "/" 
		was not escaped in R.)*/


* Questions?;




*********** Stop 7e ***********;




/* Finally, I had to get rid of the comma in the 3rd value and 
	the percent sign in the 4th value, but only in those locations. 


	So, my plan is:
	1. get rid of the commas and percent signs first, within
		the variable string.
	2. reshape using a do loop, translating to numbers
		along the way.

	 Instead, I will list 
	out any problem cases on the SAS log. */

/* I will also use the nice formatting and
	labeling features of SAS */
	


data best2a;
	retain re1 re2;
	retain Rank Name N_Employees JobGrowth; * to define data set order;
	keep Rank Name N_Employees JobGrowth;
	format N_Employees comma8. JobGrowth percent7.1;
	label N_Employees="N of Employees" JobGrowth="Job Growth";
	length Name $80;
	if _n_=1 then do;
		re1=prxparse('s/,//');
		re2=prxparse("s/%//");
	end;
	do i=1 to 4;
		set best2a4;
		if i=1 then Rank=input(string,f8.0);
		else if i=2 then Name=string;
		else if i=3 then do;
			call prxchange(re1,-1,string,string,r_l,tr,n_c);
			N_Employees=input(string,f8.0);
			if N_Employees=. then put "****: N_Employees missing due to string=" string;
		end;
		else do; * i=4;
			call prxchange(re2,-1,string,string,r_l,tr,n_c);
			JobGrowth=input(string,f8.0)/100;
			if JobGrowth=. then put "****: Jobgrowth missing due to string=" string;
		end;
	end;
run;





/*
#### 3. Creating Nicer Output ####



SAS has very extensive features for
writing output in different formats.

This is handled in SAS by ODS--
its Output Delivery System.

You have actually been using ODS
every time you write O/P to the
Results Viewer!

We will only briefly look at some ODS
features.

SAS also has the ability to extract
	subsets of this output, but we
	will not discuss that feature
	in this course.
	(R's abilities here are extensive
	and use standard methods, so they 
	seem more natural to me.)
*/

	
/*
By default, the o/p in the windowing
environment in SAS (Windows or UNIX)
is html.

Here are some ways to use this, or
other, output features.
*/


/* (See TLSB, V5, p. 151 for a picture.)
ODS creates output with this route:
1. data from PROC
2. passes through a "table template" (shape)
3. passes through a "style template" (font, colors, ...)
4. then output is produced.
*/

* Ideas of style templates--at least their names:;
proc template;
	list styles;
run;

* For these examples, let's use a subset of
	the best2a data.;

data test;
	set best2a;
	if _n_=8 then stop;
run;

ODS html5 file="&dirOUT.SAStestx.html";
	* default style=Htmlblue;
	title 'First 7 records of best2a';
	proc print data=test noobs;run;
	title;
	options nocenter;
	proc print data=test noobs;run;
ODS html5 close; 

%put &dirOUT;



/* However, ODS offers *many* output options,
	including:
	1. Listing (plain text)--we already used this.
	2. RTF (Rich Text Format--great for Word)
	3. PDF
*/

/* We will only try RTF here */

ODS rtf file="&dirOUT.SAStestx.rtf" bodytitle;
	options center;
	title 'First 7 records of best2a';
	proc print data=test noobs;run;
	title;
	options nocenter nonumber nodate;
	proc print data=test noobs;run;
ODS rtf close; 


/* changing styles and including graphs,
   even within one output file. */
ODS rtf file="&dirOUT.SAS2testx.rtf" bodytitle style=banker;
	options center;
	title 'First 7 records of best2a';
	proc print data=test noobs;run;
	ods graphics / width = 8in height = 2.75in;
	proc sgscatter data=best2a;
		plot N_Employees*Rank JobGrowth*Rank JobGrowth*N_Employees/columns=3 ;
	run;
	title;
	options nocenter;
	ods rtf style=rtf;
	proc print data=test noobs;run;
	ods graphics / width = 8in height = 2.75in;
	proc sgscatter data=best2a;
		plot N_Employees*Rank JobGrowth*Rank JobGrowth*N_Employees/columns=3 ;
	run; 
ODS rtf close; 







	
	
/* One more example...

	Let's look at the distribution of N_Employees
	using the last example.

	As usual, in SAS we can use PROC
	format to do the breaks. 
*/

* "try 3";
proc format;
	value nEesF
		1000-4999="[1K,5K)"
		5000-9999="[5K,10K)"
		10000-49999="[10K,50K)"
		50000-99999="[50K,100K)"
		100000-499999="[100K,500K)"
		500000-high=">500K"
	;
run;

* Trying out two more styles...;
title "Distribution of N of employees at top 100 companies.";
ODS rtf file="&dirOUT.SAStest2x.rtf" bodytitle style=Statdoc;
	options nocenter nonumber nodate;
	proc freq data=best2a;
		tables N_Employees/nopercent nocum;
		format N_Employees nEesF.;
	run;
	ods rtf style=Statistical;
	ods noproctitle;
	proc freq data=best2a;
		tables N_Employees/nopercent nocum;
		format N_Employees nEesF.;
	run;
ODS rtf close; 

/* Note:
	1. The ODS option noproctitle seems like 
		one you would normally use.
	2. There may be a way to later add more
		information to a output file (like
		R's append=TRUE). However, from what
		I know, after you close an output file
		you cannot reopen it and add additional
		output to it.
*/


* As in R, you should be able to see that if you plan to do
	this kind of work on a regular basis, you might want to
	write a macro to do it.;



	


* Questions? If not, you have completed the SAS portion of the class!;




*********** Stop 8d ***********;
















