# AmeriCorps Member School Placement Algorithm

## Project Description 

Each year City Year places AmeriCorps Members (ACMs) in one of 26 Chicago Public Schools to serve as near-peer tutors and mentors. We are building a tool that will suggest school placements based on various demographic features and school needs. Our current iteration is an Excel Workbook which makes extensive use of VBA, but suffers from poor performance and a clunky user interface.  The goal of this project is to correct these problems using R and Power BI, where the data can be processed in a parallelized way and visualized with greater transparency.
 
## Final Product 
* Excel Workbook with 1 sheet for ACM data and another for setting parameters 
* .pbix file 
* Would contain R script for the deployment  
* Google Maps API Calls made by Query Editor 
* Dashboard for reviewing results 
* If it were fast, we might be able to get it to interact with slicers in Power BI 
* User will need to install R, but we can build in code for installing all the correct packages 
 
## Audience & Usage 
Ideally this will be a tool that each City Year site can use.  Usage of the tool would look like this: 
### Set Up 
1. Eval Rep would need to ensure that they have Power BI Desktop & R (MRAN distribution) installed 
2. Eval Rep would partner with their site leadership to configure the parameter sheet 
3. Eval Rep would work with Recruitment & Admissions to get ACM data and pull it into the ACM sheet 
### Use 
1. Once the Excel workbook is configured, Eval Rep would just need to open PBIX 
1. Ensure that its pointing at the Excel Workbook 
1. Refresh the data (thus executing the deployment algorithm) 
1. Interpret the results 
 
## Development Workflows 
Workflow  | Tools  | Notes
----------|--------|------
Deployment Algorithm  | R  | Will develop and implement algorithm for deploying ACM
Commute information  | Power Query, Google Maps API   | Given School Locations and ACM Zip Codes, will develop a tool for estimating commute time
Deployment Dashboard  | Power BI  | Visualize the results to help communicate the results. Once we get everything together, further exploration will be done to see if we can implement the deployment algorithm in a more interactive way.

## Timeline 
For this product to be useable by the next program year we would need to have a final working product done by mid-July.  A development timeline for that target might be: 
* April 27th - Make decisions on the approach and final product. Ideally figure out pieces that can be assigned to individual point people and begin development of base functionality. 
* May 18th - Call to check in on progress. 
* June 23rd - Pull all pieces into final product and start extensive testing. 
* July 7th - Product must be complete with Demo ready for Summer Academy 

## Features
Parent | Title  | Description  | Necessary?  
-------|--------|--------------|---------------------
 Configuration Workbook  | Updateable Parameters Table  | Excel-based Parameter Table allows stakeholders to set "ideal" distribution of ACMs by school for each of the input features.  | Yes
Configuration Workbook  | ACM Input Table  | An Excel Sheet for collecting all relevant data on ACMs  | Yes
Power BI  | Estimate Commute  | Use the Google Maps API to estimate ACM commute so that it can be added as a feature  | No
Deployment Algorithm  | Deploys ACMs  | Uses algorithm to deploy ACMs to schools while maintaining several criteria.   | Yes
Power BI  | Visualize the Results  | Power BI Dashboard which translates what has been done into a digestible dashboard.  | Yes
Configuration  Workbook  | Allow for manual specification of zone or school  | A feature of the ACM Input Table.  Would need to be able to assign ACMs schools or zones which the algorithm respects.    | Yes
Deployment Algorithm/ Configuration Workbook  | Return final deployment  | Power BI should return the deployed ACMs to the Excel workbook in a third sheet  | Yes
Deployment Algorithm  | Smart Swaps  | As written, the algorithm makes random swaps between all ACMs and makes swaps until it makes positive impact on the residual.  If the algorithm is changed so that it is smarter about which ACMs it is trying to swap, we might be able to reduce the number of iterations  | No
| Deployment Algorithm  | Smart Initial Placement  | The initial placement method used in the original algorithm simply places any ACM at any school. However if we instead initially place ACMs in a smarter way, we may reduce the number of iterations to reach convergence.  Might look like cycling through each school and adding one ACM at a time.  The ACM might be chosen from a distribution of ACMs meeting certain criteria.  | No
