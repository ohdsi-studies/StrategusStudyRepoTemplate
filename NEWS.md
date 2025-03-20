StrategusStudyRepoTemplate 1.1.1
===============
- Revise sample study to reduce execution time (#18)

StrategusStudyRepoTemplate 1.1.0
===============

- Adds a new sample study (T: ACE inhibitors, C:Diuretics, I: Hypertensive Disorder, O: AMI, Angioedema) to use for testing this template at OHDSI network sites.
- Update `renv.lock` to capture updated HADES/DARWIN packages
- Add new TCIS script for creating analysis specification
- Use the Characterization module default settings for features (#7)

StrategusStudyRepoTemplate 1.0.0
===============

- Established this repository to aid the OHDSI community in using Strategus v1.0 for conducting network studies.
- Created [documentation](UsintThisTemplate.md) to describe how to design and distribute a Strategus network study (#4). This documentation also links to the Save our Sisyphus challenge resources that further detail OHDSI network study process. (#4)
- The `renv.lock` file only contains tagged releases of all packages (#1)
- This study template repo also includes Python dependencies which are restored via the `renv` package (#2)
- `renv.lock` contains the dependencies necessary to launch a OHDSI Shiny App Results Viewer (#3)