#!/bin/bash

#===產生迴圈======
while :
do


#====顯示「功能」
echo "

+----------------------------------------------------------------------
| 2017.11.13 Write By Landy.Wang Version 3.0
| Blog http://my-fish-it.blogspot.com
+----------------------------------------------------------------------

+----------------------------------------------------------------------
| Download & Unzip ELK 6.0.0 FOR CentOS 7          1
+----------------------------------------------------------------------
| Install ELK 6.0.0 FOR CentOS 7                   2
-----------------------------------------------------------------------
| Edit Elasticsearch Config File                   3
-----------------------------------------------------------------------
| Edit Logstash Config File                        4
-----------------------------------------------------------------------
| Edit Kibana Config File                          5
+----------------------------------------------------------------------
| Restart Elasticsearch                            6
+----------------------------------------------------------------------
| Restart Logstash                                 7
+----------------------------------------------------------------------
| Restart Kibana                                   8
+----------------------------------------------------------------------
| Check |TCP-9200|TCP-5043|UDP-514|TCP-5601        9
+----------------------------------------------------------------------
| Install X-Pack For Elasticsearch、Kibana          10
+----------------------------------------------------------------------
| ELK Web UI http:// Hostname or Local_IP:5601
| ELK For X-PACK Default User:elastic Password:changeme
+----------------------------------------------------------------------
| Note Memory Can Not Be Less Than 4G Best Suggestion 6G
+----------------------------------------------------------------------
"

#===選擇輸入「1」或「2」存入「select」
read -p "Please Choice " select


#=============判斷「輸入」1 安裝「ELK 6.0.0」=========
if [ $select = 1 ]; then


#===下載「elasticsearch」、「logstash」、「kibana」

#切換「/opt」目錄
cd /opt


#====判斷「elasticsearch」檔案「是/否」存在

elasticsearch=`find /opt -name elasticsearch-6.0.0.tar.gz | wc -l`

if [ $elasticsearch == 1 ]; then   
	#解壓縮「elasticsearch-6.0.0.tar.gz」到「當前目錄」
	tar -xzf elasticsearch-6.0.0.tar.gz -C /opt/
	
elif [ $elasticsearch == 0 ]; then
    #下載「elasticsearch」
    wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-6.0.0.tar.gz
	#解壓縮「elasticsearch-6.0.0.tar.gz」到「當前目錄」
	tar -xzf elasticsearch-6.0.0.tar.gz -C /opt/
fi


#====判斷「logstash」檔案「是/否」存在

logstash=`find /opt -name logstash-6.0.0.tar.gz | wc -l`

if [ $logstash == 1 ]; then
	#解壓縮「logstash-6.0.0.tar.gz」到「當前目錄」
    tar -xzf logstash-6.0.0.tar.gz -C /opt/
	
elif [ $logstash == 0 ]; then
    #下載「logstash」
    wget https://artifacts.elastic.co/downloads/logstash/logstash-6.0.0.tar.gz
	#解壓縮「logstash-6.0.0.tar.gz」到「當前目錄」
    tar -xzf logstash-6.0.0.tar.gz -C /opt/
fi


#====判斷「logstash」檔案「是/否」存在

kibana=`find /opt -name kibana-6.0.0-linux-x86_64.tar.gz | wc -l`

if [ $kibana == 1 ]; then
	#解壓縮「kibana-6.0.0-linux-x86_64.tar.gz」到「當前目錄」
    tar -xzf kibana-6.0.0-linux-x86_64.tar.gz -C /opt/
	
elif [ $kibana == 0 ]; then
    #下載「kibana」
    wget https://artifacts.elastic.co/downloads/kibana/kibana-6.0.0-linux-x86_64.tar.gz
	#解壓縮「kibana-6.0.0-linux-x86_64.tar.gz」到「當前目錄」
    tar -xzf kibana-6.0.0-linux-x86_64.tar.gz -C /opt/
fi

#====END==================================


#顯示「位置」
find /opt -name elasticsearch-6.0.0

#顯示「位置」
find /opt -name logstash-6.0.0

