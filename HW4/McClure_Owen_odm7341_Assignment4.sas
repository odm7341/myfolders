%let dirdata=/folders/myfolders/HW4/;
LIBNAME save "&dirdata";

/********* 1 ***********/
*a;
data snow;
	set save.snow;
	year = input(substr(season,1,4), BEST4.);
	drop season;
run;

/*
proc print data = save.snow;
run;
*/
proc print data = snow;
run;



title "Snowfall by month 1950 - 2002";
proc sgplot data=snow;
	where year > 1949 and year < 2003;
	SERIES X = year Y = Dec / lineattrs=(color=red);
	SERIES X = year Y = Jan / lineattrs=(color=orange);
	SERIES X = year Y = Feb / lineattrs=(color=green);
	SERIES X = year Y = Mar / lineattrs=(color=blue);
	yaxis label = "Inches" ;
run;

/********* 2 ***********/
*a;
/*
title "Snowfall for January";
proc sgplot data=snow;
	Scatter X = year Y = Jan;
	reg X = year Y = Jan;
	yaxis label = "Inches" ;
run;

title "Snowfall for February";
proc sgplot data=snow;
	Scatter X = year Y = Feb;
	reg X = year Y = Feb;
	yaxis label = "Inches" ;
run;

title "Snowfall for March";
proc sgplot data=snow;
	Scatter X = year Y = Mar;
	reg X = year Y = Mar;
	yaxis label = "Inches" ;
run;

title "February vs January";
proc sgplot data=snow;
	Scatter X = Jan Y = Feb;
run;

title "March vs Janruary";
proc sgplot data=snow;
	Scatter X = Jan Y = Mar;
run;

title "March vs February";
proc sgplot data=snow;
	Scatter X = Feb Y = Mar;
run;
*/
proc sgscatter data=snow;
	title "Snowfall Comparisons";
	*compare x= year
			y= (Jan Feb Mar);
	plot Jan*year Feb*year Mar*year Feb*Jan Mar*Jan Mar*Feb /  Uniscale = y;
	*matrix year Jan Feb Mar;
run;

/********* 3 ***********/
*a;
data snow1a;
	set save.snow1;
run;

proc transpose data=snow1a out=snow1a name=Month prefix=Snowfall;
	by year;
data snow1a;
	set snow1a;
	rename Snowfall1 = Snowfall;
run;
	
proc print; run;

*b;
Proc report data=snow1a;
	where year > 1990;
	title "Snowfall by Year";
	column Month year, Snowfall;
	define month / "Month" group order=data;
	define Year / "Year" across order=data;
	define Snowfall / "";
run;

Proc report data=snow1a;
	where year > 1990;
	title "Snowfall by Month";
	column Year Month, Snowfall;
	define Year / "Year" group order=data;
	define Month / "Month" across order=data;
	define Snowfall / "";
run;

*c;
proc transpose data=snow1a out=snow1Year name=name;
	by year;
	
data snow1Year;
	set snow1Year;
	drop name;
	array COL{9};
	Snowfall = 0;
	do i = 1 to 9;
		Snowfall = COL{i} + Snowfall;
	end;
	drop COL1 - COL9 i;

proc print; run;


*d;
proc sgplot data=snow1a;
	vbox Snowfall / grouporder=data group=Month;
	legend label= "Month";
run;



















