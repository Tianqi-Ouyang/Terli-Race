library(tidyverse)
library(tableone)
library(gtsummary)
library(survival)
library(ggplot2)
library(readxl)
library(ggpubr)
library(splines)
library(xlsx)
library(optmatch)
library(MatchIt)


setwd('/Users/to909/Desktop/Andrew')
all<- read_excel("All_edited_new_12142022.xlsx")


Baylor0913<- read_excel("Baylor0913.xlsx") %>% select(study_id,race)
Indiana0913 <- read_excel("Indiana0913.xlsx") %>% select(study_id,race)
Jacksonville0913<- read_excel("Jacksonville0913.xlsx") %>% select(study_id,race)
Kentukey0913<- read_excel("Kentukey0913.xlsx")  %>% select(study_id,race)
MCW0913<- read_excel("MCW0913.xlsx")%>% select(study_id,race)
MGH0913<- read_excel("MGH0913.xlsx")%>% select(study_id,race)
Michigan0913<- read_excel("Michigan0913.xlsx")%>% select(study_id,race)
Oschner0913<- read_excel("Oschner0913.xlsx")%>% select(study_id,race)
Rochester0913<- read_excel("Rochester0913.xlsx")%>% select(study_id,race)
USC0913<- read_excel("USC0913.xlsx")%>% select(study_id,race)
Yale0913<- read_excel("Yale0913.xlsx")%>% select(study_id,race)
race_added <- rbind(Baylor0913,Indiana0913,Jacksonville0913,Kentukey0913,MCW0913,MGH0913,Michigan0913,Oschner0913,Rochester0913,USC0913,Yale0913) 


all <- merge(all,race_added, by="study_id",all.x=TRUE)

#check variables  
str_sort(names(all))
table(all$ethnicity, useNA = "always")
table(all$race_cat, useNA = "always")
table(all$race,useNA = "always")

all <- all %>% mutate(ethnicity=ifelse(ethnicity==1,"Hispanic",ifelse(ethnicity==2,"Non-Hispanic","Unknown")))
All <- all %>% mutate(type_of_aki=case_when(
  final_type_of_aki == 1 ~ "Prerenal",
  final_type_of_aki == 2 ~ "HRS-AKI",
  final_type_of_aki == 3 ~"ATN",
  final_type_of_aki == 4 ~"Other",
  final_type_of_aki == 5 ~"Unable to diagnosis")) %>%
  mutate(etiology_cirrhosis=case_when(
    etiology_cirrhosis == 1 ~ "Alcohol",
    etiology_cirrhosis == 2 ~ "HCV",
    etiology_cirrhosis == 3 ~ "NASH",
    etiology_cirrhosis == 5 ~ "Multifactorial",
    etiology_cirrhosis == 6 | etiology_cirrhosis == 7 | etiology_cirrhosis == 4 ~ "Other"))  %>% 
  mutate(race=case_when(
    race == 1 ~ "American Indian or Alaska Native",
    race == 2 ~ "Asian",
    race == 3 ~ "Black or African American",
    race == 4 ~ "Native Hawaiian or Other Pacific Islander",
    race == 5 ~ "White", 
    race == 6 ~ "Other", 
    race == 7 ~ "Unknown")) %>% 
  mutate(race_cat_new=case_when(
    race == "Black or African American" ~ "Black or African American",
    race == "White" ~ "White", 
    TRUE ~ "Other"
  ))%>%
  mutate(
   
      race_cat_5 = case_when(
        ethnicity == 2 & race == 5 ~ "NHW",  # Non-Hispanic White
        ethnicity == 1 & race == 5 ~ "HW",   # Hispanic White
        ethnicity == 2 & race == 3 ~ "NHB",  # Non-Hispanic Black
        ethnicity == 1 & race == 3 ~ "HB",   # Hispanic Black
        ethnicity %in% c(1, 2) & race %in% c(1, 2, 4, 6, 7) ~ "NWNB"
    )
  
  )
  

a <- All[,c("race_cat","race_cat_new")]

# all variables in the table
a <- All %>%filter(race=='Unknown')
table(All$race, useNA = "always")

# table 1 remove Unknown for race 
All_no_unknown <- All %>% filter(!race=='Unknown') 

