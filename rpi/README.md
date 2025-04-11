# Greengrass Lite for Raspberry Pi (Precompiled)

This repository includes a precompiled version of **AWS IoT Greengrass Lite** for ARMv7-based Raspberry Pi boards.

The Greengrass Lite runtime is compiled and packaged from the official [aws-greengrass-lite](https://github.com/aws-greengrass/aws-greengrass-lite) repository to save time on device setup — no need to build from source on every device.

---

## 📆 Download

You can download and extract the latest precompiled build using:

```bash
wget https://github.com/mlamp99/iotc_greengrass_component/raw/main/rpi/greengrass-lite-armv7.tar.gz
tar -xzvf greengrass-lite-armv7.tar.gz
cd greengrass-lite-export
./misc/run_nucleus
```

> **Note:** This launches Greengrass Lite directly. You can optionally install it as a systemd service (see below).

---

## 📁 Contents of Archive

- `bin/`: Compiled binaries for Greengrass Lite
- `misc/`: Scripts including `run_nucleus`
- `LICENSE` and `README.md`: From upstream
- Optional: systemd unit file (`greengrass-lite.target`) for enabling at boot

---

## ⚙️ Systemd Installation (Optional)

To run Greengrass Lite automatically at boot:

```bash
sudo cp greengrass-lite-export/greengrass-lite.target /etc/systemd/system/
sudo systemctl daemon-reexec
sudo systemctl enable greengrass-lite.target
sudo systemctl start greengrass-lite.target
```

---

## 📋 Build Environment

This package was compiled on:

- **Device:** Raspberry Pi 4 Model B (ARMv7 / 32-bit mode)
- **OS:** Raspberry Pi OS (32-bit)
- **Image:** `2024-03-15-raspios-bookworm-armhf-lite.img`
- **Kernel:** `6.1.x` (Debian Bookworm-based)
- **GCC Version:** 12.x (from Raspberry Pi OS toolchain)
- **Build Type:** `MinSizeRel` via CMake

---

## ✅ Requirements on Target Device

- Raspberry Pi running Raspberry Pi OS (32-bit recommended)
- ARMv7-compatible CPU (Pi 2, 3, 4)
- Internet access for MQTT/device telemetry (optional but typical)
- If you use systemd: `systemctl` must be available

---

## 📌 SHA-256 Checksum

For verification:

```bash
sha256sum greengrass-lite-armv7.tar.gz
```

Output:
```
REPLACE_WITH_YOUR_CHECKSUM
```

---

## 📌 Upstream Repository

Built from:
👉 [aws-greengrass/aws-greengrass-lite](https://github.com/aws-greengrass/aws-greengrass-lite)

---

## 📬 Questions or Issues?

Submit an issue in this repository or reach out to the maintainer.

