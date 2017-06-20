/****************************************************************************
 This program outputs the simple descriptive statistics for the data set. It
 creates a replica of Table 1 found on p927.
 ****************************************************************************/
 
%let final_date = where = (date between '1Jan1970'd and &enddt);/* set act range of data		*/

data BMCalc_adj;						/* filter the dates down to act range	*/
	set BMCalc(&final_date);
		by permno date;
run;

%winsorize(BMCalc_adj, clean_data,,log_issue11 log_issue17 log_issue59 log_issue65 log_bm bm_lag log_mkt_val mkt_lag MOM mom_lag,_bottom = 1, _top = 99);

proc means data = clean_data mean p25 median p75 stddev maxdec = 2;
	var log_issue11 log_issue59 log_bm log_mkt_val MOM ret12;
	title 'Panel A: Simple Statistics';
run; 
