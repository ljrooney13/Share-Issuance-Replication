/****************************************************************************
 Outputs the SAS data set into Stata form to be able to run analysis
 ****************************************************************************/

%let dir = .;
%let stata_keep = c_date mom mom_lag permno ret ret1 ret6 ret12 ret24 ret36 log_issue11 log_issue17 log_issue23 log_issue59 log_issue65 dumy log_bm bm_lag bm_dummy bmd_lag log_mkt_val mkt_lag rep11 rep23 rep35 seo11 seo23 seo35 sma11 sma23 rlead slead; 
%let test_keep = c_date permno adj_shr issue11 log_issue11 log_issue17 ret12;


*proc contents data = setFlag;
*run;

proc print data = setFlag(keep = &test_keep obs = 1000);
run;

endsas;

proc export data = setFlag(keep = &stata_keep) outfile = "&dir/shares.dta";
run;
