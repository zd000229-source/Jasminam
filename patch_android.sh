#!/bin/bash
set -e
python3 - <<'PY'
from pathlib import Path

# Android permissions + app label
manifest = Path("android/app/src/main/AndroidManifest.xml")
s = manifest.read_text()
permissions = """    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.RECORD_AUDIO"/>
    <uses-permission android:name="android.permission.USE_BIOMETRIC"/>
"""
if "android.permission.INTERNET" not in s:
    s = s.replace("<application", permissions + "    <application", 1)
s = s.replace('android:label="jasmina"', 'android:label="Jasmin"')
if 'android:usesCleartextTraffic=' not in s:
    s = s.replace('<application', '<application android:usesCleartextTraffic="true"', 1)
manifest.write_text(s)

# model_viewer_plus requires Android minSdk 24.
for gradle in [Path('android/app/build.gradle'), Path('android/app/build.gradle.kts')]:
    if gradle.exists():
        t = gradle.read_text()
        t = t.replace('minSdk = flutter.minSdkVersion', 'minSdk = 24')
        t = t.replace('minSdkVersion flutter.minSdkVersion', 'minSdkVersion 24')
        gradle.write_text(t)

# local_auth requires FlutterFragmentActivity on Android.
for p in Path("android/app/src/main/kotlin").rglob("MainActivity.kt"):
    t = p.read_text()
    if "FlutterActivity" in t and "FlutterFragmentActivity" not in t:
        t = t.replace(
            "import io.flutter.embedding.android.FlutterActivity",
            "import io.flutter.embedding.android.FlutterFragmentActivity",
        )
        t = t.replace("extends FlutterActivity", "extends FlutterFragmentActivity")
        t = t.replace(": FlutterActivity()", ": FlutterFragmentActivity()")
        p.write_text(t)
PY
