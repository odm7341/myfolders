%let dirdata=/folders/myshortcuts/SAS_part/Week 2/;
data homegarden;
	infile "&dirdata.Garden.dat";
	input Name $ 1-7 Tomato Zucchini Peas Grapes;
	Zone=14;	
	Type='home';
	Zucchini=Zucchini*10;
	Total = Tomato + Zucchini + Peas + Grapes;
	PerTom = (Tomato / Total) * 100;
run;
proc print data=homegarden;
run;
data contest;
	infile "&dirdata.Pumpkin_Plus3.dat";
	input Name $16. Age 3. +1 Type $1. +1 Date MMDDYY10. (Scr1 Scr2 Scr3 Scr4 Scr5) (4.1);
	TotScore = SUM(Scr1, Scr2, Scr3, Scr4, Scr5);
	TotScore2 = Scr1 + Scr2 + Scr3 + Scr4 + Scr5;
	AvgScore = MEAN(Scr1, Scr2, Scr3, Scr4, Scr5);
	AveScore2=(Scr1 + Scr2 + Scr3 + Scr4 + Scr5) / 5;
	DayEntered = DAY(Date);
	Type= UPCASE(Type);
	run;
proc print data= contest;
run;
data oldcars;
	infile "&dirdata.Auction.dat";
	input Make $ 1-13 Model $ 15-29  YearMade Seats MillionsPaid;
	If YearMade < 1890 then Veteran='Yes';
	If Model = 'F-88' Then DO;
		Make='Oldsmobile';
		Seats=2;
	END;
run;
proc print data=oldcars;
run;
data homeimprovement;
	infile "&dirdata.Home.dat";
	input  Owner $ 1-7 Description $ 9-33 Cost;
	If Cost=. then CostGroup='missing';
		else if Cost < 2000 then CostGroup='low';
		else if Cost < 10000 then CostGroup='medium';
		else CostGroup='high';
run;
proc print data=homeimprovement;
run;
data comedy; 
	infile "&dirdata.Shakespeare.dat";
	input Title $ 1-26 Year Type $;
	If Type = 'comedy';
run;
proc print data= comedy;
run;
data Shakespeare;
	infile "&dirdata.Shakespeare.dat";
	input Title $ 1-26 Year Type $;
run;
data comedy2;
	Set Shakespeare;
	if Type='comedy';
run;
proc print data=comedy2;run;

data Shakespeare;
	set shakespeare END=eof;
	length TypeAbb $4 Group $5;
	TypeAbb=substr(Type,1,4);
	if not(TypeAbb='come' OR TypeAbb='roma') then Group='heavy';
	else Group='light';
	if (eof) then put 'Last title in the data set is:' Title;
run;
proc print data=Shakespeare;
run;
data dateTest;
	input d1 MMDDYY8. +1 d2 DATE9.;
	d1f=d1;
	d2f=d2;
	d3f=d2;
	format d1f DATE9. d2f WORDDATE. d3f MMDDYY8.;
	datalines;
01111960 12Jan1960
01011961 01Mar2013
	;
run;
proc print;
run;
proc print;
	format d1f 9.0 d1 WEEKDATE.;
	run;
data librarycards;
infile "&dirdata.Library.dat" TRUNCOVER;
input Name $11. +1 Birthdate MMDDYY10. +1 IssueDate ANYDTDTE10. Duedate Date11.;
DaysOverdue=TODAY() - Duedate;
CurrentAge = INT(YRDIF(Birthdate,Today(),'AGE'));
If IssueDate > '01Jan2012'D then NewCard='Yes';
run;
proc print data=librarycards;
	format IssueDate MMDDYY8. DueDate WeekDate17.;
	title 'SAS Dates';
run;
data gamestats;
infile "&dirdata.Games.dat";
input Month 1 Day 3-4 Team $ 6-25 Hits 27-28 Runs 30-31;
retain MaxRuns;
MaxRuns=MAX(MaxRuns, Runs);
retain RunstoDate 0;
RunstoDate = sum(RunsToDate, Runs);
run;
proc print data=gamestats;
run;
data songs;
infile "&dirdata.KBRK.dat";
input City $ 1-15 Age wj kt tr filp ttr;
ARRAY song (5) wj kt tr filp ttr;
DO i=1 to 5;
	IF song(i)=9 then song(i)=.;
