/****************************************************************************
 portfolio.sas assigns a dummy variable depending on issuance directionality.
 It then uses this variable to open buy / sell positions in each company,
 which is held for 12 months. The returns are output monthly.
 ****************************************************************************/

%let ret12_start = 12;
%let ret1_start  = 1;

data portfolio;

	set descripData;
		by permno c_date;

	if (log_issue17 > 0)	     	then flag1 = -1;	/* set dummy buy / sell for 1m	*/
	if (log_issue17 < 0)	     	then flag1 = 1;
	if (log_issue17 = 0)		then flag1 = .;
	if (log_issue17 = .) 		then flag1 = .;

	if (log_issue17 > 0)		then flag  = -1;
	if (log_issue17 < 0)		then flag  = 1;
	if (log_issue17 = 0)		then flag  = .;
	if (log_issue17 = .)		then flag  = .;

	if (lag11(log_issue17) > 0 ) 	then flag12 = -1;	/* set dummy buy / sell for 12m	*/
	if (lag11(log_issue17) < 0 )	then flag12 = 1;
	if (lag11(log_issue17) = 0 ) 	then flag12 = .;
	if (lag11(log_issue17) = . ) 	then flag12 = .;

	

	if (0 < elap < 17 + &ret12_start) then flag12 = .;	/* clean up data issues.	*/
	if (0 < elap < 17 + &ret1_start) then flag1 = .;
	if (0 < elap < 18) 		then flag = .;	

	hold_ret12 = ret12 * flag12;				/* calc portfolio ret		*/
	hold_ret1 = ret1 * flag1;
	hold_test = ret12 * flag;
run;

proc sort data = portfolio out = port_sorted;
	by c_date;
run;

data port_ret;

	set port_sorted;
		by c_date;

	retain total_ret12 total_ret1 cnt12 cnt1 tr ct;

	if (first.c_date) then do;
		total_ret12 = 0;
		total_ret1 = 0;
		tr = 0;	
		ct = 0;
		cnt1 = 0;
		cnt12 = 0;
	end;
	
	if (hold_ret12 ne .) then do;
		total_ret12 = total_ret12 + hold_ret12;
		cnt12 = cnt12 + 1;
	end;

	if (hold_ret1 ne .) then do;
		total_ret1 = total_ret1 + hold_ret1;
		cnt1 = cnt1 + 1;
	end;

	if (hold_test ne .) then do;
		tr = tr + hold_test;
		ct = ct + 1;
	end;

	if (last.c_date) then do;
		mo_ret12 = total_ret12 / cnt12;
		mo_ret1  = total_ret1 / cnt1;
		mo_test = tr / ct;
		output;
	end;	

run;

*proc print data = portfolio (keep = c_date ret1 hold_ret1 flag1 log_issue17 obs = 250);
*run;

*proc print data = port_ret (keep = c_date mo_ret12 mo_test log_issue17 obs = 200);
*run;
*endsas;
