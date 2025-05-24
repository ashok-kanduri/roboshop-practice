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