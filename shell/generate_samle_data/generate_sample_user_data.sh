#!/usr/bin/env bash

sample_data_file=sample_user_data.csv
number_of_records=5000

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

userSal[0]="1000000"
userSal[1]="2000000"
userSal[2]="3000000"
userSal[3]="4000000"
userSal[4]="5000000"
userSal[5]="6000000"
userSal[6]="7000000"
userSal[7]="8000000"
userSal[8]="9000000"
userSal[9]="15000000"
userSal[10]="1200000"

echo "Sample data is being generated!!!"

for (( i=1; i<=$number_of_records; i++ ))
do
  randCity=$[$RANDOM % ${#myCity[@]}]
  randSal=$[$RANDOM % ${#userSal[@]}]
#  echo $i",user"$i","${userSal[$randSal]}","${myCity[$randCity]}",91905012540"$i
  echo -e "$i,user$i,${userSal[$randSal]},${myCity[$randCity]},91902$RANDOM$i"
done > $sample_data_file

echo -e "\n\n$sample_data_file file is ready."

#End of script
