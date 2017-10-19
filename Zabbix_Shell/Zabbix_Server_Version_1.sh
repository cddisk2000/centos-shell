#!/bin/bash

#===產生迴圈======
while :
do


#====顯示「功能」
echo "

+----------------------------------------------------------------------
| 2017.10.12 Write By Landy.Wang Version 1.0
| Blog http://my-fish-it.blogspot.com
+----------------------------------------------------------------------

+----------------------------------------------------------------------
| Zabbix 3.2 FOR CentOS 7                         1
+----------------------------------------------------------------------
| Zabbix 3.4 For Centos 7                         2
+----------------------------------------------------------------------
| Modify MariaDB Root Password (Recommendation)   3
+----------------------------------------------------------------------
| Restart Http | MySQL | Zabbix-server |          4
+----------------------------------------------------------------------
| Check Status Http | MySQL | Zabbix-server |     5
+----------------------------------------------------------------------
| Check TCP | 80 | 10051 | 3306 |                 6
+----------------------------------------------------------------------
| Zabbix Install Web Guide http:// Hostname or Local_IP /zabbix/
| Default Zabbix Web Account - User「Admin」、Passowrd「zabbix」
| Default Zabbix MySQL Account - User「zabbix」、Passowrd「2017」 (Only Localhost Login)
+----------------------------------------------------------------------
"

#===選擇輸入「1」或「2」存入「select」
read -p "Please Choice " select


#=============判斷「輸入」1 安裝「Zabbix 3.2」=========
if [ $select = 1 ]; then

#修改「hostname」
hostnamectl set-hostname zabbix-3_2

#關閉「Selinux」為「disabled」才不會阻擋「服務連線」服務
#使用「sed」將「SELINUX=enforcing」替換「SELINUX=disabled」
sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config


#=== 設定 Zabbix Firewall ============
 
# Zabbix-Http (Server) 80/TCP
sudo firewall-cmd --add-port=80/tcp --permanent 

# MySQL (Server) 3306/TCP
sudo firewall-cmd --add-port=3306/tcp --permanent

# Zabbix-Trapper (Server) 10051/TCP、UDP
sudo firewall-cmd --add-port=10051/tcp --permanent 
sudo firewall-cmd --add-port=10051/udp --permanent

#重新啟動「防火牆」
sudo firewall-cmd --reload



#====更新「yum」套件=============
#清理「暫存」
#yum clean all
#「更新」所有「Yum」源
#yum update -y


#====「yum」安裝 「Apache」 ================
yum install httpd -y
#「啟動」及設定「Apache」 開機自動執行
systemctl start httpd
systemctl enable httpd


#====「Yum」安裝 「MariaDB」(MySQL)=========
yum install mariadb-server mariadb -y
#「啟動」及設定「MariaDB」 開機自動執行
systemctl start mariadb
systemctl enable mariadb


#===「Yum」安裝「PHP」套件==============
yum install -y php php-mysql php-gd php-ldap php-odbc php-pear php-xml php-xmlrpc php-mbstring php-snmp php-soap curl curl-devel
#「Apache」PHP 套件 才會生效
systemctl restart httpd.service


#====安裝「Zabbix 3.2」版本庫========
rpm -ivh http://repo.zabbix.com/zabbix/3.2/rhel/7/x86_64/zabbix-release-3.2-1.el7.noarch.rpm
rpm -ivh http://repo.zabbix.com/zabbix/3.2/rhel/7/x86_64/zabbix-get-3.2.2-1.el7.x86_64.rpm


#使用「YUM」安裝「Zabbix」, 執行以下指令安裝 Zabbix 及相關套件: 
#「zabbix-server-mysql」、「zabbix-web-mysql」、「zabbix-agent」、「zabbix-java-gateway」
yum install zabbix-server-mysql zabbix-web-mysql zabbix-agent zabbix-java-gateway -y


# =====設定檔「/etc/httpd/conf.d/zabbix.conf」修改「時間」=====
# php_value date.timezone Asia/Taipei
# 替換「# php_value date.timezone Europe/Riga」為「php_value date.timezone Asia/Taipei」
sed -i s:"        # php_value date.timezone Europe/Riga":"        php_value date.timezone Asia/Taipei":g /etc/httpd/conf.d/zabbix.conf


#重新啟動「Apache-Server」
service httpd restart


#====修改「Zabbix MySQL Password」=====
sed -i 's/# DBPassword=/DBPassword=2017/' /etc/zabbix/zabbix_server.conf

#重新啟動「zabbix-server」
sudo systemctl restart zabbix-server




#======建立「zabbix」資料庫 並 設定「語系」=========
#必須尚未配置「root」密碼 才行
mysql -e ' create database zabbix character set utf8 collate utf8_bin; '

#建立「zabbix」帳號 與 密碼 並 限制「本機」登入「zabbix」資料庫。
#必須尚未配置「root」密碼 才行
mysql -e " GRANT ALL PRIVILEGES on zabbix.* to 'zabbix'@'localhost' IDENTIFIED BY '2017'; "

#更新「MySQL」
#必須尚未配置「root」密碼 才行
mysql -e " FLUSH PRIVILEGES; "


# 因為使用「RPM」安裝「Zabbix」=>「/usr/share/doc/zabbix-server-mysql-3.2.*/create.sql.gz」會有 SQL 檔案。
# -u (帳號) zabbix ，-p 為「驗證密碼」，zabbix 為「資料庫」。
passwd=2017
zcat /usr/share/doc/zabbix-server-mysql-3.2.*/create.sql.gz | mysql -uzabbix -p"$passwd" zabbix



#===進行「相關」啟動「服務」-「Apache | mariadb | zabbix-server」=====
systemctl restart httpd.service
systemctl restart mariadb
systemctl restart zabbix-server

