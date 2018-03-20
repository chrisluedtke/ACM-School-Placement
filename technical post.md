# Diverse Team Creation

How do you take a large pool of people and create fixed number of teams from them which maximize their racial and gender diversity, equally distributes certain beneficial skills and experiences, and ensure certain rules are followed in the placement like not allowing 17-20 year old's on certain teams?

To those familiar with combinatorial optimization problems, this rings true as a classic, though perhaps more complex situation.  This problem is different from many in the number of different constraints and measurements we have on our placements, where as more classic version such as the Nurse Scheduling Problem or College Admissions Problem have scoring functions that are really in terms of only one variable.  We hope that by detailing our approach, others may a starting point for their own solutions.

## Defining the Business Need

Each City Year site faces the challenge of creating diverse teams every year as we deploy teams of 17-25 year old AmeriCorps members into schools in cities around the United States.  For the vast majority of sites, the solution was essentially to do it by hand. Managers and Directors would just do their best to make sure that they got relatively "equal" teams.  As we will explore in greater detail, this solution is costly in terms of time and invites certain biases.  It was particularly challenging at larger scale sites, which lead to City Year Los Angeles, with 25 team to place, to independently developing a solution using VBA and Excel in 2013.  After several years of an effective but slow implementation, this team formed to improve it using the  R programming language.

## Researching and Defining Our Approach

## Flattening the Search Space

## Defining the Loss Function

## Results

## Advocating for the Solution

### Problems with Hand Placement

There are a few potential problems in this approach.

#### Cost in terms of worker time

First is the time commitment. The cost to the entire network in terms of the number of worker-hours it takes to complete all placements by hand is in the thousands of worker hours. Here's a breakdown of that estimate: There are probably around 350 program managers in the network. If it takes 4 to 8 hours of full staff to complete placements, then we are looking at between 350*4 (1400) to 350*8 (2800) hours. 

#### Unconscious Bias

Second is the invitation of unconscious bias into the process. By having managers choose their own teammates, we invite like-me biases and other forms of unconscious biases to cause us to deviate from the mean.