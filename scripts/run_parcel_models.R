# run_parcel_models

library(tidyverse)
library(lmerTest)
library(emmeans)
library(here)

# main function
run_parcel_models <- function(df, 
                           parcels_filter,
                           target_data,
                           diagnostics = FALSE) {
  
  # filter data
  data_sub <- df %>% mutate(condition = as.factor(condition),
                                  task = as.factor(task))
  
  # define contrasts
  contrasts(data_sub$condition) <- contr.treatment(2)
  contrasts(data_sub$task) <- contr.treatment(3, base = 1)
  
  # define rois
  if(length(parcels_filter) == 1){
    rois <- data_sub$ROI %>% unique()
  } else {
    rois <- data_sub %>% select(ROI) %>% unique() %>% pull()
  }
  
  # initialize result tables
  roi_models_all <- tibble()
  roi_models_pairwise_condition <- tibble()
  roi_models_pairwise_task <- tibble()
  roi_models_pairwise_maineffects <- tibble()
  roi_models_all_means <- tibble()
  
  # construct output directory using target_data
  out_table_dir <- here("results", "stats", paste0(target_data, "_model_stats"))
  if(!dir.exists(out_table_dir)) dir.create(out_table_dir, recursive=TRUE)
  
  # diagnostics subdirectory
  if (diagnostics) {
    diag_dir <- file.path(out_table_dir, "model_diagnostics")
    if(!dir.exists(diag_dir)) dir.create(diag_dir, recursive=TRUE)
  }

  # loop over rois / parcels
  parcels_to_iterate <- if(length(parcels_filter) > 1) parcels_filter else NA
  
  for(atl in parcels_to_iterate){
    
    rois_loop <- if(!is.na(atl)) data_sub %>% filter(parcels==atl) %>% select(ROI) %>% unique() %>% pull() else rois
    
    for(i in rois_loop){
      # Progress message
      message("[", target_data, "] Running model for atlas=", if(!is.na(atl)) atl else "GcSS", ", ROI=", i, " (", which(rois_loop==i), "/", length(rois_loop), ")")
      
      # model testing differences between conditions
      model <- lmer(EffectSize ~ 1 + condition + task + condition:task + (1|Subject),
                    data = if(!is.na(atl)) data_sub %>% filter(parcels==atl, ROI==i) else data_sub %>% filter(ROI==i),
                    control=lmerControl(optimizer="bobyqa"))
      
      if (diagnostics) {
        res <- resid(model, type = "pearson")
        
        # Q–Q plot
        p_qq <- ggplot(data.frame(sample = res), aes(sample = sample)) +
          stat_qq(alpha = 0.6, size = 0.8) +
          stat_qq_line() +
          labs(title = paste0(i, " — Q–Q plot of residuals"),
              x = "Theoretical quantiles", y = "Sample quantiles") +
          theme_minimal(base_size = 12)
        
        safe_i <- gsub("[^A-Za-z0-9._-]+", "_", i)
        ggsave(file.path(diag_dir,
                        paste0(target_data, "_", safe_i, "_qq.pdf")),
              p_qq, width = 5, height = 4, dpi = 300)
        
        # Residuals vs fitted
        diag_df <- tibble(
          fitted = fitted(model),
          resid  = res,
          task   = model.frame(model)$task
        )
        
        p_rvf <- ggplot(diag_df, aes(fitted, resid)) +
          geom_point(alpha = 0.5) +
          geom_hline(yintercept = 0, linetype = "dashed") 
          facet_wrap(~ task, scales = "free_x") +
          labs(title = paste0(i, " — Residuals vs Fitted by task"),
              x = "Fitted values", y = "Pearson residuals") +
          theme_minimal(base_size = 12)
        
        ggsave(file.path(diag_dir,
                        paste0(target_data, "_", safe_i, "_resid_vs_fitted.pdf")),
              p_rvf, width = 7, height = 5, dpi = 300)
      }
      
      sum_coef <- summary(model)$coef
      names <- rownames(sum_coef)
      sum_tbl <- cbind(names, sum_coef, ROI=i, atlas=if(!is.na(atl)) atl else "GSS") %>% as_tibble()
      roi_models_all <- roi_models_all %>% rbind(sum_tbl)
      
      emm <- suppressWarnings(emmeans(model, ~ task * condition)) # remove suppressWarnings for additional information
      
      # language vs WM
      cond_vs_zero <- contrast(emm, method = list(
        "Alice baseline" = c(1,0,0,0,0,0),
        "Alice critical" = c(0,0,0,1,0,0),
        "Language baseline" = c(0,1,0,0,0,0),
        "Language critical" = c(0,0,0,0,1,0),
        "MD baseline" = c(0,0,1,0,0,0),
        "MD critical" = c(0,0,0,0,0,1)
      ), adjust="none") %>% as_tibble() %>% cbind(ROI=i, atlas=if(!is.na(atl)) atl else "GSS")
      
      # between-conditions
      critical_between_tasks <- contrast(emm, method = list(
        "criticalAlice vs. criticalLang" = c(0,0,0,1,-1,0),
        "criticalAlice vs. criticalMD" = c(0,0,0,1,0,-1),
        "criticalLang vs. criticalMD" = c(0,0,0,0,1,-1)
      ), adjust="none") %>% as_tibble() %>% cbind(ROI=i, atlas=if(!is.na(atl)) atl else "GSS")
      
      # critical vs baseline
      critical_vs_baseline <- contrast(emm, method = list(
        "Alice critical vs. baseline" = c(-1,0,0,1,0,0),
        "Lang critical vs. baseline" = c(0,-1,0,0,1,0),
        "MD critical vs. baseline" = c(0,0,-1,0,0,1)
      ), adjust="none") %>% as_tibble() %>% cbind(ROI=i, atlas=if(!is.na(atl)) atl else "GSS")
      
      means_tbl <- emm %>% as_tibble() %>% cbind(ROI=i, atlas=if(!is.na(atl)) atl else "GSS")
      
      roi_models_pairwise_maineffects <- roi_models_pairwise_maineffects %>% rbind(cond_vs_zero)
      roi_models_pairwise_condition <- roi_models_pairwise_condition %>% rbind(critical_vs_baseline)
      roi_models_pairwise_task <- roi_models_pairwise_task %>% rbind(critical_between_tasks)
      roi_models_all_means <- roi_models_all_means %>% rbind(means_tbl)
    }
  }
  
  # Consistently rename columns of all result tibbles before writing tables
  colnames(roi_models_all) <- c('effect', 'estimate', 'se', 'df', 't_value', 'p_value', 'roi', 'atlas')
  colnames(roi_models_pairwise_condition) <- c('contrast', 'estimate', 'se', 'df', 'z_ratio', 'p_value', 'roi', 'atlas')
  colnames(roi_models_pairwise_task) <- c('contrast', 'estimate', 'se', 'df', 'z_ratio', 'p_value', 'roi', 'atlas')
  colnames(roi_models_pairwise_maineffects) <- c('contrast', 'estimate', 'se', 'df', 'z_ratio', 'p_value', 'roi', 'atlas')
  colnames(roi_models_all_means) <- c('task', 'condition', 'emmean', 'se', 'df', 'lowCI', 'highCI', 'roi', 'atlas')

  # write tables with filenames including the target_data string
  write.table(roi_models_all, file = file.path(out_table_dir, paste0(target_data, "_roi_models_all.txt")), sep="\t", row.names=F, quote=F)
  write.table(roi_models_pairwise_maineffects, file = file.path(out_table_dir, paste0(target_data, "_roi_models_pairwise_maineffects.txt")), sep="\t", row.names=F, quote=F)
  write.table(roi_models_pairwise_condition, file = file.path(out_table_dir, paste0(target_data, "_roi_models_pairwise_conditions.txt")), sep="\t", row.names=F, quote=F)
  write.table(roi_models_pairwise_task, file = file.path(out_table_dir, paste0(target_data, "_roi_models_pairwise_tasks.txt")), sep="\t", row.names=F, quote=F)
  write.table(roi_models_all_means, file = file.path(out_table_dir, paste0(target_data, "_roi_models_all_means.txt")), sep="\t", row.names=F, quote=F)
  
  # Return all result tibbles as a list
  return(list(
    all = roi_models_all,
    pairwise_condition = roi_models_pairwise_condition,
    pairwise_task = roi_models_pairwise_task,
    maineffects = roi_models_pairwise_maineffects,
    means = roi_models_all_means
  ))
  
  # message("Finished models for ", paste(parcels_filter, collapse=", "))
}