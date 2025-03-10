#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

if [[ -z $1 ]]
then
  echo "Please provide an element as an argument."
else

  # Determine if input is a number or a string
  if [[ $1 =~ ^[0-9]+$ ]]; then
    SEARCH_QUERY="e.atomic_number = $1"
  else
    SEARCH_QUERY="e.symbol = '$1' OR e.name = '$1'"
  fi

  # Fetch element details (case-sensitive search)
  ELEMENT_INFO=$($PSQL "SELECT e.atomic_number, e.symbol, e.name, t.type, p.atomic_mass, p.melting_point_celsius, p.boiling_point_celsius 
                        FROM elements e
                        INNER JOIN properties p ON e.atomic_number = p.atomic_number
                        INNER JOIN types t ON p.type_id = t.type_id
                        WHERE $SEARCH_QUERY")

  # If element found, process data
  if [[ -n $ELEMENT_INFO ]]
  then
    IFS="|" read -r NUMBER SYMBOL NAME TYPE MASS MELTING BOILING <<< "$ELEMENT_INFO"
    echo "The element with atomic number $NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MELTING celsius and a boiling point of $BOILING celsius."
  else
    echo "I could not find that element in the database."
  fi
fi
