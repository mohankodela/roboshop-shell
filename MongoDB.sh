#!/bin/bash

ID=$(id -u)
TIMESTAMP=$(date +%F-%H:%M:%S)
R="\e[31m"
G="\e[32m"
Y="\e[31m"
N="\e[0m"

LOGFILE="/tmp/$0-$TIMESTAMP.log"

if [ $ID -ne 0 ]
then    
    echo -e "$R You are not a root user $N"
    exit 1
else
    echo -e "$G You are root user $N"
fi

echo "Script has been exuted at $TIMESTAMP" &>>$LOGFILE

VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2 is $R FAILED $N"
    else
        echo -e "$2 is $G SUCCESS $N"
    fi
}

cp mongo.repo /etc/yum.repos.d/mongo.repo &>>$LOGFILE

VALIDATE $? "Copying Mongo Repo"

dnf install mongodb-org -y &>>$LOGFILE

VALIDATE $? "Installing MongoDB"

systemctl enable mongod &>>$LOGFILE

VALIDATE $? "Enabling MongoDB"

systemctl start mongod &>>$LOGFILE

VALIDATE $? "Starting MongoDB"

sed -i "s/127.0.0.1/0.0.0.0/g" /etc/mongod.conf &>>$LOGFILE

VALIDATE $? "Update Config"

systemctl restart mongod &>>$LOGFILE

VALIDATE $? "Restart MongoDB"
