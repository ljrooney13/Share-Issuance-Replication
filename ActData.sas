/****************************************************************************
 The following outputs the table Table 1: Descriptive Statistics, 1970 to
 2003 on p927. This is done to compare actual results to expected results.
 ****************************************************************************/


data table1;
	input Variable $ Mean  twenty  Median  seventy  Std;
	datalines;
Issue11 0.04 0.00 0.00 0.03 0.15
Issue59 0.12 0.00 0.00 0.14 0.33
BM -0.34 -0.79 -0.07 0.00 0.94
ME 11.11 9.63 10.97 12.46 2.02
MOM 0.06 -0.16 0.02 0.22 0.41
R11 0.14 -0.23 0.05 0.34 0.88
;
run;

proc print data = table1;
run;
