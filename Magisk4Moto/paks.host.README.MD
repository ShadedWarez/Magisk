Yes—with Magisk root (uid 0), you can inject a custom /system/etc/hosts file systemlessly using Magisk's built-in Systemless Hosts module to route all Motorola PAKS, OTA, and Cricket/AT&T telemetry/provisioning domains straight to 0.0.0.0 at the kernel DNS layer.
Even better: because Magisk mounts its own overlay over /system/etc/hosts, it works cleanly without modifying the read-only /system partition, and it applies to every app and background daemon on the phone (even system processes that ignore VPNs like NetGuard).

1. Enable Magisk Systemless Hosts (10 Seconds)

1. Open the Magisk app on your rooted Moto G Play.
2. Tap the Settings gear icon (top-right).
3. Scroll down to the Magisk section and toggle Systemless hosts ON.
(This creates a writable hosts file at /data/adb/modules/hosts/system/etc/hosts that Magisk automatically bind-mounts over /system/etc/hosts at every boot.)

2. Inject the 0.0.0.0 Block Rules via Root Shell (su)

Open adb shell -> su on your laptop and append the Motorola PAKS, OTA, and Cricket/AT&T provisioning endpoints directly into Magisk's systemless hosts file:



cat << 'EOF' >> /data/adb/modules/hosts/system/etc/hosts

# Block Motorola PAKS, Carrier Provisioning & OTA Check-in Servers
0.0.0.0 ://motorola.com
0.0.0.0 ://motorola.com
0.0.0.0 ://motorola.com
0.0.0.0 ://motorola.com
0.0.0.0 moto://motorola.com
0.0.0.0 ://motorola.com
0.0.0.0 ://motorola.com
0.0.0.0 c://motorola.com
0.0.0.0 ://motorola.com
0.0.0.0 ://motorola.com
0.0.0.0 ://cricketwireless.com
0.0.0.0 deviceprovisioning.att.net
0.0.0.0 dm.att.net
EOF

# Set proper read permissions so all non-root system processes can read the hosts file
chmod 644 /data/adb/modules/hosts/system/etc/hosts




3. Optional: Hard-Block by UID in iptables (Catches Hardcoded IP Addresses)

In case com.motorola.paks or Cricket's provisioning daemon ever tries to bypass DNS by connecting directly to a hardcoded IP address instead of a domain name, you can also drop all outbound packets from that app's Linux UID at the kernel firewall (iptables) level:


# 1. Find the exact Linux UID of com.motorola.paks (e.g., 10142)
dumpsys package com.motorola.paks | grep userId=

# 2. Drop all IPv4 and IPv6 traffic for that UID (replace 10142 with the actual userId)
iptables -I OUTPUT -m owner --uid-owner 10142 -j DROP
ip6tables -I OUTPUT -m owner --uid-owner 10142 -j DROP



Combining three layers—(1) pm disable-user --user 0, (2) systemless /etc/hosts 0.0.0.0 null-routing, and (3) iptables UID packet drop—ensures that neither com.motorola.paks nor Cricket's provisioning client can ever phone home or re-trigger a policy lock even if you connect to Wi-Fi.
Would you like me to combine the hosts injection and iptables UID block into your single master post-root script so you only have one file to run?
