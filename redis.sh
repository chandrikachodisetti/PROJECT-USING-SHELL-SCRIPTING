#!/bin/bash

user_id=$(id -u)
logs_folder="/var/log/roboshop"
logs_file="${logs_folder}/${0}.log"
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
    date '+%d-%m-%Y %H:%M:%S'
}

validate(){
    if [ $1 -ne 0 ]; then
        echo -e "${timestamp}[ERROR] ${2}..${R}FAILED${N}" | tee -a $logs_file
        exit 1
    else
        echo -e "${timestamp} [INFO] ${2}..${G}SUCCESS${N}" | tee -a $logs_file
    fi
}
echo "$timestamp =======script started execution=========" 
dnf module disable redis -y
dnf module enable redis:7 -y
dnf install redis -y
validate $? "install redis" &>> $logs_file

sed -i -e 's/^bind 127.0.0.1/bind 0.0.0.0/' -e 's/^protected-mode yes/protected-mode no/' /etc/redis/redis.conf
validate $? "remote connection" &>> $logs_file

systemctl enable redis
systemctl start redis
validate $? "system enable and start" &>> $logs_file

echo "$timestamp =======total time taken=========" 



