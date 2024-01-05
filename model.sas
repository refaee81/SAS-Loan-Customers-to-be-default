libname TT "\\file1\LabShare\SASProject\data";
proc contents data=tt.HMEQ
;
run;

/**********
              #    Variable    Type    Len    Label

              1    bad         Num       8    Default or seriously delinquent
             10    clage       Num       8    Age of oldest trade line in months
             12    clno        Num       8    Number of trade (credit) lines
             13    debtinc     Num       8    Debt to income ratio
              9    delinq      Num       8    Number of delinquent trade lines
              8    derog       Num       8    Number of major derogatory reports
              6    job         Char      6    Prof/exec sales mngr office self other
              2    loan        Num       8    Amount of current loan request
              3    mortdue     Num       8    Amount due on existing mortgage
             11    ninq        Num       8    Number of recent credit inquiries
              5    reason      Char      7    Home improvement or debt consolidation
              4    value       Num       8    Value of current property
              7    yoj         Num       8    Years on current job

bad
clage
clno
debtinc
delinq
derog
job
loan
mortdue
ninq
reason
value
yoj

***********/


proc freq data=tt.hmeq;
   tables bad reason job;
run;

data Hmeq(drop=job reason);/* we change the char variables into numberic and then drop them in same line*/
  set tt.Hmeq;
  JOB_Mgr=(JOB='Mgr');
  JOB_Office=(JOB='Office');
  JOB_Other=(JOB='Other');
  JOB_ProfExe=(JOB='ProfExe');
  JOB_Sales=(JOB='Sales');
  JOB_Self=(JOB='Self');
  JOB_miss=(JOB=' ');
  REASON_DebtCon=(REASON='DebtCon');
  REASON_HomeImp=(REASON='HomeImp');
  REASON_Miss=(REASON=' ');
  /*
  if CLAGE=. then CLAGE=179.7662752;
  if CLNO=. then CLNO=21.2960962;
  if DEBTINC=. then DEBTINC=33.7799153;
  if DELINQ=. then DELINQ=0.4494424;
  if DEROG=. then DEROG=0.2545697;
  if LOAN=. then LOAN= 18607.97;
  if MORTDUE=. then MORTDUE=73760.82;
  if NINQ=. then NINQ= 1.1860550;
  if VALUE=. then VALUE=101776.05;
  if YOJ=. then YOJ= 8.9222681;
  */
run;

proc contents data=Hmeq;
run;

%let inter_var=

clage
clno
debtinc
delinq
derog
loan
mortdue
ninq
value
yoj
;

%LET DSN=Hmeq;
%LET RESP=BAD;
%LET GROUPS=10;

%MACRO LOGTCONT                         ;
      OPTIONS CENTER PAGENO=1 DATE;
	  data test;
	    set &DSN;
	  run;
	  %do i=6 %to 6;
	  %LET VBLE=%scan(&inter_var, &i);  
       PROC RANK DATA =TEST (KEEP=&RESP &VBLE)
               GROUPS = &GROUPS
                  OUT = JUNK1     ;
            RANKS NEWVBLE         ;
            VAR &VBLE             ;
       RUN                        ;

       PROC SUMMARY DATA = JUNK1 NWAY ;
            CLASS NEWVBLE             ;
            VAR &RESP &VBLE           ;
            OUTPUT OUT = JUNK2
                  MEAN =
                  MIN(&VBLE)=MIN
                  MAX(&VBLE)=MAX
                     N = NOBS         ;
       RUN                            ;

       DATA JUNK2                     ;
            SET JUNK2                 ;
            IF &RESP NE 0 THEN
               LOGIT = LOG ( &RESP / (1- &RESP) ) ;
            ELSE IF &RESP = 0 THEN LOGIT = .       ;
       RUN                            ;

       PROC SQL NOPRINT;
        CREATE TABLE JUNK3 AS
        SELECT 99 AS NEWVBLE, COUNT(*) AS NOBS, MEAN(&RESP) AS &RESP
        FROM test
        WHERE &VBLE=.
       ;

       DATA JUNK3;
        SET JUNK3;
        LOGIT=LOG(&RESP/(1-&RESP));
       RUN;


       DATA JUNK4;
        SET JUNK2 JUNK3;
       RUN;
	

       PROC PLOT DATA = JUNK4         ;
            TITLE1 "Plot of Logit(Response) by &&VBLE" ;
            PLOT  LOGIT* &VBLE        ;
       RUN  ;


        proc plot data=junk4;
        plot &resp*&vble;
        plot _freq_*&vble;
        TITLE2 "Plot of Response by &&VBLE" ;
        run;

       PROC PRINT DATA = JUNK4 LABEL SPLIT = '*' NOOBS ;
            TITLE3 "Table of Response by Grouped &&VBLE" ;
            VAR NEWVBLE NOBS &VBLE MIN MAX &RESP ;
            LABEL NEWVBLE = "&&VBLE Grouping"
                     NOBS = '# of*Records'
                     LOGIT = "Logit of Response"
                     MIN   ='MIN'
                     MAX   ='MAX'                       ;
       RUN                                             ;

	   %end;


