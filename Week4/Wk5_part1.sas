/****** This material is on graphical methods using SAS.


****** Making good graphs is often an interactive,
****** high-feedback process: 
******	1. Make an initial graph
****** 	2. Decide to try some different
****** 	   versions of it until it 
****** 	   presents the (often complex)information 
****** 	   quickly, yet accurately.
****** 	3. Or, find features in one graph
****** 	   that leads to create another graph...

"ODS Graphics" in SAS can make *certain kinds* of graphs 
very easily (once you learn its syntax, of course). However, SAS
seems much less flexible than R in creating graphs.

For this reason, I don't believe SAS is very well suited for this
interactive, high-feedback process. But let's see what you think.





/*Create formats used for dmin_formats SAS data set.
 */
%let dirdata=/folders/myfolders/;
libname perm "&dirdata";
PROC FORMAT;
	value cut 
     1 = "Fair"       2 = "Good" 
     3 = "Very Good"  4 = "Premium"    5 = "Ideal";
	value color 
     1 = "D"   2 = "E"  3 = "F"  4 = "G" 
     5 = "H"   6 = "I"  7 = "J" ;
	value clarity 
     1 = "I1"   2 = "SI2"   3 = "SI1"   4 = "VS2" 
     5 = "VS1"  6 = "VVS2"  7 = "VVS1"  8 = "IF" ;
run;

/* Both dmid.sas7bdat and dmid_formats.sas7bdat are files
  that correspond to permanent SAS data sets. Those are the SAS data sets 
   we'll be using this week.*/
   
/* These are the dmid SAS data sets. Note that
	dmid uses cut/color/clarity as character variables,
	while dmin_formats uses these as numeric, formatted
	variables. */

title 'dmid';
proc print data=perm.dmid (obs=5);run;
proc contents data=perm.dmid;run;

title 'dmid_formats';
proc print data=perm.dmid_formats (obs=5);run;
proc contents data=perm.dmid_formats;run;
title;

/* The formatted version will be much more useful to us, because
	it will preserve that natural order of cut and clarity */

* We will start with the sgplot function;
title "Middle-size data: N=10,000";
proc sgplot data=perm.dmid_formats;
	scatter x=carat y=price;
run;

/* Note that the title statement works for this
	high-resolution plot */

/* The symbols and colors defaults are based are 
	the "ODS style template" you are using. Here
	"ODS" stands for "Output Delivery System"--a 
	SAS topic that we will cover later in the course */
	
/* By the way, it is possible to extract the n of rows in 
	the SAS data set and use that value directly, 
	instead of typing in "10,000". We will see how 
	to do this when we look at SAS macros. (However,
	it is much simpler to do this in R.) */
	

/*   *********** Stop 1 ***********/




data dmid2; 
	set perm.dmid_formats;
	log_carat=log10(carat);
	log_price=log10(price);
	label log_carat="log(carat)" log_price="log(price)";
run;

/* Each graph is generated on its own. (Unlike R, the idea 
of "rewriting to the same graphics window"--and overwriting
the earlier graph--does not exist in SAS.)  */

title "Using logs";
footnote  justify=left color=red height=10pt "(Note axis names)";
proc sgplot data=dmid2;
	scatter x=log_carat y=log_price;
run;
footnote;
* Note that additional features can be added to footnote (and to title);

title "Using log scales";
proc sgplot data=perm.dmid_formats;
	scatter x=carat y=price;
	xaxis type=log ;
	yaxis type=log;
run;

/* The correct plot is made--but with a very poor choice of axis labels.
	The algorithm is spacing the labels equally on the *linear* scale.
	This does not make much sense. */

* Now, it is possible to create your own labels on the original scale;
title "Custom axis label: works partially on original scale";
proc sgplot data=perm.dmid_formats;
	scatter x=carat y=price;
	yaxis values=(500 1000 2000 5000 10000 15000 20000); * or (num1 TO num2 BY increment);
run;

/* it is also possible to create your own labels on 
    the log scale in PC SAS, at least in version 9.4.
	   Note: it was *not* possible to create your own labels on 
    the log scale in SAS 9.3. I think this is an indication
    that SAS is still doing work on these graphic PROC's 
    to get them to run acceptably. */
title "Custom axis label (works in SAS 9.4, not 9.3).";
proc sgplot data=perm.dmid_formats;
	scatter x=carat y=price;
	xaxis type=log; 
	yaxis type=log values=(500 1000 2000 5000 10000 15000 20000);
run;
title;


