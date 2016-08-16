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

extern "C" void init_silk_functions();

SilkCodec::SilkCodec() {
	init_silk_functions();

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
	int ret = SKP_Silk_SDK_Get_Encoder_Size(&encSizeBytes);
	enc_status = malloc(encSizeBytes);
	memset(enc_status, 0, encSizeBytes);
	LOGI("SILK Get_Encoder_Size ret = %d", ret);

	SKP_int32 decSizeBytes;
	ret = SKP_Silk_SDK_Get_Decoder_Size(&decSizeBytes);
	dec_status = malloc(decSizeBytes);
	memset(dec_status, 0, decSizeBytes);
}

SilkCodec::~SilkCodec() {
	free(enc_status);
}

void SilkCodec::setParameter(P_CodecParameter parameter) {
	SKP_int32 ret = -1;
	/* Reset Encoder */
	ret = SKP_Silk_SDK_InitEncoder(enc_status, &encControl);
	LOGI("SKP_Silk_SDK_InitEncoder ret = %d", ret);
	/* Set Encoder parameters */
	encControl.API_sampleRate = parameter->sampleRate;
	encControl.maxInternalSampleRate = parameter->sampleRate;
	encControl.packetSize = (parameter->ptime * encControl.API_sampleRate) / 1000;
	encControl.bitRate = (parameter->bitRate > 0 ? parameter->bitRate : 0);
	encControl.packetLossPercentage = 10;
	encControl.useInBandFEC = 1;
	encControl.complexity = 2;

	ret = SKP_Silk_SDK_InitDecoder(dec_status);
	LOGI("SKP_Silk_SDK_InitDecoder ret = %d", ret);
	/* Set Decoder parameters */
	decControl.API_sampleRate = parameter->sampleRate;
	decControl.framesPerPacket = 1;

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

int SilkCodec::encode(void* inData, short inLen, void* outData, int& outLen) {
	SKP_int32 ret = 0;
	// TODO : use dynamic value instead of fixed value
	nBytes = 900;
	ret = SKP_Silk_SDK_Encode(enc_status, &encControl, (short*) inData, (SKP_int16) inLen, (unsigned char*) outData, &nBytes);
	outLen = nBytes;
	LOGI("Silk encode ret = %d, dataLen = %d, nBytes = %d", ret, inLen, nBytes);
	return ret;
}

int SilkCodec::decode(void* inData, short inLen, void* outData, int& outLen) {
	SKP_Silk_TOC_struct toc;
	SKP_Silk_SDK_get_TOC((SKP_uint8*) inData, inLen, &toc);
	if (toc.framesInPacket == 0) {

	}
	SKP_int32 ret = 0;
	SKP_int16 out_nBytes = 320;
	ret = SKP_Silk_SDK_Decode(dec_status, &decControl, 0, (SKP_uint8*) inData, inLen, (SKP_int16*) outData, &out_nBytes);
	outLen = out_nBytes;
	return ret;
}
