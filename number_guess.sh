#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# Header/ask for username
echo -e "\n~~ Number Guessing Game ~~\n"
echo Enter your username:
read ENTERED_USERNAME

# Check if username is returning
USERNAME=$($PSQL "SELECT username FROM users WHERE username = '$ENTERED_USERNAME'")
if [[ -z $USERNAME ]]
# If not, make new username
then USERNAME=$ENTERED_USERNAME
# Mark account as new
NEW="new"
# Greet as new
echo "Welcome, $ENTERED_USERNAME! It looks like this is your first time here."

# If so, get previous information
else 
GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE username = '$USERNAME'")
BEST_GUESS=$($PSQL "SELECT best_game_guesses FROM users WHERE username = '$USERNAME'")

# Greet as returning
echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GUESS guesses."
fi

# Generate random number
RANDOM_NUMBER=$(( $RANDOM % 1000 ))
echo "Guess the secret number between 1 and 1000:"

GUESSES=0
# Function for guesses
NUMBER_GUESS() {
if [[ $1 ]]
then echo $1
fi
read USER_GUESS
# If not integer, message
if ! [[ $USER_GUESS =~ ^[0-9]+$ ]]
then NUMBER_GUESS "That is not an integer, guess again:"

# If less than, message + increment
elif [[ $USER_GUESS < $RANDOM_NUMBER ]]
then GUESSES=$(( GUESSES + 1 ))
NUMBER_GUESS "It's higher than that, guess again:"

# If greater than, message + increment
elif [[ $USER_GUESS > $RANDOM_NUMBER ]]
then GUESSES=$(( GUESSES + 1 ))
NUMBER_GUESS "It's lower than that, guess again:"

# If correct guess, message and deliver increment
elif [[ $USER_GUESS == $RANDOM_NUMBER ]]
then GUESSES=$(( GUESSES + 1 ))
echo "You guessed it in $GUESSES tries. The secret number was $RANDOM_NUMBER. Nice job!"
fi
}
NUMBER_GUESS

# Check if user is new and if not, insert username, 1 game, and guesses
if [[ $NEW == "new" ]]
then 
SAVE_USER=$($PSQL "INSERT INTO users(username, games_played, best_game_guesses) VALUES('$USERNAME', 1, $GUESSES)")
else 
# Check if number is less than previous
if [[ $BEST_GUESS > $GUESSES ]]
# If so, send to database
then 
SAVE_GUESS=$($PSQL "UPDATE users SET best_game_guesses = $GUESSES WHERE username = '$USERNAME'")
fi
# Increment number of games played
SAVE_GAMES=$($PSQL "UPDATE users SET games_played = $(( $GAMES_PLAYED + 1 )) WHERE username = '$USERNAME'")
fi
