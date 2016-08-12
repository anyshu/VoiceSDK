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
#if ( EMBEDDED_ARM >= 7 )

	VARDEF len32, r3
	VARDEF len32tmp, lr
	VARDEF ptr1, r2
	VARDEF ptr2, r1
	VARDEF tmp1, r4
	VARDEF tmp2, r5

	VARDEFD val_0, d0
	VARDEFD val_1, d1
	VARDEFD val_2, d2
	VARDEFD val_3, d3
	VARDEFQ sum_tmp1, q2
	VARDEFQ sum_tmp2, q3
	VARDEFD sum_tmp1_lo, d4
	VARDEFD sum_tmp1_hi, d5
ALIGN 4
.globl	SYM(SKP_Silk_inner_prod_aligned_neon)
SYM(SKP_Silk_inner_prod_aligned_neon):
	stmdb	sp!,  {r4-r10, fp, ip, lr}
	vpush	{q0-q7}
	add		fp, sp, #164
	mov			len32, r2								//	put length into r3
	mov			ptr1, r0								//  put in1 to r2
	mov			r0, #0								//	put result to r0	
//	USE SL8D, SI4D
L(2)
	cmp			len32, #24
	and			len32tmp, len32, #0x7
	blt			LR(3, f)

	vmov.i32	sum_tmp1, #0
	vld1.16		{val_0, val_1}, [ptr2]!
	vld1.16		{val_2, val_3}, [ptr1]!
	vmov.i32	sum_tmp2, #0								// Set Q2, Q3 to 0
	sub			len32, len32, #16
L(0)	
	subs		len32, len32, #8
	vmlal.s16	sum_tmp1, val_0, val_2
	vmlal.s16	sum_tmp2, val_1, val_3
	vld1.16		{val_0, val_1}, [ptr2]!
	vld1.16		{val_2, val_3}, [ptr1]!
	bge			LR(0, b)
	
	vmlal.s16	sum_tmp1, val_0, val_2
	vmlal.s16	sum_tmp2, val_1, val_3
	vadd.s32	sum_tmp1, sum_tmp1, sum_tmp2
	vadd.s32	val_0, sum_tmp1_lo, sum_tmp1_hi
	vmov		tmp1, tmp2, val_0
	cmp			len32tmp, #0								// Check if length%4 == 0
	add			r0, r0, tmp1
	add			r0, r0, tmp2
	bgt			LR(1, f)									// Jump to process the reminder
	
	vpop	{q0-q7}
	ldmia	sp!,  {r4-r10, fp, ip, pc}
	
	VARDEFQ sum_tmp3, q1
	VARDEFD sum_tmp3_lo, d2
	VARDEFD sum_tmp3_hi, d3
//	USE SL4D, SI4D
L(3)	
	cmp			len32, #12
	and			len32tmp, len32, #0x3
	movlt		len32tmp, len32								//	if length is not enough for SIMD. 
	blt			LR(1, f)
	
	vld1.16		val_0, [ptr2]!
	vld1.16		val_1, [ptr1]!
	vmov.i32	sum_tmp3, #0 
	sub			len32, len32, #8
L(0)	
	subs		len32, len32, #4
	vmlal.s16	sum_tmp3, val_0, val_1
	vld1.16		val_0, [ptr2]!
	vld1.16		val_1, [ptr1]!
	bge			LR(0, b)
	
	vmlal.s16	sum_tmp3, val_0, val_1
	vadd.s32	val_0, sum_tmp3_lo, sum_tmp3_hi
	vmov		tmp1, tmp2, val_0
	cmp			len32tmp, #0								// Check if length%4 == 0
	add			r0, r0, tmp1
	add			r0, r0, tmp2
	bgt			LR(1, f)									// Jump to process the reminder
	
	vpop	{q0-q7}
	ldmia	sp!,  {r4-r10, fp, ip, pc}

	VARDEF tmp0, r3

L(1)
	subs		len32tmp, len32tmp, #1
	ldrsh		tmp0, [ptr2], #2
	ldrsh		tmp1, [ptr1], #2
	beq			LR(2, f)	
L(0)	
	smlabb		r0, tmp0, tmp1, r0	
	ldrsh		tmp0, [ptr2], #2
	ldrsh		tmp1, [ptr1], #2
	subs		len32tmp, len32tmp, #1
	bgt			LR(0, b)

L(2)
	smlabb		r0, tmp0, tmp1, r0
	vpop	{q0-q7}
	ldmia	sp!,  {r4-r10, fp, ip, pc}

	VARDEF len64, r4
	VARDEF len64tmp, lr
	VARDEF ptr00, r2
	VARDEF ptr01, r3
	VARDEFD val0, d0
	VARDEFD val1, d1
	VARDEFD val2, d2
	VARDEFD val3, d3
	VARDEFQ mul0, q2
	VARDEFD mul0_lo, d4
	VARDEFD mul0_hi, d5
	VARDEFQ mul1, q3
	VARDEFD mul1_lo, d6
	VARDEFD mul1_hi, d7
	VARDEFQ accu0, q4
	VARDEFD accu0_lo, d8
	VARDEFD accu0_hi, d9
	VARDEFQ accu1, q5
	VARDEFD accu1_lo, d10
	VARDEFD accu1_hi, d11
