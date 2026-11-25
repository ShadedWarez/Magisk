#!/system/bin/sh
# Run as root (uid 0) via: adb shell -> su

echo "=== 1. Auditing Device Policy & Secondary Users ==="
dumpsys device_policy
pm list users
pm list packages | grep -iE "paks|caller|cricket|omadm|ota|mdm|dpc"

echo "=== 2. Disabling PAKS, Carrier Provisioning & OTA Packages ==="
# If Step 1 showed a separate Device Policy protector package (e.g., callercom), add:
# pm disable-user --user 0 <protector.package.name>
pm disable-user --user 0 com.motorola.paks
pm disable-user --user 0 com.motorola.ccc.ota
pm disable-user --user 0 com.motorola.omadm.service
pm disable-user --user 0 com.motorola.carrierconfig

# If Step 1 showed a leftover Work/Managed Profile user ID (e.g., 10), uncomment below:
# pm remove-user 10

echo "=== 3. Injecting 0.0.0.0 Rules into Magisk Systemless Hosts ==="
HOSTS_FILE="/data/adb/modules/hosts/system/etc/hosts"
if [ -f "$HOSTS_FILE" ]; then
cat << 'EOF' >> "$HOSTS_FILE"

# Motorola PAKS, Carrier Provisioning & OTA Endpoints
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
EOF
chmod 644 "$HOSTS_FILE"
echo "Systemless hosts updated."
else
echo "WARNING: $HOSTS_FILE not found. Enable 'Systemless hosts' in Magisk Settings first."
fi

echo "=== 4. Applying Kernel iptables UID Drop for com.motorola.paks ==="
PAKS_UID=$(dumpsys package com.motorola.paks | grep -m1 "userId=" | sed 's/.*userId=//' | awk '{print $1}')
if [ -n "$PAKS_UID" ]; then
  iptables -I OUTPUT -m owner --uid-owner "$PAKS_UID" -j DROP
  ip6tables -I OUTPUT -m owner --uid-owner "$PAKS_UID" -j DROP
  echo "Dropped all IPv4/IPv6 outbound packets for UID $PAKS_UID (com.motorola.paks)."
fi

echo "=== 5. Raw Verification ==="
pm list packages -d | grep -iE "paks|caller|cricket|omadm|ota|mdm|dpc"
grep -A 2 -E "paks|caller|omadm" /data/system/users/0/package-restrictions.xml
ps -ef | grep -iE "paks|caller|omadm"
