%let dirdata=/folders/myfolders/project/;

LIBNAME save "&dirdata";

/************ q1a **************/
%put q1a;

data snow1;
  infile "&dirdata.Pr1Snowfall1.csv" DLM = ',' DSD MISSOVER;
  tot = 0;
  drop i tot;
  retain year Season Sep Oct Nov Dec Jan Feb Mar Apr May Total;
  input Season $ Sep Oct Nov Dec Jan Feb Mar Apr May Total;
  year = substr(Season, 1, 4);
  year = input(year, comma4.);
  array mon{10} Sep--Total;
  do i=1 to 10;
		if mon{i} = 'T' then mon{i} = 0;
		tot = tot + mon{i};
  end;
  if mod(year,1) = 0;
  if tot > 0 and Total > 0;
run;

title q1a;
Footnote q1a;
proc contents; run;
proc print; run;

%put q1a;


/************ q1b **************/
%put q1b;

data _null_;
	call symput('lastobs',put(lastobs,best.));
	set snow1 nobs=lastobs;
run;
%put &lastobs full years of snowfall data;

%put q1b;


/************ q1c **************/
%put q1c;

data snow2;
  infile "&dirdata.Pr1Snowfall2.csv" DLM = ',' DSD MISSOVER;
  tot = 0;
  drop i tot;
  retain year Season Sep Oct Nov Dec Jan Feb Mar Apr May Total;
  input Season $ Sep Oct Nov Dec Jan Feb Mar Apr May Total;
  year = substr(Season, 1, 4);
  year = input(year, comma4.);
  array mon{10} Sep--Total;
  do i=1 to 10;
		if mon{i} = 'T' then mon{i} = 0;
		tot = tot + mon{i};
  end;
  if mod(year,1) = 0;
  if tot > 0 and Total > 0;
run;

title q1c;
Footnote q1c;
proc contents; run;
proc print; run;


data _null_;
	call symput('lastobs',put(lastobs,best.));
	set snow2 nobs=lastobs;
run;
%put &lastobs full years of snowfall data;

%put q1c;



/************ q2a **************/
%put q2a;

data CT1;
	infile "&dirdata.Pr1CT.dat" DLM ='09'x DSD MISSOVER firstobs=2;
	length Race $15;
	input PatientID $ Sex $ Race $ Treatment $ Sens0 Sens1 Sens3 Sens6 Sens12 Sens24;
	if PatientID = "Missing" then PatientID = .;
	if Sex = "Missing" then Sex = .;
	if Race = "Missing" then Race = .;
	if Treatment = "Missing" then Treatment = .;
	

title q2a;
Footnote q2a;
PROC CONTENTS data=CT1; RUN; 
PROC PRINT data=CT1 (OBS=325);RUN;


%put q2a;


/************ q2b **************/
%put q2b;

data CT2;
	set ct1;
	Location = substr(PatientID, 1, 1);
	IDNumber = substr(PatientID, 2, 3);


title q2b;
Footnote q2b;
PROC CONTENTS data=CT2; RUN; 
PROC PRINT data=CT2 (OBS=325);RUN;
%put q2b;


/************ q2c **************/
%put q2c;


data _null_;
	set ct2;
	if Location ^= "P" and Location ^= "J" and Location ^= "M" and Location ^= "N" and Location ^= "V" then do;
      	put "Error: Location " Location "changed to X for PatientID " PatientID;
      	Location = "X";
   	end;
	run;

%put q2c;










/************ q3a **************/
%put q3a;

data wBuff1;
  infile "&dirdata.Weather_Buffalo.csv" DLM = ',' DSD MISSOVER firstobs=2;
  length Station_ID $17 Station $43;
  informat Date yymmdd10.;
  input Station_ID $ Station $ Elevation Latitude Longitude Date MaxSnow Miss CMiss 
  	Precip Miss_1 CMiss_1 Snowfall Miss_2 CMiss_2 MeanMaxTemp Miss_3 CMiss_3 MeanMinTemp Miss_4 CMiss_4 MeanTemp Miss_5 CMiss_5;
  if MaxSnow = -9999 then MaxSnow = .;
  if Precip = -9999 then Precip = .;
  if Snowfall = -9999 then Snowfall = .;
  if MeanMaxTemp = -9999 then MeanMaxTemp = .;
  if MeanMinTemp = -9999 then MeanMinTemp = .;
  if MeanTemp = -9999 then MeanTemp = .;
  format date mmddyy10.;