ALIGN 4
.globl	SYM(SKP_Silk_inner_prod16_aligned_64_neon)
SYM(SKP_Silk_inner_prod16_aligned_64_neon):
	stmdb	sp!,  {r4-r10, fp, ip, lr}
	vpush	{q0-q7}
	add		fp, sp, #164
	mov			len64, r2
	mov			ptr00, r0
	mov			ptr01, r1
	mov			r0, #0						/*Output*/
	mov			r1, #0

//	USE SL8D, SI4D
L(2)	
	cmp			len64, #24
	and			len64tmp, len64, #0x7
	blt			LR(3, f)
	
	vld1.16		{val0, val1}, [ptr00]!
	vld1.16		{val2, val3}, [ptr01]!
	vmov		accu0_lo, r0, r1 
	vmov		accu0_hi, r0, r1
	vmov		accu1, accu0 
	sub			len64, len64, #16
L(0)	
	vmull.s16	mul0, val0, val2
	vmull.s16	mul1, val1, val3
	vld1.16		{val0, val1}, [ptr00]!
	subs		len64, len64, #8
	//vqadd.s32	mul0, mul0, mul1
	vld1.16		{val2, val3}, [ptr01]!
	vaddw.s32	accu0, accu0, mul0_lo
	vaddw.s32	accu1, accu1, mul0_hi
	vaddw.s32	accu0, accu0, mul1_lo
	vaddw.s32	accu1, accu1, mul1_hi
	bge			LR(0, b)
	
	vmull.s16	mul0, val0, val2
	vmull.s16	mul1, val1, val3
	//vqadd.s32	mul0, mul0, mul1
	vaddw.s32	accu0, accu0, mul0_lo
	vaddw.s32	accu1, accu1, mul0_hi
	vaddw.s32	accu0, accu0, mul1_lo
	vaddw.s32	accu1, accu1, mul1_hi
	vqadd.s64	accu0, accu0, accu1
	vqadd.s64	accu0_lo, accu0_lo, accu0_hi
	vmov		r0, r1, accu0_lo
	cmp			len64tmp, #0								// Check if length%4 == 0
	bgt			LR(1, f)									// Jump to process the reminder
	
	vpop	{q0-q7}
	ldmia	sp!,  {r4-r10, fp, ip, pc}

	VARDEFQ mul2, q1
	VARDEFD mul2_lo, d2
	VARDEFD mul2_hi, d3
	VARDEFQ accu2, q2
	VARDEFD accu2_lo, d4
	VARDEFD accu2_hi, d5
	VARDEFQ accu3, q3

//	USE SL4D, SI4D
L(3)	
	cmp			len64, #12
	and			len64tmp, len64, #0x3
	movlt		len64tmp, len64								//	if length is not enough for SIMD. 
	blt			LR(1, f)
	
	vld1.16		val0, [ptr00]!
	vld1.16		val1, [ptr01]!
	vmov		accu2_lo, r0, r1 
	vmov		accu2_hi, r0, r1
	vmov		accu3, accu2 
	sub			len64, len64, #8
L(0)	
	vmull.s16	mul2, val0, val1
	vld1.16		val0, [ptr00]!
	subs		len64, len64, #4
	vaddw.s32	accu2, accu2, mul2_lo
	vld1.16		val1, [ptr01]!
	vaddw.s32	accu3, accu3, mul2_hi
	bge			LR(0, b)
	
	vmull.s16	mul2, val0, val1
	vaddw.s32	accu2, accu2, mul2_lo
	vaddw.s32	accu3, accu3, mul2_hi
	vqadd.s64	accu2, accu2, accu3
	vqadd.s64	accu2_lo, accu2_lo, accu2_hi
	vmov		r0, r1, accu2_lo
	cmp			len64tmp, #0
	bgt			LR(1, f)
	
	vpop	{q0-q7}
	ldmia	sp!,  {r4-r10, fp, ip, pc}

	VARDEF val4, r4
	VARDEF val5, r5
L(1)
	subs		len64tmp, len64tmp, #1
	ldrsh		val4, [ptr00], #2
	ldrsh		val5, [ptr01], #2
	beq			LR(2, f)	
L(0)	
	smlalbb		r0, r1, val4, val5
	ldrsh		val4, [ptr00], #2
	ldrsh		val5, [ptr01], #2
	subs		len64tmp, len64tmp, #1
	bgt			LR(0, b)

L(2)
	smlalbb		r0, r1, val4, val5
	vpop	{q0-q7}
	ldmia	sp!,  {r4-r10, fp, ip, pc}

#endif
	END
#endif
