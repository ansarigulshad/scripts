#!/usr/bin/env bash

myCity[0]="Delhi"
myCity[1]="Pune"
myCity[2]="Indore"
myCity[3]="Bangalore"
myCity[4]="Jaipur"
myCity[5]="Mumbai"
myCity[6]="Kota"
myCity[7]="Panjab"
myCity[8]="Chennai"
myCity[9]="Srinagar"
myCity[10]="Ahemadabad"
myCity[11]="Hydrabad"

rand=$[$RANDOM % ${#myCity[@]}]


for (( i=1; i<=5000000; i++ ))
do
  echo -e "$i,${myCity[$rand]}$i,${myCity[$rand]}"
done > sample_user_data.csv
