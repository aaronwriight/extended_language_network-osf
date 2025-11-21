# plot_brains

library(tidyverse)
library(here)
library(readxl)
library(ggsflabel)
library(ggseg)
library(ggsegGlasser)
library(ggsegDKT)
library(ggsegHO)
library(patchwork)

# brainplot, braincollage, and brainplot_* functions

# The ***brainplot*** function works by modifying both the native ggseg atlas data AND a custom dataset supplied by the user.
#
# It is generally supposed to work if your data is structure the same as a ggseg atlas. It is recommended to look at, e.g., {ggsegDKT} by calling **dkt\$data** and observing its structure. {ggseg} has certain *necessary* columns, however. Your data must include the following columns: **hemi, side**, **region**, and **geometry**.
# 
# In our case, we've also added functionality to be able to filter by task (assuming you have a column "task" in your dataset). This can be modified given your data.
# 
# And the following are helpful links about the inner workings of ggseg:
#
#   https://ggseg.github.io/ggseg/articles/externalData.html
#   https://ggseg.github.io/ggseg/articles/externalData.html (probably the MOST helpful)
#   https://ggseg.github.io/ggseg/articles/geom-sf.html
# 
# The ***braincollage*** function produces a handful of preset atlas layouts that work well with the ***brainplot*** function's structure. It is recommended that dimensional changes be made carefully. (But, of course, have fun!)
# The various ***'brainplot_*'*** functions are miniature and functionally-limited versions of the core brainplot function.


# brainplot: a dynamic function for plotting functional neuroimaging data using ggseg atlases.

