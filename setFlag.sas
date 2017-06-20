/****************************************************************************
 Setflag uses the REP / SEO / SMA designations from the SDC data to set 
 different levels of flags to be used when running regressions.

 REP = Repurchase flag
 SEO = follow on equity offering flag
 SMA = stock merger flag
 ****************************************************************************/ 

data setFlag;

	merge clean_data match_s;
		by permno c_date;

	retain rdelta sdelta mdelta;

	if (first.permno) then do;				/* initialize all vars to zero at start	*/

		r1 	= 0;					/* r1 = counter for one year REP	*/
		r2 	= 0;					/* r2 = counter for two year REP	*/
		r3 	= 0;					/* r3 = counter for three year REP	*/
		rep11 	= 0;					/* rep11 = one year REP variable	*/
		rep23 	= 0;					/* rep23 = two year REP variable	*/
		rep35 	= 0;					/* rep35 = three year REP variabel	*/
		rdelta 	= 0;					/* rdelta used when multiple REP / year	*/
		
		s1 	= 0;					/* s1 = counter for one year SEO	*/
		s2 	= 0;					/* s2 = counter for two year SEO	*/
		s3 	= 0;					/* s3 = counter for three year SEO	*/
		seo11 	= 0;					/* seo11 = one year SEO variable	*/
		seo23 	= 0;					/* seo23 = two year SEO variable	*/
		seo35 	= 0;					/* seo35 = three year SEO variable	*/
		sdelta	= 0;					/* sdelta used when multiple SEO / year	*/

		m1 	= 0;					/* m1 = counter for one year SMA	*/
		m2 	= 0;					/* m2 = counter for two year SMA	*/
		sma11 	= 0;					/* sma11 = one year SMA variable	*/
		sma23 	= 0;					/* sma23 = two year SMA variable	*/
		mdelta 	= 0;					/* mdelta used when multiple SMA / year	*/

		RE1 	= 0;					/* RE1 = counter for leading REP var	*/
		rlead 	= 0;					/* rlead = leading REP var		*/
		rldelta = 0;					/* rldelta used when multiple rleads	*/
		SL1 	= 0;					/* SL1 = counter for leading SEO var	*/
		slead 	= 0;					/* slead = leading SEO var		*/
		sldelta = 0;					/* sldelta used when multiple sleads	*/
	end;

	retain r1 r2 r3 rep11 rep23 rep35;			/* deals with REP			*/

	if (r1 = .) then r1 = 0;				/* initializes counters			*/
	if (r2 = .) then r2 = 0;
	if (r3 = .) then r3 = 0;
	
	if (rep11 = .) then rep11 = 0;
	if (rep23 = .) then rep23 = 0;
	if (rep35 = .) then rep35 = 0;

	if (category = "REP" and r1 = 0) then do;		/* set flag if existing data matches	*/
		if ((log_mkt_val ne . ) or (ret1 ne .)) then do;
			r1 = 1;
			rep11 = 1;
		end;
	end;

	if (category = "REP" and r1 > 1) then rdelta = r1;	/* accounts for multiple REP / year	*/

	if (r1 = 12) then do;					/* rolls value over to second year	*/
		r2 = 1;
		rep23 = 1;
	end;

	if (r1 = 12 + rdelta) then do;				/* re initialize annual counter to zero	*/
		r1 = 0;
		rep11 = 0;
	end;

	if (r2 = 12) then do;					/* rolls value over to third year	*/
		r3 = 1;
		rep35 = 1;
	end;

	if (r2 = 12 + rdelta) then do;				/* re initialize two year counter to 0	*/
		r2 = 0;
		rep23 = 0;
		rdelta = 0;
	end;
		
	if (r3 = 12 + rdelta) then do;				/* re initialize three year counter to 0*/
		r3 = 0;
		rep35 = 0;
	end;

	if (lag(rep11) = 1) then do;				/* roll counter forward			*/
		if (r1 ne 0) then do;
			rep11 = 1;
			r1 + 1;
		end;
		if (r1 = 0) then rep11 = 0;
	end;

	if (lag(rep23) = 1) then do;
		if (r2 = 0) then rep23 = 0;
		if (r2 ne 0) then do;
			rep23 = 1;
			r2 + 1;
		end;
	end;

	if (lag(rep35) = 1) then do;
		if (r3 = 0) then rep35 = 0;
		if (r3 ne 0) then do;
			rep35 = 1;
			r3 +1;
		end;
	end;							/* finishes REP cases			*/

        retain s1 s2 s3 seo11 seo23 seo35;			/* handles SEO cases			*/

        if (s1 = .) then s1 = 0;				/* initializes counters			*/
        if (s2 = .) then s2 = 0;
        if (s3 = .) then s3 = 0;

        if (seo11 = .) then seo11 = 0;
        if (seo23 = .) then seo23 = 0;
        if (seo35 = .) then seo35 = 0;

        if (category = "SEO" and s1 = 0) then do;		/* set flag if existing data matches	*/
            	if ( (log_mkt_val ne . ) or (ret1 ne .)) then do;
			s1 = 1;
                	seo11 = 1;
        	end;	
	end;

	if (cateogry = "SEO" and s1 > 1) then sdelta = s1;	/* accounts for multiple SEO / year	*/

        if (s1 = 12) then do;					/* rolls value over to second year	*/
                s2 = 1;
                seo23 = 1;
        end;

	if (s1 = 12 + sdelta) then do;				/* re initialize annual count to zero	*/
		s1 = 0;
		seo11 = 0;
	end;

        if (s2 = 12) then do;					/* rolls value over to third year	*/
                s3 = 1;
                seo35 = 1;
        end;

	if (s2 = 12 + sdelta) then do;				/* re initialize two year count to zero	*/
		s2 = 0;
		seo23 = 0;
		sdelta = 0;
	end;

        if (s3 = 12) then do;					/* re initialize three yr count to zero	*/
                s3 = 0;
                seo35 = 0;
        end;

        if (lag(seo11) = 1) then do;				/* roll counter forward			*/
                if (s1 ne 0) then do;
                        seo11 = 1;
                        s1 + 1;
                end;
                if (s1 = 0) then seo11 = 0;
        end;

        if (lag(seo23) = 1) then do;
                if (s2 = 0) then seo23 = 0;
                if (s2 ne 0) then do;
                        seo23 = 1;
                        s2 + 1;
                end;
        end;

        if (lag(seo35) = 1) then do;
                if (s3 = 0) then seo35 = 0;
                if (s3 ne 0) then do;
                        seo35 = 1;
                        s3 +1;
                end;
        end;							/* finishes SEO cases			*/

        retain m1 m2 sma11 sma23;				/* handles SMA cases			*/

        if (m1 = .) then m1 = 0;				/* initializes counters			*/
        if (m2 = .) then m2 = 0;
        
        if (sma11 = .) then sma11 = 0;
        if (sma23 = .) then sma23 = 0;

        if (category = "SMA" and m1 = 0) then do;		/* set flag if existing data matches	*/
		if ( (log_mkt_val ne .) or (ret1 ne .)) then do;
                	m1 = 1;
                	sma11 = 1;
        	end;
	end;

	if (category = "SMA" and m1 > 1) then mdelta = m1;	/* accounts for multiple SMA / year	*/

        if (m1 = 12) then do;					/* rolls value over to second year	*/
                m2 = 1;
                sma23 = 1;
        end;

	if (m1 = 12 + mdelta) then do;				/* re initializes one yr count to zero	*/
		m1 = 0;
		sma11 = 0;
	end;

        if (m2 = 12 + mdelta) then do;				/* re initializes two yr count to zero	*/
                m2 = 0;
                sma23 = 0;
		mdelta = 0;
	end;

        if (lag(sma11) = 1) then do;				/* roll counter forward			*/
                if (m1 ne 0) then do;
                        sma11 = 1;
                        m1 + 1;
                end;
                if (m1 = 0) then sma11 = 0;
        end;

        if (lag(sma23) = 1) then do;
                if (m2 = 0) then sma23 = 0;
                if (m2 ne 0) then do;
                        sma23 = 1;
                        m2 + 1;
                end;
        end;							/* end of SMA cases			*/

	retain SL1 slead sldelta;				/* handles SEO and REP lead cases	*/
	retain RE1 rlead rldelta;

	if (SL1 = .) then SL1 = 0;				/* initialize counters			*/
	if (slead = .) then slead = 0;

	if (RE1 = .) then RE1 = 0;
	if (rlead = .) then rlead = 0;

	if (category = "SEO Lead" and SL1 = 0) then do;		/* set flag for SEO lead data		*/
		if ( (log_mkt_val ne .) or (ret1 ne .)) then do;
			SL1 = 1;
			slead = 1;
		end;
	end;
	
	if (category = "SEO Lead" and SL1 > 1) 			/* accounts for multiple SEOs / year	*/
					then sldelta = SL1;

	if (SL1 = 12 + sldelta) then do;			/* re initialize flags			*/
		SL1 = 0;
		slead = 0;
		sldelta = 0;
	end;

	if (lag(slead) = 1) then do;				/* roll counter forward			*/
		if (SL1 ne 0) then do;
			slead = 1;
			SL1 + 1;
		end;
		if (SL1 = 0) then slead = 0;
	end;

	if (category = "REP Lead" and RE1 = 0) then do;		/* set flag for REP lead data		*/
		if ( (log_mkt_val ne . ) or (ret1 ne . )) then do;	
			RE1 = 1;
                	rlead = 1;
        	end;
	end;

        if (category = "REP Lead" and RE1 > 1)			/* accounts for multiple REPs / year	*/
					then rldelta = RE1;

        if (RE1 = 12 + rldelta) then do;			/* re initialize flags			*/
                RE1 = 0;
                rlead = 0;
                rldelta = 0;
        end;

        if (lag(rlead) = 1) then do;				/* roll counter forward			*/
                if (RE1 ne 0) then do;
                        rlead = 1;
                        RE1 + 1;
                end;
                if (RE1 = 0) then rlead = 0;
        end;							/* end of lead cases			*/
	
	if ( (log_mkt_val ne .) or (ret1 ne .)) then output;	/* makes sure one more time that all 	*/
								/* vars are within date range		*/
run;

*proc print data = setFlag(obs = 1000 keep = permno c_date rep11 seo11 sma11 sma23 ret1 ret6 ret12 mom);
*run;
*endsas;
