; Hovertank 3-D Source Code
; Copyright (C) 1993-2014 Flat Rock Software
;
; This program is free software; you can redistribute it and/or modify
; it under the terms of the GNU General Public License as published by
; the Free Software Foundation; either version 2 of the License, or
; (at your option) any later version.
;
; This program is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.
;
; You should have received a copy of the GNU General Public License along
; with this program; if not, write to the Free Software Foundation, Inc.,
; 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

	ifndef	??version
?debug	macro
	endm
publicdll macro	name
	public	name
	endm
$comm	macro	name,dist,size,count
	comm	dist name:BYTE:count*size
	endm
	else
$comm	macro	name,dist,size,count
	comm	dist name[size]:BYTE:count
	endm
	endif
	?debug	S "jm_sb.c"
	?debug	C E9573E9E16076A6D5F73622E63
	?debug	C E900104D1613433A5C42435C494E434C5544455C646F732E68
	?debug	C E9DB749D16076A6D5F73622E68
	?debug	C E978749D16046A6D2E68
_TEXT	segment byte public 'CODE'
_TEXT	ends
DGROUP	group	_DATA,_BSS
	assume	cs:_TEXT,ds:DGROUP
_DATA	segment word public 'DATA'
d@	label	byte
d@w	label	word
_DATA	ends
_BSS	segment word public 'BSS'
b@	label	byte
b@w	label	word
_BSS	ends
_DATA	segment word public 'DATA'
sbSamplePlaying	label	word
	db	0
	db	0
sbOldIntMask	label	byte
	db	255
sbLocation	label	word
	db	255
	db	255
sbInterrupt	label	word
	db	7
	db	0
sbIntVec	label	word
	db	15
	db	0
sbIntVectors	label	word
	db	255
	db	255
	db	255
	db	255
	db	10
	db	0
	db	11
	db	0
	db	255
	db	255
	db	13
	db	0
	db	255
	db	255
	db	15
	db	0
_DATA	ends
_TEXT	segment byte public 'CODE'
   ;	
   ;	static void
   ;	
	assume	cs:_TEXT
jmDelay	proc	near
	push	bp
	mov	bp,sp
	push	si
	push	di
	mov	di,word ptr [bp+4]
	jmp	short @1@122
