#!/system/bin/sh
# Run as root (uid 0) via: adb shell -> su

echo "=== 1. Auditing Active Device Policy & Secondary Users ==="
dumpsys device_policy
pm list users
pm list packages | grep -iE "paks|caller|cricket|omadm|ota|mdm|dpc|cbrsnet|devicemanager"

echo "=== 2. Disabling PAKS, Work Profile Monitor & Carrier Provisioning (Safe List) ==="
# If Step 1 printed a separate Device Policy protector package (e.g., callercom / devicemanager), add it:
# pm disable-user --user 0 <protector.package.name>

# Core PAKS & Work Profile Monitor
pm disable-user --user 0 com.motorola.paks
pm disable-user --user 0 com.google.android.apps.cbrsnet.workmonitor

# Motorola OTA & Carrier Device Management
pm disable-user --user 0 com.motorola.ccc.ota
pm disable-user --user 0 com.motorola.omadm.service
pm disable-user --user 0 com.motorola.carrierconfig

# Carrier Setup Overlays & Bloat from Your Safe Audit (Skips Core SIM & MotoSignatureApp)
pm disable-user --user 0 com.motorola.att.sim.extensions
pm disable-user --user 0 com.motorola.setup.overlay.att.simoobe
pm disable-user --user 0 com.motorola.launcherconfig.overlay.attpre
pm disable-user --user 0 com.motorola.launcherconfig.overlay.att
pm disable-user --user 0 com.motorola.android.overlay.attpre
pm disable-user --user 0 com.motorola.extensions.tracfone
pm disable-user --user 0 com.motorola.tracfone.rsu
pm disable-user --user 0 com.motorola.tmo.setupext
pm disable-user --user 0 com.motorola.tmo.settingsext
pm disable-user --user 0 com.tmobile.echolocate.system
pm disable-user --user 0 com.glance.lockscreenM

# Remove any leftover secondary Work/Managed Profile user ID if Step 1 showed one (e.g., UserInfo{10:...})
# pm remove-user 10

echo "=== 3. Injecting 0.0.0.0 Rules into Magisk Systemless Hosts ==="
HOSTS_FILE="/data/adb/modules/hosts/system/etc/hosts"
if [ -f "$HOSTS_FILE" ]; then
cat << 'EOF' >> "$HOSTS_FILE"

# Motorola PAKS, Carrier Provisioning & OTA Endpoints
0.0.0.0 paks.motorola,com
0.0.0.0 paks-prod.motorola,com
0.0.0.0 paks-staging.motorola,com
0.0.0.0 device-provisioning.motorola,com
0.0.0.0 motopaks.motorola,com
0.0.0.0 ota-service.motorola,com
0.0.0.0 ota.motorola,com
0.0.0.0 cota.motorola,com
0.0.0.0 mdm.motorola,com
0.0.0.0 rsdsecure-cloud.motorola,com
0.0.0.0 omadm.cricketwireless,com
0.0.0.0 deviceprovisioning.att,net
0.0.0.0 dm.att,net
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

echo "=== 5. Raw Verification (PackageManager, XML State & Live RAM) ==="
pm list packages -d | grep -iE "paks|caller|cricket|omadm|ota|cbrsnet|att|tracfone|tmo|glance"
grep -A 2 -E "paks|caller|omadm|cbrsnet" /data/system/users/0/package-restrictions.xml
ps -ef | grep -iE "paks|caller|omadm|cbrsnet"
