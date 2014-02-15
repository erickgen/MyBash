#!/bin/bash

# 配置信息
mysql_user="user"
mysql_password="password"
mysql_host="localhost"
mysql_port="3306"
mysql_charset="utf8"
backup_db_arr=("mianshui-db" "stat")
backup_location=/home/genghonghao/mysqlbackup #备份位置
expire_backup_delete="ON" #是否开启过期过期备份删除
expire_days=3 #过期时间天数 默认为三天，此项只在expire_backup_delete开启时有效

#预定义数据不需要修改
backup_time=`date +%Y%m%d%H%M` #定义备份详细时间
backup_Ymd=`date +%Y-%m-%d` #定义备份目录中的年月日时间
backup_3ago=`date -d '3 days ago' +%Y-%m-%d` #3天之前的日期
backup_dir=$backup_location/$backup_Ymd #备份文件夹全路径
welcome_msg="Welcome to use MySQL backup tools!" #欢迎语

#判断MYSQL是否启动，如果没启过刚退出备份
mysql_ps=`ps -ef|grep mysql |wc -l`
mysql_listen=`netstat -an |grep LISTEN |grep $mysql_port|wc -l`
if [ [$mysql_ps == 0] -o [$mysql_listen == 0] ]; then
    echo "ERROR:MySQL is not running! backup stop!"
    exit
else
    echo $welcome_msg
fi

#连接MYSQL数据库，无法连接则退出备份
/usr/local/mysql/bin/mysql -h$mysql_host -P$mysql_port -u$mysql_user -p$mysql_password <<end 
use mysql;
select host,user from user where user='root' and host='localhost';
exit
end

flag=`echo $?`
if [ $flag != "0" ]; then
    echo "ERROR:Can't connect mysql server! backup stop!"
    exit
else
    echo "MySQL connect ok! Please wait......"
    # 判断有没有定义备份的数据库，如果定义则开始备份，否则退出备份
    if [ "$backup_db_arr" != "" ]; then
        #dbnames=$(cut -d ',' -f1-5 $backup_database)
        #echo "arr is (${backup_db_arr[@]})"
        for dbname in ${backup_db_arr[@]}
        do
            echo "database $dbname backup start..."
            `mkdir -p $backup_dir`
            `/usr/local/mysql/bin/mysqldump -h$mysql_host -P$mysql_port -u$mysql_user -p$mysql_password $dbname --default-character-set=$mysql_charset|gzip > $backup_dir/$dbname-$backup_time.sql.gz`
            flag=`echo $?`
            if [ $flag == "0" ]; then
                echo "database $dbname success backup to $backup_dir/$dbname-$backup_time.sql.gz"
            else 
                echo "database $dbname backup fail!"
            fi
        done
    else
        echo "ERROR:No database to backup! backup stop"
        exit
    fi

    #如果开启了删除过期备份，则进行删除操作
    if [ "$expire_backup_delete" == "ON" -a "$backup_location" != "" ]; then
        `find $backup_location/ -type d -mtime +$expire_days|xargs rm -rf`
        echo "Expired backup data delete complete"
    fi
    echo "All database backup success! Thank you!"
    exit
fi


