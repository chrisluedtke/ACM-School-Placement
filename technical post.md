# Diverse Team Creation

How do you distribute a large pool of people into a fixed number of teams which maximizes racial and gender diversity, equally distributes beneficial skills and experiences, and conforms to certain rules like preventing prior relationship conflicts?

This type of problem falls into the general umbrella of combinatorial optimization, where we are interested in finding the best combination from a large pool of possibilities. For example, for a site of 80 AmeriCorps Members (ACMs) split into 8 equally sized teams, there are 2.1 x 10^12 possible combinations (for comparison...).

In this post, we go over how we implemented our solution to this problem so that others might adapt it to their own use case. 

## Defining the Business Need

Each City Year site faces the challenge of creating diverse teams every year as we deploy teams of 17-25 year old AmeriCorps members into schools in cities around the United States.  For the vast majority of sites, the solution was to do it by hand. Managers and Directors would do their best to make sure they got relatively "equal" teams.  As we will explore in greater detail, this solution is costly in terms of time and invites certain biases.  It was particularly challenging at larger scale sites, which lead to City Year Los Angeles, with 25 teams to place, to independently develop a solution using VBA and Excel in 2013.  After several years of an effective but slow implementation, we chose to build a solution from scratch in the R programming language.

## Researching and Defining Our Approach

There are many classic cases of finding optimal matches across two sets of items. Implementing our solution through the lens of any given case involves different implications for the attributes we collect and the method of scoring "good" placements.

