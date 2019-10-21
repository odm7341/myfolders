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

data wBuf;
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
run;



%put q3a;


/************ q5a **************/
%put q5a;


data 

