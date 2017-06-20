/****************************************************************************
 The following code calculates the 1 year and 5 year rolling issuances, and 
 the 5 year dummy variable.
 ****************************************************************************/

%let dummy_keep = keep = permno dummyvar;			/* vars to keep post dummy calc		*/
%let count = 1000000;						/* sets large dimension for temp arrays */
%let revert = 0.95;						/* error checking reversion per p924	*/
%let maxch = 0.20;						/* error checking threshold per p924	*/

data DummyVar(&dummy_keep);

	set compdata;
		by permno date;

	retain f_date;						/* first date a permno appears in data	*/
	if (first.permno) then f_date = date;

	if (last.permno) then do;				/* calcs total num of years a permno is	*/
		length = yrdif(f_date,date,"ACT/ACT");		/* in the data. >5 for 1, <5 for 0	*/
		if length >= (&issue59 + 1)/12  then dummyvar = 1;
		else dummyvar = 0;
		output;
	end;
run;

data mergedfile;						/* merge dummy vars back with data set	*/
	merge compdata DummyVar;
		by permno;
run;

data issuecalcs;

	array _adj   (&count)	_temporary_;			/* initialize each array desired	*/
	array _date  (&count) 	_temporary_;
	array _elap  (&count) 	_temporary_;
	array _cfac  (&count) 	_temporary_;
	array _dumy  (&count) 	_temporary_;
	array _mkt   (&count) 	_temporary_;
	array _mklag (&count)	_temporary_;
	array _lmkt  (&count) 	_temporary_;
	array _prc   (&count) 	_temporary_;	
	array _mom   (&count) 	_temporary_;
	array _mlag  (&count)	_temporary_;
	array _ewret (&count) 	_temporary_;
	array _ret   (&count) 	_temporary_;

	cnt = 0;
	do until (last.permno);					/* fill each initialized array		*/
		set mergedfile;
			by permno;
		cnt + 1;
		_adj   (cnt) 	= shrout;
		_date  (cnt) 	= c_date;
		_elap  (cnt) 	= elap;
		_cfac  (cnt) 	= cfacshr;
		_dumy  (cnt) 	= dummyvar;
		_mkt   (cnt) 	= mkt_value;
		_mklag (cnt) 	= mkt_lag;
		_lmkt  (cnt) 	= log_mkt_val;
		_prc   (cnt) 	= price;
		_mom   (cnt) 	= mom;
		_mlag  (cnt)	= mom_lag;
		_ewret (cnt) 	= ewretd;
		_ret   (cnt) 	= ret;

	end;

	do j = 1 to cnt;
		c_date 		= _date(j);			/* transfer values out of array and back*/
		elap 		= _elap(j);			/* to data set				*/
		dumy 		= _dumy(j);
		cfac 		= _cfac(j);
		mkt_value 	= _mkt(j);
		mkt_lag		= _mklag(j);
		log_mkt_val 	= _lmkt(j);
		price 		= _prc(j);
		mom 		= _mom(j);
		mom_lag		= _mlag(j);
		ewretd 		= _ewret(j);
		ret 		= _ret(j);

		if (j < cnt - 4) then do;			/* checks for data erros per p924	*/
			perc_chng = abs( (_adj(j+1) / _adj(j) - 1));
			perc_dec  = abs( (_adj(j+4) - _adj(j+1)) / (_adj(j+1) - _adj(j)));

			if (perc_dec = .) then perc_dec = 0;

			if (perc_chng > &maxch) then do;
				if (perc_dec > &revert) then _adj(j+1) = _adj(j);
			end;
		end;		

		clean_shrout = _adj(j);
		adj_shr = clean_shrout * cfac;			/* calcs adjusted shares per p923	*/
		
		issue11 = adj_shr - lag&issue11(adj_shr);	/* calcs issuance over one year		*/
		log_issue11 = log(adj_shr) - log(lag&issue11(adj_shr));

		log_issue23 = lag11(log_issue11);		/* calcs one year lag of one year issue	*/
		if (0 < elap < 24) then log_issue23 = .;

		log_issue17 = lag6(log_issue11);		/* calcs six mo lag of one year issue	*/
		if (0 < elap < 18 ) then log_issue17 = .;	/* used in regressions per p924		*/

		issue59 = adj_shr - lag&issue59(adj_shr);	/* calcs issuance over five years	*/
		log_issue59 = log(adj_shr) - log(lag&issue59(adj_shr));

		log_issue65 = lag5(log_issue59);		/* calcs six mo lag of five year issue	*/
		if (0 < elap < 66) then log_issue65 = .;	/* used in regressions per p924		*/

		if (0 < elap < 1+&issue11) then do;		/* cleans up potential data issues	*/
			issue11 = .;
			log_issue11 = .;
		end;

		if (0 < elap < 1+&issue59) then do;
			issue59 = 0;
			log_issue59 = 0;
		end;

		if not(dumy) then do;				/* assigns zero value to five year issue*/
			issue59 = 0;				/* if dummy is zero. Per p924		*/
			log_issue59 = 0;
		end;
		
		clean_date = mdy(month(date), 1,year(date));
		format clean_date date9.;

		output;
	end;
run;

*proc print data = issuecalcs (obs = 200);
*run;

