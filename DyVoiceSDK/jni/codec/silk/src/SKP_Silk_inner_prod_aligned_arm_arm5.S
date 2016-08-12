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
#if EMBEDDED_ARM >=5 

/*
 *	SKP_Silk_inner_prod_aligned(val1_16bit[], val2_16bit[], len)
 *	
 *	Known issue: 
 *		1. val1_16bit and val2_16bit needs to be 16bit aligned. 
 *		2. result is in 32bit, no saturation, wrap around instead.
 */
	VARDEF sum, r0
	VARDEF val_p1, r1
	VARDEF val_p2, r2
	VARDEF len, r3
	VARDEF val1, r4
	VARDEF val2, r5
	VARDEF val3, r6

#ifdef IPHONE
	VARDEF val4, r8
	VARDEF tmp, sb
	VARDEF val5, sl
	VARDEF val6, _r7
	VARDEF val7, lr
	VARDEF val8, ip
#else
	VARDEF val4, _r7
	VARDEF tmp, r8
	VARDEF val5, sb
	VARDEF val6, sl
	VARDEF val7, lr
	VARDEF val8, ip
#endif
ALIGN 4
.globl	SYM(SKP_Silk_inner_prod_aligned_arm5)
SYM(SKP_Silk_inner_prod_aligned_arm5):
	stmdb	sp!,  {r4-r10, fp, ip, lr}
	add		fp, sp, #36

	cmp		r2, #14
	blt		LR(9, f)/*LenLessThan14*/
	
	ands	tmp, r2, #1						/*check if len is a even number*/
	mov		len, r2
	mov		val_p2, r0
	mov		sum, #0
	beq		LR(0, f)/*LenEven*/
	
	ldrsh	val3, [val_p1], #2
	ldrsh	val4, [val_p2], #2
	sub		len, len, #1
	smulbb	sum, val3, val4
/*LenEven:*/
L(0)
	ands	val1, val_p1, #2				/*Check if val_p1 is	LR(4, B) aligned.*/
	bgt		LR(1, f)/*R1Odd*/							
	ands	val2, val_p2, #2				/*Check if val_p2 is	LR(4, B) aligned*/
	bgt		LR(2, f)/*R2Odd*/
	
/*R1R2Even:*/
	ands	tmp, len, #3
	beq		LR(4, f)/*Len4*/
	sub		len, len, #2
	ldr		val1, [val_p1], #4
	ldr		val2, [val_p2], #4
	SKP_SMLAD	sum, val1, val2, sum
L(4)/*Len4:*/
	ands	tmp, len, #7
	beq		LR(8, f)/*Len8*/
	ldmia	val_p1!, {val1, val3}
	ldmia	val_p2!, {val2, val4}
	sub		len, len, #4
	SKP_SMLAD	sum, val1, val2, sum
	SKP_SMLAD	sum, val3, val4, sum

L(8)/*Len8:*/
	ldmia	val_p1!, {val1, val3, val5, val7}
	ldmia	val_p2!, {val2, val4, val6, val8}
L(0)
	subs	len, len, #8	
	SKP_SMLAD	sum, val1, val2, sum
	SKP_SMLAD	sum, val3, val4, sum
	SKP_SMLAD	sum, val5, val6, sum
	SKP_SMLAD	sum, val7, val8, sum
	ldmgtia	val_p1!, {val1, val3, val5, val7}
	ldmgtia	val_p2!, {val2, val4, val6, val8}
	bgt		LR(0, b)	
	ldmia	sp!,  {r4-r10, fp, ip, pc}

L(2)/*R2Odd:*/
	ands	tmp, len, #3
	beq		LR(6, f)/*Len4R2Odd*/
	ldr		val1, [val_p1], #4
	ldrsh	val3, [val_p2], #2
	ldrsh	val4, [val_p2], #2				/*make val_p2 even*/
	sub		len, len, #2
	smlabb	sum, val1, val3, sum
	smlatb	sum, val1, val4, sum
L(6)/*Len4R2Odd:*/
	sub		len, len, #4
	ldrsh	tmp, [val_p2], #2				/*make val_p2 even*/
	ldmia	val_p1!, {val1, val3}
	ldmia	val_p2!, {val2, val4}
	mov		tmp, tmp, lsl #16
L(0)
	subs	len, len, #4	
	smlabt	sum, val1, tmp, sum
	smlatb	sum, val1, val2, sum
	smlabt	sum, val3, val2, sum
	smlatb	sum, val3, val4, sum
	mov		tmp, val4
	ldmia	val_p1!, {val1, val3}
	ldmia	val_p2!, {val2, val4}
	bgt		LR(0, b)	
	smlabt	sum, val1, tmp, sum
	smlatb	sum, val1, val2, sum
	smlabt	sum, val3, val2, sum
	smlatb	sum, val3, val4, sum
	ldmia	sp!,  {r4-r10, fp, ip, pc}
	
