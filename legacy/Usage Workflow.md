# Usage Workflow
### Software Set-Up
1. Install R Open and necessary packages
   * Install necessary packages ("gmapsdistance", "readxl", "googleway", "dplyr", "tidyr", "dummies", "data.table", "doParallel", "doSNOW").
1. Install Power BI
### Project Set-Up
1. Distribute survey to incoming corps
1. Survey export should be named "survey_export.csv"
1. Add column "acm_id", and assign id's to ACMs as survey responses are received
1. Add column "Manual.Placements" and make any manual school assignments by typing a school's formal name in any row
1. Build "Input 3 - School Data.xls" with your site's school information. The `School Name` column should contain spellings that are consistent with those in the `Manual.Placements`column
1. Load Dashboard.pbix in Power BI
   * Edit Queries
    * Change "Folder" query to root directory of your project folder
    * Calculate commutes (not yet built out in Power BI)
    * In the "Output" query, click "Run R - Simulated Annealing" step. At the top of the script, change "root_dir = " to the root directory of your project folder, and set the number_of_iterations you want to run. Click OK. You don't have to wait for the processing to finish, becauase it will re-process when you close the Edit Query window anyway.
1. Review placements. Work with site leadership to adjust and make manual placements if necessary.
