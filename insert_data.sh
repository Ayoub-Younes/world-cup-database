#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
echo $($PSQL "TRUNCATE teams, games")
echo $($PSQL "ALTER SEQUENCE teams_team_id_seq RESTART WITH 1")
echo $($PSQL "ALTER SEQUENCE games_game_id_seq RESTART WITH 1")

cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
 if [[ $WINNER != winner && $OPPONENT != opponent ]]
 then
 #if team doesn't exist:
 WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$WINNER'")
 OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$OPPONENT'")
 
  if [[ -z $WINNER_ID ]]
  then
   INSERT_TEAM=$($PSQL "INSERT INTO teams(name) VALUES ('$WINNER')")
   echo $WINNER Inserted
  fi

  if [[ -z $OPPONENT_ID ]]
  then
   INSERT_TEAM=$($PSQL "INSERT INTO teams(name) VALUES ('$OPPONENT')")
   echo $OPPONENT Inserted
  fi

  WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$WINNER'")
  OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$OPPONENT'")

  INSERT_GAMES=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES ($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS) RETURNING *")
  echo $INSERT_GAMES

 fi
done