L(1)/*R1Odd:*/
	ands	val2, val_p2, #2				/*Check if val_p2 is	LR(4, B) aligned*/
	bgt		LR(3, f)/*R1R2Odd*/
	
	ands	tmp, len, #3
	beq		LR(5, f)/*Len4R1Odd*/
	ldrsh	val1, [val_p1], #2
	ldrsh	val2, [val_p1], #2
	ldr		val3, [val_p2], #4				/*make val_p2 even*/
	sub		len, len, #2
	smlabb	sum, val1, val3, sum
	smlabt	sum, val2, val3, sum
L(5)/*Len4R1Odd:*/
	sub		len, len, #4
	ldrsh	tmp, [val_p1], #2				/*make val_p2 even*/
	ldmia	val_p1!, {val1, val3}
	ldmia	val_p2!, {val2, val4}
	mov		tmp, tmp, lsl #16
L(0)
	subs	len, len, #4	
	smlatb	sum, tmp, val2, sum
	smlabt	sum, val1, val2, sum
	smlatb	sum, val1, val4, sum
	smlabt	sum, val3, val4, sum
	mov		tmp, val3
	ldmia	val_p1!, {val1, val3}
	ldmia	val_p2!, {val2, val4}
	bgt		LR(0, b)	
	smlatb	sum, tmp, val2, sum
	smlabt	sum, val1, val2, sum
	smlatb	sum, val1, val4, sum
	smlabt	sum, val3, val4, sum
	ldmia	sp!,  {r4-r10, fp, ip, pc}

L(3)/*R1R2Odd:*/
	sub		len, len, #4
	ldrsh	val3, [val_p1], #2
	ldrsh	val4, [val_p2], #2
	ldr		val1, [val_p1], #4
	ldr		val2, [val_p2], #4
	smlabb	sum, val3, val4, sum
L(0)
	subs	len, len, #2	
	SKP_SMLAD	sum, val1, val2, sum
	ldr		val1, [val_p1], #4
	ldr		val2, [val_p2], #4
	bgt		LR(0, b)	
	ldrsh	val3, [val_p1], #2
	ldrsh	val4, [val_p2], #2
	SKP_SMLAD	sum, val1, val2, sum
	smlabb	sum, val3, val4, sum	
	ldmia	sp!,  {r4-r10, fp, ip, pc}
	
L(9)/*LenLessThan14:*/
	mov		len, r2
	mov		val_p2, r0
	mov		sum, #0
L(0)
	ldrsh	val1, [val_p1], #2
	ldrsh	val2, [val_p2], #2
	subs	len, len, #1
	smlabb	sum, val1, val2, sum
	bgt		LR(0, b)
	ldmia	sp!,  {r4-r10, fp, ip, pc}

/*
 *	SKP_Silk_inner_prod16_aligned_64(val1_16bit[], val2_16bit[], len)
 *	
 *	Known issue: 
 *		1. val1_16bit and val2_16bit needs to be 16bit aligned. 
 *		2. result is in 64bit.
 */

// only redefine those registers. 
	VARDEF sumLo, r0
	VARDEF sumHi, r1

#ifdef IPHONE
	VARDEF val_p3, sl
	VARDEF val_5, sb
	VARDEF val_6, _r7
	VARDEF val_7, lr
	VARDEF val_8, ip
#else
	VARDEF val_p3, sb
	VARDEF val_5, r8
	VARDEF val_6, sl
	VARDEF val_7, lr
	VARDEF val_8, ip
#endif

ALIGN 4
.globl	SYM(SKP_Silk_inner_prod16_aligned_64_arm5)
SYM(SKP_Silk_inner_prod16_aligned_64_arm5):
	stmdb	sp!,  {r4-r10, fp, ip, lr}
	add		fp, sp, #36
	
	cmp			r2, #14
	blt			LR(9, f)/*LenLessThan14_64*/
	
	ands		tmp, r2, #1						/*check if len is a even number*/
	mov			len, r2
	mov			val_p2, r0
	mov			val_p3, r1
	mov			sumLo, #0
	mov			sumHi, #0
	beq			LR(0, f)/*LenEven64*/
	
	ldrsh		val3, [val_p3], #2
	ldrsh		val4, [val_p2], #2
	sub			len, len, #1
	smlalbb		sumLo, sumHi, val3, val4
