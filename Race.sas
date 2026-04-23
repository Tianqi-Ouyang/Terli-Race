proc import datafile="C:\Users\to909\Desktop\Projects\Shelsea\CKD\All_edited_new_12142022.xlsx" 
dbms=xlsx  out=master_race replace;
run;
data master_race;
set master_race;
if race=3 then race_cat ="Black or African American";
else if race=5 then race_cat ="White";
else race_cat ="Other";
if ethnicity = 1 then ethnicity_cat = "Hispanic";
else if ethnicity = 2 then ethnicity_cat = "Non Hispanic";
else if ethnicity = 3 then ethnicity_cat = "Unknown";
keep ethnicity ethnicity_cat palliative_care death_in_90days_status;
run;


proc format;
  value death_in_90days_status
    1 = 'Dead'
    0 = 'Alive';

  value palliative_care
    1 = 'Yes'
    0 = 'No';
    run;


proc sort data = master_race;
by  descending palliative_care descending death_in_90days_status;
run;


ODS PDF FILE = 'C:\Users\to909\Desktop\Projects\Subanalysis_race\palliative_care_death.pdf';
proc freq data=master_race order=data;
 
   tables ethnicity_cat*palliative_care*death_in_90days_status/norow cmh;
   where ethnicity ^= 3;
   format death_in_90days_status death_in_90days_status.  palliative_care palliative_care.;
run;
ODS PDF close;





proc logistic data=master_race;
class palliative_care ethnicity_cat/ param=ref ;
model death_in_90days_status = palliative_care ethnicity_cat;
run; 

proc logistic data=master_race;
  class palliative_care(ref="0")  ethnicity_cat/ param=ref ;
  model death_in_90days_status(ref="0") = palliative_care ethnicity_cat;

run;

proc logistic data=master_race;
  class palliative_care(ref="0")  /param=ref ;
  model death_in_90days_status(ref="0") = palliative_care;

run;
