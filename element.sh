#!/bin/bash

# Connect to PostgreSQL
PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

# Function to display element info
display_element() {
  local atomic_num=$1
  local name=$2
  local symbol=$3
  local mass=$4
  local melt=$5
  local boil=$6
  local type=$7

  echo "The element with atomic number $atomic_num is $name ($symbol). It's a $type, with a mass of $mass amu. $name has a melting point of $melt celsius and a boiling point of $boil celsius."
}

# If no argument is provided
if [[ -z $1 ]]; then
  echo "Please provide an element as an argument."
  exit 0
fi

# Determine the search condition based on the input type
if [[ $1 =~ ^[0-9]+$ ]]; then
  # Input is an atomic number
  condition="e.atomic_number = $1"
elif [[ $1 =~ ^[A-Z][a-z]?$ ]]; then
  # Input is a chemical symbol (1-2 letters)
  condition="e.symbol = '$1'"
else
  # Input is an element name
  condition="e.name = '$1'"
fi

# Build and execute the query
query="SELECT 
          e.atomic_number, 
          e.name, 
          e.symbol, 
          p.atomic_mass, 
          p.melting_point_celsius, 
          p.boiling_point_celsius, 
          t.type 
       FROM 
          elements e 
       JOIN properties p ON e.atomic_number = p.atomic_number 
       JOIN types t ON p.type_id = t.type_id 
       WHERE $condition;"

result=$($PSQL "$query")
trimmed_result=$(echo "$result" | xargs)

# Check if result is empty
if [[ -z $trimmed_result ]]; then
  echo "I could not find that element in the database."
  exit 0
else
  # Parse and display result
  IFS="|" read -r atomic_num name symbol mass melt boil type <<< "$trimmed_result"
  display_element "$atomic_num" "$name" "$symbol" "$mass" "$melt" "$boil" "$type"
fi
