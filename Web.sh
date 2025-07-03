#!/bin/bash

ID=$( id -u )
TIMESTAMP=$( date +F%-%H:%M:%S)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOGFILE="/tmp/$0-$TIMESTAMP.log"

if [ $ID -ne 0 ]
then
    echo -e "$R You are not a root user $N"
    exit 1
else
    echo -e "$G You are root user $N"
fi

VALIDATE(){
    if [ $? -ne 0 ]
    then
        echo -e "$2 is $G FAILED $N"
        exit 1
    else
        echo -e "$2 is $R SUCCESS $N"
    fi
}

echo "Checking if Nginx is Installed"

dnf list installed nginx &>>$LOGFILE

if [ $? -ne 0 ]
then
    echo -e "$Y Nginx is not Installed $N"
else
    echo -e "$G Nginx is Installed SKIPPING $N"
fi

echo "Installing Nginx"

dnf install nginx -y &>>$LOGFILE

VALIDATE $? "Installation of Nginx"

systemctl enable nginx &>>$LOGFILE

VALIDATE $? "Enabling Nginx"

systemctl start nginx &>>$LOGFILE

VALIDATE $? "Starting Nginx"

echo "Removing Default File"
rm -rf /usr/share/nginx/html/* &>>$LOGFILE

echo "Downloading Web.zip" &>>$LOGFILE
curl -o /tmp/web.zip https://roboshop-builds.s3.amazonaws.com/web.zip

cd /usr/share/nginx/html &>>$LOGFILE

unzip -o /tmp/web.zip &>>$LOGFILE

cp /home/centos/roboshop-shell/roboshop.conf /etc/nginx/default.d/ &>>$LOGFILE

systemctl restart nginx &>>$LOGFILE

VALIDATE $? "Restarting Nginx"


