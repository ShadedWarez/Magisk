#!/system/bin/sh
# Run as root (uid 0) via: adb shell -> su

echo "=== 1. Auditing Device Policy & Packages ==="
dumpsys device_policy
pm list users
pm list packages | grep -iE "paks|trustonic|caller|cricket|omadm|ota|mdm|dpc"

echo "=== 2. Disabling PAKS, Trustonic DPC & Carrier Provisioning ==="
pm disable-user --user 0 com.motorola.paks
pm disable-user --user 0 com.trustonic.telecoms.standard.dpc
pm disable-user --user 0 com.motorola.ccc.ota
pm disable-user --user 0 com.motorola.omadm.service
pm disable-user --user 0 com.motorola.carrierconfig

echo "=== 3. Injecting 0.0.0.0 Rules into Magisk Systemless Hosts ==="
HOSTS_FILE="/data/adb/modules/hosts/system/etc/hosts"
if [ -f "$HOSTS_FILE" ]; then
cat << 'EOF' >> "$HOSTS_FILE"

# Motorola PAKS, Trustonic DPC & Carrier Provisioning Endpoints
0.0.0.0 paks.motorola.com
0.0.0.0 paks-prod.motorola.com
0.0.0.0 paks-staging.motorola.com
0.0.0.0 device-provisioning.motorola.com
0.0.0.0 motopaks.motorola.com
0.0.0.0 ota-service.motorola.com
0.0.0.0 ota.motorola.com
0.0.0.0 cota.motorola.com
0.0.0.0 mdm.motorola.com
0.0.0.0 rsdsecure-cloud.motorola.com
0.0.0.0 omadm.cricketwireless.com
0.0.0.0 deviceprovisioning.att.net
0.0.0.0 dm.att.net
0.0.0.0 device.cloud.trustonic.com
0.0.0.0 cloud.trustonic.com
0.0.0.0 trustonic.com
EOF
