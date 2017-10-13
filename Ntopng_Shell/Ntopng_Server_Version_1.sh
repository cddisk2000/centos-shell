#!/bin/bash

#===產生迴圈======
while :
do


#====顯示「功能」
echo "

+----------------------------------------------------------------------
| 2017.10.13 Write By Landy.Wang Version 1.0
| Blog http://my-fish-it.blogspot.com
+----------------------------------------------------------------------

+----------------------------------------------------------------------
| Ntopng 3.1.171009 FOR CentOS 7                   1
+----------------------------------------------------------------------
| Config Ntopng Community  Version                 2
+----------------------------------------------------------------------
| Check Ntopng Status                              3
+----------------------------------------------------------------------
| Check TCP | 3000 |                               4
+----------------------------------------------------------------------
| Check Ntopng File Data                           5
+----------------------------------------------------------------------
| Grafana Web  http:// Hostname or Local_IP:3000
| Default Grafana Web Account - User「admin」、Passowrd「admin」
+----------------------------------------------------------------------
"

#===選擇輸入「1」或「2」存入「select」
read -p "Please Choice " select


#=============判斷「輸入」1 安裝「Zabbix 3.2」=========
if [ $select = 1 ]; then

#修改「hostname」
hostnamectl set-hostname Ntopng

#關閉「Selinux」為「disabled」才不會阻擋「服務連線」服務
#使用「sed」將「SELINUX=enforcing」替換「SELINUX=disabled」
sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config


#=== 設定 Ntopng Firewall ============
 
# Ntopng-Http (Server) 3000/TCP
sudo firewall-cmd --add-port=3000/tcp --permanent 

#重新啟動「防火牆」
sudo firewall-cmd --reload



#切換「Yum」源，根目錄
cd /etc/yum.repos.d/

#「Wget」下載「ntop.repo」修改檔名「ntop.repo」
wget http://packages.ntop.org/centos/ntop.repo -O ntop.repo

#「Rpm」下載「epel-release-latest-7.noarch.rpm」並「安裝」
rpm -ivh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm

#清理「暫存」
yum clean all

#「更新」所有「Yum」源
yum update -y

#安裝「Pfring」、「n2disk」、「nprobe」、「ntopng」、「ntopng-data」、「cento」、「tcpdump」。
yum install pfring n2disk nprobe ntopng ntopng-data cento tcpdump -y

#安裝「pfring」驅動程式
yum install pfring-drivers-zc-dkms -y

#開啟「redis」服務
sudo systemctl start redis.service
#重開機「redis」自動開啟「服務」
sudo systemctl enable redis.service

#開啟「ntopng」服務，啟動「會有錯誤」不用擔心，因為需要「重啟」。
sudo systemctl start ntopng.service
#重開機「ntopng」自動開啟「服務」
sudo systemctl enable ntopng.service

#重新啟動
reboot -h now

fi




#=============判斷「輸入」2 安裝「Ntopng Config Community」=========
if [ $select = 2 ]; then

#在「第一行」後面 插入「下一行」內容
sed -i '1 a --community' /etc/ntopng/ntopng.conf

#重啟「ntopng.service」服務
systemctl restart ntopng.service

#檢查「ntopng.service」狀態
systemctl status ntopng.service

fi




#=============判斷「輸入」3 設定「Ntopng Status」=========
if [ $select = 3 ]; then

#檢查「ntopng」狀態
sudo systemctl status ntopng.service

#檢查「redis」狀態
systemctl status redis.service


fi





#=============判斷「輸入」4 檢查「3000」端口=========
if [ $select = 4 ]; then

netstat -tulpn | grep -e "3000"

fi



#=============判斷「輸入」5  確認「Log」=========
if [ $select = 5 ]; then

find /var/tmp/ntopng/*/top_talkers/*

fi


#===迴圈結束======
done