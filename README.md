# AmeriCorps Member School Placement Algorithm

## Project Description 

City Year operates in 28 cities across the United States. At the start of each school year, City Year places thousands of AmeriCorps Members (ACMs) in hundreds of schools as near-peer tutors and mentors. This tool makes these placements based on various firm and soft constraints including commute times, language ability, and team diversity. The two spreadsheet inputs include a survey of all incoming ACMs and a spreadsheet of school information.

## Algorithm Constraints
* Firm Constraints
  * CMs serving in High Schools must be 21+ or have some college experience
  * Roommates cannot be on the same school team
  * Staff can hand-place individual ACMs into schools, and those placements will trump all other constraints
* Soft Constraints
  * Commute times for each ACM are reasonable
  * Consistent gender diversity across teams
  * Consistent ethnic diversity across teams
  * Consistent tutoring experience across all teams
  * Consistent educational attainment across Elementary Schools (3rd-8th grades) and across High Schools (9th grade)
  * Grade level preferences taken into consideration

## Tools and Resources
* R Open and Power BI (Visualization)
* R Optimization and Cleaning Tips
  * [FasteR! HigheR! StrongeR! - A Guide to Speeding Up R Code for Busy People](http://www.noamross.net/blog/2013/4/25/faster-talk.html)
  * [Cleaning Data with R - Nick Mader](http://nsmader.github.io/knitr-sandbox/cleaning-data-with-R.html#intro)

## Similar Problems (Ranked by Relevance)
* [The Traveling Salesman with Simulated Annealing, R, and Shiny](http://toddwschneider.com/posts/traveling-salesman-with-simulated-annealing-r-and-shiny/) - code from their github formed the backbone of our algorithm
* [Nurse Scheduling Problem](https://en.wikipedia.org/wiki/Nurse_scheduling_problem)
  * Simulated Annealing
  * Constraint Programming
* [Assignment Problem](https://en.wikipedia.org/wiki/Assignment_problem)
* [National Resident Match Algorithm](https://en.wikipedia.org/wiki/National_Resident_Matching_Program#Matching_algorithm)
* [Stable Marriage Problem](https://en.wikipedia.org/wiki/Stable_marriage_problem)
