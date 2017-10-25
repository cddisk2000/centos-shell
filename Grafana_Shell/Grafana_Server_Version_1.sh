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
| Grafana 4.5.2-1 FOR CentOS 7                     1
+----------------------------------------------------------------------
| Install Grafana Plugin                           2
+----------------------------------------------------------------------
| Config Grafana E-mail  Aleart                    3
+----------------------------------------------------------------------
| Check TCP | 3000 |                               4
+----------------------------------------------------------------------
| Check Grafana Log                                5
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
hostnamectl set-hostname Grafana

#關閉「Selinux」為「disabled」才不會阻擋「服務連線」服務
#使用「sed」將「SELINUX=enforcing」替換「SELINUX=disabled」
sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config


#=== 設定 Grafana Firewall ============
 
# Grafana-Http (Server) 3000/TCP
sudo firewall-cmd --add-port=3000/tcp --permanent 

#重新啟動「防火牆」
sudo firewall-cmd --reload



  #====建立「grafana.repo」資源庫=====
  # cat                 主要功能「查看」、「建立」
  # <<EOF               配置文件開始標誌
  # >/opt/grafana.repo  將「內文」寫入「grafana.repo」
  # 最後面 EOF 告訴 系統，這止結束。
#cat <<EOF >/etc/yum.repos.d/grafana.repo
#[grafana]
#name=grafana
#baseurl=https://packagecloud.io/grafana/stable/el/6/$basearch
#repo_gpgcheck=1
#enabled=1
#gpgcheck=1
#gpgkey=https://packagecloud.io/gpg.key https://grafanarel.s3.amazonaws.com/RPM-GPG-KEY-grafana
#sslverify=1
#sslcacert=/etc/pki/tls/certs/ca-bundle.crt
#EOF

#下載「grafana-4.5.2-1.x86_64.rpm」並「安裝」
sudo yum install https://s3-us-west-2.amazonaws.com/grafana-releases/release/grafana-4.5.2-1.x86_64.rpm -y

#使用「yum」安裝「grafana」
sudo yum install grafana -y

#啟動「grafana-server」
sudo service grafana-server start

#開機「自動」啟用「grafana-server」
sudo systemctl enable grafana-server.service

fi




#=============判斷「輸入」2 安裝「Grafana Plugin」=========
if [ $select = 2 ]; then

#安裝「Grafan」For「percona-percona-app」Plugin
grafana-cli plugins install percona-percona-app

#安裝「Grafan」For「Example app for Grafana」Plugin
grafana-cli plugins install grafana-example-app

#安裝「Grafan」For「Pannel - Monitor Elasticsearch」Plugin (監控 ELK)
grafana-cli plugins install stagemonitor-elasticsearch-app

#安裝「Grafan」For「Pannel - Raintank Worldping」Plugin
grafana-cli plugins install raintank-worldping-app

#安裝「Grafan」For「Pannel - Worldmap Panel」Plugin (世界地圖)
grafana-cli plugins install grafana-worldmap-panel

#安裝「Grafan」For「Pannel - 3D Globe Panel」Plugin (3D 地圖)
grafana-cli plugins install satellogic-3d-globe-panel

#安裝「Grafan」For「Pannel - Clock」Plugin (時鐘)
grafana-cli plugins install grafana-clock-panel

#安裝「Grafan」For 「Pannel - Pie Chart」Plugin (圓餅圖)
grafana-cli plugins install grafana-piechart-panel

#安裝「Grafan」For 「Pannel - Diagram」Plugin (圖表)
grafana-cli plugins install jdbranham-diagram-panel

#安裝「Grafan」For「Panel - Natel-Plotly」Plugin (點陣圖)
grafana-cli plugins install natel-plotly-panel

#安裝「Grafan」For「Discrete」Plugin 
grafana-cli plugins install natel-discrete-panel

#安裝「Grafan」For「Annunciator」Plugin 
grafana-cli plugins install michaeldmoore-annunciator-panel

#安裝「Grafan」For「Bubble Chart」Plugin 
grafana-cli plugins install digrich-bubblechart-panel

#安裝「Grafan」For「Kentik-App」Plugin
grafana-cli plugins install kentik-app

#安裝「Grafan」For「briangann-datatable-panel」Plugin
grafana-cli plugins install briangann-datatable-panel

#安裝「Grafana」For「Zabbix-Apps」( Zabbix Data API Plugin )
sudo grafana-cli plugins install alexanderzobnin-zabbix-app

#安裝「Grafana」For「prtg-datasource」
grafana-cli plugins install jasonlashua-prtg-datasource

#安裝「Grafana」For「influxdb-datasource」
grafana-cli plugins install grafana-influxdb-08-datasource

#安裝「Grafana」For「Simple-json-datasource」
grafana-cli plugins install grafana-simple-json-datasource

#安裝「Grafana」Ford「ntop-ntopng-datasource」
grafana-cli plugins install ntop-ntopng-datasource


#====「InfluxData - Admin UI 」需要安裝「下面」套件====
yum install -y nodejs
yum install -y openssl
npm install -g yarn
npm install -g grunt-cli
#安裝「natel-influx」( Influx Admin UI) 套件
grafana-cli plugins install natel-influx-admin-panel
#=====END============


#更新「Grafana 」最新「版本」
grafana-cli plugins update-all

#重新啟動「Grafana」
sudo systemctl restart grafana-server

#檢查「Grafana」安裝「套件」
ls -ll /var/lib/grafana/plugins

fi




#=============判斷「輸入」3 設定「E-mail」=========
if [ $select = 3 ]; then

#使用「sed」選擇「311」行。
#「c」替代為「enabled = true」
sed -i '311c enabled = true' /usr/share/grafana/conf/defaults.ini


#===輸入「SMTP」===
echo sample smtp.163.com:25
read -p "Please Enter Smtp_Server " smtp
#選擇「311」行，替代為「host = smtp.163.com:25」。
sed -i "312c host = $smtp" /usr/share/grafana/conf/defaults.ini


#===輸入「smtp_user」===
read -p "Please Enter Smtp_User " user
#選擇「313」行，替代為「user = xxx@163.com」。
sed -i "313c user = $user" /usr/share/grafana/conf/defaults.ini


#===輸入「smtp_password」===
read -p "Please Enter Smtp_Password " password
#選擇「315」行，替代為「password = 123456」。
sed -i "315c password = $password" /usr/share/grafana/conf/defaults.ini


#===輸入「from_address」===
echo sample xxxx@gmail.com
read -p "Please Enter from_address " from_address
#選擇「319」行，替代為「from_address = 15523250128@163.com」。
sed -i "319c from_address = $from_address" /usr/share/grafana/conf/defaults.ini


#===輸入「from_name」===
echo sample Grafana
read -p "Please Enter from_address " from_address
#選擇「320」行，替代為「from_name = Grafana」。
sed -i "320c from_name = $from_address" /usr/share/grafana/conf/defaults.ini


#===重新啟動「Grafana」===
sudo systemctl restart grafana-server

fi





#=============判斷「輸入」4 檢查「3000」端口=========
if [ $select = 4 ]; then

netstat -tulpn | grep -e "3000"

fi



#=============判斷「輸入」5  確認「Log」=========
if [ $select = 5 ]; then

cat /var/log/grafana/grafana.log

fi


#===迴圈結束======
done