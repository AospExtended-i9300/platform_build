#
# Copyright (C) 2018 The Android Open Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/mainline.mk)
$(call enforce-product-packages-exist,)

PRODUCT_NAME := mainline_arm64
PRODUCT_DEVICE := mainline_arm64
PRODUCT_BRAND := generic
PRODUCT_SHIPPING_API_LEVEL := 28
PRODUCT_RESTRICT_VENDOR_FILES := all

PRODUCT_ENFORCE_ARTIFACT_PATH_REQUIREMENTS := relaxed
PRODUCT_ARTIFACT_PATH_REQUIREMENT_WHITELIST += \
  root/init.zygote64_32.rc \
  system/etc/seccomp_policy/crash_dump.arm.policy \
  system/etc/seccomp_policy/mediacodec.policy \

# Modules that are to be moved to /product
PRODUCT_ARTIFACT_PATH_REQUIREMENT_WHITELIST += \
  system/app/Calendar/Calendar.apk \
  system/app/Camera2/Camera2.apk \
  system/app/DeskClock/DeskClock.apk \
  system/app/DeskClock/oat/arm64/DeskClock.odex \
  system/app/DeskClock/oat/arm64/DeskClock.vdex \
  system/app/Gallery2/Gallery2.apk \
  system/app/Music/Music.apk \
  system/app/QuickSearchBox/QuickSearchBox.apk \
  system/app/webview/webview.apk \
  system/bin/healthd \
  system/etc/init/healthd.rc \
  system/etc/vintf/manifest/manifest_healthd.xml \
  system/lib64/libjni_eglfence.so \
  system/lib64/libjni_filtershow_filters.so \
  system/lib64/libjni_jpegstream.so \
  system/lib64/libjni_jpegutil.so \
  system/lib64/libjni_latinime.so \
  system/lib64/libjni_tinyplanet.so \
  system/priv-app/CarrierConfig/CarrierConfig.apk \
  system/priv-app/CarrierConfig/oat/arm64/CarrierConfig.odex \
  system/priv-app/CarrierConfig/oat/arm64/CarrierConfig.vdex \
  system/priv-app/Contacts/Contacts.apk \
  system/priv-app/Dialer/Dialer.apk \
  system/priv-app/Launcher3QuickStep/Launcher3QuickStep.apk \
  system/priv-app/OneTimeInitializer/OneTimeInitializer.apk \
  system/priv-app/Provision/Provision.apk \
  system/priv-app/Settings/Settings.apk \
  system/priv-app/SettingsIntelligence/SettingsIntelligence.apk \
  system/priv-app/StorageManager/StorageManager.apk \
  system/priv-app/SystemUI/SystemUI.apk \
  system/priv-app/SystemUI/oat/arm64/SystemUI.odex \
  system/priv-app/SystemUI/oat/arm64/SystemUI.vdex \
  system/priv-app/WallpaperCropper/WallpaperCropper.apk \
