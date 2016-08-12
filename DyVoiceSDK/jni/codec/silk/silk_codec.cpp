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

	API_fs_Hz = 24000;
	max_internal_fs_Hz = 0;
	targetRate_bps = 25000;
	smplsSinceLastPacket = 20;
	packetSize_ms = 20;
	frameSizeReadFromFile_ms = 20;
	packetLoss_perc = 0;

#if LOW_COMPLEXITY_ONLY
	complexity_mode = 0;
#else
	complexity_mode = 1;
#endif

	DTX_enabled = 0;
	INBandFEC_enabled = 0;
	quiet = 0;

	/* Set Encoder parameters */
	encControl.API_sampleRate = API_fs_Hz;
	encControl.maxInternalSampleRate = max_internal_fs_Hz;
	encControl.packetSize = (packetSize_ms * API_fs_Hz) / 1000;
	encControl.packetLossPercentage = packetLoss_perc;
	encControl.useInBandFEC = INBandFEC_enabled;
	encControl.useDTX = DTX_enabled;
	encControl.complexity = complexity_mode;
	encControl.bitRate = (targetRate_bps > 0 ? targetRate_bps : 0);

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
	if (ret) {
		LOGE("SKP_Silk_SDK_InitEncoder ret = %d", ret);
	}
	/* Set Encoder parameters */
	encControl.API_sampleRate = parameter->sampleRate;
	encControl.maxInternalSampleRate = max_internal_fs_Hz;
	encControl.packetSize = (packetSize_ms * API_fs_Hz) / 1000;
	encControl.packetLossPercentage = packetLoss_perc;
	encControl.useInBandFEC = INBandFEC_enabled;
	encControl.useDTX = DTX_enabled;
	encControl.complexity = complexity_mode;
	encControl.bitRate = (parameter->bitRate > 0 ? parameter->bitRate : 0);

}

int SilkCodec::encode(void* inData, short dataLen, void* outData) {
	SKP_int32 ret = -1;
	ret = SKP_Silk_SDK_Encode(psEnc, &encControl, (short*) inData, (SKP_int16) dataLen, (unsigned char*) outData, &nBytes);
	return ret;
}

int SilkCodec::decode(void* inData, short dataLen, void* outData) {
	return 0;
}
