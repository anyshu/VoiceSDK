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
	parameter.ptime = 0;

	// TEST
	m_in_file = NULL;
	m_bitOut_file = NULL;
	m_out_file = NULL;

	char in_name[250] = "/sdcard/dyvoicedemo/original.pcm";
	strcpy(m_in_file_name, in_name);
	char bitOut_name[250] = "/sdcard/dyvoicedemo/original";
	strcpy(m_bitOut_file_name, bitOut_name);
	char out_name[250] = "/sdcard/dyvoicedemo/original_out.pcm";
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
		parameter.ptime = 20;
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
		LOGI("DisContruct VoiceApi");
		delete m_voiceCodec;
		m_voiceCodec = NULL;
	}
	return 0;
}

// TEST
int VoiceApi::encode() {
	short sampleLen = 0;
	int payloadLen = 0, decode_payloadLen = 0;
	short sample[4800];
	unsigned char payload[1250];
	unsigned char decode_payload[1250];
	int packetSizeInShort;
	int ret = 0;
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
	if (m_out_file == NULL) {
		m_out_file = fopen(m_out_file_name, "wb");
		if (m_out_file == NULL) {
			LOGE("m_out_file == NULL");
			return -1;
		}
	}

	packetSizeInShort = (parameter.ptime * parameter.sampleRate) / 1000;
	LOGD("packetSizeInShort = %d", packetSizeInShort);

	while (1) {
		sampleLen = fread(sample, sizeof(unsigned short), packetSizeInShort, m_in_file);
		if (sampleLen < (packetSizeInShort)) {
			LOGI("Read file to the end");
			break;
		}
		if (m_voiceCodec != NULL) {
			ret = m_voiceCodec->encode(sample, sampleLen, payload, payloadLen);
			if (ret < 0) {
				LOGE("Encode error");
			}
			ret = m_voiceCodec->decode(payload, payloadLen, decode_payload, decode_payloadLen);
			if (ret < 0) {
				LOGE("Decode error");
			} else {
				fwrite(decode_payload, sizeof(unsigned short), decode_payloadLen, m_out_file);
			}
		}

		fwrite(payload, sizeof(unsigned char), payloadLen, m_bitOut_file);
	}

	if (m_in_file != NULL) {
		LOGI("Close m_in_file");
		fclose(m_in_file);
		m_in_file = NULL;
	}
	if (m_bitOut_file != NULL) {
		LOGI("Close m_out_file");
		fclose(m_bitOut_file);
		m_bitOut_file = NULL;
	}
	if (m_out_file != NULL) {
			LOGI("Close m_out_file");
			fclose(m_out_file);
			m_out_file = NULL;
		}
	return 0;
}

int VoiceApi::decode() {
	return 0;
}
