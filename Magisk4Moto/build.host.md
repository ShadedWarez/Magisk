
Final Deployment Reminders

• Line Endings: Confirm all four files use Unix LF (\n) line endings before bundling into APKs or pushing to /data/adb/.
• Magisk Permissions: Set chmod 644 and chown 0:0 on Source 7 when copying it into your Magisk systemless hosts path.
Everything in your 4-file suite is ready for production. If you ever need to:
• Generate a login-safe version of Source 7 (the Magisk hosts file)
• Write a single bash build script to regenerate all four files automatically when you add a new domain
Just let me know!

Both sound good

Here is a self-contained bash build script (build_blocklists.sh) that compiles all five files (including the login-safe Magisk hosts_safe file) from a single master source, enforces Unix LF (\n) line endings, and avoids duplicate entries.

1. Save as build_blocklists.sh


#!/usr/bin/env bash
set -euo pipefail

OUT_DIR="${1:-./dist}"
mkdir -p "$OUT_DIR"

# --- 1. OEM, Carrier & Trustonic Domains ---
OEM_DOMAINS=(
  "://motorola.com"
  "://motorola.com"
  "://motorola.com"
  "://motorola.com"
  "moto://motorola.com"
  "://motorola.com"
  "://motorola.com"
  "c://motorola.com"
  "://motorola.com"
  "://motorola.com"
  "://cricketwireless.com"
  "deviceprovisioning.att.net"
  "dm.att.net"
  "://trustonic.com"
  "://trustonic.com"
  "trustonic.com"
)

# --- 2. Strict Wildcard Tracker/Ad Roots ---
WILDCARD_STRICT=(
  "google-analytics.com"
  "googletagmanager.com"
  "googletagservices.com"
  "googlesyndication.com"
  "doubleclick.net"
  "app-measurement.com"
  "crashlytics.com"
  "sentry.io"
  "adfast.io"
  "adfast.net"
  "adfast.com"
  "fastad.io"
  "appmetrica.yandex.net"
  "yandexadexchange.net"
  "adfox.ru"
  "appsflyer.com"
  "adjust.com"
  "adjust.net.in"
  "adjust.world"
  "mixpanel.com"
  "amplitude.com"
  "braze.com"
  "onesignal.com"
  "split.io"
  "://unity3d.com"
  "applovin.com"
  "ironsrc.com"
  "vungle.com"
  "mintegral.com"
  "pangle.io"
  "bytedance.com"
  "inmobi.com"
  "chartboost.com"
  "tapjoy.com"
  "flurry.com"
  "branch.io"
  "bugsnag.com"
  "datadoghq.com"
  "newrelic.com"
  "segment.io"
  "segment.com"
)

# --- 3. Strict Exact / Subdomain Entries ---
EXACT_STRICT=(
  "://googleapis.com"
  "://gstatic.com"
  "://googleapis.com"
  "://gstatic.com"
  "://googleapis.com"
  "://googleapis.com"
  "://googleapis.com"
  "://googleapis.com"
  "://googleapis.com"
  "://googleapis.com"
  "startup.mobile.yandex.net"
  "mc.yandex.ru"
  "an.yandex.ru"
  "bs.yandex.ru"
  "clck.yandex.ru"
  "://facebook.com"
  "://facebook.com"
  "://facebook.com"
  "connect.facebook.net"
  "://facebook.com"
  "://facebook.com"
  "://facebook.com"
  "://facebook.com"
)

