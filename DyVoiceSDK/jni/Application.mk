APP_ABI := armeabi armeabi-v7a x86
APP_STL := stlport_static

APP_CFLAGS += -Wno-error=format-security
APP_CPPFLAGS += -frtti -Wno-error=format-security -fexceptions -fpermissive

LOCAL_CPPFLAGS := -std=c++11