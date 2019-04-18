#!/bin/bash

FILE=/opt/apnic/ip_apnic
rm -rf $FILE
wget http://ftp.apnic.net/apnic/stats/apnic/delegated-apnic-latest -O $FILE 
grep "apnic|CN|ipv4|" $FILE | cut -f4,5 -d '|' | sed -e "s/|/  /g" | while read ip cnt
do
echo $ip:$cnt
mask=$(cat << EOF | bc | tail -1
      pow=32;
      define log2(x) {
      if (x<=1)return(pow);
      pow--;
      return (log2(x/2));
      }    
      log2($cnt)
EOF
)
echo $ip/$mask >> cn.net  #cn.net保存所有的过滤出来的地址信息
if whois $ip -h whois.apnic.net | grep -i "*.chinanet.*\| *.telecom.*" > /dev/null;
then
       echo $ip/$mask >> chinanet
elif whois $ip -h whois.apnic.net | grep -i "*.unicom.*" > /dev/null;
then 
      echo $ip/$mask >> unicom
else  
      echo $ip/$mask >> others
fi
done

