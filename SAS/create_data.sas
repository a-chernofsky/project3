/****************************************************************************************************
*
* 001 CPET-PA-Metabolits Mediation
* Date created: 09/10/2020
*
*
*****************************************************************************************************/

*libraries for permanent data;
libname pa 'X:\PA_Data\t_physacts_2019_m_1256';
libname cpet 'X:\project3\data';
libname core 'Y:\FRAMDATA\2 -  Datasets -  Core';

/******************** Read in PA Data ********************/

*Read in PA data
	- convert MV Day by quartiles;
data g3e3pa;
	set pa.t_physacts_2019_m_1256;
	drop META_SED_DAY META_LIGHT_DAY META_MOD_DAY META_VIG_DAY META_MV_DAY KIN_SED_DAY KIN_LIGHT_DAY KIN_MOD_DAY
			KIN_VIG_DAY TOT_BOUTMETA_SEDENTARY_DAY TOT_BOUTMETA_LIGHT_DAY TOT_BOUTMETA_MODERATE_DAY
			TOT_BOUTMETA_VIGOROUS_DAY TOT_BOUTMETA_MVPA_DAY STARTTIME 
			PEAKDAY1_DAY PEAKDAY5_DAY PEAKDAY10_DAY PEAKDAY30_DAY PEAKDAY60_DAY;
	if exam = 3;
	if SOL_MV_DAY <= 10 then MV_DAY_CAT = 1;
	else if 10 < SOL_MV_DAY <= 21.4 then MV_DAY_CAT = 2;
	else if 21.4 < SOL_MV_DAY <= 30 then MV_DAY_CAT = 3;
	else if SOL_MV_DAY > 30 then MV_DAY_CAT = 4;
	else MV_DAY_CAT = .;

	MINS_DAY = HRS_DAY * 60;
	SED_DAY_REL = (SOL_SED_DAY/HRS_DAY)*18;
run;

/******************** Read in CPET Data ********************/

*Read in cpet data
	- create numeric id variable;
data g3e3cpet;
	set cpet.temp_t_cpetvvc02_ex03_3_1225_v1;
	idnum = idtype * 10000 + id;
	if idtype=3 then do;
	if id = 4453 then Peak_VCO2_abs = 3571; 
	if id = 689 then Peak_VE = 59.35;
	if id = 6946 then Peak_VT = 2273;
	if id = 3262 then Peak_PETO2 = 105;
	if id = 8675 then VO2rd = 46;
end;
run;

/******************** Read in Metabolites Data ********************/

PROC IMPORT OUT= WORK.METAB 
            DATAFILE= "X:\project3\data\metabs.xlsx" 
            DBMS=EXCEL REPLACE;
     RANGE="Sheet1$"; 
     GETNAMES=YES;
     MIXED=NO;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;

/*data metab1;
	set metab;
	idnum = idtype * 10000 + id;
	keep idnum NBL_trimethylbenzene -- actical_use;
run;*/

*Read in exam data;
data exam3 (rename = (G3C0687 = STATE 
						G3C0748 = PAI_SLEEP 
						G3C0749 = PAI_SEDENTARY 
						G3C0750 = PAI_SLIGHT 
						G3C0751 = PAI_MODERATE 
						G3C0752 = PAI_HEAVY 
						G3C0139 = HBPMED 
						G3C0143 = DIABETESMED 
						G3C0140 = CHOLMED 
						G3C0144 = CVDMED
						G3C0357 = miop1
						G3C0655 = miop2 
						G3C0318 = chfop1
						G3C0652 = chfop2
						G3C0356 = ciop1
						G3C0654 = ciop2
						G3C0436 = stroketiaop1
						G3C0659 = stroketiaop2
						G3C0323 = sys1
						G3C0324 = dia1
						G3C0507 = sys2
						G3C0508 = dia2));
	set core.e_exam_ex03_3b_1069;
	if idtype = 2 or idtype = 3 or idtype = 72;
	idnum = idtype * 10000 + id;
	*calculate PAI;
	pai = G3C0748 + G3C0749 * 1.1 + G3C0750 * 1.5 + G3C0751 * 2.4 + G3C0752 * 5;
	keep id idtype idnum G3C0245 G3C0687 G3C0748 G3C0749 G3C0750 G3C0751 G3C0752 
					G3C0139 G3C0143 G3C0140 G3C0144 G3C0357 
					G3C0655 G3C0318 G3C0652 G3C0356 G3C0654 
					G3C0436 G3C0659 G3C0323 G3C0324 G3C0507 
					G3C0508  pai;
