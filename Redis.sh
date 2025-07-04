#!/bin/bash

ID=$( id -u )
TIMESTAMP=$( date +%F:%H:%M:%S)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOGFILE="/tmp/$0-$TIMESTAMP.log"

echo "Script start executing at $TIMESTAMP" &>>$LOGFILE

if [ $ID -ne 0 ]
then
    echo -e "$R You are not a ROOT user $N"
    exit 1
else
    echo -e "$G You are ROOT user $N"
fi

VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2 is $R FAILED $N"
        exit 1
    else
        echo -e "$2 is $G SUCCESS $N"
    fi
}

sudo dnf module reset redis &>>$LOGFILE

VALIDATE $? "Reset"

sudo dnf module enable redis:6 -y &>>$LOGFILE

VALIDATE $? "Enable"

sudo dnf install redis -y &>>$LOGFILE

VALIDATE $? "Install"

echo "Updating Config Files"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/redis.conf &>>$LOGFILE

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/redis/redis.conf &>>$LOGFILE

VALIDATE $? "Updating Config Files"

systemctl enable redis &>>$LOGFILE

VALIDATE $? "Enabling Redis"

systemctl start redis &>>$LOGFILE

VALIDATE $? "Starting Redis"