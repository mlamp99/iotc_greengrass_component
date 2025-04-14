# STM32MP135 AWS IoT Greengrass Lite Quick Setup

This repository contains a ready-to-use script for easily setting up **AWS IoT Greengrass Lite** on your STM32MP135 device, along with the required pre-built Python wheels (`awscrt` and `awsiotsdk`).

## 📋 Prerequisites

- STM32MP135 device running OpenSTLinux.
- Internet access from your device.
- AWS IoT credentials: device certificate, private key, and AWS configuration (`config.yaml`) provided by your AWS or IoTConnect account.

## 🚀 Quick Installation

### Step 1: Prepare Your Device

Ensure your device is updated and has basic networking:

```bash
apt update && apt upgrade -y
```

### Step 2: Copy Certificates and Config

Transfer the following files (obtained from AWS or IoTConnect) to the `/home/root` directory of your STM32MP135 device:

- Device certificate (`cert_*.crt`)
- Private key (`pk_*.pem`)
- `config.yaml`

Example using SCP:

```bash
scp cert_*.crt pk_*.pem config.yaml root@<device_ip>:/home/root/
```

Replace `<device_ip>` with your STM32MP135 IP address.

### Step 3: Run the Installation Script

Log in to your device via SSH or serial terminal:

```bash
ssh root@<device_ip>
```

Download and run the provided setup script directly:

```bash
wget https://raw.githubusercontent.com/mlamp99/iotc_greengrass_component/main/stmp135/gg-lite-mp1.sh
chmod +x gg-lite-mp1.sh
./gg-lite-mp1.sh
```

### Step 4: Verify Installation

After running the script, verify Greengrass Lite status:

```bash
systemctl status greengrass-lite.target
greengrass-cli component list
```

You should see Greengrass Lite services active and running without errors.

## 🔧 Troubleshooting

If you encounter issues:

- Check service logs:
  ```bash
  journalctl -u greengrass-lite.target -f
  ```

- Ensure the `ggl.core.ggconfigd.service` and `ggl.core.iotcored.service` are running:
  ```bash
  systemctl status ggl.core.ggconfigd.service
  systemctl status ggl.core.iotcored.service
  ```

## 📖 References

- [AWS IoT Greengrass Documentation](https://docs.aws.amazon.com/greengrass/v2/developerguide/)
- [STM32MP1 AWS IoT Greengrass Lite GitHub Repository](https://github.com/stm32-hotspot/STM32MP1_AWS-IoT-Greengrass-nucleus-lite)
