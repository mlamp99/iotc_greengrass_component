#!/bin/bash

# Variables (updated with correct URLs)
GG_LITE_URL="https://github.com/stm32-hotspot/STM32MP1_AWS-IoT-Greengrass-nucleus-lite/raw/main/gg_lite/gglite.gz"
AWS_ROOT_CA="https://www.amazontrust.com/repository/AmazonRootCA1.pem"
AWSCRT_WHL="https://github.com/mlamp99/iotc_greengrass_component/raw/main/stmp135/awscrt-0.24.1-cp311-abi3-manylinux_2_28_armv7l.manylinux_2_31_armv7l.whl"
IOTSDK_WHL="https://github.com/mlamp99/iotc_greengrass_component/raw/main/stmp135/awsiotsdk-1.22.2-py3-none-any.whl"

INSTALL_DIR="/home/root"
TMP_DIR="/usr/local/tmp"

# Step 1: Update and install essential dependencies
apt-get update && apt-get install -y curl wget unzip libzip uriparser python3-pip

# Step 2: Download & Extract Greengrass Lite
wget "$GG_LITE_URL" -P "$INSTALL_DIR"
tar -xzf "$INSTALL_DIR/gglite.gz" -C "$INSTALL_DIR"
chown -R root:root "$INSTALL_DIR/aws-greengrass-lite"

# Step 3: Prepare Greengrass directories
mkdir -p /var/lib/greengrass /etc/greengrass

# User-uploaded certificates (ensure user has placed them in INSTALL_DIR beforehand)
cp "$INSTALL_DIR"/pk_*.pem /var/lib/greengrass/
cp "$INSTALL_DIR"/cert_*.crt /var/lib/greengrass/
cp "$INSTALL_DIR"/config.yaml /etc/greengrass/

# Step 4: Download Amazon Root CA
wget "$AWS_ROOT_CA" -O /var/lib/greengrass/AmazonRootCA1.pem

# Correct permissions
chmod 600 /var/lib/greengrass/*.pem
chmod 644 /var/lib/greengrass/*.crt /var/lib/greengrass/*.pem

# Step 5: Set up systemd services
cp "$INSTALL_DIR/aws-greengrass-lite/lib/systemd/system/"* /lib/systemd/system/
systemctl daemon-reload

# Step 6: Install Python wheels for AWS CRT and IoT SDK
mkdir -p "$TMP_DIR"
TMPDIR="$TMP_DIR" pip3 install --no-cache-dir "$AWSCRT_WHL" "$IOTSDK_WHL"

# Step 7: Launch Greengrass Lite via systemd (no run_nucleus required)
systemctl enable greengrass-lite.target
systemctl start greengrass-lite.target

# Confirm status
echo "Greengrass Lite service status:"
systemctl status greengrass-lite.target
systemctl status ggl.core.iotcored.service
