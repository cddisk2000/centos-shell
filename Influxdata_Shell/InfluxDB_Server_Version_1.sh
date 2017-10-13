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
| InfluxDB 1.3.5 FOR CentOS 7                      1
+----------------------------------------------------------------------
| Check   TCP | 8086                               2
+----------------------------------------------------------------------
| InfluxDB API http:// Local_IP:8086
| Default InfluxDB User「admin」、Password「admin」 (Full Privileges)
| DATABASE collections
+----------------------------------------------------------------------
"

#===選擇輸入「1」或「2」存入「select」
read -p "Please Choice " select


#=============判斷「輸入」1 安裝「Zabbix 3.2」=========
if [ $select = 1 ]; then

#修改「hostname」
hostnamectl set-hostname InfluxDB

#關閉「Selinux」為「disabled」才不會阻擋「服務連線」服務
#使用「sed」將「SELINUX=enforcing」替換「SELINUX=disabled」
sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config
 

#=== 設定 InfluxDB Firewall ============
 
# InfluxDB (Server) 8086/TCP
sudo firewall-cmd --add-port=8086/tcp --permanent

#重新啟動「防火牆」
sudo firewall-cmd --reload


#更新「Yum」庫源
yum install epel-release -y

#====建立「InfluxDB.repo」資源庫=====
# cat                 主要功能「查看」、「建立」
# <<EOF               配置文件開始標誌
# >/opt/grafana.repo  將「內文」寫入「grafana.repo」
# 最後面 EOF 告訴 系統，這止結束。
cat <<EOF >/etc/yum.repos.d/grafana.repo
[influxdb]
name = InfluxDB Repository - RHEL \$releasever
baseurl = https://repos.influxdata.com/rhel/\$releasever/\$basearch/stable
enabled = 1
gpgcheck = 1
gpgkey = https://repos.influxdata.com/influxdb.key
EOF

#安裝「influxdb」
sudo yum install influxdb -y

#啟動「InfluxDB」
systemctl start influxd

#開機自動啟動「InfluxDB」
systemctl enable influxdb.service


#建立「使用者」賦予「最高權限」
/usr/bin/influx -execute " CREATE USER "admin" WITH PASSWORD 'admin' WITH ALL PRIVILEGES "

#建立「資料庫」(collections) 
/usr/bin/influx -execute " CREATE DATABASE "collections" "


#修改「influxdb.conf」配置。
sed -i '201c enabled = true' /etc/influxdb/influxdb.conf

#啟用「8086」允許「任意介面」
sed -i '204c bind-address = ":8086" ' /etc/influxdb/influxdb.conf

sed -i '207c auth-enabled = true' /etc/influxdb/influxdb.conf

sed -i '213c log-enabled = true' /etc/influxdb/influxdb.conf

sed -i '216c write-tracing = false' /etc/influxdb/influxdb.conf

sed -i '220c pprof-enabled = false' /etc/influxdb/influxdb.conf

sed -i '223c https-enabled = false' /etc/influxdb/influxdb.conf

sed -i '226c https-certificate = "/etc/ssl/influxdb.pem" ' /etc/influxdb/influxdb.conf

#重新啟動「InfluxDB」
systemctl restart influxd

fi



if [ $select = 2 ]; then

#顯示「確認」TCP | 8086 通訊協議
netstat -tulpn | grep -e "8086"

fi

#===迴圈結束======
done