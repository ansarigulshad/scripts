#!/usr/bin/env bash

sample_data_file=sample_user_data.csv
number_of_records=100

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

echo "Sample data is being generated!!!"

for (( i=1; i<=$number_of_records; i++ ))
do
  rand=$[$RANDOM % ${#myCity[@]}]
  echo $i",user"$i","${myCity[$rand]}
done > $sample_data_file

echo -e "\n\n$sample_data_file file is ready."
