#!/bin/bash

INSTALL_DIR="/home/root"
TMP_DIR="/usr/local/tmp"

AWS_ROOT_CA="https://www.amazontrust.com/repository/AmazonRootCA1.pem"
AWSCRT_WHL="https://github.com/mlamp99/iotc_greengrass_component/raw/main/stmp135/awscrt-0.24.1-cp311-abi3-manylinux_2_28_armv7l.manylinux_2_31_armv7l.whl"
IOTSDK_WHL="https://github.com/mlamp99/iotc_greengrass_component/raw/main/stmp135/awsiotsdk-1.22.2-py3-none-any.whl"

# Step 1: Permanently set correct date explicitly
timedatectl set-ntp false
date -s "2025-04-15 23:55:00"
hwclock --systohc

# Step 2: Install explicitly compatible dependencies
apt-get update && apt-get install -y curl wget unzip libzip uriparser python3-pip git cmake make

# Step 3: Clone Greengrass explicitly (SSL should now correctly work)
rm -rf "$INSTALL_DIR/aws-greengrass-lite"
git clone https://github.com/aws-greengrass/aws-greengrass-lite.git "$INSTALL_DIR/aws-greengrass-lite"
cd "$INSTALL_DIR/aws-greengrass-lite"
git fetch origin pull/830/head:pull-830
git checkout pull-830
mkdir -p build && cd build
cmake .. -DCMAKE_BUILD_TYPE=Release
make -j$(nproc)
make install

# Step 4: Prepare Greengrass directories explicitly
mkdir -p /var/lib/greengrass /etc/greengrass
cp "$INSTALL_DIR"/pk_*.pem /var/lib/greengrass/
cp "$INSTALL_DIR"/cert_*.crt /var/lib/greengrass/
cp "$INSTALL_DIR"/config.yaml /etc/greengrass/

# Step 5: Download Amazon Root CA explicitly (standard SSL verification)
wget "$AWS_ROOT_CA" -O /var/lib/greengrass/AmazonRootCA1.pem

# Explicit permission correction
chmod 600 /var/lib/greengrass/*.pem
chmod 644 /var/lib/greengrass/*.crt /var/lib/greengrass/*.pem

# Step 6: Setup systemd services explicitly
cp "$INSTALL_DIR/aws-greengrass-lite/lib/systemd/system/"* /lib/systemd/system/
systemctl daemon-reload

# Step 7: Install Python wheels explicitly
mkdir -p "$TMP_DIR"
TMPDIR="$TMP_DIR" pip3 install --no-cache-dir "$AWSCRT_WHL" "$IOTSDK_WHL"

# Step 8: Launch Greengrass Lite explicitly via systemd
systemctl enable greengrass-lite.target
systemctl start greengrass-lite.target

# Explicit Verification
echo "Greengrass Lite service status:"
systemctl status greengrass-lite.target
systemctl status ggl.core.iotcored.service
