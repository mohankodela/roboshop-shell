#!/bin/bash

ID=$(id -u)
TIMESTAMP=$(date +%F-%H:%M:%S)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOGFILE="/tmp/$0-$TIMESTAMP"

echo "Script started executing at $TIMESTAMP" &>>$LOGFILE

if [ $ID -ne 0 ]
then    
    echo -e "$R You are not a root user $N"
    exit 1
else
    echo -e "$G You are root user $N"
fi

VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo "$2 is $R FAILED $N"
    else
        echo "$2 is $G SUCCESS $N"
    fi
}

dnf module disable nodejs -y &>>$LOGFILE

VALIDATE $? "Disable Existing NodeJS"

dnf module enable nodejs:18 -y &>>$LOGFILE

VALIDATE $? "Enabling NodeJS 18"

dnf install nodejs -y &>>$LOGFILE

VALIDATE $? "Installing NodeJS 18"

useradd roboshop &>>$LOGFILE

VALIDATE $? "Creating user roboshop"

echo "Creating app directory"
mkdir /app

echo "Downloading catalouge"
curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip

cd /app 

echo "Unzipping catalouge to app directory"
unzip /tmp/catalogue.zip

cd /app

npm install 

VALIDATE $? "Installing Dependencies"

cp /home/centos/roboshop-shell/catalogue.service /etc/systemd/system/

VALIDATE $? "Copying Catalogue Service"

systemctl daemon-reload

systemctl start catalogue

VALIDATE $? "Started Catalogue Service"