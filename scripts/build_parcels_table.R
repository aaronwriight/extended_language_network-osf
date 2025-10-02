# build_parcels_table.R
library(tidyverse)

build_parcels_table <- function(parcels_df, models_condition, models_task, models_maineffects) {
  
  # conditions df
  cond <- parcels_df %>%
    left_join(models_condition, by = c("roi", "atlas")) %>%
    filter(!is.na(ROIName)) %>%
    rename(parcel = ROIName) %>%
    mutate(contrast = case_when(
      contrast == "Alice critical vs. baseline" ~ "I>D",
      contrast == "Lang critical vs. baseline"  ~ "S>N",
      contrast == "MD critical vs. baseline"    ~ "H>E"
    )) %>%
    select(atlas, everything())
  
  # tasks df
  task <- parcels_df %>%
    left_join(models_task, by = c("roi", "atlas")) %>%
    filter(!is.na(ROIName)) %>%
    rename(parcel = ROIName) %>%
    mutate(contrast = case_when(
      contrast == "criticalAlice vs. criticalMD"   ~ "I>H",
      contrast == "criticalLang vs. criticalMD"    ~ "S>H",
      contrast == "criticalAlice vs. criticalLang" ~ "I>S"
    )) %>%
    filter(contrast != "I>S") %>%
    select(atlas, everything())
  
  # main effects df
  maineff <- parcels_df %>%
    left_join(models_maineffects, by = c("roi", "atlas")) %>%
    filter(!is.na(ROIName)) %>%
    rename(parcel = ROIName) %>%
    mutate(contrast = case_when(
      contrast == "Alice critical"   ~ "I",
      contrast == "Alice baseline"   ~ "D",
      contrast == "Language critical"~ "S",
      contrast == "Language baseline"~ "N",
      contrast == "MD critical"      ~ "H",
      contrast == "MD baseline"      ~ "E"
    )) %>%
    select(atlas, everything())
  
  # join together
  df_joined <- full_join(cond, task, by = c("roi","atlas","contrast"),
                         suffix = c(".cond",".task"), relationship = "many-to-many") %>%
    full_join(maineff, by = c("roi","atlas","contrast"),
              suffix = c("",".maineff"), relationship = "many-to-many")
  
  # coalesce + clean
  df_clean <- df_joined %>%
    mutate(
      lobe      = coalesce(lobe, lobe.cond, lobe.task),
      roi       = coalesce(roi, roi),
      Parcel    = coalesce(parcel, parcel.cond, parcel.task),
      hemi      = coalesce(hemi, hemi.cond, hemi.task),
      estimate  = coalesce(estimate, estimate.cond, estimate.task),
      se        = coalesce(se, se.cond, se.task),
      df        = coalesce(df, df.cond, df.task),
      z_ratio   = coalesce(z_ratio, z_ratio.cond, z_ratio.task),
      p_value   = coalesce(p_value, p_value.cond, p_value.task)
    ) %>%
    select(atlas, lobe, roi, Parcel, hemi, contrast, estimate, se, df, z_ratio, p_value)
  
  # add Localizer Task labels
  df_labeled <- df_clean %>%
    mutate(`Localizer Task` = case_when(
      contrast %in% c("S","N","S>N","S>H") ~ "Reading language localizer",
      contrast %in% c("I","D","I>D","I>H") ~ "Auditory language localizer",
      contrast %in% c("H","E","H>E")       ~ "Spatial WM localizer"
    )) %>%
    mutate(`Contrast No.` = case_when(
      contrast %in% c("S","I","H") ~ "1",
      contrast %in% c("N","D","E") ~ "2",
      contrast %in% c("S>N","I>D","H>E") ~ "3",
      contrast %in% c("S>H","I>H") ~ "4"
    )) %>%
    mutate(`Task No.` = case_when(
      contrast %in% c("S","N","S>N","S>H") ~ "1",
      contrast %in% c("I","D","I>D","I>H") ~ "2",
      contrast %in% c("H","E","H>E")       ~ "3"
    )) %>%
    rename(
      Atlas = atlas,
      ROI = roi,
      Hemisphere = hemi,
      `Lobe(s)` = lobe,
      Contrast = contrast,
      `Effect Size` = estimate,
      Std.Error = se,
      `z-score` = z_ratio,
      `p-value` = p_value
    ) %>%
    mutate(
      `Effect Size` = round(`Effect Size`, 2),
      Std.Error     = round(Std.Error, 2),
      `z-score`     = round(`z-score`, 2),
      `p-value`     = round(`p-value`, 3),
      Hemisphere    = str_to_title(Hemisphere),
      Parcel        = str_to_title(Parcel)
    ) %>%
    select(
      Atlas, `Contrast No.`, `Task No.`, ROI, Hemisphere, `Lobe(s)`, Parcel,
      `Localizer Task`, Contrast, `Effect Size`, Std.Error, `z-score`, `p-value`
    )
  
  # sorting
  localizer_order <- c("Reading language localizer", "Auditory language localizer", "Spatial WM localizer")
  contrast_order  <- c("S","N","S>N","S>H","I","D","I>D","I>H","H","E","H>E")
  
  df_sorted <- df_labeled %>%
    arrange(
      Atlas,
      `Lobe(s)`,
      ROI,
      factor(`Localizer Task`, levels = localizer_order),
      factor(Contrast, levels = contrast_order)
    )
  
  return(df_sorted)
}