brainplot <- function(
  df, 
  atlas,
  plot_type, task = NULL,
  plot_title = NULL,
  subtitle = NULL,
  legend_title = NULL,
  legend_on = TRUE,
  xlab = NULL,
  ylab = NULL,
  fill_regions = NULL,
  annotate = FALSE,
  outline = FALSE,
  outline_hemi = NULL,
  outline_side = NULL,
  outline_regions = NULL,
  view = NULL,
  folder = NULL,
  file_name = NULL,
  file_type = "pdf") {
  
  # example call
  
  # brainplot(
  #   df = my_brain_data, # data frame compatible with ggseg atlas object (i.e., includes columns 'hemi', 'side', 'region')
  #   atlas = dkt, # ggseg atlas object (includes columns 'hemi', 'side', 'region', 'label, 'geometry')
  #   plot_type = "responsive",
  #   task = "Lang", # default NULL includes all matches to plot_type column (i.e., remains unfiltered)
  #   plot_title = "My Brain Plot",
  #   subtitle = "Regions responsive to language",
  #   legend_title = "Activation level",
  #   legend_on = TRUE, # default = TRUE
  #   xlab = NULL, # default NULL results in specifications below - enter empty string to remove labels
  #   ylab = NULL, # default NULL results in specifications below - enter empty string to remove labels
  #   annotate = TRUE,
  #   outline = TRUE,
  #   outline_hemi = ,
  #   outline_side = ,
  #   outline_regions = NULL, # a list of character strings specifying which regions to outline
  #   view = "left_lateral",
  #   folder = "data_folder",
  #   file_name = "my_brain_plot",
  #   file_type = "png"
  # )
  
  # (aesthetic) create a blank string of spaces to separate elements of the axis labels - if changed, must be done in conjunction with axis and labeling adjustments and ggsave parameters (width and height)
  x_spaces <- paste(rep(" ", 18), collapse = "")
  y_spaces <- paste(rep(" ", 10), collapse = "")
  
  # # extra spacing recommended for patchwork
  # x_spaces <- paste(rep(" ", 50), collapse = "")
  # y_spaces <- paste(rep(" ", 35), collapse = "")
  
  # set default views for atlas types (aseg vs non-aseg)
  if (is.null(view)) {
    if (grepl("aseg", atlas$atlas)) {
      view <- "both"  # default for aseg atlas: coronal and sagittal
      message("no view provided; defaulting to 'both' for aseg atlas")
    } else {
      view <- "all"   # default for non-aseg atlas: all views (left lateral, left medial, right lateral, right medial)
      message("no view provided; defaulting to 'all' for non-aseg atlas")
    }
  }
  
  # set dynamic x/y axis breaks and labels based on the view type
  switch(view,
         
         "coronal" = {
           if (grepl("aseg", atlas$atlas)) {
             # coronal view: single x-axis label, no y-axis labeling
             xlab <- ifelse(is.null(xlab), "Coronal", xlab)
             ylab <- ifelse(is.null(ylab), "", ylab)
           } else {
             # fallback if this ever happens for non-aseg (we don't expect "coronal" to be used here)
             stop("'coronal' is reserved for aseg atlas")
             break
           }
         },

         "sagittal" = {
           if (grepl("aseg", atlas$atlas)) {
             # sagittal view: single x-axis label, no y-axis labeling
             xlab <- ifelse(is.null(xlab), "Sagittal", xlab)
             ylab <- ifelse(is.null(ylab), "", ylab)
           } else {
             # fallback if this ever happens for non-aseg (we don't expect "sagittal" to be used here)
             stop("'sagittal' is reserved for aseg atlas")
             break
           }
         },

         "both" = {
           # for aseg (coronal and sagittal)
           if (grepl("aseg", atlas$atlas)) {
             # modify xlab by adding spaces
             xlab <- ifelse(is.null(xlab), paste("Coronal", x_spaces, "Sagittal"), xlab)
             ylab <- ifelse(is.null(ylab), "", ylab)
           } else {
             # fallback if this ever happens for non-aseg (we don't expect "both" to be used here)
             stop("'both' is reserved for aseg atlas")
             break
           }
         },

         "left" = {
           # for aseg (left half of coronal slice)
           if (grepl("aseg", atlas$atlas)) {
             # left hemisphere: left half of coronal slice on x-axis, no y-axis labeling
             xlab <- ifelse(is.null(xlab), "Coronal Left", xlab)
             ylab <- ifelse(is.null(ylab), "", ylab)
           } else {
             # left hemisphere: left lateral and left medial sides on x-axis, no y-axis labeling
             xlab <- ifelse(is.null(xlab), paste("Lateral", x_spaces, "Medial"), xlab)
             ylab <- ifelse(is.null(ylab), "Left", ylab)
           }
         },

         "right" = {
           # for aseg (right half of coronal slice)
           if (grepl("aseg", atlas$atlas)) {
             # right hemisphere: right half of coronal slice on x-axis, no y-axis labeling
             xlab <- ifelse(is.null(xlab), "Coronal Right", xlab)
             ylab <- ifelse(is.null(ylab), "", ylab)
           } else {
             # right hemisphere: right medial and right lateral sides on x-axis, no y-axis labeling
             # (note: ggseg switches medial/lateral order compared to left hemisphere by default)
             xlab <- ifelse(is.null(xlab), paste("Medial", x_spaces, "Lateral"), xlab)
             ylab <- ifelse(is.null(ylab), "Right", ylab)
           }
         },

         "all" = {
           # for non-aseg: "all" means all four views: left lateral, left medial, right lateral, right medial
           if (!grepl("aseg", atlas$atlas)) {
             # modify xlab and ylab by adding spaces
             xlab <- ifelse(is.null(xlab), paste("Lateral", x_spaces, "Medial"), xlab)
             ylab <- ifelse(is.null(ylab), paste("Left", y_spaces, "Right"), ylab)
           } else {
             # fallback if this ever happens for aseg (we don't expect "all" to be used here)
             stop("'all' is reserved for non-aseg atlases")
             break
           }
         },

         "left_lateral" = {
           if (!grepl("aseg", atlas$atlas)) {
             # for non-aseg: left lateral view
             xlab <- ifelse(is.null(xlab), "Lateral", xlab)
             ylab <- ifelse(is.null(ylab), "Left", ylab)
           } else {
             # fallback if this ever happens for aseg (we don't expect "left_lateral" to be used here)
             stop("'left_lateral is reserved for non-aseg atlases")
             break
           }
         },

         "left_medial" = {
           if (!grepl("aseg", atlas$atlas)) {
             # for non-aseg: left medial view
             xlab <- ifelse(is.null(xlab), "Medial", xlab)
             ylab <- ifelse(is.null(ylab), "Left", ylab)
           } else {
             # fallback if this ever happens for aseg (we don't expect "left_medial" to be used here)
             stop("'left_medial' is reserved for non-aseg atlases")
             break
           }
         },

         "right_lateral" = {
           if (!grepl("aseg", atlas$atlas)) {
             # for non-aseg: right lateral view
             xlab <- ifelse(is.null(xlab), "Lateral", xlab)
             ylab <- ifelse(is.null(ylab), "Right", ylab)
           } else {
             # fallback if this ever happens for aseg (we don't expect "right_lateral" to be used here)
             stop("'right_lateral' is reserved for non-aseg atlases")
             break
           }
         },

         "right_medial" = {
           if (!grepl("aseg", atlas$atlas)) {
             # for non-aseg: right medial view
             xlab <- ifelse(is.null(xlab), "Medial", xlab)
             ylab <- ifelse(is.null(ylab), "Right", ylab)
           } else {
             # fallback if this ever happens for aseg (we don't expect "right_medial" to be used here)
             stop("'right_medial' is reserved for non-aseg atlases")
             break
           }
         }
  )

  # define a column containing the activation type of a given ROI
  df <- df %>%
    mutate(
      activity_resp = case_when(
        lang_resp == 1 ~ "Responsive",   # lang_resp = 1 indicates "Active"
        lang_resp == 0 ~ NA,  # lang_resp = 0 indicates "Inactive"
      ),
      activity_sel = case_when(
        lang_sel == 1 ~ "Selective",    # lang_sel = 1 indicates "Active"
        lang_sel == 0 ~ NA,   # lang_sel = 0 indicates "Inactive"
      )
    )
  
  # define "plot_type" variations
  fill_var <- switch(
    plot_type,
    "responsive" = c("MeanEffectResponsive", "lang_resp"),
    "binary_responsive" = c("activity_resp", "lang_resp"),
    "selective" = c("MeanEffectSelect", "lang_sel"),
    "binary_selective" = c("activity_sel", "lang_sel"),
    "overlap" = c("OverlapPercentage", "OverlapPercentage"),
    "binary_dual" = c("sig", c("lang_resp", "lang_sel")),
    stop("Invalid plot_type provided!")
  )
  
  # filter dataset by 'task' after preserving ROI activity information (MUST do if annotation is to work properly - otherwise annotations are duplicated)
  if (!is.null(task)) {
    if (!task %in% c("Alice", "Lang", "MD")) stop("Invalid task provided!")
    # neglecting to retain NAs impacts scale_fill_manual capability
    df <- df %>% filter(task == !!task | is.na(task))
  }
  
  # initialize atlas_view for specific view filtering (default: no filtering)
  atlas_view <- atlas
  
  # check if 'view' is 'all' or NULL
  if (view == "all" | is.null(view)) {
    # do nothing, plot all views (atlas and df remain as is)
  } else {
    # check if 'view' is something specific and filter the atlas data for the specific view (MUST do if annotation is to work properly - otherwise annotations are duplicated)
    if (view == "left") {
      atlas_view$data <- atlas$data %>% filter(hemi == "left")
      df <-  df %>% filter(hemi == "left")
    } else if (view == "right") {
      atlas_view$data <- atlas$data %>% filter(hemi == "right")
      df <-  df %>% filter(hemi == "right")
    } else if (view == "left_medial") {
      atlas_view$data <- atlas$data %>% filter(hemi == "left", side == "medial")
      df <-  df %>% filter(hemi == "left", side == "medial")
    } else if (view == "left_lateral") {
      atlas_view$data <- atlas$data %>% filter(hemi == "left", side == "lateral")
      df <-  df %>% filter(hemi == "left", side == "lateral")
    } else if (view == "right_medial") {
      atlas_view$data <- atlas$data %>% filter(hemi == "right", side == "medial")
      df <-  df %>% filter(hemi == "right", side == "medial")
    } else if (view == "right_lateral") {
      atlas_view$data <- atlas$data %>% filter(hemi == "right", side == "lateral")
      df <-  df %>% filter(hemi == "right", side == "lateral")
    } else if (view == "coronal") {
      atlas_view$data <- atlas$data %>% filter(side == "coronal")
      df <-  df %>% filter(side == "coronal")
    } else if (view == "sagittal") {
      atlas_view$data <- atlas$data %>% filter(side == "sagittal")
      df <-  df %>% filter(side == "sagittal")
    } 
  }

  # core plot setup
  
  ## for Non-aseg atlases
  atlas_plot <- if (!grepl("aseg", atlas$atlas)) {
    ### for non-aseg: filtering for binary_responsive and binary_selective based on activity_resp and activity_sel
    df %>%
      filter(
        plot_type == "overlap" & OverlapPercentage > 0.00 |
          (plot_type == "binary_responsive") |
          (plot_type == "binary_selective") |
          (plot_type != "overlap" & plot_type != "binary_responsive" & plot_type != "binary_selective" & !!sym(fill_var[2]) == 1)
      ) %>%
      distinct(region, hemi, side, .keep_all = TRUE) %>%
      brain_join(atlas_view, by = c("hemi", "region", "side"))
  } else {
    ### for aseg: same filtering logic for binary_responsive and binary_selective based on activity_resp and activity_sel
    df %>%
      filter(
        (plot_type == "binary_responsive") |
          (plot_type == "binary_selective") |
          (plot_type != "binary_responsive" & plot_type != "binary_selective" & !!sym(fill_var[2]) == 1)
      ) %>%
      distinct(region, hemi, side, .keep_all = TRUE) %>%
      brain_join(atlas_view, by = c("hemi", "region", "side"))
  }
  
  ## reposition brain for 'all' view for non-aseg atlases (reposition_brain is incompatible with aseg atlas)
  if ((!grepl("aseg", atlas$atlas)) && (view == "all" || is.null(view))) {
    atlas_plot <- atlas_plot %>%
      reposition_brain(hemi ~ side) # repositioning is applied here
    
    
    # other core plot mappings and aesthetics
  }

  
    ##
  atlas_plot <- atlas_plot %>%
    ggplot(aes(fill = !!sym(fill_var[1]))) +
    geom_sf(show.legend = legend_on, aes(alpha = factor(ifelse(is.na(!!sym(fill_var[1])), .99, 1)))) +
    scale_alpha_discrete(range = c(0.1, 1), guide = "none") +
    theme_brain()
  ## axis and labeling adjustments
  atlas_plot <- atlas_plot +
    theme(axis.text.y = element_blank(),
          axis.text.x = element_blank(),
          axis.title.y = element_text(
            vjust = 5, 
            size = 30),
          axis.title.x = element_text(
            vjust = -5, 
            size = 30),
          plot.title = element_text(size = 30), # hjust = 0.5 recommended for patchwork
          plot.subtitle = element_text(size = 15),
          legend.title = element_text(size = 20),
          # adds space between the legend title and gradient
          legend.spacing.y = unit(1.5, 'cm'),
          legend.text = element_text(size = 20), # hjust = 0.5 recommended for patchwork
          
          # # legend positioned at the bottom with added margin recommended for patchwork
          # legend.position = "bottom",
          # legend.margin = margin(t = 40),
          
          # margin specified top, right, bottom, left
          plot.margin = margin(60, 60, 60, 60)) +
    labs(
      title = ifelse(is.null(plot_title), "", plot_title), 
      subtitle = ifelse(is.null(subtitle), "", subtitle), 
      fill = ifelse(is.null(legend_title), "", legend_title), 
      # NULL xlab/ylab defaults to settings above; providing an empty string to the xlab or ylab argument will remove the label from the respective axis
      x = xlab,
      y = ylab
    )
  
  ## dynamically adjust color scales
  if (plot_type == "binary_responsive" | plot_type == "binary_selective") {
    
    atlas_plot <- atlas_plot +
      scale_fill_manual(values = c("Selective" = "indianred3", "Responsive" = "indianred3", na.value = "black"),
                    
                        # # original
                        # na.translate = FALSE,
                        # na.value = "transparent"
          
                        # alternative grey shading - bear in mind, na.translate = TRUE shows NA in legend
                        # (not recommended if outlining regions)
                        na.translate = TRUE,
                        # na.value = "black"
                        
                        # # guide customization recommended if legend.position = "bottom"
                        # guide = guide_legend(title.position = "top", title.hjust = 0.5),
                        
                        )
    
  } else if (plot_type == "binary_dual") {
    
    ### if all responsive language parcels are also selective parcels, default to labeling and coloring as "Language-Selective" only
    if (all(df$lang_sel == df$lang_resp, na.rm = TRUE)) {
      
      # change the labels and colors when all lang_sel == lang_resp
      atlas_plot <- atlas_plot +
        scale_fill_manual(
          values = c("0" = "indianred3", "1" = "indianred3"), 
          labels = c("Language-Selective"), 
          
          # # original
          na.translate = TRUE,
          # na.value = "transparent"
          
          # alternative grey shading - bear in mind, na.translate = TRUE shows NA in legend
          # (not recommended if outlining regions)
          # na.translate = FALSE,
          # na.value = "black"
          
          # # guide customization recommended if legend.position = "bottom"
          # guide = guide_legend(title.position = "top", title.hjust = 0.5),
          
          )
      
    } else {
      
      ### default behavior when there are differences
      atlas_plot <- atlas_plot +
        scale_fill_manual(
          values = c("0" = "rosybrown1", "1" = "indianred3", na.value = "black"), 
          labels = c("Language-Responsive", "Language-Selective"),
          
          # # original
          # na.translate = FALSE,
          # na.value = "transparent"
          
          # alternative grey shading - bear in mind, na.translate = TRUE shows NA in legend
          # (not recommended if outlining regions)
          na.translate = TRUE,
          # na.value = "black"
          
          # # guide customization recommended if legend.position = "bottom"
          # guide = guide_legend(title.position = "top", title.hjust = 0.5),
          
          )
      
    }
    
  } else if (plot_type == "overlap"){
    
    ### plot the overlap of the atlas parcels with the GcSS functional language parcels
    atlas_plot <- atlas_plot +
      scale_fill_gradient(low="white", high="red4", na.value = "black",
                          limits = c(0, 100),
                          
                          # # original
                          # na.value = "transparent"
                          
                          # alternative grey shading (not recommended if outlining regions)
                          # na.value = "black"
                          
                          # # guide customization recommended if legend.position = "bottom"
                          # guide = guide_colorbar(title.position = "top", title.hjust = 0.5)
                          
                          ) +
      expand_limits(fill = seq("0", "100", by=0.5)) 
    
    # +
    #   # use if legend position = "bottom" (e.g., patchwork plots)
    #   theme(
    #     legend.key.width = unit(2.5, "cm"),
    #     legend.key.height = unit(.5, "cm"))
    
  } else if (plot_type %in% c('responsive', 'selective')) {
    
    atlas_plot <- atlas_plot +
      scale_fill_gradient(low = "white", high = "red4", na.value = "black",
                          limits = c(0, 2.5), 
                          breaks = seq(0, 2.5, by = 0.5),
                          
                          # # original
                          # na.value = "transparent"
                          
                          # alternative grey shading (not recommended if outlining regions)
                          # na.value = "black"
                          
                          # # guide customization recommended if legend.position = "bottom"
                          # guide = guide_colorbar(title.position = "top", title.hjust = 0.5)
                          
                          ) 
    # +
    #   # use if legend position = "bottom" (e.g., patchwork plots)
    #   theme(legend.key.width = unit(3.5, "cm"),
    #         legend.key.height = unit(.5, "cm"))
    
  }

  ## Optional outline toggle
  if (outline) {

    ### Set custom outline value based on view
    outline_value <- case_when(
      view == 'all' ~ 0.35,
      view %in% c('left', 'right', 'both') ~ 1.5,
      view %in% c('left_lateral', 'left_medial', 'right_lateral', 'right_medial', 'coronal', 'sagittal') ~ 3.75,
      TRUE ~ 0.25  # Default if view is unspecified
      )

      ### Determine which regions should be outlined
    valid_outlined_regions <- df$region[!is.na(df[[fill_var[1]]])]  # Start with all non-NA regions
  
      ### Apply outline_hemi filter if specified
    if (!is.null(outline_hemi)) {
      valid_outlined_regions <- valid_outlined_regions[df$hemi %in% outline_hemi]
      }
  
      ### Apply outline_side filter if specified
    if (!is.null(outline_side)) {
      valid_outlined_regions <- valid_outlined_regions[df$side %in% outline_side]
      }
  
    ### Apply outline_regions filter if specified
    if (!is.null(outline_regions)) {
      valid_outlined_regions <- valid_outlined_regions[valid_outlined_regions %in% outline_regions]
      }

    ### !![CURRENTLY NOT FUNCTIONAL FOR THE FOLLOWING SPECIFICATIONS - AUTHORS ARE WORKING ON THIS - STILL HIGHLIGHTS SIGNIFICANT REGIONS APPROPRIATELY]!!
    ### Now valid_outlined_regions will contain regions that match all specified conditions interactively
    
      # outline_hemi = "left",
      # outline_side = "lateral",
      # outline_side = "medial",
      # outline_regions = "",
    
    ## Update base plot with conditional linewidth application
    atlas_plot <- atlas_plot +
      geom_sf(
        show.legend = legend_on,
        aes(
          linewidth = ifelse(region %in% valid_outlined_regions
                             & !is.na(!!sym(fill_var[1])), outline_value, 0.25),
          alpha = factor(ifelse(is.na(!!sym(fill_var[1])), .99, 1)))
        ) +
      scale_linewidth_continuous(range = c(0.15, 3.0), guide = "none") + # Adjust range as needed
      scale_alpha_discrete(range = c(0.1, 1), guide = "none")
    }
  
  
  ## optional annotation toggle
  if (annotate) {
    
    ### set force and text size based on view - consider editing if using patchwork
    annotation_value <- case_when(
      view == 'all' ~ c(5, 2, 0.20), # recommended (5, 4, 0.20) for patchwork
      view %in% c('left', 'right', 'both') ~ c(40, 2.5, 0.15), # recommended (40, 4.5, 0.15) for patchwork
      view %in% c('left_lateral', 'left_medial', 'right_lateral', 'right_medial', 'coronal', 'sagittal') ~ c(10, 2.5, 0.10) # recommended (10, 4.5, 0.10) for patchwork
      )
    
    ### add labels only for "Active" regions, keep "Inactive" in the legend
    atlas_plot <- atlas_plot +
      geom_sf_text_repel(aes(
        label = case_when(
          plot_type == "binary_responsive" & activity_resp == "Responsive" ~ region,  # Only label if responsive and active
          plot_type == "binary_selective" & activity_sel == "Selective" ~ region,   # Only label if selective and active
          !plot_type %in% c("binary_responsive", "binary_selective") & !is.na(!!sym(fill_var[2])) ~ region,
          TRUE ~ NA_character_  # Don't show label for other cases
          )
        ),
        max.overlaps = Inf,
        force = annotation_value[1],
        size = annotation_value[2],
        min.segment.length = annotation_value[3],
        segment.size = 0.25,
        show.legend = legend_on)
    }
  
  ## save plot - folder var included to improve output functionality for different atlases - name according to atlas below
  # ensure folder and file_name are valid strings
  if (is.null(folder) || folder == "") folder <- "default_folder"
  if (is.null(file_name) || file_name == "") file_name <- "default_file"

  # replace spaces with underscores for folder and file_name
  folder <- gsub(" ", "_", folder)
  file_name <- gsub(" ", "_", file_name)

  # create folder if it doesn't exist
  dir.create(file.path(here("viz", "images", "main", "by_atlas"), folder), recursive = TRUE, showWarnings = FALSE)
  
  ggsave(
  filename = file.path(here("viz", "images", "main", "by_atlas"), folder, paste0(file_name, ".", file_type)),
  plot = atlas_plot,
  dpi = 500,
  width = 18,
  height = 14,
  units = "in"
  )
  
  ## return plot as ggplot object for additional use with patchwork
  return(atlas_plot)
}

