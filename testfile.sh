#!/usr/bin/env bash
export NICE_VAR=10
export ANOTHER_VAR=20

for i in {0..25..5}
do
  export NICE_VAR=$NICE_VAR+$i
  echo $NICE_VAR
done

for ((i=1;i<=25;i+=1))
do
  export ANOTHER_VAR=$ANOTHER_VAR+$i
  echo $ANOTHER_VAR
done

if [ $ANOTHER_VAR -gt $NICE_VAR ]
then
  echo "ANOTHER bigger than nice"
else
  echo "Nice is bigger or equal"
fi