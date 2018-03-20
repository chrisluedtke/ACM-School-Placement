# Diverse Team Creation

How do you take a large pool of people and create fixed number of teams from them which maximize their racial and gender diversity, equally distributes certain beneficial skills and experiences, and ensure certain rules are followed in the placement like not allowing 17-20 year old's on certain teams?

This type of problem falls into the general umbrella of combinatorial optimization, where we are interested in finding the best comination in a large pool of possibilities. For example, for a site of 80 ACMs spitting into 8 equally sized teams, there are 2.1e12 possible combinations. This problem is is also an interesting twist on classic cases because of the number of different constraints and variables we have on our placements, where as more classic version such as the Nurse Scheduling Problem or College Admissions Problem have scoring functions that are only in terms of one variable.  

In this technical post, we will go over how we implemented our solution to this problem sufficiently so that you might adapt it to your own problem.  Our suspicion is that this type of problem happens quite frequently, though perhaps the people facing it often don't have the technical tools to solve it. 

## Defining the Business Need

Each City Year site faces the challenge of creating diverse teams every year as we deploy teams of 17-25 year old AmeriCorps members into schools in cities around the United States.  For the vast majority of sites, the solution was essentially to do it by hand. Managers and Directors would just do their best to make sure that they got relatively "equal" teams.  As we will explore in greater detail, this solution is costly in terms of time and invites certain biases.  It was particularly challenging at larger scale sites, which lead to City Year Los Angeles, with 25 team to place, to independently developing a solution using VBA and Excel in 2013.  After several years of an effective but slow implementation, this team formed to improve it using the  R programming language.

## Researching and Defining Our Approach

## Encoding the Inputs

## Flattening the Search Space

Firm constraints...

## Defining the Loss Function

Since we have many different variables contributing to the score of the placement, we need to build a scoring function for each individual variable.  This requires some choices be made about how we will calculate something like a "score" for the age distribution.  For some variables, this was fairly straightforward.  For example, for education experience (and a number of other variables) we set ideal targets at each school for the numbers of high school graduate and ACMs with some college experience.  This set the ideal number of ACMs from those two subgroup for each team according to distributing them equally to each team.  Then at each iteration we would simply take the difference in desired ACMs from that subgroup and the actual, and the square the result. For other variables we would calculate values like the variance of the ages of the team compared to the variance of the ages of the Corps at he site, and take the absolute value of their difference.  Once we had calculated the individaul scores for each variable, we would add them up to get the total score.

### Scores on Different Scale

One issue we encountered was that our scores were on dramatically different scales.  Some were small values in the tens to hundreds, others were millions.  This imbalance caused a need for us to attempt to balance each score and then also apply a weighting method at the end so that we can vary the importance of each input.

## Scheduling the Annealing Process

## Results

## Advocating for the Solution

### Problems with Hand Placement

There are a few potential problems in this approach.

#### Cost in terms of worker time

First is the time commitment. The cost to the entire network in terms of the number of worker-hours it takes to complete all placements by hand is in the thousands of worker hours. Here's a breakdown of that estimate: There are probably around 350 program managers in the network. If it takes 4 to 8 hours of full staff to complete placements, then we are looking at between 350*4=1400 to 350*8=2800 hours. 

#### Unconscious Bias

Second is the invitation of unconscious bias into the process. By having managers choose their own teammates, we invite like-me biases and other forms of unconscious biases to cause us to deviate from the mean.