run;

title q3a;
Footnote q3a;
PROC CONTENTS data=wBuff1; RUN; 
PROC PRINT data=wBuff1 (OBS=20);RUN;

%put q3a;



/************ q3b **************/
%put q3b;

proc summary data=wBuff1;
	var Miss CMiss Miss_1 CMiss_1 Miss_2 CMiss_2 Miss_3 CMiss_3 
		Miss_4 CMiss_4 Miss_5 CMiss_5;
	output out=BuffTotals sum=MissTot CMissTot Miss_1Tot CMiss_1Tot Miss_2Tot CMiss_2Tot Miss_3Tot CMiss_3Tot 
		Miss_4Tot CMiss_4Tot Miss_5Tot CMiss_5Tot;		
run;

title q3b;
Footnote q3b;
proc print data=BuffTotals;
	var MissTot CMissTot Miss_1Tot CMiss_1Tot Miss_2Tot CMiss_2Tot Miss_3Tot CMiss_3Tot 
		Miss_4Tot CMiss_4Tot Miss_5Tot CMiss_5Tot;
run;

%put q3b;

/************ q3c **************/
%put q3c;

data wBuff2;
	set wBuff1;
	drop Miss CMiss Miss_1 CMiss_1 Miss_2 CMiss_2 Miss_3 CMiss_3 
		Miss_4 CMiss_4 Miss_5 CMiss_5 Station_ID Elevation Latitude Longitude;
		
title q3c;
Footnote q3c;
proc contents data=wBuff2;
proc sql; * idk if im allowed to do this, but its way easier than using a proc table 
			(espically since I have sql experience) and it IS mentioned in the book at the end; 
	select distinct Station as Station_Names_Listing from wBuff2;
run;

%put q3c;

/************ q3d **************/
%put q3d;

data wBuff3;
	set wBuff2;
	City = "Buffalo";
	length Site $10;
	if Station = "BUFFALO NY US" then do;
		Station = "Buffalo City";
		Site = "City";
	end;
	else do;
		Station = "Buffalo Airport";
		Site = "Airport";
	end;

title q3d;
Footnote q3d;
PROC CONTENTS data=wBuff3; RUN; 
PROC PRINT data=wBuff3 (OBS=20);RUN;

%put q3d;

/************ q3e **************/
%put q3e;

data wBuff4;
	set wBuff3;
	MonthN = month(date);
	format Month monname3.;
	Month = date;
	Year = year(date);
	if MonthN > 9 then SnowSeasonLong = Year;
	if MonthN < 5 then SnowSeasonLong = Year - 1;


title q3e;
Footnote q3e;
PROC CONTENTS data=wBuff4; RUN; 
PROC PRINT data=wBuff4 (OBS=20);RUN;

%put q3e;

/************ q3f **************/
%put q3f;

data wBuff5;
	set wBuff4;
	Maxsnow = round(Maxsnow / 25.4, 0.1);
	Precip = round(Precip / 254, 0.1);
	Snowfall = round(Snowfall / 25.4, 0.1);
	MeanMaxTemp = round((MeanMaxTemp * .18) + 32, 0.1);
	MeanMinTemp = round((MeanMinTemp * .18) + 32, 0.1);
	MeanTemp = round((MeanTemp * .18) + 32, 0.1);

title q3f;
Footnote q3f;
PROC PRINT data=wBuff5 (OBS=20);RUN;

%put q3f;

/************ q4a **************/
%put q4a;

proc sql;
	select date as Cdates from wBuff5 where Site = "City";
	select Cdates from wBuff5 where Site = "Airport";

data Overlap;
	set wBuff5;
	if 

title q4a;
Footnote q4a;
PROC PRINT data=wBuff5 (OBS=20);RUN;

%put q4a;


/************ q5a **************/
%put q5a;