* Next, use PROC SGSCATTER to make *panels* of plots;
proc sgscatter data=dmid2;
	plot price*carat log_price*log_carat;
run;

/* In sgscatter, all plots are given the same attributes by default. It
	it possible to override this, but it seems that this is very awkward.
 */
	
/* There is a way to change the plot size, and panel shape.
	See TLSB. */
	
* Any questions?



*   *********** Stop 2 ***********






* Based on the first graph, it seems reasonable to look
*	at the distribution of carats for a bit;

proc sgplot data=dmid2;
	histogram carat;
run;
/* Note: we have now used PROC SGPLOT for (1) scatter plots and (2) histograms.*/
 
/* Note: For *histogram* the default is percent, not counts. 
   And a default fill color is used*/

/* Aside on styles. "Styles" are a collection of default colors,
	symbols, and so on that are intended to make graphs in a more
	automatic way. Here are some examples. */

/* Note: these examples work for PC SAS. 
	These have *not* worked for me in SAS Studio:
	when I run the ods statement, I receive an 
	"Insufficient authorization" error. These also
	do *not* work in the SAS Web Editor. */

/* To create HTML output in SAS studio, its recommended to use ODS HTML 5.
Between ODS HTML5 statement and ODS HTML5 closed, the graphical result can be output to
an html, or pdf, or rtf up to your choice. An alternative on SAS studio will be going to results tab
and manually export the result. */
ODS HTML5 path='/folders/myfolders/' file="myplot.html"
          style=default;
proc sgplot data=dmid2;
histogram carat;
run;
ods html5 close;
/* For some reason, this graph is not the same as the earlier one. 
   What style was used for that? I would think it would have
   been ... "default"! And I don't know how to query SAS to find
   the current style that it is using. (Solutions, anyone?). */

/* ODS example using macro path variable dirdata with harvest style*/
ods html5 path="&dirdata" file="myplot_harvest.html" style=harvest ; 
proc sgplot data=dmid2;
histogram carat;
run;
ods html5 close;
ods html5 path="&dirdata" file="myplot_harvest.html"  style=journal; 
proc sgplot data=dmid2;
histogram carat;
run;
ods html5 close;
/* This is very nice if you like one of the styles provided by SAS. If not, 
	you need to do a reasonable amount of work to create your own style,
	or to try to override the style in use.

End of Aside on styles */



* Questions (same as last week...):
*	1. What happened to the gaps at certain carat sizes?
*	2. Any ideas on handling this?


*   *********** Stop 3 ***********;
*   *********** Stop 4 ***********;









/* Getting more control in a graph. 
	Determining the splits, and more. An example. */
proc sgplot data=dmid2;
	histogram carat/
		BINSTART= 0.1   /* start and width define the breaks */
		BINWIDTH= 0.1
		BOUNDARY= LOWER 
		nofill
		scale=count; 
run;


/*
* It *looks* like there may be a some jumps at 1.0, 1.5,...
* 	but the graph should be enhanced to help the user.

* At first I didn't have *any* idea see how to enhance the histogram in SAS.

* However, a fundamental restriction in SGPLOT (and ODS Graphics more generally)
	is the following: while we can 
	use more than one statement to draw on the plot, **all of the
	data must come (a) from the same SAS data set, and (b) from the same rows**
	(At least this is how it seems to me).

* To try to work within this restriction to get asterisks on the histogram,
	I then tried the following--Please try to figure out what I was trying to
	do here;
*/
	
* These are the midpoints and counts that I would like to graph. This 
	is from the full dmid data set (n=10,000) ;
data addhist;
	input carat2 freq2;
	datalines;
0.55 1204
1.05 1338
1.55  526
2.05  239
2.55   13
3.05    6
;

* I then added these to the original data set, "on the top";
data addhist2;
set  addhist dmid2;
run;
proc print data=addhist2 (obs=8);run;

* So, I have now put all the data into the same SAS data set
	(Yes, this seems very awkward...) ;

* Next, I'll try to use two statements to get what I want: 
	a histogram and then red asterisks;

proc sgplot data=addhist2;
	histogram carat/
		BINSTART= 0.1 		BINWIDTH= 0.1
		BOUNDARY= LOWER	nofill	scale=count;
	scatter x=carat2 y=freq2/markerattrs= (symbol=asterisk color=red);
run;

* However, this yielded the following error message:
 ERROR: Attempting to overlay incompatible plot or chart types. '
 
*  Next, I tried to see is there was a *datalabel* option. We will
	see this option used a little later to place text in a graph.
	Well, I find that this option is available with the SCATTER statement--
	but not with the HISTOGRAM statement.
	
