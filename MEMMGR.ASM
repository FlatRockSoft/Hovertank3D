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
	?debug	S "memmgr.c"
	?debug	C E90E549D16086D656D6D67722E63
	?debug	C E9D03A9E160749444C49422E48
	?debug	C E9AE10A3160A4752415048484F562E48
	?debug	C E92592951609534E4453484F562E48
	?debug	C E900104D1616433A5C42435C494E434C5544455C7374646172672E+
	?debug	C 68
	?debug	C E900104D1613433A5C42435C494E434C5544455C646F732E68
	?debug	C E900104D1613433A5C42435C494E434C5544455C6D656D2E68
	?debug	C E900104D1618433A5C42435C494E434C5544455C7379735C737461+
	?debug	C 742E68
	?debug	C E900104D1615433A5C42435C494E434C5544455C66636E746C2E68
	?debug	C E900104D1616433A5C42435C494E434C5544455C7374646C69622E+
	?debug	C 68
	?debug	C E900104D1615433A5C42435C494E434C5544455C616C6C6F632E68
	?debug	C E900104D1612433A5C42435C494E434C5544455C696F2E68
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
	db	69
	db	77
	db	77
	db	88
	db	88
	db	88
	db	88
	db	48
	db	1 dup (0)
_DATA	ends
_TEXT	segment byte public 'CODE'
   ;	
   ;	void CheckForEMS (void)
   ;	
	assume	cs:_TEXT
_CheckForEMS	proc	near
	push	bp
	mov	bp,sp
	sub	sp,10
	push	ss
	lea	ax,word ptr [bp-10]
	push	ax
	push	ds
	mov	ax,offset DGROUP:d@+0
	push	ax
	mov	cx,9
	call	near ptr N_SCOPY@
   ;	
   ;	{
   ;	  char	emmname[9] = "EMMXXXX0";
   ;	
   ;	asm	mov	dx,OFFSET emmname
   ;	
		mov		dx,OFFSET [bp-10]
   ;	
   ;	asm	mov	ax,0x3d00
   ;	
		mov		ax,03d00H
   ;	
   ;	asm	int	0x21		// try to open EMMXXXX0 device
   ;	
		int		021H		
   ;	
   ;	asm	jc	error
   ;	
	jc	short @1@506
   ;	
   ;	
   ;	asm	mov	bx,ax
   ;	
		mov		bx,ax
   ;	
   ;	asm	mov	ax,0x4400
   ;	
		mov		ax,04400H
   ;	
   ;	
   ;	asm	int	0x21		// get device info
   ;	
		int		021H		
   ;	
   ;	asm	jc	error
   ;	
	jc	short @1@506
   ;	
   ;	
   ;	asm	and	dx,0x80
   ;	
		and		dx,080H
   ;	
   ;	asm	jz	error
   ;	
	je	short @1@506
   ;	
   ;	
   ;	asm	mov	ax,0x4407
   ;	
		mov		ax,04407H
   ;	
   ;	
   ;	asm	int	0x21		// get status
   ;	
		int		021H		
   ;	
   ;	asm	jc	error
   ;	
	jc	short @1@506
   ;	
   ;	asm	or	al,al
   ;	
		or		al,al
   ;	
   ;	asm	jz	error
   ;	
	je	short @1@506
   ;	
   ;	
   ;	asm	mov	ah,0x3e
   ;	
		mov		ah,03eH
   ;	
   ;	asm	int	0x21		// close handle
   ;	
		int		021H		
   ;	
   ;	asm	jc	error
   ;	
	jc	short @1@506
   ;	
   ;	
   ;	//
   ;	// EMS is good
   ;	//
   ;	
   ;	
   ;	  return;
   ;	
	jmp	short @1@530
@1@506:
   ;	
   ;	
   ;	error:
   ;	//
   ;	// EMS is bad
   ;	//
   ;	  EMSpresent = 0;
   ;	
	mov	word ptr DGROUP:_EMSpresent,0
@1@530:
   ;	
   ;	
   ;	}
   ;	
	mov	sp,bp
	pop	bp
	ret	
_CheckForEMS	endp
   ;	
   ;	int FindBlock (memptr *ptr)
   ;	
	assume	cs:_TEXT
_FindBlock	proc	near
	push	bp
	mov	bp,sp
	push	si
   ;	
   ;	{
   ;	  int i;
   ;	  for (i=1;i<numblocks;i++)
   ;	
	mov	si,1
	jmp	short @2@122
@2@50:
   ;	
   ;	    if (blocks[i].useptr == ptr)
   ;	
	mov	bx,si
	shl	bx,1
	shl	bx,1
	shl	bx,1
	mov	ax,word ptr DGROUP:_blocks[bx+6]
	cmp	ax,word ptr [bp+4]
	jne	short @2@98
   ;	
   ;	      return i;
   ;	
	mov	ax,si
	jmp	short @2@170
@2@98:
	inc	si
@2@122:
	cmp	si,word ptr DGROUP:_numblocks
	jl	short @2@50
   ;	
   ;	
   ;	  Quit ("Memory manager error: Block not found!");
   ;	
	mov	ax,offset DGROUP:s@
	push	ax
	call	near ptr _Quit
	pop	cx
   ;	
   ;	  return -1;
   ;	
	mov	ax,65535
	jmp	short @2@170
@2@170:
   ;	
   ;	}
   ;	
	pop	si
	pop	bp
	ret	
_FindBlock	endp
   ;	
   ;	void RemoveBlock (int block)
   ;	
	assume	cs:_TEXT
_RemoveBlock	proc	near
	push	bp
	mov	bp,sp
	sub	sp,10
	push	si
	mov	si,word ptr [bp+4]
   ;	
   ;	{
   ;	  void far *source, far *dest;
   ;	  unsigned length;
   ;	
   ;	  *blocks[block].useptr = NULL;
   ;	
	mov	bx,si
	shl	bx,1
	shl	bx,1
	shl	bx,1
	mov	bx,word ptr DGROUP:_blocks[bx+6]
	mov	word ptr [bx],0
   ;	
   ;	  if (block!=numblocks-1)
   ;	
	mov	ax,word ptr DGROUP:_numblocks
	dec	ax
	cmp	ax,si
	je	short @3@74
   ;	
   ;	  {
   ;	    source = &blocks[block+1];
   ;	
	mov	ax,si
	shl	ax,1
	shl	ax,1
	shl	ax,1
	add	ax,offset DGROUP:_blocks+8
	mov	word ptr [bp-2],ds
	mov	word ptr [bp-4],ax
   ;	
   ;	    dest = &blocks[block];
   ;	
	mov	ax,si
	shl	ax,1
	shl	ax,1
	shl	ax,1
	add	ax,offset DGROUP:_blocks
	mov	word ptr [bp-6],ds
	mov	word ptr [bp-8],ax
   ;	
   ;	    length = (numblocks-1-block)*sizeof(blocks[0]);
   ;	
	mov	ax,word ptr DGROUP:_numblocks
	dec	ax
	sub	ax,si
	shl	ax,1
	shl	ax,1
	shl	ax,1
	mov	word ptr [bp-10],ax
   ;	
   ;	    movedata (FP_SEG(source),FP_OFF(source),FP_SEG(dest),FP_OFF(dest),length);
   ;	
	push	word ptr [bp-10]
	push	word ptr [bp-8]
	push	word ptr [bp-6]
	push	word ptr [bp-4]
	push	word ptr [bp-2]
	call	near ptr _movedata
	add	sp,10
@3@74:
   ;	
   ;	  }
   ;	  numblocks--;
   ;	
	dec	word ptr DGROUP:_numblocks
   ;	
   ;	}
   ;	
	pop	si
	mov	sp,bp
	pop	bp
	ret	