all_var <- c(
  "age_admission","sex","White","hispanic_race","reason_for_admission","loop_diuretic","aldosterone_antagonist","lactulose","rifaximin",
  "prophylactic_antibiotic","nsaids","beta_blockers","albumin_given_admission","albumin_amount_admission",                       
  "albumin_given_prior","diabetes","cad","ckd","htn","etiology_cirrhosis","ascites_admission",
  "encephalopathy_admission","gi_bleed_admission","peritonitis_admission","hcc_admission","tips_admission","lvp_admission",
  "alcoholic_hepatitis_admission","na_admit","k_admit","cl_admit","co2_admit","bun_admit","creatinine_admission","urine_creatinine","ca_admit",                        "mg_admit","phos_admit",
  "peak_creatinine","alt_admit",	"alkphos_admit",	"tb_admit",		"alb_admit","nh3_admit","inr_admit",
  "wbc_admit",	"hct_admit",	"plt_admit","urine_sodium","fena","he_grade_admission","sbp_admission","dbp_admission","rrt","rrt_hemodialysis", "initial_rrt","icu_admission","hrs_vasoconstrictor","pressor","intubated",
  "respiratory_failure","liver_transplant_listed","liver_transplant","kidney_transplant", "palliative_care","discharge_disposition",
  "code_status","Akin","final_type_of_aki","MELD_baseline", "MELD_Na_baseline","site","AKI_responders","clif_score", "MAP",                   
  "CLIF_C_Score","aclf_grade","status_90days","time_90days", "Encephalopathy",
  "Alcoholic_hepatitis",
  "HCC",
  "New_diagnosis_of_cirrhosis",
  "Transplant_evalutation" ,
  "SBP",
  "aki_stage_4",
  "death_discharge",
  "baseline_creatinine",
  "admission_route",
  "los",
  "admission_route",
  "peak_creatinine",
  "rrt_hemodialysis",
  "rrt_crrt",
  "initial_rrt",
  "days_icu",
  "intubated",
  "death_discharge",
  "respiratory_failure",
  "readmissions",
  "liver_transplant",
  "kidney_transplant",
  "discharge_disposition",
  "cpr_given"
)



# all the categorical variables 
cat_var <- c(
  "sex","White","hispanic_race","reason_for_admission","loop_diuretic","aldosterone_antagonist","lactulose","rifaximin",
  "prophylactic_antibiotic","nsaids","beta_blockers","albumin_given_admission",                         
  "albumin_given_prior","diabetes","cad","ckd","htn","etiology_cirrhosis","ascites_admission",
  "encephalopathy_admission","gi_bleed_admission","peritonitis_admission","hcc_admission","tips_admission","lvp_admission",
  "alcoholic_hepatitis_admission",
  "he_grade_admission","rrt","rrt_hemodialysis","initial_rrt","icu_admission","hrs_vasoconstrictor","pressor","intubated",
  "respiratory_failure","liver_transplant_listed","liver_transplant","kidney_transplant", "palliative_care","discharge_disposition",
  "code_status","Akin","final_type_of_aki","site","AKI_responders",                   
  "aclf_grade", "Encephalopathy",
  "Alcoholic_hepatitis",
  "HCC",
  "New_diagnosis_of_cirrhosis",
  "Transplant_evalutation" ,
  "SBP",
  "aki_stage_4",
  "death_discharge",
  "admission_route",

  "rrt_hemodialysis",
  "rrt_crrt",
  "initial_rrt",
  "intubated",
  "death_discharge",
  "respiratory_failure",
  "readmissions",
  "liver_transplant",
  "kidney_transplant",
  "discharge_disposition",
  "cpr_given"
)


#create numerical variables
num_var <- setdiff(all_var,cat_var)


#create table one by race levels#
T1_race_all <- CreateTableOne(vars = all_var,strata = "race",includeNA = F,addOverall = TRUE,data = All_no_unknown, factorVars = cat_var)
#print table one 
T1_race_all_csv <- print(T1_race_all,exact = c("HCC","New_diagnosis_of_cirrhosis","kidney_transplant"), nonnormal=num_var,showAllLevels = T,missing = T,quote = FALSE, noSpaces = TRUE, printToggle = FALSE)
#save 
write.csv(T1_race_all_csv, file = "Table1_race_all.csv")




