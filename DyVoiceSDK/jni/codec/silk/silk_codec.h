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
	int encode(void* inData, short inLen, void* outData, int& outLen);
	int decode(void* inData, short inLen, void* outData, int& outLen);

private:
	SKP_int16 nBytes;

    SKP_SILK_SDK_EncControlStruct encControl; // Struct for input to encoder
    SKP_SILK_SDK_DecControlStruct decControl;  // Struct for status of encoder

    void *enc_status;
    void *dec_status;
};

#endif /* CODEC_SILK_SILK_CODEC_H_ */
