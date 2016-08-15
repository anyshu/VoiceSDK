LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE    := dyvoicesdk

LOCAL_STATIC_LIBRARIES := silk

LOCAL_C_INCLUDES := $(LOCAL_PATH)/jniwrapper \
					$(LOCAL_PATH)/api \
					$(LOCAL_PATH)/utils \
					$(LOCAL_PATH)/codec \
					$(LOCAL_PATH)/codec/silk \
					$(LOCAL_PATH)/codec/silk/interface

LOCAL_SRC_FILES := jniwrapper/com_duoyi_dyvoicesdk_api_DyVoiceAPI.cpp \
				   api/voice_api.cpp \
				   utils/dyutils.cpp \
				   codec/silk/silk_codec.cpp

LOCAL_LDLIBS += -llog
#LOCAL_CFLAGS += -fPIC

include $(BUILD_SHARED_LIBRARY)

include $(LOCAL_PATH)/codec/silk/Android.mk