* At that point, I gave up. But even if I have found a way to do this,
	it would not fall under a consistent, broader, set of methods, but 
	rather a trick to get SAS to do what I want. At least
	this is how things appear to me. Solutions, anyone?;
 
/*** Saving a graph

In SAS PC, just right-click on the graph. You can copy/paste into 
	Word, for example, or save as a picture in either png or bitmap
	format (png is usually better).
In SAS Studio, you can also right-click on the graph. You can then
	click on "Copy Image"--but pasting that copy does not seem to work.
	(In fact, I don't think that "Copy Image" even makes a copy.)
	However, "Save Image As ..." and then saving as a png file, does
	work. You can also click the "W" icon at the top (under "Log")
	to save as an RTF file. However, when I did that, the plot
	was in black-and-white.
In SAS Web Editor, I have not had much luck with direct copy/pasting.
	1. If I right-click on the graph, then click Copy Image,
		and then paste into Word, I just get a blank image.
	2. However, if I click on the icons under Code|Log|Results, then
		"Download results as rtf" and the open that file in 
		Word, and then copy/pasting into Word works fine.
	3. Or (easier, I'd say), just use the Windows snipping tool--but
      I think just this probably yields the inferior bitmap format.

* You may be able to save the graphs with SAS code. However, all
	I saw in the sgplot documentation was how to save the
	code in SAS's GTL (Graph Template Language) to recreate
	the graph. */





*   *********** Stop 5 ***********






* OK, back to our histogram....;


/* Aside on Histograms for SAS data sets

* Suppose we want a histogram for each numeric variable in the data set
	and we also want frequency charts for each "factor" (or discrete, or
	character, variable).

* I don't think this can be done directly with ODS Graphics in SAS.

However, it *is* possible to make a "matrix plot" of both
	1. All pair-wise scatter plots (on the off-diagonals)
	2. Histograms (on the diagonals)
for numeric variables.

I tried this with the obvious numeric variables price and carat,
as well as the discrete variables clarity and color (which are 
numeric but with formatted values): */

proc sgscatter data=perm.dmid_formats;
	matrix price carat clarity color/ 
		diagonal=(histogram kernel);
run;

/* (Here, I also added a smooth density curve (kernel option) 
	to each histogram )*/
	
/* You can see that 
	a. The plot works fine for the true numeric variables price and carat
	b. It runs, but makes less sense for, the discrete variables
	c. No values are shown on the axes, so it it hard for me to make sense
		of the histograms or scatter plots. */


/* SAS note:
	1. Proc sgplot only makes *one* plot on a page, but it can make 
		*many* different kinds of plots (scatter, histogram, boxplot, 
		vertical bar charts, ...).
	2. Proc sgscatter can make *many* plots on a page, but it really 
		makes only *one* kind of plot: a scatter plot. (Well, it can 
      also make histograms, as shown in the last graph. But this 
      is a very special case). */

* End of Aside on Histograms for SAS data sets;



* Question (again, from last week):
* However, there is a possible shortcoming to using a 
* 	histogram here. Any ideas? 
*	And any ideas on what to do about this?


*   *********** Stop 6 ***********


* By their nature, histograms tend to group, or bin, values

* However, instead of binning the carat data to get frequencies, 
*	perhaps we should consider using the frequency
*	for *each distinct level* of carat.

* Let's  get the frequencies ourselves and 
*	then plot them directly.

* Question: how can we obtain the individual frequencies in SAS?



*   *********** Stop 7 ***********;



