_RemoveBlock	endp
   ;	
   ;	void InsertBlock (int block)
   ;	
	assume	cs:_TEXT
_InsertBlock	proc	near
	push	bp
	mov	bp,sp
	sub	sp,6
	push	si
	push	di
   ;	
   ;	{
   ;	  unsigned source,dest,length;
   ;	
   ;	  if (block!=numblocks-1)
   ;	
	mov	ax,word ptr DGROUP:_numblocks
	dec	ax
	cmp	ax,word ptr [bp+4]
	je	short @4@266
   ;	
   ;	  {
   ;	    source = ((unsigned)&blocks[numblocks])-2;
   ;	
	mov	ax,word ptr DGROUP:_numblocks
	shl	ax,1
	shl	ax,1
	shl	ax,1
	add	ax,offset DGROUP:_blocks
	dec	ax
	dec	ax
	mov	word ptr [bp-2],ax
   ;	
   ;	    dest = ((unsigned)&blocks[numblocks+1])-2;
   ;	
	mov	ax,word ptr DGROUP:_numblocks
	shl	ax,1
	shl	ax,1
	shl	ax,1
	add	ax,offset DGROUP:_blocks+8
	dec	ax
	dec	ax
	mov	word ptr [bp-4],ax
   ;	
   ;	    length = (numblocks-1-block)*sizeof(blocks[0])/2;
   ;	
	mov	ax,word ptr DGROUP:_numblocks
	dec	ax
	sub	ax,word ptr [bp+4]
	shl	ax,1
	shl	ax,1
	shl	ax,1
	shr	ax,1
	mov	word ptr [bp-6],ax
   ;	
   ;	asm	mov	cx,length
   ;	
		mov		cx,[bp-6]
   ;	
   ;	asm	mov	si,source
   ;	
		mov		si,[bp-2]
   ;	
   ;	asm	mov	di,dest
   ;	
		mov		di,[bp-4]
   ;	
   ;	asm	mov	ax,ds
   ;	
		mov		ax,ds
   ;	
   ;	asm	mov	es,ax
   ;	
		mov		es,ax
   ;	
   ;	asm	std
   ;	
		std	
   ;	
   ;	asm	rep	movsw
   ;	
		rep	movsw	
   ;	
   ;	asm	cld
   ;	
		cld	
@4@266:
   ;	
   ;	  }
   ;	  if (++numblocks>=MAXBLOCKS)
   ;	
	inc	word ptr DGROUP:_numblocks
	mov	ax,word ptr DGROUP:_numblocks
	cmp	ax,1500
	jl	short @4@314
   ;	
   ;	    Quit ("Memory manager error: Too many blocks!");
   ;	
	mov	ax,offset DGROUP:s@+39
	push	ax
	call	near ptr _Quit
	pop	cx
@4@314:
   ;	
   ;	}
   ;	
	pop	di
	pop	si
	mov	sp,bp
	pop	bp
	ret	
_InsertBlock	endp
   ;	
   ;	void MMStartup (void)
   ;	
	assume	cs:_TEXT
_MMStartup	proc	near
	push	bp
	mov	bp,sp
	sub	sp,14
	push	si
	push	di
   ;	
   ;	{
   ;	  unsigned long length;
   ;	  void far *start;
   ;	  unsigned nearstart,farstart,EMSstart,seg;
   ;	  unsigned nearlength,farlength,emslength,xmslength;
   ;	
   ;	//
   ;	// get all available near conventional memory
   ;	//
   ;	  length=coreleft();
   ;	
	call	near ptr _coreleft
	mov	word ptr [bp-2],0
	mov	word ptr [bp-4],ax
   ;	
   ;	  start = (void far *)(nearheap = malloc(length));
   ;	
	push	word ptr [bp-4]
	call	near ptr _malloc
	pop	cx
	mov	word ptr DGROUP:_nearheap,ax
	mov	word ptr [bp-6],ds
	mov	word ptr [bp-8],ax
   ;	
   ;	
   ;	//
   ;	// paragraph align it and figure size
   ;	//
   ;	  length -= 16-(FP_OFF(start)&15);
   ;	
	mov	ax,word ptr [bp-8]
	and	ax,15
	mov	dx,16
	sub	dx,ax
	sub	word ptr [bp-4],dx
	sbb	word ptr [bp-2],0
   ;	
   ;	  length -= EXTRASTACKSIZE;
   ;	
	sub	word ptr [bp-4],4096
	sbb	word ptr [bp-2],0
   ;	
   ;	  nearlength = length / 16;			// now in paragraphs
   ;	
	mov	dx,word ptr [bp-2]
	mov	ax,word ptr [bp-4]
	mov	cl,4
	call	near ptr N_LXURSH@
	mov	word ptr [bp-12],ax
   ;	
   ;	  nearstart = FP_SEG(start)+(FP_OFF(start)+15)/16;
   ;	
	mov	ax,word ptr [bp-8]
	add	ax,15
	mov	cl,4
	shr	ax,cl
	mov	dx,word ptr [bp-6]
	add	dx,ax
	mov	si,dx
   ;	
   ;	
   ;	//
   ;	// get all available far conventional memory
   ;	//
   ;	  length=farcoreleft();
   ;	
	call	near ptr _farcoreleft
	mov	word ptr [bp-2],dx
	mov	word ptr [bp-4],ax
   ;	
   ;	  start = farheap = farmalloc(length);
   ;	
	push	word ptr [bp-2]
	push	word ptr [bp-4]
	call	near ptr _farmalloc
	pop	cx
	pop	cx
	mov	word ptr DGROUP:_farheap+2,dx
	mov	word ptr DGROUP:_farheap,ax
	mov	word ptr [bp-6],dx
	mov	word ptr [bp-8],ax
   ;	
   ;	
   ;	//
   ;	// paragraph align it and figure size
   ;	//
   ;	  if (FP_OFF(start))
   ;	
	cmp	word ptr [bp-8],0
	je	short @5@74
   ;	
   ;	  {
   ;	    length -= 16-FP_OFF(start);
   ;	
	mov	ax,16
	sub	ax,word ptr [bp-8]
	sub	word ptr [bp-4],ax
	sbb	word ptr [bp-2],0
   ;	
   ;	    start = (void far *)MK_FP(FP_SEG(start)+1,0);
   ;	
	mov	ax,word ptr [bp-6]
	inc	ax
	mov	word ptr [bp-6],ax
	mov	word ptr [bp-8],0
@5@74:
   ;	
   ;	  }
   ;	  farlength = length / 16;			// now in paragraphs
   ;	
	mov	dx,word ptr [bp-2]
	mov	ax,word ptr [bp-4]
	mov	cl,4
	call	near ptr N_LXURSH@
	mov	word ptr [bp-14],ax
   ;	
   ;	  farstart = FP_SEG(start);
   ;	
	mov	di,word ptr [bp-6]
   ;	
   ;	
   ;	  totalmem = nearlength + farlength;
   ;	
	mov	ax,word ptr [bp-12]
	add	ax,word ptr [bp-14]
	mov	word ptr DGROUP:_totalmem,ax
   ;	
   ;	
   ;	//
   ;	// detect EMS and allocate 64K at page frame
   ;	//
   ;	  CheckForEMS();
   ;	
	call	near ptr _CheckForEMS
   ;	
   ;	  if (EMSpresent)
   ;	
	cmp	word ptr DGROUP:_EMSpresent,0
	je	short @5@122
   ;	
   ;	  {
   ;	    EMSstart = 0xffff;
   ;	
	mov	word ptr [bp-10],65535
   ;	
   ;	    totalmem += 0x1000;				// 64k of EMS
   ;	
	add	word ptr DGROUP:_totalmem,4096
   ;	
   ;	    MMMapEMS();					// map in used pages
   ;	
	call	near ptr _MMMapEMS
   ;	
   ;	  }
   ;	
	jmp	short @5@146
@5@122:
   ;	
   ;	  else
   ;	  {
   ;	    EMSstart = 0xffff;
   ;	
	mov	word ptr [bp-10],65535
@5@146:
   ;	
   ;	  }
   ;	
   ;	//
   ;	// set up locked blocks
   ;	//
   ;	  numblocks = 0;
   ;	
	mov	word ptr DGROUP:_numblocks,0
   ;	
   ;	
   ;	  blocks[numblocks].start = 0;
   ;	
	mov	bx,word ptr DGROUP:_numblocks
	shl	bx,1
	shl	bx,1
	shl	bx,1
	mov	word ptr DGROUP:_blocks[bx],0
   ;	
   ;	  blocks[numblocks].length = nearstart;
   ;	
	mov	bx,word ptr DGROUP:_numblocks
	shl	bx,1
	shl	bx,1
	shl	bx,1
	mov	word ptr DGROUP:_blocks[bx+2],si
   ;	
   ;	  blocks[numblocks].attributes = LOCKBIT;
   ;	
	mov	bx,word ptr DGROUP:_numblocks
	shl	bx,1
	shl	bx,1
	shl	bx,1
	mov	word ptr DGROUP:_blocks[bx+4],32768
   ;	
   ;	
   ;	  numblocks++;
   ;	
	inc	word ptr DGROUP:_numblocks
   ;	
   ;	
   ;	  blocks[numblocks].start = nearstart+nearlength;
   ;	
	mov	bx,word ptr DGROUP:_numblocks
	shl	bx,1
	shl	bx,1
	shl	bx,1
	mov	ax,si
	add	ax,word ptr [bp-12]
	mov	word ptr DGROUP:_blocks[bx],ax
   ;	
   ;	  blocks[numblocks].length = farstart-(nearstart+nearlength);
   ;	
	mov	bx,word ptr DGROUP:_numblocks
	shl	bx,1
	shl	bx,1
	shl	bx,1
	mov	ax,si
	add	ax,word ptr [bp-12]
	mov	dx,di
	sub	dx,ax
	mov	word ptr DGROUP:_blocks[bx+2],dx
   ;	
   ;	  blocks[numblocks].attributes = LOCKBIT;
   ;	
	mov	bx,word ptr DGROUP:_numblocks
	shl	bx,1
	shl	bx,1
	shl	bx,1
	mov	word ptr DGROUP:_blocks[bx+4],32768
   ;	
   ;	
   ;	  numblocks++;
   ;	
	inc	word ptr DGROUP:_numblocks
   ;	
   ;	
   ;	  blocks[numblocks].start = farstart+farlength;
   ;	
	mov	bx,word ptr DGROUP:_numblocks
	shl	bx,1
	shl	bx,1
	shl	bx,1
	mov	ax,di
	add	ax,word ptr [bp-14]
	mov	word ptr DGROUP:_blocks[bx],ax
   ;	
   ;	  blocks[numblocks].length = EMSstart-(farstart+farlength);
   ;	
	mov	bx,word ptr DGROUP:_numblocks
	shl	bx,1
	shl	bx,1
	shl	bx,1
	mov	ax,di
	add	ax,word ptr [bp-14]
	mov	dx,word ptr [bp-10]
	sub	dx,ax
	mov	word ptr DGROUP:_blocks[bx+2],dx
   ;	
   ;	  blocks[numblocks].attributes = LOCKBIT;
   ;	
	mov	bx,word ptr DGROUP:_numblocks
	shl	bx,1
	shl	bx,1
	shl	bx,1
	mov	word ptr DGROUP:_blocks[bx+4],32768
   ;	
   ;	
   ;	  numblocks++;
   ;	
	inc	word ptr DGROUP:_numblocks
   ;	
   ;	
   ;	
   ;	}
   ;	
	pop	di
	pop	si
	mov	sp,bp
	pop	bp
	ret	
