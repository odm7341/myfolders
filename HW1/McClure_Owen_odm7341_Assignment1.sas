/*
Assignment 1
Owen McClure
*/

/*
1a)  These two data sets should be exactly the same because the Manufracurer length in cars93ff2 is set correctly.
1b)  Without the $ SAS will think the variable is a number variable instead of text an will not read the data correctly.
1c)  Without this option SAS will try reading for data on the first line of the data file, which is not data beacause its headers.
*/

/************ 2 *************/

%let dirdata=/folders/myfolders/HW1/;

/*importing the subfree data first*/
data cars93ff2;
  infile "&dirdata.cars93subfree.txt" firstobs=2;
  length Manufacturer $10;
  input Manufacturer $ Type $ Price MPG_city MPG_highway Horsepower Origin $;
run;

/*importing the comma delim data*/
data cars93ff_comma;
  infile "&dirdata.cars93subcomma.txt" DLM = ',' DSD MISSOVER firstobs=2;
  length Manufacturer $10;
  input Manufacturer $ Type $ Price MPG_city MPG_highway Horsepower Origin $;
run;

/*importing the tab delim data*/
data cars93ff_tab;
  infile "&dirdata.cars93subtab.txt" DLM ='09'x DSD MISSOVER firstobs=2;
  length Manufacturer $10;
  input Manufacturer $ Type $ Price MPG_city MPG_highway Horsepower Origin $;
run;

proc compare base=cars93ff2 compare=cars93ff_comma ;
proc compare base=cars93ff2 compare=cars93ff_tab ;
run;

/*
3a)  Yes the deliminator option is needed so that sas knows where each variable stops and the next begins, the default delim is a space.
3b)  No,this option is not needed, because all the lines end with room for each variable.
3b)  By removing one of the double commas in line 5 of the bands.csv file without MISSOVER SAS will now skip over this line and leave it out of the data set.
*/

/************ 4 *************/

DATA nationalparks2;
   INFILE "&dirdata.NatPark.dat";
   INPUT ParkName $ 1-22 State $ Year Acreage:COMMA9.;
RUN;

/*
I simply removed the @40 and specified the data format of the Acreage variable to be COMMA9.
*/

/************ 5 *************/

data googleBannerStats;
	infile "&dirdata.preprocessedgooglestatstab.txt" DLM ='09'x DSD MISSOVER firstobs=2;
	input weekday $ date:DATE7. impressions clicks revinue:dollar.;
run;

proc print data=googleBannerStats;run;