# braincollage: a useful wrapper function for brainplot for creating several useful plots for a given atlas. Formats are given, but use-specific edits are encouraged.

braincollage <- function(df, atlas) {
  
  ## set default values for folder based on atlas
  folder <- if (atlas$atlas == "aseg") {
    
    ### use a fixed name for the aseg atlas
    "hoSubCort"
    
  } else {
    
    gsub(" ", "_", atlas$atlas)  # Default folder naming convention
    
  }
  
  ## define atlas names based on the atlas
  atlas_name <- switch(
    atlas$atlas,
    "glasser" = "Glasser cortical",
    "dkt" = "DKT cortical",
    "hoCort" = "Harvard-Oxford cortical",
    "aseg" = "Harvard-Oxford Subcortical",
    "Unknown Atlas"  # default case
  )
  
  ## define the plot configurations based on desired labeling names
  ## consider removing \n from legend_title if legend.position = "bottom" is defined above
  plot_configurations <- list(
    list(plot_type = "binary_dual", task = NULL, annotate = FALSE, plot_title = paste0("Language-selective parcels\nin the ", atlas_name, " parcels"), legend_title = "Parcel type\n", view = ifelse(atlas$atlas == "aseg", "coronal", "all"), file_name = paste0(atlas_name, "_lang_binary_dual"), file_type = "pdf"),
    list(plot_type = "binary_dual", task = NULL, annotate = TRUE, plot_title = paste0("Language-selective parcels\nin the ", atlas_name, " parcels"), legend_title = "Parcel type\n", view = ifelse(atlas$atlas == "aseg", "coronal", "all"), file_name = paste0(atlas_name, "_lang_binary_dual_annotated"), file_type = "pdf"),
    list(plot_type = "binary_selective", task = NULL, annotate = FALSE, plot_title = paste0("Language-selective parcels\nin the ", atlas_name, " parcels"), legend_title = "Language-selective\nparcel:\n", view = ifelse(atlas$atlas == "aseg", "coronal", "all"), file_name = paste0(atlas_name, "_lang_binary_selective"), file_type = "pdf"),
    list(plot_type = "binary_selective", task = NULL, annotate = TRUE, plot_title = paste0("Language-selective parcels\nin the ", atlas_name, " parcels"), legend_title = "Language-selective\nparcel:\n", view = ifelse(atlas$atlas == "aseg", "coronal", "all"), file_name = paste0(atlas_name, "_lang_binary_selective_annotated"), file_type = "pdf"),
    list(plot_type = "binary_responsive", task = NULL, annotate = FALSE, plot_title = paste0("Language-responsive parcels\nin the ", atlas_name, " parcels"), legend_title = "Language-responsive\nparcel:\n", view = ifelse(atlas$atlas == "aseg", "coronal", "all"), file_name = paste0(atlas_name, "_lang_binary_responsive"), file_type = "pdf"),
    list(plot_type = "binary_responsive", task = NULL, annotate = TRUE, plot_title = paste0("Language-responsive parcels\nin the ", atlas_name, " parcels"), legend_title = "Language-responsive\nparcel:\n", view = ifelse(atlas$atlas == "aseg", "coronal", "all"), file_name = paste0(atlas_name, "_lang_binary_responsive_annotated"), file_type = "pdf"),
    list(plot_type = "selective", task = "Lang", annotate = FALSE, plot_title = paste0("Response to the language contrast\nin the ", atlas_name, " parcels"), legend_title = "Effect Size: \nS - N\n", view = ifelse(atlas$atlas == "aseg", "coronal", "all"), file_name = paste0(atlas_name, "_langloc_selective"), file_type = "pdf"),
    list(plot_type = "selective", task = "Lang", annotate = TRUE, plot_title = paste0("Response to the language contrast\nin the ", atlas_name, " parcels"), legend_title = "Effect Size: \nS - N\n", view = ifelse(atlas$atlas == "aseg", "coronal", "all"), file_name = paste0(atlas_name, "_langloc_selective_annotated"), file_type = "pdf"),
    list(plot_type = "responsive", task = "Lang", annotate = FALSE, plot_title = paste0("Response to the language contrast\nin the ", atlas_name, " parcels"), legend_title = "Effect Size: \nS - N\n", view = ifelse(atlas$atlas == "aseg", "coronal", "all"), file_name = paste0(atlas_name, "_langloc_responsive"), file_type = "pdf"),
    list(plot_type = "responsive", task = "Lang", annotate = TRUE, plot_title = paste0("Response to the language contrast\nin the ", atlas_name, " parcels"), legend_title = "Effect Size: \nS - N\n", view = ifelse(atlas$atlas == "aseg", "coronal", "all"), file_name = paste0(atlas_name, "_langloc_responsive_annotated"), file_type = "pdf"),
    list(plot_type = "selective", task = "Alice", annotate = FALSE, plot_title = paste0("Response to the auditory language contrast\nin the ", atlas_name, " parcels"), legend_title = "Effect Size: \nI - D\n", view = ifelse(atlas$atlas == "aseg", "coronal", "all"), file_name = paste0(atlas_name, "_alice_selective"), file_type = "pdf"),
    list(plot_type = "selective", task = "Alice", annotate = TRUE, plot_title = paste0("Response to the auditory language contrast\nin the ", atlas_name, " parcels"), legend_title = "Effect Size: \nI - D\n", view = ifelse(atlas$atlas == "aseg", "coronal", "all"), file_name = paste0(atlas_name, "_alice_selective_annotated"), file_type = "pdf"),
    list(plot_type = "responsive", task = "Alice", annotate = FALSE, plot_title = paste0("Response to the auditory language contrast\nin the ", atlas_name, " parcels"), legend_title = "Effect Size: \nI - D\n", view = ifelse(atlas$atlas == "aseg", "coronal", "all"), file_name = paste0(atlas_name, "_alice_responsive"), file_type = "pdf"),
    list(plot_type = "responsive", task = "Alice", annotate = TRUE, plot_title = paste0("Response to the auditory language contrast\nin the ", atlas_name, " parcels"), legend_title = "Effect Size: \nI - D\n", view = ifelse(atlas$atlas == "aseg", "coronal", "all"), file_name = paste0(atlas_name, "_alice_responsive_annotated"), file_type = "pdf")
  )
  
  ## only add overlap plots for non-aseg atlases
  if (atlas$atlas != "aseg") {
    
    plot_configurations <- c(plot_configurations, list(
      list(plot_type = "overlap", task = NULL, annotate = FALSE, plot_title = paste0("Overlap between ", atlas_name, " parcels\nand functional language parcels"), legend_title = "Percent overlap\n", view = "all", file_name = paste0(atlas_name, "_overlap"), file_type = "pdf"),
      list(plot_type = "overlap", task = NULL, annotate = TRUE, plot_title = paste0("Overlap between ", atlas_name, " parcels\nand functional language parcels"), legend_title = "Percent overlap\n", view = "all", file_name = paste0(atlas_name, "_overlap_annotated"), file_type = "pdf")
    ))
    
  }
  
  ## loop through each configuration and create the plots
  for (config in plot_configurations) {
    
    ### call the brainplot function with the specified configurations
    brainplot(
      df = df,
      atlas = atlas,
      plot_type = config$plot_type,
      task = config$task,
      plot_title = config$plot_title,
      subtitle = NULL,
      legend_title = config$legend_title,
      legend_on = TRUE,
      # xlab = NULL,
      # ylab = NULL,
      annotate = config$annotate,
      view = config$view,
      folder = folder,
      file_name = config$file_name,
      file_type = config$file_type
    )
    
    print(paste0("Plot created for ", atlas_name, " atlas: ", config$plot_type, " | annotate = ", as.character(config$annotate)))
    
  }
  
  print(paste0("Plots created for atlas: ", atlas_name))
  
}

