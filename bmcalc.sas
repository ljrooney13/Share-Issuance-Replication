/****************************************************************************
 The following code uses two existing data sets to calculate book to market
 for the data.
 ****************************************************************************/

%let adj = 1000;						/* adjustment factor to align values	*/

data BMCalc;							/* calculates book market		*/

	merge descripData cleaned;
		by permno c_date;

	retain fy_dt fy_book;
	if (book ne .) then fy_dt = month(c_date);		/* set the fiscal yr end month		*/
	if (month(c_date) = fy_dt) then fy_book = book; 	/* retain book value at fiscal mo	*/

	bm = fy_book / mkt_value * &adj;			/* bm is book / size per p925		*/
	
	if (bm = .) then bm_dummy = 0;				/* set bm dummy values			*/
	if (bm ne .) then bm_dummy = 1;

	retain dec_bm;						/* retain december book market per p925	*/

	if(first.permno) then do;				/* clear all values if it is the first	*/
		dec_bm = .;					/* permno to avoid any overlap issues	*/
		fy_dt = .;
		fy_book = .;
		bm = .;
		bm_dummy = .;
		bm_lag = .;
		bmd_lag = .;
	end;

	log_bm = log(dec_bm);					/* calc log of the december book market	*/
	if (log_bm = .) then log_bm = 0;

	bm_lag = lag11(log_bm);					/* calc lag of the bm to be used in	*/
	if (0 < elap < 13) then bm_lag = .;			/* regressions per p929			*/

	bmd_lag = lag11(bm_dummy);				/* calc lag of bm dummy to be used in	*/
	if (0 < elap < 13) then bmd_lag = .;			/* regressions per p929			*/

	if(month(c_date) = 12) then dec_bm = bm;		/* use dec bm per p925			*/

run;