%MEND LOGTCONT      ;
%LOGTCONT      ;

data Hmeq1;
  set Hmeq;
  /*
  JOB_Mgr=(JOB='Mgr');
  JOB_Office=(JOB='Office');
  JOB_Other=(JOB='Other');
  JOB_ProfExe=(JOB='ProfExe');
  JOB_Sales=(JOB='Sales');
  JOB_Self=(JOB='Self');
  JOB_miss=(JOB=' ');
  REASON_DebtCon=(REASON='DebtCon');
  REASON_HomeImp=(REASON='HomeImp');
  REASON_Miss=(REASON=' ');
  */
  if CLAGE=. then CLAGE=95.205;
  if CLAGE>295 then CLAGE=295;
  if CLNO<10 then CLNO=0;
  if CLNO=. then CLNO= 42.2;
  if CLNO<15 then CLNO= 15;
     DEBTINC_MISS=(DEBTINC=.);
  if DELINQ=. then DELINQ=0;
  if DEROG=. then DEROG=0;
  if LOAN>30500 then LOAN=30500;
  if MORTDUE=. then MORTDUE= 46141.88;
  if NINQ=. then NINQ=0;
     VALUE_MISS=(VALUE=.);
  if YOJ=. then YOJ=25;
run;

PROC CONTENTS DATA=Hmeq;
RUN;

%LET INPUT2=

JOB_Mgr
JOB_Office
JOB_Other
JOB_ProfExe
JOB_Sales
JOB_Self
JOB_miss
REASON_DebtCon
REASON_HomeImp
REASON_Miss
VALUE_MISS
clage
clno
delinq
derog
loan
mortdue
ninq
yoj
;

proc logistic data=Hmeq1 descending;
model bad=&input2
  /selection=stepwise fast lackfit rsquare corrb stb;
run;

%LET INPUT3=
DEBTINC_MISS
JOB_Office
JOB_Other
JOB_Sales
JOB_Self
JOB_miss
REASON_HomeImp
VALUE_MISS
clage
clno
delinq
derog
ninq
yoj
;

proc logistic data=Hmeq descending;
model bad=&input3
  /selection=stepwise fast lackfit rsquare corrb stb;
run;


%LET INPUT4=
DEBTINC_MISS
JOB_Office
JOB_Sales
JOB_miss
REASON_HomeImp
VALUE_MISS
clage
clno
delinq
derog
ninq
yoj
;

proc logistic data=Hmeq1 descending;
model bad=&input4
  /selection=stepwise fast lackfit rsquare corrb stb;
run;



data val;
  set Hmeq1;
Logit=
-1.5204		
+2.6277		*	DEBTINC_MISS	/*Debt to income ratio IS MISSING */
-0.6524		*	JOB_Office
+1.1876		*	JOB_Sales
-1.933		*	JOB_miss
+0.2527		*	REASON_HomeImp	/*Home improvement */
+4.5662		*	VALUE_MISS		/*Value of current property IS MISSING */
-0.00616	*	clage			/*Age of oldest trade line in months*/
-0.0148		*	clno			/*Number of trade (credit) lines*/
+0.6875		*	delinq			/*Number of delinquent trade lines*/
+0.5215		*	derog			/*Number of major derogatory reports*/
+1.32E-01	*	ninq			/*Number of recent credit inquiries*/
-0.0168		*	yoj				/*Years on current job*/
;

prob=1/(1+exp(-logit)); 
run;

proc sort data=val out=val1;
   by descending prob;
run;

proc rank		data = val1
				out = val_ranked
				groups = 20
				descending;
		var		prob;
		ranks	rank;
run;

data val_ranked(drop=rank prob);
set val_ranked;
	model_rank=rank + 1;
	model_score=prob;
	
run;

PROC TABULATE DATA = val_ranked MISSING NOSEPS;
            CLASS model_rank        ;
            VAR   model_score     bad  ;
	TABLES model_rank ALL, model_score*MEAN*F=5.3 bad='BAD'*(sum='# of Bad' n='# of Acct' mean*F=5.3);
RUN;

data development;
  set tt.Hmeq;
  if ranuni(1234567)<=0.6;
run;
