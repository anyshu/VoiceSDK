/*
 * silk_codec.cpp
 *
 *  Created on: 2016Äê8ÔÂ10ÈÕ
 *      Author: duoyi01
 */
#include "silk_codec.h"
#include "dyutils.h"
#include <stdlib.h>

/* Define codec specific settings */
#define MAX_BYTES_PER_FRAME     250 // Equals peak bitrate of 100 kbps
#define MAX_INPUT_FRAMES        5
#define FRAME_LENGTH_MS         20
#define MAX_API_FS_KHZ          48

SilkCodec::SilkCodec() {
	nBytes = MAX_BYTES_PER_FRAME * MAX_INPUT_FRAMES;

	/* Set Default Encoder parameters */
	encControl.API_sampleRate = 16000;
	encControl.maxInternalSampleRate = encControl.API_sampleRate;
	encControl.packetSize = (20 * encControl.API_sampleRate) / 1000;
	encControl.packetLossPercentage = 0;
	encControl.useInBandFEC = 0;
	encControl.useDTX = 0;
#ifdef LOW_COMPLEXITY_ONLY
	encControl.complexity = 0;
#else
	encControl.complexity = 1;
#endif
	encControl.bitRate = 30000;

	SKP_int32 encSizeBytes;
	SKP_Silk_SDK_Get_Encoder_Size(&encSizeBytes);
	psEnc = malloc(encSizeBytes);
}

SilkCodec::~SilkCodec() {
	free(psEnc);
}

void SilkCodec::setParameter(P_CodecParameter parameter) {
	SKP_int32 ret = -1;
	/* Reset Encoder */
	ret = SKP_Silk_SDK_InitEncoder(psEnc, &encStatus);
	LOGI("SKP_Silk_SDK_InitEncoder ret = %d", ret);
	/* Set Encoder parameters */
	encControl.API_sampleRate = parameter->sampleRate;
	encControl.maxInternalSampleRate = parameter->sampleRate;
	encControl.packetSize = (parameter->ptime * encControl.API_sampleRate) / 1000;
	encControl.bitRate = (parameter->bitRate > 0 ? parameter->bitRate : 0);

	LOGI("SILK parameter samplerate = %d, maxInternalSampleRate = %d, packetSize = %d, packetLossPercentage = %d, FEC = %d, dtx = %d, complexity = %d, bitRate = %d",
			encControl.API_sampleRate,
			encControl.maxInternalSampleRate,
			encControl.packetSize,
			encControl.packetLossPercentage,
			encControl.useInBandFEC,
			encControl.useDTX,
			encControl.complexity,
			encControl.bitRate);
}

int SilkCodec::encode(void* inData, short dataLen, void* outData) {
	SKP_int32 ret = 0;
	ret = SKP_Silk_SDK_Encode(psEnc, &encControl, (short*) inData, (SKP_int16) dataLen, (unsigned char*) outData, &nBytes);
	LOGE("Silk encode ret = %d, dataLen = %d, nBytes = %d", ret, dataLen, nBytes);
	return ret;
}

int SilkCodec::decode(void* inData, short dataLen, void* outData) {
	return 0;
}
