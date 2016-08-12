/*
 * voice_api.cpp
 *
 *  Created on: 2016Äê8ÔÂ11ÈÕ
 *      Author: duoyi01
 */

#include "voice_api.h"

VoiceApi* VoiceApi::instance = NULL;

VoiceApi::VoiceApi() {
	m_voiceCodec = NULL;
	parameter.bitRate = 0;
	parameter.sampleRate = 0;

	// TEST
	m_in_file = NULL;
	m_bitOut_file = NULL;
	m_out_file = NULL;

	char in_name[250] = "/sdcard/orginal_1.pcm";
	strcpy(m_in_file_name, in_name);
	char bitOut_name[250] = "/sdcard/orginal_1";
	strcpy(m_bitOut_file_name, bitOut_name);
	char out_name[250] = "/sdcard/orginal_1_out.pcm";
	strcpy(m_out_file_name, out_name);
}

VoiceApi::~VoiceApi() {

}

VoiceApi* VoiceApi::getInstance() {
	if(instance == NULL) {
		instance = new VoiceApi();
	}
	return instance;
}

void VoiceApi::setParameter(int codecId,
							int sampleRate,
							int bitRate,
							int maxInternalSampleRate,
							bool useFec,
							bool dtx,
							int complexity) {
	switch (codecId) {
	case kSilk: {
		m_voiceCodec = new SilkCodec();
		parameter.sampleRate = sampleRate;
		parameter.bitRate = bitRate;
		P_CodecParameter p_parameter = &parameter;
		m_voiceCodec->setParameter(p_parameter);
	}
		break;
	default:
		break;
	}
}

int VoiceApi::startCall() {
	return 0;
}

int VoiceApi::stopCall() {
	if(m_voiceCodec != NULL) {
		delete m_voiceCodec;
		m_voiceCodec = NULL;
	}
	return 0;
}

// TEST
int VoiceApi::encode() {
	short counter = 0;
	short in[4800];
	unsigned char payload[1250];
	int frameSizeReadFromFile = 20, ret = 0;
	if (m_in_file == NULL) {
		m_in_file = fopen(m_in_file_name, "rb");
		if (m_in_file == NULL) {
			LOGE("m_in_file == NULL");
			return -1;
		}
	}
	if (m_bitOut_file == NULL) {
		m_bitOut_file = fopen(m_bitOut_file_name, "wb");
		if (m_bitOut_file_name == NULL) {
			LOGE("m_bitOut_file_name == NULL");
			return -1;
		}
	}

	while(1) {
		counter = fread(in, sizeof(unsigned short), (frameSizeReadFromFile * parameter.sampleRate) / 1000, m_in_file);
		if (counter < ((frameSizeReadFromFile * parameter.sampleRate) / 1000)) {
			break;
			LOGI("Read file to the end");
		}
		if (m_voiceCodec != NULL) {
			ret = m_voiceCodec->encode(in, counter, payload);
			if (ret) {
				LOGI("encode file ret = %d", ret);
			}
		}

		fwrite(payload, sizeof(unsigned char), sizeof(payload), m_bitOut_file);
	}

	if (m_in_file != NULL) {
		fclose(m_in_file);
	}
	if (m_bitOut_file != NULL) {
		fclose(m_bitOut_file);
	}
	return 0;
}

int VoiceApi::decode() {
	return 0;
}
