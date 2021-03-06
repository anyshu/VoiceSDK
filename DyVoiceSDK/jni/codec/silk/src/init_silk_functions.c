#include "SKP_Silk_SigProc_FIX.h"
#include <cpu-features.h>
#include <android/log.h>

extern SKP_int32 SKP_Silk_inner_prod_aligned_neon(const SKP_int16* const, const SKP_int16* const, const SKP_int);
extern SKP_int32 SKP_Silk_inner_prod_aligned_arm5(const SKP_int16* const, const SKP_int16* const, const SKP_int);
extern SKP_int32 SKP_Silk_inner_prod_aligned_c(const SKP_int16* const, const SKP_int16* const, const SKP_int);
extern SKP_int64 SKP_Silk_inner_prod16_aligned_64_neon(const SKP_int16*, const SKP_int16*, const SKP_int);
extern SKP_int64 SKP_Silk_inner_prod16_aligned_64_arm5(const SKP_int16*, const SKP_int16*, const SKP_int);
extern SKP_int64 SKP_Silk_inner_prod16_aligned_64_c(const SKP_int16*, const SKP_int16*, const SKP_int);
extern void SKP_Silk_MA_Prediction_neon(const SKP_int16*, const SKP_int16*, SKP_int32*, SKP_int16*, const SKP_int32, const SKP_int32);
extern void SKP_Silk_MA_Prediction_arm5(const SKP_int16*, const SKP_int16*, SKP_int32*, SKP_int16*, const SKP_int32, const SKP_int32);
extern void SKP_Silk_MA_Prediction_c(const SKP_int16*, const SKP_int16*, SKP_int32*, SKP_int16*, const SKP_int32, const SKP_int32);

#ifdef ANDROID

SKP_Silk_inner_prod_aligned_prototype* SKP_Silk_inner_prod_aligned = NULL;
SKP_Silk_inner_prod16_aligned_64_prototype* SKP_Silk_inner_prod16_aligned_64 = NULL;
SKP_Silk_MA_Prediction_prototype* SKP_Silk_MA_Prediction = NULL;

void init_silk_functions() {
	SKP_int32 g_IsNeonSupport = 0;
	if (android_getCpuFamily() == ANDROID_CPU_FAMILY_ARM
			&& (android_getCpuFeatures() & ANDROID_CPU_ARM_FEATURE_NEON) != 0) {
		g_IsNeonSupport = 1;
		__android_log_print(ANDROID_LOG_INFO, "DYVOICE", "device support NEON");
	} else {
		g_IsNeonSupport = 0;
		__android_log_print(ANDROID_LOG_INFO, "DYVOICE", "device don't support NEON");
	}

#ifdef HAVE_NEON
	if(g_IsNeonSupport == 1) {
		SKP_Silk_inner_prod_aligned = SKP_Silk_inner_prod_aligned_neon;
		SKP_Silk_inner_prod16_aligned_64 = SKP_Silk_inner_prod16_aligned_64_neon;
		SKP_Silk_MA_Prediction = SKP_Silk_MA_Prediction_neon;
	} else 
#endif
//  Fix compile error on NDKR9
#if (EMBEDDED_ARM >= 5)
	{
		SKP_Silk_inner_prod_aligned = SKP_Silk_inner_prod_aligned_arm5;
		SKP_Silk_inner_prod16_aligned_64 = SKP_Silk_inner_prod16_aligned_64_arm5;
		SKP_Silk_MA_Prediction = SKP_Silk_MA_Prediction_arm5;
	}
#else
	{
		SKP_Silk_inner_prod_aligned = SKP_Silk_inner_prod_aligned_c;
		SKP_Silk_inner_prod16_aligned_64 = SKP_Silk_inner_prod16_aligned_64_c;
		SKP_Silk_MA_Prediction = SKP_Silk_MA_Prediction_c;
	}
#endif
}
#else
#if ( EMBEDDED_ARM >= 7 ) // neon
SKP_Silk_inner_prod_aligned_prototype* SKP_Silk_inner_prod_aligned = SKP_Silk_inner_prod_aligned_neon;
SKP_Silk_inner_prod16_aligned_64_prototype* SKP_Silk_inner_prod16_aligned_64 = SKP_Silk_inner_prod16_aligned_64_neon;
SKP_Silk_MA_Prediction_prototype* SKP_Silk_MA_Prediction = SKP_Silk_MA_Prediction_neon;
#elif !NO_ASM // arm
SKP_Silk_inner_prod_aligned_prototype* SKP_Silk_inner_prod_aligned = SKP_Silk_inner_prod_aligned_arm5;
SKP_Silk_inner_prod16_aligned_64_prototype* SKP_Silk_inner_prod16_aligned_64 = SKP_Silk_inner_prod16_aligned_64_arm5;
SKP_Silk_MA_Prediction_prototype* SKP_Silk_MA_Prediction = SKP_Silk_MA_Prediction_arm5;
#else // no asm
SKP_Silk_inner_prod_aligned_prototype* SKP_Silk_inner_prod_aligned = SKP_Silk_inner_prod_aligned_c;
SKP_Silk_inner_prod16_aligned_64_prototype* SKP_Silk_inner_prod16_aligned_64 = SKP_Silk_inner_prod16_aligned_64_c;
SKP_Silk_MA_Prediction_prototype* SKP_Silk_MA_Prediction = SKP_Silk_MA_Prediction_c;
#endif
#endif