_MMStartup	endp
   ;	
   ;	void MMShutdown (void)
   ;	
	assume	cs:_TEXT
_MMShutdown	proc	near
	push	bp
	mov	bp,sp
   ;	
   ;	{
   ;	  farfree (farheap);
   ;	
	push	word ptr DGROUP:_farheap+2
	push	word ptr DGROUP:_farheap
	call	near ptr _farfree
	pop	cx
	pop	cx
   ;	
   ;	  free (nearheap);
   ;	
	push	word ptr DGROUP:_nearheap
	call	near ptr _free
	pop	cx
   ;	
   ;	
   ;	}
   ;	
	pop	bp
	ret	
_MMShutdown	endp
   ;	
   ;	void MMMapEMS (void)
   ;	
	assume	cs:_TEXT
_MMMapEMS	proc	near
	push	bp
	mov	bp,sp
   ;	
   ;	{
   ;	
   ;	}
   ;	
	pop	bp
	ret	
_MMMapEMS	endp
   ;	
   ;	void MMGetPtr (memptr *baseptr,long size)
   ;	
	assume	cs:_TEXT
_MMGetPtr	proc	near
	push	bp
	mov	bp,sp
	sub	sp,8
	push	si
	push	di
   ;	
   ;	{
   ;	  int i,j,k,try;
   ;	  unsigned start,end;
   ;	
   ;	  //
   ;	  // change size from bytes to paragraphs
   ;	  //
   ;	  size = (size+15)/16;
   ;	
	xor	ax,ax
	mov	dx,16
	push	ax
	push	dx
	mov	ax,word ptr [bp+8]
	mov	dx,word ptr [bp+6]
	add	dx,15
	adc	ax,0
	push	ax
	push	dx
	call	near ptr N_LDIV@
	mov	word ptr [bp+8],dx
	mov	word ptr [bp+6],ax
   ;	
   ;	
   ;	  //
   ;	  // try a normal scan, then compress if not found
   ;	  //
   ;	  for (try=0;try<2;try++)
   ;	
	mov	word ptr [bp-4],0
	jmp	@8@482
@8@50:
   ;	
   ;	  {
   ;	    for (i=0;i<numblocks-1;i++)
   ;	
	xor	si,si
	jmp	@8@386
@8@74:
   ;	
   ;	    {
   ;	      if (blocks[i].attributes & PURGEBITS )
   ;	
	mov	bx,si
	shl	bx,1
	shl	bx,1
	shl	bx,1
	test	word ptr DGROUP:_blocks[bx+4],3
	je	short @8@122
   ;	
   ;		continue;
   ;	
	jmp	@8@362
@8@122:
   ;	
   ;	      //
   ;	      // blocks[i] cannot be written over, so try to allocate the
   ;	      // new block right after it
   ;	      //
   ;	      start = blocks[i].start + blocks[i].length;
   ;	
	mov	bx,si
	shl	bx,1
	shl	bx,1
	shl	bx,1
	mov	ax,word ptr DGROUP:_blocks[bx]
	mov	bx,si
	shl	bx,1
	shl	bx,1
	shl	bx,1
	add	ax,word ptr DGROUP:_blocks[bx+2]
	mov	word ptr [bp-6],ax
   ;	
   ;	      end = start + size;
   ;	
	mov	ax,word ptr [bp-6]
	add	ax,word ptr [bp+6]
	mov	word ptr [bp-8],ax
   ;	
   ;	      j=i+1;
   ;	
	mov	ax,si
	inc	ax
	mov	di,ax
	jmp	short @8@218
@8@146:
   ;	
   ;	      while (blocks[j].start < end)
   ;	      {
   ;		if (!(blocks[j].attributes & PURGEBITS))
   ;	
	mov	bx,di
	shl	bx,1
	shl	bx,1
	shl	bx,1
	test	word ptr DGROUP:_blocks[bx+4],3
	jne	short @8@194
   ;	
   ;		{
   ;		  i = j-1;
   ;	
	mov	ax,di
	dec	ax
	mov	si,ax
   ;	
   ;		  goto lookmore;		// a non purgable block is in the way
   ;	
	jmp	@8@362
@8@194:
   ;	
   ;		}
   ;		j++;
   ;	
	inc	di
@8@218:
	mov	bx,di
	shl	bx,1
	shl	bx,1
	shl	bx,1
	mov	ax,word ptr DGROUP:_blocks[bx]
	cmp	ax,word ptr [bp-8]
	jb	short @8@146
   ;	
   ;	      }
   ;	      //
   ;	      // purge the blocks in the way
   ;	      //
   ;	      for (k=i+1;k<j;j--)
   ;	
	mov	ax,si
	inc	ax
	mov	word ptr [bp-2],ax
	jmp	short @8@314
@8@266:
   ;	
   ;		RemoveBlock(k);
   ;	
	push	word ptr [bp-2]
	call	near ptr _RemoveBlock
	pop	cx
	dec	di
@8@314:
	cmp	word ptr [bp-2],di
	jl	short @8@266
   ;	
   ;	      //
   ;	      // allocate the new block
   ;	      //
   ;	      InsertBlock(i);
   ;	
	push	si
	call	near ptr _InsertBlock
	pop	cx
   ;	
   ;	      *(unsigned *)baseptr = start;
   ;	
	mov	bx,word ptr [bp+4]
	mov	ax,word ptr [bp-6]
	mov	word ptr [bx],ax
   ;	
   ;	      blocks[i+1].start = start;
   ;	
	mov	bx,si
	shl	bx,1
	shl	bx,1
	shl	bx,1
	mov	ax,word ptr [bp-6]
	mov	word ptr DGROUP:_blocks[bx+8],ax
   ;	
   ;	      blocks[i+1].length = size;
   ;	
	mov	bx,si
	shl	bx,1
	shl	bx,1
	shl	bx,1
	mov	ax,word ptr [bp+6]
	mov	word ptr DGROUP:_blocks[bx+10],ax
   ;	
   ;	      blocks[i+1].useptr = baseptr;
   ;	
	mov	bx,si
	shl	bx,1
	shl	bx,1
	shl	bx,1
	mov	ax,word ptr [bp+4]
	mov	word ptr DGROUP:_blocks[bx+14],ax
   ;	
   ;	      blocks[i+1].attributes = BASEATTRIBUTES;
   ;	
	mov	bx,si
	shl	bx,1
	shl	bx,1
	shl	bx,1
	mov	word ptr DGROUP:_blocks[bx+12],0
   ;	
   ;	      return;
   ;	
	jmp	short @8@530
@8@362:
	inc	si
@8@386:
	mov	ax,word ptr DGROUP:_numblocks
	dec	ax
	cmp	ax,si
	jle	@@84
	jmp	@8@74
@@84:
   ;	
   ;	lookmore:;
   ;	    }
   ;	    //
   ;	    // didn't find any space, so compress and try again
   ;	    //
   ;	    if (try==0)
   ;	
	cmp	word ptr [bp-4],0
	jne	short @8@458
   ;	
   ;	      MMSortMem();
   ;	
	call	near ptr _MMSortMem
@8@458:
	inc	word ptr [bp-4]
@8@482:
	cmp	word ptr [bp-4],2
	jge	@@85
	jmp	@8@50
@@85:
   ;	
   ;	  }
   ;	
   ;	//puts("");
   ;	//MMBlockDump();	// DEBUG
   ;	  Quit ("Memory manager error: Out of memory!");
   ;	
	mov	ax,offset DGROUP:s@+78
	push	ax
	call	near ptr _Quit
	pop	cx
@8@530:
   ;	
   ;	}
   ;	
	pop	di
	pop	si
	mov	sp,bp
	pop	bp
	ret	