#create table one by race levels#
T1_race <- CreateTableOne(vars = all_var,strata = "race_cat",includeNA = F,addOverall = TRUE,data = All, factorVars = cat_var)
#print table one 
T1_race_csv <- print(T1_race,exact = c("HCC","New_diagnosis_of_cirrhosis","kidney_transplant","admission_route"), nonnormal=num_var,showAllLevels = F,missing = T,quote = FALSE, noSpaces = TRUE, printToggle = FALSE)
#save 
write.csv(T1_race_csv, file = "Table1_race.csv")



#create table one by race levels#
T1_ethnicity <- CreateTableOne(vars = all_var,strata = "ethnicity",includeNA = F,addOverall = TRUE,data = All, factorVars = cat_var)
#print table one 
T1_ethnicity_csv <- print(T1_ethnicity,exact = c("liver_transplant","kidney_transplant","Alcoholic_hepatitis","HCC","New_diagnosis_of_cirrhosis" ), nonnormal=num_var,showAllLevels = F,missing = T,quote = FALSE, noSpaces = TRUE, printToggle = FALSE)
#save 
write.csv(T1_ethnicity_csv, file = "Table1_ethnicity.csv")


########### remove unknown 
All_no_unknown <-All %>%  filter(!ethnicity=="Unknown")

#create table one by race levels#
T1_ethnicity_without_unknown <- CreateTableOne(vars = all_var,strata = "ethnicity",includeNA = F,addOverall = TRUE,data = All_no_unknown, factorVars = cat_var)
#print table one 
T1_ethnicity_without_unknown_csv <- print(T1_ethnicity_without_unknown,exact = c("kidney_transplant","Alcoholic_hepatitis","New_diagnosis_of_cirrhosis", "admission_route"), nonnormal=num_var,showAllLevels = F,missing = T,quote = FALSE, noSpaces = TRUE, printToggle = FALSE)
#save 
write.csv(T1_ethnicity_without_unknown_csv, file = "Table1_ethnicity_without_unknown.csv")



#create subcohort 
All_white <- All %>% filter(White==1)
All_nonwhite <- All %>% filter(White==0)
All_hispanic <- All %>% filter(ethnicity=="Hispanic")
All_nonhispanic <- All %>% filter(ethnicity=="Non-Hispanic")
All_unknown_ethnicity <- All %>% filter(ethnicity=="Unknown")
All_known_ethnicity <- All %>% filter(!ethnicity=="Unknown")
table(All$ethnicity)


table(All$White, useNA = "always")

#create table  for 90 days death white
T1_death_white <- CreateTableOne(vars = all_var,strata = "death_in_90days_status",includeNA = F,addOverall = TRUE,data = All_white, factorVars = cat_var)
#print table  
T1_death_white_csv <- print(T1_death_white,exact = c("liver_transplant","kidney_transplant"),nonnormal=num_var,showAllLevels = F ,missing = T,quote = FALSE, noSpaces = TRUE, printToggle = FALSE)
#save 
write.csv(T1_death_white_csv, file = "Table_2_90days_white.csv")

#create table  for 90 days death nonwhite
T1_death_nonwhite <- CreateTableOne(vars = all_var,strata = "death_in_90days_status",includeNA = F,addOverall = TRUE,data = All_nonwhite, factorVars = cat_var)
#print table  
T1_death_nonwhite_csv <- print(T1_death_nonwhite,exact = c("liver_transplant","kidney_transplant","initial_rrt","HCC","SBP"),nonnormal=num_var,showAllLevels = F ,missing = T,quote = FALSE, noSpaces = TRUE, printToggle = FALSE)
#save 
write.csv(T1_death_nonwhite_csv, file = "Table_2_90days_nonwhite.csv")

#create table  for 90 days death hispanic
T1_death_hispanic <- CreateTableOne(vars = all_var,strata = "death_in_90days_status",includeNA = F,addOverall = TRUE,data = All_hispanic, factorVars = cat_var)
#print table  
T1_death_hispanic_csv <- print(T1_death_hispanic,exact = c("liver_transplant","kidney_transplant","tips_admission","he_grade_admission","initial_rrt","respiratory_failure",                                                                       'discharge_disposition',"final_type_of_aki",
                                                           "aclf_grade","Alcoholic_hepatitis","HCC","New_diagnosis_of_cirrhosis","SBP"),nonnormal=num_var,showAllLevels = F ,missing = T,                                                            quote = FALSE, noSpaces = TRUE, printToggle = FALSE)
#save 
write.csv(T1_death_hispanic_csv, file = "Table_2_90days_hispanic.csv")