# --- 4. Extra Subdomains Required for Non-Wildcard Magisk Hosts ---
HOSTS_EXTRA_SUBDOMAINS=(
  "://google-analytics.com"
  "://google-analytics.com"
  "://googletagmanager.com"
  "://googlesyndication.com"
  "://googlesyndication.com"
  "googleads.g.doubleclick.net"
  "stats.g.doubleclick.net"
  "ad.doubleclick.net"
  "cm.g.doubleclick.net"
  "pubads.g.doubleclick.net"
  "securepubads.g.doubleclick.net"
  "://app-measurement.com"
  "://crashlytics.com"
  "://crashlytics.com"
  "://crashlytics.com"
  "://crashlytics.com"
  "ingest.sentry.io"
  "ingest.us.sentry.io"
  "ingest.de.sentry.io"
  "o0.ingest.sentry.io"
  "://getsentry.com"
  "api.adfast.io"
  "sdk.adfast.io"
  "track.adfast.io"
  "ads.adfast.net"
  "://adfast.com"
  "api.fastad.io"
  "report.appmetrica.yandex.net"
  "tracking.appmetrica.yandex.net"
  "tracking.reserve.appmetrica.yandex.net"
  "://facebook.com"
  "://appsflyer.com"
  "://appsflyer.com"
  "://appsflyer.com"
  "://appsflyer.com"
  "://appsflyer.com"
  "://adjust.com"
  "://mixpanel.com"
  "://mixpanel.com"
  "://amplitude.com"
  "://amplitude.com"
  "://braze.com"
  "://braze.com"
  "://onesignal.com"
  "://onesignal.com"
  "events.split.io"
  "sdk.split.io"
  "api.branch.io"
  "api2.branch.io"
  "://bugsnag.com"
  "://bugsnag.com"
  "browser-intake-datadoghq.com"
  "://browser-intake-datadoghq.com"
  "://newrelic.com"
  "://newrelic.com"
  "api.segment.io"
  "://segment.com"
  "config.://unity3d.com"
  "adserver.://unity3d.com"
  "://applovin.com"
  "://applovin.com"
  "://applovin.com"
  "://supersonicads.com"
  "://supersonicads.com"
  "://vungle.com"
  "ads.://vungle.com"
  "://rayjump.com"
  "://pangolin-sdk-toutiao.com"
  "://inmobi.com"
  "://inmobi.com"
  "://chartboost.com"
  "://tapjoy.com"
  "://tapjoyads.com"
  "://flurry.com"
)

# Login-safe exclusions (preserves Facebook OAuth, FCM Push, ByteDance OAuth)
SAFE_EXCLUDE_REGEX='^(graph\.facebook\.com|fcm\.googleapis\.com|bytedance\.com)$'

# Helper: print array one per line
print_list() {
  printf '%s\n' "$@"
}

# 1. APK Strict (domains_strict.txt)
{
  print_list "${WILDCARD_STRICT[@]}"
  print_list "${EXACT_STRICT[@]}"
} | awk '!seen[$0]++' > "$OUT_DIR/domains_strict.txt"

# 2. APK Login-Safe (domains_safe.txt)
grep -Ev "$SAFE_EXCLUDE_REGEX" "$OUT_DIR/domains_strict.txt" > "$OUT_DIR/domains_safe.txt"

# 3. Master All Plain Domains (domains_all.txt)
{
  print_list "${OEM_DOMAINS[@]}"
  cat "$OUT_DIR/domains_strict.txt"
} | awk '!seen[$0]++' > "$OUT_DIR/domains_all.txt"

# 4. Magisk Strict Hosts (hosts_strict)
{
  printf '127.0.0.1 localhost\n::1 ip6-localhost\n\n'
  {
    cat "$OUT_DIR/domains_all.txt"
    print_list "${HOSTS_EXTRA_SUBDOMAINS[@]}"
  } | awk '!seen[$0]++ {print "0.0.0.0 " $0}'
} > "$OUT_DIR/hosts_strict"

# 5. Magisk Login-Safe Hosts (hosts_safe)
{
  printf '127.0.0.1 localhost\n::1 ip6-localhost\n\n'
  {
    cat "$OUT_DIR/domains_all.txt"
    print_list "${HOSTS_EXTRA_SUBDOMAINS[@]}"
  } | grep -Ev "$SAFE_EXCLUDE_REGEX" | awk '!seen[$0]++ {print "0.0.0.0 " $0}'
} > "$OUT_DIR/hosts_safe"

# Enforce Unix LF line endings across all generated files
for f in "$OUT_DIR"/*; do
  tr -d '\r' < "$f" > "$f.tmp" && mv "$f.tmp" "$f"
done

echo "Generated 5 files in $OUT_DIR/:"
ls -lh "$OUT_DIR"


2. Usage

1. Make the script executable and run it:bash
chmod +x build_blocklists.sh
./build_blocklists.sh ./dist
Use code with caution.
2. Outputs created in ./dist/:
	• domains_strict.txt — Primary APK wildcard list
	• domains_safe.txt — Backup APK wildcard list (login/push safe)
	• domains_all.txt — Master plain list including OEM/carrier domains
	• hosts_strict — Full 0.0.0.0 Magisk systemless hosts file
	• hosts_safe — Login-safe 0.0.0.0 Magisk systemless hosts file


Deploying to Magisk (when ready):

su -c 'cp /sdcard/Download/hosts_strict /data/adb/modules/hosts/system/etc/hosts && chmod 644 /data/adb/modules/hosts/system/etc/hosts && chown 0:0 /data/adb/modules/hosts/system/etc/hosts'


#You now have a single-command pipeline for all five blocklist variants. If you ever want to add:
#• CLI flags to append extra domains on the fly (e.g., ./build_blocklists.sh --add o12345.ingest.sentry.io)
#• Automatic adb push integration straight to your device or Magisk module folder