_MMGetPtr	endp
   ;	
   ;	void MMFreePtr (memptr *baseptr)
   ;	
	assume	cs:_TEXT
_MMFreePtr	proc	near
	push	bp
	mov	bp,sp
   ;	
   ;	{
   ;	  RemoveBlock(FindBlock (baseptr));
   ;	
	push	word ptr [bp+4]
	call	near ptr _FindBlock
	pop	cx
	push	ax
	call	near ptr _RemoveBlock
	pop	cx
   ;	
   ;	}
   ;	
	pop	bp
	ret	
_MMFreePtr	endp
   ;	
   ;	void MMSetPurge (memptr *baseptr, int purge)
   ;	
	assume	cs:_TEXT
_MMSetPurge	proc	near
	push	bp
	mov	bp,sp
	push	si
	push	di
   ;	
   ;	{
   ;	  int block;
   ;	  unsigned attr;
   ;	
   ;	  block = FindBlock (baseptr);
   ;	
	push	word ptr [bp+4]
	call	near ptr _FindBlock
	pop	cx
	mov	di,ax
   ;	
   ;	
   ;	  attr = blocks[block].attributes;
   ;	
	mov	bx,di
	shl	bx,1
	shl	bx,1
	shl	bx,1
	mov	si,word ptr DGROUP:_blocks[bx+4]
   ;	
   ;	  attr &= 0xffff - PURGEBITS;
   ;	
	and	si,65532
   ;	
   ;	  attr |= purge;		// set bits in attributes
   ;	
	or	si,word ptr [bp+6]
   ;	
   ;	  blocks[block].attributes = attr;
   ;	
	mov	bx,di
	shl	bx,1
	shl	bx,1
	shl	bx,1
	mov	word ptr DGROUP:_blocks[bx+4],si
   ;	
   ;	}
   ;	
	pop	di
	pop	si
	pop	bp
	ret	
_MMSetPurge	endp
   ;	
   ;	void MoveParaBase (unsigned source, unsigned dest, unsigned words)
   ;	
	assume	cs:_TEXT
_MoveParaBase	proc	near
	push	bp
	mov	bp,sp
	push	si
	push	di
   ;	
   ;	{
   ;	asm	mov	cx,words
   ;	
		mov		cx,[bp+8]
   ;	
   ;	asm	xor	si,si
   ;	
		xor		si,si
   ;	
   ;	asm	xor	di,di
   ;	
		xor		di,di
   ;	
   ;	asm	mov	ax,source
   ;	
		mov		ax,[bp+4]
   ;	
   ;	asm	mov	bx,dest
   ;	
		mov		bx,[bp+6]
   ;	
   ;	asm	mov	ds,source
   ;	
		mov		ds,[bp+4]
   ;	
   ;	asm	mov	es,dest
   ;	
		mov		es,[bp+6]
   ;	
   ;	asm	rep	movsw
   ;	
		rep	movsw	
   ;	
   ;	asm	mov	ax,ss
   ;	
		mov		ax,ss
   ;	
   ;	asm	mov	ds,ax
   ;	
		mov		ds,ax
   ;	
   ;	}
   ;	
	pop	di
	pop	si
	pop	bp
	ret	
_MoveParaBase	endp
   ;	
   ;	void MoveParaBaseUp (unsigned source, unsigned dest, unsigned words)
   ;	
	assume	cs:_TEXT
