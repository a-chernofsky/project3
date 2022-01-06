PROC IMPORT OUT= WORK.METABs 
            DATAFILE= "X:\cpet_pa_metab_mediation\data\metabs.xlsx" 
            DBMS=EXCEL REPLACE;
     RANGE="Sheet1$"; 
     GETNAMES=YES;
     MIXED=NO;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;