run;

*race data;
data race;
	set core.vr_raceall_2008_a_0712 (keep=idtype id race_code);
	idnum = id + idtype*10000;
	if race_code in ('W','E','ER','EW') or substr(race_code,1,1)=" " then white=1; else white=0;
	if race_code = 'B' then black=1; else black=0;
run;
 
* Lab variables exam 3;
data lab3; 
	set core.l_fhslab_ex03_3b_1170;  
	if idtype in (2,3,72);
	idnum = idtype * 10000 + id;
	keep idtype id idnum glucose fasting cholesterol hdl;
run;

* Exam dates;
data exdates; 
	set core.vr_dates_2019_a_1175; 
	if idtype in (2,3,72); if att3=1; 
	idnum = idtype * 10000 + id;

	keep idtype id idnum sex date3 age3;  
run;

/* subset of cvd includes MI, coronary insufficiency, stroke or tia, heart failure */
data cvd; 
	set core.vr_soe_2018_a_1311; 
	if idtype in (2,3,72);
	if event in (1,2,3,7,11-15,40,41);
	idnum = idtype * 10000 + id;
run;

proc sort data=cvd; by idtype id date; run;

data cvd1; 
	set cvd; 
	by idtype id; 
	if first.id; 
run;

*****************smoking status*******************;

data smoke1; 
	set core.e_exam_ex01_3_0086_v2 (keep=idtype id g3a070-G3A072)
		core.e_exam_ex01_2_0813 (keep=idtype id g3a070-G3A072)
		core.e_exam_ex01_72_0652 (keep=idtype id g3a070-G3A072);
	idnum = idtype * 10000 + id; 
run;

data smoke2;
	set core.e_exam_2011_m_0017_v1 (keep = idtype id g3b0091);
	idnum = idtype * 10000 + id;
run;

data smokestat_1_2;
	set core.vr_wkthru_ex02_3b_0464_v4 (keep = id idtype CURRSMK1 CURRSMK2 age1 age2);
	idnum = id + idtype*10000;
run;

data smokestat3;
	set core.e_exam_ex03_3b_1069 (rename = (G3C0246 = SMKYR3));
	idnum = idtype * 10000 + id;
	keep idnum id idtype CURRSMK3 SMKYR3;
run;

proc sort data = smoke1; by idnum;
proc sort data = smoke2; by idnum;
proc sort data = smokestat_1_2; by idnum;
proc sort data = smokestat3; by idnum;
proc sort data = exdates; by idnum;

data smokestat;
	merge smoke1 smoke2 smokestat_1_2 smokestat3 exdates;
	by idnum;

	if currsmk1=1 then smstat1=2;
	else if g3a070=1 then smstat1=1;
	else if currsmk1=0 and g3a070=0 and g3a072=0 then smstat1=0;

	if age1=. then smstat1=.;
	if currsmk2=1 then smstat2=2;
	else if smstat1 > 0 or g3b0091 = 1 then smstat2=1;
	else if currsmk2=0 and smstat1=0 then smstat2=0;

	if age2=. then smstat2=.;

	if SMKYR3 = 1 then smstat3 = 2;
	else if SMKYR3 = 0 then do;
		if G3C0245=1 or smstat2 > 0 or smstat1 > 0 then smstat3 = 1;
		else if smstat1 = 0 and smstat2 <= 0 then smstat3 = 0;
	end;
	if age3 = . then smstat3 = .;
	keep idnum smstat1 smstat2 smstat3 SMKYR3 age3;
run;

proc freq data = smokestat;
	table smstat3 / missing;
run;

/******************** Merge Data ********************/

*sort data to merge by idnum;
proc sort data = g3e3cpet; by idnum; 
proc sort data = exdates; by idnum; 
proc sort data = exam3; by idnum; 
proc sort data = race; by idnum; 
proc sort data = lab3; by idnum; 
proc sort data = g3e3pa; by idnum; 
proc sort data = cvd1; by idnum; 
proc sort data = smokestat; by idnum;
proc sort data = metab1; by idnum;