#create table  for 90 days death nonhispanic
T1_death_nonhispanic <- CreateTableOne(vars = all_var,strata = "death_in_90days_status",includeNA = F,addOverall = TRUE,data = All_nonhispanic, factorVars = cat_var)
#print table  
T1_death_nonhispanic_csv <- print(T1_death_nonhispanic,exact = c("liver_transplant","kidney_transplant","tips_admission","he_grade_admission","initial_rrt"                            
                                                                 ),nonnormal=num_var,showAllLevels = F ,missing = T,quote = FALSE, noSpaces = TRUE, printToggle = FALSE)
#save 
write.csv(T1_death_nonhispanic_csv, file = "Table_2_90days_nonhispanic.csv")


#create table  for 90 days death unknown_ethnicity
T1_death_unknown_ethnicity <- CreateTableOne(vars = all_var,strata = "death_in_90days_status",includeNA = F,addOverall = TRUE,data = All_unknown_ethnicity, factorVars = cat_var)
#print table  
T1_death_unknown_ethnicity_csv <- print(T1_death_unknown_ethnicity,exact = c("liver_transplant","kidney_transplant",
                                                                             "reason_for_admission","prophylactic_antibiotic","albumin_given_prior","etiology_cirrhosis",
                                                                             "peritonitis_admission","hcc_admission","tips_admission","he_grade_admission","initial_rrt",
                                                                             "respiratory_failure","liver_transplant_listed","liver_transplant","discharge_disposition",
                                                                             "code_status","final_type_of_aki","site","AKI_responders","aclf_grade","Encephalopathy",
                                                                             "Alcoholic_hepatitis","HCC","New_diagnosis_of_cirrhosis","Transplant_evalutation" 
                                                                             ),nonnormal=num_var,showAllLevels = F ,missing = T,quote = FALSE, noSpaces = TRUE, printToggle = FALSE)
#save 
write.csv(T1_death_unknown_ethnicity_csv, file = "Table_2_90days_unknown_ethnicity.csv")

#create table  for 90 days death known_ethnicity
T1_death_known_ethnicity <- CreateTableOne(vars = all_var,strata = "death_in_90days_status",includeNA = F,addOverall = TRUE,data = All_known_ethnicity, factorVars = cat_var)
#print table  
T1_death_known_ethnicity_csv <- print(T1_death_known_ethnicity,exact = c("liver_transplant","kidney_transplant"),nonnormal=num_var,showAllLevels = F ,missing = T,quote = FALSE, noSpaces = TRUE, printToggle = FALSE)
#save 
write.csv(T1_death_known_ethnicity_csv, file = "Table_2_90days_known_ethnicity.csv")






################################# PSA #################### 
library(cobalt)
library(MatchIt)

All_no_unknown <- All_no_unknown %>% filter(!race_cat=="Other") %>% mutate(race_cat_2=ifelse(race_cat=="White","White","Black or African American"))


All_no_unknown <- All_no_unknown %>% mutate_at(cat_var,factor)
All_no_unknown[, cat_var] <- lapply(All_no_unknown[, cat_var], as.factor)

missing <- sapply(All_no_unknown %>% select(age_admission,sex,cad,ckd,htn,MELD_Na_baseline,HCC,final_type_of_aki,admission_route,los), function(x) sum(is.na(x)))
missing[!missing==0]

All_no_unknown_imputated <- All_no_unknown %>% mutate(MELD_Na_baseline=replace_na(MELD_Na_baseline,median(MELD_Na_baseline,na.rm = T)))
All_no_unknown_imputated <- All_no_unknown_imputated %>% drop_na(sex,cad,ckd,htn,admission_route,los)

missing <- sapply(All_no_unknown_imputated %>% select(age_admission,sex,cad,ckd,htn,MELD_Na_baseline,HCC,final_type_of_aki,admission_route,los), function(x) sum(is.na(x)))
missing[!missing==0]

bal.tab(All_no_unknown_imputated  %>% select(
  age_admission,sex,cad,ckd,htn,MELD_Na_baseline,HCC,final_type_of_aki,admission_route,los
),
treat = All_no_unknown_imputated$race_cat_2,
s.d.denom = "pooled",
threshold = .1
)


All_no_unknown_imputated <- All_no_unknown_imputated %>% mutate(race_ps=ifelse(race_cat_2=="White",0,1))







