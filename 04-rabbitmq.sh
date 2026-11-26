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

cp rabbitmq.repo /etc/yum.repos.d/rabbitmq.repo &>>$logs_file
validate $? "adding rabbitmq.repo "

dnf install erlang rabbitmq-server -y  &>>$logs_file
validate $? "rabbitmq installation"

systemctl enable rabbitmq-server  &>>$logs_file
systemctl start rabbitmq-server   &>>$logs_file
validate $? "enable and start rabbitmq"

rabbitmqctl add_user roboshop roboshop123  &>>$logs_file
validate $? "creating rabbitmq user for app"
rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>>$logs_file
validate $? "setup the permissions rabbitmq user for app"

echo "$(timestamp) [info] script completed in $SECONDS Seconds "
echo "$(timestamp) [info] =======script completed execution=========" | tee -a $logs_file
