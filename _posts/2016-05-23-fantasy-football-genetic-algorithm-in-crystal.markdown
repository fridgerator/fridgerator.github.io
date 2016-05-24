---
layout: post
title:  "Fantasy Football Genetic Algorithm in Crystal"
date:   2016-05-23 22:08:08 -0600
comments: true
disqus_url: "http://fridgerator.github.io/2016/05/23/fantasy-football-genetic-algorithm-in-crystal.html"
disqus_identifier: "/2016/05/23/fantasy-football-genetic-algorithm-in-crystal.html"
---

This blog post fueled by [Watch Man IPA](http://empyreanbrewingco.com/beers/watch-man-ipa)

Inspired by a recent talk at [Nebraska.code()](http://nebraskacode.com/) conference - [__Artificial Intelligence: A Crash Course__](http://nebraskacode.com/sessions/artificial-intelligence-a-crash-course) from Josh Durham over at [Beyond the Scores](https://www.beyondthescores.com), I set out to try some AI / Machine learning of my own.

Perhaps one of the more interesting topics in the field, IMO, is the Genetic Algorithm - emulating biological evolution over a data set using natural selection, mutation and breeding.  I'm not going to pretend to be an expert on the topic, to the contrary I am a complete noob and suggestions on how to improve my code are very welcome.

And now the hardest part, finding a suitable application for testing and creating the algorithm.

Last year I started playing fantasy football, using a Rails app I created that allows me to track my team and make efficient recuitments / trades based on the data from the [Fantasy Football Nerd](http://www.fantasyfootballnerd.com/) API.  I also tried my hand at [FanDuel](https://www.fanduel.com) and wrote some brute-force functions (not really knowing much about linear algebra) to try to build the best team with the highest expected points while staying under the salary cap.  But thats boring and took a long time, a reeeeally long time if I used the entire data set - billions of possible combinations.

#### The fantasy football binary knapsack problem.

This idea isn't unique or novel in any way, a quick search returns dozens of others that have applied some kind of genetic algorithm to the fantasy football knapsack problem.  The one thing that does make this unique, is that its written in [Crystal](http://crystal-lang.org/) ;)

My genetic population is a list of randomly generated teams, each containing 9 players (quarterback, two running backs, three wide receivers, a tight end, kicker and defence). Links to [`Team`](https://github.com/fridgerator/fantasy_football_nerd_api/blob/master/src/fantasy_football_nerd/genetic/team.cr) and [`Player`](https://github.com/fridgerator/fantasy_football_nerd_api/blob/master/src/fantasy_football_nerd/genetic/player.cr) classes.

The `Team` class, or - the chromosome, contains several important methods:

  * The `fitness` method returns the total expected points for the team.
  * The `mutate` method, takes a random position on the team and replaces it with another random player of the same position.
  * Also `breed` and `create_child` methods, which takes traits from the 2 parents to produce child teams.

The main `run` loop ([here](https://github.com/fridgerator/fantasy_football_nerd_api/blob/master/src/fantasy_football_nerd/genetic/genetic.cr)) creates a population of 10,000 teams and evolves it a total of 80 times.

In the `evolve` function:

  * The population is sorted by `fitness` (highest first) and the top %65 of teams will continue live in the population, the remaining will be killed off.
  * Teams have a small chance of being mutated during the loop (0.005).  
  * We repopulate our population by breeding two random from the surviving teams.

Check out the beast in action: [http://recordit.co/lu8ZEV916D](http://recordit.co/lu8ZEV916D)

The salaries right now are randomly generated, as I don't have actual data to use since we're not in football season.  And I haven't yet done much tuning of the parameters: changing the population size, number of itterations, mutation percent, etc.

Again, feel free to leave feedback on how this can be improved.  I will probably continue to tweak and modify the algorithm so its ready come football season.