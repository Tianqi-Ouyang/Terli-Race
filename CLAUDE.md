# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Sub-analysis of the HARMONY study examining race/ethnicity differences in outcomes among hospitalized patients with cirrhosis and AKI. Pure R analysis project (no build system) — analysis lives in R Markdown / Quarto documents that knit to HTML for sharing on RStudio Connect (`rsconnect/`).

## Data Pipeline

1. **Master dataset:** `data/All_edited_new_12142022.xlsx` — patient-level HARMONY data, one row per `study_id`.
2. **Per-site race files:** `data/<Site>0913.xlsx` (Baylor, Indiana, Jacksonville, Kentukey, MCW, MGH, Michigan, Oschner, Rochester, USC, Yale) — each contributes `study_id, race, rrt_crrt, days_icu, cpr_given`. USC lacks `rrt_crrt/days_icu/cpr_given` (set to NA before binding).
3. Sites are `rbind`-ed into `race_added`, then **left-joined onto `all` by `study_id`** to attach race/ethnicity. Don't re-join in a different order — the master file is the source of truth for everything else.

## Key Derived Variables (built in `final/Final race analysis.Rmd`)

- `race` — labelled factor from numeric race code (1=AI/AN, 2=Asian, 3=Black, 4=NHPI, 5=White, 6=Other, 7=Unknown).
- `race_cat_new` — collapsed: White / Black or African American / Other.
- `race_cat_4` — primary stratifier: NHW, HW, B (Hispanic + Non-Hispanic Black combined), NWNB. Releveled to `NHW` reference.
- `race_cat_5` — splits Black into NHB / HB.
- `ethnicity` — relabelled Hispanic / Non-Hispanic / Unknown.
- `type_of_aki` — Prerenal / HRS-AKI / ATN / Other / Unable to diagnosis.
- `etiology_cirrhosis` — Alcohol / HCV / NASH / Multifactorial / Other (codes 4,6,7 collapsed).
- `cirrhosis` — 1 if `etiology_cirrhosis == 1` (Alcohol), else 0, NA preserved.
- `transplant_evaluation_outcome` — 0/1 from `Transplant_evalutation` (note misspelling — keep it; matches source data).
- `female` — 1 if `sex == 2`.
- `meld_3` — MELD 3.0 score from `calculate_meld3()` (returns NA if any input NA or non-positive). Formula uses `tb_admit, na_admit, inr_admit, creatinine_admission, alb_admit`.
- `death_status_90days` — 1 if `status_90days == 1`, else 0 (used for KM; competing-risk models use raw `status_90days`).

## Analysis Cohort (`master`)

Filter chain:
1. Drop `race == 'Unknown'` and `ethnicity == 'Unknown'`.
2. Impute `MELD_Na_baseline` with median; then keep `MELD_Na_baseline >= 0`.
3. After deriving `meld_3`, drop rows missing any of: `age_admission, meld_3, etiology_cirrhosis, hcc_admission, diabetes, cad, ckd, htn, site` (the multivariable model adjusters).
4. `master_hrs <- master %>% filter(type_of_aki == "HRS-AKI")` for HRS sub-cohort analyses.

## Variable Lists

`all_var`, `cat_var`, and `num_var <- setdiff(all_var, cat_var)` are defined once and reused for `tableone::CreateTableOne` and `gtsummary` calls. `all_var` contains intentional duplicates added on 2025-03-17 — don't dedupe without checking which downstream `select()` calls index by position (e.g., `all_var[1:60]`, `all_var[60:97]`).

## Models

- **Competing-risk regression:** `tidycmprsk::crr` with `failcode = 1, cencode = 0` on `Surv(time_90days, status_90days)`. Two adjuster sets ("model 1" = full demographics+comorbidities; "model 2" = age + meld_3 + etiology + hcc + site only). Run on both full `master` and `master_hrs`.
- **KM curves:** `survfit` + `survminer::ggsurvplot` on `death_status_90days`.
- **Table 1:** `tableone::CreateTableOne` stratified by `race_cat_new` and `race_cat_4`; exact tests for `HCC, New_diagnosis_of_cirrhosis, kidney_transplant`; non-normal continuous vars use `num_var`.

## Hardcoded Paths — Read Before Editing

`Final race analysis.Rmd` calls `setwd('/Users/to909/Desktop/Andrew')` and writes CSVs to `/Users/to909/Partners HealthCare Dropbox/Tianqi Ouyang/Projects/Subanalysis_race/final/`. The actual project root is `/Users/to909/Desktop/Subanalysis_race/`. When adding new outputs, prefer relative paths under `final/` or `result/`.

## Outputs

- `result/` — historical Table 1 / Table 2 CSVs across many cohort definitions (race, ethnicity, hispanic stratification, propensity-score-matched).
- `final/` — current Table 1 CSVs keyed by `race_cat_new` and `race_cat_4`, plus the knit `Final-race-analysis.html`.

## Required Packages

`tidyverse, tableone, gtsummary, survival, survminer, ggplot2, ggpubr, readxl, splines, xlsx, MatchIt, tidycmprsk`.

## Gotchas

- **Em-dashes in R strings:** Non-ASCII characters (`—`, `–`, `×`, accented letters) inside strings built by R at runtime (e.g., `paste0("Cohort — ", n)`, `kable` captions) get rendered as literal `<U+2014>` escapes when the R locale isn't UTF-8 — especially under `Rscript` in non-interactive terminals. Fixes applied: (a) `Sys.setlocale("LC_ALL", "en_US.UTF-8")` in the setup chunk; (b) use ASCII `--` in R code strings (pandoc auto-converts to en-dash). Em-dashes in prose Markdown (outside `{r}` chunks) are fine — pandoc reads them as UTF-8 directly.
- **Patient-level data is PHI:** `data/*.xlsx` files are HARMONY patient-level records. The GitHub repo (`Tianqi-Ouyang/Terli-Race`) is public; `data/` is gitignored and must stay that way.
- **USC race file missing columns:** `USC0913.xlsx` lacks `rrt_crrt`, `days_icu`, `cpr_given` — add them as NA before `rbind`.
- **`Transplant_evalutation` misspelling:** kept intentionally; matches source column.

## Commit Style

Commits are authored by Tianqi Ouyang only. Do not add `Co-Authored-By` trailers or any other AI attribution.