#顯示「位置」
find /opt -name kibana-6.0.0-linux-x86_64

fi



#=============判斷「輸入」2 設定「ELK 6.0.0」=========
if [ $select = 2 ]; then


#修改「hostname」
hostnamectl set-hostname elk_6_0_0

#關閉「Selinux」為「disabled」才不會阻擋「服務連線」服務
#使用「sed」將「SELINUX=enforcing」替換「SELINUX=disabled」
sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config


#=== 設定 ELK Firewall ============
 
# ElasticSearch Mapping API 9200/TCP
sudo firewall-cmd --add-port=9200/tcp --permanent 

# Kibana Http Web UI 5601/TCP
sudo firewall-cmd --add-port=5601/tcp --permanent 

# Logstash - FileBeat Collection 5043/TCP  
sudo firewall-cmd --add-port=5043/tcp --permanent 

# Logstash - Network SysLog Collection 514/UDP
sudo firewall-cmd --add-port=514/udp --permanent 

#重新啟動「防火牆」
sudo firewall-cmd --reload


#===更新「epel-release」資源庫===
yum install epel-release -y

#==安裝「java 」======
yum install java -y
yum install java-devel -y

#==安裝「ruby 」======
yum install ruby rubygems -y



#==設定「elasticsearch」( Process Log )======

#建立「elk」使用者 帳號
useradd elk

#賦予「elk」擁有「讀取」權限
chown -R elk:elk /opt/elasticsearch-6.0.0

#最後 面加入「多線程」搜尋
sed -i '$a\thread_pool.search.queue_size: 10000' /opt/elasticsearch-6.0.0/config/elasticsearch.yml
#最後 面加入「transport.host」「network.host」允許「任意」IP 存取「TCP-9200」
sed -i '$a\transport.host: localhost' /opt/elasticsearch-6.0.0/config/elasticsearch.yml
sed -i '$a\network.host: 0.0.0.0' /opt/elasticsearch-6.0.0/config/elasticsearch.yml

#使用「elk」帳號，背景運行「elasticsearch」 程序。TCP-9200
su elk -c 'nohup /opt/elasticsearch-6.0.0/bin/elasticsearch &'

#===================跑回圈確認「elasticsearch-端口狀態」

# for 迴圈「0~2」跑「3」次
for ((i=0; i<3; ++i))
   
   # for 迴圈「開始」
   do
      
	  #「elasticsearch」變數 存入「端口統計」
      elasticsearch=`netstat -ltunp | grep -e "9200" | wc -l`
      
	  #判斷「logstash」為「3」「顯示」OK
	  if [ $elasticsearch==1 ] ; then
	  echo  Elasticsearch Start OK Continue Next Setup!
	    
		#否則「logstash」等待「10」秒
	    elif [ $elasticsearch!=1 ]; then
	      echo  Waiting Elasticsearch Start!
	      #等待「10秒」
          sleep 10000
	  #判斷「結束」  
	  fi
	  
   # for 迴圈「結束」  
   done




#==設定「logstash」( Log Collection ) ======

#建立「logstash」設定檔

cat <<EOF >/opt/logstash-6.0.0/config/logstash-conf.yml

input {
        beats {                       #輸入「監聽」「TCP 5043」端口，接收来自 Filebeat 的 Log
        port => "5043"
        }
}

input {
        syslog {
        port => "514"              #輸入「監聽」「UDP 514」端口，接收来自 網路設備、防火牆 的 Log
       }
}

output {
  elasticsearch { hosts => ["localhost:9200"] }  #輸出「結果」到「elasticsearch」「TCP 9200」端口。
  stdout { codec => rubydebug }
}

EOF


#  執行「logstash」會產生「處理程序」PID。，-f  => 啟動「配置文件」。
nohup /opt/logstash-6.0.0/bin/logstash -f /opt/logstash-6.0.0/config/logstash-conf.yml &



#===================跑回圈確認「logstash-端口狀態」

