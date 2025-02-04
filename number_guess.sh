#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
#get the username
echo -e "Enter your username:"
read USERNAME
#validate if the user exists
CUSTOMER_EXIST_RESULT=$($PSQL "select number_games, best_game FROM users WHERE username='$USERNAME';")
#create the variables attemps, secret_number and score
ATTEMPS=0
SECRET_NUMBER=0
BEST_GAME=0
GAME_PLAYED=0
if [[ -z $CUSTOMER_EXIST_RESULT ]]
then
#if not exist, show welcome for first time and create the user
echo -e "\nWelcome, $USERNAME! It looks like this is your first time here."
SAVE_CUSTOMER=$($PSQL "insert into users(username) values('$USERNAME');")
else
#assing data to variables
    GAME_PLAYED=$(echo "${CUSTOMER_EXIST_RESULT[0]}" | cut -d'|' -f1)
    BEST_GAME=$(echo "${CUSTOMER_EXIST_RESULT[0]}" | cut -d'|' -f2)
#if exists, show welcome message
echo -e "\nWelcome back, $USERNAME! You have played $GAME_PLAYED games, and your best game took $BEST_GAME guesses."
fi
#generate and store the secret_number between 1 and 1000
SECRET_NUMBER=$(($RANDOM % 1000 + 1))
#show the message to play
echo -e "\nGuess the secret number between 1 and 1000:"
#create a loop to get numbers from the user until guess the secret number
while true
do
#ask and get the user number
read USER_NUMBER
#validate if the input is a number
if ! [[ $USER_NUMBER =~ ^[0-9]+$ ]]
then
 #if the input is not a number,show a message
 echo -e "\nThat is not an integer, guess again:"
 continue
fi
((ATTEMPS++))
if [[ $USER_NUMBER -eq $SECRET_NUMBER ]]
then
#if the number is the guessed, update user's games played
#validate the user's best_score and update it if is necessary
if [[ $BEST_GAME == 0 || $ATTEMPS -lt $BEST_GAME ]]
then
  ((GAME_PLAYED++))
  USER_UPDATED=$($PSQL "update users set number_games=$GAME_PLAYED , best_game=$ATTEMPS where username='$USERNAME';")
else
 ((GAME_PLAYED++))
  USER_UPDATED=$($PSQL "update users set number_games=$GAME_PLAYED  where username='$USERNAME';")
fi
echo -e "\nYou guessed it in $ATTEMPS tries. The secret number was $SECRET_NUMBER. Nice job!"
#finish the loop and the program, showing the final message
break
elif [[  $USER_NUMBER -gt $SECRET_NUMBER ]]
then
#if it's higher than the secret number, show a specific message
 echo -e "\nIt's lower than that, guess again:"
else
#if number is lower than the secret number, show a specific message
 echo -e "\nIt's higher than that, guess again:"
fi
done