_MoveParaBaseUp	proc	near
	push	bp
	mov	bp,sp
	push	si
	push	di
   ;	
   ;	{
   ;	asm	mov	cx,words
   ;	
		mov		cx,[bp+8]
   ;	
   ;	asm	mov	si,cx
   ;	
		mov		si,cx
   ;	
   ;	asm	dec	si
   ;	
		dec		si
   ;	
   ;	asm	shl	si,1
   ;	
		shl		si,1
   ;	
   ;	asm	mov	di,si
   ;	
		mov		di,si
   ;	
   ;	asm	mov	ax,source
   ;	
		mov		ax,[bp+4]
   ;	
   ;	asm	mov	bx,dest
   ;	
		mov		bx,[bp+6]
   ;	
   ;	asm	mov	ds,source
   ;	
		mov		ds,[bp+4]
   ;	
   ;	asm	mov	es,dest
   ;	
		mov		es,[bp+6]
   ;	
   ;	asm	rep	movsw
   ;	
		rep	movsw	
   ;	
   ;	asm	mov	ax,ss
   ;	
		mov		ax,ss
   ;	
   ;	asm	mov	ds,ax
   ;	
		mov		ds,ax
   ;	
   ;	}
   ;	
	pop	di
	pop	si
	pop	bp
	ret	
_MoveParaBaseUp	endp
   ;	
   ;	void MoveParas (unsigned source, unsigned dest, unsigned paragraphs)
   ;	
	assume	cs:_TEXT
_MoveParas	proc	near
	push	bp
	mov	bp,sp
	push	si
	push	di
	mov	si,word ptr [bp+4]
	mov	di,word ptr [bp+6]
   ;	
   ;	{
   ;	  if (source>dest)
   ;	
	cmp	si,di
	jbe	short @13@170
   ;	
   ;	  {
   ;	asm	cld
   ;	
		cld	
	jmp	short @13@122
@13@98:
   ;	
   ;	    while (paragraphs>0xfff)
   ;	    {
   ;	      MoveParaBase (source,dest,0xfff*8);
   ;	
	mov	ax,32760
	push	ax
	push	di
	push	si
	call	near ptr _MoveParaBase
	add	sp,6
   ;	
   ;	      source += 0xfff*8;
   ;	
	add	si,32760
   ;	
   ;	      dest += 0xfff*8;
   ;	
	add	di,32760
   ;	
   ;	      paragraphs -= 0xfff;
   ;	
	sub	word ptr [bp+8],4095
@13@122:
	cmp	word ptr [bp+8],4095
	ja	short @13@98
   ;	
   ;	    }
   ;	    MoveParaBase (source,dest,paragraphs*8);
   ;	
	mov	ax,word ptr [bp+8]
	shl	ax,1
	shl	ax,1
	shl	ax,1
	push	ax
	push	di
	push	si
	call	near ptr _MoveParaBase
	add	sp,6
   ;	
   ;	  }
   ;	
	jmp	short @13@314
@13@170:
   ;	
   ;	  else
   ;	  {
   ;	asm	std
   ;	
		std	
   ;	
   ;	    source+=paragraphs;
   ;	
	add	si,word ptr [bp+8]
   ;	
   ;	    dest+=paragraphs;
   ;	
	add	di,word ptr [bp+8]
	jmp	short @13@242
@13@218:
   ;	
   ;	    while (paragraphs>0xfff)
   ;	    {
   ;	      source-=0xfff;
   ;	
	sub	si,4095
   ;	
   ;	      dest-=0xfff;
   ;	
	sub	di,4095
   ;	
   ;	      MoveParaBaseUp (source,dest,0xfff*8);
   ;	
	mov	ax,32760
	push	ax
	push	di
	push	si
	call	near ptr _MoveParaBaseUp
	add	sp,6
   ;	
   ;	      paragraphs -= 0xfff;
   ;	
	sub	word ptr [bp+8],4095
@13@242:
	cmp	word ptr [bp+8],4095
	ja	short @13@218
   ;	
   ;	    }
   ;	    source-=paragraphs;
   ;	
	sub	si,word ptr [bp+8]
   ;	
   ;	    dest-=paragraphs;
   ;	
	sub	di,word ptr [bp+8]
   ;	
   ;	    MoveParaBaseUp (source,dest,paragraphs*8);
   ;	
	mov	ax,word ptr [bp+8]
	shl	ax,1
	shl	ax,1
	shl	ax,1
	push	ax
	push	di
	push	si
	call	near ptr _MoveParaBaseUp
	add	sp,6
   ;	
   ;	asm	cld
   ;	
		cld	
@13@314:
   ;	
   ;	  }
   ;	}
   ;	
	pop	di
	pop	si
	pop	bp
	ret	
_MoveParas	endp
   ;	
   ;	void PushUp (int move)
   ;	
	assume	cs:_TEXT
_PushUp	proc	near
	push	bp
	mov	bp,sp
	sub	sp,6
	push	si
	push	di
	mov	di,word ptr [bp+4]
   ;	
   ;	{
   ;	  unsigned source,dest,size;
   ;	  int i;
   ;	
   ;	  size = blocks[move].length;
   ;	
	mov	bx,di
	shl	bx,1
	shl	bx,1
	shl	bx,1
	mov	ax,word ptr DGROUP:_blocks[bx+2]
	mov	word ptr [bp-6],ax
   ;	
   ;	  source = blocks[move].start;
   ;	
	mov	bx,di
	shl	bx,1
	shl	bx,1
	shl	bx,1
	mov	ax,word ptr DGROUP:_blocks[bx]
	mov	word ptr [bp-2],ax
   ;	
   ;	
   ;	  for (i=numblocks-1;i>keyblock;i--)
   ;	
	mov	ax,word ptr DGROUP:_numblocks
	dec	ax
	mov	si,ax
	jmp	@14@122
@14@50:
   ;	
   ;	  {
   ;	  //
   ;	  // if the block can fit under this block, move it
   ;	  //
   ;	    dest = blocks[i].start - size;
   ;	
	mov	bx,si
	shl	bx,1
	shl	bx,1
	shl	bx,1
	mov	ax,word ptr DGROUP:_blocks[bx]
	sub	ax,word ptr [bp-6]
	mov	word ptr [bp-4],ax
   ;	
   ;	    if (blocks[i-1].start+blocks[i-1].length <= dest)
   ;	
	mov	bx,si
	shl	bx,1
	shl	bx,1
	shl	bx,1
	mov	ax,word ptr DGROUP:_blocks[bx-8]
	mov	bx,si
	shl	bx,1
	shl	bx,1
	shl	bx,1
	add	ax,word ptr DGROUP:_blocks[bx-6]
	cmp	ax,word ptr [bp-4]
	ja	short @14@98
   ;	
   ;	    {
   ;	    //
   ;	    // make a copy of block 'move' under block 'i'
   ;	    //
   ;	      InsertBlock (i-1);
   ;	
	mov	ax,si
	dec	ax
	push	ax
	call	near ptr _InsertBlock
	pop	cx
   ;	
   ;	      blocks[i] = blocks[move];
   ;	
	mov	ax,si
	shl	ax,1
	shl	ax,1
	shl	ax,1
	add	ax,offset DGROUP:_blocks
	push	ds
	push	ax
	mov	ax,di
	shl	ax,1
	shl	ax,1
	shl	ax,1
	add	ax,offset DGROUP:_blocks
	push	ds
	push	ax
	mov	cx,8
	call	near ptr N_SCOPY@
   ;	
   ;	      blocks[i].start = dest;
   ;	
	mov	bx,si
	shl	bx,1
	shl	bx,1
	shl	bx,1
	mov	ax,word ptr [bp-4]
	mov	word ptr DGROUP:_blocks[bx],ax
   ;	
   ;	      *(blocks[i].useptr) = (void _seg *)dest;	// modify the pointer to the new spot
   ;	
	mov	bx,si
	shl	bx,1
	shl	bx,1
	shl	bx,1
	mov	bx,word ptr DGROUP:_blocks[bx+6]
	mov	ax,word ptr [bp-4]
	mov	word ptr [bx],ax
   ;	
   ;	      MoveParas (source,dest,size);
   ;	
	push	word ptr [bp-6]
	push	word ptr [bp-4]
	push	word ptr [bp-2]
	call	near ptr _MoveParas
	add	sp,6
   ;	
   ;	      break;
   ;	
	jmp	short @14@146
@14@98:
	dec	si
@14@122:
	cmp	si,word ptr DGROUP:_keyblock
	jle	@@86
	jmp	@14@50
@@86:
@14@146:
   ;	
   ;	    }
   ;	  }
   ;	
   ;	  //
   ;	  // erase original position
   ;	  //
   ;	  RemoveBlock (move);
   ;	
	push	di
	call	near ptr _RemoveBlock
	pop	cx
   ;	
   ;	  keyblock--;		// because a block below it was removed
   ;	
	dec	word ptr DGROUP:_keyblock
   ;	
   ;	}
   ;	
	pop	di
	pop	si
	mov	sp,bp
	pop	bp
	ret	
