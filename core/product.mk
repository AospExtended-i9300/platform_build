#
# Copyright (C) 2007 The Android Open Source Project
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

#
# Functions for including AndroidProducts.mk files
# PRODUCT_MAKEFILES is set up in AndroidProducts.mks.
# Format of PRODUCT_MAKEFILES:
# <product_name>:<path_to_the_product_makefile>
# If the <product_name> is the same as the base file name (without dir
# and the .mk suffix) of the product makefile, "<product_name>:" can be
# omitted.

#
# Returns the list of all AndroidProducts.mk files.
# $(call ) isn't necessary.
#
define _find-android-products-files
$(file <$(OUT_DIR)/.module_paths/AndroidProducts.mk.list) \
  $(SRC_TARGET_DIR)/product/AndroidProducts.mk
endef

#
# For entries returned by get-product-makefiles, decode an entry to a short
# product name. These either may be in the form of <name>:path/to/file.mk or
# path/to/<name>.mk
# $(1): The entry to decode
#
# Returns two words:
#   <name> <file>
#
define _decode-product-name
$(strip \
  $(eval _cpm_words := $(subst :,$(space),$(1))) \
  $(if $(word 2,$(_cpm_words)), \
    $(wordlist 1,2,$(_cpm_words)), \
    $(basename $(notdir $(1))) $(1)))
endef

#
# Validates the new common lunch choices -- ensures that they're in an
# appropriate form, and are paired with definitions of their products.
# $(1): The new list of COMMON_LUNCH_CHOICES
# $(2): The new list of PRODUCT_MAKEFILES
#
define _validate-common-lunch-choices
$(strip $(foreach choice,$(1),\
  $(eval _parts := $(subst -,$(space),$(choice))) \
  $(if $(call math_lt,$(words $(_parts)),2), \
    $(error $(LOCAL_DIR): $(choice): Invalid lunch choice)) \
  $(if $(call math_gt_or_eq,$(words $(_parts)),4), \
    $(error $(LOCAL_DIR): $(choice): Invalid lunch choice)) \
  $(if $(filter-out eng userdebug user,$(word 2,$(_parts))), \
    $(error $(LOCAL_DIR): $(choice): Invalid variant: $(word 2,$(_parts)))) \
  $(if $(filter-out $(foreach p,$(2),$(call _decode-product-name,$(p))),$(word 1,$(_parts))), \
    $(error $(LOCAL_DIR): $(word 1,$(_parts)): Product not defined in this file)) \
  ))
endef

#
# Returns the sorted concatenation of PRODUCT_MAKEFILES
# variables set in the given AndroidProducts.mk files.
# $(1): the list of AndroidProducts.mk files.
#
# As a side-effect, COMMON_LUNCH_CHOICES will be set to a
# union of all of the COMMON_LUNCH_CHOICES definitions within
# each AndroidProducts.mk file.
#
define get-product-makefiles
$(sort \
  $(eval _COMMON_LUNCH_CHOICES :=) \
  $(foreach f,$(1), \
    $(eval PRODUCT_MAKEFILES :=) \
    $(eval COMMON_LUNCH_CHOICES :=) \
    $(eval LOCAL_DIR := $(patsubst %/,%,$(dir $(f)))) \
    $(eval include $(f)) \
    $(call _validate-common-lunch-choices,$(COMMON_LUNCH_CHOICES),$(PRODUCT_MAKEFILES)) \
    $(eval _COMMON_LUNCH_CHOICES += $(COMMON_LUNCH_CHOICES)) \
    $(PRODUCT_MAKEFILES) \
   ) \
  $(eval PRODUCT_MAKEFILES :=) \
  $(eval LOCAL_DIR :=) \
  $(eval COMMON_LUNCH_CHOICES := $(sort $(_COMMON_LUNCH_CHOICES) $(LUNCH_MENU_CHOICES))) \
  $(eval _COMMON_LUNCH_CHOICES :=) \
 )
endef

#
# Returns the sorted concatenation of all PRODUCT_MAKEFILES
# variables set in all AndroidProducts.mk files.
# $(call ) isn't necessary.
#
define get-all-product-makefiles
$(call get-product-makefiles,$(_find-android-products-files))
endef

