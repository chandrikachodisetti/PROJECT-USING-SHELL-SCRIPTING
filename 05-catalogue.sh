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


dnf module disable nodejs -y &>> $logs_file
dnf module enable nodejs:24 -y &>> $logs_file
dnf install nodejs -y  &>> $logs_file
validate $? "nodejs installation"

id roboshop  &>> $logs_file
if [ $? -ne 0 ]; then
     useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>> $logs_file
     validate $? "creating the user for catalogue"
    else 
    echo  -e "$(timestamp)[ INFO ] this user already exits...${Y}SKIPPING${N}"
    fi

mkdir  -p /app  &>> $logs_file
validate $? "creating the folder"

curl -L -o /tmp/catalogue.zip https://raw.githubusercontent.com/daws-92s/roboshop-documentation/refs/heads/main/artifacts/catalogue-v4.zip  &>> $logs_file
validate $? "download the  catalogue code"


cd /app  &>> $logs_file
unzip -o /tmp/catalogue.zip  &>> $logs_file
validate $? "unzipping  the catalogue file"

npm install  &>> $logs_file
validate $? "install the npm depnedcies"

sed -i "s/DOMAIN_NAME/$domain_name/  "$scripts_dir/catalogue.service""  &>> $logs_file
cp  "$scripts_dir/catalogue.service" /etc/systemd/system/catalogue.service  &>> $logs_file

systemctl daemon-reload  &>> $logs_file
systemctl enable catalogue  &>> $logs_file
systemctl start catalogue  &>> $logs_file
validate $? "enable and start"

cp "$scripts_dir/mongo.repo" /etc/yum.repos.d/mongo.repo &>> $logs_file
validate $? "adding mongorepo" 

dnf install mongodb-mongosh -y &>> $logs_file
validate $? "install mongodb"

product_count="$(mongosh --host <mongodb.$domain_name> --quiet --eval 'db.getSiblingDB("catalogue").products.countDocuments()')" 2>> $logs_file
if [ "$product_count" -eq 0 ]; then
mongosh --host mongodb.$domain_name </app/db/master-data.js &>> $logs_file
validate $? "loading products" 
else 
  echo -e "$(timestamp)[ INFO ] product count already exits...${Y}SKIPPING${N}"
fi

systemctl restart catalogue &>> $logs_file
validate $? "system restart"



echo "$(timestamp) [info] script completed in $SECONDS Seconds "
echo "$(timestamp) [info] =======script completed execution=========" | tee -a $logs_file
