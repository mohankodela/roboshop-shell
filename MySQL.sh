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

dnf module disable mysql -y

VALIDATE $? "Disable MySQL"

cp /home/centos/roboshop-shell/mysql.repo /etc/yum.repos.d/

dnf install mysql-community-server -y

VALIDATE $? "Install MySQL"

systemctl enable mysqld

VALIDATE $? "Enable MySQL"

systemctl start mysqld

VALIDATE $? "Start MySQL"

mysql_secure_installation --set-root-pass RoboShop@1

VALIDATE $? "Set Password"
