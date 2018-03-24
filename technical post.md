# Diverse Team Creation

How do you distribute a large pool of people into a fixed number of teams which maximizes racial and gender diversity, equally distributes beneficial skills and experiences, and conforms to certain rules like preventing prior relationship conflicts?

This type of problem falls into the general umbrella of combinatorial optimization, where we are interested in finding the best combination from a large pool of possibilities. For example, for a site of 80 AmeriCorps Members (ACMs) split into 8 equally sized teams, there are 2.1 x 10^12 possible combinations (for comparison...).

We suspect this type of problem happens quite frequently, often without clarity on the technical steps to solve it. In this post, we go over how we implemented our solution to this problem so that others might adapt it to their own use case. 

## Defining the Business Need

Each City Year site faces the challenge of creating diverse teams every year as we deploy teams of 17-25 year old AmeriCorps members into schools in cities around the United States.  For the vast majority of sites, the solution was to do it by hand. Managers and Directors would do their best to make sure they got relatively "equal" teams.  As we will explore in greater detail, this solution is costly in terms of time and invites certain biases.  It was particularly challenging at larger scale sites, which lead to City Year Los Angeles, with 25 teams to place, to independently develop a solution using VBA and Excel in 2013.  After several years of an effective but slow implementation, we chose to build a solution from scratch in the R programming language.

## Researching and Defining Our Approach

There are many classic cases of finding optimal matches across two sets of items. Implementing our solution through the lens of any given case involves different implications for the attributes we collect and the method of scoring "good" placements.

In cases like the [National Resident Match Algorithm](https://en.wikipedia.org/wiki/National_Resident_Matching_Program) and [Stable Marriage Problem](https://en.wikipedia.org/wiki/Stable_marriage_problem), each item of Sets A and B ranks the items on the other set, and the algorithm optimizes placements such that each item in a pair is comparably ranked by the other. While we could feasibly structure our problem similarly, it would require a large logistical lift to ask ACMs to rank schools, let alone asking schools to rank ACMs.

In the [Assignment Problem](https://en.wikipedia.org/wiki/Assignment_problem), a set of agents are matched to a set of tasks, and the goal is to minimize the aggregate cost of assignments. Rideshare solutions might use a similar approach in matching drivers to passengers while optimizing for things like proximity and number of passenger seats required (see also the [Nurse Scheduling Problem](https://en.wikipedia.org/wiki/Nurse_scheduling_problem)). In perhaps the most famous similar case, the [Traveling Salesman Problem](https://en.wikipedia.org/wiki/Travelling_salesman_problem) seeks to find the most optimal route an agent can travel between a list of destinations. These approaches are more aligned with our case, which requires the flexibility to include a number of different constraints and variables.

For each of the above cases, various algorithmic solutions exist. Ultimately we chose simulated annealing, which is a method of randomized iterative optimization that could reasonably be applied to most of the cases above. This solution stood out to us in particular due to [a nicely compiled R implementation for the case of the Traveling Salesman](http://toddwschneider.com/posts/traveling-salesman-with-simulated-annealing-r-and-shiny/). The author's GitHub repository provided the backbone from which we tailored our solution. We can't understate the value of open source software in developing solutions like ours.

The research phase of our project provided an understanding of comparable problems and the language to express our need. With this knowledge we founded a weekly working group in Chicago's local civic tech community, [ChiHackNight](https://chihacknight.org/). We reached out for collaborators with any experience in Simulated Annealing or R, and we formed an enthusiastic group that served as an indispensable sounding board and development space for our implementation.

(TODO: more language around how simulated annealing operates)

## Encoding the Inputs

## Defining the Loss Function

Since we have many different variables contributing to the score of the placement, we need to build a scoring function for each individual variable.  This requires some choices be made about how we will calculate something like a "score" for the age distribution.  For some variables, this was fairly straightforward.  For example, for education experience (and a number of other variables) we set ideal targets at each school for the numbers of high school graduate and ACMs with some college experience.  This set the ideal number of ACMs from those two subgroup for each team according to distributing them equally to each team.  Then at each iteration we would simply take the difference in desired ACMs from that subgroup and the actual, and the square the result. For other variables we would calculate values like the variance of the ages of the team compared to the variance of the ages of the Corps at he site, and take the absolute value of their difference.  Once we had calculated the individual scores for each variable, we would add them up to get the total score.

### Scores on Different Scales

One issue we encountered was that our scores were on dramatically different scales.  Some were small values in the tens to hundreds, others were millions.  This imbalance caused a need for us to attempt to balance each score and then also apply a weighting method at the end so that we can vary the importance of each input.

## Flattening the Search Space

In an early stage of our solution, we implemented a scoring function that penalized team placements that violated our firm constraints. For example, if two roommates were placed on the same school team, we worsened the placement score by a factor of 10 to disincentivize the match. However, this approach restricted the search behavior of the algorithm by creating large peaks and valleys in the search space.

For example, we want to ensure that Spanish speaking ACMs are placed at schools with greater Spanish speaking need. When we heavily penalized invalid placements based on Spanish speakers, we discovered that these ACMs would get stuck in the first valid placement the algorithm found for them. In order to consider alternative placements for the Spanish speakers, the algorithm would either need to randomly swap two Spanish speakers or accept a dramatically inflated score in an intermediary step before finding better placements for them.

We solved this by writing firm constraints such that certain placements would never occur. When two ACMs are selected to be swapped, the algorithm references two pre-calculated tables that represent each ACM's eligibility to serve at each school and each ACM's eligibility to serve with each other ACM (to prevent roommate and prior relationship conflicts). With more constraints hard-coded into the algorithm, we flattened the search space such that the algorithm explores only valid placements and does not get 'stuck' when it places ACMs in the first valid slot that it finds.

## Scheduling the Annealing Process

## Results

## Advocating for the Solution

### Problems with Hand Placement

There are a few potential problems in this approach.

#### Cost in terms of worker time

First is the time commitment. The cost to the entire network in terms of the number of worker-hours it takes to complete all placements by hand is in the thousands of worker hours. Here's a breakdown of that estimate: There are probably around 350 program managers in the network. If it takes 4 to 8 hours of full staff to complete placements, then we are looking at between 350*4=1400 to 350*8=2800 hours.

#### Unconscious Bias

Second is the invitation of unconscious bias into the process. By having managers choose their own teammates, we invite like-me biases and other forms of unconscious biases to cause us to deviate from the mean.
