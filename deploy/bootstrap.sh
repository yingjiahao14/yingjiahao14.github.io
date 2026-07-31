#!/usr/bin/env bash
# 服务器初始化脚本：装 Docker、建目录、生成密钥、拉起 Caddy + Matomo。
# 幂等设计，重复执行安全。用法（在服务器上）：
#   bash /opt/webstack/bootstrap.sh
set -euo pipefail

STACK_DIR=/opt/webstack
SITE_DIR=/var/www/site

echo "==> [1/6] 安装 Docker（如已安装则跳过）"
if ! command -v docker >/dev/null 2>&1; then
  curl -fsSL https://get.docker.com | sudo sh
fi
sudo usermod -aG docker "$USER" || true

echo "==> [2/6] 配置 1GB swap（2G 内存的安全垫，如已有则跳过）"
if ! sudo swapon --show | grep -q .; then
  sudo fallocate -l 1G /swapfile
  sudo chmod 600 /swapfile
  sudo mkswap /swapfile
  sudo swapon /swapfile
  echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab >/dev/null
fi

echo "==> [3/6] 创建站点目录 $SITE_DIR"
sudo mkdir -p "$SITE_DIR"
sudo chown "$USER":"$USER" "$SITE_DIR"
if [ ! -f "$SITE_DIR/index.html" ]; then
  echo '<!doctype html><meta charset="utf-8"><title>Coming soon</title><p>Site deploying...</p>' > "$SITE_DIR/index.html"
fi

echo "==> [4/6] 生成 .env 密钥（如已存在则不覆盖，避免丢失数据库密码）"
cd "$STACK_DIR"
if [ ! -f .env ]; then
  {
    echo "MATOMO_DB_PASSWORD=$(openssl rand -hex 16)"
    echo "MATOMO_DB_ROOT_PASSWORD=$(openssl rand -hex 16)"
  } > .env
  chmod 600 .env
fi

echo "==> [5/6] 启动服务栈"
sudo docker compose up -d

echo "==> [6/6] 等待就绪并自检"
sleep 8
sudo docker compose ps
echo
echo "静态站:  https://jhying.org/"
echo "Matomo:  https://analytics.jhying.org  (经 Caddy 反代)"
echo
echo "首次部署提醒: 打开 Matomo 走安装向导时"
echo "  1) 不要勾选「隐藏访客 IP 最后一段」(否则拿不到完整 IP)"
echo "  2) 装完在 config.ini.php 的 [General] 段加 proxy_client_headers[]=\"HTTP_X_FORWARDED_FOR\""
echo "     否则所有访客 IP 会显示成 172.x 内网地址"
