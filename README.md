# The extended language network: Language selective brain areas whose contributions to language remain to be discovered

This repository contains code and data accompanying:

`Wolna, A., Wright, A., Casto, C., Hutchinson, S., Lipkin, B., & Fedorenko, E. (2025). The extended language network: Language selective brain areas whose contributions to language remain to be discovered. *bioRxiv*, 2025-04. https://www.biorxiv.org/content/10.1101/2025.04.02.646835v2`

![](viz/images/supplemental/ext_lang_net_brain.png)

## Abstract
```
Although language neuroscience has largely focused on ‘core’ left frontal and temporal brain areas and their right-hemisphere homotopes, numerous other areas—cortical, subcortical, and cerebellar—have been implicated in linguistic processing. However, these areas’ contributions to language remain unclear given that the evidence for their recruitment comes from diverse paradigms, many of which conflate language processing with perceptual, motor, or task-related cognitive processes. Using fMRI data from 772 participants performing an extensively-validated language ‘localizer’ paradigm that isolates language processing from other processes, we a) delineate a comprehensive set of areas that respond reliably to language across written and auditory modalities, and b) evaluate these areas’ selectivity for language relative to a demanding non-linguistic task. In line with prior claims, many areas outside the core fronto-temporal network respond during language processing, and most of them show selectivity for language relative to general task demands. These language-selective areas of the extended language network include areas around the temporal poles, in the medial frontal cortex, in the hippocampus, and in the cerebellum, among others. Although distributed across many parts of the brain, the extended language-selective network still only comprises ~1.2% of the brain’s volume and is about the size of a strawberry, challenging the view that language processing is broadly distributed across the cortical surface. These newly identified language-selective areas can now be systematically characterized to decipher their contributions to language processing, including testing whether these contributions differ from those of the core language areas.
```

## Project configuration & environment

