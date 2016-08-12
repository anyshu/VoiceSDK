/*
 * dylog.h
 *
 *  Created on: 2016��8��10��
 *      Author: duoyi01
 */

#ifndef UTILS_DYUTILS_H_
#define UTILS_DYUTILS_H_

#include <android/log.h>

#define TAG "DYVOICE"

#define LOGD(...) __android_log_print(ANDROID_LOG_DEBUG,TAG ,__VA_ARGS__)
#define LOGI(...) __android_log_print(ANDROID_LOG_INFO,TAG ,__VA_ARGS__)
#define LOGW(...) __android_log_print(ANDROID_LOG_WARN,TAG ,__VA_ARGS__)
#define LOGE(...) __android_log_print(ANDROID_LOG_ERROR,TAG ,__VA_ARGS__)
#define LOGF(...) __android_log_print(ANDROID_LOG_FATAL,TAG ,__VA_ARGS__)

unsigned long getTimestamp();

#endif /* UTILS_DYUTILS_H_ */
