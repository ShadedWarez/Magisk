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
0.0.0.0 device.cloud.trustonic,com
0.0.0.0 cloud.trustonic,com
0.0.0.0 trustonic,com
EOF
chmod 644 "$HOSTS_FILE"
echo "Systemless hosts updated."
else
echo "WARNING: $HOSTS_FILE not found. Enable 'Systemless hosts' in Magisk Settings first."
fi

echo "=== 4. Applying Kernel iptables UID Drop ==="
for PKG in com.motorola.paks com.trustonic.telecoms.standard.dpc; do
  APP_UID=$(dumpsys package "$PKG" | grep -m1 "userId=" | sed 's/.*userId=//' | awk '{print $1}')
  if [ -n "$APP_UID" ]; then
    iptables -I OUTPUT -m owner --uid-owner "$APP_UID" -j DROP
    ip6tables -I OUTPUT -m owner --uid-owner "$APP_UID" -j DROP
  fi
done

echo "=== 5. Verification ==="
pm list packages -d | grep -iE "paks|trustonic|caller|cricket|omadm|ota|mdm|dpc"
