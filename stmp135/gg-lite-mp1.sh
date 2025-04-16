#!/bin/bash

INSTALL_DIR="/home/root"
TMP_DIR="/usr/local/tmp"

AWS_ROOT_CA="https://www.amazontrust.com/repository/AmazonRootCA1.pem"
AWSCRT_WHL="https://github.com/mlamp99/iotc_greengrass_component/raw/main/stmp135/awscrt-0.24.1-cp311-abi3-manylinux_2_28_armv7l.manylinux_2_31_armv7l.whl"
IOTSDK_WHL="https://github.com/mlamp99/iotc_greengrass_component/raw/main/stmp135/awsiotsdk-1.22.2-py3-none-any.whl"

# Step 1: Update and install compatible packages
apt-get update && apt-get install -y curl wget unzip libzip uriparser python3-pip cmake make git

# Step 2: Clone and build patched Greengrass Lite explicitly
rm -rf "$INSTALL_DIR/aws-greengrass-lite"
git clone https://github.com/aws-greengrass/aws-greengrass-lite.git "$INSTALL_DIR/aws-greengrass-lite"
cd "$INSTALL_DIR/aws-greengrass-lite"
git fetch origin pull/830/head:pull-830
git checkout pull-830
mkdir -p build && cd build
cmake .. -DCMAKE_BUILD_TYPE=Release
make -j$(nproc)
make install

# Step 3: Prepare Greengrass directories
mkdir -p /var/lib/greengrass /etc/greengrass
cp "$INSTALL_DIR"/pk_*.pem /var/lib/greengrass/
cp "$INSTALL_DIR"/cert_*.crt /var/lib/greengrass/
cp "$INSTALL_DIR"/config.yaml /etc/greengrass/

# Step 4: Explicitly download Amazon Root CA (no SSL check)
wget --no-check-certificate "$AWS_ROOT_CA" -O /var/lib/greengrass/AmazonRootCA1.pem

# Permissions explicitly set
chmod 600 /var/lib/greengrass/*.pem
chmod 644 /var/lib/greengrass/*.crt /var/lib/greengrass/*.pem

# Step 5: Setup systemd services
cp "$INSTALL_DIR/aws-greengrass-lite/lib/systemd/system/"* /lib/systemd/system/
systemctl daemon-reload

# Step 6: Install Python wheels explicitly
mkdir -p "$TMP_DIR"
TMPDIR="$TMP_DIR" pip3 install --no-cache-dir "$AWSCRT_WHL" "$IOTSDK_WHL"

# Step 7: Launch Greengrass Lite via systemd
systemctl enable greengrass-lite.target
systemctl start greengrass-lite.target

# Verify explicitly
echo "Greengrass Lite service status:"
systemctl status greengrass-lite.target
systemctl status ggl.core.iotcored.service