end;
run;
proc print data= songs;
run;
data songs2;
infile "&dirdata.KBRK.dat";
input City $ 1-15 Age wj kt tr filp ttr;
ARRAY old (5) wj -- ttr;
ARRAY new (5) Song1 - Song5;
drop i;
do i=1 to 5;
	if old(i)=9 then new(i)=.;
	else new(i)=old(i); 
end;
AveScore=Mean(OF Song1 - Song5);
run;
proc print data=songs2;
run;
data expenses;
infile "&dirdata.expensesArray.csv" dlm="," DSD firstobs=2;
length Resortname $26 Resort $8;
input Resortname Resort OffSeason1-OffSeason6;
run;
proc print;run;
data SeasonalRates1;
set expenses;
Seasonal1=1.25*OffSeason1;
Seasonal2=1.25*OffSeason2;
Seasonal3=1.25*OffSeason3;
Seasonal4=1.25*OffSeason4;
Seasonal5=1.25*OffSeason5;
Seasonal6=1.25*OffSeason6;
format OffSeason1-OffSeason6 seasonal1-seasonal6 dollar9.2;
run;
proc print;run;

data work.SeasonalRates2;
set expenses;
drop i;
array offseason (6) OffSeason1-OffSeason6;
*array seasonal (6) Season1-Season6;
array seasonal (*) Season1-Season6;
do i=1 to dim(seasonal);
	seasonal(i)=1.25*offseason(i);
end;
format OffSeason1 - OffSeason6 Season1 - Season6 dollar9.2;;
run;
proc print;run;
data expense_plus;
infile "&dirdata.expensesArray_Plus.csv" dlm="," DSD firstobs=2;
length Resortname $ 26 Resort $ 8;
input ResortName Resort  RoomRate Dailyfood Spavisits RoundofGolf HorseBackRiding ParkAdmissions;
run;
data diffs;
	drop i;
	set expense_plus;
	array budget{6} _temporary_ (175,75,25,35,25,30);
	array expense{6} RoomRate Dailyfood Spavisits RoundofGolf HorseBackRiding ParkAdmissions;
	array difference{6};
	do i=1 to dim(expense);
		difference{i}=budget{i} - expense{i};
		end;
run;
proc print;run;
data style;
infile "&dirdata.Artists.dat";
input Name $ 1-21 Genre $ 23-40 Origin $ 42;
run;
proc print;run;
proc print data=style;
	where genre='Impressionism';
	title ' Major Impressionist painters';
	footnote 'F=France N=Netherlands U=US';
run;
title;
footnote;
data marine;
infile "&dirdata.Lengths.dat";
input name $ family $ length @@;
run;
proc print data=marine;run;
proc sort data=marine out=seasort nodupkey;
	by family descending length;
run;
proc print data=seasort;
run;
data address;
infile "&dirdata.Mail.dat";
input Name $6. Street $18. City $9. State $6.;
run;
title 'addressed not sorted';
proc print;run;
proc sort data=address out=sortone 	SORTSEQ=linguistic (numeric_collation =on);
	by street;
run;
	proc print data=sortone;
	title 'addresses sorted by street';
	run;
proc sort data=address out=sorttwo sortseq=linguistic (strength=primary);
	by state;
run;
proc print data=sorttwo;run;
data sales;

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
PROC PRINT DATA = carsurvey;
   FORMAT Sex gender. Age agegroup. Color $col. Income DOLLAR8.;
   TITLE 'Survey Results Printed with User-Defined Formats';
RUN;

%let dirOUT=/folders/myshortcuts/SAS_part/Week 2/; 

%put &dirout; 

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

PROC MEANS DATA = fsalesP MAXDEC = 2;
   BY Month;
   VAR Petunia SnapDragon Marigold;
   TITLE 'Summary of Flower Sales by Month';
RUN;

PROC MEANS DATA = fsalesP N MEAN Stddev CLM alpha=0.1 MAXDEC = 2;
   BY Month;
   VAR Petunia SnapDragon Marigold;
   TITLE 'Summary of Flower Sales by Month';
RUN;


PROC SORT DATA = fsalesP;
   BY CustID;
run;
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

DATA orders;
   INFILE "&dirdata.Coffee.dat";
   INPUT Coffee $ Window $ @@; 
RUN;

Title 'Coffee/Window data';
PROC PRINT;run;

TITLE 'Summary of Coffee/Window data';
PROC FREQ DATA = orders;
   TABLES Window  Window * Coffee;
RUN;