#每次開機啟用「zabbix-server」
systemctl enable zabbix-server

#重新啟動「主機」
reboot -h now

fi




#=============判斷「輸入」2 安裝「Zabbix 3.4」=========
if [ $select = 2 ]; then

#修改「hostname」
hostnamectl set-hostname zabbix-3_4

#關閉「Selinux」為「disabled」才不會阻擋「服務連線」服務
#使用「sed」將「SELINUX=enforcing」替換「SELINUX=disabled」
sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config


#=== 設定 Zabbix Firewall ============
 
# Zabbix-Http (Server) 80/TCP
sudo firewall-cmd --add-port=80/tcp --permanent 

# MySQL (Server) 3306/TCP
sudo firewall-cmd --add-port=3306/tcp --permanent

# Zabbix-Trapper (Server) 10051/TCP、UDP
sudo firewall-cmd --add-port=10051/tcp --permanent 
sudo firewall-cmd --add-port=10051/udp --permanent

#重新啟動「防火牆」
sudo firewall-cmd --reload



#====更新「yum」套件=============
#清理「暫存」
#yum clean all
#「更新」所有「Yum」源
#yum update -y


#====「yum」安裝 「Apache」 ================
yum install httpd -y
#「啟動」及設定「Apache」 開機自動執行
systemctl start httpd
systemctl enable httpd


#====「Yum」安裝 「MariaDB」(MySQL)=========
yum install mariadb-server mariadb -y
#「啟動」及設定「MariaDB」 開機自動執行
systemctl start mariadb
systemctl enable mariadb


#===「Yum」安裝「PHP」套件==============
yum install -y php php-mysql php-gd php-ldap php-odbc php-pear php-xml php-xmlrpc php-mbstring php-snmp php-soap curl curl-devel
#「Apache」PHP 套件 才會生效
systemctl restart httpd.service


#====安裝「Zabbix 3.4」版本庫========
rpm -ivh http://repo.zabbix.com/zabbix/3.4/rhel/7/x86_64/zabbix-release-3.4-1.el7.centos.noarch.rpm
rpm -ivh http://repo.zabbix.com/zabbix/3.4/rhel/7/x86_64/zabbix-get-3.4.0-1.el7.x86_64.rpm


#使用「YUM」安裝「Zabbix」, 執行以下指令安裝 Zabbix 及相關套件: 
#「zabbix-server-mysql」、「zabbix-web-mysql」、「zabbix-agent」、「zabbix-java-gateway」
yum install zabbix-server-mysql zabbix-web-mysql zabbix-agent zabbix-java-gateway -y


# =====設定檔「/etc/httpd/conf.d/zabbix.conf」修改「時間」=====
# php_value date.timezone Asia/Taipei
# 替換「# php_value date.timezone Europe/Riga」為「php_value date.timezone Asia/Taipei」
sed -i s:"        # php_value date.timezone Europe/Riga":"        php_value date.timezone Asia/Taipei":g /etc/httpd/conf.d/zabbix.conf


#重新啟動「Apache-Server」
service httpd restart


#====修改「Zabbix MySQL Password」=====
sed -i 's/# DBPassword=/DBPassword=2017/' /etc/zabbix/zabbix_server.conf

#重新啟動「zabbix-server」
sudo systemctl restart zabbix-server




#======建立「zabbix」資料庫 並 設定「語系」=========
#必須尚未配置「root」密碼 才行
mysql -e ' create database zabbix character set utf8 collate utf8_bin; '

#建立「zabbix」帳號 與 密碼 並 限制「本機」登入「zabbix」資料庫。
#必須尚未配置「root」密碼 才行
mysql -e " GRANT ALL PRIVILEGES on zabbix.* to 'zabbix'@'localhost' IDENTIFIED BY '2017'; "

#更新「MySQL」
#必須尚未配置「root」密碼 才行
mysql -e " FLUSH PRIVILEGES; "


# 因為使用「RPM」安裝「Zabbix」=>「/usr/share/doc/zabbix-server-mysql-3.4.*/create.sql.gz」會有 SQL 檔案。
# -u (帳號) zabbix ，-p 為「驗證密碼」，zabbix 為「資料庫」。
passwd=2017
zcat /usr/share/doc/zabbix-server-mysql-3.4.*/create.sql.gz | mysql -uzabbix -p"$passwd" zabbix



#===進行「相關」啟動「服務」-「Apache | mariadb | zabbix-server」=====
systemctl restart httpd.service
systemctl restart mariadb
systemctl restart zabbix-server

#每次開機啟用「zabbix-server」
systemctl enable zabbix-server


#====啟動「zabbix-agent」
sudo systemctl start zabbix-agent
#==每次開機啟用「zabbix-agent 」。
sudo systemctl enable zabbix-agent

    

#重新啟動「主機」
reboot -h now

fi


#=============判斷「輸入」3 修改「MariaDB」Root 密碼=========
if [ $select = 3 ]; then

/usr/bin/mysql_secure_installation

fi

#=============判斷「輸入」4 重啟「Http | MySQL | Zabbix-server」=========
if [ $select = 4 ]; then

systemctl restart httpd.service

systemctl restart mariadb 

systemctl restart zabbix-server

fi


#=============判斷「輸入」5 安裝「Zabbix 3.4」=========
if [ $select = 5 ]; then

systemctl status httpd

systemctl status mariadb

systemctl status zabbix-server

fi


#=============判斷「輸入」6 檢查「80 | 10051 | 3306」端口=========
if [ $select = 6 ]; then

netstat -tulpn | grep -e "80" -e "10051"  -e "3306"

fi



#===迴圈結束======
done
