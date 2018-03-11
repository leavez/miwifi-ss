#!/bin/sh

clear
echo "#############################################################"
echo "# Install Shadowsocks for Miwifi"
echo "#############################################################"

# Make sure only root can run our script
if [[ $EUID -ne 0 ]]; then
   echo "Error:This script must be run as root!" 1>&2
   exit 1
fi
cd /userdisk/data/

# setup the ssr
rm -f ssr-bin.zip
curl https://raw.githubusercontent.com/leavez/miwifi-ss/master/r2d/bin.zip -o ssr-bin.zip
unzip ssr-bin.zip
rm ssr-bin.zip

mv bin .shadowsocksR
chmod +x .shadowsocksR/* 

add_to_file_if_needed(){
  result=$(grep -c "$1" $2)
  if [ "$result" -eq 0 ] ; then
      echo "$1" >> $2
  fi
} 
add_to_file_if_needed 'export PATH=/userdisk/data/.shadowsocksR:$PATH'  /etc/profile
add_to_file_if_needed 'export LD_LIBRARY_PATH=/userdisk/data/.shadowsocksR:$LD_LIBRARY_PATH'  /etc/profile


# Config shadowsocks init script
rm -f shadowsocks_miwifi.tar.gz
curl https://raw.githubusercontent.com/leavez/miwifi-ss/master/r2d/shadowsocks_miwifi.tar.gz -o shadowsocks_miwifi.tar.gz
tar zxf shadowsocks_miwifi.tar.gz

cp ./shadowsocks_miwifi/myshadowsocks /etc/init.d/myshadowsocks
chmod +x /etc/init.d/myshadowsocks


# download update gfwlist tool
curl https://raw.githubusercontent.com/leavez/miwifi-ss/master/update_gfw_list_tool.zip -o update_gfw_list_tool.zip
unzip update_gfw_list_tool.zip
rm update_gfw_list_tool.zip
mv update_gfw_list_tool /userdisk/data/.shadowsocksR/update_gfw_list_tool
chmod +x /userdisk/data/.shadowsocksR/update_gfw_list_tool/update_rules.sh
chmod +x /userdisk/data/.shadowsocksR/update_gfw_list_tool/gfwlist2dnsmasq.sh



#config setting and save settings.
echo "#############################################################"
echo "#"
echo "# Please input your shadowsocks configuration"
echo "#"
echo "#############################################################"
echo ""
echo "请输入服务器IP:"
read serverip
echo "请输入服务器端口:"
read serverport
echo "请输入密码"
read shadowsockspwd
echo "请输入加密方式"
read method
echo "请输入 protocol"
read protocol
echo "请输入 protocol_param"
read protocol_param
echo "请输入 obfs"
read obfs
echo "请输入 obfs_param （更多参数请在 /etc/shadowsocks.json 中设置）"
read obfs_param


# Config shadowsocks
cat > /etc/shadowsocks.json<<-EOF
{
  "server":"${serverip}",
  "server_port":${serverport},
  "local_address":"127.0.0.1",
  "local_port":1081,
  "password":"${shadowsockspwd}",
  "timeout":600,
  "method":"${method}",
  "protocol":"${protocol}",
  "protocol_param":"${protocol_param}",
  "obfs":"${obfs}",
  "obfs_param":"${obfs_param}"
}
EOF

#config dnsmasq
mkdir -p /etc/dnsmasq.d
cp -f ./shadowsocks_miwifi/dnsmasq_list.conf /etc/dnsmasq.d/dnsmasq_list.conf

#config firewall
cp -f /etc/firewall.user /etc/firewall.user.back
echo "ipset -N gfwlist iphash -! " >> /etc/firewall.user
echo "iptables -t nat -A PREROUTING -p tcp -m set --match-set gfwlist dst -j REDIRECT --to-port 1081" >> /etc/firewall.user

#restart all service
/etc/init.d/dnsmasq restart
/etc/init.d/firewall restart
/etc/init.d/myshadowsocks start
/etc/init.d/myshadowsocks enable


#install successfully
rm -rf /userdisk/data/shadowsocks_miwifi
rm -f /userdisk/data/shadowsocks_miwifi.tar.gz
echo ""
echo "Shadowsocks安装成功！"
echo ""
exit 0
