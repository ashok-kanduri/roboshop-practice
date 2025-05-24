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
USER_DIR=$PWD

mkdir -p $LOGS_FOLDER
echo "script started executing at: "$(date) 

if [ $USERID -eq 0 ]
    then
        echo "your are running with root access" 
    else 
        echo -e "$R ERROR:: please run this script using root access $N"
        exit 1
    fi

 cp $USER_DIR/mongodb.repo /etc/yum.repos.d/mongodb.repo 

VALIDATE(){
    if [ $1 -eq 0 ]
    then
        echo -e "$2 is.... $G SUCCESSFUL $N" | tee -a $LOG_FILE
    else
        echo -e "$2 is.... $R FAILURE $N" | tee -a $LOG_FILE
        exit 1
    fi
}

 dnf install mongodb-org -y &>>$LOG_FILE
 VALIDATE $? "Installing mongobd"

 systemctl enable mongod &>>$LOG_FILE
 VALIDATE $? "Enabling mongodb"

 systemctl start mongod &>>$LOG_FILE
 VALIDATE $? "starting mongodb"

 sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf &>>$LOG_FILE
 VALIDATE $? "Editing mongod.conf file for remote connections"

systemctl restart mongod
VALIDATE $? "restarting mongodb"

END_TIME=$(date +%s)
TOTAL_TIME=$(( $END_TIME - $START_TIME ))

echo -e "script execution completed succesfully, $Y time taken: $TOTAL_TIME seconds $N" | tee -a $LOG_FILE