_PushUp	endp
   ;	
   ;	void PushDown (void)
   ;	
	assume	cs:_TEXT
_PushDown	proc	near
	push	bp
	mov	bp,sp
	sub	sp,10
	push	si
	push	di
   ;	
   ;	{
   ;	  unsigned source,dest,size,end,lowblock,checkblock,i;
   ;	
   ;	  size = blocks[keyblock].length;
   ;	
	mov	bx,word ptr DGROUP:_keyblock
	shl	bx,1
	shl	bx,1
	shl	bx,1
	mov	ax,word ptr DGROUP:_blocks[bx+2]
	mov	word ptr [bp-4],ax
   ;	
   ;	  source = blocks[keyblock].start;
   ;	
	mov	bx,word ptr DGROUP:_keyblock
	shl	bx,1
	shl	bx,1
	shl	bx,1
	mov	ax,word ptr DGROUP:_blocks[bx]
	mov	word ptr [bp-2],ax
   ;	
   ;	
   ;	//
   ;	// find the lowest space it can be moved into
   ;	//
   ;	  for (lowblock = 0;lowblock<keyblock;lowblock++)
   ;	
	xor	si,si
	jmp	@15@458
@15@50:
   ;	
   ;	    if (!(blocks[lowblock].attributes & PURGEBITS) ||
   ;	
   ;	
   ;		blocks[lowblock].attributes & LOCKBIT)
   ;	
	mov	bx,si
	shl	bx,1
	shl	bx,1
	shl	bx,1
	test	word ptr DGROUP:_blocks[bx+4],3
	je	short @15@98
	mov	bx,si
	shl	bx,1
	shl	bx,1
	shl	bx,1
	test	word ptr DGROUP:_blocks[bx+4],32768
	jne	@@87
	jmp	@15@434
@@87:
@15@98:
   ;	
   ;	    {
   ;	    //
   ;	    // found a locked or nonpurgable block below keyblock
   ;	    //
   ;	    // see if there is enough space to move block
   ;	    //
   ;	      dest = blocks[lowblock].start + blocks[lowblock].length;
   ;	
	mov	bx,si
	shl	bx,1
	shl	bx,1
	shl	bx,1
	mov	ax,word ptr DGROUP:_blocks[bx]
	mov	bx,si
	shl	bx,1
	shl	bx,1
	shl	bx,1
	add	ax,word ptr DGROUP:_blocks[bx+2]
	mov	di,ax
   ;	
   ;	      end = dest+size;
   ;	
	mov	ax,di
	add	ax,word ptr [bp-4]
	mov	word ptr [bp-6],ax
   ;	
   ;	
   ;	    //
   ;	    // see if any of the blocks in the middle can be moved away
   ;	    //
   ;	      checkblock = lowblock+1;
   ;	
	mov	ax,si
	inc	ax
	mov	word ptr [bp-8],ax
	jmp	short @15@194
@15@122:
   ;	
   ;	      while (checkblock < keyblock && blocks[checkblock].start<end)
   ;	      {
   ;		if (!(blocks[checkblock].attributes & PURGEBITS) )
   ;	
	mov	bx,word ptr [bp-8]
	shl	bx,1
	shl	bx,1
	shl	bx,1
	test	word ptr DGROUP:_blocks[bx+4],3
	jne	short @15@170
   ;	
   ;		  goto nofit;   // can't fit between two locked blocks
   ;	
	jmp	@15@434
@15@170:
   ;	
   ;		//
   ;		// push the block up or remove it, in either case dropping
   ;		// keyblock and changing blocks[checkblock]
   ;		//
   ;		PushUp (checkblock);
   ;	
	push	word ptr [bp-8]
	call	near ptr _PushUp
	pop	cx
@15@194:
	mov	ax,word ptr [bp-8]
	cmp	ax,word ptr DGROUP:_keyblock
	jae	short @15@242
	mov	bx,word ptr [bp-8]
	shl	bx,1
	shl	bx,1
	shl	bx,1
	mov	ax,word ptr DGROUP:_blocks[bx]
	cmp	ax,word ptr [bp-6]
	jb	short @15@122
@15@242:
   ;	
   ;	      }
   ;	//
   ;	// move it!
   ;	//
   ;	      if (dest != source)
   ;	
	cmp	di,word ptr [bp-2]
	jne	@@88
	jmp	@15@410
@@88:
   ;	
   ;	      {
   ;		MoveParas (source,dest,size);
   ;	
	push	word ptr [bp-4]
	push	di
	push	word ptr [bp-2]
	call	near ptr _MoveParas
	add	sp,6
   ;	
   ;		blocks[keyblock].start = dest;
   ;	
	mov	bx,word ptr DGROUP:_keyblock
	shl	bx,1
	shl	bx,1
	shl	bx,1
	mov	word ptr DGROUP:_blocks[bx],di
   ;	
   ;		*(blocks[keyblock].useptr) = (void _seg *)dest;	// modify the pointer to the new spot
   ;	
	mov	bx,word ptr DGROUP:_keyblock
	shl	bx,1
	shl	bx,1
	shl	bx,1
	mov	bx,word ptr DGROUP:_blocks[bx+6]
	mov	word ptr [bx],di
   ;	
   ;		if (lowblock<keyblock-1)
   ;	
	mov	ax,word ptr DGROUP:_keyblock
	dec	ax
	cmp	ax,si
	ja	@@89
	jmp	@15@410
@@89:
   ;	
   ;		{
   ;		//
   ;		// reorder the block records
   ;		//
   ;		  tempblock = blocks[keyblock];
   ;	
	mov	ax,offset DGROUP:_tempblock
	push	ds
	push	ax
	mov	ax,word ptr DGROUP:_keyblock
	shl	ax,1
	shl	ax,1
	shl	ax,1
	add	ax,offset DGROUP:_blocks
	push	ds
	push	ax
	mov	cx,8
	call	near ptr N_SCOPY@
   ;	
   ;		  for (i=keyblock;i>lowblock+1;i--)
   ;	
	mov	ax,word ptr DGROUP:_keyblock
	mov	word ptr [bp-10],ax
	jmp	short @15@362
@15@314:
   ;	
   ;		    blocks[i]=blocks[i-1];
   ;	
	mov	ax,word ptr [bp-10]
	shl	ax,1
	shl	ax,1
	shl	ax,1
	add	ax,offset DGROUP:_blocks
	push	ds
	push	ax
	mov	ax,word ptr [bp-10]
	dec	ax
	shl	ax,1
	shl	ax,1
	shl	ax,1
	add	ax,offset DGROUP:_blocks
	push	ds
	push	ax
	mov	cx,8
	call	near ptr N_SCOPY@
	dec	word ptr [bp-10]
@15@362:
	mov	ax,si
	inc	ax
	cmp	ax,word ptr [bp-10]
	jb	short @15@314
   ;	
   ;		  blocks[lowblock+1] = tempblock;
   ;	
	mov	ax,si
	inc	ax
	shl	ax,1
	shl	ax,1
	shl	ax,1
	add	ax,offset DGROUP:_blocks
	push	ds
	push	ax
	mov	ax,offset DGROUP:_tempblock
	push	ds
	push	ax
	mov	cx,8
	call	near ptr N_SCOPY@
@15@410:
   ;	
   ;		}
   ;	
   ;	//MMBlockDump();	// DEBUG
   ;	      }
   ;	      return;
   ;	
	jmp	short @15@482
@15@434:
	inc	si
@15@458:
	cmp	si,word ptr DGROUP:_keyblock
	jae	@@90
	jmp	@15@50
@@90:
@15@482:
   ;	
   ;	
   ;	 nofit:;		// keep looking...
   ;	
   ;	    }
   ;	}
   ;	
	pop	di
	pop	si
	mov	sp,bp
	pop	bp
	ret	
