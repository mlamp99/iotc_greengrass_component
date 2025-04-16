#!/bin/bash

INSTALL_DIR="/home/root"
TMP_DIR="/usr/local/tmp"

AWS_ROOT_CA="https://www.amazontrust.com/repository/AmazonRootCA1.pem"
AWSCRT_WHL="https://github.com/mlamp99/iotc_greengrass_component/raw/main/stmp135/awscrt-0.24.1-cp311-abi3-manylinux_2_28_armv7l.manylinux_2_31_armv7l.whl"
IOTSDK_WHL="https://github.com/mlamp99/iotc_greengrass_component/raw/main/stmp135/awsiotsdk-1.22.2-py3-none-any.whl"

# Step 1: Fix Date Permanently
timedatectl set-ntp false
date -s "$(date -u '+%Y-%m-%d %H:%M:%S')"
hwclock --systohc

# Step 2: Update and install only compatible packages explicitly
apt-get update && apt-get install -y curl wget unzip libzip uriparser python3-pip git cmake make

# Step 3: Clone and build patched Greengrass Lite (no SSL verify explicitly)
rm -rf "$INSTALL_DIR/aws-greengrass-lite"
git -c http.sslVerify=false clone https://github.com/aws-greengrass/aws-greengrass-lite.git "$INSTALL_DIR/aws-greengrass-lite"
cd "$INSTALL_DIR/aws-greengrass-lite"
git fetch origin pull/830/head:pull-830
git checkout pull-830
mkdir -p build && cd build
cmake .. -DCMAKE_BUILD_TYPE=Release
make -j$(nproc)
make install

# Step 4: Prepare Greengrass directories
mkdir -p /var/lib/greengrass /etc/greengrass
cp "$INSTALL_DIR"/pk_*.pem /var/lib/greengrass/
cp "$INSTALL_DIR"/cert_*.crt /var/lib/greengrass/
cp "$INSTALL_DIR"/config.yaml /etc/greengrass/

# Step 5: Explicitly download Amazon Root CA (temporarily bypass SSL)
wget --no-check-certificate "$AWS_ROOT_CA" -O /var/lib/greengrass/AmazonRootCA1.pem

# Correct permissions explicitly
chmod 600 /var/lib/greengrass/*.pem
chmod 644 /var/lib/greengrass/*.crt /var/lib/greengrass/*.pem

# Step 6: Setup systemd services explicitly
cp "$INSTALL_DIR/aws-greengrass-lite/lib/systemd/system/"* /lib/systemd/system/
systemctl daemon-reload

# Step 7: Install Python wheels explicitly (ignore SSL for pip if needed)
mkdir -p "$TMP_DIR"
TMPDIR="$TMP_DIR" pip3 install --no-cache-dir "$AWSCRT_WHL" "$IOTSDK_WHL"

# Step 8: Launch Greengrass Lite via systemd explicitly
systemctl enable greengrass-lite.target
systemctl start greengrass-lite.target

# Verify explicitly
echo "Greengrass Lite service status:"
systemctl status greengrass-lite.target
systemctl status ggl.core.iotcored.service