* with PROC FREQ, of course. (Other PROC's could also be used.)
But we need to save the output counts;


proc freq data=dmid2 noprint;
	tables carat/nocum nopercent 
		out=caratTable1 (rename=(carat=Carat COUNT=Count));
run;
* (I made an attempt here to rename some variables to get a nicer look, 
	but this did not work. Basically, the names are not case-sensitive ...);

proc print data=caratTable1 (obs=5);
run;

proc sgplot data=caratTable1;
	needle x=carat y=count;
run;
* (However, COUNT was automatically assigned a label ...);



*   *********** Stop 8a ***********








* Let's do a bit more playing around to get a nicer graph, 
*	before we do some other work:

* cut off highest values (not interesting here) to 
*	get better resolution:;

proc sgplot data=caratTable1;
	needle x=carat y=count;
	xaxis min=0.2 max=2.2;
run;



* Next, let's see *visually* which ones stand out. This is 
	subjective, but useful for communication. 
* In SAS, I don't believe it is possible to interact with
	a graph to find or highlight these values. 
* So let's do this instead--label the highest 20
	frequencies. To do this, we will need a sort/data/sort/merge
	sequence first.;

* We can find the highest frequencies, 
	with a proc sort ... by descending carat, then keeping only the first 20
	with a data step, and then doing another proc sort to put these in carat order, 
	and then do a proc print:;

* 1. sort to prepare for the next step;
proc sort data=caratTable1 out=carat20;
	by descending count;
run;
proc print data=_last_ (obs=5);run;

* 2. select the top 20 counts and create a character
	variable to hold the carat values;
data carat20;
	set carat20;
	if _n_=21 then stop;
	length caratc20 $4;
	caratc20=put(carat,4.2);
run;
proc print data=_last_ (obs=5);run;

* 3. sort by carat for the merge step. Also print out;
proc sort; by carat;run;
proc print; run;


* 4. merge this with the earlier data. This will 
	be used to create the labels. Note that 
	caratc20 = the carat value for the top 20 and is "" otherwise;
data caratTable2;
	merge caratTable1 carat20;
	by carat;
run;
proc print data=_last_ (obs=35);run; * print out a subset;


/* Note that we again using a trick to get what we really want.
	The trick is to create another variable in our SAS data
	set. Remember: the only data we can use in these PROC's
	must come (a) from one SAS data set and (b) from the same rows.
	(I say "same rows" because we could use a WHERE statement to 
	restrict the rows of the original SAS data set. But the same 
	WHERE statement applies to all of the graphing statements
	in the PROC. */
	
* redraw the graph with these labels;
title "Distribution of carats (up to 2.2 carats)";
title2 "with some key carat values highlighted.";
proc sgplot data=caratTable2;
	needle x=carat y=count/datalabel=caratc20 datalabelattrs=(color=red);
	xaxis min=0.2 max=2.2;
run;
* Note that labels are really drawn for *all* the points--however,
	most of the labels are "";

* Again, to me this seems like a pretty awkward way (many steps, and 
    using tricks) to what should be a simple and natural task;


*   *********** Stop 8b ***********




* For discrete variables, we can use vbar (vertical bar chart)
	or hbar (horizontal bar chart);

title 'Frequency counts for clarity';
proc sgplot data=dmid2;
	vbar clarity;
run;

title 'Mean price for each clarity level';
proc sgplot data=dmid2;
	vbar clarity/response=price stat=mean; * options are freq, mean, sum;
	format price dollar6.0;
run;

* Note that this is nicely ordered because I used
	the SAS data set that has clarity as a numeric variable
	with numbers 1-8. If I had used the data set with
	clarity as a character variable, the ordering would be
	alphabetical (default). This is shown in the next graph: ;
	
title 'Mean price for each clarity level';
title2 'when clarity is a character variable';
proc sgplot data=perm.dmid;
	vbar clarity/response=price stat=mean;
	format price dollar6.0;
run;


*   *********** Stop 8c ***********






* Let's next look at some of the relations between other variables
* Let's see how the distribution of price is affected by cut
* 	and by clarity.

* Remember: Tukey's boxplots. 
*	These are a way to represent a distribution in one dimension,
	so we can use another variable on the second dimension.

* Boxplots of price, vs. cut and clarity. (The diamond represents the mean.);

title;
proc sgplot data=dmid2;
	vbox price/category=cut;
	format price dollar6.0;
run;


proc sgplot data=dmid2;
	vbox price/category=clarity;
	format price dollar6.0;
run;

*   *********** Stop 8c ***********;








* As before, this looks strange. For example, the diamonds with the
*	worst two clarity levels have the largest
*	median prices.

* (Question: how did the clarity values get to be in the correct order?);


*   *********** Stop 9 ***********;






/**** Bringing in a third dimension;

 It is very common is statistical analysis that the problem
	to be solved is multidimensional...
	Graphically, we will need to add one or more dimensions
	to our graphs.

 There are several ways to bring in a 3rd dimension to a graph
	based on one or more additional variables...;

 We will examine two of these: colors and side-by-side graphs.

 SAS too has many ways to select colors. See SASHelp_MarkersAndColors.doc for details*/


/* Note:
 Colors in SAS work as "group by group". This can be made equivalent
	to point by point, but the thinking involved seems different to me */

	
* Back to the problem at hand

* Remember: The 1 represents a diamond with a good number of inclusions 
*	(imperfections), while 8 represents a nearly perfectly clear diamond.

*	Recall that in R, I wanted the clearest diamonds to have the 
	lightest shade of gray, and the least clear diamonds the darkest shade.

	In SAS, when we group by clarity, as we will soon see, this is what happens: 
	"Each group is represented by unique visual attributes derived from the 
	GraphData1... GraphDatan style elements in the current style."

	That is, the current style determines what colors, for example, will
	be used with the different groups. If we want to change the colors,
	it appears that we will need to change the style. As I have noted
	before, this does not appear appear simple to do;



* Questions?;

/*   *********** Stop 10 ***********/











* For the third dimension, I will add carat back in. Because
*	carat and price are continuous, but clarity is discrete,
*	I will naturally use clarity for the color:

* However, I am going to use the existing styles (I will
	not try to recreate the gray scale by creating a new style);

title "First try at grouping:clarity by color";
proc sgplot data=perm.dmid_formats;
	scatter x=carat y=price/group=clarity;
	xaxis type=log ;
	yaxis type=log;
run;

* Well, the grouping listing seems to be in the wrong order! Yes? 
	It does not seem to be in any kind of reasonable order, in fact.
	So, I added another option;

title "Second try at grouping:clarity by color";

proc sgplot data=perm.dmid_formats;
	scatter x=carat y=price/group=clarity grouporder= ascending;
	xaxis type=log ;
	yaxis type=log;
run; 

* This worked. It seems that the grouping listing is
	by default in order of the data!! (This is not mentioned in the online
	documentation. This is a *very* odd choice for a default.)

	However, ODS graphics (like ggplot2) automatically adds a legend.

* Once again, we can see that "Price increases with clarity when we adjust for carat"
 (Remember, the opposite pattern seemed to occur in the boxplot of price vs. clarity)

* Questions?;


/*   *********** Stop 11a ***********/










/* Other ways to present these results.

 One of the problems here is that we have N=10,000 values, so a lot of these
	are probably overlapped or hidden.

 To avoid this to some extent, we would like to produce separate graphs for each
	level of clarity

 The SGSCATTER procedure is the natural choice to use here.
	However, with this procedure, it is only possible to produce multiple panels
	on one graph, *if* we use different x or y values. Here is an example: */
	
title;
proc sgscatter data=dmid2;
	plot price*table (price table x)*carat;
run;

/* By the way, a desired option has disappeared when we move from SGPLOT to 
	SGSCATTER. We can no longer make plots on the log scale.
	And even if we could, it would have to be applied to *all* plots (based on the 
	syntax that appears for all other options). The 
	same is true for the min and max values of a scale, and more.

	We can also do grouping, but the grouping is only done *within* a panel.
	Let's try to do this with the "group=clarity grouporder= ascending"
	options from sgplot: */


/* We get
		ERROR: Variable ASCENDING not found.
		WARNING 1-322: Assuming the symbol GROUP was misspelled as grouporder.
   So "grouporder" is no longer an option! Very strange... So let's try again */
   
proc sgscatter data=dmid2;
	plot price*table (price table x)*carat/group=clarity;
run;

/* Well, this produced a plot. However, the legend is 
	once again based on the data order. Not desirable. We could "fix" this
	by sorting the data by clarity, but this is not very satisfactory.*/
	
/* It would be possible to come a little closer to the plot we made in R:
	a 3x3 layout, with 8 plots. One plot was made for each level of clarity,
	with a different color (shade of gray) in each plot, but with the same,
	overall, regression line.
  
	To do this, we could create a new price variable and a new carat variable for 
	each level of clarity. For example price_I1 and carat_I1, price_SI2 and carat_SI2, 
	and so on. For example, price_I1=price when clarity=I1 and price_I1 = . (missing 
	value) otherwise.
	
	Remember, this is needed because we need to put different y and/or x variables on
	different plots to get different plots made.

	Even here, however, we still could not have different colors appear in the different
	panels */

/* I suppose you could use proc sgplot 8 times, one for each level of clarity; choose
	a different color for each proc; and then copy paste 8 times into Word and arrange 
	this into a 3x3 Word table. This would be error-prone and slow. And the graphs would 
	need to be reduced in size, and that would create other problems. */
	
/* We will *not* spend our time doing this! */

/* So:

	1.	SAS ODS Graphics: fairly automatic graphs as long as they are from
		the "menu" that SAS offers. Otherwise, graphs are either difficult
		to make, perhaps involving tricks, or (to me) are impossible to make.

	From what I know about ggplot2 and lattice, they certainly can make the automatic
	style of graphs in SAS ODS Graphics, but it seems that they can do this
	more flexibly than SAS, and that extensions can be written with functions.

*/
  

