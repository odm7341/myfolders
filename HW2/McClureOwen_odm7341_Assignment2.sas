
%let dirdata=/folders/myfolders/HW2/;




data dfwlax;
   infile "&dirdata.dfwlax_space.txt";
   length Flight Dest $3;
   informat Date mmddyy8.;
   format Date mmddyy10.;
   input Date Flight FirstClass Economy Dest;
run;

data onboard;
   retain i 0;
   put _n_=;
   i+1; put _all_;
   set dfwlax;
   i+1; put _all_;
   Total=FirstClass+Economy;
   i+1; put _all_;
run;
/************* 1 *************/
/*

1)  The last 3 put statements corrispont to the compile and execution steps because the first statement shows us that
		the program vestor is filled with blanks, and the statements then show us that program vector gets filled and
		then we see the total calculation work. The _n_ value gets to 11 because SAS will move to one more than the
		last line before it realizes there is no more data and it stops. The i vaue gets to 31 because it is iterated
		3 times in each data iteration.
		
*/
/************* 2 *************/
data mydata;
  infile "&dirdata.mydata_Plus.csv" DLM = ',' DSD MISSOVER firstobs=2;
  input Workshop Gender $ q1 q2 q3 q4;
  if q1 = . then q1 = 9;if q2 = . then q2 = 9;if q3 = . then q3 = 9;if q4 = . then q4 = 9;
  if q1 = 4 then q1 = 20;if q2 = 4 then q2 = 20;if q3 = 4 then q3 = 20;if q4 = 4 then q4 = 20;
  if q1 = 5 then q1 = .;if q2 = 5 then q2 = .;if q3 = 5 then q3 = .;if q4 = 5 then q4 = .;
run;

/************* 3 *************/

data gamesPlus;
  infile "&dirdata.Games_Plus.dat" TRUNCOVER;
  INPUT Month 1 Day 3-4 Team $ 6-25 Hits 27-28 Runs 30-31 status $ 33-40;
  RETAIN MaxRuns 0;
  RETAIN RunsToDate 0;
  MaxRuns = MAX(MaxRuns, Runs);
  RunsToDate = RunsToDate + Runs;  
run;

/************* 4 *************/
data snow;
  infile "&dirdata.RochesterSnowfall.csv" DLM = ',' DSD MISSOVER firstobs=5 obs=117;
  drop i;
  input Season $ Sep Oct Nov Dec Jan Feb Mar Apr May Total;
  array mon{10} Sep--Total;
  do i=1 to 10;
		if mon{i} = 'T' then mon{i} = 0;
  end;
run;

title 'Snowfall in Rochester (inches)';
proc print data=snow noobs ;
run;