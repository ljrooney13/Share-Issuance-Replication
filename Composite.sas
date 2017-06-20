/****************************************************************************
 The following code recreates the Pontiff and Woodgate 2008 JF paper titled
 "Share Issuance and Cross Sectional Return". 
 ****************************************************************************/

/****************************************************************************
 Set up the macro variable definitons to be used throughout the program to 
 keep track of the situations being run.
 ****************************************************************************/

%let startdt = '1Jan1965'd;

%let enddt    = '31Dec2003'd;

*%let where = where = (permno in (10107 14593 15159));
%let where = where = (date between &startdt and &enddt);

*%let where_comp = where = (gvkey in ('012141' '001690' '022629'));
%let where_comp = ;

%let issue11 = 11;
%let issue59  = 59;
%let issue23 = 23;

/****************************************************************************
 Include relevant macros from Lew.
 ****************************************************************************/

%include "&_macros/utility.sas";
%include "&_macros/mk_history.sas";
%include "&_macros/compustat_macros.sas";
%include "&_macros/compustat_crsp_utility_macros.sas";
%include "&_macros/winsorize.sas";

/****************************************************************************
 IssuesData.sas retrieves and filters the data from the CRSP Monthly Stock
 File. It eliminates observations from firms that have not been in the
 database for more than 6 months. It also pulls the index data and includes
 an equally weighted return number for each date used.                           
 *****************************************************************************/

%include "IssuesData.sas";

/****************************************************************************
 momentum.sas calculates the momentum variable. It calculates a rolling 6 month
 return variable that is used as a proxy for momentum. It is lagged by one
 month to avoid any positive autocorrelation.
 ****************************************************************************/

%include "momentum.sas";

/*****************************************************************************
 IssueCalcs.sas takes the data from IssuesData.sas and performs
 initialization calculations to it. It calculates dummy variables, adjusted 
 shares, and total issuances for given time periods.
 *****************************************************************************/

%include "IssueCalcs.sas";

/****************************************************************************
 returns.sas calculates the rolling returns used as dependent variables in
 the calculations. Uses array sot do the rolling returns. Each rolling return
 value gets its own data set as this makes date matching easier.
 ****************************************************************************/

%include "returns.sas";
%include "portfolio.sas";
/****************************************************************************
 compdata.sas pulls data from Compustat and sets up a link file in order to 
 merge the Compustat gvkeys with the CRSP permnos. Can specify what compustat
 data you want to be pulled.
 ****************************************************************************/

%include "compdata.sas";

/****************************************************************************
 bmcalc.sas calculates the book value and equity market values for the data set
 and calculates the book to market value to be used going forward.
 ****************************************************************************/

%include "bmcalc.sas";

/*****************************************************************************
 DescriptiveStat.sas calculates the simple descriptive statistics found in the
 paper. Creates a replication of Table 1 on p927.
 *****************************************************************************/

%include "DescriptiveStat.sas";

/****************************************************************************
 ActData simply outputs the actual results from the paper. It is a replication
 of Table 1: Descriptive Statistics, Panel A: Simple Statistics. It is
 intended as a check against the actual results being run.
 ****************************************************************************/

%include "ActData.sas";

/****************************************************************************
 Namematch brings in an excel file of SDC data and uses the 6 digit SIC codes
 to match to permnos. The output is a file containing permnos and a flag on
 one of four different activities. These are: repurchases (REP), seasoned 
 equity offerings (SEO), mergers with stock (SMA) and mergers with unknown
 consideration (UMA).

 ****************************************************************************/

%include "NameMatch.sas";

/****************************************************************************
 setFlag uses the REP / SEO / SMA / UMA designations from the SDC data to set
 different levels of flags to be used when running regressions. Uses trailing
 one, two and three years for REP and SEO, and trailing one and two years for
 SMA and UMA.
 ****************************************************************************/

%include "setFlag.sas";

/****************************************************************************
 createStata reformats the data to be in a format that is useable for stata
 ****************************************************************************/

%include "createStata.sas";

