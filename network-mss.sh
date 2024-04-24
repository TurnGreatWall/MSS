#!/bin/bash

# 创建 network-mss.sh 文件
cat << 'EOF' > "/etc/network-mss.sh"
#!/bin/bash

common() {
    iptables -t mangle -A FORWARD -p tcp -m tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu
    iptables -t mangle -A OUTPUT -p tcp -m tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu
}

common &

sleep infinity
EOF

# 赋予可执行权限
chmod +x "/etc/network-mss.sh"

echo "network-mss.sh 文件已生成并赋予可执行权限，路径为：/etc/network-mss.sh"

# 创建 network-mss.service 文件
cat << EOF > "/etc/systemd/system/network-mss.service"
[Unit]
Description=network mss service
After=network.target network-online.target nss-lookup.target
Wants=network-online.target

[Service]
ExecStart=/etc/network-mss.sh
Restart=on-failure

[Install]
WantedBy=default.target
EOF

echo "network-mss.service 文件已生成，路径为：/etc/systemd/system/network-mss.service"

# 启用服务
systemctl enable network-mss.service

# 启动服务
systemctl start network-mss.service

echo "服务 network-mss.service 已启用并启动"