# for 迴圈「0~2」跑「3」次
for ((i=0; i<3; ++i))
   
   # for 迴圈「開始」
   do
      
	  #「logstash」變數 存入「端口統計」
      logstash=`netstat -ltunp | grep -e "5043" -e "514" | wc -l`
      
	  #判斷「logstash」為「3」「顯示」OK
	  if [ $logstash==3 ] ; then
	  echo  Logstash Start OK Continue Next Setup!
	    
		#否則「logstash」等待「10」秒
	    elif [ $logstash!=3 ]; then
	      echo  Waiting Logstash Start!
	      #等待「10秒」
          sleep 100000
	  #判斷「結束」  
	  fi
	  
   # for 迴圈「結束」  
   done
   


#==設定「kibana」( Web UI )======


#最後 面加入「允許」任意連線
sed -i '$a\server.host: "0.0.0.0"' /opt/kibana-6.0.0-linux-x86_64/config/kibana.yml

#啟動「Kibana Web UI」
/opt/kibana-6.0.0-linux-x86_64/bin/kibana &

fi




#=============判斷「輸入」3 編輯「Elasticsearch」設定檔=========

if [ $select = 3 ]; then
     
vi /opt/elasticsearch-6.0.0/config/elasticsearch.yml

fi 



#=============判斷「輸入」4 編輯「Logstash」設定檔=========

if [ $select = 4 ]; then
     
vi /opt/logstash-6.0.0/config/logstash-conf.yml

fi 


#=============判斷「輸入」5 編輯「Kibana」設定檔=========

if [ $select = 5 ]; then
     
vi /opt/kibana-6.0.0-linux-x86_64/config/kibana.yml

fi



#=============判斷「輸入」6 重啟「ElasticSearch」=========
if [ $select = 6 ]; then

 
  #查找 端口號「PID」
  ElasticSearch_PID=`netstat -ltunp | grep "9200" |awk '{print $7}'|awk -F'/' '{print $1}'`
 
  #Echo ElasticSearch_PID
  echo Kill ElasticSearch_PID $ElasticSearch_PID
	
  #刪除「PID」程序
  kill -9 $ElasticSearch_PID
 
  #Restart ElasticSearch
  echo Restart ElasticSearch
 
  #使用「elk」帳號，背景運行「elasticsearch」 程序。TCP-9200
  su elk -c 'nohup /opt/elasticsearch-6.0.0/bin/elasticsearch &'
 
fi


#=============判斷「輸入」7 重啟「Logstash」=========
if [ $select = 7 ]; then
 
  #查找 端口號「PID」
  Logstash_PID=`netstat -ltunp | grep "5043" |awk '{print $7}'|awk -F'/' '{print $1}'`
 
  #Echo ElasticSearch_PID
  echo Kill Logstash_PID $Logstash_PID
	
  #刪除「PID」程序
  kill -9 $Logstash_PID
 
  #Restart Logstash
  echo Restart Logstash
 
  #執行「logstash」會產生「處理程序」PID。，-f  => 啟動「配置文件」。
  nohup /opt/logstash-6.0.0/bin/logstash -f /opt/logstash-6.0.0/config/logstash-conf.yml &

fi



#=============判斷「輸入」8 重啟「Kibana」=========
if [ $select = 8 ]; then
     
	#查找 端口號「PID」
    Kibana_PID=`netstat -ltunp | grep "5601" |awk '{print $7}'|awk -F'/' '{print $1}'`
	
	#Echo Kibana_PID
	echo Kill Kibana_PID $Kibana_PID
	
    #刪除「PID」程序
    kill -9 $Kibana_PID
	
	#Restart Kibana
	echo Restart Kibana
	
    #啟動「Kibana Web UI」
    /opt/kibana-6.0.0-linux-x86_64/bin/kibana &

fi


