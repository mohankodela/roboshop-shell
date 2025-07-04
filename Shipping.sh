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

dnf install maven -y &>>$LOGFILE

VALIDATE $? "Install Maven"

useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOGFILE

VALIDATE $? "Add user roboshop"

mkdir /app &>>$LOGFILE

VALIDATE $? "Create app directory"

curl -L -o /tmp/shipping.zip https://roboshop-artifacts.s3.amazonaws.com/shipping-v3.zip

cd /app 

unzip /tmp/shipping.zip

mvn clean package  &>>$LOGFILE

VALIDATE $? "Clean MVN Package"

mv target/shipping-1.0.jar shipping.jar  &>>$LOGFILE

cp /home/centos/roboshop-shell/shipping.service /etc/systemd/system/

systemctl daemon-reload &>>$LOGFILE

VALIDATE $? "Daemon Reload"

systemctl enable shipping  &>>$LOGFILE

VALIDATE $? "Enable Shipping"

systemctl start shipping &>>$LOGFILE

VALIDATE $? "Start Shipping"

dnf install mysql -y &>>$LOGFILE

VALIDATE $? "Install MySQL"

mysql -h mysql.mohankodela.shop -uroot -pRoboShop@1 < /app/db/schema.sql

mysql -h mysql.mohankodela.shop -uroot -pRoboShop@1 < /app/db/app-user.sql 

mysql -h mysql.mohankodela.shop -uroot -pRoboShop@1 < /app/db/master-data.sql

systemctl restart shipping &>>$LOGFILE

VALIDATE $? "Restart Shipping"
