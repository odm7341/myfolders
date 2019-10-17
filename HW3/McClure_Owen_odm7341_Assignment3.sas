%let dirdata=/folders/myfolders/HW3/;


/********* 1 ***********/
*a;
data temperature;
  infile "&dirdata.tempArray.csv" DLM = ',' DSD MISSOVER firstobs=2;
  array temp{24};
  input temp1 - temp24;
  array tempC{24};
  drop i;
  do i=1 to 24;
		tempC{i} = round((temp{i} - 32) / 1.8,0.1);
  end;
*b;  
  day = _n_;
*c;  
  informat date MMDDYY10.;
  date = mdy(1,22 + day,2012);
run;

*d;
LIBNAME save '/folders/myfolders/HW3/';
data save.Temperatures;
	set temperature;
run;

*e;
proc print data=temperature noobs;
	format date MMDDYY10.;
	title 'Temperature Data';
	var day date temp1-temp12 tempC1-tempC24;
run;

*f;
proc print data=temperature noobs;
	format date MMDDYY10.;
	title 'Temperature Data';
	var day date;
	var temp1 tempC1;
	var temp2 tempC2;
	var temp3 tempC3;
	var temp4 tempC4;
	var temp5 tempC5;
	var temp6 tempC6;
	var temp7 tempC7;
	var temp8 tempC8;
	var temp9 tempC9;
	var temp10 tempC10;
	var temp11 tempC11;
	var temp12 tempC12;
	var temp13 tempC13;
	var temp14 tempC14;
	var temp15 tempC15;
	var temp16 tempC16;
	var temp17 tempC17;
	var temp18 tempC18;
	var temp19 tempC19;
	var temp20 tempC20;
	var temp21 tempC21;
	var temp22 tempC22;
	var temp23 tempC23;
	var temp24 tempC24;
run;


/********* 2 ***********/
*a;
data namerank;
  infile "&dirdata.top-1000-baby-boy-names.txt" firstobs=7;
  informat rank COMMA4.;
  length name $20;
  input name $ rank @@;
  rank = rank * -1;
run;

*b;
PROC FREQ DATA=namerank;
    TABLES name;
    format name $1.;
RUN;

*c;
PROC FREQ DATA=namerank order=freq;
    TABLES name / nopercent nocum;
    format name $1.;
RUN;

/*
proc print data = namerank;
run;
*/



/********* 3 ***********/
*a;
PROC FREQ DATA=namerank order=freq;
    TABLES name / nopercent nocum;
    format name $2.;
    where substr(name,1,1) = 'J';      
RUN;
*b;
data popular1;
  set namerank;
  where substr(name,1,2) = 'Ja';  
run;
proc sort data=popular1;
 	by rank;
run;
*proc print data = popular1;run;

data popular2;
  set namerank;
  where substr(name,1,2) = 'Jo';  
run;
proc sort data=popular2;
 	by rank;
run;
*proc print data = popular2;run;

data mainPopular;
	set popular1 popular2;
run;
proc print data = mainPopular noobs;
	title 'Most popular Ja and Jo names';
run;

/********* 4 ***********/
*a;
data googleBannerStats;
	infile "&dirdata.preprocessedgooglestatstab.txt" DLM ='09'x DSD MISSOVER firstobs=2;
	length weekday $9;
	input weekday $ date:DATE7. impressions clicks revinue:dollar.;
	array count{7};
	array totimpress{7};
	array totclick{7};
	array totrev{7};
	if weekday = "Monday" then i = 1;
	if weekday = "Tuesday" then i = 2;
	if weekday = "Wednesday" then i = 3;
	if weekday = "Thursday" then i = 4;
	if weekday = "Friday" then i = 5;
	if weekday = "Saturday" then i = 6;
	if weekday = "Sunday" then i = 7;
	retain count1 - count7 0;
	retain totimpress1 - totimpress7 0;
	retain totclick1 - totclick7 0;
	retain totrev1 - totrev7 0;
	count{i} = count{i} + 1;
	totimpress{i} = (impressions + totimpress{i}) / count{i};
	totclick{i} = (clicks + totclick{i}) / count{i};
	totrev{i} = (revinue + totrev{i}) / count{i};
	avgImpressions = totimpress{i};
	avgClicks = totclick{i};
	avgRevinue = totrev{i};
run;
*b;
proc sort data = googleBannerStats;
	by weekday;
RUN;

data stats2;
	set googleBannerStats;
	by weekday;
	if last.weekday;

/* this is basiclly all i needed to do for c, because of the way i decided to solve the problem*/
proc sort data = stats2 ;
	by i;

proc print data=stats2 noobs;
	title "Google Ad Stastics by Weekday";
	format date MMDDYY10.;
	var weekday avgImpressions avgClicks avgRevinue;
RUN; 

proc print data=googlebannerStats;
	format date MMDDYY10.;
run;


/********* 5 ***********/ 

*a;
LIBNAME save '/folders/myfolders/HW3/'; 
data save.nypop; 
  infile "&dirdata.nypopulation.csv" DSD DLM = ',' firstobs=2; 
  length County $25; 
  informat TotalPop COMMA9.; 
  input County $ TotalPop ; 
 
proc print data=save.nypop;
	title "NY Population Data";
	format TotalPop COMMA9.; 
run; 
 
data save.nycvote; 
	title "NYC Voter Data";
	infile "&dirdata.nycvoters.csv" DSD DLM = ',' firstobs=2; 
	length County $25; 
	informat Republican COMMA7. Democrat COMMA7. Total COMMA9.; 
	input County Republican Democrat I C L R G W B Total; 
	drop I C L R G W B; 
 
proc print data=save.nycvote; 
	format Republican COMMA7. Democrat COMMA7. Total COMMA9.; 
run; 
 
data save.nonnycvote; 
	title "NON-NYC Voter Data";
	infile "&dirdata.nonnycvoters.csv" DSD DLM = ',' firstobs=2; 
	length County $25; 
	informat Republican COMMA7. Democrat COMMA7. Total COMMA9.; 
	input County Republican Democrat I C L R G W B Total; 
	drop I C L R G W B;

proc print data=save.nonnycvote; 
	format Republican COMMA7. Democrat COMMA7. Total COMMA9.; 
run;

*b;
data merge1;
	merge save.nypop save.nonnycvote;
run;

proc print data=merge1; 
	format Republican COMMA7. Democrat COMMA7. Total COMMA9. TotalPop COMMA9.;
	var County Republican Democrat Total TotalPop;
*	where Total = . AND TotalPop <> .;*
^----- uncomment to only show counties that are in the nypop data set but not the nonnycvote data set; 
*	where Total <> . AND TotalPop = .;*
^----- uncomment to only show counties that are in the nonnycvote data set but not the nypop data set;
run; 

*c;
data nyvote;
	set save.nonnycvote save.nycvote;
run;

*d;
data merge2;
	merge save.nypop nyvote;
run;

proc print data=merge2; 
	format Republican COMMA7. Democrat COMMA7. Total COMMA9. TotalPop COMMA9.;
	var County Republican Democrat Total TotalPop;
*	where Total = . AND TotalPop <> .;*
^----- uncomment to only show counties that are in the nypop data set but not the nyvote data set; 
*	where Total <> . AND TotalPop = .;*
^----- uncomment to only show counties that are in the nyvote data set but not the nypop data set;
run; 
*e;
data percent;
	set merge2;
	Percent = round((total / totalpop) *100, 0.1); 
run;
proc sort data=percent;
	by decending percent;
proc print data=percent noobs;
	title "Percent Registered to vote";
	var County Percent;
run;