#=============判斷「輸入」9 確認「TCP-9200|TCP-5043|UDP-514|TCP-5601」=========
if [ $select = 9 ]; then
     
	#查找 ElasticSearch 端口號「9200」
    ElasticSearch_Count=`netstat -ltunp | grep "9200"|wc -l`
	
	if [ $ElasticSearch_Count != 0 ]; then
	   echo ElasticSearch TCP 9200 - OK
	    else
		  echo ElasticSearch TCP 9200 - Fail
	fi
	#=========================================
	
	
	#查找 Logstash 端口號「5043」
    Logstash_Count=`netstat -ltunp | grep "5043"|wc -l`
	
	if [ $Logstash_Count != 0 ]; then
	   echo Logstash TCP 5043 - OK
	    else
		  echo Logstash TCP 5043 - Fail
	fi
	
	#============================================
	
	
	#查找 Logstash 端口號「514」
    Logstash_Count=`netstat -ltunp | grep "514"|wc -l`
	
	if [ $Logstash_Count != 0 ]; then
	   echo Logstash UDP 514 - OK
	    else
		  echo Logstash UDP 514 - Fail
	fi
	
	#============================================
	
	
	#判斷 ElasticSearch 端口號「5601」
    Kibana_Count=`netstat -ltunp | grep "5601"|wc -l`
	
	if [ $Kibana_Count != 0 ]; then
	   echo Kibana TCP 5601 - OK
	    else
		  echo Kibana TCP 5601 - Fail
	fi
	
	#============================================
	

fi



#=============判斷「輸入」10 安裝「X-Pack For Elasticsearch、Kibana」=========
if [ $select = 10 ]; then

    #切換 「kibana」bin 目錄。
    cd /opt/kibana-6.0.0-linux-x86_64/bin
	
   # kibana 線上安裝「x-pack」套件，時間會比較久，約「5~10」分鐘。
   ./kibana-plugin install x-pack
   
   
    #切換 「elasticsearch」bin 目錄。
    cd /opt/elasticsearch-6.0.0/bin

	#「elasticsearch」安裝 「x-pack」套件，出現「問答」則輸入「2」次「y」
	./elasticsearch-plugin install x-pack << EOF
	y
    y
EOF
   
    	
    #====刪除「logstash」程序
	#查找 端口號「PID」
    Logstash_PID=`netstat -ltunp | grep "5043" |awk '{print $7}'|awk -F'/' '{print $1}'`
	#刪除「PID」程序
    kill -9 $Logstash_PID
    #執行「logstash」會產生「處理程序」PID。，-f  => 啟動「配置文件」。
    nohup /opt/logstash-6.0.0/bin/logstash -f /opt/logstash-6.0.0/config/logstash-conf.yml &
	
    
    
	#====刪除「elasticsearch」程序
    #查找 端口號「PID」
    ElasticSearch_PID=`netstat -ltunp | grep "9200" |awk '{print $7}'|awk -F'/' '{print $1}'`
    #刪除「PID」程序
    kill -9 $ElasticSearch_PID
    #使用「elk」帳號，背景運行「elasticsearch」 程序。TCP-9200
    su elk -c 'nohup /opt/elasticsearch-6.0.0/bin/elasticsearch &'
	
	
	
	#====刪除「Kibana」程序
    #查找 端口號「PID」
    Kibana_PID=`netstat -ltunp | grep "5601" |awk '{print $7}'|awk -F'/' '{print $1}'`
    #刪除「PID」程序
    kill -9 $Kibana_PID
    #啟動「Kibana Web UI」
    /opt/kibana-6.0.0-linux-x86_64/bin/kibana &
   
   
   #====重啟「logstash」、「elasticsearch」、「Kibana Web UI」====
   
   #  執行「logstash」會產生「處理程序」PID。，-f  => 啟動「配置文件」。
   nohup /opt/logstash-6.0.0/bin/logstash -f /opt/logstash-6.0.0/config/logstash-conf.yml &
   
   #等待「5」秒
   sleep 50000
   
   #使用「elk」帳號，背景運行「elasticsearch」 程序。TCP-9200
   su elk -c 'nohup /opt/elasticsearch-6.0.0/bin/elasticsearch &'
   
   #等待「10」秒
   sleep 10000
   
   #啟動「Kibana Web UI」
    /opt/kibana-6.0.0-linux-x86_64/bin/kibana &

fi

#===迴圈結束======
done