package com.duoyi.dyvoicesdk.api;

public class DyVoiceAPI {
	
	static {
		try {
			System.loadLibrary("dyvoicesdk");
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	private native int setParameter(int codecId, int sampleRate, int bitRate, int maxInternalSampleRate, boolean useFEC, boolean dtx, int complexity);
	private native int startCall();
	private native int stopCall();
	
	private native int encode();
	private native int decode();
	
	public int start() {
		return startCall();
	}
	
	public int stop() {
		return stopCall();
	}
	
	public int setCodecParameter(int codecId, int sampleRate, int bitRate, int maxInternalSampleRate, boolean useFEC,
			boolean dtx, int complexity) {
		return setParameter(codecId, sampleRate, bitRate, maxInternalSampleRate, useFEC, dtx, complexity);
	}

	// TEST
	public int encodeTest() {
		return encode();
	}
	
	public int decodeTest() {
		return decode();
	}
}