In cases like the [National Resident Match Algorithm](https://en.wikipedia.org/wiki/National_Resident_Matching_Program) and [Stable Marriage Problem](https://en.wikipedia.org/wiki/Stable_marriage_problem), each item of Sets A and B ranks the items on the other set, and the algorithm optimizes placements such that each item in a pair is comparably ranked by the other. While we could feasibly structure our problem similarly, it would require a large logistical lift to ask ACMs to rank schools, let alone asking schools to rank ACMs.

In the [Assignment Problem](https://en.wikipedia.org/wiki/Assignment_problem), a set of agents are matched to a set of tasks, and the goal is to minimize the aggregate cost of assignments. Rideshare solutions might use a similar approach in matching drivers to passengers while optimizing for things like proximity and number of passenger seats required (see also the [Nurse Scheduling Problem](https://en.wikipedia.org/wiki/Nurse_scheduling_problem)). In perhaps the most famous similar case, the [Traveling Salesman Problem](https://en.wikipedia.org/wiki/Travelling_salesman_problem) seeks to find the most optimal route an agent can travel between a list of destinations. These approaches are more aligned with our case, which requires the flexibility to include a number of different constraints and variables.

For each of the above cases, various algorithmic solutions exist. Ultimately we chose simulated annealing, which is a method of randomized iterative optimization that could reasonably be applied to most of the cases above. This solution stood out to us in particular due to [a nicely compiled R implementation for the case of the Traveling Salesman](http://toddwschneider.com/posts/traveling-salesman-with-simulated-annealing-r-and-shiny/). The author's GitHub repository provided the backbone from which we tailored our solution. We can't understate the value of open source software in developing solutions like ours.

The research phase of our project provided an understanding of comparable problems and the language to express our need. With this knowledge we founded a weekly working group in Chicago's local civic tech community, [ChiHackNight](https://chihacknight.org/). We reached out for collaborators with any experience in Simulated Annealing or R, and we formed an enthusiastic group that served as an indispensable sounding board and development space for our implementation.

(TODO: remove unncessary language.  Lol, I think I added way too much.)
Simulated annealing is a probabilistic optimization technique developed Marshal Rosenbluth in 1953, and offers some advantages over alternative optimization techniques frequently used.  Consider the most common solution, a technique called [hill climbing optimization](https://en.wikipedia.org/wiki/Hill_climbing).  Hill Climbing algorithm can be sketched as follows.  Suppose we have 100 ACMs we are going to place onto 10 teams, and we have some pre-defined loss function which gives us a measurement of error for a given placement relative to the "ideal" placement.  Now we begin the algorithm:
  1. Randomly place ACMs onto teams
  2. Calculate the baseline score
  3. For each iteration up to max:
     1. Choose two ACMs at random and swap their teams
     2. Calculate new score
     3. If new score > baseline
         * then keep the swap and update baseline to be the new score
         * otherwise swap back

The general idea is that we start with a random placement and try new placements keeping the good ones and throwing out the bad. It makes intuitive sense that if we do this for long enough, we'll eventually find a much better placement than we started with.  In fact, over thousands of iterations we hope that the algorithm will converge to a particular placement, which we are hoping is at the global minimum of the space defined by our loss function, i.e. the best possible placement. 

Incidently, this method was the one originally implamented in CYLA.

While that all sounds great, the hill climbing algorithm actually suffers from a number of known problems.  Let's start by exploring what I meant by "the space defined by our loss fucntion."  Specifically, this is the space of all possible team placements with the corresponding score.   Hill climbing works great when the loss space has a single optimum, i.e. looks like this: 

![Thanks Wikipedia!](imgs/Hill_climb_one_peak.png)

However our loss space is quite different, as it is expansive with 2.1 x 10^12 combinations for 80 ACMs x 8 teams, and explodes exponentially as we add more ACMs and teams into the problem (at CYLA we have 31 teams and 300 ACMs). Furthermore, as we add complexity to the loss function by measuring more and more variables about the ACMs, this loss space becomes correspondingly multidimensional.  Instead of being 3 dimensional and smooth, as pictured, our loss space has 11 dimensions has many, many peaks and troughs. If we were to picture a 3-dimensional equivalent it might look like:

![Thanks MIT!](imgs/optimization.jpg)

The tendancy for the hill climbing algorithm in this space will be to converge to one of the many dips in the space, but not necessarily (not evan likely) the lowest possible point.  

The simulated annealling alogorithm offers a solution to the problem with just a slight adjustment to hill climbing.  What we need is a strategy which can *explore a series of worse placements.*  The issue with hill climbing is that once it gets stuck in an area where *any swap leads to a worse placement*, then it has converged by its own rules.  But in a method which would allow for explore worse placements, we could escape the lip of the small dip we got stuck in then potentially finding an even lower dip. 

Simulated annealing gets its name from metaleurgy, where the annealing of metals involves heating them up and then slowly cooling to ultimately reduce the defects in the metal.  Analgously, in simulated annealing we have the idea of "temperature" which corresponds to the probability that we'll accept a worse placement. When the temperature is high, the algorithm is more likely to accept a placement which is worse than the one it is currently at.  However, as the temperature cools over the course of the run, the algorithm becomes more conservative and eventually is just hill climbing.  We can adapt the algorithm from before to include these details:

  1. Randomly place ACMs onto teams
  2. Calculate the baseline score and initialize temperature
  3. For each iteration up to max:
     1. Choose two ACMs at random and swap their teams
     2. Calculate new score and update temperature/acceptance probability
     3. If new score > baseline
         * then keep the swap and update baseline to be the new score
         * otherwise:
            * draw random number between 0 and 1
            * if the random number is < the acceptance probability 
              * then keep swap and update baseline
              * else revert swap

## Defining the Loss Function

Since we have many different variables contributing to the score of the placement, we need to build a scoring function for each individual variable.  This requires some choices be made about how we will calculate something like a "score" for the age distribution.  For some variables, this was fairly straightforward.  For example, for education experience (and a number of other variables) we set ideal targets at each school for the numbers of high school graduate and ACMs with some college experience.  This set the ideal number of ACMs from those two subgroup for each team according to distributing them equally to each team.  Then at each iteration we would simply take the difference in desired ACMs from that subgroup and the actual, and the square the result. For other variables we would calculate values like the variance of the ages of the team compared to the variance of the ages of the Corps at he site, and take the absolute value of their difference.  Once we had calculated the individual scores for each variable, we would add them up to get the total score.  

One way we improved the efficiancy of this process was to pre-process the data by changing categorical variables into a series of boolean columns 

### Scores on Different Scales

One issue we encountered was that our scores were on dramatically different scales.  Some were small values in the tens to hundreds, others were millions.  This imbalance caused a need for us to attempt to balance each score and then also apply a weighting method at the end so that we can vary the importance of each input.

## Flattening the Search Space

In an early stage of our solution, we implemented a scoring function that penalized team placements that violated our firm constraints. For example, if two roommates were placed on the same school team, we worsened the placement score by a factor of 10 to disincentivize the match. However, this approach restricted the search behavior of the algorithm by creating large peaks and valleys in the search space.

For example, we want to ensure that Spanish speaking ACMs are placed at schools with greater Spanish speaking need. When we heavily penalized invalid placements based on Spanish speakers, we discovered that these ACMs would get stuck in the first valid placement the algorithm found for them. In order to consider alternative placements for the Spanish speakers, the algorithm would either need to randomly swap two Spanish speakers or accept a dramatically inflated score in an intermediary step before finding better placements for them.

We solved this by writing firm constraints such that certain placements would never occur. When two ACMs are selected to be swapped, the algorithm references two pre-calculated tables that represent each ACM's eligibility to serve at each school and each ACM's eligibility to serve with each other ACM (to prevent roommate and prior relationship conflicts). With more constraints hard-coded into the algorithm, we flattened the search space such that the algorithm explores only valid placements and does not get 'stuck' when it places ACMs in the first valid slot that it finds.

## Scheduling the Annealing Process

By this we mean, what is the function that we use to describe what the temperature should be based on which iteration it is?

## Results

## Advocating for the Solution

### Problems with Hand Placement

There are a few potential problems in this approach.

#### Cost in terms of worker time

First is the time commitment. The cost to the entire network in terms of the number of worker-hours it takes to complete all placements by hand is in the thousands of worker hours. Here's a breakdown of that estimate: There are probably around 350 program managers in the network. If it takes 4 to 8 hours of full staff to complete placements, then we are looking at between 350*4=1400 to 350*8=2800 hours.

#### Unconscious Bias

Second is the invitation of unconscious bias into the process. By having managers choose their own teammates, we invite like-me biases and other forms of unconscious biases to cause us to deviate from the mean.
