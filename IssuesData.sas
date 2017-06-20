/****************************************************************************
 The following code retrieves and filters the data from the CRSP Monthly
 Stock File. It eliminates observations from firms that have not been in the 
 database for more than 6 months. It also pulls the index data and includes
 an equally weighted return number for each date used.
 *****************************************************************************/

%let issue_keep = keep = permno date ret prc shrout cfacshr;	/* vars kept from CRSP MSF 		*/
%let index_keep = keep = c_date ewretd;				/* vars kept from CRSP MSIX 		*/

data companyData;
	
	set crsp.msf(&issue_keep &where);
		by permno date;

	retain elap; 						/* counter of observations per permno 	*/
	if (first.permno) then elap = 0;
	elap = elap + 1;

	price = abs(prc);					/* accounts for any negative prices 	*/
	mkt_value = price * shrout;				/* calculates the market value 		*/
	log_mkt_val = log(mkt_value);
								/* calcs the lagged market value, used 	*/
	mkt_lag = lag11(log_mkt_val);				/* in the regressions, per p929 	*/
	if ( 0 < elap < 12) then mkt_lag = .;			/* adjusts to eliminate any false lags 	*/

	c_date = mdy(month(date),1,year(date));			/* sets a clean date variable to ensure */ 
	format c_date date9.;					/* the code aligns throughout 		*/

run;

data indexData(&index_keep);

	set crsp.msix(keep = caldt ewretd where = (caldt between &startdt and &enddt));
		by caldt;
	
	c_date = mdy(month(caldt),1,year(caldt));		/* sets a clean date variable to ensure */
	format c_date date9.;					/* the code aligns throughout 		*/

run;

proc sort data = companyData out = s_coData;			/* sort company data to align with index*/
	by c_date;						/* so they can be merged		*/
run;

data mergedData;
	
	merge s_coData indexData;				/* merge the company and index data 	*/
		by c_date;
run;

proc sort data = mergedData out = IssuePull;			/* sort merged data set by permno again */
	by permno c_date;
run;

*proc print data = IssuePull(obs = 1000);
*run;

