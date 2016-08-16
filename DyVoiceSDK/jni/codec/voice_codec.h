/*
 * voice_encoder.h
 *
 *  Created on: 2016Äê8ÔÂ10ÈÕ
 *      Author: duoyi01
 */

#ifndef CODEC_SILK_VOICE_CODEC_H_
#define CODEC_SILK_VOICE_CODEC_H_

typedef struct
{
	int sampleRate;
	int bitRate;
	int ptime;
}CodecParameter, *P_CodecParameter;

class VoiceCodec
{
public:
	virtual ~VoiceCodec() {};
	virtual void setParameter(P_CodecParameter parameter) = 0;
	virtual int encode(void* inData, short dataLen, void* outData) = 0;
	virtual int decode(void* inData, short dataLen, void* outData) = 0;
};

#endif /* CODEC_SILK_VOICE_CODEC_H_ */
