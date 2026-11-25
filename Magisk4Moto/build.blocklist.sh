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

SAFE_EXCLUDE_REGEX='^(graph\.facebook\.com|fcm\.googleapis\.com|bytedance\.com)$'

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

# Enforce Unix LF line endings and verify no corrupted URL schemes exist
for f in "$OUT_DIR"/*; do
  tr -d '\r' < "$f" > "$f.tmp" && mv "$f.tmp" "$f"
  if grep -q '://' "$f"; then
    echo "ERROR: Corrupted '://' found in $f! Aborting." >&2
    exit 1
  fi
done

echo "Verified and generated 5 clean files in $OUT_DIR/:"
ls -lh "$OUT_DIR"
