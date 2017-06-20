/****************************************************************************
 Name match brings in an excel file of SDC data and uses the 6 digit SIC codes
 to match to permnos. The output is a file containing permnos and a flag on
 one of four different activities. These are: repurchases (REP), seasoned
 equity offerings (SEO), mergers with stock (SMA), and mergers with an unkown
 consideration (UMA).
 ****************************************************************************/

proc import out = temp datafile = "sdc data2.xlsx" dbms = xlsx;	/* import existing file with date flags	*/
run;								/* at each event			*/

proc sort data = temp out = sdcdata;				/* sort data by cusip			*/
	by cusip;
run;

proc sort data = crsp.dsenames out = dse;			/* grab cusip by permno			*/
	by ncusip;
run;

data dsesort(keep = permno comnam cusip6);			/* adjust crsp cusips to be six digits	*/
	
	set dse;
		by ncusip;

	cusip6 = substr(ncusip,1,6);

	if (first.ncusip) then output;				/* output each value once to match	*/
run;


data match(drop = coname secondary tertiary);			/* match the sdc data with permnos	*/

	merge dsesort(rename = (cusip6 = cusip)) sdcdata;
		by cusip;
	
	c_date = mdy(month(date), 1, year(date));		/* clean date used for matching		*/

	if (permno ne .) then do;
		if (category ne "") then output;
	end;

run;

proc sort data = match out = match_s;				/* resort the data by permno		*/
	by permno date;
run;

*proc print data = match_s(obs = 100);
*run;

