#!/bin/bash

ID=$( id -u )
TIMESTAMP=$( date +%F:%H:%M:%S)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
MONGO_HOST=mongodb.mohankodela.shop

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

dnf module disable nodejs -y &>>$LOGFILE

VALIDATE $? "Disable NodeJS"

dnf module enable nodejs:18 -y &>>$LOGFILE

VALIDATE $? "Enable NodeJS 18"

dnf install nodejs -y &>>$LOGFILE

VALIDATE $? "Installing NodeJS"

id roboshop
if [ $? -ne 0 ]
then
    echo "UserID doesn't exist"
    useradd roboshop
else 
    echo -e "User Exists $Y SKIPPING $N"
fi

mkdir /app &>>$LOGFILE

VALIDATE $? "Create app directory"

curl -L -o /tmp/user.zip https://roboshop-builds.s3.amazonaws.com/user.zip

cd /app 

unzip -o /tmp/user.zip

npm install &>>$LOGFILE

VALIDATE $? "Installing Modules"

cp /home/centos/roboshop-shell/user.service /etc/systemd/system/

systemctl daemon-reload &>>$LOGFILE

VALIDATE $? "Reload"

systemctl enable user &>>$LOGFILE

VALIDATE $? "Enable"

systemctl start user &>>$LOGFILE

VALIDATE $? "Start"

cp /home/centos/roboshop-shell/mongo.repo /etc/yum.repos.d/ &>>$LOGFILE

dnf install mongodb-org-shell -y &>>$LOGFILE

VALIDATE $? "Installing Mongo Shell"

mongo --host $MONGO_HOST </app/schema/user.js &>>$LOGFILE

VALIDATE $? "Add Schema"