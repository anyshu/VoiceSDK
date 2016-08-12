/*
 * com_duoyi_dyvoicesdk_api_DyVoiceAPI.cpp
 *
 *  Created on: 2016Äê8ÔÂ10ÈÕ
 *      Author: duoyi01
 */

#include <dyutils.h>
#include "com_duoyi_dyvoicesdk_api_DyVoiceAPI.h"
#include "voice_api.h"

JNIEXPORT jint JNI_OnLoad(JavaVM* vm, void* reserved) {
	LOGI("JNI_OnLoad");
	return JNI_VERSION_1_4;
}

JNIEXPORT jint JNICALL Java_com_duoyi_dyvoicesdk_api_DyVoiceAPI_setParameter(
		JNIEnv *, jobject, jint codecId, jint sampleRate, jint bitRate, jint maxInternalSampleRate, jboolean useFEC, jboolean dtx, jint complexity) {
	VoiceApi* voiceapi = VoiceApi::getInstance();
	if (voiceapi != NULL) {
		voiceapi->setParameter(codecId, sampleRate, bitRate, maxInternalSampleRate, useFEC, dtx, complexity);
		return 1;
	}
	return 0;
}

JNIEXPORT jint JNICALL Java_com_duoyi_dyvoicesdk_api_DyVoiceAPI_startCall(
		JNIEnv *, jobject) {
	VoiceApi* voiceapi = VoiceApi::getInstance();
	if (voiceapi != NULL) {
		return voiceapi->startCall();
	}
	return 0;
}

JNIEXPORT jint JNICALL Java_com_duoyi_dyvoicesdk_api_DyVoiceAPI_stopCall(
		JNIEnv *, jobject) {
	VoiceApi* voiceapi = VoiceApi::getInstance();
	if (voiceapi != NULL) {
		int ret = voiceapi->stopCall();
		delete VoiceApi::instance;
		VoiceApi::instance = NULL;
		return ret;
	}
	return 0;
}

JNIEXPORT jint JNICALL Java_com_duoyi_dyvoicesdk_api_DyVoiceAPI_encode(
		JNIEnv *, jobject) {
	VoiceApi* voiceapi = VoiceApi::getInstance();
	if (voiceapi != NULL) {
		return voiceapi->encode();
	}
	return 0;
}

JNIEXPORT jint JNICALL Java_com_duoyi_dyvoicesdk_api_DyVoiceAPI_decode(
		JNIEnv *, jobject) {
	VoiceApi* voiceapi = VoiceApi::getInstance();
	if (voiceapi != NULL) {
		return voiceapi->decode();
	}
	return 0;
}