#
# Functions for including product makefiles
#

_product_var_list := \
    PRODUCT_BUILD_PROP_OVERRIDES \
    PRODUCT_NAME \
    PRODUCT_MODEL \
    PRODUCT_LOCALES \
    PRODUCT_AAPT_CONFIG \
    PRODUCT_AAPT_PREF_CONFIG \
    PRODUCT_AAPT_PREBUILT_DPI \
    PRODUCT_HOST_PACKAGES \
    PRODUCT_PACKAGES \
    PRODUCT_PACKAGES_DEBUG \
    PRODUCT_PACKAGES_DEBUG_ASAN \
    PRODUCT_PACKAGES_ENG \
    PRODUCT_PACKAGES_TESTS \
    PRODUCT_DEVICE \
    PRODUCT_MANUFACTURER \
    PRODUCT_BRAND \
    PRODUCT_PROPERTY_OVERRIDES \
    PRODUCT_DEFAULT_PROPERTY_OVERRIDES \
    PRODUCT_PRODUCT_PROPERTIES \
    PRODUCT_PRODUCT_SERVICES_PROPERTIES \
    PRODUCT_ODM_PROPERTIES \
    PRODUCT_CHARACTERISTICS \
    PRODUCT_COPY_FILES \
    PRODUCT_OTA_PUBLIC_KEYS \
    PRODUCT_EXTRA_RECOVERY_KEYS \
    PRODUCT_PACKAGE_OVERLAYS \
    DEVICE_PACKAGE_OVERLAYS \
    PRODUCT_ENFORCE_RRO_EXCLUDED_OVERLAYS \
    PRODUCT_ENFORCE_RRO_TARGETS \
    PRODUCT_SDK_ATREE_FILES \
    PRODUCT_SDK_ADDON_NAME \
    PRODUCT_SDK_ADDON_COPY_FILES \
    PRODUCT_SDK_ADDON_COPY_MODULES \
    PRODUCT_SDK_ADDON_DOC_MODULES \
    PRODUCT_SDK_ADDON_SYS_IMG_SOURCE_PROP \
    PRODUCT_SOONG_NAMESPACES \
    PRODUCT_DEFAULT_WIFI_CHANNELS \
    PRODUCT_DEFAULT_DEV_CERTIFICATE \
    PRODUCT_RESTRICT_VENDOR_FILES \
    PRODUCT_VENDOR_KERNEL_HEADERS \
    PRODUCT_BOOT_JARS \
    PRODUCT_SUPPORTS_BOOT_SIGNER \
    PRODUCT_SUPPORTS_VBOOT \
    PRODUCT_SUPPORTS_VERITY \
    PRODUCT_SUPPORTS_VERITY_FEC \
    PRODUCT_OEM_PROPERTIES \
    PRODUCT_SYSTEM_DEFAULT_PROPERTIES \
    PRODUCT_SYSTEM_PROPERTY_BLACKLIST \
    PRODUCT_VENDOR_PROPERTY_BLACKLIST \
    PRODUCT_SYSTEM_SERVER_APPS \
    PRODUCT_SYSTEM_SERVER_JARS \
    PRODUCT_ALWAYS_PREOPT_EXTRACTED_APK \
    PRODUCT_DEXPREOPT_SPEED_APPS \
    PRODUCT_LOADED_BY_PRIVILEGED_MODULES \
    PRODUCT_VBOOT_SIGNING_KEY \
    PRODUCT_VBOOT_SIGNING_SUBKEY \
    PRODUCT_VERITY_SIGNING_KEY \
    PRODUCT_SYSTEM_VERITY_PARTITION \
    PRODUCT_VENDOR_VERITY_PARTITION \
    PRODUCT_PRODUCT_VERITY_PARTITION \
    PRODUCT_PRODUCT_SERVICES_VERITY_PARTITION \
    PRODUCT_ODM_VERITY_PARTITION \
    PRODUCT_SYSTEM_SERVER_DEBUG_INFO \
    PRODUCT_OTHER_JAVA_DEBUG_INFO \
    PRODUCT_DEX_PREOPT_MODULE_CONFIGS \
    PRODUCT_DEX_PREOPT_DEFAULT_COMPILER_FILTER \
    PRODUCT_DEX_PREOPT_DEFAULT_FLAGS \
    PRODUCT_DEX_PREOPT_BOOT_FLAGS \
    PRODUCT_DEX_PREOPT_PROFILE_DIR \
    PRODUCT_DEX_PREOPT_BOOT_IMAGE_PROFILE_LOCATION \
    PRODUCT_DEX_PREOPT_GENERATE_DM_FILES \
    PRODUCT_DEX_PREOPT_NEVER_ALLOW_STRIPPING \
    PRODUCT_USE_PROFILE_FOR_BOOT_IMAGE \
    PRODUCT_SYSTEM_SERVER_COMPILER_FILTER \
    PRODUCT_SANITIZER_MODULE_CONFIGS \
    PRODUCT_SYSTEM_BASE_FS_PATH \
    PRODUCT_VENDOR_BASE_FS_PATH \
    PRODUCT_PRODUCT_BASE_FS_PATH \
    PRODUCT_PRODUCT_SERVICES_BASE_FS_PATH \
    PRODUCT_ODM_BASE_FS_PATH \
    PRODUCT_SHIPPING_API_LEVEL \
    VENDOR_PRODUCT_RESTRICT_VENDOR_FILES \
    VENDOR_EXCEPTION_MODULES \
    VENDOR_EXCEPTION_PATHS \
    PRODUCT_ART_TARGET_INCLUDE_DEBUG_BUILD \
    PRODUCT_ART_USE_READ_BARRIER \
    PRODUCT_IOT \
    PRODUCT_SYSTEM_HEADROOM \
    PRODUCT_MINIMIZE_JAVA_DEBUG_INFO \
    PRODUCT_INTEGER_OVERFLOW_EXCLUDE_PATHS \
    PRODUCT_ADB_KEYS \
    PRODUCT_CFI_INCLUDE_PATHS \
    PRODUCT_CFI_EXCLUDE_PATHS \
    PRODUCT_DISABLE_SCUDO \
    PRODUCT_COMPATIBLE_PROPERTY_OVERRIDE \
    PRODUCT_ACTIONABLE_COMPATIBLE_PROPERTY_DISABLE \
    PRODUCT_ENFORCE_ARTIFACT_PATH_REQUIREMENTS \
    PRODUCT_ENFORCE_ARTIFACT_SYSTEM_CERTIFICATE_REQUIREMENT \
    PRODUCT_ARTIFACT_SYSTEM_CERTIFICATE_REQUIREMENT_WHITELIST \
    PRODUCT_ARTIFACT_PATH_REQUIREMENT_HINT \
    PRODUCT_ARTIFACT_PATH_REQUIREMENT_WHITELIST \
    PRODUCT_USE_DYNAMIC_PARTITION_SIZE \
    PRODUCT_BUILD_SUPER_PARTITION \
    PRODUCT_FORCE_PRODUCT_MODULES_TO_SYSTEM_PARTITION \
    PRODUCT_USE_DYNAMIC_PARTITIONS \
    PRODUCT_RETROFIT_DYNAMIC_PARTITIONS \
    PRODUCT_OTA_ENFORCE_VINTF_KERNEL_REQUIREMENTS \
    PRODUCT_XOM_EXCLUDE_PATHS \
    PRODUCT_MANIFEST_PACKAGE_NAME_OVERRIDES \
    PRODUCT_PACKAGE_NAME_OVERRIDES \
    PRODUCT_CERTIFICATE_OVERRIDES \
    PRODUCT_BUILD_SYSTEM_IMAGE \
    PRODUCT_BUILD_SYSTEM_OTHER_IMAGE \
    PRODUCT_BUILD_VENDOR_IMAGE \
    PRODUCT_BUILD_PRODUCT_IMAGE \
    PRODUCT_BUILD_PRODUCT_SERVICES_IMAGE \
    PRODUCT_BUILD_ODM_IMAGE \
    PRODUCT_BUILD_CACHE_IMAGE \
    PRODUCT_BUILD_RAMDISK_IMAGE \
    PRODUCT_BUILD_USERDATA_IMAGE \
    PRODUCT_UPDATABLE_BOOT_MODULES \
    PRODUCT_UPDATABLE_BOOT_LOCATIONS \
    PRODUCT_CHECK_ELF_FILES \

