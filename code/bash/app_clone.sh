#!/bin/bash
APK="TMDriver.apk"
URL_APK="http://files.bitmaster.ru/TM/android/"$APK""
NAME_APK="TMDriver"
NEW_NAME_APK="TAXI 116 RUS"
#keytool -genkeypair -v -keystore filekey.keystore -alias keyname -keyalg RSA -keysize 2048 -validity 10000
KEYFILE="filekey.keystore"
KEY="keyname"
URL_OLD="ru.taximaster.www"
URL_NEW="ru.taxopark.www"
NEW_ICON_FILE=./icon.png
#convert -resize 48x48^ -gravity center -extent 48x48 -quality 100% ./icon.jpg ./icon.png
ICON="./TMDriver/res/drawable/icon.png"
PASSWORD_KEYFILE="pfqwtd"


rm -rf ./$APK
rm -rf ./$NAME_APK
wget "$URL_APK"
apktool d ./$APK
sed 's/>'"$NAME_APK"'</>'"$NEW_NAME_APK"'</g' -i ./TMDriver/res/values/strings.xml
sed 's/android:authorities="'"$URL_OLD"'.firebaseinitprovider"/android:authorities="'"$URL_NEW"'"/g' ./TMDriver/AndroidManifest.xml -i
sed 's/package="'"$URL_OLD"'"/package="'"$URL_NEW"'"/g' ./TMDriver/AndroidManifest.xml -i
sed 's/'"$URL_OLD"'.permission/'"$URL_NEW"'.permission/g' ./TMDriver/AndroidManifest.xml -i
cp "$NEW_ICON_FILE" "$ICON"
apktool b $NAME_APK
zipalign -f -v 4 "./$NAME_APK/dist/$APK" "./$NEW_NAME_APK.apk"
echo "$PASSWORD_KEYFILE" | apksigner sign --ks "./$KEYFILE" --ks-key-alias "$KEY" "./$NEW_NAME_APK.apk"

adb push ./"$NEW_NAME_APK".apk /sdcard/
adb shell pm install -r -d /sdcard/"$NEW_NAME_APK".apk