_PushDown	endp
   ;	
   ;	void MMSortMem (void)
   ;	
	assume	cs:_TEXT
_MMSortMem	proc	near
	push	bp
	mov	bp,sp
	dec	sp
	dec	sp
	push	si
	push	di
   ;	
   ;	{
   ;	  unsigned i,source,dest;
   ;	
   ;	  keyblock = 0;
   ;	
	mov	word ptr DGROUP:_keyblock,0
@16@50:
   ;	
   ;	
   ;	  do
   ;	  {
   ;	    keyblock++;
   ;	
	inc	word ptr DGROUP:_keyblock
   ;	
   ;	
   ;	    //
   ;	    // non-purgable, unlocked blocks will be pushed low in memory
   ;	    //
   ;	    if ( !(blocks[keyblock].attributes & PURGEBITS) &&
   ;	
   ;	
   ;		 !(blocks[keyblock].attributes & LOCKBIT) )
   ;	
	mov	bx,word ptr DGROUP:_keyblock
	shl	bx,1
	shl	bx,1
	shl	bx,1
	test	word ptr DGROUP:_blocks[bx+4],3
	jne	short @16@122
	mov	bx,word ptr DGROUP:_keyblock
	shl	bx,1
	shl	bx,1
	shl	bx,1
	test	word ptr DGROUP:_blocks[bx+4],32768
	jne	short @16@122
   ;	
   ;	      PushDown ();
   ;	
	call	near ptr _PushDown
@16@122:
   ;	
   ;	
   ;	  } while (keyblock<numblocks-1);
   ;	
	mov	ax,word ptr DGROUP:_numblocks
	dec	ax
	cmp	ax,word ptr DGROUP:_keyblock
	jg	short @16@50
   ;	
   ;	
   ;	
   ;	  for (i=numblocks-2;i>0;i--)
   ;	
	mov	ax,word ptr DGROUP:_numblocks
	add	ax,65534
	mov	si,ax
	jmp	@16@266
@16@170:
   ;	
   ;	  {
   ;	    //
   ;	    // push all purgable blocks as high as possible
   ;	    // Currently they are NOT moved around locked blocks!
   ;	    //
   ;	    if ( blocks[i].attributes & PURGEBITS )
   ;	
	mov	bx,si
	shl	bx,1
	shl	bx,1
	shl	bx,1
	test	word ptr DGROUP:_blocks[bx+4],3
	jne	@@91
	jmp	@16@242
@@91:
   ;	
   ;	    {
   ;	      source= blocks[i].start;
   ;	
	mov	bx,si
	shl	bx,1
	shl	bx,1
	shl	bx,1
	mov	ax,word ptr DGROUP:_blocks[bx]
	mov	word ptr [bp-2],ax
   ;	
   ;	      dest= blocks[i+1].start-blocks[i].length;
   ;	
	mov	bx,si
	inc	bx
	shl	bx,1
	shl	bx,1
	shl	bx,1
	mov	ax,word ptr DGROUP:_blocks[bx]
	mov	bx,si
	shl	bx,1
	shl	bx,1
	shl	bx,1
	sub	ax,word ptr DGROUP:_blocks[bx+2]
	mov	di,ax
   ;	
   ;	      if (source!=dest)
   ;	
	cmp	word ptr [bp-2],di
	je	short @16@242
   ;	
   ;	      {
   ;		MoveParas (source,dest,blocks[i].length);
   ;	
	mov	bx,si
	shl	bx,1
	shl	bx,1
	shl	bx,1
	push	word ptr DGROUP:_blocks[bx+2]
	push	di
	push	word ptr [bp-2]
	call	near ptr _MoveParas
	add	sp,6
   ;	
   ;		blocks[i].start = dest;
   ;	
	mov	bx,si
	shl	bx,1
	shl	bx,1
	shl	bx,1
	mov	word ptr DGROUP:_blocks[bx],di
   ;	
   ;		*(blocks[i].useptr) = (void _seg *)dest;	// modify the pointer to the new spot
   ;	
	mov	bx,si
	shl	bx,1
	shl	bx,1
	shl	bx,1
	mov	bx,word ptr DGROUP:_blocks[bx+6]
	mov	word ptr [bx],di
@16@242:
	dec	si
@16@266:
	or	si,si
	jbe	@@92
	jmp	@16@170
@@92:
   ;	
   ;	      }
   ;	    }
   ;	  }
   ;	
   ;	  PatchPointers();		// let the main program fix up any
   ;	
	call	near ptr _PatchPointers
   ;	
   ;					// internal references
   ;	}
   ;	
	pop	di
	pop	si
	mov	sp,bp
	pop	bp
	ret	
_MMSortMem	endp
	?debug	C E900104D1615433A5C42435C494E434C5544455C535444494F2E48
   ;	
   ;	void MMBlockDump (void)
   ;	
	assume	cs:_TEXT
_MMBlockDump	proc	near
	push	bp
	mov	bp,sp
	push	si
	push	di
   ;	
   ;	{
   ;	  int i;
   ;	  unsigned free;
   ;	
   ;	  fprintf (stdprn,"-------------\n");
   ;	
	mov	ax,offset DGROUP:s@+115
	push	ax
	mov	ax,offset DGROUP:__streams+64
	push	ax
	call	near ptr _fprintf
	pop	cx
	pop	cx
   ;	
   ;	  for (i=0;i<numblocks;i++)
   ;	
	xor	si,si
	jmp	@17@146
@17@50:
   ;	
   ;	  {
   ;	    fprintf (stdprn,"Start:%4X\tLength:%4X\tAttr:%4X\tPtr:%p\n"
   ;	
   ;	
   ;	    ,blocks[i].start,blocks[i].length,blocks[i].attributes,blocks[i].useptr);
   ;	
	mov	bx,si
	shl	bx,1
	shl	bx,1
	shl	bx,1
	push	word ptr DGROUP:_blocks[bx+6]
	mov	bx,si
	shl	bx,1
	shl	bx,1
	shl	bx,1
	push	word ptr DGROUP:_blocks[bx+4]
	mov	bx,si
	shl	bx,1
	shl	bx,1
	shl	bx,1
	push	word ptr DGROUP:_blocks[bx+2]
	mov	bx,si
	shl	bx,1
	shl	bx,1
	shl	bx,1
	push	word ptr DGROUP:_blocks[bx]
	mov	ax,offset DGROUP:s@+130
	push	ax
	mov	ax,offset DGROUP:__streams+64
	push	ax
	call	near ptr _fprintf
	add	sp,12
   ;	
   ;	    if (i<numblocks-1)
   ;	
	mov	ax,word ptr DGROUP:_numblocks
	dec	ax
	cmp	ax,si
	jle	short @17@122
   ;	
   ;	    {
   ;	      free = blocks[i+1].start - (blocks[i].start+blocks[i].length);
   ;	
	mov	bx,si
	shl	bx,1
	shl	bx,1
	shl	bx,1
	mov	ax,word ptr DGROUP:_blocks[bx]
	mov	bx,si
	shl	bx,1
	shl	bx,1
	shl	bx,1
	add	ax,word ptr DGROUP:_blocks[bx+2]
	mov	bx,si
	shl	bx,1
	shl	bx,1
	shl	bx,1
	mov	dx,word ptr DGROUP:_blocks[bx+8]
	sub	dx,ax
	mov	di,dx
   ;	
   ;	      if (free)
   ;	
	or	di,di
	je	short @17@122
   ;	
   ;		fprintf (stdprn,"### Free:%X\n",free);
   ;	
	push	di
	mov	ax,offset DGROUP:s@+168
	push	ax
	mov	ax,offset DGROUP:__streams+64
	push	ax
	call	near ptr _fprintf
	add	sp,6
@17@122:
	inc	si
@17@146:
	cmp	si,word ptr DGROUP:_numblocks
	jge	@@93
	jmp	@17@50
@@93:
   ;	
   ;	    }
   ;	  }
   ;	  puts("");
   ;	
	mov	ax,offset DGROUP:s@+181
	push	ax
	call	near ptr _puts
	pop	cx
   ;	
   ;	}
   ;	
	pop	di
	pop	si
	pop	bp
	ret	
