/*
 * voice_api.h
 *
 *  Created on: 2016Äê8ÔÂ11ÈÕ
 *      Author: duoyi01
 */

#ifndef API_VOICE_API_H_
#define API_VOICE_API_H_

#include <stdio.h>
#include <stdlib.h>
#include "silk_codec.h"
#include "dyutils.h"

class VoiceApi {
public:
	VoiceApi();
	~VoiceApi();
	static VoiceApi* getInstance();
	static VoiceApi* instance;

	void setParameter(
			int codecId,
			int sampleRate,
			int bitRate,
			int maxInternalSampleRate,
			bool useFec,
			bool dtx,
			int complexity);

	int startCall();
	int stopCall();

	int encode();
	int decode();

private:
	enum CodecId {
		kSilk = 0
	};
	VoiceCodec* m_voiceCodec;
	CodecParameter parameter;
	// TEST
	FILE* m_in_file;
	FILE* m_bitOut_file;
	FILE* m_out_file;

	char m_in_file_name[250];
	char m_bitOut_file_name[250];
	char m_out_file_name[250];
};

#endif /* API_VOICE_API_H_ */
