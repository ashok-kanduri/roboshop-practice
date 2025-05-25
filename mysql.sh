#!/bin/bash

START_TIME=$(date +%s)
USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOGS_FOLDER="/var/log/roboshop-logs"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOG_FILE=$LOGS_FOLDER/$SCRIPT_NAME.log
SCRIPT_DIR=$PWD

mkdir -p $LOGS_FOLDER
echo "script started executing at: $(date)" 

if [ $USERID -eq 0 ]
    then
        echo "your are running with root access" 
    else 
        echo -e "$R ERROR:: please run this script using root access $N"
        exit 1
    fi

VALIDATE(){
    if [ $1 -eq 0 ]
    then
        echo -e "$2 is.... $G SUCCESSFUL $N" | tee -a $LOG_FILE
    else
        echo -e "$2 is.... $R FAILURE $N" | tee -a $LOG_FILE
        exit 1
    fi
}

echo "Please enter root password to setup the service:"
read -s ROBOSHOP_ROOT_PASSWORD

dnf install mysql-server -y &>>$LOG_FILE
VALIDATE $? "Installing mysql"

systemctl enable mysqld &>>$LOG_FILE
VALIDATE $? "Enabling mysql"

systemctl start mysqld &>>$LOG_FILE
VALIDATE $? "Starting mysql"

mysql_secure_installation --set-root-pass ROBOSHOP_ROOT_PASSWORD &>>$LOG_FILE 
VALIDATE $? "changing Default password"

END_TIME=$(date +%s)
TOTAL_TIME=$(($END_TIME - $START_TIME ))

echo "script executed succesfully, time taken: $Y $TOTAL_TIME $N seconds" | tee -a  $LOG_FILE