_MMBlockDump	endp
   ;	
   ;	unsigned MMUnusedMemory (void)
   ;	
	assume	cs:_TEXT
_MMUnusedMemory	proc	near
	push	bp
	mov	bp,sp
	push	si
	push	di
   ;	
   ;	{
   ;	  int i;
   ;	  unsigned free;
   ;	
   ;	  free = 0;
   ;	
	xor	di,di
   ;	
   ;	
   ;	  for (i=0;i<numblocks;i++)
   ;	
	xor	si,si
	jmp	short @18@122
@18@50:
   ;	
   ;	  {
   ;	    if (i<numblocks-1)
   ;	
	mov	ax,word ptr DGROUP:_numblocks
	dec	ax
	cmp	ax,si
	jle	short @18@98
   ;	
   ;	      free += blocks[i+1].start - (blocks[i].start+blocks[i].length);
   ;	
	mov	bx,si
	shl	bx,1
	shl	bx,1
	shl	bx,1
	mov	ax,word ptr DGROUP:_blocks[bx]
	mov	bx,si
	shl	bx,1
	shl	bx,1
	shl	bx,1
	add	ax,word ptr DGROUP:_blocks[bx+2]
	mov	bx,si
	shl	bx,1
	shl	bx,1
	shl	bx,1
	mov	dx,word ptr DGROUP:_blocks[bx+8]
	sub	dx,ax
	add	di,dx
@18@98:
	inc	si
@18@122:
	cmp	si,word ptr DGROUP:_numblocks
	jl	short @18@50
   ;	
   ;	  }
   ;	
   ;	  return free;
   ;	
	mov	ax,di
	jmp	short @18@170
@18@170:
   ;	
   ;	}
   ;	
	pop	di
	pop	si
	pop	bp
	ret	
_MMUnusedMemory	endp
   ;	
   ;	unsigned MMTotalFree (void)
   ;	
	assume	cs:_TEXT
_MMTotalFree	proc	near
	push	bp
	mov	bp,sp
	push	si
	push	di
   ;	
   ;	{
   ;	  int i;
   ;	  unsigned free;
   ;	
   ;	  free = 0;
   ;	
	xor	di,di
   ;	
   ;	
   ;	  for (i=0;i<numblocks;i++)
   ;	
	xor	si,si
	jmp	short @19@170
@19@50:
   ;	
   ;	  {
   ;	    if (blocks[i].attributes & PURGEBITS)
   ;	
	mov	bx,si
	shl	bx,1
	shl	bx,1
	shl	bx,1
	test	word ptr DGROUP:_blocks[bx+4],3
	je	short @19@98
   ;	
   ;	      free += blocks[i].length;
   ;	
	mov	bx,si
	shl	bx,1
	shl	bx,1
	shl	bx,1
	add	di,word ptr DGROUP:_blocks[bx+2]
@19@98:
   ;	
   ;	    if (i<numblocks-1)
   ;	
	mov	ax,word ptr DGROUP:_numblocks
	dec	ax
	cmp	ax,si
	jle	short @19@146
   ;	
   ;	      free += blocks[i+1].start - (blocks[i].start+blocks[i].length);
   ;	
	mov	bx,si
	shl	bx,1
	shl	bx,1
	shl	bx,1
	mov	ax,word ptr DGROUP:_blocks[bx]
	mov	bx,si
	shl	bx,1
	shl	bx,1
	shl	bx,1
	add	ax,word ptr DGROUP:_blocks[bx+2]
	mov	bx,si
	shl	bx,1
	shl	bx,1
	shl	bx,1
	mov	dx,word ptr DGROUP:_blocks[bx+8]
	sub	dx,ax
	add	di,dx
@19@146:
	inc	si
@19@170:
	cmp	si,word ptr DGROUP:_numblocks
	jl	short @19@50
   ;	
   ;	  }
   ;	
   ;	  return free;
   ;	
	mov	ax,di
	jmp	short @19@218
@19@218:
   ;	
   ;	}
   ;	
	pop	di
	pop	si
	pop	bp
	ret	
_MMTotalFree	endp
_TEXT	ends
_BSS	segment word public 'BSS'
_totalmem	label	word
	db	2 dup (?)
_blocks	label	word
	db	12000 dup (?)
_farheap	label	dword
	db	4 dup (?)
_nearheap	label	word
	db	2 dup (?)
_keyblock	label	word
	db	2 dup (?)
_tempblock	label	word
	db	8 dup (?)
_numblocks	label	word
	db	2 dup (?)
_EMSpresent	label	word
	db	2 dup (?)
_XMSpresent	label	word
	db	2 dup (?)
	?debug	C E9
_BSS	ends
_DATA	segment word public 'DATA'
s@	label	byte
	db	'Memory manager error: Block not found!'
	db	0
	db	'Memory manager error: Too many blocks!'
	db	0
	db	'Memory manager error: Out of memory!'
	db	0
	db	'-------------'
	db	10
	db	0
	db	'Start:%4X'
	db	9
	db	'Length:%4X'
	db	9
	db	'Attr:%4X'
	db	9
	db	'Ptr:%p'
	db	10
	db	0
	db	'### Free:%X'
	db	10
	db	0
	db	0
_DATA	ends
_TEXT	segment byte public 'CODE'
_TEXT	ends
	public	_MMShutdown
	public	_MMBlockDump
	extrn	_farcoreleft:near
	public	_XMSpresent
	public	_MMTotalFree
	public	_MMStartup
	public	_EMSpresent
	public	_MMFreePtr
	public	_RemoveBlock
	extrn	_farmalloc:near
	public	_PushDown
	public	_numblocks
	public	_MMSetPurge
	public	_MMGetPtr
	public	_tempblock
	public	_MMSortMem
	public	_FindBlock
	extrn	_free:near
	public	_keyblock
	public	_nearheap
	extrn	_malloc:near
	extrn	_farfree:near
	public	_farheap
	extrn	_puts:near
	public	_MoveParaBase
	extrn	_fprintf:near
	public	_MMMapEMS
	extrn	_Quit:near
	public	_PushUp
	public	_MoveParaBaseUp
	public	_CheckForEMS
	public	_blocks
	extrn	N_SCOPY@:far
	extrn	_movedata:near
	extrn	N_LXURSH@:far
	extrn	__streams:word
	extrn	N_LDIV@:far
	public	_totalmem
	public	_MoveParas
	extrn	_coreleft:near
	public	_MMUnusedMemory
	public	_InsertBlock
	extrn	_PatchPointers:near
	end
