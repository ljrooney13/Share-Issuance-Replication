/*****************************************************************************
 The following code pulls data from Compustat and sets up a link file in order
 to merge the Compustat gvkeys with the CRSP permnos.
 ****************************************************************************/

%let ccmlink = liid linktype lpermco;
%let compdata = fyear fyr seq txdb itcb pstkrv pstkl pstk ceq at lt prcc_f csho seq;

/*This macro pulls the file that links the gvkeys and permnos.*/
%ccm_link(crsp_comp_link, start_date = &startdt, stop_date = &enddt);

/*This macro pulls the desired data from the comp funda file.*/
%read_comp(compdata, &compdata, startdt = &startdt, stopdt = &enddt);

data linked;							/* combines compustat datasets by GVKEY	*/

	merge compdata crsp_comp_link(drop = &ccmlink rename = (lpermno = permno));
		by gvkey;

	c_date = mdy(month(datadate),1,year(datadate));		/* clean date to help align all code	*/

	if (permno ne .) then output;
run;

proc sort data = linked out = sortedlink;			/* resort the data so it is by permno	*/
	by permno datadate;
run;

data cleaned;							/* calculates book value per Fama French*/
	set sortedlink;
		by permno;

	if	(seq ~=.) then seq = seq;
	else if	(ceq ~=.) then seq = sum(ceq,pstk);
	else if	(at ~=.) then seq = sum(at, -lt);
	else seq = .;

	if	(pstkrv ~=.) then bv_pref = -pstkrv;
	else if	(pstkl ~=.) then bv_pref = -pstkl;
	else if	(pstk ~=.) then bv_pref = -pstk;
	else bv_pref = .;

	book = sum(seq, txdb, itcb, bv_pref);
run;

*proc print data = cleaned(obs = 100 keep = permno c_date ceq seq txdb itcb bv_pref book t1);
*run;
