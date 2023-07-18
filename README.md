# RMAPI - Coding challenge for obé fitness
## Author: Bruno Trindade

### Implementation
The relevant files can be found here:
```
app
└── controllers
    └── rick_and_morty_characters_controller.rb
lib
├── rick_and_morty_api
│   └── client
│       ├── base.rb
│       └── character.rb
└── rick_and_morty_api.rb
spec
├── lib
│   └── rick_and_morty_api_spec.rb
└── requests
    └── rick_and_morty_characters_spec.rb
```

Part 1 and part 2 of the challenge are both present in the code.

The app can be run the standard way using
```bash
$ rails s
```

When the app is running, requests can be made quite simply by issuing a GET request for (or navigateing a browser to) the URI:
```
http://localhost:3000/api/rick_and_morty_characters/?name=jerry
```
Output is raw JSON.

I've added Apipie documentation just for fun, and it's mounted at root `http://localhost:3000/`

#### **Part 1**
I have integrated with Rick and Morty API's RESTful interface for simplicity, but please refer to my answer to question 2 for reflections on this decision.  The episode information comes as a string ("S01E03" for example), and so the code pulls this episode information, parses the string, and aggregates the counts the instances, putting them into a hash that is propagated to the output indexed by the `appearances` key.

I chose to do most of the heavy lifting in a lib to keep the controller implementation simple, so that adding more endpoints is clean and readable.

The lib itself involves a Base client class that can be inherited; it provides some utility methods like making a request and constructing a URL.  This allows us to change schemas or implementation as needed without making too big a mess.

Tests have been added, with the most important one being the request spec.

#### **Part 2**
I'm using Rails default low-level caching to cache the result of the operation(s).  Within scope of this are the external API calls as well as the aggregation method that counts the appearances. This is not very efficient, and the initial uncached request can take as much as 30 seconds to complete. More on this below.

### Questions answered
#### **Question 1**
This was a bit difficult to be honest.  I looked at the historical episode releases to see if they occurred regularly on a specific day of the week.  This was mostly true, with the exception of the first season.  If we could have complete confidence in this, we'd be able to hold on to our cache longer, expiring between, say 12 hours and 1 week.  It's unclear what the demands are on the availability of up-to-date data, but we could take this further if we understood exactly what time of day new data is made available to us.  In my case, I made the assumption that we can be 24 hours behind given the non-mission-critical nature of this data.

I'm using a file store for caching in development because this allows for easier testing via the console.  In a production environment I would opt for memcache or redis.

#### **Question 2**
First and foremost, using the Rick and Morty API's GraphQL endpoint would improve performance (assuming their query structures under the hood are sane).  The advantage to this would be eliminating the multiple calls to the `episode` endpoint when retrieving the episode/season information.  This was the approach I initially took.  Unfortunately, Rails doesn't have a well-supported GraphQL _client_ library (there is one out there, but it is not very active with many open and old issues and disregarded PRs), and my attempts at making raw requests were hitting some snags.  I couldn't tell if the problem was in my code or in their API itself as I was receiving 200 OK responses, but garbage data.  Rather than spinning my wheels, I integrated with the REST API instead.

Even so, there is a way to improve performance with the REST API.  The way to do this would be to issue each `episode` request within a Thread, then join all the threads.  Since the GIL doesn't prevent us from issuing multiple network calls in parallel, this allows us to shorten the time this method runs from `(T1 + T2 + T3 ... + Tn) + Y` to `Tx + Y`, where `n` is the number of episodes, `Tx` is the duration of the `episode` call that took the longest to return, and `Y` is the timing of the rest of the operations in this endpoint.  This would add some complexity to the code, but could be worth it if Rick and Morty ever got to as many seasons as The Simpsons.

#### **Question 3**
I think most of the downsides come to the performance issues stated in the above answer.  I think the implementation is pretty good, and it is clear how another developer can add endpoints.  The code is concise, and fairly self-explanatory.  Testing is minimal, then again so is the API, but it could deserve another look to see about increasing coverage.  If I had more time, I would revisit making GraphQL requests to the API - assuming that there is nothing wrong on their end.