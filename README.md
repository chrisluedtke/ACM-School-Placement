# AmeriCorps Member School Placement Algorithm

## Project Description 

City Year operates in 28 cities across the United States. Each year in Chicago, City Year places ~250 AmeriCorps Members (ACMs) in 26 Chicago Public Schools as near-peer tutors and mentors. We are building a tool that produces diverse teams with conisderation of ACM commute times, preferences, skills, and school needs.

## Tools and Resources
* R Open and Power BI (Visualization)
* R Optimization and Cleaning Tips
  * [FasteR! HigheR! StrongeR! - A Guide to Speeding Up R Code for Busy People](http://www.noamross.net/blog/2013/4/25/faster-talk.html)
  * [Cleaning Data with R - Nick Mader](http://nsmader.github.io/knitr-sandbox/cleaning-data-with-R.html#intro)

## Similar Problems (Ranked by Relevance)
* [Nurse Scheduling Problem](https://en.wikipedia.org/wiki/Nurse_scheduling_problem)
  * Simulated Annealing
  * Constraint Programming
* [The Traveling Salesman with Simulated Annealing, R, and Shiny](http://toddwschneider.com/posts/traveling-salesman-with-simulated-annealing-r-and-shiny/) - code from their github formed the backbone of our algorithm
* [Assignment Problem](https://en.wikipedia.org/wiki/Assignment_problem)
* [National Resident Match Algorithm](https://en.wikipedia.org/wiki/National_Resident_Matching_Program#Matching_algorithm)
* [Stable Marriage Problem](https://en.wikipedia.org/wiki/Stable_marriage_problem)

## Final Product
* ACM Survey
* Excel Workbook with ACM characteristics produced by survey
  * Column to manually asign an ACM to a school
* Excel Workbook with School characteristics and desired team characteristics
  * Team Size
  * School Demographics and Language Speaking Needs
* Google Maps API calls to calculate commutes (DONE!)
* Power BI Dashboard for reviewing results
* Easily transferable across City Year sites

## Algorithm Constraints
* Firm Constraints
  * CMs serving in High Schools must be 21+ or have some college experience
  * Roommates cannot be on the same school team
  * Managers can hand-place individual ACMs into schools, and those placements will be firm constraints
* Soft Constraints
  * Commute times for each ACM are reasonable
  * Consistent gender diversity across teams
  * Consistent ethnic diversity across teams
  * Consistent tutoring experience across all teams
  * Consistent educational attainment across Elementary Schools (3rd-8th grades) and across High Schools (9th grade)
  * Grade level preferences taken into consideration

## Timeline 
Date | Milestone
-----|----------
June 23 | Pull all pieces into final product and start extensive testing.
July 7 | Product complete with demo ready to present to sites across the national network.