ps_function <- f.build("race_ps", select(All_no_unknown_imputated,age_admission,sex,cad,ckd,htn,MELD_Na_baseline,HCC,final_type_of_aki))
psm <- glm(ps_function, data = All_race_2, family = binomial)
ps <- predict(psm, newdata = All_race_2, type = "response")
ps_logit <- log((1 - ps) / ps)

All_no_unknown_imputated$race_ps <- factor(All_no_unknown_imputated$race_ps)


table(All_no_unknown_imputated$race_cat_2)

# Greedy nearest neighbor matching without replacement
set.seed(1000)
matched_all <- matchit(
  ps_function,
  data = All_no_unknown_imputated,
  method ="optimal",
  distance = "logit",
  #m.order = "largest", # descending order
  discard ="control",
  ratio = 2
)

m.data1 <- match.data(matched_all, data = All_no_unknown_imputated)


g.matches1 <- get_matches(matched_all, data = All_race_2,
                          distance = "prop.score")
dim(m.data1) #one row per matched unit
head(m.data1)


names(m.data1)


bal.tab(m.data1 %>% select(
  age_admission,sex,cad,ckd,htn,MELD_Na_baseline,HCC,final_type_of_aki,admission_route,los
),
treat = m.data1$race_cat_2,
s.d.denom = "pooled",
threshold = .1
)

bal.plot(m.out, "race", which = "both")





#create table one by race levels#
T1_race_ps <- CreateTableOne(vars = all_var,strata = "race_cat_2",includeNA = F,addOverall = TRUE,data = m.data1, factorVars = cat_var)
#print table one 
T1_race_ps_csv <- print(T1_race_ps,exact = c("HCC","New_diagnosis_of_cirrhosis","kidney_transplant","admission_route"), nonnormal=num_var,showAllLevels = F,missing = T,quote = FALSE, noSpaces = TRUE, printToggle = FALSE)
#save 
write.csv(T1_race_ps_csv , file = "Table1_race_ps_2.csv")





################  cox regression ###################




all_var <-  c("age_admission","sex","cad","ckd","htn","MELD_Na_baseline","HCC","final_type_of_aki","death_in_90days_status","death_in_90days_time","race_cat_new","ethnicity")
all_num <- c("age_admission","death_in_90days_time","death_in_90days_status","MELD_Na_baseline")
all_cat <- setdiff(all_var ,all_num)

master <- All %>% filter(!race=='Unknown',!ethnicity=="Unknown")  %>% select(all_of(all_var)) %>% filter(!MELD_Na_baseline<0) %>% mutate(MELD_Na_baseline =replace_na(MELD_Na_baseline,median(MELD_Na_baseline,na.rm = TRUE))) %>% drop_na()

master[, all_cat] <- lapply(master[, all_cat], as.factor)
# relevel factor #

master$race_cat_new <- relevel(master$race_cat_new, ref= "White")

######   univariate cox regression ######
master %>%
  select( "race_cat_new","ethnicity","age_admission","sex","cad","ckd","htn","MELD_Na_baseline","HCC","final_type_of_aki","death_in_90days_status","death_in_90days_time"
  ) %>%
  tbl_uvregression(
    method = coxph,
    y = Surv(death_in_90days_time,death_in_90days_status),
    exponentiate = TRUE,
    show_single_row=c( "sex",        
                       "htn","cad","ckd",              
                       "HCC"),
    pvalue_fun = ~style_pvalue(.x, digits = 3)
  ) %>%
  bold_p() %>%  
  bold_labels() %>% 
  modify_spanning_header(
    c(estimate, ci, p.value) ~  
      "**Univariate cox regression corhort**")	




cox_multivariate <- coxph(Surv(death_in_90days_time,death_in_90days_status) ~race_cat_new+ethnicity+age_admission+sex+cad+ckd+htn+MELD_Na_baseline+HCC+final_type_of_aki, data = master)

summary(cox_multivariate)
test.ph <- cox.zph(cox_multivariate)
test.ph
ggcoxzph(test.ph)

cox_multivariate %>%  tbl_regression(exponentiate = TRUE,
                                     show_single_row=c( "sex",        
                                                        "htn","cad","ckd",              
                                                        "HCC"),
                                     pvalue_fun = ~style_pvalue(.x, digits = 3)) %>% bold_p() %>%  
  bold_labels()%>% 
  modify_spanning_header(
    c(estimate, ci, p.value) ~  
      "** Multivariate cox regression **")