The environment is a R 4.4.1 environment that makes heavy use of [Tidyverse packages](https://www.tidyverse.org/packages/), [{ggseg}](https://github.com/ggseg/ggseg), [{emmeans}](https://cran.r-project.org/web/packages/emmeans/index.html), [{lmerTest}](https://cran.r-project.org/web/packages/lmerTest/index.html), and [{patchwork}](https://patchwork.data-imaginist.com). Packages and environment managed by [{renv}](https://rstudio.github.io/renv/); organization managed by [{here}](https://here.r-lib.org)

To get started:

1.  Clone the repository:

    ``` bash
    # git clone https://github.com/aaronwriight/extended_language_network.git # internal use
    # git clone https://github.com/aaronwriight/extended_language_network-osf.git # reproducibility / external use
    cd extended_language_network
    ```

To recreate the exact R environment used in the paper, run:

2.  Run the setup script:

    ``` bash
    chmod +x ./dev/setup-dev.sh
    ./dev/setup-dev.sh
    ```

This script will install R dependencies based on dependencies listed in the `renv.lock` file and configure your environment accordingly.

3.  Open the `extended_language_network.Rproj` file in RStudio or Positron and begin exploring or running the code.

## Repository structure & pipeline

Below is a high-level overview of the directories and files imporant for reproducing analyses and visualizations included throughout the project. Outputs from scripts, renderings, etc. are not necessarily listed below, nor included in the default repo. Many are masked in the .gitignore by default to keep a clean repo space, and will only appear as scripts are run locally.

**`Bolded`** items appear on [OSF](https://osf.io/7594t/, in either the main repository, or the GitHub folder (sourced from [extended_language_network-osf](https://github.com/aaronwriight/extended_language_network-osf)

*`Italicized`* items are noteworthy items omitted or hidden by the .gitignore

***NB***: some files necessary for processing/analysis have been purposefully excluded from the external repository for such reasons as file size issues, anonymity concerns, or otherwise.

### Organization

```         
extended_language_network/
├── data/                                       # raw data input to scripts
│   ├── {auditory_language | reading_language | spatial_WM}_localizer/
│   │   ├── *_subjects.csv                      # subject lists for functional data
│   │   └── Funcloc/                            # functional data
│   ├── functional_language_parcels/            # .nii data (original GSS parcels)
│   ├── MDfROIs/                                 # statistical data for 3 localizers (fROIs defined by MDfROI parcels)
│   ├── AtlasParcels.xlsx                       # atlas parcellations
│   ├── detail_all.txt                          # comprehensive data for GSS and atlas parcels
│   ├── detail_atlases_top10_top100.txt         # comprehensive data for GSS and atlas parcels at different thresholds
│   ├── detail_gss_p.001.txt                    # GSS parcels, thresholded at p.001
│   ├── detail_langloc_size_comparison.txt      # parcel size comparison at different thresholds
│   ├── recode_conditions.txt                   # re-ordering file for conditions (used in scripts)
│   ├── recode_parcels.txt                      # re-ordering file for parcels (used in scripts)
│   ├── Subjects_table.xlsx                     # EvLab SUBJECTS data
│   └── TableResults.xlsx                       # functional data statistics
│   ├── voxel_overlap_results_average.txt       # overlap between functional parcels and atlas parcels
│   └── whole_brain_lang_estimates.txt          # whole-brain statistical estimates (by-run in each of three preprocessing pipeline)
├── dev/                                        # developmental/set-up scripts
│   ├── osf-dev.sh                              # bash script to locally clone a subset of the repo into a new repo (see OSF desc.)
│   ├── osf.txt                                 # text file specifying files to be used by osf-dev.sh
│   ├── setup-dev.sh                            # bash script to replicate project environment (R or python)
│   └── update-dev.sh                           # bash script to update project environment (R or python)
├── extented_language_network.Rproj             # R project file
├── .gitignore
├── LICENSE
├── osf/                                        # hand-picked files to push to OSF repository
├── misc/                                       # miscellaneous resources
├── _quarto.yml                                 # quarto rendering (keep in root dir)
├── README.md
├── renv/                                       # R environment directory
├── renv.lock                                   # R package lockfile
├── results/
│   ├── stats/                                  # statistical model outputs (e.g., for GSS and atlas parcels)
│   └── tables/                                 # descriptive outputs and summary tables
├── setup-dev.sh                                # Development setup script
├── scripts/                                    # .qmd, .R, and other scripts used in pipeline
├── viz/
│   ├── figures/                                # publication-ready, composite figures manually produced for visualization
│   ├── illustrator/                            # adobe illustrator files used in curating visualizations
│   ├── images/                                 # plots and images produced by scripts
│   │   ├── main/                               # images from main scripts
│   │   └── supplemental/                       # images from supplemental scripts
│   └── presentation/                           # associated conference posters
...
```

### Extended summary

[data](./data): Contains raw data files that are used for inferential and descriptive statistical analyses

-   `auditory_language_localizer` \| `auditory_language_localizer` \| `spatial_WM_localizer`: functional language data
-   `Atlas_Parcels.xlsx`, `Subjects_table.xlsx`, `TableResults.xlsx`: atlas parcels, EvLab subjects, and statistical data
-   *`detail_all.txt`*, *`detail_atlases_top10_top100.txt`*: comprehensive tables of statistical outputs for functional activations in atlas and GSS parcels at different thresholds
-   `detail_gss_p.001`, `detail_langloc_size_comparison.txt`, `voxel_overlap_results_average.txt`, `whole_brain_lang_estimates.txt`: supplemental parcel data files for extended anaylses
- `recode_conditions.txt`, `recode_parcels`: re-ordering files used in scripts to re-map, e.g. old GSS parcel numbering to new numbering schema

[dev](./dev): Setup and maintenance scripts for replicating and updating the project environment.

- `osf-dev.sh`, `osf.txt`: defines and constructs the OSF mirror repository subset (see OSF section for a full)
- `osf.txt`: text file specifying files to be used by osf-dev.sh
- `setup-dev.sh`: recreates the project environment (i.e., here R environment using `renv`)
- `update-dev.sh`: updates the project environment

[misc](./misc): Contains miscellanous files and resources consulted throughout the project

[osf](./osf): hand-picked files for the OSF repository (see OSF section for a full description)

[results](./results): outputs generated during analysis

-   ***`stats`***: statistical outputs from the analyses, organized by atlas type (e.g., DKT, Glasser, etc.). Each subdirectory contains model summaries and test results specific to that analysis
-   ***`tables`***: tables generated from the analyses, organized by atlas type (e.g., DKT, Glasser, etc.). Each subdirectory contains results specific to that analysis
- **`\*_responsive_rois_names*.txt`**, **`\*_selective_rois_names*.txt`**: responsive and selective parcel counts for different analyses
- **`table_*.xlsx`**: different summary tables

[scripts](./scripts): analysis pipeline scripts

-   `00a_sanity_checks.qmd`: archival script - a scratch notebook for miscellanous verifications
-   `00b_miscellaneous_metadata.qmd`: archival script - a scratch notebook for miscellanous info, e.g., demographics
-   `01_get_data`: takes in functional data and outputs `detail_all.txt`, the main data table for subsequent analyses
-   **`02_stats`**: produces the gss (n=772 and n=86) and atlas parcel models/statistics
-   **`03_plots`**: produces a variety of labeled brain plots and the shell of the main cortical and subcortical figures
-   **`04_summary_tables`**: produces a comprehensive list of the distribution of atlas parcels
-   **`05_supplemental_MDfROIs.qmd`**: supp. analyses of fROIs defined by MD (spatial WM) localizer
-   **`10_supplemental_LangfROIs_p.001.qmd`**: supp. analyses and visualizations comparising top10% of parcels to parcels thresholded at p.001
-   **`11_supplemental_LangfROIs_GcSS_excluded_for_size.qmd`**: supp. analyses of GSS ROIs excluded for size
-   **`12_supplemental_correlation_between_preprocessings.qmd`**: supp. comparative analysis between preprocessing pipelines
-   **`13_supplemental_GcSS_n772_n86_model_comparisons.qmd`**: supp. comparative analyses between gss parcels using the n=772 and n=86 partitions of the data
-   **`build_parcels_table.R`**: a helper script for constructing standardized summary tables for parcels
-   **`plot_brains.R`**: a helper script for for plotting raw and statistical data on [{ggseg}](https://github.com/ggseg/ggseg) brains
-   **`plotting_aesthetics.R`**: a helper script for defining aesthetic preferences for plotting
-   **`run_parcel_models.R`**: a helper script for running statistical models on parcel data

[viz](./viz): all vizualisation assets

-    **`figures`**: manually-curated, publication-ready, composite figures (usually illustrator exports)
-    `illustrator`: adobe illustrator files
-    `images`: script-generated images, with subdirectories for `main/` and `supplemental/`
-    `presentation`: conference and symposium posters

# OSF

Information below also appears in the `README-OSF.md`.

## Overview

This repository has been published on [OSF](https://osf.io/7594t/) in accordance with open science goals and principles and includes data and scripts necessary to reproduce analyses and plots reported in the paper "The extended language network: Language selective brain areas whose contributions to language remain to be discovered" by Agata Wolna, Aaron Wright, Samuel Hutchinson, Colton Casto, Benjamin Lipkin, and Evelina Fedorenko:

`Wolna, A., Wright, A., Casto, C., Hutchinson, S., Lipkin, B., & Fedorenko, E. (2025). The extended language network: Language selective brain areas whose contributions to language remain to be discovered. *bioRxiv*, 2025-04. https://www.biorxiv.org/content/10.1101/2025.04.02.646835v2`

In case of any questions about the project, contact Agata Wolna (awolna@mit.edu).

Abstract:
Although language neuroscience has largely focused on ‘core’ left frontal and temporal brain areas and their right-hemisphere homotopes, numerous other areas—cortical, subcortical, and cerebellar—have been implicated in linguistic processing. However, these areas’ contributions to language remain unclear given that the evidence for their recruitment comes from diverse paradigms, many of which conflate language processing with perceptual, motor, or task-related cognitive processes. Using fMRI data from 772 participants performing an extensively-validated language ‘localizer’ paradigm that isolates language processing from other processes, we a) delineate a comprehensive set of areas that respond reliably to language across written and auditory modalities, and b) evaluate these areas’ selectivity for language relative to a demanding non-linguistic task. In line with prior claims, many areas outside the core fronto-temporal network respond during language processing, and most of them show selectivity for language relative to general task demands. These language-selective areas of the extended language network include areas around the temporal poles, in the medial frontal cortex, in the hippocampus, and in the cerebellum, among others. Although distributed across many parts of the brain, the extended language-selective network still only comprises ~1.2% of the brain’s volume and is about the size of a strawberry, challenging the view that language processing is broadly distributed across the cortical surface. These newly identified language-selective areas can now be systematically characterized to decipher their contributions to language processing, including testing whether these contributions differ from those of the core language areas.

Tags: `functional localizers`, `language network`, `neuroscience of language`, `precision fMRI`

## Repository relations & key items

### High-level

The materials (e.g., data and code) supporting this project are distributed across three platforms to accommodate, e.g., file storage restrictions. An extended description of each location and its key content is included below the follow high-level summary:

- **`OSF`**: supplementary materials
    - OSF Storage/ : supplementary materials, including functional_language_parcels, Figures OSF1-5, Tables OSF1-2
    - Extended Language Network (DropBox)/ : linked to DropBox (see DropBox desc. below)
    - Extended Language Network (GitHub - OSF) linked to GitHub (see GitHub desc. below)
- **`GitHub`**: code and reproducibility
    - Internal (main project repository - for authors' personal use)
    - OSF (public-access mirror repository containing a subset of files - for external use)
- **`DropBox`**: raw and large data files that do not fit on OSF or Github

For additional details, see the `README-OSF.md` in the OSF Storage folder, or navigate to the associated public-access mirror repository: [extended_language_network-osf](https://github.com/aaronwriight/extended_language_network-osf)

### Organization across platforms (extended)

**OSF**

```
OSF Storage/
├── FigureOSF1 - SNvsNFix_Overlap
├── FigureOSF2 - Robustness_PreprocessingChoices 
├── FigureOSF3 - Different_GSS_threshold
├── FigureOSF4 - Robustness_fROIDefinitionDetails
├── FigureOSF5 - Robustness_ParticipantSelection
├── functional_language_parcels/                # .nii data (original GSS parcels)
│   ├── symmetrical parcels/
│   └── original GcSS parcels/
├── TableOSF1 - ExtendedLanguageNetwork_SI_LitReviewTable
├── TableOSF2 - 
...
```

**GitHub-osf**

The GitHub-osf storage is linked through the [OSF](https://osf.io/7594t/) file storage. Key files are shown below; files not specified below are expounded in the README.md in the public-access GitHub repository: [extended_language_network-osf](https://github.com/aaronwriight/extended_language_network-osf)

```         
Extended Language Network (GitHub - OSF)/
├── data/                                       # raw data input to scripts
│   ├── functional_language_parcels/            # .nii data (original GSS parcels)
│   │   ├── symmetrical parcels/
│   │   └── original GcSS parcels/
│   ├── MDfROIs/                                # statistical data for 3 localizers (fROIs defined by MDfROI parcels)
│   ├── AtlasParcels.xlsx                       # atlas parcellations
│   ├── detail_gss_p.001.txt                    # GSS parcels, thresholded at p.001
│   ├── detail_langloc_size_comparison.txt      # parcel size comparison at different thresholds
│   ├── recode_conditions.txt                   # re-ordering file for conditions (used in scripts)
│   ├── recode_parcels.txt                      # re-ordering file for parcels (used in scripts)
│   ├── voxel_overlap_results_average.txt       # overlap between functional parcels and atlas parcels
│   └── whole_brain_lang_estimates.txt          # whole-brain statistical estimates (by-run in each of three preprocessing pipeline)
├── dev/                                        # developmental/set-up scripts
│   ├── setup-dev.sh                            # bash script to replicate project environment (R or python)
│   └── update-dev.sh                           # bash script to update project environment (R or python)
├── results/
│   ├── stats/                                  # statistical model outputs (e.g., for GSS and atlas parcels)
│   │   ├── atlas_model_stats
│   │   ├── gss_n86_model_stats
│   │   └── gss_n772_model_stats
│   ├── tables/                                 # descriptive outputs and summary tables
│   │   ├── atlas_lang_responsive_rois_names_top100.txt
│   │   ├── atlas_lang_responsive_rois_names_.txt
│   │   ├── atlas_lang_selective_rois_names_top100.txt
│   │   ├── atlas_lang_responsive_rois_names.txt
│   │   ├── gss86_lang_responsive_rois_names_.txt
│   │   ├── gss86_lang_selective_rois_names_.txt
│   │   ├── gss772_lang_responsive_rois_names_.txt
│   │   ├── gss772_lang_selective_rois_names_.txt
│   │   ├── `Table1.xlsx`: UNIQUE functional GSS parcels (responsive and selective, n=772) and UNIQUE HOSubCort parcels.
│   │   ├── `Table2.xlsx`: UNIQUE atlas parcels (DKT, Glasser, HoCort), and NO HOSubCort parcels
│   │   ├── `TableO1.xlsx`: COMPREHENSIVE atlas parcels (DKT, Glasser, HoCort), and NO HOSubCort parcels
│   │   ├── `TableO2A.xlsx`: ALL functional GSS parcels (responsive and selective, n=772) and ALL HOSubCort parcels.
│   │   ├── `TableO2B.xlsx`: ALL functional GSS parcels (responsive and selective, n=86) and NO HOSubCort parcels.
│   │   └── `TableO3.xlsx`: literature review, same as osf/TableOSF1 - ExtendedLanguageNetwork_SI_LitReviewTable
├── scripts/
│   ├── `02_stats`: produces the gss (n=772 and n=86) and atlas parcel models/statistics
│   ├── `03_plots`: produces a variety of labeled brain plots and the shell of the main cortical and subcortical figures
│   ├── `04_summary_tables`: produces a comprehensive list of the distribution of atlas parcels
│   ├── `05_supplemental_MDfROIs.qmd`: supp. analyses of fROIs defined by MD (spatial WM) localizer
│   ├── `10_supplemental_LangfROIs_p.001.qmd`: supp. analyses and visualizations comparising top10% of parcels to parcels thresholded at p.001
│   ├── `11_supplemental_LangfROIs_GcSS_excluded_for_size.qmd`: supp. analyses of GSS ROIs excluded for size
│   ├── `12_supplemental_correlation_between_preprocessings.qmd`: supp. comparative analysis between preprocessing pipelines
│   ├── `13_supplemental_GcSS_n772_n86_model_comparisons.qmd`: supp. comparative analyses between gss parcels using the n=772 and n=86 partitions of the data
│   ├── `build_parcels_table.R`: a helper script for constructing standardized summary tables for parcels
│   ├── `plot_brains.R`: a helper script for for plotting raw and statistical data on [{ggseg}](https://github.com/ggseg/ggseg) brains
│   ├── `plotting_aesthetics.R`: a helper script for defining aesthetic preferences for plotting
│   └── `run_parcel_models.R`: a helper script for running statistical models on parcel data
├── viz/
│   ├── figures/                                # publication-ready, composite figures manually produced for visualization
│   ├── images/                                 # plots and images produced by scripts
│   │   ├── main/                               # images from main scripts
│   │   └── supplemental/                       # images from supplemental scripts
...
```

**Dropbox**

The Dropbox storage is linked through the [OSF](https://osf.io/7594t/) file storage. It includes large files and supplemental data ***not*** natively on GitHub or OSF.

```         
Extended Language Network (DropBox)/
├── first_level_contrast_maps/                  # statistical contrast maps
│   ├── Auditory language localizer/
│   ├── Reading language localizer/
│   └── Spatial WM localizer
├── functional_language_parcels/                # .nii data (original GSS parcels)
│   ├── symmetrical parcels/
│   └── original GcSS parcels/
├── langloc_unsmoothed_statistical_maps_n86/    # unsmoothed contrast estimates for subjects who completed all three localizers
├── raw_data/
│   ├── detail_all.txt                          # comprehensive data for GSS and atlas parcels
│   └── detail_atlases_top10_top100.txt         # comprehensive data for GSS and atlas parcels at different thresholds
...
```

## Citation

If you use this repository or data, please cite:

```         
@article{Wolna2025,
  bibtex_show = {true},
  title = {The extended language network: Language selective brain areas whose contributions to language remain to be discovered},
  author = {Wolna, Agata and **Wright, Aaron** and Casto, Colton and Hutchinson, Samuel, Lipkin, Benjamin and Fedorenko, Evelina},
  abstract = {Although language neuroscience has largely focused on ‘core’ left frontal and temporal brain areas and their right-hemisphere homotopes, numerous other areas—cortical, subcortical, and cerebellar—have been implicated in linguistic processing. However, these areas’ contributions to language remain unclear given that the evidence for their recruitment comes from diverse paradigms, many of which conflate language processing with perceptual, motor, or task-related cognitive processes. Using fMRI data from 772 participants performing an extensively-validated language ‘localizer’ paradigm that isolates language processing from other processes, we a) delineate a comprehensive set of areas that respond reliably to language across written and auditory modalities, and b) evaluate these areas’ selectivity for language relative to a demanding non-linguistic task. In line with prior claims, many areas outside the core fronto-temporal network respond during language processing, and most of them show selectivity for language relative to general task demands. These language-selective areas of the extended language network include areas around the temporal poles, in the medial frontal cortex, in the hippocampus, and in the cerebellum, among others. Although distributed across many parts of the brain, the extended language-selective network still only comprises ~1.2% of the brain’s volume and is about the size of a strawberry, challenging the view that language processing is broadly distributed across the cortical surface. These newly identified language-selective areas can now be systematically characterized to decipher their contributions to language processing, including testing whether these contributions differ from those of the core language areas.},
  journal = {bioRxiv},
  year = {2025},
  date = {2024/01/03},
  volume = {},
  issue = {},
  pages = {},
  doi = {10.1101/2025.04.02.646835},
  url = {https://doi.org/10.1101/2025.04.02.646835},
  pdf = {https://www.biorxiv.org/content/10.1101/2025.04.02.646835v2.full.pdf},
  selected = {true},
  recommended_citation = {Wolna, A., Wright, A., Casto, C., Hutchinson, S., Lipkin, B., & Fedorenko, E. (2025). The extended language network: Language selective brain areas whose contributions to language remain to be discovered. *bioRxiv*, 2025-04. https://doi.org/10.1101/2025.04.02.646835.}
}
```

## License

This project is open source and available under the [MIT License](LICENSE).

README.md templated from [Greta Tuckute](https://github.com/gretatuckute/drive_suppress_brains/blob/main/README.md) and [Guillaume Noblet](https://github.com/gnoblet/TidyTuesday/blob/main/README.md)