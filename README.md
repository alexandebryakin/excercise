# README

## Exercise details are taken from https://github.com/jzajpt/hiring-exercises/tree/master/batting-averages

Ruby version: `2.6.1`
Rails version: ` 5.2.6`

# Endpoints

`POST /batting_average/process`

```
params:
  batting_file: File    [required]
  year:         string  [optional]  <- filters results by year
  team:         string  [optional]  <- filters results by team name
  teams_file:   File    [optional]  <- if not passed it's going to use the one stored in the `db/teams.csv`
```

`Output:` the output would be a JSON string

# Usage

run `rails s` for app to start serving locally (the port would probably be 3000)
run `curl -X POST -F "batting_file=@spec/fixtures/files/batting.csv" http://localhost:3000/batting_average/process`

In this case it's going to use the same file that is stored in the `/spec` directory

But you could also specify the path to your own `Batting.csv` file as
well as the `Teams.scv` file. In order to do that
run `curl -X POST -F "batting_file=@<PATH_TO_Batting.csv>" -F "teams_file=@<PATH_TO_Teams.csv>" http://localhost:3000/batting_average/process`

In order to appply filters use:
`curl -X POST -F "batting_file=@spec/fixtures/files/batting.csv" http://localhost:3000/batting_average/process\?year=2019\&team\=ALIAS`

# The task itself:

# Batting Average App

Batting average is simple and a common way to measure batter’s performance.
Create an app that will ingest a raw CSV file with player statistics and
presents simple UI for ranking and filtering players based on their batting
performance.

## Interface

The application should take an input in form of a CSV file. The file will be
comma separated CSV with headers. The headers that interest you are: “playerID”,
“yearID”, “stint”, teamID”, “AB”, and “H”.

Batting Average is calculated as: BA = H/AB (Hits / At Bats).

Once the file is loaded and processed, the user will see the following table
sorted by Batting Averages:

```
+----------+--------+--------------+-----------------+
| playerID | yearId | Team name(s) | Batting Average |
+----------+--------+--------------+-----------------+
| ...                                                |
+----------------------------------------------------+
```

If the player has more stints in the season, calculate batting average for the
whole season (across all stints), team names are comma separated in that case.
Format the batting average to 3 decimals.

The table should be filterable by any of these:

- Player ID (use autocomplete/searchable select)
- Year (simple select)

When filter is selected, the table presents players that match the filter,
sorted according to their batting average.

## CSV files

The input CSV file is `Batting.csv`. This file includes "teamID", use the
file `Teams.csv` to map "teamID" to a team's real name. You can process the
teams file and have the data ready in your app to map out "teamID" to team
names, it doesn't need to be uploaded from the user.

## Guidelines

- Use any of the major languages that can run on OSX
- The app can be client only or client-server split, up to you
- Do not fork this repo, create a clean one for a solution
- Feel free to ask for any clarification