define dump-product
$(warning ==== $(1) ====)\
$(foreach v,$(_product_var_list),\
$(warning PRODUCTS.$(1).$(v) := $(PRODUCTS.$(1).$(v))))\
$(warning --------)
endef

define dump-products
$(foreach p,$(PRODUCTS),$(call dump-product,$(p)))
endef

#
# $(1): product to inherit
#
# To be called from product makefiles, and is later evaluated during the import-nodes
# call below. It does three things:
#  1. Inherits all of the variables from $1.
#  2. Records the inheritance in the .INHERITS_FROM variable
#  3. Records the calling makefile in PARENT_PRODUCT_FILES
#
# (2) and (3) can be used together to reconstruct the include hierarchy
# See e.g. product-graph.mk for an example of this.
#
define inherit-product
  $(if $(findstring ../,$(1)),\
    $(eval np := $(call normalize-paths,$(1))),\
    $(eval np := $(strip $(1))))\
  $(foreach v,$(_product_var_list), \
      $(eval $(v) := $($(v)) $(INHERIT_TAG)$(np))) \
  $(eval current_mk := $(strip $(word 1,$(_include_stack)))) \
  $(eval inherit_var := PRODUCTS.$(current_mk).INHERITS_FROM) \
  $(eval $(inherit_var) := $(sort $($(inherit_var)) $(np))) \
  $(eval PARENT_PRODUCT_FILES := $(sort $(PARENT_PRODUCT_FILES) $(current_mk)))
