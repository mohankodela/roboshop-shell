#!/bin/bash

ID=$(id -u)
TIMESTAMP=$(date +%F-%H:%M:%S)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
MONGO_HOST=mongodb.mohankodela.shop

LOGFILE="/tmp/$0-$TIMESTAMP.log"

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
        echo -e "$2 is $R FAILED $N"
    else
        echo -e "$2 is $G SUCCESS $N"
    fi
}

dnf module disable nodejs -y &>>$LOGFILE

VALIDATE $? "Disable Existing NodeJS"

dnf module enable nodejs:18 -y &>>$LOGFILE

VALIDATE $? "Enabling NodeJS 18"

dnf install nodejs -y &>>$LOGFILE

VALIDATE $? "Installing NodeJS 18"

id roboshop

if [ $? -ne 0 ]
then 
    echo "User doesn't exist"
    useradd roboshop
    VALIDATE $? "Creating user roboshop"
else
    echo -e "User already exists.. $Y SKIP $N"
fi

echo "Creating app directory"
mkdir -p /app &>>$LOGFILE

echo "Downloading catalouge"
curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip

cd /app &>>$LOGFILE

echo "Unzipping catalouge to app directory"
unzip -o /tmp/catalogue.zip

cd /app &>>$LOGFILE

npm install &>>$LOGFILE

VALIDATE $? "Installing Dependencies"

cp /home/centos/roboshop-shell/catalogue.service /etc/systemd/system/ &>>$LOGFILE

VALIDATE $? "Copying Catalogue Service"

systemctl daemon-reload &>>$LOGFILE

systemctl start catalogue &>>$LOGFILE

VALIDATE $? "Started Catalogue Service"

cp /home/centos/roboshop-shell/mongo.repo /etc/yum.repos.d/mongo.repo &>>$LOGFILE

VALIDATE $? "Copying MongoDB Repo"

dnf install mongodb-org-shell -y &>>$LOGFILE

VALIDATE $? "Install MongoDB Client"

mongo --host $MONGO_HOST </app/schema/catalogue.js &>>$LOGFILE

VALIDATE $? "Load Schema"