@1@50:
   ;	
   ;	jmDelay(int usec)
   ;	{
   ;	// DEBUG - use real timing routines
   ;		int	i;
   ;	
   ;		while (usec--)
   ;	
	xor	si,si
	jmp	short @1@98
@1@74:
	inc	si
@1@98:
	cmp	si,1000
	jl	short @1@74
@1@122:
	mov	ax,di
	dec	di
	or	ax,ax
	jne	short @1@50
   ;	
   ;			for (i = 0;i < 1000;i++)
   ;				;
   ;	
	pop	di
	pop	si
	pop	bp
	ret	
jmDelay	endp
   ;	
   ;	static longword
   ;	
	assume	cs:_TEXT
jmPlaySeg	proc	near
	push	bp
	mov	bp,sp
	sub	sp,10
   ;	
   ;	jmPlaySeg(byte huge *data,longword length)
   ;	{
   ;		unsigned		datapage;
   ;		longword		dataofs,uselen;
   ;	
   ;	
	mov	ax,word ptr [bp+10]
	mov	dx,word ptr [bp+8]
	mov	word ptr [bp-8],ax
	mov	word ptr [bp-10],dx
   ;	
   ;		uselen = length;
   ;	
	mov	ax,word ptr [bp+6]
	mov	cl,12
	shr	ax,cl
	mov	word ptr [bp-2],ax
   ;	
   ;		datapage = FP_SEG(data) >> 12;
   ;	
	mov	ax,word ptr [bp+6]
	and	ax,4095
	mov	cl,4
	shl	ax,cl
	add	ax,word ptr [bp+4]
	mov	word ptr [bp-4],0
	mov	word ptr [bp-6],ax
   ;	
   ;		dataofs = ( (FP_SEG(data)&0xfff)<<4 ) + FP_OFF(data);
   ;	
	cmp	word ptr [bp-4],1
	jb	short @2@122
	jne	short @2@98
	cmp	word ptr [bp-6],0
	jb	short @2@122
@2@98:
   ;	
   ;		if (dataofs>=0x10000)
   ;		{
   ;	
	inc	word ptr [bp-2]
   ;	
   ;		  datapage++;
   ;	
	sub	word ptr [bp-6],0
	sbb	word ptr [bp-4],1
@2@122:
   ;	
   ;		  dataofs-=0x10000;
   ;		}
   ;	
   ;	
	mov	ax,word ptr [bp-4]
	mov	dx,word ptr [bp-6]
	add	dx,word ptr [bp-10]
	adc	ax,word ptr [bp-8]
	cmp	ax,1
	jb	short @2@218
	ja	short @2@194
	or	dx,dx
	jbe	short @2@218
@2@194:
   ;	
   ;		if (dataofs + uselen > 0x10000)
   ;	
	mov	ax,1
	xor	dx,dx
	sub	dx,word ptr [bp-6]
	sbb	ax,word ptr [bp-4]
	mov	word ptr [bp-8],ax
	mov	word ptr [bp-10],dx
@2@218:
   ;	
   ;			uselen = 0x10000 - dataofs;
   ;	
   ;	
	sub	word ptr [bp-10],1
	sbb	word ptr [bp-8],0
   ;	
   ;		uselen--;	// DEBUG
   ;	
   ;		// Program the DMA controller
   ;	
	mov	dx,10
	mov	al,5
	out	dx,al
   ;	
   ;		outportb(0x0a,5);							// Mask off channel 1 DMA
   ;	
	mov	dx,12
	mov	al,0
	out	dx,al
   ;	
   ;		outportb(0x0c,0);							// Clear byte ptr F/F to lower byte
   ;	
	mov	dx,11
	mov	al,73
	out	dx,al
   ;	
   ;		outportb(0x0b,0x49);						// Set transfer mode for D/A conv
   ;	
	mov	dx,2
	mov	al,byte ptr [bp-6]
	out	dx,al
   ;	
   ;		outportb(0x02,(byte)dataofs);				// Give LSB of address
   ;	
	mov	dx,word ptr [bp-4]
	mov	ax,word ptr [bp-6]
	mov	cl,8
	call	near ptr N_LXURSH@
	mov	dx,2
	out	dx,al
   ;	
   ;		outportb(0x02,(byte)(dataofs >> 8));		// Give MSB of address
   ;	
	mov	dx,131
	mov	al,byte ptr [bp-2]
	out	dx,al
   ;	
   ;		outportb(0x83,(byte)datapage);				// Give page of address
   ;	
	mov	dx,3
	mov	al,byte ptr [bp-10]
	out	dx,al
   ;	
   ;		outportb(0x03,(byte)uselen);				// Give LSB of length
   ;	
	mov	dx,word ptr [bp-8]
	mov	ax,word ptr [bp-10]
	mov	cl,8
	call	near ptr N_LXURSH@
	mov	dx,3
	out	dx,al
   ;	
   ;		outportb(0x03,(byte)(uselen >> 8));			// Give MSB of length
   ;	
	mov	dx,10
	mov	al,1
	out	dx,al
	jmp	short @2@242
@2@242:
   ;	
   ;		outportb(0x0a,1);							// Turn on channel 1 DMA
   ;	
   ;		// Start playing the thing
   ;	
	mov	dx,word ptr DGROUP:sbLocation
	add	dx,524
	in	al,dx
	mov	ah,0
	test	ax,128
	jne	short @2@242
   ;	
   ;		sbWriteDelay();
   ;	
	mov	dx,word ptr DGROUP:sbLocation
	add	dx,524
	mov	al,20
	out	dx,al
	jmp	short @2@290
@2@290:
   ;	
   ;		sbOut(sbWriteCmd,0x14);
   ;	
	mov	dx,word ptr DGROUP:sbLocation
	add	dx,524
	in	al,dx
	mov	ah,0
	test	ax,128
	jne	short @2@290
   ;	
   ;		sbWriteDelay();
   ;	
	mov	dx,word ptr DGROUP:sbLocation
	add	dx,524
	mov	al,byte ptr [bp-10]
	out	dx,al
	jmp	short @2@338
@2@338:
   ;	
   ;		sbOut(sbWriteData,(byte)uselen);
   ;	
	mov	dx,word ptr DGROUP:sbLocation
	add	dx,524
	in	al,dx
	mov	ah,0
	test	ax,128
	jne	short @2@338
   ;	
   ;		sbWriteDelay();
   ;	
	mov	dx,word ptr [bp-8]
	mov	ax,word ptr [bp-10]
	mov	cl,8
	call	near ptr N_LXURSH@
	mov	dx,word ptr DGROUP:sbLocation
	add	dx,524
	out	dx,al
   ;	
   ;		sbOut(sbWriteData,(byte)(uselen >> 8));
   ;	
   ;	
	add	word ptr [bp-10],1
	mov	ax,word ptr [bp-10]
	adc	word ptr [bp-8],0
	mov	dx,word ptr [bp-8]
	jmp	short @2@386
@2@386:
   ;	
   ;		return(++uselen);
   ;	
	mov	sp,bp
	pop	bp
	ret	
jmPlaySeg	endp
   ;	
   ;	void interrupt
   ;	
	assume	cs:_TEXT
_jmSBService	proc	far
	push	ax
	push	bx
	push	cx
	push	dx
	push	es
	push	ds
	push	si
	push	di
	push	bp
	mov	bp,DGROUP
	mov	ds,bp
	mov	bp,sp
	sub	sp,4
   ;	
   ;	jmSBService(void)
   ;	{
   ;		longword	used;
   ;	
   ;	
	mov	dx,word ptr DGROUP:sbLocation
	add	dx,526
	in	al,dx
   ;	
   ;		sbIn(sbDataAvail);
   ;	
	mov	dx,32
	mov	al,32
	out	dx,al
   ;	
   ;		outportb(0x20,0x20);
   ;	
   ;	
	xor	cx,cx
	xor	bx,bx
	mov	dx,word ptr DGROUP:sbNextSegPtr+2
	mov	ax,word ptr DGROUP:sbNextSegPtr
	call	near ptr N_PCMP@
	je	short @3@194
   ;	
   ;		if (sbNextSegPtr)
   ;		{
   ;	
	push	word ptr DGROUP:sbNextSegLen+2
	push	word ptr DGROUP:sbNextSegLen
	push	word ptr DGROUP:sbNextSegPtr+2
	push	word ptr DGROUP:sbNextSegPtr
	call	near ptr jmPlaySeg
	add	sp,8
	mov	word ptr [bp-2],dx
	mov	word ptr [bp-4],ax
   ;	
   ;			used = jmPlaySeg(sbNextSegPtr,sbNextSegLen);
   ;	
	mov	ax,word ptr DGROUP:sbNextSegLen+2
	mov	dx,word ptr DGROUP:sbNextSegLen
	cmp	ax,word ptr [bp-2]
	ja	short @3@146
	jne	short @3@122
	cmp	dx,word ptr [bp-4]
	ja	short @3@146
@3@122:
   ;	
   ;			if (sbNextSegLen <= used)
   ;	
	mov	word ptr DGROUP:sbNextSegPtr+2,0
	mov	word ptr DGROUP:sbNextSegPtr,0
	jmp	short @3@170
@3@146:
   ;	
   ;				sbNextSegPtr = nil;
   ;			else
   ;			{
   ;	
	mov	cx,word ptr [bp-2]
	mov	bx,word ptr [bp-4]
	mov	dx,ds
	mov	ax,offset DGROUP:sbNextSegPtr
	call	near ptr N_PADA@
   ;	
   ;				sbNextSegPtr += used;
   ;	
	mov	ax,word ptr [bp-2]
	mov	dx,word ptr [bp-4]
	sub	word ptr DGROUP:sbNextSegLen,dx
	sbb	word ptr DGROUP:sbNextSegLen+2,ax
@3@170:
   ;	
   ;				sbNextSegLen -= used;
   ;			}
   ;	
	jmp	short @3@218
@3@194:
   ;	
   ;		}
   ;		else
   ;	
	call	near ptr _jmStopSample
@3@218:
   ;	
   ;			jmStopSample();
   ;	
	mov	sp,bp
	pop	bp
	pop	di
	pop	si
	pop	ds
	pop	es
	pop	dx
	pop	cx
	pop	bx
	pop	ax
	iret	
_jmSBService	endp
   ;	
   ;	void
   ;	
	assume	cs:_TEXT
_jmPlaySample	proc	near
	push	bp
	mov	bp,sp
	sub	sp,24
	push	si
	mov	si,word ptr [bp+4]
   ;	
   ;	jmPlaySample(sound)
   ;		int	sound;
   ;	{
   ;		byte			huge *data,
   ;						timevalue;
   ;		longword		used;
   ;		SampledSound	sample;
   ;	
   ;	
	call	near ptr _jmStopSample
   ;	
   ;		jmStopSample();
   ;	
   ;	
	dec	si
	lea	ax,word ptr [bp-24]
	push	ss
	push	ax
	mov	ax,si
	cwd	
	push	ax
	push	dx
	xor	dx,dx
	mov	ax,14
	pop	cx
	pop	bx
	call	near ptr N_LXMUL@
	push	ax
	push	dx
	mov	dx,word ptr DGROUP:sbSamples+2
	mov	ax,word ptr DGROUP:sbSamples
	pop	cx
	pop	bx
	call	near ptr N_PADD@
	push	dx
	push	ax
	mov	cx,14
	call	near ptr N_SCOPY@
   ;	
   ;		sample = sbSamples[--sound];
   ;	
   ;	
	mov	dx,word ptr DGROUP:sbSamples+2
	mov	ax,word ptr DGROUP:sbSamples
	mov	cx,word ptr [bp-22]
	mov	bx,word ptr [bp-24]
	call	near ptr N_PADD@
	mov	word ptr [bp-2],dx
	mov	word ptr [bp-4],ax
   ;	
   ;		data = ((byte huge *)sbSamples) + sample.offset;
   ;	
	push	word ptr [bp-14]
	push	word ptr [bp-16]
	mov	ax,15
	mov	dx,16960
	push	ax
	push	dx
	call	near ptr N_LUDIV@
	mov	dl,0
	sub	dl,al
	mov	byte ptr [bp-5],dl
	jmp	short @4@50
@4@50:
   ;	
   ;		timevalue = 256 - (1000000 / sample.hertz);
   ;	
   ;	//	printf("sample #%d ",sound);
   ;	//	printf("%ld bytes, %ldHz, tc=%d\n",sample.length,sample.hertz,timevalue);
   ;	
   ;	//	printf("setting time constant\n");
   ;		// Set the SoundBlaster DAC time constant
   ;	
	mov	dx,word ptr DGROUP:sbLocation
	add	dx,524
	in	al,dx
	mov	ah,0
	test	ax,128
	jne	short @4@50
   ;	
   ;		sbWriteDelay();
   ;	
	mov	dx,word ptr DGROUP:sbLocation
	add	dx,524
	mov	al,64
	out	dx,al
	jmp	short @4@98
@4@98:
   ;	
   ;		sbOut(sbWriteCmd,0x40);
   ;	
	mov	dx,word ptr DGROUP:sbLocation
	add	dx,524
	in	al,dx
	mov	ah,0
	test	ax,128
	jne	short @4@98
   ;	
   ;		sbWriteDelay();
   ;	
	mov	dx,word ptr DGROUP:sbLocation
	add	dx,524
	mov	al,byte ptr [bp-5]
	out	dx,al
   ;	
   ;		sbOut(sbWriteData,timevalue);
   ;	
   ;	
	push	word ptr [bp-18]
	push	word ptr [bp-20]
	push	word ptr [bp-2]
	push	word ptr [bp-4]
	call	near ptr jmPlaySeg
	add	sp,8
	mov	word ptr [bp-8],dx
	mov	word ptr [bp-10],ax
   ;	
   ;		used = jmPlaySeg(data,sample.length);
   ;	
	mov	ax,word ptr [bp-18]
	mov	dx,word ptr [bp-20]
	cmp	ax,word ptr [bp-8]
	ja	short @4@218
	jne	short @4@194
	cmp	dx,word ptr [bp-10]
	ja	short @4@218
@4@194:
   ;	
   ;		if (sample.length <= used)
   ;	
	mov	word ptr DGROUP:sbNextSegPtr+2,0
	mov	word ptr DGROUP:sbNextSegPtr,0
	jmp	short @4@242
@4@218:
   ;	
   ;			sbNextSegPtr = nil;
   ;		else
   ;		{
   ;	
	mov	dx,word ptr [bp-2]
	mov	ax,word ptr [bp-4]
	mov	cx,word ptr [bp-8]
	mov	bx,word ptr [bp-10]
	call	near ptr N_PADD@
	mov	word ptr DGROUP:sbNextSegPtr+2,dx
	mov	word ptr DGROUP:sbNextSegPtr,ax
   ;	
   ;			sbNextSegPtr = data + used;
   ;	
	mov	ax,word ptr [bp-18]
	mov	dx,word ptr [bp-20]
	sub	dx,word ptr [bp-10]
	sbb	ax,word ptr [bp-8]
	mov	word ptr DGROUP:sbNextSegLen+2,ax
	mov	word ptr DGROUP:sbNextSegLen,dx
@4@242:
   ;	
   ;			sbNextSegLen = sample.length - used;
   ;		}
   ;	
   ;	//	printf("enabling SB irq #%d\n",sbInterrupt);
   ;		// Save old interrupt status and unmask ours
   ;	
	mov	dx,33
	in	al,dx
	mov	byte ptr DGROUP:sbOldIntMask,al
   ;	
   ;		sbOldIntMask = inportb(0x21);
   ;	
	mov	al,1
	mov	cl,byte ptr DGROUP:sbInterrupt
	shl	al,cl
	not	al
	push	ax
	mov	al,byte ptr DGROUP:sbOldIntMask
	pop	dx
	and	al,dl
	mov	dx,33
	out	dx,al
	jmp	short @4@266
@4@266:
   ;	
   ;		outportb(0x21,sbOldIntMask & ~(1 << sbInterrupt));
   ;	
   ;	//	printf("enabling DSP DMA request\n");
   ;	
	mov	dx,word ptr DGROUP:sbLocation
	add	dx,524
	in	al,dx
	mov	ah,0
	test	ax,128
	jne	short @4@266
   ;	
   ;		sbWriteDelay();
   ;	
	mov	dx,word ptr DGROUP:sbLocation
	add	dx,524
	mov	al,212
	out	dx,al
   ;	
   ;		sbOut(sbWriteCmd,0xd4);						// Make sure DSP DMA is enabled
   ;	
   ;	//	printf("sound should be playing\n");
   ;	
	mov	word ptr DGROUP:sbSamplePlaying,1
   ;	
   ;		sbSamplePlaying = true;
   ;	
	pop	si
	mov	sp,bp
	pop	bp
	ret	
_jmPlaySample	endp
   ;	
   ;	void
   ;	
	assume	cs:_TEXT
_jmStopSample	proc	near
	push	bp
	mov	bp,sp
   ;	
   ;	jmStopSample(void)
   ;	{
   ;		byte	is;
   ;	
   ;	
	cmp	word ptr DGROUP:sbSamplePlaying,0
	je	short @5@194
	jmp	short @5@74
@5@74:
   ;	
   ;		if (sbSamplePlaying)
   ;		{
   ;	//		printf("turning off DSP DMA\n");
   ;	
	mov	dx,word ptr DGROUP:sbLocation
	add	dx,524
	in	al,dx
	mov	ah,0
	test	ax,128
	jne	short @5@74
   ;	
   ;			sbWriteDelay();
   ;	
	mov	dx,word ptr DGROUP:sbLocation
	add	dx,524
	mov	al,208
	out	dx,al
   ;	
   ;			sbOut(sbWriteCmd,0xd0);	// Turn off DSP DMA
   ;	
   ;	//		printf("restoring interrupt\n");
   ;	
	mov	dx,33
	in	al,dx
	mov	bl,al
   ;	
   ;			is = inportb(0x21);	// Restore interrupt mask bit
   ;	
	mov	ax,1
	mov	cl,byte ptr DGROUP:sbInterrupt
	shl	ax,cl
	mov	dl,byte ptr DGROUP:sbOldIntMask
	mov	dh,0
	test	ax,dx
	je	short @5@146
   ;	
   ;			if (sbOldIntMask & (1 << sbInterrupt))
   ;	
	mov	al,1
	mov	cl,byte ptr DGROUP:sbInterrupt
	shl	al,cl
	or	bl,al
	jmp	short @5@170
@5@146:
   ;	
   ;				is |= (1 << sbInterrupt);
   ;			else
   ;	
	mov	al,1
	mov	cl,byte ptr DGROUP:sbInterrupt
	shl	al,cl
	not	al
	and	bl,al
@5@170:
   ;	
   ;				is &= ~(1 << sbInterrupt);
   ;	
	mov	dx,33
	mov	al,bl
	out	dx,al
   ;	
   ;			outportb(0x21,is);
   ;	
   ;	
   ;	
	mov	word ptr DGROUP:sbSamplePlaying,0
@5@194:
   ;	
   ;			sbSamplePlaying = false;
   ;		}
   ;	
	pop	bp
	ret	
_jmStopSample	endp
   ;	
   ;	static boolean
   ;	
	assume	cs:_TEXT
jmCheckSB	proc	near
	push	bp
	mov	bp,sp
	push	si
   ;	
   ;	jmCheckSB(int port)
   ;	{
   ;		int	i;
   ;	
   ;	
	mov	ax,word ptr [bp+4]
	mov	cl,4
	shl	ax,cl
	mov	word ptr DGROUP:sbLocation,ax
   ;	
   ;		sbLocation = port << 4;	// Initialize stuff for later use
   ;	
   ;	
	mov	dx,word ptr DGROUP:sbLocation
	add	dx,518
	mov	al,1
	out	dx,al
   ;	
   ;		sbOut(sbReset,true);	// Reset the SoundBlaster DSP
   ;	
	mov	ax,4
	push	ax
	call	near ptr jmDelay
	pop	cx
   ;	
   ;		jmDelay(4);				// Wait 4usec
   ;	
	mov	dx,word ptr DGROUP:sbLocation
	add	dx,518
	mov	al,0
	out	dx,al
   ;	
   ;		sbOut(sbReset,false);	// Turn off sb DSP reset
   ;	
	mov	ax,100
	push	ax
	call	near ptr jmDelay
	pop	cx
   ;	
   ;		jmDelay(100);			// Wait 100usec
   ;	
	xor	si,si
	jmp	short @6@194
@6@50:
   ;	
   ;		for (i = 0;i < 100;i++)
   ;		{
   ;	
	mov	dx,word ptr DGROUP:sbLocation
	add	dx,526
	in	al,dx
	test	al,128
	je	short @6@170
   ;	
   ;			if (sbIn(sbDataAvail) & 0x80)		// If data is available...
   ;			{
   ;	
	mov	dx,word ptr DGROUP:sbLocation
	add	dx,522
	in	al,dx
	cmp	al,170
	jne	short @6@146
   ;	
   ;				if (sbIn(sbReadData) == 0xaa)	// If it matches correct value
   ;	
	mov	ax,1
	jmp	short @6@242
	jmp	short @6@170
@6@146:
   ;	
   ;					return(true);
   ;				else
   ;				{
   ;	
	mov	word ptr DGROUP:sbLocation,65535
   ;	
   ;					sbLocation = -1;			// Otherwise not a SoundBlaster
   ;	
	xor	ax,ax
	jmp	short @6@242
@6@170:
	inc	si
@6@194:
	cmp	si,100
	jl	short @6@50
   ;	
   ;					return(false);
   ;				}
   ;			}
   ;		}
   ;	
	mov	word ptr DGROUP:sbLocation,65535
   ;	
   ;		sbLocation = -1;						// Retry count exceeded - fail
   ;	
	xor	ax,ax
	jmp	short @6@242
@6@242:
   ;	
   ;		return(false);
   ;	
	pop	si
	pop	bp
	ret	
jmCheckSB	endp
   ;	
   ;	boolean
   ;	
	assume	cs:_TEXT
_jmDetectSoundBlaster	proc	near
	push	bp
	mov	bp,sp
	push	si
	push	di
	mov	si,word ptr [bp+4]
   ;	
   ;	jmDetectSoundBlaster(int port)
   ;	{
   ;		int	i;
   ;	
   ;	
	or	si,si
	jne	short @7@74
   ;	
   ;		if (port == 0)					// If user specifies default address, use 2
   ;	
	mov	si,2
@7@74:
   ;	
   ;			port = 2;
   ;	
	cmp	si,65535
	jne	short @7@266
   ;	
   ;		if (port == -1)
   ;		{
   ;	
	mov	di,1
	jmp	short @7@194
@7@122:
   ;	
   ;			for (i = 1;i <= 6;i++)		// Scan through possible SB locations
   ;			{
   ;	
	push	di
	call	near ptr jmCheckSB
	pop	cx
	or	ax,ax
	je	short @7@170
   ;	
   ;				if (jmCheckSB(i))		// If found at this address,
   ;	
	mov	ax,1
	jmp	short @7@290
@7@170:
	inc	di
@7@194:
	cmp	di,6
	jle	short @7@122
   ;	
   ;					return(true);		//	return success
   ;			}
   ;	
	xor	ax,ax
	jmp	short @7@290
   ;	
   ;			return(false);				// All addresses failed, return failure
   ;	
	jmp	short @7@290
@7@266:
   ;	
   ;		}
   ;		else
   ;	
	push	si
	call	near ptr jmCheckSB
	pop	cx
	jmp	short @7@290
@7@290:
   ;	
   ;			return(jmCheckSB(port));	// User specified address or default
   ;	
	pop	di
	pop	si
	pop	bp
	ret	
_jmDetectSoundBlaster	endp
   ;	
   ;	void
   ;	
	assume	cs:_TEXT
_jmSetSBInterrupt	proc	near
	push	bp
	mov	bp,sp
   ;	
   ;	jmSetSBInterrupt(int num)
   ;	{
   ;	
	mov	ax,word ptr [bp+4]
	mov	word ptr DGROUP:sbInterrupt,ax
   ;	
   ;		sbInterrupt = num;
   ;	
	mov	bx,word ptr DGROUP:sbInterrupt
	shl	bx,1
	mov	ax,word ptr DGROUP:sbIntVectors[bx]
	mov	word ptr DGROUP:sbIntVec,ax
   ;	
   ;		sbIntVec = sbIntVectors[sbInterrupt];
   ;	
	pop	bp
	ret	
_jmSetSBInterrupt	endp
   ;	
   ;	void
   ;	
	assume	cs:_TEXT
_jmStartSB	proc	near
	push	bp
	mov	bp,sp
   ;	
   ;	jmStartSB(void)
   ;	{
   ;	//	printf("setting interrupt #0x%02x handler\n",sbIntVec);
   ;	
	push	word ptr DGROUP:sbIntVec
	call	near ptr _getvect
	pop	cx
	mov	word ptr DGROUP:sbOldIntHand+2,dx
	mov	word ptr DGROUP:sbOldIntHand,ax
   ;	
   ;		sbOldIntHand = getvect(sbIntVec);	// Get old interrupt handler
   ;	
	push	cs
	mov	ax,offset _jmSBService
	push	ax
	push	word ptr DGROUP:sbIntVec
	call	near ptr _setvect
	add	sp,6
	jmp	short @9@50
@9@50:
   ;	
   ;		setvect(sbIntVec,jmSBService);		// Set mine
   ;	
   ;	//	printf("setting DSP modes\n");
   ;	
	mov	dx,word ptr DGROUP:sbLocation
	add	dx,524
	in	al,dx
	mov	ah,0
	test	ax,128
	jne	short @9@50
   ;	
   ;		sbWriteDelay();
   ;	
	mov	dx,word ptr DGROUP:sbLocation
	add	dx,524
	mov	al,209
	out	dx,al
   ;	
   ;		sbOut(sbWriteCmd,0xd1);						// Turn on DSP speaker
   ;	
	pop	bp
	ret	
_jmStartSB	endp
   ;	
   ;	void
   ;	
	assume	cs:_TEXT
_jmShutSB	proc	near
	push	bp
	mov	bp,sp
   ;	
   ;	jmShutSB(void)
   ;	{
   ;	
	call	near ptr _jmStopSample
   ;	
   ;		jmStopSample();
   ;	
   ;	//	printf("restoring interrupt vector\n");
   ;	
	push	word ptr DGROUP:sbOldIntHand+2
	push	word ptr DGROUP:sbOldIntHand
	push	word ptr DGROUP:sbIntVec
	call	near ptr _setvect
	add	sp,6
   ;	
   ;		setvect(sbIntVec,sbOldIntHand);	// Set vector back
   ;	
	pop	bp
	ret	
_jmShutSB	endp
   ;	
   ;	boolean
   ;	
	assume	cs:_TEXT
_jmSamplePlaying	proc	near
	push	bp
	mov	bp,sp
   ;	
   ;	jmSamplePlaying(void)
   ;	{
   ;	
	mov	ax,word ptr DGROUP:sbSamplePlaying
	jmp	short @11@50
@11@50:
   ;	
   ;		return(sbSamplePlaying);
   ;	
	pop	bp
	ret	
_jmSamplePlaying	endp
   ;	
   ;	void
   ;	
	assume	cs:_TEXT
_jmSetSamplePtr	proc	near
	push	bp
	mov	bp,sp
   ;	
   ;	jmSetSamplePtr(s)
   ;		SampledSound huge *s;
   ;	{
   ;	
	mov	ax,word ptr [bp+6]
	mov	dx,word ptr [bp+4]
	mov	word ptr DGROUP:sbSamples+2,ax
	mov	word ptr DGROUP:sbSamples,dx
   ;	
   ;		sbSamples = s;
   ;	
	pop	bp
	ret	
_jmSetSamplePtr	endp
_TEXT	ends
_BSS	segment word public 'BSS'
sbSamples	label	dword
	db	4 dup (?)
sbNextSegLen	label	word
	db	4 dup (?)
sbOldIntHand	label	dword
	db	4 dup (?)
sbNextSegPtr	label	dword
	db	4 dup (?)
	?debug	C E9
_BSS	ends
_DATA	segment word public 'DATA'
s@	label	byte
_DATA	ends
_TEXT	segment byte public 'CODE'
_TEXT	ends
_sbIntVec	equ	sbIntVec
	public	_jmSBService
_jmPlaySeg	equ	jmPlaySeg
	extrn	_setvect:near
_jmCheckSB	equ	jmCheckSB
	public	_jmStartSB
	extrn	_getvect:near
_jmDelay	equ	jmDelay
	public	_jmShutSB
_sbSamplePlaying	equ	sbSamplePlaying
	public	_jmDetectSoundBlaster
	extrn	N_SCOPY@:far
_sbNextSegPtr	equ	sbNextSegPtr
_sbOldIntMask	equ	sbOldIntMask
_sbIntVectors	equ	sbIntVectors
	extrn	N_LUDIV@:far
	public	_jmSetSBInterrupt
_sbOldIntHand	equ	sbOldIntHand
	extrn	N_LXURSH@:far
_sbInterrupt	equ	sbInterrupt
	extrn	N_LXMUL@:far
_sbNextSegLen	equ	sbNextSegLen
	public	_jmSamplePlaying
	extrn	N_PCMP@:far
	public	_jmSetSamplePtr
_sbLocation	equ	sbLocation
	extrn	N_PADD@:far
	extrn	N_PADA@:far
_sbSamples	equ	sbSamples
	public	_jmStopSample
	public	_jmPlaySample
	end