endef

# Specifies a number of path prefixes, relative to PRODUCT_OUT, where the
# product makefile hierarchy rooted in the current node places its artifacts.
# Creating artifacts outside the specified paths will cause a build-time error.
define require-artifacts-in-path
  $(eval current_mk := $(strip $(word 1,$(_include_stack)))) \
  $(eval PRODUCTS.$(current_mk).ARTIFACT_PATH_REQUIREMENTS := $(strip $(1))) \
  $(eval PRODUCTS.$(current_mk).ARTIFACT_PATH_WHITELIST := $(strip $(2))) \
  $(eval ARTIFACT_PATH_REQUIREMENT_PRODUCTS := \
    $(sort $(ARTIFACT_PATH_REQUIREMENT_PRODUCTS) $(current_mk)))
endef

# Makes including non-existant modules in PRODUCT_PACKAGES an error.
# $(1): whitelist of non-existant modules to allow.
define enforce-product-packages-exist
  $(eval current_mk := $(strip $(word 1,$(_include_stack)))) \
  $(eval PRODUCTS.$(current_mk).PRODUCT_ENFORCE_PACKAGES_EXIST := true) \
  $(eval PRODUCTS.$(current_mk).PRODUCT_ENFORCE_PACKAGES_EXIST_WHITELIST := $(1)) \
  $(eval .KATI_READONLY := PRODUCTS.$(current_mk).PRODUCT_ENFORCE_PACKAGES_EXIST) \
  $(eval .KATI_READONLY := PRODUCTS.$(current_mk).PRODUCT_ENFORCE_PACKAGES_EXIST_WHITELIST)
endef

#
# Do inherit-product only if $(1) exists
#
define inherit-product-if-exists
  $(if $(wildcard $(1)),$(call inherit-product,$(1)),)
endef

#
# $(1): product makefile list
#
#TODO: check to make sure that products have all the necessary vars defined
define import-products
$(call import-nodes,PRODUCTS,$(1),$(_product_var_list))
endef


