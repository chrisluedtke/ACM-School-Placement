# AmeriCorps Member School Placement Algorithm

## About

City Year operates in 28 cities across the United States. At the start of each school year, City Year places thousands of AmeriCorps Members (ACMs) in hundreds of schools as near-peer tutors and mentors. This tool combines an incoming AmeriCorps Member survey with school data to makes these placements based on various firm and soft constraints including commute times, language ability, and team diversity. The two spreadsheet inputs include a survey of all incoming ACMs and a spreadsheet of school information.

## Constraints
* Firm Constraints
  * ACMs serving in High Schools must be 21+ or have some college experience, as well as declare comfort with algebra
  * Prior relationship conflicts are prevented. This includes preventing roommates from serving at the same school
  * Manual override - user can hand-place any corps members into any school regardless of other constraints
  * Spanish speaker targets at each school are met
* Soft Constraints
  * Commute times are minimized
  * Consistent gender diversity across teams
  * Consistent ethnic diversity across teams

## Requirements
* GitHub, to clone this repository
* Power BI Desktop, to run the algorithm with interactive results
* R Open, to run R script through Power BI

## Related Analyses, by Relevance
* [The Traveling Salesman with Simulated Annealing, R, and Shiny](http://toddwschneider.com/posts/traveling-salesman-with-simulated-annealing-r-and-shiny/) - code from their github formed the backbone of our algorithm
* [Nurse Scheduling Problem](https://en.wikipedia.org/wiki/Nurse_scheduling_problem)
  * Simulated Annealing
  * Constraint Programming
* [Assignment Problem](https://en.wikipedia.org/wiki/Assignment_problem)
* [National Resident Match Algorithm](https://en.wikipedia.org/wiki/National_Resident_Matching_Program#Matching_algorithm)
* [Stable Marriage Problem](https://en.wikipedia.org/wiki/Stable_marriage_problem)

## Project Acknowledgements
* Alex Perusse, algorithm co-lead
* Nick Mader, algorithm support
* Cassandra Chin, collaboration logistics
* Pat Geronimo, Washington DC implementation lead
* Adriana Hernandez, Boston implementation lead
* Mariana Schmalstig, survey logistics