# brainplot_sign

#### Plotting function - atlas on the brain ####
brainplot_sign <- function(df, atl, legend_title, plot_title, name) {
  if (grepl("HOC", name)) {
    x1=300
    x2=1000
    y1=200
    y2=650
  } else {
    x1=140
    x2=520
    y1=100
    y2=350
  }
  plot=ggplot(df) +
    geom_brain(atlas = atl, position = position_brain(hemi ~ side), color = "grey18", size=0.2, 
               aes(fill=sig)) +
    scale_fill_manual(values = c("0" = "rosybrown1", "1" = "indianred3", na.value = "black"), labels = c("Language-Responsive", "Language-Selective")) +
    theme_brain() +
    scale_x_continuous(breaks = c(x1, x2), 
                       labels = c("lateral", "medial")) +
    scale_y_continuous(breaks = c(y1, y2), 
                       labels = c("left", "right")) +
    labs(fill=legend_title,
         title=plot_title)
  print(plot)
  # Ensure atlas folder exists
  dir.create(file.path(here("viz", "images", "main", "by_atlas"), atl$atlas), recursive = TRUE, showWarnings = FALSE)
  ggsave(
    filename = file.path(here("viz", "images", "main", "by_atlas"), atl$atlas, paste0(name, ".pdf")),
    dpi = 500,
    width = 14,
    height = 12,
    units = "cm"
  )
}