#
# Does various consistency checks on all of the known products.
# Takes no parameters, so $(call ) is not necessary.
#
define check-all-products
$(if ,, \
  $(eval _cap_names :=) \
  $(foreach p,$(PRODUCTS), \
    $(eval pn := $(strip $(PRODUCTS.$(p).PRODUCT_NAME))) \
    $(if $(pn),,$(error $(p): PRODUCT_NAME must be defined.)) \
    $(if $(filter $(pn),$(_cap_names)), \
      $(error $(p): PRODUCT_NAME must be unique; "$(pn)" already used by $(strip \
          $(foreach \
            pp,$(PRODUCTS),
              $(if $(filter $(pn),$(PRODUCTS.$(pp).PRODUCT_NAME)), \
                $(pp) \
               ))) \
       ) \
     ) \
    $(eval _cap_names += $(pn)) \
    $(if $(call is-c-identifier,$(pn)),, \
      $(error $(p): PRODUCT_NAME must be a valid C identifier, not "$(pn)") \
     ) \
    $(eval pb := $(strip $(PRODUCTS.$(p).PRODUCT_BRAND))) \
    $(if $(pb),,$(error $(p): PRODUCT_BRAND must be defined.)) \
    $(foreach cf,$(strip $(PRODUCTS.$(p).PRODUCT_COPY_FILES)), \
      $(if $(filter 2 3,$(words $(subst :,$(space),$(cf)))),, \
        $(error $(p): malformed COPY_FILE "$(cf)") \
       ) \
     ) \
   ) \
)
endef


#
# Returns the product makefile path for the product with the provided name
#
# $(1): short product name like "generic"
#
define _resolve-short-product-name
  $(eval pn := $(strip $(1)))
  $(eval p := \
      $(foreach p,$(PRODUCTS), \
          $(if $(filter $(pn),$(PRODUCTS.$(p).PRODUCT_NAME)), \
            $(p) \
       )) \
   )
  $(eval p := $(sort $(p)))
  $(if $(filter 1,$(words $(p))), \
    $(p), \
    $(if $(filter 0,$(words $(p))), \
      $(error No matches for product "$(pn)"), \
      $(error Product "$(pn)" ambiguous: matches $(p)) \
    ) \
  )
endef
define resolve-short-product-name
$(strip $(call _resolve-short-product-name,$(1)))
endef

_product_stash_var_list := $(_product_var_list)
# TODO: Move this to board_config.mk when no longer set in product makefiles
_product_stash_var_list += WITH_DEXPREOPT_BOOT_IMG_AND_SYSTEM_SERVER_ONLY
_product_strip_var_list :=

#
# Mark the variables in _product_stash_var_list as readonly
#
define readonly-product-vars
$(foreach v,$(_product_stash_var_list), \
  $(eval $(v) ?=) \
  $(eval .KATI_READONLY := $(v)) \
 )
endef

#
# Strip the variables in _product_strip_var_list
#
define strip-product-vars
$(foreach v,$(_product_strip_var_list),$(eval $(v) := $(strip $($(v)))))
endef

define add-to-product-copy-files-if-exists
$(if $(wildcard $(word 1,$(subst :, ,$(1)))),$(1))
endef

# whitespace placeholder when we record module's dex-preopt config.
_PDPMC_SP_PLACE_HOLDER := |@SP@|
# Set up dex-preopt config for a module.
# $(1) list of module names
# $(2) the modules' dex-preopt config
define add-product-dex-preopt-module-config
$(eval _c := $(subst $(space),$(_PDPMC_SP_PLACE_HOLDER),$(strip $(2))))\
$(eval PRODUCT_DEX_PREOPT_MODULE_CONFIGS += \
  $(foreach m,$(1),$(m)=$(_c)))
endef

# whitespace placeholder when we record module's sanitizer config.
_PSMC_SP_PLACE_HOLDER := |@SP@|
# Set up sanitizer config for a module.
# $(1) list of module names
# $(2) the modules' sanitizer config
define add-product-sanitizer-module-config
$(eval _c := $(subst $(space),$(_PSMC_SP_PLACE_HOLDER),$(strip $(2))))\
$(eval PRODUCT_SANITIZER_MODULE_CONFIGS += \
  $(foreach m,$(1),$(m)=$(_c)))
endef
