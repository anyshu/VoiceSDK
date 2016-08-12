/*
 * silk_codec.h
 *
 *  Created on: 2016Äê8ÔÂ10ÈÕ
 *      Author: duoyi01
 */

#ifndef CODEC_SILK_SILK_CODEC_H_
#define CODEC_SILK_SILK_CODEC_H_

#include "voice_codec.h"
#include "SKP_Silk_SDK_API.h"

class SilkCodec: public VoiceCodec {
public:
	SilkCodec();
	~SilkCodec();
	void setParameter(P_CodecParameter parameter);
	int encode(void* inData, short dataLen, void* outData);
	int decode(void* inData, short dataLen, void* outData);

private:
	SKP_int16 nBytes;

	/* default settings */
	SKP_int32 API_fs_Hz;
	SKP_int32 max_internal_fs_Hz;
	SKP_int32 targetRate_bps;
	SKP_int32 smplsSinceLastPacket;
	SKP_int32 packetSize_ms;
	SKP_int32 frameSizeReadFromFile_ms;
	SKP_int32 packetLoss_perc;

	SKP_int32 complexity_mode;

	SKP_int32 DTX_enabled;
	SKP_int32 INBandFEC_enabled;
	SKP_int32 quiet;

    SKP_SILK_SDK_EncControlStruct encControl; // Struct for input to encoder
    SKP_SILK_SDK_EncControlStruct encStatus;  // Struct for status of encoder

    void *psEnc;
};

#endif /* CODEC_SILK_SILK_CODEC_H_ */