L(0)/*LenEven64:*/
	ands		val1, val_p3, #2				/*Check if val_p3 is	LR(4, B) aligned.*/
	bgt			LR(1, f)/*R1Odd64*/							
	ands		val2, val_p2, #2				/*Check if val_p2 is	LR(4, B) aligned*/
	bgt			LR(2, f)/*R2Odd64*/
/*R1R2Even64:*/			
	ands		tmp, len, #3
	beq			LR(4, f)/*Len464*/
	sub			len, len, #2
	ldr			val1, [val_p3], #4
	ldr			val2, [val_p2], #4
	SKP_SMLALD	sumLo, sumHi, val1, val2
	
L(4)/*Len464:*/	
	ands		tmp, len, #7
	beq			LR(8, f)/*Len864*/
	sub			len, len, #4
	ldmia		val_p3!, {val1, val3}
	ldmia		val_p2!, {val2, val4}
	SKP_SMLALD	sumLo, sumHi, val1, val2
	SKP_SMLALD	sumLo, sumHi, val3, val4
	
L(8)/*Len864:*/	
	ldmia		val_p3!, {val1, val3, val_5, val_7}
	ldmia		val_p2!, {val2, val4, val_6, val_8}
L(0)
	subs		len, len, #8	
	SKP_SMLALD	sumLo, sumHi, val1, val2
	SKP_SMLALD	sumLo, sumHi, val3, val4
	SKP_SMLALD	sumLo, sumHi, val_5, val_6
	SKP_SMLALD	sumLo, sumHi, val_7, val_8
	ldmgtia		val_p3!, {val1, val3, val_5, val_7}
	ldmgtia		val_p2!, {val2, val4, val_6, val_8}
	bgt			LR(0, b)	
	ldmia	sp!,  {r4-r10, fp, ip, pc}

L(2)/*R2Odd64:*/
	sub			len, len, #2
	sub			val_p2, val_p2, #2				/*make val_p2 even*/
	ldr			val1, [val_p3], #4
	ldr			val3, [val_p2], #4
	ldr			val2, [val_p2], #4
L(0)
	subs		len, len, #2	
	smlalbt		sumLo, sumHi, val1, val3
	smlaltb		sumLo, sumHi, val1, val2
	mov			val3, val2
	ldr			val1, [val_p3], #4
	ldr			val2, [val_p2], #4
	bgt			LR(0, b)	
	smlalbt		sumLo, sumHi, val1, val3
	smlaltb		sumLo, sumHi, val1, val2
	ldmia	sp!,  {r4-r10, fp, ip, pc}

L(1)/*R1Odd64:*/
	ands		val2, r2, #2					/*Check if val_p2 is	LR(4, B) aligned*/
	bgt			LR(3, f)/*R1R2Odd64*/
	sub			len, len, #2
	sub			val_p3, val_p3, #2				/*make val_p3 even*/
	ldr			val3, [val_p3], #4
	ldr			val1, [val_p3], #4
	ldr			val2, [val_p2], #4
L(0)
	subs		len, len, #2	
	smlaltb		sumLo, sumHi, val3, val2
	smlalbt		sumLo, sumHi, val1, val2
	mov			val3, val1
	ldr			val1, [val_p3], #4
	ldr			val2, [val_p2], #4
	bgt			LR(0, b)	
	smlaltb		sumLo, sumHi, val3, val2
	smlalbt		sumLo, sumHi, val1, val2
	ldmia	sp!,  {r4-r10, fp, ip, pc}

L(3)/*R1R2Odd64:*/
	sub			len, len, #4
	ldrsh		val3, [val_p3], #2
	ldrsh		val4, [val_p2], #2
	ldr			val1, [val_p3], #4
	ldr			val2, [val_p2], #4
	smlalbb		sumLo, sumHi, val3, val4
L(0)
	subs		len, len, #2	
	SKP_SMLALD		sumLo, sumHi, val1, val2
	ldr			val1, [val_p3], #4
	ldr			val2, [val_p2], #4
	bgt			LR(0, b)	
	ldrsh		val3, [val_p3], #2
	ldrsh		val4, [val_p2], #2
	SKP_SMLALD		sumLo, sumHi, val1, val2
	smlalbb		sumLo, sumHi, val3, val4
	ldmia	sp!,  {r4-r10, fp, ip, pc}
	
L(9)/*LenLessThan14_64:*/
	mov			len, r2
	mov			val_p2, r0
	mov			val_p3, r1
	mov			sumLo, #0
	mov			sumHi, #0
L(0)
	ldrsh		val1, [val_p3], #2
	ldrsh		val2, [val_p2], #2
	subs		len, len, #1
	smlalbb		sumLo, sumHi, val1, val2
	bgt			LR(0, b)
	ldmia	sp!,  {r4-r10, fp, ip, pc}
#endif	
	END
#endif