# brainplot_effect_selective

brainplot_effect_selective <- function(df, atl, legend_title, plot_title, name) {
  if (grepl("HOC", name)) {
    x1=300
    x2=1000
    y1=200
    y2=650
  } else {
    x1=140
    x2=520
    y1=100
    y2=350
  }
  plot=ggplot(df) +
    geom_brain(atlas = atl, position = position_brain(hemi ~ side), color = "grey18", size=0.2, 
               aes(fill=MeanEffectSelect)) +
    scale_fill_gradient(low="white", high="red4", limits = c(0, 3)) +
    theme_brain() +
    scale_x_continuous(breaks = c(x1, x2), 
                       labels = c("lateral", "medial")) +
    scale_y_continuous(breaks = c(y1, y2), 
                       labels = c("left", "right")) +
    labs(fill=legend_title,
         title=plot_title) +
    expand_limits(fill = seq("0", "2.5", by=0.5))
  print(plot)
  # Ensure atlas folder exists
  dir.create(file.path(here("viz", "images", "main", "by_atlas"), atl$atlas), recursive = TRUE, showWarnings = FALSE)
  ggsave(
    filename = file.path(here("viz", "images", "main", "by_atlas"), atl$atlas, paste0(name, ".pdf")),
    dpi = 500,
    width = 14,
    height = 12,
    units = "cm"
  )
}