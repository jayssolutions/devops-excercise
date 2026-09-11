#!/bin/bash
set -euo pipefail

PROM_VERSION="2.55.1"

useradd --no-create-home --shell /sbin/nologin prometheus || true
mkdir -p /etc/prometheus /var/lib/prometheus

cd /tmp
curl -sL "https://github.com/prometheus/prometheus/releases/download/v$${PROM_VERSION}/prometheus-$${PROM_VERSION}.linux-amd64.tar.gz" -o prometheus.tar.gz
tar -xzf prometheus.tar.gz
cp "prometheus-$${PROM_VERSION}.linux-amd64/prometheus" /usr/local/bin/
cp "prometheus-$${PROM_VERSION}.linux-amd64/promtool" /usr/local/bin/

cat >/etc/prometheus/prometheus.yml <<'PROM_EOF'
${prometheus_yml}
PROM_EOF

cat >/etc/prometheus/alerts.yml <<'ALERTS_EOF'
${alerts_yml}
ALERTS_EOF

chown -R prometheus:prometheus /etc/prometheus /var/lib/prometheus

cat >/etc/systemd/system/prometheus.service <<'SERVICE_EOF'
[Unit]
Description=Prometheus
After=network.target

[Service]
User=prometheus
ExecStart=/usr/local/bin/prometheus --config.file=/etc/prometheus/prometheus.yml --storage.tsdb.path=/var/lib/prometheus --web.listen-address=:9090
Restart=on-failure

[Install]
WantedBy=multi-user.target
SERVICE_EOF

systemctl daemon-reload
systemctl enable --now prometheus
