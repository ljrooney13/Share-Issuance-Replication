/****************************************************************************
 momentum.sas calculates the momentum variable. This is a rolling 6 month
 return variable that is used as a proxy for momentum. It is lagged by one
 month.
 ****************************************************************************/

%let mom_keep = keep = permno c_date mom;			/* vars kept from momentum calcs 	*/
%let num = 0;							/* initialize variable to handle errors */
%let hp = 6;							/* set holding period for momentum 	*/
								/* value is 6 per page 925 		*/
data _null_;							
	
	set issuepull  nobs = num;				/* re initializes num 			*/
	call symput('num',num);
	stop;

run;

data momentum(&mom_keep);

	array _ret (&num) _temporary_;				/* set temp arrays to hold needed vars 	*/
	array _date(&num) _temporary_;

	ct = 0;							/* counter var keeping track of size 	*/

	do until (last.permno);					/* initialize the temp arrays 		*/
		set issuepull;
			by permno c_date;

		ct + 1;
		_ret (ct) = ret;
		_date(ct) = c_date;
	end;

	do j = 1 to (ct - &hp);
		
		mom = 1;	

		do i = j to (j + &hp - 1);
			mom = mom * (1 + _ret(i));		/* calculate the rolling return 	*/
		end;

		mom = mom - 1;
		
		c_date = intnx('MONTH',_date(j), &hp - 2, 'S');	/* lags the momentum var by a month per */
		format c_date date9.;				/* p925 				*/
		output;
	end;

run;

proc sort data = momentum out = s_ret;
	by permno c_date;
run;

data compdata;
	
	merge s_ret issuepull;					/* combine the momentum vars back into	*/
		by permno c_date;				/* the primary data set			*/

	mom_lag = lag11(mom);					/* cals the lagged mom value, used in	*/
	if (0 < elap < 12) then mom_lag = .;			/* regression calcs per p929		*/

run;

*proc print data = compdata(obs = 100);
*run;




