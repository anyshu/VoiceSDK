/***********************************************************************
Copyright (c) 2006-2012, Skype Limited. All rights reserved. 
Redistribution and use in source and binary forms, with or without 
modification, (subject to the limitations in the disclaimer below) 
are permitted provided that the following conditions are met:
- Redistributions of source code must retain the above copyright notice,
this list of conditions and the following disclaimer.
- Redistributions in binary form must reproduce the above copyright 
notice, this list of conditions and the following disclaimer in the 
documentation and/or other materials provided with the distribution.
- Neither the name of Skype Limited, nor the names of specific 
contributors, may be used to endorse or promote products derived from 
this software without specific prior written permission.
NO EXPRESS OR IMPLIED LICENSES TO ANY PARTY'S PATENT RIGHTS ARE GRANTED 
BY THIS LICENSE. THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND 
CONTRIBUTORS ''AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,
BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND 
FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE 
COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, 
INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF 
USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON 
ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT 
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE 
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
***********************************************************************/

#if defined(__arm__)

#include "SKP_Silk_AsmPreproc.h"

#if EMBEDDED_ARM>=5
/*
 * void SKP_Silk_MA_Prediction(
 *	const SKP_int16		*in,			 I:	input signal								
 *  const SKP_int16		*B,				 I:	MA coefficients, Q13 [order+1]				
 *	SKP_int32			*S,				 I/O: state vector [order]						
 *	SKP_int16			*out,			 O:	output signal								
 *	const SKP_int32		len,			 I:	signal length								
 *	const SKP_int32		order			 I:	filter order								
 *	)
 *
 *
 */
 
 
	VARDEF ma_in, sb
	VARDEF ma_out, sl
	VARDEF ma_s, ip
	VARDEF ma_b, lr
	VARDEF ma_len, r4

	VARDEF ma_in_val, r0
	VARDEF ma_s0_val, r1
	VARDEF ma_s1_val, r2
	VARDEF ma_order, r5
	VARDEF ma_b_val, r6

	VARDEF ma_tmp0, r3
	VARDEF ma_out_val, r1
	VARDEF ma_const0, r3

	VARDEF ma_s2_val, r3

#ifdef IPHONE
	VARDEF ma_new_s1, r8
	VARDEF ma_new_s2, _r7
#else
	VARDEF ma_new_s1, _r7
	VARDEF ma_new_s2, r8
#endif

ALIGN 4
.set	SAVE_IN, 0 
.set	SAVE_B, 4 
.set	SAVE_S, 8 
.set	SAVE_OUT, 12 

.globl	SYM(SKP_Silk_MA_Prediction_arm5)
SYM(SKP_Silk_MA_Prediction_arm5):
	stmdb	sp!,  {r4-r10, fp, ip, lr}
	add		fp, sp, #36
	sub		sp, sp, #16
.set	arg_len, 56 
.set	arg_order, 60 

