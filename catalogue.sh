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
echo "script started executing at: $(date)" 

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

dnf module disable nodejs -y &>>$LOG_FILE
VALIDATE $? "Disabling default nodejs"

dnf module enable nodejs:20 -y &>>$LOG_FILE
VALIDATE $? "Enabling nodejs:20"

dnf install nodejs -y &>>$LOG_FILE
VALIDATE $? "Installing nodejs:20"

id roboshop
if [ $? -eq 0 ]
then 
    echo -e "system user roboshop already created... $Y SKIPPING $N" | tee -a $LOG_FILE
else
    useradd --system --home /app --shell /sbin/nologin --comment "system user roboshop" roboshop &>>$LOG_FILE
    VALIDATE $? "creating system user roboshop"
fi

mkdir -p /app &>>$LOG_FILE
VALIDATE $? "Creating app directory"

rm -rf /app/*
curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip &>>$LOG_FILE
VALIDATE $? "Downloading Catalogue"

cd /app 
unzip /tmp/catalogue.zip &>>$LOG_FILE
VALIDATE $? "Unzipping Catalogue"

npm install &>>$LOG_FILE
VALIDATE $? "Installing dependencies"

cp $USER_DIR/catalogue.service /etc/systemd/system/catalogue.service 
VALIDATE $? "Copying catalogue.service"

systemctl daemon-reload &>>$LOG_FILE
systemctl enable catalogue &>>$LOG_FILE
systemctl start catalogue
VALIDATE $? "Starting catalogue service"

cp $USER_DIR/mongodb.repo /etc/yum.repos.d/mongodb.repo
VALIDATE $? "copying mongodb"

dnf install mongodb-mongosh -y &>>$LOG_FILE
VALIDATE $? "Installinng mongosh client server"

STATUS=$(mongosh --host mongodb.kashok.store --eval 'db.getMongo().getDBNames().indexOf("catalogue")')
if [ $STATUS -lt 0 ]
then 
    mongosh --host mongodb.kashok.store </app/db/master-data.js &>>$LOG_FILE
    VALIDATE $? "Loading data into mongodb"
else 
    echo -e "Data is already loaded... $Y SKIPPING $N"
fi

END_TIME=$(date +%s)
TOTAL_TIME=$(( $END_TIME - $START_TIME ))

echo -e "script execution completed succesfully, $Y time taken: $TOTAL_TIME seconds $N" | tee -a $LOG_FILE


