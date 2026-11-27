#!/bin/bash

user_id=$(id -u)
logs_folder="/var/log/roboshop"
logs_file="${logs_folder}/${0}.log"
domain_name="sep92s.online"
scripts_dir="$(dirname -- "$(realpath -- "$0")")"
 #####scripts_dir=$(dirname "(realpath$0)")
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

if [ $user_id -ne 0 ]; then
    echo "Please run this script with sudo access.."
    exit 1
fi

mkdir -p $logs_folder

timestamp(){
    date "+%d-%m-%Y %H:%M:%S"
}

validate(){
    if [ $1 -ne 0 ]; then
        echo -e "$(timestamp) [ERROR] ${2}..${R}FAILED${N}" | tee -a $logs_file
        exit 1
    else
        echo -e "$(timestamp) [INFO] ${2}..${G}SUCCESS${N}" | tee -a $logs_file
    fi
}
echo "$(timestamp) [info] =======script started execution=========" | tee -a $logs_file

dnf module enable maven:3.9 -y
dnf install maven java-25-openjdk-devel -y
validate $? "java and maven install"

echo "$(timestamp) [info] script completed in $SECONDS Seconds "
echo "$(timestamp) [info] =======script completed execution=========" | tee -a $logs_file