/*LOAD INPUT ARGS*/	
	ldr		ma_order, [sp, #arg_order]
	ldr		ma_len, [sp, #arg_len]
	ands	_r7, r1, #3
	bne		LR(9, f)/*MA_Prediction_ORDER_2BYTE*/
	ands	r6, ma_order, #1
	bne		LR(9, f)/*MA_Prediction_ORDER_2BYTE*/
	cmp		ma_order, #6					
	blt		LR(9, f)/*MA_Prediction_ORDER_2BYTE*/
//	order % 2 == 0
	str		r0, [sp, #SAVE_IN]
	str		r1, [sp, #SAVE_B]
	str		r2, [sp, #SAVE_S]
	str		r3, [sp, #SAVE_OUT]
	
	mov		ma_in, r0
	mov		ma_out, r3

L(0)
	ldr		ma_s, [sp, #SAVE_S]
	ldr		ma_b, [sp, #SAVE_B]
	ldrsh	ma_in_val, [ma_in], #2
	ldr		ma_s0_val, [ma_s], #4
	ldr		ma_order, [sp, #arg_order]
	ldr		ma_s1_val, [ma_s], #4
	rsb		ma_tmp0, ma_s0_val, ma_in_val, lsl #12
	ldr		ma_b_val, [ma_b], #4
	qadd	ma_out_val, ma_tmp0, ma_tmp0
	sub		ma_order, ma_order, #4
	mov		ma_const0, #32768
	qadd	ma_out_val, ma_out_val, ma_out_val
	qadd	ma_out_val, ma_out_val, ma_out_val
	qadd	ma_out_val, ma_out_val, ma_out_val
	qadd	ma_out_val, ma_out_val, ma_const0
	ldr		ma_s2_val, [ma_s], #4
	mov		ma_out_val, ma_out_val, asr #16
	strh	ma_out_val, [ma_out], #2
	sub		r1, ma_s, #12	
L(1)
	smlabb	ma_new_s1, ma_in_val, ma_b_val, ma_s1_val
	smlabt	ma_new_s2, ma_in_val, ma_b_val, ma_s2_val
	ldmia	ma_s!, {ma_s1_val, ma_s2_val}
	ldr		ma_b_val,  [ma_b],  #4
	subs	ma_order, ma_order, #2
	stmia	r1!, {ma_new_s1, ma_new_s2}
	bgt		LR(1, b)
	smlabb	ma_new_s1, ma_in_val, ma_b_val, ma_s1_val
	smlabt	ma_new_s2, ma_in_val, ma_b_val, ma_s2_val
	ldr		ma_s1_val, [ma_s], #-12
	ldr		ma_b_val,  [ma_b]
	str		ma_new_s1, [ma_s], #4
	str		ma_new_s2, [ma_s], #4
	
	smlabb	ma_new_s1, ma_in_val, ma_b_val, ma_s1_val
	smulbt	ma_new_s2, ma_in_val, ma_b_val
	subs	ma_len, ma_len, #1
	str		ma_new_s1, [ma_s], #4
	str		ma_new_s2, [ma_s]
	bgt		LR(0, b)
	
	add		sp, sp, #16
	ldmia	sp!,  {r4-r10, fp, ip, pc}

	VARDEF ma1_in, r6
	VARDEF ma1_out, sb
	VARDEF ma1_s0_val, lr
	VARDEF ma1_b, _r7
	VARDEF ma1_s, r8
	VARDEF ma1_b_val, r2
	VARDEF ma1_s1_val, r3
	VARDEF ma1_b0_val, r1
	VARDEF ma1_s2_val, r2
	
//	order % 2 != 0 	
/*MA_Prediction_ORDER_2BYTE:	*/
L(9)
	add		r2, r2, #4
	str		r0, [sp, #SAVE_IN]
	str		r1, [sp, #SAVE_B]
	str		r2, [sp, #SAVE_S]
	str		r3, [sp, #SAVE_OUT]
	
	mov		ma1_in, r0
	mov		ma1_out, r3
	ldr		ma1_s0_val, [r2, #-4]

L(0)
	ldrsh	ma_in_val, [ma1_in], #2
	ldr		ma_order, [sp, #arg_order]
	ldr		ma1_b, [sp, #SAVE_B]
	ldr		ma1_s, [sp, #SAVE_S]
	rsb		ma_out_val, ma1_s0_val, ma_in_val, lsl #12
	ldrsh	ma1_b_val, [ma1_b], #2
	qadd	ma_out_val, ma_out_val, ma_out_val
	ldr		ma1_s1_val, [ma1_s]
	qadd	ma_out_val, ma_out_val, ma_out_val
	smlabb	ma1_s0_val, ma_in_val, ma1_b_val, ma1_s1_val
	mov		ma1_s1_val, #32768
	qadd	ma_out_val, ma_out_val, ma_out_val
	qadd	ma_out_val, ma_out_val, ma_out_val
	qadd	ma_out_val, ma_out_val, ma1_s1_val
	mov		ma_out_val, ma_out_val, asr #16
	sub		ma_order, ma_order, #3
	ldr		ma1_s1_val, [ma1_s, #4]
	strh	ma_out_val, [ma1_out], #2
	ldrsh	ma1_b0_val,  [ma1_b], #2

L(1)	
	smlabb	ma1_s2_val, ma_in_val, ma1_b0_val, ma1_s1_val
	ldr		ma1_s1_val, [ma1_s, #8]
	ldrsh	ma1_b0_val,  [ma1_b], #2
	str		ma1_s2_val, [ma1_s], #4
	subs	ma_order, ma_order, #1
	bgt		LR(1, b)
	
	smlabb	ma1_s2_val, ma_in_val, ma1_b0_val, ma1_s1_val
	ldrsh	ma1_b0_val,  [ma1_b], #2
	str		ma1_s2_val, [ma1_s], #4
	smulbb	ma1_s2_val, ma_in_val, ma1_b0_val
	subs	ma_len, ma_len, #1
	str		ma1_s2_val, [ma1_s]
	bgt		LR(0, b)
	
	ldr		r2, [sp, #SAVE_S]
	str		ma1_s0_val, [r2, #-4]
	add		sp, sp, #16
	ldmia	sp!,  {r4-r10, fp, ip, pc}


/*
 * void SKP_Silk_MA_Prediction_Q13(
 *	const SKP_int16		*in,			 I:	input signal								
 *  const SKP_int16		*B,				 I:	MA coefficients, Q13 [order+1]				
 *	SKP_int32			*S,				 I/O: state vector [order]						
 *	SKP_int16			*out,			 O:	output signal								
 *	const SKP_int32		len,			 I:	signal length								
 *	const SKP_int32		order			 I:	filter order								
 *	)
 *
 *
 */

	VARDEF maq13_s, ip 
	VARDEF maq13_b, lr 
	VARDEF maq13_in, sb
	VARDEF maq13_out, sl
	VARDEF maq13_in_val, r0
	VARDEF maq13_out_val, r1
	VARDEF maq13_order, r5
	VARDEF maq13_len, r4
	VARDEF maq13_s1, r1
	VARDEF maq13_s2, r2
	VARDEF maq13_s3, r3
	VARDEF maq13_b1, r6
	VARDEF maq13_s1_new, _r7
	VARDEF maq13_s2_new, r8
ALIGN 4
.set	SAVE_IN, 0 
.set	SAVE_B, 4 
.set	SAVE_S, 8 
.set	SAVE_OUT, 12 
.globl	SYM(SKP_Silk_MA_Prediction_Q13_arm5)
SYM(SKP_Silk_MA_Prediction_Q13_arm5):
	stmdb	sp!,  {r4-r10, fp, ip, lr}
	add		fp, sp, #36
	sub		sp, sp, #16
.set	arg_len, 56 
.set	arg_order, 60 
	
/*LOAD INPUT ARGS*/	
	ldr		maq13_order, [sp, #arg_order]
	ldr		maq13_len, [sp, #arg_len]
	ands	_r7, r1, #3
	bne		LR(2, f)/*MA_Prediction_Q13_ORDER_2BYTE*/
	ands	r6, r5, #1
	bne		LR(2, f)/*MA_Prediction_Q13_ORDER_2BYTE*/
	cmp		r5, #6					
	blt		LR(2, f)/*MA_Prediction_Q13_ORDER_2BYTE*/
//	order % 2 == 0
	str		r0, [sp, #SAVE_IN]
	str		r1, [sp, #SAVE_B]
	str		r2, [sp, #SAVE_S]
	str		r3, [sp, #SAVE_OUT]
	
	mov		maq13_in, r0
	mov		maq13_out, r3
	
L(0)
	ldr		maq13_s, [sp, #SAVE_S]
	ldr		maq13_b, [sp, #SAVE_B]
	ldrsh	maq13_in_val, [maq13_in], #2
	ldr		maq13_s1, [maq13_s], #4
	ldr		maq13_order, [sp, #arg_order]
	ldr		maq13_s2, [maq13_s], #4
	rsb		maq13_s3, maq13_s1, maq13_in_val, lsl #13
	ldr		maq13_b1, [maq13_b], #4
	
	qadd	maq13_out_val, maq13_s3, maq13_s3
	sub		maq13_order, maq13_order, #4
	mov		r3, #32768
	qadd	maq13_out_val, maq13_out_val, maq13_out_val
	qadd	maq13_out_val, maq13_out_val, maq13_out_val
	qadd	maq13_out_val, maq13_out_val, r3
	ldr		maq13_s3, [maq13_s], #4
	mov		maq13_out_val, maq13_out_val, asr #16

	strh	maq13_out_val, [maq13_out], #2
L(1)
	smlabb	maq13_s1_new, maq13_in_val, maq13_b1, maq13_s2
	smlabt	maq13_s2_new, maq13_in_val, maq13_b1, maq13_s3
	ldr		maq13_s2, [maq13_s], #4
	ldr		maq13_s3, [maq13_s], #-16
	ldr		maq13_b1, [maq13_b], #4
	subs	maq13_order, maq13_order, #2
	str		maq13_s1_new, [maq13_s], #4
	str		maq13_s2_new, [maq13_s], #16
	bgt		LR(1, b)
	
	smlabb	maq13_s1_new, maq13_in_val, maq13_b1, maq13_s2
	smlabt	maq13_s2_new, maq13_in_val, maq13_b1, maq13_s3
	ldr		maq13_s2, [maq13_s], #-12
	ldr		maq13_b1, [maq13_b]
	str		maq13_s1_new, [maq13_s], #4
	str		maq13_s2_new, [maq13_s], #4
	
	smlabb	maq13_s1_new, maq13_in_val, maq13_b1, maq13_s2
	smulbt	maq13_s2_new, maq13_in_val, maq13_b1
	subs	maq13_len, maq13_len, #1
	str		maq13_s1_new, [maq13_s], #4
	str		maq13_s2_new, [maq13_s]
	bgt		LR(0, b)
	
	add		sp, sp, #16
	ldmia	sp!,  {r4-r10, fp, ip, pc}


	VARDEF ma1q13_s, r8 
	VARDEF ma1q13_b, _r7
	VARDEF ma1q13_in, r6
	VARDEF ma1q13_out, sb
	VARDEF ma1q13_s1, r3
	VARDEF ma1q13_s0, r2
	VARDEF ma1q13_b1, r1
	VARDEF ma1q13_b_tmp, r2

//	order % 2 != 0 	
/*MA_Prediction_Q13_ORDER_2BYTE:	*/
L(2)
	add		r2, r2, #4
	str		r0, [sp, #SAVE_IN]
	str		r1, [sp, #SAVE_B]
	str		r2, [sp, #SAVE_S]
	str		r3, [sp, #SAVE_OUT]
	
	mov		ma1q13_in, r0
	mov		ma1q13_out, r3
	ldr		lr, [r2, #-4]

L(0)
	ldrsh	maq13_in_val, [ma1q13_in], #2
	ldr		maq13_order, [sp, #arg_order]
	ldr		ma1q13_b, [sp, #SAVE_B]
	ldr		ma1q13_s, [sp, #SAVE_S]	
	rsb		maq13_out_val, lr, maq13_in_val, lsl #13
	ldrsh	ma1q13_b_tmp, [ma1q13_b], #2
	qadd	maq13_out_val, maq13_out_val, maq13_out_val
	ldr		ma1q13_s1, [ma1q13_s]
	qadd	maq13_out_val, maq13_out_val, maq13_out_val
	smlabb	lr, maq13_in_val, ma1q13_b_tmp, ma1q13_s1
	mov		r3, #32768
	qadd	maq13_out_val, maq13_out_val, maq13_out_val
	qadd	maq13_out_val, maq13_out_val, r3
	mov		maq13_out_val, maq13_out_val, asr #16
	sub		maq13_order, maq13_order, #3
	ldr		ma1q13_s1, [ma1q13_s, #4]
	strh	maq13_out_val, [sb], #2
	ldrsh	ma1q13_b1, [ma1q13_b], #2

L(1)	
	smlabb	ma1q13_s0, maq13_in_val, ma1q13_b1, ma1q13_s1
	ldr		ma1q13_s1, [ma1q13_s, #8]
	ldrsh	ma1q13_b1, [ma1q13_b], #2
	str		ma1q13_s0, [ma1q13_s], #4
	subs	maq13_order, maq13_order, #1
	bgt		LR(1, b)
	
	smlabb	ma1q13_s0, maq13_in_val, ma1q13_b1, ma1q13_s1
	ldrsh	ma1q13_b1, [ma1q13_b], #2
	str		ma1q13_s0, [ma1q13_s], #4
	smulbb	ma1q13_s0, maq13_in_val, ma1q13_b1
	subs	maq13_len, maq13_len, #1
	str		ma1q13_s0, [ma1q13_s]
	bgt		LR(0, b)
	
	ldr		r2, [sp, #SAVE_S]
	str		lr, [r2, #-4]
	
	add		sp, sp, #16
	ldmia	sp!,  {r4-r10, fp, ip, pc}

#endif

#if EMBEDDED_ARM>=5

#define	SKP_Silk_MAX_ORDER_LPC 16
ALIGN 4
.set	sp_B, 0 
.set	sp_pin, 32 
.set	sp_pB, 36 
.set	sp_pS, 40 
.set	sp_pout, 44 
.globl	SYM(SKP_Silk_LPC_analysis_filter)
SYM(SKP_Silk_LPC_analysis_filter):
	stmdb	sp!,  {r4-r10, fp, ip, lr}
	add		fp, sp, #36
	sub		sp, sp, #48
.set	arg_len, 88 
.set	arg_Order, 92 
	VARDEF len, r4
	VARDEF order, r5
	VARDEF S_val, r6
	VARDEF B_val, _r7
	VARDEF S_tmp1, r8
	VARDEF S_tmp2, sb
	VARDEF out32, sl
// Registers not used in main inner loop
	VARDEF in, r6
	VARDEF in_Q12, _r7
	VARDEF B_tmp, r6
	VARDEF pB_tmp, _r7
	str		r0, [sp, #sp_pin]
	str		r1, [sp, #sp_pB]
	str		r2, [sp, #sp_pS]
	str		r3, [sp, #sp_pout]	
	ldr		len, [sp, #arg_len]
	ldr		order, [sp, #arg_Order]
/*B_ALIGNMENT:*/	
	tst		r1, #0x3
	beq		LR(3, f)/*S_ALIGNMENT*/
	ldrh	B_tmp, [r1], #2
	add		pB_tmp, sp, #sp_B
	sub		order, order, #1
L(0)
	subs	order, order, #1
	strh	B_tmp, [pB_tmp]
	ldrh	B_tmp, [r1], #2
	bgt		LR(0, b)
	ldr		order, [sp, #arg_Order]
	strh	B_tmp, [pB_tmp]
	add		r1, sp, #sp_B						//R1 aligned pointer to B.
/*S_ALIGNMENT:*/
L(3)
	tst		r2, #0x3
	bne		LR(4, f)/*MAIN_FORLOOP1*/
/*MAIN_FORLOOP0:	*/
L(0)
	mov		out32, #0
	ldr		order, [sp, #arg_Order]
/*MAIN_INNER_FORLOOP0:*/
	ldr		S_val, [r2], #2
	ldr		B_val, [r1], #4
	sub		order, order, #4
	mov		S_tmp2, S_val, lsr #16
	strh	S_val, [r2], #2
	SKP_SMLAD	out32, B_val, S_val, out32
	ldr		S_val, [r2]
L(1)
	ldr		B_val, [r1], #4
	add		S_tmp2, S_tmp2, S_val, lsl #16
	ldr		S_tmp1, [r2, #4]
	subs	order, order, #2
	str		S_tmp2, [r2], #4	
	SKP_SMLAD	out32, B_val, S_val, out32
	mov		S_tmp2, S_val, lsr #16
	mov		S_val, S_tmp1
	bgt		LR(1, b)
	ldr		B_val, [r1]
	add		S_tmp2, S_tmp2, S_val, lsl #16
	SKP_SMLAD	out32, B_val, S_val, out32
	str		S_tmp2, [r2]
	
	ldrsh	in, [r0], #2
	ldr		r2, [sp, #sp_pS]
	ldr		r1, [sp, #sp_pB]
	mov		in_Q12, in, lsl #12
	qsub	out32, in_Q12, out32
	mov		out32, out32, asr #11
	strh	in, [r2]
	add		out32, out32, #1
#if EMBEDDED_ARM >=6
	ssat	out32, #16, out32, asr #1
#else	
	mov		out32, out32, asr #1
	cmp		out32, #0x8000
	mvnge	out32, #0x8000
	subge	out32, out32, #1
	cmn		out32, #0x8000
	movlt	out32, #0x8000
#endif
	subs	len, len, #1
	strh	out32, [r3], #2
	bgt		LR(0, b)
	add		sp, sp, #48
	ldmia	sp!,  {r4-r10, fp, ip, pc}

/*MAIN_FORLOOP1:	//pS&3!=0*/
L(4)
L(0)
	mov		out32, #0
	ldr		order, [sp, #arg_Order]
/*MAIN_INNER_FORLOOP1:*/
	ldrh	S_val, [r2], #2
	ldr		S_tmp1, [r2]
	ldr		S_tmp2, [r2, #4]
	ldr		B_val, [r1], #4
	sub		order, order, #4
	add		S_val, S_val, S_tmp1, lsl #16
	mov		S_tmp1, S_tmp1, lsr #16
	str		S_val, [r2], #4
	SKP_SMLAD	out32, B_val, S_val, out32
L(1)
	ldr		B_val, [r1], #4
	add		S_val, S_tmp1, S_tmp2, lsl #16
	mov		S_tmp1, S_tmp2, lsr #16
	subs	order, order, #2
#ifdef _WINRT
	ble		LR(2, f)
	ldr		S_tmp2, [r2, #4]
L(2)	
#else	
	ldrgt	S_tmp2, [r2, #4]
#endif	
	str		S_val, [r2], #4	
	SKP_SMLAD	out32, B_val, S_val, out32
	bgt		LR(1, b)
	ldrsh	S_tmp2, [r2]
	ldr		B_val, [r1]
	add		S_val, S_tmp1, S_tmp2, lsl #16
	SKP_SMLAD	out32, B_val, S_val, out32
	strh	S_val, [r2]
	
	ldrsh	in, [r0], #2
	ldr		r2, [sp, #sp_pS]
	ldr		r1, [sp, #sp_pB]
	mov		in_Q12, in, lsl #12
	qsub	out32, in_Q12, out32
	mov		out32, out32, asr #11
	strh	in, [r2]
	add		out32, out32, #1
#if EMBEDDED_ARM >=6
	ssat	out32, #16, out32, asr #1
#else	
	mov		out32, out32, asr #1
	cmp		out32, #0x8000
	mvnge	out32, #0x8000
	subge	out32, out32, #1
	cmn		out32, #0x8000
	movlt	out32, #0x8000
#endif
	subs	len, len, #1
	strh	out32, [r3], #2
	bgt		LR(0, b)
	
	add		sp, sp, #48
	ldmia	sp!,  {r4-r10, fp, ip, pc}
	END
#endif
#endif