data all;
	merge g3e3cpet (in = incpet) g3e3pa (in = inpa) exam3 exdates race lab3 g3e3pa cvd1 (in = incvd) smokestat metab;
	by idnum;
	if incpet = 1;

	*Create Transformed Variable;
	SQRT_VO2RD_EX = sqrt(VO2RD_ex + 1);
	LOG_PEAK_VO2_REL_EX = log(PEAK_VO2_REL_EX);
	LOG_O2PULSE_SLOPE = log(O2PULSE_SLOPE+1);
	LOG_AT_FINAL_REL = log(AT_FINAL_REL + 1);
	MAP_75 = (SBP_75 + 2*DBP_75)/3;
	Post_AT_VO2 = Peak_VO2_rel - AT_final_rel;
	
	*create inclusion criteria indicator;
	if incpet = 1 and inpa = 1 and metab_base = 1 then inall = 1;

	female = sex - 1;

	MAP_75 = (SBP_75 + 2*DBP_75)/3;
	Post_AT_VO2 = Peak_VO2_rel - AT_final_rel;

	*Create Northeast;
	if state = 'MA' or 
		state = 'VT/NH' or 
		state = 'CT' or 
		state = 'RI' or 
		state = 'ME' or 
		state = 'NY'  
		then NE = 1;
	else if state = "." then NE = .;
	else NE = 0;

	*create BMI categories;
	if bmi < 25 then bmicat = "normal";
	else if 25 <= bmi < 30 then bmicat = "over";
	else if bmi >= 30 then bmicat = "obese";
	else bmicat = " ";

	*Create Season Variable;
	if 9 <= month(ACTICAL_DATE) < 12 then season = 1;
	else if month(ACTICAL_DATE) = 12 or month(ACTICAL_DATE) < 3 then season = 2;
	else if 3 <= month(ACTICAL_DATE) < 6 then season = 3;
	else if 6 <= month(ACTICAL_DATE) < 9 then season = 4;

	*summarized blood pressure;
	sbp = mean(of sys1 sys2);
	dbp = mean(of dia1 dia2);

	*indicator for hypertension;
	if hbpmed=1 or sbp>=130 or dbp>=80 then htn=1;
	else if hbpmed=0 and sbp>0 and dbp>0 then htn=0;

	*indicator of diabetes metillus;
	if diabetesmed=1 or (fasting=1 and glucose >= 126) or glucose >= 200 then dm=1;
	else if diabetesmed=. or glucose=. then DM=.;
	else dm=0;

	*indicator of cvd;
	cvd = (cvdmed=1) or (chfop1=1 and chfop2=1) or (ciop1=1 and ciop2=1)
		or (miop1=1 and miop2=1) or (stroketiaop1=1 and stroketiaop2=1)
		or (incvd=1 and date <= date3);

	*Exclusion criteria;
	if inall = 1 then do;
		if peak_rer < 1 then exclude1 = 1;
		if adherentyn = 0 then exclude2 = 1;
		if cnts_day > 3000000 then exclude3 = 1;
		if steps_day = 0 then exclude4 = 1;
		if steps_day > 30000 or sed_day_rel <= 400 then exclude5 = 1;
		if cmiss(age_exercise_rounded, white, bmi, female, smstat3, htn, dm) >= 1 then exclude6 = 1;
	end;

	hr_pred_tanake = 208 - (0.7 * AGE_EXERCISE_ROUNDED);
    hr_pcnt_pred_tanake = (peak_hr/hr_pred_tanake) * 100;

format ACTICAL_DATE date9.;
 
run;

proc freq data = all;
	tables metab_base * met_guide; run;

	proc freq data = all;
	tables inall; run;

proc freq data = all;
	tables exclude1; 
run;

proc freq data = all;
	where exclude1 = .;
	tables exclude2; 
run;

proc freq data = all;
	where exclude1 = . and exclude2 = .;
	tables exclude3; 
run;

proc freq data = all;
	where exclude1 = . and exclude2 = . and exclude3 = .;
	tables exclude4; 
run;

proc freq data = all;
	where exclude1 = . and exclude2 = . and exclude3 = . and exclude4 = .;
	tables exclude5; 
run;

proc freq data = all;
	where exclude1 = . and 
			exclude2 = . and 
			exclude3 = . and 
			exclude4 = . and
			exclude5 = .;
	tables exclude6; 
run;


/******************** Export Data ********************/

data cpet.project3_data (rename =(AGE_EXERCISE_ROUNDED = AGE3 actical_date = actical_date3 N_ADH_DAYS = N_ADH_DAYS3
		hrs_day = hrs_day3 mins_day = mins_day3 cnts_day = cnts_day3 
		SOL_SED_DAY = sed_day3 SED_DAY_REL = SED_DAY_REL3 SOL_MV_DAY = mv_day3 mv_day_cat = mv_day_cat3
		steps_day = steps_day3 season = season3 adherentyn = adherentyn3));
	set all;
run;