###################### Race ###############

cox_multivariate_race <- coxph(Surv(death_in_90days_time,death_in_90days_status) ~race_cat_new+age_admission+sex+cad+ckd+htn+MELD_Na_baseline+HCC+final_type_of_aki, data = master)

cox_multivariate_race %>%  tbl_regression(exponentiate = TRUE,
                                     show_single_row=c( "sex",        
                                                        "htn","cad","ckd",              
                                                        "HCC"),
                                     pvalue_fun = ~style_pvalue(.x, digits = 3)) %>% bold_p() %>%  
  bold_labels()%>% 
  modify_spanning_header(
    c(estimate, ci, p.value) ~  
      "** Multivariate cox regression with race**")

###################### Ethnicity ###############
cox_multivariate_ethnicity <- coxph(Surv(death_in_90days_time,death_in_90days_status) ~ethnicity+age_admission+sex+cad+ckd+htn+MELD_Na_baseline+HCC+final_type_of_aki, data = master)

cox_multivariate_ethnicity %>%  tbl_regression(exponentiate = TRUE,
                                          show_single_row=c( "sex",        
                                                             "htn","cad","ckd",              
                                                             "HCC"),
                                          pvalue_fun = ~style_pvalue(.x, digits = 3)) %>% bold_p() %>%  
  bold_labels()%>% 
  modify_spanning_header(
    c(estimate, ci, p.value) ~  
      "** Multivariate cox regression with ethnicity**")



library(cobalt)

####################### 
master_ps <- master %>% mutate(race_cat_2=ifelse(race_cat_new=="White","White",ifelse(race_cat_new=="Black or African American","Black or African American",NA))) %>% drop_na(race_cat_2)
master_ps$race_cat_2 <- factor(master_ps$race_cat_2,levels = c("White","Black or African American"))

ps_function <- f.build("race_cat_2", select(master_ps,age_admission,sex,cad,ckd,htn,MELD_Na_baseline,HCC,final_type_of_aki))

# optimal  matching 
set.seed(1000)
matched_all <- matchit(
  ps_function,
  data = master_ps,
  method ="optimal",
  distance = "logit",
  #m.order = "largest", # descending order
  discard ="control",
  ratio = 2
)

master_matched <- match.data(matched_all, data = master_ps)


######   univariate cox regression matched######
master_matched %>%
  select( "age_admission","sex","cad","ckd","htn","MELD_Na_baseline","HCC","final_type_of_aki","death_in_90days_status","death_in_90days_time","race_cat_2","ethnicity"
  ) %>%
  tbl_uvregression(
    method = coxph,
    y = Surv(death_in_90days_time,death_in_90days_status),
    exponentiate = TRUE,
    show_single_row=c( "sex",        
                       "htn","cad","ckd",              
                       "HCC"),
    pvalue_fun = ~style_pvalue(.x, digits = 3)
  ) %>%
  bold_p() %>%  
  bold_labels() %>% 
  modify_spanning_header(
    c(estimate, ci, p.value) ~  
      "**Univariate cox regression corhort ps matched**")	






##### 90 days mortality 
table(all$ethnicity,useNA = "always")
new_all <- all %>% filter(ethnicity!=3)
new_all <- new_all %>% mutate(ethnicity=ifelse(ethnicity==1,"Hispanic","Non-Hispanic")) %>% 
                       mutate(death_in_90days_status=ifelse(death_in_90days_status==1,"Dead","alive"))
table(new_all$ethnicity,new_all$death_in_90days_status,useNA = "always")
contingency_table <- table(new_all$ethnicity,new_all$death_in_90days_status)
contingency_table
chisq.test(contingency_table)



##### 90 days mortality 
new_all <- all %>% filter(ethnicity!=3)

#create table one by race levels#
T1_new_all <- CreateTableOne(vars = all_var,strata = "death_in_90days_status",includeNA = F,addOverall = TRUE,data = new_all, factorVars = cat_var)
#print table one 
T1_new_all_csv <- print(T1_new_all,exact = c("kidney_transplant","admission_route"), nonnormal=num_var,showAllLevels = F,missing = T,quote = FALSE, noSpaces = TRUE, printToggle = FALSE)
#save 
write.csv(T1_new_all_csv, file = "Table1_Hispanic_Non-Hispanic.csv")




###1/8/2024


