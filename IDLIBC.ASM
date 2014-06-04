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
	?debug	S "idlibc.c"
	?debug	C E92C869D160869646C6962632E63
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
_TEXT	segment byte public 'CODE'
   ;	
   ;	void CalibrateJoy (int joynum)
   ;	
	assume	cs:_TEXT
_CalibrateJoy	proc	near
	push	bp
	mov	bp,sp
	sub	sp,42
	push	si
	push	di
	mov	si,word ptr [bp+4]
   ;	
   ;	{
   ;	  int stage,dx,dy,xl,yl,xh,yh;
   ;	  ControlStruct ctr;
   ;	
   ;	  ExpWin (34,11);
   ;	
	mov	ax,11
	push	ax
	mov	ax,34
	push	ax
	call	near ptr _ExpWin
	pop	cx
	pop	cx
   ;	
   ;	
   ;	
   ;	  fontcolor=13;
   ;	
	mov	word ptr DGROUP:_fontcolor,13
   ;	
   ;	  CPPrint("Joystick Configuration\n");
   ;	
	mov	ax,offset DGROUP:s@
	push	ax
	call	near ptr _CPPrint
	pop	cx
   ;	
   ;	  py+=6;
   ;	
	add	word ptr DGROUP:_py,6
   ;	
   ;	  fontcolor=15;
   ;	
	mov	word ptr DGROUP:_fontcolor,15
   ;	
   ;	  PPrint("Hold the joystick in the UPPER LEFT\n");
   ;	
	mov	ax,offset DGROUP:s@+24
	push	ax
	call	near ptr _PPrint
	pop	cx
   ;	
   ;	  PPrint("corner and press a button:");
   ;	
	mov	ax,offset DGROUP:s@+61
	push	ax
	call	near ptr _PPrint
	pop	cx
   ;	
   ;	  stage=15;
   ;	
	mov	di,15
   ;	
   ;	  sx=(px+7)/8;
   ;	
	mov	ax,word ptr DGROUP:_px
	add	ax,7
	shr	ax,1
	shr	ax,1
	shr	ax,1
	mov	word ptr DGROUP:_sx,ax
@1@50:
   ;	
   ;	  do				// wait for a button press
   ;	  {
   ;	    DrawChar (sx,py,stage);
   ;	
	push	di
	push	word ptr DGROUP:_py
	push	word ptr DGROUP:_sx
	call	near ptr _DrawChar
	add	sp,6
   ;	
   ;	    WaitVBL (3);
   ;	
	mov	ax,3
	push	ax
	call	near ptr _WaitVBL
	pop	cx
   ;	
   ;	    if (++stage==23)
   ;	
	inc	di
	mov	ax,di
	cmp	ax,23
	jne	short @1@98
   ;	
   ;	      stage=15;
   ;	
	mov	di,15
@1@98:
   ;	
   ;	    ReadJoystick (joynum,&xl,&yl);
   ;	
	lea	ax,word ptr [bp-8]
	push	ax
	lea	ax,word ptr [bp-6]
	push	ax
	push	si
	call	near ptr _ReadJoystick
	add	sp,6
   ;	
   ;	    ctr = ControlJoystick(joynum);
   ;	
	lea	ax,word ptr [bp-18]
	push	ss
	push	ax
	push	si
	push	ss
	lea	ax,word ptr [bp-24]
	push	ax
	call	near ptr _ControlJoystick
	add	sp,6
	lea	ax,word ptr [bp-24]
	push	ss
	push	ax
	mov	cx,6
	call	near ptr N_SCOPY@
   ;	
   ;	    if (keydown[1])
   ;	
	cmp	byte ptr DGROUP:_keydown+1,0
	je	short @1@146
   ;	
   ;	      return;
   ;	
	jmp	@1@674
@1@146:
   ;	
   ;	  } while (ctr.button1!= 1 && ctr.button2!=1);
   ;	
	cmp	word ptr [bp-16],1
	je	short @1@194
	cmp	word ptr [bp-14],1
	jne	short @1@50
@1@194:
   ;	
   ;	   DrawChar(sx,py,BLANKCHAR);
   ;	
	mov	ax,9
	push	ax
	push	word ptr DGROUP:_py
	push	word ptr DGROUP:_sx
	call	near ptr _DrawChar
	add	sp,6
@1@218:
   ;	
   ;	  do                  		// wait for the button release
   ;	  {
   ;	    ctr = ControlJoystick(joynum);
   ;	
	lea	ax,word ptr [bp-18]
	push	ss
	push	ax
	push	si
	push	ss
	lea	ax,word ptr [bp-30]
	push	ax
	call	near ptr _ControlJoystick
	add	sp,6
	lea	ax,word ptr [bp-30]
	push	ss
	push	ax
	mov	cx,6
	call	near ptr N_SCOPY@
   ;	
   ;	  } while (ctr.button1);
   ;	
	cmp	word ptr [bp-16],0
	jne	short @1@218
   ;	
   ;	  WaitVBL (4);			// so the button can't bounce
   ;	
	mov	ax,4
	push	ax
	call	near ptr _WaitVBL
	pop	cx
   ;	
   ;	
   ;	  py+=6;
   ;	
	add	word ptr DGROUP:_py,6
   ;	
   ;	  PPrint("\nHold the joystick in the LOWER RIGHT\n");
   ;	
	mov	ax,offset DGROUP:s@+88
	push	ax
	call	near ptr _PPrint
	pop	cx
   ;	
   ;	  PPrint("corner and press a button:");
   ;	
	mov	ax,offset DGROUP:s@+127
	push	ax
	call	near ptr _PPrint
	pop	cx
@1@290:
   ;	
   ;	  do				// wait for a button press
   ;	  {
   ;	    DrawChar (sx,py,stage);
   ;	
	push	di
	push	word ptr DGROUP:_py
	push	word ptr DGROUP:_sx
	call	near ptr _DrawChar
	add	sp,6
   ;	
   ;	    WaitVBL (3);
   ;	
	mov	ax,3
	push	ax
	call	near ptr _WaitVBL
	pop	cx
   ;	
   ;	    if (++stage==23)
   ;	
	inc	di
	mov	ax,di
	cmp	ax,23
	jne	short @1@338
   ;	
   ;	      stage=15;
   ;	
	mov	di,15
@1@338:
   ;	
   ;	    ReadJoystick (joynum,&xh,&yh);
   ;	
	lea	ax,word ptr [bp-12]
	push	ax
	lea	ax,word ptr [bp-10]
	push	ax
	push	si
	call	near ptr _ReadJoystick
	add	sp,6
   ;	
   ;	    ctr = ControlJoystick(joynum);
   ;	
	lea	ax,word ptr [bp-18]
	push	ss
	push	ax
	push	si
	push	ss
	lea	ax,word ptr [bp-36]
	push	ax
	call	near ptr _ControlJoystick
	add	sp,6
	lea	ax,word ptr [bp-36]
	push	ss
	push	ax
	mov	cx,6
	call	near ptr N_SCOPY@
   ;	
   ;	    if (keydown[1])
   ;	
	cmp	byte ptr DGROUP:_keydown+1,0
	je	short @1@386
   ;	
   ;	      return;
   ;	
	jmp	@1@674
@1@386:
   ;	
   ;	  } while (ctr.button1!= 1 && ctr.button2!=1);
   ;	
	cmp	word ptr [bp-16],1
	je	short @1@434
	cmp	word ptr [bp-14],1
	jne	short @1@290
@1@434:
   ;	
   ;	  DrawChar (sx,py,BLANKCHAR);
   ;	
	mov	ax,9
	push	ax
	push	word ptr DGROUP:_py
	push	word ptr DGROUP:_sx
	call	near ptr _DrawChar
	add	sp,6
@1@458:
   ;	
   ;	  do                  		// wait for the button release
   ;	  {
   ;	    ctr = ControlJoystick(joynum);
   ;	
	lea	ax,word ptr [bp-18]
	push	ss
	push	ax
	push	si
	push	ss
	lea	ax,word ptr [bp-42]
	push	ax
	call	near ptr _ControlJoystick
	add	sp,6
	lea	ax,word ptr [bp-42]
	push	ss
	push	ax
	mov	cx,6
	call	near ptr N_SCOPY@
   ;	
   ;	  } while (ctr.button1);
   ;	
	cmp	word ptr [bp-16],0
	jne	short @1@458
   ;	
   ;	
   ;	  //
   ;	  // figure out good boundaries
   ;	  //
   ;	
   ;	  dx=(xh-xl) / 6;
   ;	
	mov	ax,word ptr [bp-10]
	sub	ax,word ptr [bp-6]
	mov	bx,6
	cwd	
	idiv	bx
	mov	word ptr [bp-2],ax
   ;	
   ;	  dy=(yh-yl) / 6;
   ;	
	mov	ax,word ptr [bp-12]
	sub	ax,word ptr [bp-8]
	mov	bx,6
	cwd	
	idiv	bx
	mov	word ptr [bp-4],ax
   ;	
   ;	  JoyXlow[joynum]=xl+dx;
   ;	
	mov	bx,si
	shl	bx,1
	mov	ax,word ptr [bp-6]
	add	ax,word ptr [bp-2]
	mov	word ptr DGROUP:_JoyXlow[bx],ax
   ;	
   ;	  JoyXhigh[joynum]=xh-dx;
   ;	
	mov	bx,si
	shl	bx,1
	mov	ax,word ptr [bp-10]
	sub	ax,word ptr [bp-2]
	mov	word ptr DGROUP:_JoyXhigh[bx],ax
   ;	
   ;	  JoyYlow[joynum]=yl+dy;
   ;	
	mov	bx,si
	shl	bx,1
	mov	ax,word ptr [bp-8]
	add	ax,word ptr [bp-4]
	mov	word ptr DGROUP:_JoyYlow[bx],ax
   ;	
   ;	  JoyYhigh[joynum]=yh-dy;
   ;	
	mov	bx,si
	shl	bx,1
	mov	ax,word ptr [bp-12]
	sub	ax,word ptr [bp-4]
	mov	word ptr DGROUP:_JoyYhigh[bx],ax
   ;	
   ;	  if (joynum==1)
   ;	
	cmp	si,1
	jne	short @1@554
   ;	
   ;	    playermode[1]=joystick1;
   ;	
	mov	word ptr DGROUP:_playermode+2,2
	jmp	short @1@578
@1@554:
   ;	
   ;	  else
   ;	    playermode[1]=joystick2;
   ;	
	mov	word ptr DGROUP:_playermode+2,3
@1@578:
   ;	
   ;	
   ;	  py+=6;
   ;	
	add	word ptr DGROUP:_py,6
   ;	
   ;	  PPrint ("\n(F)ire or (A)fterburn with B1 ?");
   ;	
	mov	ax,offset DGROUP:s@+154
	push	ax
	call	near ptr _PPrint
	pop	cx
   ;	
   ;	  ch = PGet();
   ;	
	call	near ptr _PGet
	mov	byte ptr DGROUP:_ch,al
   ;	
   ;	  if ( ch == 'A' || ch == 'a')
   ;	
	cmp	byte ptr DGROUP:_ch,65
	je	short @1@626
	cmp	byte ptr DGROUP:_ch,97
	jne	short @1@650
@1@626:
   ;	
   ;	    buttonflip = 1;
   ;	
	mov	word ptr DGROUP:_buttonflip,1
	jmp	short @1@674
@1@650:
   ;	
   ;	  else
   ;	    buttonflip = 0;
   ;	
	mov	word ptr DGROUP:_buttonflip,0
@1@674:
   ;	
   ;	}
   ;	
	pop	di
	pop	si
	mov	sp,bp
	pop	bp
	ret	
_CalibrateJoy	endp
_TEXT	ends
_DATA	segment word public 'DATA'
	db	63
	db	63
	db	49
	db	50
	db	51
	db	52
	db	53
	db	54
	db	55
	db	56
	db	57
	db	48
	db	45
	db	43
	db	63
	db	63
	db	81
	db	87
	db	69
	db	82
	db	84
	db	89
	db	85
	db	73
	db	79
	db	80
	db	91
	db	93
	db	124
	db	63
	db	65
	db	83
	db	68
	db	70
	db	71
	db	72
	db	74
	db	75
	db	76
	db	59
	db	34
	db	63
	db	63
	db	63
	db	90
	db	88
	db	67
	db	86
	db	66
	db	78
	db	77
	db	44
	db	46
	db	47
	db	63
	db	63
	db	63
	db	63
	db	63
	db	63
	db	63
	db	63
	db	63
	db	63
	db	63
	db	63
	db	63
	db	63
	db	63
	db	63
	db	63
	db	63
	db	15
	db	63
	db	45
	db	21
	db	53
	db	17
	db	43
	db	63
	db	19
	db	63
	db	63
	db	63
	db	63
	db	63
	db	63
	db	63
	db	63
	db	63
	db	63
	db	63
	db	63
	db	63
	db	63
	db	63
	db	63
	db	63
	db	63
	db	63
	db	63
	db	63
	db	63
	db	63
	db	63
	db	63
	db	63
	db	63
	db	63
	db	63
	db	63
	db	63
	db	63
	db	63
	db	63
	db	63
	db	63
	db	63
	db	63
	db	63
	db	63
	db	63
	db	63
	db	63
	db	63
	db	63
	db	63
	db	63
_DATA	ends
_TEXT	segment byte public 'CODE'
   ;	
   ;	void printscan (int sc)
   ;	
	assume	cs:_TEXT
_printscan	proc	near
	push	bp
	mov	bp,sp
	sub	sp,4
	push	si
	mov	si,word ptr [bp+4]
   ;	
   ;	{
   ;	 char static chartable[128] =
   ;	 {'?','?','1','2','3','4','5','6','7','8','9','0','-','+','?','?',
   ;	  'Q','W','E','R','T','Y','U','I','O','P','[',']','|','?','A','S',
   ;	  'D','F','G','H','J','K','L',';','"','?','?','?','Z','X','C','V',
   ;	  'B','N','M',',','.','/','?','?','?','?','?','?','?','?','?','?',
   ;	  '?','?','?','?','?','?','?','?', 15,'?','-', 21,'5', 17,'+','?',
   ;	   19,'?','?','?','?','?','?','?','?','?','?','?','?','?','?','?',
   ;	  '?','?','?','?','?','?','?','?','?','?','?','?','?','?','?','?',
   ;	  '?','?','?','?','?','?','?','?','?','?','?','?','?','?','?','?'};
   ;	
   ;	 sc = sc & 0x7f;
   ;	
	mov	ax,si
	and	ax,127
	mov	si,ax
   ;	
   ;	
   ;	 if (sc==1)
   ;	
	cmp	si,1
	jne	short @2@74
   ;	
   ;	   PPrint ("ESC");
   ;	
	mov	ax,offset DGROUP:s@+187
	push	ax
	call	near ptr _PPrint
	pop	cx
	jmp	@2@1346
@2@74:
   ;	
   ;	 else if (sc==0xe)
   ;	
	cmp	si,14
	jne	short @2@122
   ;	
   ;	   PPrint ("BKSP");
   ;	
	mov	ax,offset DGROUP:s@+191
	push	ax
	call	near ptr _PPrint
	pop	cx
	jmp	@2@1346
@2@122:
   ;	
   ;	 else if (sc==0xf)
   ;	
	cmp	si,15
	jne	short @2@170
   ;	
   ;	   PPrint ("TAB");
   ;	
	mov	ax,offset DGROUP:s@+196
	push	ax
	call	near ptr _PPrint
	pop	cx
	jmp	@2@1346
@2@170:
   ;	
   ;	 else if (sc==0x1d)
   ;	
	cmp	si,29
	jne	short @2@218
   ;	
   ;	   PPrint ("CTRL");
   ;	
	mov	ax,offset DGROUP:s@+200
	push	ax
	call	near ptr _PPrint
	pop	cx
	jmp	@2@1346
@2@218:
   ;	
   ;	 else if (sc==0x2A)
   ;	
	cmp	si,42
	jne	short @2@266
   ;	
   ;	   PPrint ("LSHIFT");
   ;	
	mov	ax,offset DGROUP:s@+205
	push	ax
	call	near ptr _PPrint
	pop	cx
	jmp	@2@1346
@2@266:
   ;	
   ;	 else if (sc==0x39)
   ;	
	cmp	si,57
	jne	short @2@314
   ;	
   ;	   PPrint ("SPACE");
   ;	
	mov	ax,offset DGROUP:s@+212
	push	ax
	call	near ptr _PPrint
	pop	cx
	jmp	@2@1346
@2@314:
   ;	
   ;	 else if (sc==0x3A)
   ;	
	cmp	si,58
	jne	short @2@362
   ;	
   ;	   PPrint ("CAPSLK");
   ;	
	mov	ax,offset DGROUP:s@+218
	push	ax
	call	near ptr _PPrint
	pop	cx
	jmp	@2@1346
@2@362:
   ;	
   ;	 else if (sc>=0x3b && sc<=0x44)
   ;	
	cmp	si,59
	jl	short @2@458
	cmp	si,68
	jg	short @2@458
   ;	
   ;	 {
   ;	   char str[3];
   ;	   PPrint ("F");
   ;	
	mov	ax,offset DGROUP:s@+225
	push	ax
	call	near ptr _PPrint
	pop	cx
   ;	
   ;	   itoa (sc-0x3a,str,10);
   ;	
	mov	ax,10
	push	ax
	lea	ax,word ptr [bp-4]
	push	ax
	mov	ax,si
	add	ax,65478
	push	ax
	call	near ptr _itoa
	add	sp,6
   ;	
   ;	   PPrint (str);
   ;	
	lea	ax,word ptr [bp-4]
	push	ax
	call	near ptr _PPrint
	pop	cx
   ;	
   ;	 }
   ;	
	jmp	@2@1346
@2@458:
   ;	
   ;	 else if (sc==0x57)
   ;	
	cmp	si,87
	jne	short @2@506
   ;	
   ;	   PPrint ("F11");
   ;	
	mov	ax,offset DGROUP:s@+227
	push	ax
	call	near ptr _PPrint
	pop	cx
	jmp	@2@1346
@2@506:
   ;	
   ;	 else if (sc==0x59)
   ;	
	cmp	si,89
	jne	short @2@554
   ;	
   ;	   PPrint ("F12");
   ;	
	mov	ax,offset DGROUP:s@+231
	push	ax
	call	near ptr _PPrint
	pop	cx
	jmp	@2@1346
@2@554:
   ;	
   ;	 else if (sc==0x46)
   ;	
	cmp	si,70
	jne	short @2@602
   ;	
   ;	   PPrint ("SCRLLK");
   ;	
	mov	ax,offset DGROUP:s@+235
	push	ax
	call	near ptr _PPrint
	pop	cx
	jmp	@2@1346
@2@602:
   ;	
   ;	 else if (sc==0x1c)
   ;	
	cmp	si,28
	jne	short @2@650
   ;	
   ;	   PPrint ("ENTER");
   ;	
	mov	ax,offset DGROUP:s@+242
	push	ax
	call	near ptr _PPrint
	pop	cx
	jmp	@2@1346
@2@650:
   ;	
   ;	 else if (sc==0x36)
   ;	
	cmp	si,54
	jne	short @2@698
   ;	
   ;	   PPrint ("RSHIFT");
   ;	
	mov	ax,offset DGROUP:s@+248
	push	ax
	call	near ptr _PPrint
	pop	cx
	jmp	@2@1346
@2@698:
   ;	
   ;	 else if (sc==0x37)
   ;	
	cmp	si,55
	jne	short @2@746
   ;	
   ;	   PPrint ("PRTSC");
   ;	
	mov	ax,offset DGROUP:s@+255
	push	ax
	call	near ptr _PPrint
	pop	cx
	jmp	@2@1346
@2@746:
   ;	
   ;	 else if (sc==0x38)
   ;	
	cmp	si,56
	jne	short @2@794
   ;	
   ;	   PPrint ("ALT");
   ;	
	mov	ax,offset DGROUP:s@+261
	push	ax
	call	near ptr _PPrint
	pop	cx
	jmp	@2@1346
@2@794:
   ;	
   ;	 else if (sc==0x47)
   ;	
	cmp	si,71
	jne	short @2@842
   ;	
   ;	   PPrint ("HOME");
   ;	
	mov	ax,offset DGROUP:s@+265
	push	ax
	call	near ptr _PPrint
	pop	cx
	jmp	@2@1346
@2@842:
   ;	
   ;	 else if (sc==0x49)
   ;	
	cmp	si,73
	jne	short @2@890
   ;	
   ;	   PPrint ("PGUP");
   ;	
	mov	ax,offset DGROUP:s@+270
	push	ax
	call	near ptr _PPrint
	pop	cx
	jmp	@2@1346
@2@890:
   ;	
   ;	 else if (sc==0x4f)
   ;	
	cmp	si,79
	jne	short @2@938
   ;	
   ;	   PPrint ("END");
   ;	
	mov	ax,offset DGROUP:s@+275
	push	ax
	call	near ptr _PPrint
	pop	cx
	jmp	@2@1346
@2@938:
   ;	
   ;	 else if (sc==0x51)
   ;	
	cmp	si,81
	jne	short @2@986
   ;	
   ;	   PPrint ("PGDN");
   ;	
	mov	ax,offset DGROUP:s@+279
	push	ax
	call	near ptr _PPrint
	pop	cx
	jmp	@2@1346
@2@986:
   ;	
   ;	 else if (sc==0x52)
   ;	
	cmp	si,82
	jne	short @2@1034
   ;	
   ;	   PPrint ("INS");
   ;	
	mov	ax,offset DGROUP:s@+284
	push	ax
	call	near ptr _PPrint
	pop	cx
	jmp	short @2@1346
@2@1034:
   ;	
   ;	 else if (sc==0x53)
   ;	
	cmp	si,83
	jne	short @2@1082
   ;	
   ;	   PPrint ("DEL");
   ;	
	mov	ax,offset DGROUP:s@+288
	push	ax
	call	near ptr _PPrint
	pop	cx
	jmp	short @2@1346
@2@1082:
   ;	
   ;	 else if (sc==0x45)
   ;	
	cmp	si,69
	jne	short @2@1130
   ;	
   ;	   PPrint ("NUMLK");
   ;	
	mov	ax,offset DGROUP:s@+292
	push	ax
	call	near ptr _PPrint
	pop	cx
	jmp	short @2@1346
@2@1130:
   ;	
   ;	 else if (sc==0x48)
   ;	
	cmp	si,72
	jne	short @2@1178
   ;	
   ;	   PPrint ("UP");
   ;	
	mov	ax,offset DGROUP:s@+298
	push	ax
	call	near ptr _PPrint
	pop	cx
	jmp	short @2@1346
@2@1178:
   ;	
   ;	 else if (sc==0x50)
   ;	
	cmp	si,80
	jne	short @2@1226
   ;	
   ;	   PPrint ("DOWN");
   ;	
	mov	ax,offset DGROUP:s@+301
	push	ax
	call	near ptr _PPrint
	pop	cx
	jmp	short @2@1346
@2@1226:
   ;	
   ;	 else if (sc==0x4b)
   ;	
	cmp	si,75
	jne	short @2@1274
   ;	
   ;	   PPrint ("LEFT");
   ;	
	mov	ax,offset DGROUP:s@+306
	push	ax
	call	near ptr _PPrint
	pop	cx
	jmp	short @2@1346
@2@1274:
   ;	
   ;	 else if (sc==0x4d)
   ;	
	cmp	si,77
	jne	short @2@1322
   ;	
   ;	   PPrint ("RIGHT");
   ;	
	mov	ax,offset DGROUP:s@+311
	push	ax
	call	near ptr _PPrint
	pop	cx
	jmp	short @2@1346
@2@1322:
   ;	
   ;	 else
   ;	 {
   ;	   str[0]=chartable[sc];
   ;	
	mov	al,byte ptr DGROUP:d@+0[si]
	mov	byte ptr DGROUP:_str,al
   ;	
   ;	   str[1]=0;
   ;	
	mov	byte ptr DGROUP:_str+1,0
   ;	
   ;	   PPrint (str);
   ;	
	mov	ax,offset DGROUP:_str
	push	ax
	call	near ptr _PPrint
	pop	cx
@2@1346:
   ;	
   ;	 }
   ;	}
   ;	
	pop	si
	mov	sp,bp
	pop	bp
	ret	
_printscan	endp
   ;	
   ;	void calibratekeys (void)
   ;	
	assume	cs:_TEXT
_calibratekeys	proc	near
	push	bp
	mov	bp,sp
	sub	sp,8
	push	si
	push	di
   ;	
   ;	{
   ;	  char ch;
   ;	  int hx,hy,i,select,new;
   ;	
   ;	  ExpWin (22,12);
   ;	
	mov	ax,12
	push	ax
	mov	ax,22
	push	ax
	call	near ptr _ExpWin
	pop	cx
	pop	cx
   ;	
   ;	  fontcolor=13;
   ;	
	mov	word ptr DGROUP:_fontcolor,13
   ;	
   ;	  CPPrint ("Keyboard Configuration");
   ;	
	mov	ax,offset DGROUP:s@+317
	push	ax
	call	near ptr _CPPrint
	pop	cx
   ;	
   ;	  fontcolor=15;
   ;	
	mov	word ptr DGROUP:_fontcolor,15
   ;	
   ;	  PPrint ("\n1 north");
   ;	
	mov	ax,offset DGROUP:s@+340
	push	ax
	call	near ptr _PPrint
	pop	cx
   ;	
   ;	  PPrint ("\n2 east");
   ;	
	mov	ax,offset DGROUP:s@+349
	push	ax
	call	near ptr _PPrint
	pop	cx
   ;	
   ;	  PPrint ("\n3 south");
   ;	
	mov	ax,offset DGROUP:s@+357
	push	ax
	call	near ptr _PPrint
	pop	cx
   ;	
   ;	  PPrint ("\n4 west");
   ;	
	mov	ax,offset DGROUP:s@+366
	push	ax
	call	near ptr _PPrint
	pop	cx
   ;	
   ;	  PPrint ("\n5 button1");
   ;	
	mov	ax,offset DGROUP:s@+374
	push	ax
	call	near ptr _PPrint
	pop	cx
   ;	
   ;	  PPrint ("\n6 button2");
   ;	
	mov	ax,offset DGROUP:s@+385
	push	ax
	call	near ptr _PPrint
	pop	cx
   ;	
   ;	  PPrint ("\nModify which action:");
   ;	
	mov	ax,offset DGROUP:s@+396
	push	ax
	call	near ptr _PPrint
	pop	cx
   ;	
   ;	  hx=(px+7)/8;
   ;	
	mov	ax,word ptr DGROUP:_px
	add	ax,7
	shr	ax,1
	shr	ax,1
	shr	ax,1
	mov	word ptr [bp-4],ax
   ;	
   ;	  hy=py;
   ;	
	mov	ax,word ptr DGROUP:_py
	mov	word ptr [bp-6],ax
   ;	
   ;	  for (i=0;i<4;i++)
   ;	
	xor	si,si
	jmp	short @3@98
@3@50:
   ;	
   ;	  {
   ;	    px=pxl+8*12;
   ;	
	mov	ax,word ptr DGROUP:_pxl
	add	ax,96
	mov	word ptr DGROUP:_px,ax
   ;	
   ;	    py=pyl+10*(1+i);
   ;	
	mov	ax,si
	inc	ax
	mov	dx,10
	imul	dx
	mov	dx,word ptr DGROUP:_pyl
	add	dx,ax
	mov	word ptr DGROUP:_py,dx
   ;	
   ;	    PPrint(":");
   ;	
	mov	ax,offset DGROUP:s@+418
	push	ax
	call	near ptr _PPrint
	pop	cx
   ;	
   ;	    printscan (key[i*2]);
   ;	
	mov	bx,si
	shl	bx,1
	mov	al,byte ptr DGROUP:_key[bx]
	cbw	
	push	ax
	call	near ptr _printscan
	pop	cx
	inc	si
@3@98:
	cmp	si,4
	jl	short @3@50
   ;	
   ;	  }
   ;	  px=pxl+8*12;
   ;	
	mov	ax,word ptr DGROUP:_pxl
	add	ax,96
	mov	word ptr DGROUP:_px,ax
   ;	
   ;	  py=pyl+10*5;
   ;	
	mov	ax,word ptr DGROUP:_pyl
	add	ax,50
	mov	word ptr DGROUP:_py,ax
   ;	
   ;	  PPrint(":");
   ;	
	mov	ax,offset DGROUP:s@+420
	push	ax
	call	near ptr _PPrint
	pop	cx
   ;	
   ;	  printscan (keyB1);
   ;	
	mov	al,byte ptr DGROUP:_keyB1
	cbw	
	push	ax
	call	near ptr _printscan
	pop	cx
   ;	
   ;	  px=pxl+8*12;
   ;	
	mov	ax,word ptr DGROUP:_pxl
	add	ax,96
	mov	word ptr DGROUP:_px,ax
   ;	
   ;	  py=pyl+10*6;
   ;	
	mov	ax,word ptr DGROUP:_pyl
	add	ax,60
	mov	word ptr DGROUP:_py,ax
   ;	
   ;	  PPrint(":");
   ;	
	mov	ax,offset DGROUP:s@+422
	push	ax
	call	near ptr _PPrint
	pop	cx
   ;	
   ;	  printscan (keyB2);
   ;	
	mov	al,byte ptr DGROUP:_keyB2
	cbw	
	push	ax
	call	near ptr _printscan
	pop	cx
@3@146:
   ;	
   ;	
   ;	  do
   ;	  {
   ;	    px=hx*8;
   ;	
	mov	ax,word ptr [bp-4]
	shl	ax,1
	shl	ax,1
	shl	ax,1
	mov	word ptr DGROUP:_px,ax
   ;	
   ;	    py=hy;
   ;	
	mov	ax,word ptr [bp-6]
	mov	word ptr DGROUP:_py,ax
   ;	
   ;	    DrawChar (hx,hy,BLANKCHAR);
   ;	
	mov	ax,9
	push	ax
	push	word ptr [bp-6]
	push	word ptr [bp-4]
	call	near ptr _DrawChar
	add	sp,6
   ;	
   ;	    ch=PGet() % 256;
   ;	
	call	near ptr _PGet
	mov	bx,256
	cwd	
	idiv	bx
	mov	byte ptr [bp-1],dl
   ;	
   ;	    if (ch<'1' || ch>'6')
   ;	
	cmp	byte ptr [bp-1],49
	jl	short @3@194
	cmp	byte ptr [bp-1],54
	jle	short @3@218
@3@194:
   ;	
   ;	      continue;
   ;	
	jmp	@3@530
@3@218:
   ;	
   ;	    select = ch - '1';
   ;	
	mov	al,byte ptr [bp-1]
	cbw	
	add	ax,65487
	mov	di,ax
   ;	
   ;	    DrawPchar (ch);
   ;	
	mov	al,byte ptr [bp-1]
	cbw	
	push	ax
	call	near ptr _DrawPchar
	pop	cx
   ;	
   ;	    PPrint ("\nPress the new key:");
   ;	
	mov	ax,offset DGROUP:s@+424
	push	ax
	call	near ptr _PPrint
	pop	cx
   ;	
   ;	    ClearKeys ();
   ;	
	call	near ptr _ClearKeys
   ;	
   ;	    new=-1;
   ;	
	mov	word ptr [bp-8],65535
	jmp	short @3@338
@3@242:
   ;	
   ;	    while (!keydown[++new])
   ;	      if (new==0x79)
   ;	
	cmp	word ptr [bp-8],121
	jne	short @3@290
   ;	
   ;		new=-1;
   ;	
	mov	word ptr [bp-8],65535
	jmp	short @3@338
@3@290:
   ;	
   ;	      else if (new==0x29)
   ;	
	cmp	word ptr [bp-8],41
	jne	short @3@338
   ;	
   ;		new++;				// skip STUPID left shifts!
   ;	
	inc	word ptr [bp-8]
@3@338:
	inc	word ptr [bp-8]
	mov	bx,word ptr [bp-8]
	mov	al,byte ptr DGROUP:_keydown[bx]
	cbw	
	or	ax,ax
	je	short @3@242
   ;	
   ;	    Bar(leftedge,py,22,10,0xff);
   ;	
	mov	ax,255
	push	ax
	mov	ax,10
	push	ax
	mov	ax,22
	push	ax
	push	word ptr DGROUP:_py
	push	word ptr DGROUP:_leftedge
	call	near ptr _Bar
	add	sp,10
   ;	
   ;	    if (select<4)
   ;	
	cmp	di,4
	jge	short @3@410
   ;	
   ;	      key[select*2]=new;
   ;	
	mov	bx,di
	shl	bx,1
	mov	al,byte ptr [bp-8]
	mov	byte ptr DGROUP:_key[bx],al
@3@410:
   ;	
   ;	    if (select==4)
   ;	
	cmp	di,4
	jne	short @3@458
   ;	
   ;	      keyB1=new;
   ;	
	mov	al,byte ptr [bp-8]
	mov	byte ptr DGROUP:_keyB1,al
@3@458:
   ;	
   ;	    if (select==5)
   ;	
	cmp	di,5
	jne	short @3@506
   ;	
   ;	      keyB2=new;
   ;	
	mov	al,byte ptr [bp-8]
	mov	byte ptr DGROUP:_keyB2,al
@3@506:
   ;	
   ;	    px=pxl+8*12;
   ;	
	mov	ax,word ptr DGROUP:_pxl
	add	ax,96
	mov	word ptr DGROUP:_px,ax
   ;	
   ;	    py=pyl+(select+2)*10;
   ;	
	mov	ax,di
	inc	ax
	inc	ax
	mov	dx,10
	imul	dx
	mov	dx,word ptr DGROUP:_pyl
	add	dx,ax
	mov	word ptr DGROUP:_py,dx
   ;	
   ;	    Bar(px/8,py,9,10,0xff);
   ;	
	mov	ax,255
	push	ax
	mov	ax,10
	push	ax
	mov	ax,9
	push	ax
	push	word ptr DGROUP:_py
	mov	ax,word ptr DGROUP:_px
	shr	ax,1
	shr	ax,1
	shr	ax,1
	push	ax
	call	near ptr _Bar
	add	sp,10
   ;	
   ;	    PPrint (":");
   ;	
	mov	ax,offset DGROUP:s@+444
	push	ax
	call	near ptr _PPrint
	pop	cx
   ;	
   ;	    printscan (new);
   ;	
	push	word ptr [bp-8]
	call	near ptr _printscan
	pop	cx
   ;	
   ;	    ClearKeys ();
   ;	
	call	near ptr _ClearKeys
   ;	
   ;	    ch='0';				// so the loop continues
   ;	
	mov	byte ptr [bp-1],48
@3@530:
   ;	
   ;	  } while (ch>='0' && ch<='9');
   ;	
	cmp	byte ptr [bp-1],48
	jl	short @3@578
	cmp	byte ptr [bp-1],57
	jg	@@82
	jmp	@3@146
@@82:
@3@578:
   ;	
   ;	  playermode[1]=keyboard;
   ;	
	mov	word ptr DGROUP:_playermode+2,0
   ;	
   ;	}
   ;	
	pop	di
	pop	si
	mov	sp,bp
	pop	bp
	ret	
_calibratekeys	endp
   ;	
   ;	ControlStruct ControlKBD ()
   ;	
	assume	cs:_TEXT
_ControlKBD	proc	near
	push	bp
	mov	bp,sp
	sub	sp,6
	push	si
	push	di
   ;	
   ;	{
   ;	 int xmove=0,
   ;	
	xor	si,si
   ;	
   ;	     ymove=0;
   ;	
	xor	di,di
   ;	
   ;	 ControlStruct action;
   ;	
   ;	 if (keydown [key[north]])
   ;	
	mov	al,byte ptr DGROUP:_key
	cbw	
	mov	bx,ax
	cmp	byte ptr DGROUP:_keydown[bx],0
	je	short @4@74
   ;	
   ;	  ymove=-1;
   ;	
	mov	di,65535
@4@74:
   ;	
   ;	 if (keydown [key[east]])
   ;	
	mov	al,byte ptr DGROUP:_key+2
	cbw	
	mov	bx,ax
	cmp	byte ptr DGROUP:_keydown[bx],0
	je	short @4@122
   ;	
   ;	  xmove=1;
   ;	
	mov	si,1
@4@122:
   ;	
   ;	 if (keydown [key[south]])
   ;	
	mov	al,byte ptr DGROUP:_key+4
	cbw	
	mov	bx,ax
	cmp	byte ptr DGROUP:_keydown[bx],0
	je	short @4@170
   ;	
   ;	  ymove=1;
   ;	
	mov	di,1
@4@170:
   ;	
   ;	 if (keydown [key[west]])
   ;	
	mov	al,byte ptr DGROUP:_key+6
	cbw	
	mov	bx,ax
	cmp	byte ptr DGROUP:_keydown[bx],0
	je	short @4@218
   ;	
   ;	  xmove=-1;
   ;	
	mov	si,65535
@4@218:
   ;	
   ;	
   ;	 if (keydown [key[northeast]])
   ;	
	mov	al,byte ptr DGROUP:_key+1
	cbw	
	mov	bx,ax
	cmp	byte ptr DGROUP:_keydown[bx],0
	je	short @4@266
   ;	
   ;	 {
   ;	   ymove=-1;
   ;	
	mov	di,65535
   ;	
   ;	   xmove=1;
   ;	
	mov	si,1
@4@266:
   ;	
   ;	 }
   ;	 if (keydown [key[northwest]])
   ;	
	mov	al,byte ptr DGROUP:_key+7
	cbw	
	mov	bx,ax
	cmp	byte ptr DGROUP:_keydown[bx],0
	je	short @4@314
   ;	
   ;	 {
   ;	   ymove=-1;
   ;	
	mov	di,65535
   ;	
   ;	   xmove=-1;
   ;	
	mov	si,65535
@4@314:
   ;	
   ;	 }
   ;	 if (keydown [key[southeast]])
   ;	
	mov	al,byte ptr DGROUP:_key+3
	cbw	
	mov	bx,ax
	cmp	byte ptr DGROUP:_keydown[bx],0
	je	short @4@362
   ;	
   ;	 {
   ;	   ymove=1;
   ;	
	mov	di,1
   ;	
   ;	   xmove=1;
   ;	
	mov	si,1
@4@362:
   ;	
   ;	 }
   ;	 if (keydown [key[southwest]])
   ;	
	mov	al,byte ptr DGROUP:_key+5
	cbw	
	mov	bx,ax
	cmp	byte ptr DGROUP:_keydown[bx],0
	je	short @4@410
   ;	
   ;	 {
   ;	   ymove=1;
   ;	
	mov	di,1
   ;	
   ;	   xmove=-1;
   ;	
	mov	si,65535
@4@410:
   ;	
   ;	 }
   ;	
   ;	  switch (ymove*3+xmove)
   ;	
	mov	ax,di
	mov	dx,3
	imul	dx
	add	ax,si
	sub	ax,65532
	mov	bx,ax
	cmp	bx,8
	ja	short @4@698
	shl	bx,1
	jmp	word ptr cs:@4@C2394[bx]
@4@482:
   ;	
   ;	 {
   ;	   case -4: action.dir = northwest; break;
   ;	
	mov	word ptr [bp-6],7
	jmp	short @4@698
@4@506:
   ;	
   ;	   case -3: action.dir = north; break;
   ;	
	mov	word ptr [bp-6],0
	jmp	short @4@698
@4@530:
   ;	
   ;	   case -2: action.dir = northeast; break;
   ;	
	mov	word ptr [bp-6],1
	jmp	short @4@698
@4@554:
   ;	
   ;	   case -1: action.dir = west; break;
   ;	
	mov	word ptr [bp-6],6
	jmp	short @4@698
@4@578:
   ;	
   ;	   case  0: action.dir = nodir; break;
   ;	
	mov	word ptr [bp-6],8
	jmp	short @4@698
@4@602:
   ;	
   ;	   case  1: action.dir = east; break;
   ;	
	mov	word ptr [bp-6],2
	jmp	short @4@698
@4@626:
   ;	
   ;	   case  2: action.dir = southwest; break;
   ;	
	mov	word ptr [bp-6],5
	jmp	short @4@698
@4@650:
   ;	
   ;	   case  3: action.dir = south; break;
   ;	
	mov	word ptr [bp-6],4
	jmp	short @4@698
@4@674:
   ;	
   ;	   case  4: action.dir = southeast; break;
   ;	
	mov	word ptr [bp-6],3
	jmp	short @4@698
@4@698:
   ;	
   ;	 }
   ;	
   ;	 action.button1 = keydown [keyB1];
   ;	
	mov	al,byte ptr DGROUP:_keyB1
	cbw	
	mov	bx,ax
	mov	al,byte ptr DGROUP:_keydown[bx]
	cbw	
	mov	word ptr [bp-4],ax
   ;	
   ;	 action.button2 = keydown [keyB2];
   ;	
	mov	al,byte ptr DGROUP:_keyB2
	cbw	
	mov	bx,ax
	mov	al,byte ptr DGROUP:_keydown[bx]
	cbw	
	mov	word ptr [bp-2],ax
   ;	
   ;	
   ;	 return (action);
   ;	
	push	word ptr [bp+6]
	push	word ptr [bp+4]
	lea	ax,word ptr [bp-6]
	push	ss
	push	ax
	mov	cx,6
	call	near ptr N_SCOPY@
	mov	ax,word ptr [bp+4]
	jmp	short @4@722
@4@722:
   ;	
   ;	}
   ;	
	pop	di
	pop	si
	mov	sp,bp
	pop	bp
	ret	
_ControlKBD	endp
@4@C2394	label	word
	dw	@4@482
	dw	@4@506
	dw	@4@530
	dw	@4@554
	dw	@4@578
	dw	@4@602
	dw	@4@626
	dw	@4@650
	dw	@4@674
   ;	
   ;	void ReadJoystick (int joynum,int *xcount,int *ycount)
   ;	
	assume	cs:_TEXT
_ReadJoystick	proc	near
	push	bp
	mov	bp,sp
	sub	sp,6
	push	si
	push	di
	mov	si,word ptr [bp+6]
	mov	di,word ptr [bp+8]
   ;	
   ;	{
   ;	 int portval,a1,a2,xbit,ybit;
   ;	
   ;	 if (joynum==1)
   ;	
	cmp	word ptr [bp+4],1
	jne	short @5@74
   ;	
   ;	 {
   ;	  xbit=1;
   ;	
	mov	word ptr [bp-4],1
   ;	
   ;	  ybit=2;
   ;	
	mov	word ptr [bp-6],2
   ;	
   ;	 }
   ;	
	jmp	short @5@98
@5@74:
   ;	
   ;	 else
   ;	 {
   ;	  xbit=4;
   ;	
	mov	word ptr [bp-4],4
   ;	
   ;	  ybit=8;
   ;	
	mov	word ptr [bp-6],8
@5@98:
   ;	
   ;	 }
   ;	
   ;	 *xcount = 0;
   ;	
	mov	word ptr [si],0
   ;	
   ;	 *ycount = 0;
   ;	
	mov	word ptr [di],0
   ;	
   ;	
   ;	 outportb (0x201,inportb (0x201));	/* start the signal pulse */
   ;	
	mov	dx,513
	in	al,dx
	mov	dx,513
	out	dx,al
   ;	
   ;	
   ;	 asm cli;
   ;	
 	cli	
@5@146:
   ;	
   ;	
   ;	 do
   ;	 {
   ;	   portval = inportb (0x201);
   ;	
	mov	dx,513
	in	al,dx
	mov	ah,0
	mov	bx,ax
   ;	
   ;	   a1 = (portval & xbit) != 0;
   ;	
	mov	ax,word ptr [bp-4]
	test	bx,ax
	je	short @5@194
	mov	ax,1
	jmp	short @5@218
@5@194:
	xor	ax,ax
@5@218:
	mov	cx,ax
   ;	
   ;	   a2 = (portval & ybit) != 0;
   ;	
	mov	ax,word ptr [bp-6]
	test	bx,ax
	je	short @5@266
	mov	ax,1
	jmp	short @5@290
@5@266:
	xor	ax,ax
@5@290:
	mov	word ptr [bp-2],ax
   ;	
   ;	   *xcount+=a1;
   ;	
	mov	ax,cx
	add	word ptr [si],ax
   ;	
   ;	   *ycount+=a2;
   ;	
	mov	ax,word ptr [bp-2]
	add	word ptr [di],ax
   ;	
   ;	 } while ((a1+a2!=0) && (*xcount<500) && (*ycount<500));
   ;	
	mov	ax,cx
	add	ax,word ptr [bp-2]
	je	short @5@386
	cmp	word ptr [si],500
	jge	short @5@386
	cmp	word ptr [di],500
	jl	short @5@146
@5@386:
   ;	
   ;	
   ;	 asm sti;
   ;	
 	sti	
   ;	
   ;	}
   ;	
	pop	di
	pop	si
	mov	sp,bp
	pop	bp
	ret	
_ReadJoystick	endp
   ;	
   ;	int JoyButton (void)
   ;	
	assume	cs:_TEXT
_JoyButton	proc	near
	push	bp
	mov	bp,sp
	push	si
   ;	
   ;	{
   ;	 int buttons = inportb (0x201);	/* Get all four button status */
   ;	
	mov	dx,513
	in	al,dx
	mov	ah,0
	mov	si,ax
   ;	
   ;	 if ((buttons & 0x10) == 0)
   ;	
	test	si,16
	jne	short @6@74
   ;	
   ;	   return 1;
   ;	
	mov	ax,1
	jmp	short @6@146
@6@74:
   ;	
   ;	 if ((buttons & 0x20) == 0)
   ;	
	test	si,32
	jne	short @6@122
   ;	
   ;	   return 2;
   ;	
	mov	ax,2
	jmp	short @6@146
@6@122:
   ;	
   ;	
   ;	 return 0;
   ;	
	xor	ax,ax
	jmp	short @6@146
@6@146:
   ;	
   ;	}
   ;	
	pop	si
	pop	bp
	ret	
_JoyButton	endp
   ;	
   ;	ControlStruct ControlJoystick (int joynum)
   ;	
	assume	cs:_TEXT
_ControlJoystick	proc	near
	push	bp
	mov	bp,sp
	sub	sp,14
	push	si
	push	di
	mov	si,word ptr [bp+8]
   ;	
   ;	{
   ;	 int joyx = 0,joyy = 0,		/* resistance in joystick */
   ;	
	mov	word ptr [bp-2],0
	mov	word ptr [bp-4],0
   ;	
   ;	     xmove = 0,
   ;	
	mov	word ptr [bp-6],0
   ;	
   ;	     ymove = 0,
   ;	
	mov	word ptr [bp-8],0
   ;	
   ;	     buttons;
   ;	 ControlStruct action;
   ;	
   ;	 ReadJoystick (joynum,&joyx,&joyy);
   ;	
	lea	ax,word ptr [bp-4]
	push	ax
	lea	ax,word ptr [bp-2]
	push	ax
	push	si
	call	near ptr _ReadJoystick
	add	sp,6
   ;	
   ;	 if ( (joyx>500) | (joyy>500) )
   ;	
	cmp	word ptr [bp-2],500
	jle	short @7@74
	mov	ax,1
	jmp	short @7@98
@7@74:
	xor	ax,ax
@7@98:
	push	ax
	cmp	word ptr [bp-4],500
	jle	short @7@146
	mov	ax,1
	jmp	short @7@170
@7@146:
	xor	ax,ax
@7@170:
	pop	dx
	or	dx,ax
	je	short @7@218
   ;	
   ;	 {
   ;	   joyx=JoyXlow [joynum] + 1;	/* no joystick connected, do nothing */
   ;	
	mov	bx,si
	shl	bx,1
	mov	ax,word ptr DGROUP:_JoyXlow[bx]
	inc	ax
	mov	word ptr [bp-2],ax
   ;	
   ;	   joyy=JoyYlow [joynum] + 1;
   ;	
	mov	bx,si
	shl	bx,1
	mov	ax,word ptr DGROUP:_JoyYlow[bx]
	inc	ax
	mov	word ptr [bp-4],ax
@7@218:
   ;	
   ;	 }
   ;	
   ;	 if (joyx > JoyXhigh [joynum])
   ;	
	mov	bx,si
	shl	bx,1
	mov	ax,word ptr DGROUP:_JoyXhigh[bx]
	cmp	ax,word ptr [bp-2]
	jge	short @7@266
   ;	
   ;	   xmove = 1;
   ;	
	mov	word ptr [bp-6],1
	jmp	short @7@314
@7@266:
   ;	
   ;	 else if (joyx < JoyXlow [joynum])
   ;	
	mov	bx,si
	shl	bx,1
	mov	ax,word ptr DGROUP:_JoyXlow[bx]
	cmp	ax,word ptr [bp-2]
	jle	short @7@314
   ;	
   ;	   xmove = -1;
   ;	
	mov	word ptr [bp-6],65535
@7@314:
   ;	
   ;	 if (joyy > JoyYhigh [joynum])
   ;	
	mov	bx,si
	shl	bx,1
	mov	ax,word ptr DGROUP:_JoyYhigh[bx]
	cmp	ax,word ptr [bp-4]
	jge	short @7@362
   ;	
   ;	   ymove = 1;
   ;	
	mov	word ptr [bp-8],1
	jmp	short @7@410
@7@362:
   ;	
   ;	 else if (joyy < JoyYlow [joynum])
   ;	
	mov	bx,si
	shl	bx,1
	mov	ax,word ptr DGROUP:_JoyYlow[bx]
	cmp	ax,word ptr [bp-4]
	jle	short @7@410
   ;	
   ;	   ymove = -1;
   ;	
	mov	word ptr [bp-8],65535
@7@410:
   ;	
   ;	
   ;	 switch (ymove*3+xmove)
   ;	
	mov	ax,word ptr [bp-8]
	mov	dx,3
	imul	dx
	add	ax,word ptr [bp-6]
	sub	ax,65532
	mov	bx,ax
	cmp	bx,8
	ja	short @7@698
	shl	bx,1
	jmp	word ptr cs:@7@C3820[bx]
@7@482:
   ;	
   ;	 {
   ;	   case -4: action.dir = northwest; break;
   ;	
	mov	word ptr [bp-14],7
	jmp	short @7@698
@7@506:
   ;	
   ;	   case -3: action.dir = north; break;
   ;	
	mov	word ptr [bp-14],0
	jmp	short @7@698
@7@530:
   ;	
   ;	   case -2: action.dir = northeast; break;
   ;	
	mov	word ptr [bp-14],1
	jmp	short @7@698
@7@554:
   ;	
   ;	   case -1: action.dir = west; break;
   ;	
	mov	word ptr [bp-14],6
	jmp	short @7@698
@7@578:
   ;	
   ;	   case  0: action.dir = nodir; break;
   ;	
	mov	word ptr [bp-14],8
	jmp	short @7@698
@7@602:
   ;	
   ;	   case  1: action.dir = east; break;
   ;	
	mov	word ptr [bp-14],2
	jmp	short @7@698
@7@626:
   ;	
   ;	   case  2: action.dir = southwest; break;
   ;	
	mov	word ptr [bp-14],5
	jmp	short @7@698
@7@650:
   ;	
   ;	   case  3: action.dir = south; break;
   ;	
	mov	word ptr [bp-14],4
	jmp	short @7@698
@7@674:
   ;	
   ;	   case  4: action.dir = southeast; break;
   ;	
	mov	word ptr [bp-14],3
	jmp	short @7@698
@7@698:
   ;	
   ;	 }
   ;	
   ;	 buttons = inportb (0x201);	/* Get all four button status */
   ;	
	mov	dx,513
	in	al,dx
	mov	ah,0
	mov	di,ax
   ;	
   ;	 if (joynum == 1)
   ;	
	cmp	si,1
	jne	short @7@890
   ;	
   ;	 {
   ;	   action.button1 = ((buttons & 0x10) == 0);
   ;	
	test	di,16
	jne	short @7@770
	mov	ax,1
	jmp	short @7@794
@7@770:
	xor	ax,ax
@7@794:
	mov	word ptr [bp-12],ax
   ;	
   ;	   action.button2 = ((buttons & 0x20) == 0);
   ;	
	test	di,32
	jne	short @7@842
	mov	ax,1
	jmp	short @7@866
@7@842:
	xor	ax,ax
@7@866:
	mov	word ptr [bp-10],ax
   ;	
   ;	 }
   ;	
	jmp	short @7@1058
@7@890:
   ;	
   ;	 else
   ;	 {
   ;	   action.button1 = ((buttons & 0x40) == 0);
   ;	
	test	di,64
	jne	short @7@938
	mov	ax,1
	jmp	short @7@962
@7@938:
	xor	ax,ax
@7@962:
	mov	word ptr [bp-12],ax
   ;	
   ;	   action.button2 = ((buttons & 0x80) == 0);
   ;	
	test	di,128
	jne	short @7@1010
	mov	ax,1
	jmp	short @7@1034
@7@1010:
	xor	ax,ax
@7@1034:
	mov	word ptr [bp-10],ax
@7@1058:
   ;	
   ;	 }
   ;	 if (buttonflip)
   ;	
	cmp	word ptr DGROUP:_buttonflip,0
	je	short @7@1106
   ;	
   ;	 {
   ;	   buttons = action.button1;
   ;	
	mov	di,word ptr [bp-12]
   ;	
   ;	   action.button1 = action.button2;
   ;	
	mov	ax,word ptr [bp-10]
	mov	word ptr [bp-12],ax
   ;	
   ;	   action.button2 = buttons;
   ;	
	mov	word ptr [bp-10],di
@7@1106:
   ;	
   ;	 }
   ;	 return (action);
   ;	
	push	word ptr [bp+6]
	push	word ptr [bp+4]
	lea	ax,word ptr [bp-14]
	push	ss
	push	ax
	mov	cx,6
	call	near ptr N_SCOPY@
	mov	ax,word ptr [bp+4]
	jmp	short @7@1130
@7@1130:
   ;	
   ;	}
   ;	
	pop	di
	pop	si
	mov	sp,bp
	pop	bp
	ret	
_ControlJoystick	endp
@7@C3820	label	word
	dw	@7@482
	dw	@7@506
	dw	@7@530
	dw	@7@554
	dw	@7@578
	dw	@7@602
	dw	@7@626
	dw	@7@650
	dw	@7@674
   ;	
   ;	ControlStruct ControlPlayer (int player)
   ;	
	assume	cs:_TEXT
_ControlPlayer	proc	near
	push	bp
	mov	bp,sp
	sub	sp,24
   ;	
   ;	{
   ;	 ControlStruct ret;
   ;	
   ;	 switch (playermode[player])
   ;	
	mov	bx,word ptr [bp+8]
	shl	bx,1
	mov	ax,word ptr DGROUP:_playermode[bx]
	or	ax,ax
	je	short @8@146
	cmp	ax,2
	je	short @8@170
	cmp	ax,3
	je	short @8@194
	jmp	short @8@218
@8@146:
   ;	
   ;	 {
   ;	   case keyboard : return ControlKBD ();
   ;	
	push	word ptr [bp+6]
	push	word ptr [bp+4]
	push	ss
	lea	ax,word ptr [bp-6]
	push	ax
	call	near ptr _ControlKBD
	pop	cx
	pop	cx
	lea	ax,word ptr [bp-6]
	push	ss
	push	ax
	mov	cx,6
	call	near ptr N_SCOPY@
	mov	ax,word ptr [bp+4]
	jmp	short @8@242
@8@170:
   ;	
   ;	   case joystick1: return ControlJoystick(1);
   ;	
	push	word ptr [bp+6]
	push	word ptr [bp+4]
	mov	ax,1
	push	ax
	push	ss
	lea	ax,word ptr [bp-12]
	push	ax
	call	near ptr _ControlJoystick
	add	sp,6
	lea	ax,word ptr [bp-12]
	push	ss
	push	ax
	mov	cx,6
	call	near ptr N_SCOPY@
	mov	ax,word ptr [bp+4]
	jmp	short @8@242
@8@194:
   ;	
   ;	   case joystick2: return ControlJoystick(2);
   ;	
	push	word ptr [bp+6]
	push	word ptr [bp+4]
	mov	ax,2
	push	ax
	push	ss
	lea	ax,word ptr [bp-18]
	push	ax
	call	near ptr _ControlJoystick
	add	sp,6
	lea	ax,word ptr [bp-18]
	push	ss
	push	ax
	mov	cx,6
	call	near ptr N_SCOPY@
	mov	ax,word ptr [bp+4]
	jmp	short @8@242
@8@218:
   ;	
   ;	 }
   ;	
   ;	 return ControlKBD();
   ;	
	push	word ptr [bp+6]
	push	word ptr [bp+4]
	push	ss
	lea	ax,word ptr [bp-24]
	push	ax
	call	near ptr _ControlKBD
	pop	cx
	pop	cx
	lea	ax,word ptr [bp-24]
	push	ss
	push	ax
	mov	cx,6
	call	near ptr N_SCOPY@
	mov	ax,word ptr [bp+4]
	jmp	short @8@242
@8@242:
   ;	
   ;	}
   ;	
	mov	sp,bp
	pop	bp
	ret	
_ControlPlayer	endp
   ;	
   ;	void ClearKeys (void)
   ;	
	assume	cs:_TEXT
_ClearKeys	proc	near
	push	bp
	mov	bp,sp
   ;	
   ;	{
   ;	  int i;
   ;	  NBKscan=NBKascii=0;
   ;	
	xor	ax,ax
	mov	word ptr DGROUP:_NBKascii,ax
	mov	word ptr DGROUP:_NBKscan,ax
   ;	
   ;	  memset (keydown,0,sizeof(keydown));
   ;	
	mov	ax,128
	push	ax
	xor	ax,ax
	push	ax
	mov	ax,offset DGROUP:_keydown
	push	ax
	call	near ptr _memset
	add	sp,6
   ;	
   ;	}
   ;	
	pop	bp
	ret	
_ClearKeys	endp
   ;	
   ;	void Ack(void)
   ;	
	assume	cs:_TEXT
_Ack	proc	near
	push	bp
	mov	bp,sp
	sub	sp,12
   ;	
   ;	{
   ;	  ControlStruct c;
   ;	
   ;	  ClearKeys();
   ;	
	call	near ptr _ClearKeys
@10@50:
   ;	
   ;	  while (1)
   ;	  {
   ;	    if (NBKscan>127)
   ;	
	cmp	word ptr DGROUP:_NBKscan,127
	jle	short @10@98
   ;	
   ;	    {
   ;	      NBKscan&=0x7f;
   ;	
	and	word ptr DGROUP:_NBKscan,127
   ;	
   ;	      return;
   ;	
	jmp	short @10@194
@10@98:
   ;	
   ;	    }
   ;	    c = ControlPlayer(1);
   ;	
	lea	ax,word ptr [bp-6]
	push	ss
	push	ax
	mov	ax,1
	push	ax
	push	ss
	lea	ax,word ptr [bp-12]
	push	ax
	call	near ptr _ControlPlayer
	add	sp,6
	lea	ax,word ptr [bp-12]
	push	ss
	push	ax
	mov	cx,6
	call	near ptr N_SCOPY@
   ;	
   ;	    if (c.button1 || c.button2)
   ;	
	cmp	word ptr [bp-4],0
	jne	short @10@146
	cmp	word ptr [bp-2],0
	je	short @10@170
@10@146:
   ;	
   ;	      return;
   ;	
	jmp	short @10@194
@10@170:
	jmp	short @10@50
@10@194:
   ;	
   ;	  }
   ;	}
   ;	
	mov	sp,bp
	pop	bp
	ret	
_Ack	endp
   ;	
   ;	unsigned long LoadFile(char *filename,char huge *buffer)
   ;	
	assume	cs:_TEXT
_LoadFile	proc	near
	push	bp
	mov	bp,sp
	sub	sp,18
   ;	
   ;	{
   ;	 unsigned handle,flength1=0,flength2=0,buf1,buf2,foff1,foff2,
   ;	
	mov	word ptr [bp-4],0
	mov	word ptr [bp-6],0
   ;	
   ;		  len1,len2;
   ;	
   ;	 buf1=FP_OFF(buffer);
   ;	
	mov	ax,word ptr [bp+6]
	mov	word ptr [bp-8],ax
   ;	
   ;	 buf2=FP_SEG(buffer);
   ;	
	mov	ax,word ptr [bp+8]
	mov	word ptr [bp-10],ax
   ;	
   ;	
   ;	asm		mov	WORD PTR foff1,0  	// file offset = 0 (start)
   ;	
			mov		WORD PTR [bp-12],0  	
   ;	
   ;	asm		mov	WORD PTR foff2,0
   ;	
			mov		WORD PTR [bp-14],0
   ;	
   ;	
   ;	asm		mov	dx,filename
   ;	
			mov		dx,[bp+4]
   ;	
   ;	asm		mov	ax,3d00h		// OPEN w/handle (read only)
   ;	
			mov		ax,3d00h		
   ;	
   ;	asm		int	21h
   ;	
			int		21h
   ;	
   ;	asm		jc	out
   ;	
	jc	short @11@1274
   ;	
   ;	
   ;	asm		mov	handle,ax
   ;	
			mov		[bp-2],ax
   ;	
   ;	asm		mov	bx,ax
   ;	
			mov		bx,ax
   ;	
   ;	asm		xor	cx,cx
   ;	
			xor		cx,cx
   ;	
   ;	asm		xor	dx,dx
   ;	
			xor		dx,dx
   ;	
   ;	asm		mov	ax,4202h
   ;	
			mov		ax,4202h
   ;	
   ;	asm		int	21h			// SEEK (find file length)
   ;	
			int		21h			
   ;	
   ;	asm		jc	out
   ;	
	jc	short @11@1274
   ;	
   ;	
   ;	asm		mov	flength1,ax
   ;	
			mov		[bp-4],ax
   ;	
   ;	asm		mov	len1,ax
   ;	
			mov		[bp-16],ax
   ;	
   ;	asm		mov	flength2,dx
   ;	
			mov		[bp-6],dx
   ;	
   ;	asm		mov	len2,dx
   ;	
			mov		[bp-18],dx
   ;	
   ;	
   ;	asm		mov	bx,handle
   ;	
			mov		bx,[bp-2]
   ;	
   ;	asm		xor	cx,cx
   ;	
			xor		cx,cx
   ;	
   ;	asm		xor	dx,dx
   ;	
			xor		dx,dx
   ;	
   ;	asm		mov	ax,4200h
   ;	
			mov		ax,4200h
   ;	
   ;	asm		int	21h			// SEEK (to file start)
   ;	
			int		21h			
   ;	
   ;	asm		jc	out
   ;	
	jc	short @11@1274
   ;	
   ;	
   ;	asm		cmp	WORD PTR len2,0			// MULTI-SEGMENTAL?
   ;	
			cmp		WORD PTR [bp-18],0			
   ;	
   ;	asm		je      L_2
   ;	
	je	short @11@1058
@11@650:
   ;	
   ;	
   ;	L_1:
   ;	
   ;	asm		push	ds
   ;	
			push		ds
   ;	
   ;	asm		mov	bx,handle
   ;	
			mov		bx,[bp-2]
   ;	
   ;	asm		mov	cx,8000h		// read 32K chunks
   ;	
			mov		cx,8000h		
   ;	
   ;	asm		mov	dx,buf1
   ;	
			mov		dx,[bp-8]
   ;	
   ;	asm		mov	ax,buf2
   ;	
			mov		ax,[bp-10]
   ;	
   ;	asm		mov	ds,ax
   ;	
			mov		ds,ax
   ;	
   ;	asm		mov	ah,3fh			// READ w/handle
   ;	
			mov		ah,3fh			
   ;	
   ;	asm		int	21h
   ;	
			int		21h
   ;	
   ;	asm		pop	ds
   ;	
			pop		ds
   ;	
   ;	asm		jc	out
   ;	
	jc	short @11@1274
   ;	
   ;	
   ;	asm		add	buf2,800h
   ;	
			add		[bp-10],800h
   ;	
   ;	asm		sub	len1,8000h
   ;	
			sub		[bp-16],8000h
   ;	
   ;	asm		sbb	WORD PTR len2,0
   ;	
			sbb		WORD PTR [bp-18],0
   ;	
   ;	asm		cmp	WORD PTR len2,0
   ;	
			cmp		WORD PTR [bp-18],0
   ;	
   ;	asm		ja	L_1
   ;	
	ja	short @11@650
   ;	
   ;	asm		cmp	len1,8000h
   ;	
			cmp		[bp-16],8000h
   ;	
   ;	asm		jae	L_1
   ;	
	jae	short @11@650
@11@1058:
   ;	
   ;	
   ;	L_2:
   ;	
   ;	asm		push	ds
   ;	
			push		ds
   ;	
   ;	asm		mov	bx,handle
   ;	
			mov		bx,[bp-2]
   ;	
   ;	asm		mov	cx,len1
   ;	
			mov		cx,[bp-16]
   ;	
   ;	asm		mov	dx,buf1
   ;	
			mov		dx,[bp-8]
   ;	
   ;	asm		mov	ax,buf2
   ;	
			mov		ax,[bp-10]
   ;	
   ;	asm		mov	ds,ax
   ;	
			mov		ds,ax
   ;	
   ;	asm		mov	ah,3fh			// READ w/handle
   ;	
			mov		ah,3fh			
   ;	
   ;	asm		int	21h
   ;	
			int		21h
   ;	
   ;	asm		pop	ds
   ;	
			pop		ds
@11@1274:
   ;	
   ;	
   ;	out:
   ;	
   ;	asm		mov	bx,handle		// CLOSE w/handle
   ;	
			mov		bx,[bp-2]		
   ;	
   ;	asm		mov	ah,3eh
   ;	
			mov		ah,3eh
   ;	
   ;	asm		int	21h
   ;	
			int		21h
   ;	
   ;	
   ;	
   ;	return (flength2*0x10000+flength1);
   ;	
	mov	dx,word ptr [bp-6]
	xor	ax,ax
	add	ax,word ptr [bp-4]
	adc	dx,0
	jmp	short @11@1370
@11@1370:
   ;	
   ;	
   ;	}
   ;	
	mov	sp,bp
	pop	bp
	ret	
_LoadFile	endp
   ;	
   ;	void SaveFile(char *filename,char huge *buffer, long size)
   ;	
	assume	cs:_TEXT
_SaveFile	proc	near
	push	bp
	mov	bp,sp
	sub	sp,10
   ;	
   ;	{
   ;	 unsigned int handle,buf1,buf2,foff1,foff2;
   ;	
   ;	 buf1=FP_OFF(buffer);
   ;	
	mov	ax,word ptr [bp+6]
	mov	word ptr [bp-4],ax
   ;	
   ;	 buf2=FP_SEG(buffer);
   ;	
	mov	ax,word ptr [bp+8]
	mov	word ptr [bp-6],ax
   ;	
   ;	
   ;	asm		mov	WORD PTR foff1,0  		// file offset = 0 (start)
   ;	
			mov		WORD PTR [bp-8],0  		
   ;	
   ;	asm		mov	WORD PTR foff2,0
   ;	
			mov		WORD PTR [bp-10],0
   ;	
   ;	
   ;	asm		mov	dx,filename
   ;	
			mov		dx,[bp+4]
   ;	
   ;	asm		mov	ax,3c00h		// CREATE w/handle (read only)
   ;	
			mov		ax,3c00h		
   ;	
   ;	asm		xor	cx,cx
   ;	
			xor		cx,cx
   ;	
   ;	asm		int	21h
   ;	
			int		21h
   ;	
   ;	asm		jc	out
   ;	
	jc	short @12@914
   ;	
   ;	
   ;	asm		mov	handle,ax
   ;	
			mov		[bp-2],ax
   ;	
   ;	asm		cmp	word ptr size+2,0	// larger than 1 segment?
   ;	
			cmp		word ptr [bp+10]+2,0	
   ;	
   ;	asm		je	L2
   ;	
	je	short @12@674
@12@290:
   ;	
   ;	
   ;	L1:
   ;	
   ;	asm		push	ds
   ;	
			push		ds
   ;	
   ;	asm		mov	bx,handle
   ;	
			mov		bx,[bp-2]
   ;	
   ;	asm		mov	cx,8000h
   ;	
			mov		cx,8000h
   ;	
   ;	asm		mov	dx,buf1
   ;	
			mov		dx,[bp-4]
   ;	
   ;	asm		mov	ax,buf2
   ;	
			mov		ax,[bp-6]
   ;	
   ;	asm		mov	ds,ax
   ;	
			mov		ds,ax
   ;	
   ;	asm		mov	ah,40h			// WRITE w/handle
   ;	
			mov		ah,40h			
   ;	
   ;	asm		int	21h
   ;	
			int		21h
   ;	
   ;	asm		pop	ds
   ;	
			pop		ds
   ;	
   ;	
   ;	asm		add	buf2,800h		// bump ptr up 1/2 segment
   ;	
			add		[bp-6],800h		
   ;	
   ;	asm		sub	WORD PTR size,8000h	// done yet?
   ;	
			sub		WORD PTR [bp+10],8000h	
   ;	
   ;	asm		sbb	WORD PTR size+2,0
   ;	
			sbb		WORD PTR [bp+10]+2,0
   ;	
   ;	asm		cmp	WORD PTR size+2,0
   ;	
			cmp		WORD PTR [bp+10]+2,0
   ;	
   ;	asm		ja	L1
   ;	
	ja	short @12@290
   ;	
   ;	asm		cmp	WORD PTR size,8000h
   ;	
			cmp		WORD PTR [bp+10],8000h
   ;	
   ;	asm		jae	L1
   ;	
	jae	short @12@290
@12@674:
   ;	
   ;	
   ;	L2:
   ;	
   ;	asm		push	ds
   ;	
			push		ds
   ;	
   ;	asm		mov	bx,handle
   ;	
			mov		bx,[bp-2]
   ;	
   ;	asm		mov	cx,WORD PTR size
   ;	
			mov		cx,WORD PTR [bp+10]
   ;	
   ;	asm		mov	dx,buf1
   ;	
			mov		dx,[bp-4]
   ;	
   ;	asm		mov	ax,buf2
   ;	
			mov		ax,[bp-6]
   ;	
   ;	asm		mov	ds,ax
   ;	
			mov		ds,ax
   ;	
   ;	asm		mov	ah,40h			// WRITE w/handle
   ;	
			mov		ah,40h			
   ;	
   ;	asm		int	21h
   ;	
			int		21h
   ;	
   ;	asm		pop	ds
   ;	
			pop		ds
   ;	
   ;	asm		jmp	out
   ;	
	jmp	short @12@914
@12@914:
   ;	
   ;	
   ;	out:
   ;	
   ;	asm		mov	bx,handle		// CLOSE w/handle
   ;	
			mov		bx,[bp-2]		
   ;	
   ;	asm		mov	ah,3eh
   ;	
			mov		ah,3eh
   ;	
   ;	asm		int	21h
   ;	
			int		21h
   ;	
   ;	
   ;	}
   ;	
	mov	sp,bp
	pop	bp
	ret	
_SaveFile	endp
   ;	
   ;	void BloadinMM (char *filename,memptr *spot)
   ;	
	assume	cs:_TEXT
_BloadinMM	proc	near
	push	bp
	mov	bp,sp
	sub	sp,86
	push	si
	push	di
	mov	si,word ptr [bp+4]
	mov	di,word ptr [bp+6]
   ;	
   ;	{
   ;	  int handle;
   ;	  long length;
   ;	  char huge *location;
   ;	  char error[80];
   ;	
   ;	  if ( (handle = open (filename,O_BINARY)) != -1 )
   ;	
	mov	ax,32768
	push	ax
	push	si
	call	near ptr _open
	pop	cx
	pop	cx
	mov	word ptr [bp-2],ax
	cmp	ax,65535
	je	short @13@74
   ;	
   ;	  {
   ;	    length = filelength (handle);
   ;	
	push	word ptr [bp-2]
	call	near ptr _filelength
	pop	cx
	mov	word ptr [bp-4],dx
	mov	word ptr [bp-6],ax
   ;	
   ;	    MMGetPtr (spot,length);
   ;	
	push	word ptr [bp-4]
	push	word ptr [bp-6]
	push	di
	call	near ptr _MMGetPtr
	add	sp,6
   ;	
   ;	    close (handle);
   ;	
	push	word ptr [bp-2]
	call	near ptr _close
	pop	cx
   ;	
   ;	    LoadFile (filename,*spot);
   ;	
	push	word ptr [di]
	xor	ax,ax
	push	ax
	push	si
	call	near ptr _LoadFile
	add	sp,6
   ;	
   ;	  }
   ;	
	jmp	short @13@98
@13@74:
   ;	
   ;	  else
   ;	  {
   ;	    strcpy (error,"BloadinMM: Can't find file ");
   ;	
	mov	ax,offset DGROUP:s@+446
	push	ax
	lea	ax,word ptr [bp-86]
	push	ax
	call	near ptr _strcpy
	pop	cx
	pop	cx
   ;	
   ;	    strcat (error,filename);
   ;	
	push	si
	lea	ax,word ptr [bp-86]
	push	ax
	call	near ptr _strcat
	pop	cx
	pop	cx
   ;	
   ;	    Quit (error);
   ;	
	lea	ax,word ptr [bp-86]
	push	ax
	call	near ptr _Quit
	pop	cx
@13@98:
   ;	
   ;	  }
   ;	}
   ;	
	pop	di
	pop	si
	mov	sp,bp
	pop	bp
	ret	
_BloadinMM	endp
   ;	
   ;	void BloadinRLEMM (char *filename,memptr *spot)
   ;	
	assume	cs:_TEXT
_BloadinRLEMM	proc	near
	push	bp
	mov	bp,sp
	sub	sp,6
	push	si
	mov	si,word ptr [bp+6]
   ;	
   ;	{
   ;	  long length;
   ;	  memptr org;
   ;	
   ;	  BloadinMM (filename,&org);
   ;	
	lea	ax,word ptr [bp-6]
	push	ax
	push	word ptr [bp+4]
	call	near ptr _BloadinMM
	pop	cx
	pop	cx
   ;	
   ;	  length = *(long _seg *)org;	// rleb compressed length
   ;	
	mov	es,word ptr [bp-6]
	mov	ax,word ptr es:[2]
	mov	dx,word ptr es:[0]
	mov	word ptr [bp-2],ax
	mov	word ptr [bp-4],dx
   ;	
   ;	  MMGetPtr (spot,length);
   ;	
	push	word ptr [bp-2]
	push	word ptr [bp-4]
	push	si
	call	near ptr _MMGetPtr
	add	sp,6
   ;	
   ;	  RLEBExpand ((unsigned char far *)org,(unsigned char far *)*spot);
   ;	
	push	word ptr [si]
	xor	ax,ax
	push	ax
	push	word ptr [bp-6]
	xor	ax,ax
	push	ax
	call	near ptr _RLEBExpand
	add	sp,8
   ;	
   ;	  MMFreePtr (&org);
   ;	
	lea	ax,word ptr [bp-6]
	push	ax
	call	near ptr _MMFreePtr
	pop	cx
   ;	
   ;	}
   ;	
	pop	si
	mov	sp,bp
	pop	bp
	ret	
_BloadinRLEMM	endp
   ;	
   ;	void BloadinHUFFMM (char *filename,memptr *spot)
   ;	
	assume	cs:_TEXT
_BloadinHUFFMM	proc	near
	push	bp
	mov	bp,sp
	sub	sp,6
	push	si
	push	di
	mov	di,word ptr [bp+4]
	mov	si,word ptr [bp+6]
   ;	
   ;	{
   ;	  long length;
   ;	  memptr org;
   ;	
   ;	  if (useegamem)
   ;	
	cmp	word ptr DGROUP:_useegamem,0
	je	short @15@74
   ;	
   ;	  {
   ;	    org = (memptr)(0xa000+(linewidth*200)/16);
   ;	
	mov	ax,word ptr DGROUP:_linewidth
	mov	dx,200
	imul	dx
	mov	cl,4
	shr	ax,cl
	add	ax,40960
	mov	word ptr [bp-6],ax
   ;	
   ;	    LoadFile (filename,MK_FP(org,0));
   ;	
	xor	ax,ax
	push	word ptr [bp-6]
	push	ax
	push	di
	call	near ptr _LoadFile
	add	sp,6
   ;	
   ;	  }
   ;	
	jmp	short @15@98
@15@74:
   ;	
   ;	  else
   ;	    BloadinMM (filename,&org);
   ;	
	lea	ax,word ptr [bp-6]
	push	ax
	push	di
	call	near ptr _BloadinMM
	pop	cx
	pop	cx
@15@98:
   ;	
   ;	
   ;	  length = *(((long _seg *)org)+1);	// huff compressed length
   ;	
	mov	es,word ptr [bp-6]
	mov	ax,word ptr es:[6]
	mov	dx,word ptr es:[4]
	mov	word ptr [bp-2],ax
	mov	word ptr [bp-4],dx
   ;	
   ;	  MMGetPtr (spot,length);
   ;	
	push	word ptr [bp-2]
	push	word ptr [bp-4]
	push	si
	call	near ptr _MMGetPtr
	add	sp,6
   ;	
   ;	  HuffExpandFile ((unsigned char far *)org,(unsigned char far *)*spot);
   ;	
	xor	ax,ax
	push	word ptr [si]
	push	ax
	xor	ax,ax
	push	word ptr [bp-6]
	push	ax
	call	near ptr _HuffExpandFile
	add	sp,8
   ;	
   ;	
   ;	  if (!useegamem)
   ;	
	cmp	word ptr DGROUP:_useegamem,0
	jne	short @15@146
   ;	
   ;	    MMFreePtr (&org);
   ;	
	lea	ax,word ptr [bp-6]
	push	ax
	call	near ptr _MMFreePtr
	pop	cx
@15@146:
   ;	
   ;	}
   ;	
	pop	di
	pop	si
	mov	sp,bp
	pop	bp
	ret	
_BloadinHUFFMM	endp
   ;	
   ;	long Verify(char *filename)
   ;	
	assume	cs:_TEXT
_Verify	proc	near
	push	bp
	mov	bp,sp
	sub	sp,4
	push	si
   ;	
   ;	{
   ;	 int handle;
   ;	 long size;
   ;	
   ;	 if ((handle=open(filename,O_BINARY))==-1) return 0;
   ;	
	mov	ax,32768
	push	ax
	push	word ptr [bp+4]
	call	near ptr _open
	pop	cx
	pop	cx
	mov	si,ax
	cmp	ax,65535
	jne	short @16@74
	xor	dx,dx
	xor	ax,ax
	jmp	short @16@98
@16@74:
   ;	
   ;	 size=filelength(handle);
   ;	
	push	si
	call	near ptr _filelength
	pop	cx
	mov	word ptr [bp-2],dx
	mov	word ptr [bp-4],ax
   ;	
   ;	 close(handle);
   ;	
	push	si
	call	near ptr _close
	pop	cx
   ;	
   ;	 return size;
   ;	
	mov	dx,word ptr [bp-2]
	mov	ax,word ptr [bp-4]
	jmp	short @16@98
@16@98:
   ;	
   ;	}
   ;	
	pop	si
	mov	sp,bp
	pop	bp
	ret	
_Verify	endp
   ;	
   ;	void StopDrive (void)
   ;	
	assume	cs:_TEXT
_StopDrive	proc	near
	push	bp
	mov	bp,sp
	push	si
   ;	
   ;	{
   ;	  int i;
   ;	
   ;	  for (i=0;i<100;i++)
   ;	
	xor	si,si
	jmp	short @17@98
@17@50:
   ;	
   ;	    CallTimer();
   ;	
	call	near ptr _CallTimer
	inc	si
@17@98:
	cmp	si,100
	jl	short @17@50
   ;	
   ;	}
   ;	
	pop	si
	pop	bp
	ret	
_StopDrive	endp
   ;	
   ;	void HuffExpandFile (unsigned char huge *infile,
   ;	
	assume	cs:_TEXT
_HuffExpandFile	proc	near
	push	bp
	mov	bp,sp
	sub	sp,8
   ;	
   ;	  unsigned char huge *outfile)
   ;	{
   ;	  char header[4];
   ;	  unsigned tag;
   ;	  long length;
   ;	
   ;	  header[0] = *infile;
   ;	
	les	bx,dword ptr [bp+4]
	mov	al,byte ptr es:[bx]
	mov	byte ptr [bp-4],al
   ;	
   ;	  header[1] = *(infile+1);
   ;	
	mov	dx,word ptr [bp+6]
	mov	ax,word ptr [bp+4]
	xor	cx,cx
	mov	bx,1
	call	near ptr N_PADD@
	mov	bx,ax
	mov	es,dx
	mov	al,byte ptr es:[bx]
	mov	byte ptr [bp-3],al
   ;	
   ;	  header[2] = *(infile+2);
   ;	
	mov	dx,word ptr [bp+6]
	mov	ax,word ptr [bp+4]
	xor	cx,cx
	mov	bx,2
	call	near ptr N_PADD@
	mov	bx,ax
	mov	es,dx
	mov	al,byte ptr es:[bx]
	mov	byte ptr [bp-2],al
   ;	
   ;	  header[3] = *(infile+3);
   ;	
	mov	dx,word ptr [bp+6]
	mov	ax,word ptr [bp+4]
	xor	cx,cx
	mov	bx,3
	call	near ptr N_PADD@
	mov	bx,ax
	mov	es,dx
	mov	al,byte ptr es:[bx]
	mov	byte ptr [bp-1],al
   ;	
   ;	  if (strncmp (header,"HUFF",4))
   ;	
	mov	ax,4
	push	ax
	mov	ax,offset DGROUP:s@+474
	push	ax
	lea	ax,word ptr [bp-4]
	push	ax
	call	near ptr _strncmp
	add	sp,6
	or	ax,ax
	je	short @18@74
   ;	
   ;	    Quit ("Tried to expand a file that isn't HUFF!");
   ;	
	mov	ax,offset DGROUP:s@+479
	push	ax
	call	near ptr _Quit
	pop	cx
@18@74:
   ;	
   ;	
   ;	  length = *(long huge *)(infile+4);
   ;	
	mov	dx,word ptr [bp+6]
	mov	ax,word ptr [bp+4]
	xor	cx,cx
	mov	bx,4
	call	near ptr N_PADD@
	mov	bx,ax
	mov	es,dx
	mov	ax,word ptr es:[bx+2]
	mov	dx,word ptr es:[bx]
	mov	word ptr [bp-6],ax
	mov	word ptr [bp-8],dx
   ;	
   ;	
   ;	  movedata(FP_SEG(infile+8),FP_OFF(infile+8),_DS,(unsigned)&nodearray,1020);
   ;	
	mov	ax,1020
	push	ax
	mov	ax,offset DGROUP:_nodearray
	push	ax
	push	ds
	mov	dx,word ptr [bp+6]
	mov	ax,word ptr [bp+4]
	xor	cx,cx
	mov	bx,8
	call	near ptr N_PADD@
	push	ax
	mov	dx,word ptr [bp+6]
	mov	ax,word ptr [bp+4]
	xor	cx,cx
	mov	bx,8
	call	near ptr N_PADD@
	push	dx
	call	near ptr _movedata
	add	sp,10
   ;	
   ;	  OptimizeNodes (nodearray);
   ;	
	mov	ax,offset DGROUP:_nodearray
	push	ax
	call	near ptr _OptimizeNodes
	pop	cx
   ;	
   ;	  HuffExpand (infile+1028,outfile,length,nodearray);
   ;	
	mov	ax,offset DGROUP:_nodearray
	push	ax
	push	word ptr [bp-6]
	push	word ptr [bp-8]
	push	word ptr [bp+10]
	push	word ptr [bp+8]
	mov	dx,word ptr [bp+6]
	mov	ax,word ptr [bp+4]
	xor	cx,cx
	mov	bx,1028
	call	near ptr N_PADD@
	push	dx
	push	ax
	call	near ptr _HuffExpand
	add	sp,14
   ;	
   ;	}
   ;	
	mov	sp,bp
	pop	bp
	ret	
_HuffExpandFile	endp
   ;	
   ;	void OptimizeNodes (huffnode *table)
   ;	
	assume	cs:_TEXT
_OptimizeNodes	proc	near
	push	bp
	mov	bp,sp
	push	si
	push	di
	mov	di,word ptr [bp+4]
   ;	
   ;	{
   ;	  huffnode *node;
   ;	  int i;
   ;	
   ;	  node = table;
   ;	
	mov	si,di
   ;	
   ;	
   ;	  for (i=0;i<255;i++)
   ;	
	xor	bx,bx
	jmp	short @19@194
@19@50:
   ;	
   ;	  {
   ;	    if (node->bit0 >= 256)
   ;	
	cmp	word ptr [si],256
	jb	short @19@98
   ;	
   ;	      node->bit0 = (unsigned)(table+(node->bit0-256));
   ;	
	mov	ax,word ptr [si]
	sub	ax,256
	shl	ax,1
	shl	ax,1
	mov	dx,di
	add	dx,ax
	mov	word ptr [si],dx
@19@98:
   ;	
   ;	    if (node->bit1 >= 256)
   ;	
	cmp	word ptr [si+2],256
	jb	short @19@146
   ;	
   ;	      node->bit1 = (unsigned)(table+(node->bit1-256));
   ;	
	mov	ax,word ptr [si+2]
	sub	ax,256
	shl	ax,1
	shl	ax,1
	mov	dx,di
	add	dx,ax
	mov	word ptr [si+2],dx
@19@146:
   ;	
   ;	    node++;
   ;	
	add	si,4
	inc	bx
@19@194:
	cmp	bx,255
	jl	short @19@50
   ;	
   ;	  }
   ;	}
   ;	
	pop	di
	pop	si
	pop	bp
	ret	
_OptimizeNodes	endp
   ;	
   ;	void HuffExpand (unsigned char huge *source, unsigned char huge *dest,
   ;	
	assume	cs:_TEXT
_HuffExpand	proc	near
	push	bp
	mov	bp,sp
	sub	sp,10
	push	si
	push	di
   ;	
   ;	  long length,huffnode *hufftable)
   ;	{
   ;	  unsigned bit,byte,node,code;
   ;	  unsigned sourceseg,sourceoff,destseg,destoff,endseg,endoff;
   ;	  huffnode *nodeon,*headptr;
   ;	
   ;	  headptr = hufftable+254;	// head node is allways node 254
   ;	
	mov	ax,word ptr [bp+16]
	add	ax,1016
	mov	word ptr [bp-10],ax
   ;	
   ;	
   ;	#if0
   ;	  bit = 1;
   ;	  byte = *source++;
   ;	
   ;	  while (length)
   ;	  {
   ;	    if (byte&bit)
   ;	      code = nodeon->bit1;
   ;	    else
   ;	      code = nodeon->bit0;
   ;	
   ;	    bit<<=1;
   ;	    if (bit==256)
   ;	    {
   ;	      bit=1;
   ;	      byte = *source++;
   ;	    }
   ;	
   ;	    if (code<256)
   ;	    {
   ;	      *dest++=code;
   ;	      nodeon=headptr;
   ;	      length--;
   ;	    }
   ;	    else
   ;	      nodeon = (huffnode *)code;
   ;	  }
   ;	
   ;	#endif
   ;	
   ;	  source++;	// normalize
   ;	
	xor	cx,cx
	mov	bx,1
	mov	dx,ss
	lea	ax,word ptr [bp+4]
	call	near ptr N_PADA@
   ;	
   ;	  source--;
   ;	
	xor	cx,cx
	mov	bx,1
	mov	dx,ss
	lea	ax,word ptr [bp+4]
	call	near ptr N_PSBA@
   ;	
   ;	  dest++;
   ;	
	xor	cx,cx
	mov	bx,1
	mov	dx,ss
	lea	ax,word ptr [bp+8]
	call	near ptr N_PADA@
   ;	
   ;	  dest--;
   ;	
	xor	cx,cx
	mov	bx,1
	mov	dx,ss
	lea	ax,word ptr [bp+8]
	call	near ptr N_PSBA@
   ;	
   ;	
   ;	  sourceseg = FP_SEG(source);
   ;	
	mov	ax,word ptr [bp+6]
	mov	word ptr [bp-2],ax
   ;	
   ;	  sourceoff = FP_OFF(source);
   ;	
	mov	ax,word ptr [bp+4]
	mov	word ptr [bp-4],ax
   ;	
   ;	  destseg = FP_SEG(dest);
   ;	
	mov	ax,word ptr [bp+10]
	mov	word ptr [bp-6],ax
   ;	
   ;	  destoff = FP_OFF(dest);
   ;	
	mov	ax,word ptr [bp+8]
	mov	word ptr [bp-8],ax
   ;	
   ;	
   ;	  length--;
   ;	
	sub	word ptr [bp+12],1
	sbb	word ptr [bp+14],0
   ;	
   ;	//
   ;	// al = source byte
   ;	// cl = bit in source (1,2,4,8,...)
   ;	// dx = code
   ;	//
   ;	// ds:si source
   ;	// es:di dest
   ;	// ss:bx node pointer
   ;	//
   ;	
   ;	asm     mov	bx,[headptr]
   ;	
     	mov		bx,[[bp-10]]
   ;	
   ;	asm	mov	cl,1
   ;	
		mov		cl,1
   ;	
   ;	
   ;	asm	mov	si,[sourceoff]
   ;	
		mov		si,[[bp-4]]
   ;	
   ;	asm	mov	di,[destoff]
   ;	
		mov		di,[[bp-8]]
   ;	
   ;	asm	mov	es,[destseg]
   ;	
		mov		es,[[bp-6]]
   ;	
   ;	asm	mov	ds,[sourceseg]
   ;	
		mov		ds,[[bp-2]]
   ;	
   ;	
   ;	asm	lodsb			// load first byte
   ;	
		lodsb				
@20@218:
   ;	
   ;	
   ;	expand:
   ;	asm	test	al,cl		// bit set?
   ;	
		test		al,cl		
   ;	
   ;	asm	jnz	bit1
   ;	
	jne	short @20@314
   ;	
   ;	asm	mov	dx,[ss:bx]	// take bit0 path from node
   ;	
		mov		dx,[ss:bx]	
   ;	
   ;	asm	jmp	gotcode
   ;	
	jmp	short @20@338
@20@314:
   ;	
   ;	bit1:
   ;	asm	mov	dx,[ss:bx+2]	// take bit1 path
   ;	
		mov		dx,[ss:bx+2]	
@20@338:
   ;	
   ;	
   ;	gotcode:
   ;	asm	shl	cl,1		// advance to next bit position
   ;	
		shl		cl,1		
   ;	
   ;	asm	jnc	sourceup
   ;	
	jnc	short @20@578
   ;	
   ;	asm	lodsb
   ;	
		lodsb	
   ;	
   ;	asm	cmp	si,0x10		// normalize ds:si
   ;	
		cmp		si,010H		
   ;	
   ;	asm  	jb	sinorm
   ;	
	jb	short @20@554
   ;	
   ;	asm	mov	cx,ds
   ;	
		mov		cx,ds
   ;	
   ;	asm	inc	cx
   ;	
		inc		cx
   ;	
   ;	asm	mov	ds,cx
   ;	
		mov		ds,cx
   ;	
   ;	asm	xor	si,si
   ;	
		xor		si,si
@20@554:
   ;	
   ;	sinorm:
   ;	asm	mov	cl,1		// back to first bit
   ;	
		mov		cl,1		
@20@578:
   ;	
   ;	
   ;	sourceup:
   ;	asm	or	dh,dh		// if dx<256 its a byte, else move node
   ;	
		or		dh,dh		
   ;	
   ;	asm	jz	storebyte
   ;	
	je	short @20@674
   ;	
   ;	asm	mov	bx,dx		// next node = (huffnode *)code
   ;	
		mov		bx,dx		
   ;	
   ;	asm	jmp	expand
   ;	
	jmp	short @20@218
@20@674:
   ;	
   ;	
   ;	storebyte:
   ;	asm	mov	[es:di],dl
   ;	
		mov		[es:di],dl
   ;	
   ;	asm	inc	di		// write a decopmpressed byte out
   ;	
		inc		di		
   ;	
   ;	asm	mov	bx,[headptr]	// back to the head node for next bit
   ;	
		mov		bx,[[bp-10]]	
   ;	
   ;	
   ;	asm	cmp	di,0x10		// normalize es:di
   ;	
		cmp		di,010H		
   ;	
   ;	asm  	jb	dinorm
   ;	
	jb	short @20@890
   ;	
   ;	asm	mov	dx,es
   ;	
		mov		dx,es
   ;	
   ;	asm	inc	dx
   ;	
		inc		dx
   ;	
   ;	asm	mov	es,dx
   ;	
		mov		es,dx
   ;	
   ;	asm	xor	di,di
   ;	
		xor		di,di
@20@890:
   ;	
   ;	dinorm:
   ;	
   ;	asm	sub	[WORD PTR ss:length],1
   ;	
		sub		[WORD PTR ss:[bp+12]],1
   ;	
   ;	asm	jnc	expand
   ;	
	jnc	short @20@218
   ;	
   ;	asm  	dec	[WORD PTR ss:length+2]
   ;	
  		dec		[WORD PTR ss:[bp+12]+2]
   ;	
   ;	asm	jns	expand		// when length = ffff ffff, done
   ;	
	jns	short @20@218
   ;	
   ;	
   ;	asm	mov	ax,ss
   ;	
		mov		ax,ss
   ;	
   ;	asm	mov	ds,ax
   ;	
		mov		ds,ax
   ;	
   ;	
   ;	}
   ;	
	pop	di
	pop	si
	mov	sp,bp
	pop	bp
	ret	
_HuffExpand	endp
   ;	
   ;	void RLEWExpand (unsigned far *source, unsigned far *dest)
   ;	
	assume	cs:_TEXT
_RLEWExpand	proc	near
	push	bp
	mov	bp,sp
	sub	sp,10
	push	si
	push	di
   ;	
   ;	{
   ;	  long length;
   ;	  unsigned value,count,i;
   ;	  unsigned far *start,far *end;
   ;	
   ;	  length = *(long far *)source;
   ;	
	les	bx,dword ptr [bp+4]
	mov	ax,word ptr es:[bx+2]
	mov	dx,word ptr es:[bx]
	mov	word ptr [bp-2],ax
	mov	word ptr [bp-4],dx
   ;	
   ;	  end = dest + (length)/2;
   ;	
	xor	ax,ax
	mov	dx,2
	push	ax
	push	dx
	push	word ptr [bp-2]
	push	word ptr [bp-4]
	call	near ptr N_LDIV@
	shl	ax,1
	mov	dx,word ptr [bp+10]
	mov	bx,word ptr [bp+8]
	add	bx,ax
	mov	word ptr [bp-8],dx
	mov	word ptr [bp-10],bx
   ;	
   ;	
   ;	  source+=2;		// skip length words
   ;	
	add	word ptr [bp+4],4
@21@50:
   ;	
   ;	//
   ;	// expand it
   ;	//
   ;	  do
   ;	  {
   ;	    value = *source++;
   ;	
	les	bx,dword ptr [bp+4]
	mov	si,word ptr es:[bx]
	add	word ptr [bp+4],2
   ;	
   ;	    if (value != RLETAG)
   ;	
	cmp	si,65278
	je	short @21@98
   ;	
   ;	    //
   ;	    // uncompressed
   ;	    //
   ;	      *dest++=value;
   ;	
	les	bx,dword ptr [bp+8]
	mov	word ptr es:[bx],si
	add	word ptr [bp+8],2
	jmp	short @21@242
@21@98:
   ;	
   ;	    else
   ;	    {
   ;	    //
   ;	    // compressed string
   ;	    //
   ;	      count = *source++;
   ;	
	les	bx,dword ptr [bp+4]
	mov	ax,word ptr es:[bx]
	mov	word ptr [bp-6],ax
	add	word ptr [bp+4],2
   ;	
   ;	      value = *source++;
   ;	
	les	bx,dword ptr [bp+4]
	mov	si,word ptr es:[bx]
	add	word ptr [bp+4],2
   ;	
   ;	      if (dest+count>end)
   ;	
	mov	ax,word ptr [bp-6]
	shl	ax,1
	mov	dx,word ptr [bp+8]
	add	dx,ax
	cmp	dx,word ptr [bp-10]
	jbe	short @21@146
   ;	
   ;		Quit("RLEWExpand error!");
   ;	
	mov	ax,offset DGROUP:s@+519
	push	ax
	call	near ptr _Quit
	pop	cx
@21@146:
   ;	
   ;	
   ;	      for (i=1;i<=count;i++)
   ;	
	mov	di,1
	jmp	short @21@218
@21@170:
   ;	
   ;		*dest++ = value;
   ;	
	les	bx,dword ptr [bp+8]
	mov	word ptr es:[bx],si
	add	word ptr [bp+8],2
	inc	di
@21@218:
	cmp	di,word ptr [bp-6]
	jbe	short @21@170
@21@242:
   ;	
   ;	    }
   ;	  } while (dest<end);
   ;	
	mov	ax,word ptr [bp+8]
	cmp	ax,word ptr [bp-10]
	jb	short @21@50
   ;	
   ;	
   ;	}
   ;	
	pop	di
	pop	si
	mov	sp,bp
	pop	bp
	ret	
_RLEWExpand	endp
   ;	
   ;	void RLEBExpand (unsigned char far *source, unsigned char far *dest)
   ;	
	assume	cs:_TEXT
_RLEBExpand	proc	near
	push	bp
	mov	bp,sp
	sub	sp,10
	push	si
   ;	
   ;	{
   ;	  long length;
   ;	  unsigned char value,count;
   ;	  unsigned i;
   ;	  unsigned char far *start,far *end;
   ;	
   ;	  length = *(long far *)source;
   ;	
	les	bx,dword ptr [bp+4]
	mov	ax,word ptr es:[bx+2]
	mov	dx,word ptr es:[bx]
	mov	word ptr [bp-2],ax
	mov	word ptr [bp-4],dx
   ;	
   ;	  end = dest + (length);
   ;	
	mov	ax,word ptr [bp+10]
	mov	dx,word ptr [bp+8]
	add	dx,word ptr [bp-4]
	mov	word ptr [bp-8],ax
	mov	word ptr [bp-10],dx
   ;	
   ;	
   ;	  source+=4;		// skip length words
   ;	
	add	word ptr [bp+4],4
@22@50:
   ;	
   ;	//
   ;	// expand it
   ;	//
   ;	  do
   ;	  {
   ;	    value = *source++;
   ;	
	les	bx,dword ptr [bp+4]
	mov	al,byte ptr es:[bx]
	mov	cl,al
	inc	word ptr [bp+4]
   ;	
   ;	    if (value != RLEBTAG)
   ;	
	cmp	cl,254
	je	short @22@98
   ;	
   ;	    //
   ;	    // uncompressed
   ;	    //
   ;	      *dest++=value;
   ;	
	les	bx,dword ptr [bp+8]
	mov	al,cl
	mov	byte ptr es:[bx],al
	inc	word ptr [bp+8]
	jmp	short @22@194
@22@98:
   ;	
   ;	    else
   ;	    {
   ;	    //
   ;	    // compressed string
   ;	    //
   ;	      count = *source++;
   ;	
	les	bx,dword ptr [bp+4]
	mov	al,byte ptr es:[bx]
	mov	byte ptr [bp-5],al
	inc	word ptr [bp+4]
   ;	
   ;	      value = *source++;
   ;	
	les	bx,dword ptr [bp+4]
	mov	al,byte ptr es:[bx]
	mov	cl,al
	inc	word ptr [bp+4]
   ;	
   ;	      for (i=1;i<=count;i++)
   ;	
	mov	si,1
	jmp	short @22@170
@22@122:
   ;	
   ;		*dest++ = value;
   ;	
	les	bx,dword ptr [bp+8]
	mov	al,cl
	mov	byte ptr es:[bx],al
	inc	word ptr [bp+8]
	inc	si
@22@170:
	mov	al,byte ptr [bp-5]
	mov	ah,0
	cmp	ax,si
	jae	short @22@122
@22@194:
   ;	
   ;	    }
   ;	  } while (dest<end);
   ;	
	mov	ax,word ptr [bp+8]
	cmp	ax,word ptr [bp-10]
	jb	short @22@50
   ;	
   ;	
   ;	}
   ;	
	pop	si
	mov	sp,bp
	pop	bp
	ret	
_RLEBExpand	endp
   ;	
   ;	void LoadPage(char *filename,unsigned dest)
   ;	
	assume	cs:_TEXT
_LoadPage	proc	near
	push	bp
	mov	bp,sp
	sub	sp,8
	push	si
	push	di
   ;	
   ;	{
   ;	  memptr src;
   ;	  unsigned from,source;
   ;	  long length;
   ;	  int i,j,width,height,xx,x,y,plane;
   ;	
   ;	//
   ;	// load the pic in
   ;	//
   ;	
   ;	  BloadinHUFFMM (filename,&src);
   ;	
	lea	ax,word ptr [bp-2]
	push	ax
	push	word ptr [bp+4]
	call	near ptr _BloadinHUFFMM
	pop	cx
	pop	cx
   ;	
   ;	  StopDrive();
   ;	
	call	near ptr _StopDrive
   ;	
   ;	
   ;	  from = 8;
   ;	
	mov	word ptr [bp-4],8
   ;	
   ;	  width = *((int far *)src+2);
   ;	
	mov	es,word ptr [bp-2]
	mov	ax,word ptr es:[4]
	mov	word ptr [bp-6],ax
   ;	
   ;	  height = *((int far *)src+3);
   ;	
	mov	es,word ptr [bp-2]
	mov	ax,word ptr es:[6]
	mov	word ptr [bp-8],ax
   ;	
   ;	  for (i=0;i<4;i++)
   ;	
	xor	di,di
	jmp	short @23@194
@23@50:
   ;	
   ;	  {
   ;	    EGAplane(i);
   ;	
	push	di
	call	near ptr _EGAplane
	pop	cx
   ;	
   ;	    for (j=0;j<height;j++)
   ;	
	xor	si,si
	jmp	short @23@122
@23@74:
   ;	
   ;	      movedata((unsigned)src,from+width*j,0xa000,dest+linewidth*j,width);
   ;	
	push	word ptr [bp-6]
	mov	ax,word ptr DGROUP:_linewidth
	imul	si
	mov	dx,word ptr [bp+6]
	add	dx,ax
	push	dx
	mov	ax,40960
	push	ax
	mov	ax,word ptr [bp-6]
	imul	si
	mov	dx,word ptr [bp-4]
	add	dx,ax
	push	dx
	push	word ptr [bp-2]
	call	near ptr _movedata
	add	sp,10
	inc	si
@23@122:
	cmp	si,word ptr [bp-8]
	jl	short @23@74
   ;	
   ;	   from += width*height;
   ;	
	mov	ax,word ptr [bp-6]
	imul	word ptr [bp-8]
	add	word ptr [bp-4],ax
	inc	di
@23@194:
	cmp	di,4
	jl	short @23@50
   ;	
   ;	  }
   ;	  MMFreePtr (&src);
   ;	
	lea	ax,word ptr [bp-2]
	push	ax
	call	near ptr _MMFreePtr
	pop	cx
   ;	
   ;	}
   ;	
	pop	di
	pop	si
	mov	sp,bp
	pop	bp
	ret	
_LoadPage	endp
   ;	
   ;	void GenYlookup (void)
   ;	
	assume	cs:_TEXT
_GenYlookup	proc	near
	push	bp
	mov	bp,sp
	push	si
   ;	
   ;	{
   ;	  int i;
   ;	
   ;	  for (i=0;i<256;i++)
   ;	
	xor	si,si
	jmp	short @24@98
@24@50:
   ;	
   ;	    ylookup[i]=i*linewidth;
   ;	
	mov	ax,si
	imul	word ptr DGROUP:_linewidth
	mov	bx,si
	shl	bx,1
	mov	word ptr DGROUP:_ylookup[bx],ax
	inc	si
@24@98:
	cmp	si,256
	jl	short @24@50
   ;	
   ;	}
   ;	
	pop	si
	pop	bp
	ret	
_GenYlookup	endp
   ;	
   ;	void SetScreenMode (grtype mode)
   ;	
	assume	cs:_TEXT
_SetScreenMode	proc	near
	push	bp
	mov	bp,sp
   ;	
   ;	{
   ;	  switch (mode)
   ;	
	mov	ax,word ptr [bp+4]
	or	ax,ax
	je	short @25@146
	cmp	ax,1
	je	short @25@170
	cmp	ax,2
	je	short @25@194
	jmp	short @25@218
@25@146:
   ;	
   ;	  {
   ;	    case text:  _AX = 3;
   ;	
	mov	ax,3
   ;	
   ;			geninterrupt (0x10);
   ;	
	int	16
   ;	
   ;			screenseg=0xb000;
   ;	
	mov	word ptr DGROUP:_screenseg,45056
   ;	
   ;			break;
   ;	
	jmp	short @25@218
@25@170:
   ;	
   ;	    case CGAgr: _AX = 4;
   ;	
	mov	ax,4
   ;	
   ;			geninterrupt (0x10);
   ;	
	int	16
   ;	
   ;			screenseg=0xb800;
   ;	
	mov	word ptr DGROUP:_screenseg,47104
   ;	
   ;			break;
   ;	
	jmp	short @25@218
@25@194:
   ;	
   ;	    case EGAgr: _AX = 0xd;
   ;	
	mov	ax,13
   ;	
   ;			geninterrupt (0x10);
   ;	
	int	16
   ;	
   ;			screenseg=0xa000;
   ;	
	mov	word ptr DGROUP:_screenseg,40960
   ;	
   ;			break;
   ;	
	jmp	short @25@218
@25@218:
   ;	
   ;	#ifdef VGAGAME
   ;	    case VGAgr:{
   ;			char extern VGAPAL;	// deluxepaint vga pallet .OBJ file
   ;			void far *vgapal = &VGAPAL;
   ;			SetCool256 ();		// custom 256 color mode
   ;			screenseg=0xa000;
   ;			_ES = FP_SEG(vgapal);
   ;			_DX = FP_OFF(vgapal);
   ;			_BX = 0;
   ;			_CX = 0x100;
   ;			_AX = 0x1012;
   ;			geninterrupt(0x10);			// set the deluxepaint pallet
   ;	
   ;			break;
   ;	#endif
   ;	  }
   ;	}
   ;	
	pop	bp
	ret	
_SetScreenMode	endp
   ;	
   ;	void EGASplitScreen (int linenum)
   ;	
	assume	cs:_TEXT
_EGASplitScreen	proc	near
	push	bp
	mov	bp,sp
	push	si
	mov	si,word ptr [bp+4]
   ;	
   ;	{
   ;	  WaitVBL (1);
   ;	
	mov	ax,1
	push	ax
	call	near ptr _WaitVBL
	pop	cx
   ;	
   ;	  if (videocard==VGAcard)
   ;	
	cmp	word ptr DGROUP:_videocard,5
	jne	short @26@74
   ;	
   ;	    linenum=linenum*2-1;
   ;	
	mov	ax,si
	shl	ax,1
	dec	ax
	mov	si,ax
@26@74:
   ;	
   ;	  outportb (CRTC_INDEX,CRTC_LINECOMPARE);
   ;	
	mov	dx,980
	mov	al,24
	out	dx,al
   ;	
   ;	  outportb (CRTC_INDEX+1,linenum % 256);
   ;	
	mov	ax,si
	mov	bx,256
	cwd	
	idiv	bx
	push	dx
	mov	dx,981
	pop	ax
	out	dx,al
   ;	
   ;	  outportb (CRTC_INDEX,CRTC_OVERFLOW);
   ;	
	mov	dx,980
	mov	al,7
	out	dx,al
   ;	
   ;	  outportb (CRTC_INDEX+1, 1+16*(linenum/256));
   ;	
	mov	ax,si
	mov	bx,256
	cwd	
	idiv	bx
	mov	cl,4
	shl	al,cl
	inc	al
	mov	dx,981
	out	dx,al
   ;	
   ;	  if (videocard==VGAcard)
   ;	
	cmp	word ptr DGROUP:_videocard,5
	jne	short @26@122
   ;	
   ;	  {
   ;	    outportb (CRTC_INDEX,CRTC_MAXSCANLINE);
   ;	
	mov	dx,980
	mov	al,9
	out	dx,al
   ;	
   ;	    outportb (CRTC_INDEX+1,inportb(CRTC_INDEX+1) & (255-64));
   ;	
	mov	dx,981
	in	al,dx
	and	al,191
	mov	dx,981
	out	dx,al
@26@122:
   ;	
   ;	  }
   ;	}
   ;	
	pop	si
	pop	bp
	ret	
_EGASplitScreen	endp
   ;	
   ;	void EGAVirtualScreen (int width)	// sets screen width
   ;	
	assume	cs:_TEXT
_EGAVirtualScreen	proc	near
	push	bp
	mov	bp,sp
   ;	
   ;	{
   ;	  WaitVBL (1);
   ;	
	mov	ax,1
	push	ax
	call	near ptr _WaitVBL
	pop	cx
   ;	
   ;	  outportb(CRTC_INDEX,CRTC_OFFSET);
   ;	
	mov	dx,980
	mov	al,19
	out	dx,al
   ;	
   ;	  outportb(CRTC_INDEX+1,width/2);		// wide virtual screen
   ;	
	mov	ax,word ptr [bp+4]
	mov	bx,2
	cwd	
	idiv	bx
	mov	dx,981
	out	dx,al
   ;	
   ;	}
   ;	
	pop	bp
	ret	
_EGAVirtualScreen	endp
   ;	
   ;	void ColorBorder (int color)
   ;	
	assume	cs:_TEXT
_ColorBorder	proc	near
	push	bp
	mov	bp,sp
   ;	
   ;	{
   ;	  _AH=0x10;
   ;	
	mov	ah,16
   ;	
   ;	  _AL=1;
   ;	
	mov	al,1
   ;	
   ;	  _BH=color;
   ;	
	mov	bh,byte ptr [bp+4]
   ;	
   ;	  geninterrupt (0x10);        	// color the border
   ;	
	int	16
   ;	
   ;	}
   ;	
	pop	bp
	ret	
_ColorBorder	endp
   ;	
   ;	void CRTCstart (unsigned start)
   ;	
	assume	cs:_TEXT
_CRTCstart	proc	near
	push	bp
	mov	bp,sp
   ;	
   ;	{
   ;	  WaitVBL (1);
   ;	
	mov	ax,1
	push	ax
	call	near ptr _WaitVBL
	pop	cx
   ;	
   ;	  outportb (CRTC_INDEX,CRTC_STARTLOW);
   ;	
	mov	dx,980
	mov	al,13
	out	dx,al
   ;	
   ;	  outportb (CRTC_INDEX+1,start % 256);
   ;	
	mov	al,byte ptr [bp+4]
	and	al,255
	mov	dx,981
	out	dx,al
   ;	
   ;	  outportb (CRTC_INDEX,CRTC_STARTHIGH);
   ;	
	mov	dx,980
	mov	al,12
	out	dx,al
   ;	
   ;	  outportb (CRTC_INDEX+1,start / 256);
   ;	
	mov	ax,word ptr [bp+4]
	mov	cl,8
	shr	ax,cl
	mov	dx,981
	out	dx,al
   ;	
   ;	}
   ;	
	pop	bp
	ret	
_CRTCstart	endp
_TEXT	ends
_DATA	segment word public 'DATA'
_colors	label	byte
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	1
	db	2
	db	3
	db	4
	db	5
	db	6
	db	7
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0
	db	24
	db	25
	db	26
	db	27
	db	28
	db	29
	db	30
	db	31
	db	0
	db	0
	db	1
	db	2
	db	3
	db	4
	db	5
	db	6
	db	7
	db	24
	db	25
	db	26
	db	27
	db	28
	db	29
	db	30
	db	31
	db	0
	db	0
	db	1
	db	2
	db	3
	db	4
	db	5
	db	6
	db	7
	db	31
	db	31
	db	31
	db	31
	db	31
	db	31
	db	31
	db	31
	db	0
	db	31
	db	31
	db	31
	db	31
	db	31
	db	31
	db	31
	db	31
	db	31
	db	31
	db	31
	db	31
	db	31
	db	31
	db	31
	db	31
	db	31
	db	17 dup (0)
_DATA	ends
_TEXT	segment byte public 'CODE'
   ;	
   ;	void SetDefaultColors(void)
   ;	
	assume	cs:_TEXT
_SetDefaultColors	proc	near
	push	bp
	mov	bp,sp
   ;	
   ;	{
   ;	  colors[3][16] = bordercolor;
   ;	
	mov	al,byte ptr DGROUP:_bordercolor
	mov	byte ptr DGROUP:_colors+67,al
   ;	
   ;	  _ES=FP_SEG(&colors[3]);
   ;	
	mov	ax,ds
	mov	es,ax
   ;	
   ;	  _DX=FP_OFF(&colors[3]);
   ;	
	mov	dx,offset DGROUP:_colors+51
   ;	
   ;	  _AX=0x1002;
   ;	
	mov	ax,4098
   ;	
   ;	  geninterrupt(0x10);
   ;	
	int	16
   ;	
   ;	}
   ;	
	pop	bp
	ret	
_SetDefaultColors	endp
   ;	
   ;	void FadeIn(void)
   ;	
	assume	cs:_TEXT
_FadeIn	proc	near
	push	bp
	mov	bp,sp
	push	si
   ;	
   ;	{
   ;	 int i;
   ;	
   ;	 for (i=0;i<4;i++)
   ;	
	xor	si,si
	jmp	short @31@98
@31@50:
   ;	
   ;	 {
   ;	   colors[i][16] = bordercolor;
   ;	
	mov	ax,si
	mov	dx,17
	imul	dx
	mov	dl,byte ptr DGROUP:_bordercolor
	mov	bx,ax
	mov	byte ptr DGROUP:_colors[bx+16],dl
   ;	
   ;	   _ES=FP_SEG(&colors[i]);
   ;	
	mov	ax,si
	mov	dx,17
	imul	dx
	add	ax,offset DGROUP:_colors
	mov	ax,ds
	mov	es,ax
   ;	
   ;	   _DX=FP_OFF(&colors[i]);
   ;	
	mov	ax,si
	mov	dx,17
	imul	dx
	add	ax,offset DGROUP:_colors
	mov	dx,ax
   ;	
   ;	   _AX=0x1002;
   ;	
	mov	ax,4098
   ;	
   ;	   geninterrupt(0x10);
   ;	
	int	16
   ;	
   ;	   WaitVBL(6);
   ;	
	mov	ax,6
	push	ax
	call	near ptr _WaitVBL
	pop	cx
	inc	si
@31@98:
	cmp	si,4
	jl	short @31@50
   ;	
   ;	 }
   ;	}
   ;	
	pop	si
	pop	bp
	ret	
_FadeIn	endp
   ;	
   ;	void FadeUp(void)
   ;	
	assume	cs:_TEXT
_FadeUp	proc	near
	push	bp
	mov	bp,sp
	push	si
   ;	
   ;	{
   ;	 int i;
   ;	
   ;	 for (i=3;i<7;i++)
   ;	
	mov	si,3
	jmp	short @32@98
@32@50:
   ;	
   ;	 {
   ;	   colors[i][16] = bordercolor;
   ;	
	mov	ax,si
	mov	dx,17
	imul	dx
	mov	dl,byte ptr DGROUP:_bordercolor
	mov	bx,ax
	mov	byte ptr DGROUP:_colors[bx+16],dl
   ;	
   ;	   _ES=FP_SEG(&colors[i]);
   ;	
	mov	ax,si
	mov	dx,17
	imul	dx
	add	ax,offset DGROUP:_colors
	mov	ax,ds
	mov	es,ax
   ;	
   ;	   _DX=FP_OFF(&colors[i]);
   ;	
	mov	ax,si
	mov	dx,17
	imul	dx
	add	ax,offset DGROUP:_colors
	mov	dx,ax
   ;	
   ;	   _AX=0x1002;
   ;	
	mov	ax,4098
   ;	
   ;	   geninterrupt(0x10);
   ;	
	int	16
   ;	
   ;	   WaitVBL(6);
   ;	
	mov	ax,6
	push	ax
	call	near ptr _WaitVBL
	pop	cx
	inc	si
@32@98:
	cmp	si,7
	jl	short @32@50
   ;	
   ;	 }
   ;	}
   ;	
	pop	si
	pop	bp
	ret	
_FadeUp	endp
   ;	
   ;	void FadeDown(void)
   ;	
	assume	cs:_TEXT
_FadeDown	proc	near
	push	bp
	mov	bp,sp
	push	si
   ;	
   ;	{
   ;	 int i;
   ;	
   ;	 for (i=6;i>2;i--)
   ;	
	mov	si,6
	jmp	short @33@98
@33@50:
   ;	
   ;	 {
   ;	   colors[i][16] = bordercolor;
   ;	
	mov	ax,si
	mov	dx,17
	imul	dx
	mov	dl,byte ptr DGROUP:_bordercolor
	mov	bx,ax
	mov	byte ptr DGROUP:_colors[bx+16],dl
   ;	
   ;	   _ES=FP_SEG(&colors[i]);
   ;	
	mov	ax,si
	mov	dx,17
	imul	dx
	add	ax,offset DGROUP:_colors
	mov	ax,ds
	mov	es,ax
   ;	
   ;	   _DX=FP_OFF(&colors[i]);
   ;	
	mov	ax,si
	mov	dx,17
	imul	dx
	add	ax,offset DGROUP:_colors
	mov	dx,ax
   ;	
   ;	   _AX=0x1002;
   ;	
	mov	ax,4098
   ;	
   ;	   geninterrupt(0x10);
   ;	
	int	16
   ;	
   ;	   WaitVBL(6);
   ;	
	mov	ax,6
	push	ax
	call	near ptr _WaitVBL
	pop	cx
	dec	si
@33@98:
	cmp	si,2
	jg	short @33@50
   ;	
   ;	 }
   ;	}
   ;	
	pop	si
	pop	bp
	ret	
_FadeDown	endp
   ;	
   ;	void SetNormalPalette(void)
   ;	
	assume	cs:_TEXT
_SetNormalPalette	proc	near
	push	bp
	mov	bp,sp
   ;	
   ;	{
   ;	 int i;
   ;	
   ;	 colors[3][16] = bordercolor;
   ;	
	mov	al,byte ptr DGROUP:_bordercolor
	mov	byte ptr DGROUP:_colors+67,al
   ;	
   ;	 _ES=FP_SEG(&colors[3]);
   ;	
	mov	ax,ds
	mov	es,ax
   ;	
   ;	 _DX=FP_OFF(&colors[3]);
   ;	
	mov	dx,offset DGROUP:_colors+51
   ;	
   ;	 _AX=0x1002;
   ;	
	mov	ax,4098
   ;	
   ;	 geninterrupt(0x10);
   ;	
	int	16
   ;	
   ;	}
   ;	
	pop	bp
	ret	
_SetNormalPalette	endp
   ;	
   ;	void FadeOut(void)
   ;	
	assume	cs:_TEXT
_FadeOut	proc	near
	push	bp
	mov	bp,sp
	push	si
   ;	
   ;	{
   ;	
   ;	 int i;
   ;	
   ;	 for (i=3;i>=0;i--)
   ;	
	mov	si,3
	jmp	short @35@98
@35@50:
   ;	
   ;	 {
   ;	   colors[i][16] = bordercolor;
   ;	
	mov	ax,si
	mov	dx,17
	imul	dx
	mov	dl,byte ptr DGROUP:_bordercolor
	mov	bx,ax
	mov	byte ptr DGROUP:_colors[bx+16],dl
   ;	
   ;	   _ES=FP_SEG(&colors[i]);
   ;	
	mov	ax,si
	mov	dx,17
	imul	dx
	add	ax,offset DGROUP:_colors
	mov	ax,ds
	mov	es,ax
   ;	
   ;	   _DX=FP_OFF(&colors[i]);
   ;	
	mov	ax,si
	mov	dx,17
	imul	dx
	add	ax,offset DGROUP:_colors
	mov	dx,ax
   ;	
   ;	   _AX=0x1002;
   ;	
	mov	ax,4098
   ;	
   ;	   geninterrupt(0x10);
   ;	
	int	16
   ;	
   ;	   WaitVBL(6);
   ;	
	mov	ax,6
	push	ax
	call	near ptr _WaitVBL
	pop	cx
	dec	si
@35@98:
	or	si,si
	jge	short @35@50
   ;	
   ;	 }
   ;	}
   ;	
	pop	si
	pop	bp
	ret	
_FadeOut	endp
   ;	
   ;	void SetLineWidth (int width)
   ;	
	assume	cs:_TEXT
_SetLineWidth	proc	near
	push	bp
	mov	bp,sp
	push	si
	mov	si,word ptr [bp+4]
   ;	
   ;	{
   ;	  EGAVirtualScreen(width);
   ;	
	push	si
	call	near ptr _EGAVirtualScreen
	pop	cx
   ;	
   ;	  linewidth = width;
   ;	
	mov	word ptr DGROUP:_linewidth,si
   ;	
   ;	  GenYlookup();
   ;	
	call	near ptr _GenYlookup
   ;	
   ;	}
   ;	
	pop	si
	pop	bp
	ret	
_SetLineWidth	endp
_TEXT	ends
_DATA	segment word public 'DATA'
_screencenterx	label	word
	db	20
	db	0
_screencentery	label	word
	db	11
	db	0
_DATA	ends
_TEXT	segment byte public 'CODE'
   ;	
   ;	void DrawWindow (int xl, int yl, int xh, int yh)
   ;	
	assume	cs:_TEXT
_DrawWindow	proc	near
	push	bp
	mov	bp,sp
	dec	sp
	dec	sp
	push	si
	push	di
	mov	di,word ptr [bp+4]
   ;	
   ;	{
   ;	 int x,y;
   ;	 win_xl=xl;
   ;	
	mov	word ptr DGROUP:_win_xl,di
   ;	
   ;	 pxl = xl*8+8;
   ;	
	mov	ax,di
	shl	ax,1
	shl	ax,1
	shl	ax,1
	add	ax,8
	mov	word ptr DGROUP:_pxl,ax
   ;	
   ;	 win_yl=yl;
   ;	
	mov	ax,word ptr [bp+6]
	mov	word ptr DGROUP:_win_yl,ax
   ;	
   ;	 win_xh=xh;
   ;	
	mov	ax,word ptr [bp+8]
	mov	word ptr DGROUP:_win_xh,ax
   ;	
   ;	 pxh = xh*8;
   ;	
	mov	ax,word ptr [bp+8]
	shl	ax,1
	shl	ax,1
	shl	ax,1
	mov	word ptr DGROUP:_pxh,ax
   ;	
   ;	 win_yh=yh;		// so the window can be erased
   ;	
	mov	ax,word ptr [bp+10]
	mov	word ptr DGROUP:_win_yh,ax
   ;	
   ;	
   ;	 DRAWCHAR (xl,yl,1);
   ;	
	mov	ax,1
	push	ax
	mov	ax,word ptr [bp+6]
	shl	ax,1
	shl	ax,1
	shl	ax,1
	push	ax
	push	di
	call	near ptr _DrawChar
	add	sp,6
   ;	
   ;	 for (x=xl+1;x<xh;x++)
   ;	
	mov	ax,di
	inc	ax
	mov	si,ax
	jmp	short @37@98
@37@50:
   ;	
   ;	   DRAWCHAR (x,yl,2);
   ;	
	mov	ax,2
	push	ax
	mov	ax,word ptr [bp+6]
	shl	ax,1
	shl	ax,1
	shl	ax,1
	push	ax
	push	si
	call	near ptr _DrawChar
	add	sp,6
	inc	si
@37@98:
	cmp	si,word ptr [bp+8]
	jl	short @37@50
   ;	
   ;	 DRAWCHAR (xh,yl,3);
   ;	
	mov	ax,3
	push	ax
	mov	ax,word ptr [bp+6]
	shl	ax,1
	shl	ax,1
	shl	ax,1
	push	ax
	push	word ptr [bp+8]
	call	near ptr _DrawChar
	add	sp,6
   ;	
   ;	 for (y=yl+1;y<yh;y++)
   ;	
	mov	ax,word ptr [bp+6]
	inc	ax
	mov	word ptr [bp-2],ax
	jmp	short @37@290
@37@146:
   ;	
   ;	 {
   ;	   DRAWCHAR (xl,y,4);
   ;	
	mov	ax,4
	push	ax
	mov	ax,word ptr [bp-2]
	shl	ax,1
	shl	ax,1
	shl	ax,1
	push	ax
	push	di
	call	near ptr _DrawChar
	add	sp,6
   ;	
   ;	   for (x=xl+1;x<xh;x++)
   ;	
	mov	ax,di
	inc	ax
	mov	si,ax
	jmp	short @37@218
@37@170:
   ;	
   ;	     DRAWCHAR (x,y,9);
   ;	
	mov	ax,9
	push	ax
	mov	ax,word ptr [bp-2]
	shl	ax,1
	shl	ax,1
	shl	ax,1
	push	ax
	push	si
	call	near ptr _DrawChar
	add	sp,6
	inc	si
@37@218:
	cmp	si,word ptr [bp+8]
	jl	short @37@170
   ;	
   ;	   DRAWCHAR (xh,y,5);
   ;	
	mov	ax,5
	push	ax
	mov	ax,word ptr [bp-2]
	shl	ax,1
	shl	ax,1
	shl	ax,1
	push	ax
	push	word ptr [bp+8]
	call	near ptr _DrawChar
	add	sp,6
	inc	word ptr [bp-2]
@37@290:
	mov	ax,word ptr [bp-2]
	cmp	ax,word ptr [bp+10]
	jl	short @37@146
   ;	
   ;	 }
   ;	 DRAWCHAR (xl,yh,6);
   ;	
	mov	ax,6
	push	ax
	mov	ax,word ptr [bp+10]
	shl	ax,1
	shl	ax,1
	shl	ax,1
	push	ax
	push	di
	call	near ptr _DrawChar
	add	sp,6
   ;	
   ;	 for (x=xl+1;x<xh;x++)
   ;	
	mov	ax,di
	inc	ax
	mov	si,ax
	jmp	short @37@386
@37@338:
   ;	
   ;	   DRAWCHAR (x,yh,7);
   ;	
	mov	ax,7
	push	ax
	mov	ax,word ptr [bp+10]
	shl	ax,1
	shl	ax,1
	shl	ax,1
	push	ax
	push	si
	call	near ptr _DrawChar
	add	sp,6
	inc	si
@37@386:
	cmp	si,word ptr [bp+8]
	jl	short @37@338
   ;	
   ;	 DRAWCHAR (xh,yh,8);
   ;	
	mov	ax,8
	push	ax
	mov	ax,word ptr [bp+10]
	shl	ax,1
	shl	ax,1
	shl	ax,1
	push	ax
	push	word ptr [bp+8]
	call	near ptr _DrawChar
	add	sp,6
   ;	
   ;	
   ;	 sx = leftedge = xl+1;
   ;	
	mov	ax,di
	inc	ax
	mov	word ptr DGROUP:_leftedge,ax
	mov	word ptr DGROUP:_sx,ax
   ;	
   ;	 sy = yl+1;
   ;	
	mov	ax,word ptr [bp+6]
	inc	ax
	mov	word ptr DGROUP:_sy,ax
   ;	
   ;	 px=sx*8;
   ;	
	mov	ax,word ptr DGROUP:_sx
	shl	ax,1
	shl	ax,1
	shl	ax,1
	mov	word ptr DGROUP:_px,ax
   ;	
   ;	 py=pyl=sy*8;
   ;	
	mov	ax,word ptr DGROUP:_sy
	shl	ax,1
	shl	ax,1
	shl	ax,1
	mov	word ptr DGROUP:_pyl,ax
	mov	word ptr DGROUP:_py,ax
   ;	
   ;	}
   ;	
	pop	di
	pop	si
	mov	sp,bp
	pop	bp
	ret	
_DrawWindow	endp
   ;	
   ;	void CenterWindow (int width, int height)
   ;	
	assume	cs:_TEXT
_CenterWindow	proc	near
	push	bp
	mov	bp,sp
	sub	sp,4
	push	si
	push	di
	mov	si,word ptr [bp+4]
	mov	di,word ptr [bp+6]
   ;	
   ;	{
   ;	  int xl = screencenterx-width/2;
   ;	
	mov	ax,si
	mov	bx,2
	cwd	
	idiv	bx
	mov	dx,word ptr DGROUP:_screencenterx
	sub	dx,ax
	mov	word ptr [bp-2],dx
   ;	
   ;	  int yl = screencentery-height/2;
   ;	
	mov	ax,di
	mov	bx,2
	cwd	
	idiv	bx
	mov	dx,word ptr DGROUP:_screencentery
	sub	dx,ax
	mov	word ptr [bp-4],dx
   ;	
   ;	
   ;	  DrawWindow (xl,yl,xl+width+1,yl+height+1);
   ;	
	mov	ax,word ptr [bp-4]
	add	ax,di
	inc	ax
	push	ax
	mov	ax,word ptr [bp-2]
	add	ax,si
	inc	ax
	push	ax
	push	word ptr [bp-4]
	push	word ptr [bp-2]
	call	near ptr _DrawWindow
	add	sp,8
   ;	
   ;	}
   ;	
	pop	di
	pop	si
	mov	sp,bp
	pop	bp
	ret	
_CenterWindow	endp
   ;	
   ;	void CharBar (int xl, int yl, int xh, int yh, int ch)
   ;	
	assume	cs:_TEXT
_CharBar	proc	near
	push	bp
	mov	bp,sp
	push	si
	push	di
   ;	
   ;	{
   ;	  int x,y;
   ;	
   ;	  for (y=yl;y<=yh;y++)
   ;	
	mov	di,word ptr [bp+6]
	jmp	short @39@170
@39@50:
   ;	
   ;	    for (x=xl;x<=xh;x++)
   ;	
	mov	si,word ptr [bp+4]
	jmp	short @39@122
@39@74:
   ;	
   ;	      DRAWCHAR (x,y,ch);
   ;	
	push	word ptr [bp+12]
	mov	ax,di
	shl	ax,1
	shl	ax,1
	shl	ax,1
	push	ax
	push	si
	call	near ptr _DrawChar
	add	sp,6
	inc	si
@39@122:
	cmp	si,word ptr [bp+8]
	jle	short @39@74
	inc	di
@39@170:
	cmp	di,word ptr [bp+10]
	jle	short @39@50
   ;	
   ;	}
   ;	
	pop	di
	pop	si
	pop	bp
	ret	
_CharBar	endp
   ;	
   ;	void ExpWin (int width, int height)
   ;	
	assume	cs:_TEXT
_ExpWin	proc	near
	push	bp
	mov	bp,sp
	push	si
	push	di
	mov	di,word ptr [bp+4]
	mov	si,word ptr [bp+6]
   ;	
   ;	{
   ;	  if (width > 2)
   ;	
	cmp	di,2
	jle	short @40@146
   ;	
   ;	  {
   ;	    if (height >2)
   ;	
	cmp	si,2
	jle	short @40@98
   ;	
   ;	      ExpWin (width-2,height-2);
   ;	
	mov	ax,si
	add	ax,65534
	push	ax
	mov	ax,di
	add	ax,65534
	push	ax
	call	near ptr _ExpWin
	pop	cx
	pop	cx
	jmp	short @40@122
@40@98:
   ;	
   ;	    else
   ;	      ExpWinH (width-2,height);
   ;	
	push	si
	mov	ax,di
	add	ax,65534
	push	ax
	call	near ptr _ExpWinH
	pop	cx
	pop	cx
@40@122:
   ;	
   ;	  }
   ;	
	jmp	short @40@194
@40@146:
   ;	
   ;	  else
   ;	    if (height >2)
   ;	
	cmp	si,2
	jle	short @40@194
   ;	
   ;	      ExpWinV (width,height-2);
   ;	
	mov	ax,si
	add	ax,65534
	push	ax
	push	di
	call	near ptr _ExpWinV
	pop	cx
	pop	cx
@40@194:
   ;	
   ;	
   ;	  WaitVBL (1);
   ;	
	mov	ax,1
	push	ax
	call	near ptr _WaitVBL
	pop	cx
   ;	
   ;	  CenterWindow (width,height);
   ;	
	push	si
	push	di
	call	near ptr _CenterWindow
	pop	cx
	pop	cx
   ;	
   ;	}
   ;	
	pop	di
	pop	si
	pop	bp
	ret	
_ExpWin	endp
   ;	
   ;	void ExpWinH (int width, int height)
   ;	
	assume	cs:_TEXT
_ExpWinH	proc	near
	push	bp
	mov	bp,sp
	push	si
	push	di
	mov	si,word ptr [bp+4]
	mov	di,word ptr [bp+6]
   ;	
   ;	{
   ;	  if (width > 2)
   ;	
	cmp	si,2
	jle	short @41@74
   ;	
   ;	    ExpWinH (width-2,height);
   ;	
	push	di
	mov	ax,si
	add	ax,65534
	push	ax
	call	near ptr _ExpWinH
	pop	cx
	pop	cx
@41@74:
   ;	
   ;	
   ;	  WaitVBL (1);
   ;	
	mov	ax,1
	push	ax
	call	near ptr _WaitVBL
	pop	cx
   ;	
   ;	  CenterWindow (width,height);
   ;	
	push	di
	push	si
	call	near ptr _CenterWindow
	pop	cx
	pop	cx
   ;	
   ;	}
   ;	
	pop	di
	pop	si
	pop	bp
	ret	
_ExpWinH	endp
   ;	
   ;	void ExpWinV (int width, int height)
   ;	
	assume	cs:_TEXT
_ExpWinV	proc	near
	push	bp
	mov	bp,sp
	push	si
	push	di
	mov	di,word ptr [bp+4]
	mov	si,word ptr [bp+6]
   ;	
   ;	{
   ;	  if (height >2)
   ;	
	cmp	si,2
	jle	short @42@74
   ;	
   ;	    ExpWinV (width,height-2);
   ;	
	mov	ax,si
	add	ax,65534
	push	ax
	push	di
	call	near ptr _ExpWinV
	pop	cx
	pop	cx
@42@74:
   ;	
   ;	
   ;	  WaitVBL (1);
   ;	
	mov	ax,1
	push	ax
	call	near ptr _WaitVBL
	pop	cx
   ;	
   ;	  CenterWindow (width,height);
   ;	
	push	si
	push	di
	call	near ptr _CenterWindow
	pop	cx
	pop	cx
   ;	
   ;	}
   ;	
	pop	di
	pop	si
	pop	bp
	ret	
_ExpWinV	endp
   ;	
   ;	void DrawFrame(int x1,int y1,int x2,int y2,int type)
   ;	
	assume	cs:_TEXT
_DrawFrame	proc	near
	push	bp
	mov	bp,sp
	push	si
	push	di
	mov	di,word ptr [bp+12]
   ;	
   ;	{
   ;	 int loop;
   ;	
   ;	 type=type*22+1;
   ;	
	mov	ax,di
	mov	dx,22
	imul	dx
	inc	ax
	mov	di,ax
   ;	
   ;	
   ;	 for (loop=x1+1;loop<x2;loop++)
   ;	
	mov	ax,word ptr [bp+4]
	inc	ax
	mov	si,ax
	jmp	short @43@98
@43@50:
   ;	
   ;	   {
   ;	    DRAWCHAR(loop,y1,type+1);
   ;	
	mov	ax,di
	inc	ax
	push	ax
	mov	ax,word ptr [bp+6]
	shl	ax,1
	shl	ax,1
	shl	ax,1
	push	ax
	push	si
	call	near ptr _DrawChar
	add	sp,6
   ;	
   ;	    DRAWCHAR(loop,y2,type+6);
   ;	
	mov	ax,di
	add	ax,6
	push	ax
	mov	ax,word ptr [bp+10]
	shl	ax,1
	shl	ax,1
	shl	ax,1
	push	ax
	push	si
	call	near ptr _DrawChar
	add	sp,6
	inc	si
@43@98:
	cmp	si,word ptr [bp+8]
	jl	short @43@50
   ;	
   ;	   }
   ;	 for (loop=y1+1;loop<y2;loop++)
   ;	
	mov	ax,word ptr [bp+6]
	inc	ax
	mov	si,ax
	jmp	short @43@194
@43@146:
   ;	
   ;	   {
   ;	    DRAWCHAR(x1,loop,type+3);
   ;	
	mov	ax,di
	add	ax,3
	push	ax
	mov	ax,si
	shl	ax,1
	shl	ax,1
	shl	ax,1
	push	ax
	push	word ptr [bp+4]
	call	near ptr _DrawChar
	add	sp,6
   ;	
   ;	    DRAWCHAR(x2,loop,type+4);
   ;	
	mov	ax,di
	add	ax,4
	push	ax
	mov	ax,si
	shl	ax,1
	shl	ax,1
	shl	ax,1
	push	ax
	push	word ptr [bp+8]
	call	near ptr _DrawChar
	add	sp,6
	inc	si
@43@194:
	cmp	si,word ptr [bp+10]
	jl	short @43@146
   ;	
   ;	   }
   ;	
   ;	 DRAWCHAR(x1,y1,type);
   ;	
	push	di
	mov	ax,word ptr [bp+6]
	shl	ax,1
	shl	ax,1
	shl	ax,1
	push	ax
	push	word ptr [bp+4]
	call	near ptr _DrawChar
	add	sp,6
   ;	
   ;	 DRAWCHAR(x2,y1,type+2);
   ;	
	mov	ax,di
	inc	ax
	inc	ax
	push	ax
	mov	ax,word ptr [bp+6]
	shl	ax,1
	shl	ax,1
	shl	ax,1
	push	ax
	push	word ptr [bp+8]
	call	near ptr _DrawChar
	add	sp,6
   ;	
   ;	 DRAWCHAR(x2,y2,type+7);
   ;	
	mov	ax,di
	add	ax,7
	push	ax
	mov	ax,word ptr [bp+10]
	shl	ax,1
	shl	ax,1
	shl	ax,1
	push	ax
	push	word ptr [bp+8]
	call	near ptr _DrawChar
	add	sp,6
   ;	
   ;	 DRAWCHAR(x1,y2,type+5);
   ;	
	mov	ax,di
	add	ax,5
	push	ax
	mov	ax,word ptr [bp+10]
	shl	ax,1
	shl	ax,1
	shl	ax,1
	push	ax
	push	word ptr [bp+4]
	call	near ptr _DrawChar
	add	sp,6
   ;	
   ;	}
   ;	
	pop	di
	pop	si
	pop	bp
	ret	
_DrawFrame	endp
   ;	
   ;	int Get (void)
   ;	
	assume	cs:_TEXT
_Get	proc	near
	push	bp
	mov	bp,sp
	dec	sp
	dec	sp
	push	si
   ;	
   ;	{
   ;	 int cycle,key;
   ;	
   ;	 ClearKeys();
   ;	
	call	near ptr _ClearKeys
@44@50:
   ;	
   ;	 do
   ;	 {
   ;	   cycle = 9;
   ;	
	mov	si,9
	jmp	short @44@98
@44@74:
   ;	
   ;	   while (!(key = NoBiosKey(1)) && cycle<13)
   ;	   {
   ;	     DRAWCHAR (sx,sy,cycle++);
   ;	
	mov	ax,si
	inc	si
	push	ax
	mov	ax,word ptr DGROUP:_sy
	shl	ax,1
	shl	ax,1
	shl	ax,1
	push	ax
	push	word ptr DGROUP:_sx
	call	near ptr _DrawChar
	add	sp,6
   ;	
   ;	     WaitVBL (5);
   ;	
	mov	ax,5
	push	ax
	call	near ptr _WaitVBL
	pop	cx
@44@98:
	mov	ax,1
	push	ax
	call	near ptr _NoBiosKey
	pop	cx
	mov	word ptr [bp-2],ax
	or	ax,ax
	jne	short @44@146
	cmp	si,13
	jl	short @44@74
@44@146:
   ;	
   ;	   }
   ;	 } while (key == 0);
   ;	
	cmp	word ptr [bp-2],0
	je	short @44@50
   ;	
   ;	 DRAWCHAR (sx,sy,' ');
   ;	
	mov	ax,32
	push	ax
	mov	ax,word ptr DGROUP:_sy
	shl	ax,1
	shl	ax,1
	shl	ax,1
	push	ax
	push	word ptr DGROUP:_sx
	call	near ptr _DrawChar
	add	sp,6
   ;	
   ;	 return NoBiosKey(0);		// take it out of the buffer
   ;	
	xor	ax,ax
	push	ax
	call	near ptr _NoBiosKey
	pop	cx
	jmp	short @44@194
@44@194:
   ;	
   ;	}
   ;	
	pop	si
	mov	sp,bp
	pop	bp
	ret	
_Get	endp
   ;	
   ;	void Print (const char *str)
   ;	
	assume	cs:_TEXT
_Print	proc	near
	push	bp
	mov	bp,sp
	dec	sp
	dec	sp
	push	si
	mov	si,word ptr [bp+4]
	jmp	short @45@170
@45@50:
   ;	
   ;	{
   ;	  unsigned char ch;
   ;	
   ;	  while ((ch=*str++) != 0)
   ;	    if (ch == '\n')
   ;	
	cmp	byte ptr [bp-1],10
	jne	short @45@98
   ;	
   ;	    {
   ;	      sy++;
   ;	
	inc	word ptr DGROUP:_sy
   ;	
   ;	      sx=leftedge;
   ;	
	mov	ax,word ptr DGROUP:_leftedge
	mov	word ptr DGROUP:_sx,ax
   ;	
   ;	    }
   ;	
	jmp	short @45@170
@45@98:
   ;	
   ;	    else if (ch == '\r')
   ;	
	cmp	byte ptr [bp-1],13
	jne	short @45@146
   ;	
   ;	      sx=leftedge;
   ;	
	mov	ax,word ptr DGROUP:_leftedge
	mov	word ptr DGROUP:_sx,ax
	jmp	short @45@170
@45@146:
   ;	
   ;	    else
   ;	      DRAWCHAR (sx++,sy,ch);
   ;	
	mov	al,byte ptr [bp-1]
	mov	ah,0
	push	ax
	mov	ax,word ptr DGROUP:_sy
	shl	ax,1
	shl	ax,1
	shl	ax,1
	push	ax
	mov	ax,word ptr DGROUP:_sx
	inc	word ptr DGROUP:_sx
	push	ax
	call	near ptr _DrawChar
	add	sp,6
@45@170:
	mov	bx,si
	inc	si
	mov	al,byte ptr [bx]
	mov	byte ptr [bp-1],al
	or	al,al
	jne	short @45@50
   ;	
   ;	}
   ;	
	pop	si
	mov	sp,bp
	pop	bp
	ret	
_Print	endp
   ;	
   ;	void Printxy(int x,int y,char *string)
   ;	
	assume	cs:_TEXT
_Printxy	proc	near
	push	bp
	mov	bp,sp
	sub	sp,4
   ;	
   ;	{
   ;	 int osx,osy;
   ;	
   ;	 osx=sx;
   ;	
	mov	ax,word ptr DGROUP:_sx
	mov	word ptr [bp-2],ax
   ;	
   ;	 osy=sy;
   ;	
	mov	ax,word ptr DGROUP:_sy
	mov	word ptr [bp-4],ax
   ;	
   ;	 sx=x;
   ;	
	mov	ax,word ptr [bp+4]
	mov	word ptr DGROUP:_sx,ax
   ;	
   ;	 sy=y;
   ;	
	mov	ax,word ptr [bp+6]
	mov	word ptr DGROUP:_sy,ax
   ;	
   ;	 Print(string);
   ;	
	push	word ptr [bp+8]
	call	near ptr _Print
	pop	cx
   ;	
   ;	 sx=osx;
   ;	
	mov	ax,word ptr [bp-2]
	mov	word ptr DGROUP:_sx,ax
   ;	
   ;	 sy=osy;
   ;	
	mov	ax,word ptr [bp-4]
	mov	word ptr DGROUP:_sy,ax
   ;	
   ;	}
   ;	
	mov	sp,bp
	pop	bp
	ret	
_Printxy	endp
   ;	
   ;	void PrintInt (int val)
   ;	
	assume	cs:_TEXT
_PrintInt	proc	near
	push	bp
	mov	bp,sp
   ;	
   ;	{
   ;	  itoa(val,str,10);
   ;	
	mov	ax,10
	push	ax
	mov	ax,offset DGROUP:_str
	push	ax
	push	word ptr [bp+4]
	call	near ptr _itoa
	add	sp,6
   ;	
   ;	  Print (str);
   ;	
	mov	ax,offset DGROUP:_str
	push	ax
	call	near ptr _Print
	pop	cx
   ;	
   ;	}
   ;	
	pop	bp
	ret	
_PrintInt	endp
   ;	
   ;	void PrintLong (long val)
   ;	
	assume	cs:_TEXT
_PrintLong	proc	near
	push	bp
	mov	bp,sp
   ;	
   ;	{
   ;	  ltoa(val,str,10);
   ;	
	mov	ax,10
	push	ax
	mov	ax,offset DGROUP:_str
	push	ax
	push	word ptr [bp+6]
	push	word ptr [bp+4]
	call	near ptr _ltoa
	add	sp,8
   ;	
   ;	  Print (str);
   ;	
	mov	ax,offset DGROUP:_str
	push	ax
	call	near ptr _Print
	pop	cx
   ;	
   ;	}
   ;	
	pop	bp
	ret	
_PrintLong	endp
_TEXT	ends
_DATA	segment word public 'DATA'
	db	48
	db	49
	db	50
	db	51
	db	52
	db	53
	db	54
	db	55
	db	56
	db	57
	db	65
	db	66
	db	67
	db	68
	db	69
	db	70
	db	2 dup (0)
_DATA	ends
_TEXT	segment byte public 'CODE'
   ;	
   ;	void PrintHexB(unsigned char value)
   ;	
	assume	cs:_TEXT
_PrintHexB	proc	near
	push	bp
	mov	bp,sp
	sub	sp,20
	push	ss
	lea	ax,word ptr [bp-20]
	push	ax
	push	ds
	mov	ax,offset DGROUP:d@+251
	push	ax
	mov	cx,16
	call	near ptr N_SCOPY@
	push	ss
	lea	ax,word ptr [bp-4]
	push	ax
	push	ds
	mov	ax,offset DGROUP:d@+267
	push	ax
	mov	cx,2
	call	near ptr N_SCOPY@
   ;	
   ;	{
   ;	 int loop;
   ;	 char hexstr[16]="0123456789ABCDEF",str[2]="";
   ;	
   ;	 for (loop=0;loop<2;loop++)
   ;	
	mov	word ptr [bp-2],0
	jmp	short @49@98
@49@50:
   ;	
   ;	   {
   ;	    str[0]=hexstr[(value>>(1-loop)*4)&15];
   ;	
	mov	al,byte ptr [bp+4]
	mov	ah,0
	mov	dl,1
	sub	dl,byte ptr [bp-2]
	shl	dl,1
	shl	dl,1
	mov	cl,dl
	sar	ax,cl
	and	ax,15
	lea	dx,word ptr [bp-20]
	add	ax,dx
	mov	bx,ax
	mov	al,byte ptr [bx]
	mov	byte ptr [bp-4],al
   ;	
   ;	    Print(str);
   ;	
	lea	ax,word ptr [bp-4]
	push	ax
	call	near ptr _Print
	pop	cx
	inc	word ptr [bp-2]
@49@98:
	cmp	word ptr [bp-2],2
	jl	short @49@50
   ;	
   ;	   }
   ;	}
   ;	
	mov	sp,bp
	pop	bp
	ret	
_PrintHexB	endp
   ;	
   ;	void PrintHex(unsigned value)
   ;	
	assume	cs:_TEXT
_PrintHex	proc	near
	push	bp
	mov	bp,sp
   ;	
   ;	{
   ;	 Print("$");
   ;	
	mov	ax,offset DGROUP:s@+537
	push	ax
	call	near ptr _Print
	pop	cx
   ;	
   ;	 PrintHexB(value>>8);
   ;	
	mov	ax,word ptr [bp+4]
	mov	cl,8
	shr	ax,cl
	push	ax
	call	near ptr _PrintHexB
	pop	cx
   ;	
   ;	 PrintHexB(value&0xff);
   ;	
	mov	al,byte ptr [bp+4]
	and	al,255
	push	ax
	call	near ptr _PrintHexB
	pop	cx
   ;	
   ;	}
   ;	
	pop	bp
	ret	
_PrintHex	endp
   ;	
   ;	void PrintBin(unsigned value)
   ;	
	assume	cs:_TEXT
_PrintBin	proc	near
	push	bp
	mov	bp,sp
	dec	sp
	dec	sp
   ;	
   ;	{
   ;	 int loop;
   ;	
   ;	 Print("%");
   ;	
	mov	ax,offset DGROUP:s@+539
	push	ax
	call	near ptr _Print
	pop	cx
   ;	
   ;	 for (loop=0;loop<16;loop++)
   ;	
	mov	word ptr [bp-2],0
	jmp	short @51@146
@51@50:
   ;	
   ;	    if ((value>>15-loop)&1) Print("1"); else Print("0");
   ;	
	mov	cl,15
	sub	cl,byte ptr [bp-2]
	mov	ax,word ptr [bp+4]
	shr	ax,cl
	test	ax,1
	je	short @51@98
	mov	ax,offset DGROUP:s@+541
	push	ax
	call	near ptr _Print
	pop	cx
	jmp	short @51@122
@51@98:
	mov	ax,offset DGROUP:s@+543
	push	ax
	call	near ptr _Print
	pop	cx
@51@122:
	inc	word ptr [bp-2]
@51@146:
	cmp	word ptr [bp-2],16
	jl	short @51@50
   ;	
   ;	}
   ;	
	mov	sp,bp
	pop	bp
	ret	
_PrintBin	endp
   ;	
   ;	void PrintC(char *string)
   ;	
	assume	cs:_TEXT
_PrintC	proc	near
	push	bp
	mov	bp,sp
	push	si
	mov	si,word ptr [bp+4]
   ;	
   ;	{
   ;	 sx=1+screencenterx-(strlen(string)/2);
   ;	
	push	si
	call	near ptr _strlen
	pop	cx
	mov	bx,2
	cwd	
	idiv	bx
	mov	dx,word ptr DGROUP:_screencenterx
	inc	dx
	sub	dx,ax
	mov	word ptr DGROUP:_sx,dx
   ;	
   ;	 Print(string);
   ;	
	push	si
	call	near ptr _Print
	pop	cx
   ;	
   ;	}
   ;	
	pop	si
	pop	bp
	ret	
_PrintC	endp
_TEXT	ends
_DATA	segment word public 'DATA'
	db	18 dup (0)
	db	48
	db	49
	db	50
	db	51
	db	52
	db	53
	db	54
	db	55
	db	56
	db	57
	db	65
	db	66
	db	67
	db	68
	db	69
	db	70
_DATA	ends
_TEXT	segment byte public 'CODE'
   ;	
   ;	unsigned InputInt(void)
   ;	
	assume	cs:_TEXT
_InputInt	proc	near
	push	bp
	mov	bp,sp
	sub	sp,40
	push	si
	push	di
	push	ss
	lea	ax,word ptr [bp-24]
	push	ax
	push	ds
	mov	ax,offset DGROUP:d@+269
	push	ax
	mov	cx,18
	call	near ptr N_SCOPY@
	push	ss
	lea	ax,word ptr [bp-40]
	push	ax
	push	ds
	mov	ax,offset DGROUP:d@+287
	push	ax
	mov	cx,16
	call	near ptr N_SCOPY@
   ;	
   ;	{
   ;	 char string[18]="",digit,hexstr[16]="0123456789ABCDEF";
   ;	 unsigned value,loop,loop1;
   ;	
   ;	 Input(string,17);
   ;	
	mov	ax,17
	push	ax
	lea	ax,word ptr [bp-24]
	push	ax
	call	near ptr _Input
	pop	cx
	pop	cx
   ;	
   ;	 if (string[0]=='$')
   ;	
	cmp	byte ptr [bp-24],36
	jne	short @53@314
   ;	
   ;	   {
   ;	    int digits;
   ;	
   ;	    digits=strlen(string)-2;
   ;	
	lea	ax,word ptr [bp-24]
	push	ax
	call	near ptr _strlen
	pop	cx
	add	ax,65534
	mov	word ptr [bp-6],ax
   ;	
   ;	    if (digits<0) return 0;
   ;	
	cmp	word ptr [bp-6],0
	jge	short @53@98
	xor	ax,ax
	jmp	@53@626
@53@98:
   ;	
   ;	
   ;	    for (value=0,loop1=0;loop1<=digits;loop1++)
   ;	
	xor	si,si
	mov	word ptr [bp-4],0
	jmp	short @53@266
@53@122:
   ;	
   ;	      {
   ;	       digit=toupper(string[loop1+1]);
   ;	
	mov	bx,word ptr [bp-4]
	inc	bx
	lea	ax,word ptr [bp-24]
	add	bx,ax
	mov	al,byte ptr [bx]
	cbw	
	push	ax
	call	near ptr _toupper
	pop	cx
	mov	byte ptr [bp-1],al
   ;	
   ;	       for (loop=0;loop<16;loop++)
   ;	
	xor	di,di
	jmp	short @53@218
@53@146:
   ;	
   ;		  if (digit==hexstr[loop])
   ;	
	mov	al,byte ptr [bp+di-40]
	cmp	al,byte ptr [bp-1]
	jne	short @53@194
   ;	
   ;		    {
   ;		     value|=(loop<<(digits-loop1)*4);
   ;	
	mov	al,byte ptr [bp-6]
	sub	al,byte ptr [bp-4]
	shl	al,1
	shl	al,1
	mov	dx,di
	mov	cl,al
	shl	dx,cl
	or	si,dx
   ;	
   ;		     break;
   ;	
	jmp	short @53@242
@53@194:
	inc	di
@53@218:
	cmp	di,16
	jb	short @53@146
@53@242:
	inc	word ptr [bp-4]
@53@266:
	mov	ax,word ptr [bp-4]
	cmp	ax,word ptr [bp-6]
	jbe	short @53@122
   ;	
   ;		    }
   ;	      }
   ;	   }
   ;	
	jmp	short @53@602
@53@314:
   ;	
   ;	 else if (string[0]=='%')
   ;	
	cmp	byte ptr [bp-24],37
	jne	short @53@578
   ;	
   ;	   {
   ;	    int digits;
   ;	
   ;	    digits=strlen(string)-2;
   ;	
	lea	ax,word ptr [bp-24]
	push	ax
	call	near ptr _strlen
	pop	cx
	add	ax,65534
	mov	word ptr [bp-6],ax
   ;	
   ;	    if (digits<0) return 0;
   ;	
	cmp	word ptr [bp-6],0
	jge	short @53@386
	xor	ax,ax
	jmp	short @53@626
@53@386:
   ;	
   ;	
   ;	    for (value=0,loop1=0;loop1<=digits;loop1++)
   ;	
	xor	si,si
	mov	word ptr [bp-4],0
	jmp	short @53@530
@53@410:
   ;	
   ;	      {
   ;	       if (string[loop1+1]<'0' || string[loop1+1]>'1') return 0;
   ;	
	mov	bx,word ptr [bp-4]
	inc	bx
	lea	ax,word ptr [bp-24]
	add	bx,ax
	cmp	byte ptr [bx],48
	jl	short @53@458
	mov	bx,word ptr [bp-4]
	inc	bx
	lea	ax,word ptr [bp-24]
	add	bx,ax
	cmp	byte ptr [bx],49
	jle	short @53@482
@53@458:
	xor	ax,ax
	jmp	short @53@626
@53@482:
   ;	
   ;	       value|=(string[loop1+1]-'0')<<(digits-loop1);
   ;	
	mov	bx,word ptr [bp-4]
	inc	bx
	lea	ax,word ptr [bp-24]
	add	bx,ax
	mov	al,byte ptr [bx]
	cbw	
	add	ax,65488
	mov	cl,byte ptr [bp-6]
	sub	cl,byte ptr [bp-4]
	shl	ax,cl
	or	si,ax
	inc	word ptr [bp-4]
@53@530:
	mov	ax,word ptr [bp-4]
	cmp	ax,word ptr [bp-6]
	jbe	short @53@410
   ;	
   ;	      }
   ;	   }
   ;	
	jmp	short @53@602
@53@578:
   ;	
   ;	 else value=atoi(string);
   ;	
	lea	ax,word ptr [bp-24]
	push	ax
	call	near ptr _atol
	pop	cx
	mov	si,ax
@53@602:
   ;	
   ;	 return value;
   ;	
	mov	ax,si
	jmp	short @53@626
@53@626:
   ;	
   ;	}
   ;	
	pop	di
	pop	si
	mov	sp,bp
	pop	bp
	ret	
_InputInt	endp
   ;	
   ;	int Input(char *string,int max)
   ;	
	assume	cs:_TEXT
_Input	proc	near
	push	bp
	mov	bp,sp
	sub	sp,182
	push	si
	push	di
   ;	
   ;	{
   ;	 char key;
   ;	 int count=0,loop;
   ;	
	xor	si,si
   ;	
   ;	 int pxt[90];
   ;	
   ;	 pxt[0]=px;
   ;	
	mov	ax,word ptr DGROUP:_px
	mov	word ptr [bp-182],ax
@54@50:
   ;	
   ;	
   ;	 do {
   ;	     key=toupper(PGet()&0xff);
   ;	
	call	near ptr _PGet
	and	ax,255
	push	ax
	call	near ptr _toupper
	pop	cx
	mov	byte ptr [bp-1],al
   ;	
   ;	     if ((key==127 || key==8)&&count>0)
   ;	
	cmp	byte ptr [bp-1],127
	je	short @54@98
	cmp	byte ptr [bp-1],8
	jne	short @54@146
@54@98:
	or	si,si
	jle	short @54@146
   ;	
   ;	       {
   ;		count--;
   ;	
	dec	si
   ;	
   ;		px=pxt[count];
   ;	
	mov	bx,si
	shl	bx,1
	lea	ax,word ptr [bp-182]
	add	bx,ax
	mov	ax,word ptr [bx]
	mov	word ptr DGROUP:_px,ax
   ;	
   ;		DrawPchar(string[count]);
   ;	
	mov	bx,word ptr [bp+4]
	mov	al,byte ptr [bx+si]
	cbw	
	push	ax
	call	near ptr _DrawPchar
	pop	cx
   ;	
   ;		px=pxt[count];
   ;	
	mov	bx,si
	shl	bx,1
	lea	ax,word ptr [bp-182]
	add	bx,ax
	mov	ax,word ptr [bx]
	mov	word ptr DGROUP:_px,ax
@54@146:
   ;	
   ;	       }
   ;	
   ;	     if (key>=' ' && key<='z' && count<max)
   ;	
	cmp	byte ptr [bp-1],32
	jl	short @54@242
	cmp	byte ptr [bp-1],122
	jg	short @54@242
	cmp	si,word ptr [bp+6]
	jge	short @54@242
   ;	
   ;	       {
   ;		*(string+count++)=key;
   ;	
	mov	bx,word ptr [bp+4]
	mov	al,byte ptr [bp-1]
	mov	byte ptr [bx+si],al
	inc	si
   ;	
   ;		DrawPchar(key);
   ;	
	mov	al,byte ptr [bp-1]
	cbw	
	push	ax
	call	near ptr _DrawPchar
	pop	cx
   ;	
   ;		pxt[count]=px;
   ;	
	mov	bx,si
	shl	bx,1
	lea	ax,word ptr [bp-182]
	add	bx,ax
	mov	ax,word ptr DGROUP:_px
	mov	word ptr [bx],ax
@54@242:
   ;	
   ;	       }
   ;	
   ;	    } while (key!=27 && key!=13);
   ;	
	cmp	byte ptr [bp-1],27
	je	short @54@290
	cmp	byte ptr [bp-1],13
	je	@@83
	jmp	@54@50
@@83:
@54@290:
   ;	
   ;	
   ;	 for (loop=count;loop<max;loop++) *(string+loop)=0;
   ;	
	mov	di,si
	jmp	short @54@362
@54@314:
	mov	bx,word ptr [bp+4]
	mov	byte ptr [bx+di],0
	inc	di
@54@362:
	cmp	di,word ptr [bp+6]
	jl	short @54@314
   ;	
   ;	
   ;	 if (key==13) return 1;
   ;	
	cmp	byte ptr [bp-1],13
	jne	short @54@434
	mov	ax,1
	jmp	short @54@458
@54@434:
   ;	
   ;	 return 0;
   ;	
	xor	ax,ax
	jmp	short @54@458
@54@458:
   ;	
   ;	}
   ;	
	pop	di
	pop	si
	mov	sp,bp
	pop	bp
	ret	
_Input	endp
   ;	
   ;	void PPrint (const char *str)
   ;	
	assume	cs:_TEXT
_PPrint	proc	near
	push	bp
	mov	bp,sp
	dec	sp
	dec	sp
	push	si
	mov	si,word ptr [bp+4]
	jmp	short @55@170
@55@50:
   ;	
   ;	{
   ;	  unsigned char ch;
   ;	
   ;	  while ((ch=*str++) != 0)
   ;	    if (ch == '\n')
   ;	
	cmp	byte ptr [bp-1],10
	jne	short @55@98
   ;	
   ;	    {
   ;	      py+=10;
   ;	
	add	word ptr DGROUP:_py,10
   ;	
   ;	      px=pxl;
   ;	
	mov	ax,word ptr DGROUP:_pxl
	mov	word ptr DGROUP:_px,ax
   ;	
   ;	    }
   ;	
	jmp	short @55@170
@55@98:
   ;	
   ;	    else if (ch == '')
   ;	
	cmp	byte ptr [bp-1],127
	jne	short @55@146
   ;	
   ;	      fontcolor=(*str++)-'A';	// set color A-P
   ;	
	mov	al,byte ptr [si]
	cbw	
	add	ax,65471
	mov	word ptr DGROUP:_fontcolor,ax
	inc	si
	jmp	short @55@170
@55@146:
   ;	
   ;	    else
   ;	      DrawPchar (ch);
   ;	
	mov	al,byte ptr [bp-1]
	mov	ah,0
	push	ax
	call	near ptr _DrawPchar
	pop	cx
@55@170:
	mov	bx,si
	inc	si
	mov	al,byte ptr [bx]
	mov	byte ptr [bp-1],al
	or	al,al
	jne	short @55@50
   ;	
   ;	}
   ;	
	pop	si
	mov	sp,bp
	pop	bp
	ret	
_PPrint	endp
   ;	
   ;	int PGet (void)
   ;	
	assume	cs:_TEXT
_PGet	proc	near
	push	bp
	mov	bp,sp
	push	si
   ;	
   ;	{
   ;	 int oldx;
   ;	
   ;	 oldx=px;
   ;	
	mov	si,word ptr DGROUP:_px
   ;	
   ;	
   ;	 ClearKeys();
   ;	
	call	near ptr _ClearKeys
	jmp	short @56@122
@56@50:
   ;	
   ;	 while (!(NoBiosKey(1)&0xff))
   ;	 {
   ;	   DrawPchar ('_');
   ;	
	mov	ax,95
	push	ax
	call	near ptr _DrawPchar
	pop	cx
   ;	
   ;	   WaitVBL (5);
   ;	
	mov	ax,5
	push	ax
	call	near ptr _WaitVBL
	pop	cx
   ;	
   ;	   px=oldx;
   ;	
	mov	word ptr DGROUP:_px,si
   ;	
   ;	   DrawPchar ('_');
   ;	
	mov	ax,95
	push	ax
	call	near ptr _DrawPchar
	pop	cx
   ;	
   ;	   px=oldx;
   ;	
	mov	word ptr DGROUP:_px,si
   ;	
   ;	   if (NoBiosKey(1)&0xff)		// slight response improver
   ;	
	mov	ax,1
	push	ax
	call	near ptr _NoBiosKey
	pop	cx
	test	ax,255
	je	short @56@98
   ;	
   ;	     break;
   ;	
	jmp	short @56@146
@56@98:
   ;	
   ;	   WaitVBL (5);
   ;	
	mov	ax,5
	push	ax
	call	near ptr _WaitVBL
	pop	cx
@56@122:
	mov	ax,1
	push	ax
	call	near ptr _NoBiosKey
	pop	cx
	test	ax,255
	je	short @56@50
@56@146:
   ;	
   ;	 }
   ;	 px=oldx;
   ;	
	mov	word ptr DGROUP:_px,si
   ;	
   ;	 return NoBiosKey(0);		// take it out of the buffer
   ;	
	xor	ax,ax
	push	ax
	call	near ptr _NoBiosKey
	pop	cx
	jmp	short @56@170
@56@170:
   ;	
   ;	}
   ;	
	pop	si
	pop	bp
	ret	
_PGet	endp
   ;	
   ;	int PSize (const char *str)
   ;	
	assume	cs:_TEXT
_PSize	proc	near
	push	bp
	mov	bp,sp
	push	si
	push	di
	mov	si,word ptr [bp+4]
   ;	
   ;	{
   ;	  int length=0;
   ;	
	xor	di,di
	jmp	short @57@122
@57@50:
   ;	
   ;	  unsigned char ch;
   ;	
   ;	  while ((ch=*str++) != 0)
   ;	  {
   ;	    if (ch=='')	// skip color changes
   ;	
	cmp	dl,127
	jne	short @57@98
   ;	
   ;	    {
   ;	      str++;
   ;	
	inc	si
   ;	
   ;	      continue;
   ;	
	jmp	short @57@122
@57@98:
   ;	
   ;	    }
   ;	    length += ((fontstruct _seg *)fontseg)->width[ch];
   ;	
	mov	es,word ptr DGROUP:_fontseg
	mov	al,dl
	mov	ah,0
	mov	bx,ax
	mov	al,byte ptr es:[bx+514]
	cbw	
	add	di,ax
@57@122:
	mov	bx,si
	inc	si
	mov	al,byte ptr [bx]
	mov	dl,al
	or	al,al
	jne	short @57@50
   ;	
   ;	  }
   ;	
   ;	  return length;
   ;	
	mov	ax,di
	jmp	short @57@170
@57@170:
   ;	
   ;	}
   ;	
	pop	di
	pop	si
	pop	bp
	ret	
_PSize	endp
   ;	
   ;	void CPPrint (const char *str)
   ;	
	assume	cs:_TEXT
_CPPrint	proc	near
	push	bp
	mov	bp,sp
	dec	sp
	dec	sp
	push	si
	mov	si,word ptr [bp+4]
   ;	
   ;	{
   ;	  int width;
   ;	
   ;	  width = PSize(str);
   ;	
	push	si
	call	near ptr _PSize
	pop	cx
	mov	word ptr [bp-2],ax
   ;	
   ;	  px=pxl+(int)(pxh-pxl-width)/2;
   ;	
	mov	ax,word ptr DGROUP:_pxh
	sub	ax,word ptr DGROUP:_pxl
	sub	ax,word ptr [bp-2]
	mov	bx,2
	cwd	
	idiv	bx
	mov	dx,word ptr DGROUP:_pxl
	add	dx,ax
	mov	word ptr DGROUP:_px,dx
   ;	
   ;	  PPrint (str);
   ;	
	push	si
	call	near ptr _PPrint
	pop	cx
   ;	
   ;	}
   ;	
	pop	si
	mov	sp,bp
	pop	bp
	ret	
_CPPrint	endp
   ;	
   ;	void PWrap (const char *str)
   ;	
	assume	cs:_TEXT
_PWrap	proc	near
	push	bp
	mov	bp,sp
	dec	sp
	dec	sp
	push	si
	mov	si,word ptr [bp+4]
	jmp	short @59@170
@59@50:
   ;	
   ;	{
   ;	  unsigned char ch;
   ;	
   ;	  while ((ch=*str++) != 0)
   ;	    if (ch == '\n')
   ;	
	cmp	byte ptr [bp-1],10
	jne	short @59@98
   ;	
   ;	    {
   ;	      py+=10;
   ;	
	add	word ptr DGROUP:_py,10
   ;	
   ;	      px=leftedge;
   ;	
	mov	ax,word ptr DGROUP:_leftedge
	mov	word ptr DGROUP:_px,ax
   ;	
   ;	    }
   ;	
	jmp	short @59@170
@59@98:
   ;	
   ;	    else if (ch == '\r')
   ;	
	cmp	byte ptr [bp-1],13
	jne	short @59@146
   ;	
   ;	      px=leftedge;
   ;	
	mov	ax,word ptr DGROUP:_leftedge
	mov	word ptr DGROUP:_px,ax
	jmp	short @59@170
@59@146:
   ;	
   ;	    else
   ;	      DrawPchar (ch);
   ;	
	mov	al,byte ptr [bp-1]
	mov	ah,0
	push	ax
	call	near ptr _DrawPchar
	pop	cx
@59@170:
	mov	bx,si
	inc	si
	mov	al,byte ptr [bx]
	mov	byte ptr [bp-1],al
	or	al,al
	jne	short @59@50
   ;	
   ;	}
   ;	
	pop	si
	mov	sp,bp
	pop	bp
	ret	
_PWrap	endp
   ;	
   ;	void PPrintInt (int val)
   ;	
	assume	cs:_TEXT
_PPrintInt	proc	near
	push	bp
	mov	bp,sp
   ;	
   ;	{
   ;	  itoa(val,str,10);
   ;	
	mov	ax,10
	push	ax
	mov	ax,offset DGROUP:_str
	push	ax
	push	word ptr [bp+4]
	call	near ptr _itoa
	add	sp,6
   ;	
   ;	  PPrint (str);
   ;	
	mov	ax,offset DGROUP:_str
	push	ax
	call	near ptr _PPrint
	pop	cx
   ;	
   ;	}
   ;	
	pop	bp
	ret	
_PPrintInt	endp
   ;	
   ;	void PPrintUnsigned (unsigned val)
   ;	
	assume	cs:_TEXT
_PPrintUnsigned	proc	near
	push	bp
	mov	bp,sp
   ;	
   ;	{
   ;	  ltoa((long)val,str,10);
   ;	
	mov	ax,10
	push	ax
	mov	ax,offset DGROUP:_str
	push	ax
	xor	ax,ax
	push	ax
	push	word ptr [bp+4]
	call	near ptr _ltoa
	add	sp,8
   ;	
   ;	  PPrint (str);
   ;	
	mov	ax,offset DGROUP:_str
	push	ax
	call	near ptr _PPrint
	pop	cx
   ;	
   ;	}
   ;	
	pop	bp
	ret	
_PPrintUnsigned	endp
   ;	
   ;	void PPrintLong (long val)
   ;	
	assume	cs:_TEXT
_PPrintLong	proc	near
	push	bp
	mov	bp,sp
   ;	
   ;	{
   ;	  ltoa((long)val,str,10);
   ;	
	mov	ax,10
	push	ax
	mov	ax,offset DGROUP:_str
	push	ax
	push	word ptr [bp+6]
	push	word ptr [bp+4]
	call	near ptr _ltoa
	add	sp,8
   ;	
   ;	  PPrint (str);
   ;	
	mov	ax,offset DGROUP:_str
	push	ax
	call	near ptr _PPrint
	pop	cx
   ;	
   ;	}
   ;	
	pop	bp
	ret	
_PPrintLong	endp
   ;	
   ;	int PInput(char *string,int max)
   ;	
	assume	cs:_TEXT
_PInput	proc	near
	push	bp
	mov	bp,sp
	sub	sp,6
	push	si
	push	di
	mov	di,word ptr [bp+4]
   ;	
   ;	{
   ;	 char key;
   ;	 int count,loop,oldx;
   ;	
   ;	 count = strlen(string);
   ;	
	push	di
	call	near ptr _strlen
	pop	cx
	mov	si,ax
   ;	
   ;	 PPrint (str);
   ;	
	mov	ax,offset DGROUP:_str
	push	ax
	call	near ptr _PPrint
	pop	cx
@63@50:
   ;	
   ;	
   ;	 do {
   ;	     key=toupper(PGet()&0xff);
   ;	
	call	near ptr _PGet
	and	ax,255
	push	ax
	call	near ptr _toupper
	pop	cx
	mov	byte ptr [bp-1],al
   ;	
   ;	     if ((key==127 || key==8)&&count>0)
   ;	
	cmp	byte ptr [bp-1],127
	je	short @63@98
	cmp	byte ptr [bp-1],8
	jne	short @63@146
@63@98:
	or	si,si
	jle	short @63@146
   ;	
   ;	       {
   ;		px-= ((fontstruct _seg *)fontseg)->width[ch];
   ;	
	mov	es,word ptr DGROUP:_fontseg
	mov	al,byte ptr DGROUP:_ch
	cbw	
	mov	bx,ax
	mov	al,byte ptr es:[bx+514]
	cbw	
	sub	word ptr DGROUP:_px,ax
   ;	
   ;		oldx=px;
   ;	
	mov	ax,word ptr DGROUP:_px
	mov	word ptr [bp-6],ax
   ;	
   ;		count--;
   ;	
	dec	si
   ;	
   ;		DrawPchar(string[count]);
   ;	
	mov	bx,si
	mov	al,byte ptr [bx+di]
	cbw	
	push	ax
	call	near ptr _DrawPchar
	pop	cx
   ;	
   ;		px=oldx;
   ;	
	mov	ax,word ptr [bp-6]
	mov	word ptr DGROUP:_px,ax
@63@146:
   ;	
   ;	       }
   ;	
   ;	     if (key>=' ' && key<='z' && count<max)
   ;	
	cmp	byte ptr [bp-1],32
	jl	short @63@242
	cmp	byte ptr [bp-1],122
	jg	short @63@242
	cmp	si,word ptr [bp+6]
	jge	short @63@242
   ;	
   ;	       {
   ;		*(string+count++)=key;
   ;	
	mov	bx,si
	mov	al,byte ptr [bp-1]
	mov	byte ptr [bx+di],al
	inc	si
   ;	
   ;		DrawPchar(key);
   ;	
	mov	al,byte ptr [bp-1]
	cbw	
	push	ax
	call	near ptr _DrawPchar
	pop	cx
@63@242:
   ;	
   ;	       }
   ;	
   ;	    } while (key!=27 && key!=13);
   ;	
	cmp	byte ptr [bp-1],27
	je	short @63@290
	cmp	byte ptr [bp-1],13
	jne	short @63@50
@63@290:
   ;	
   ;	
   ;	 for (loop=count;loop<max;loop++)
   ;	
	mov	word ptr [bp-4],si
	jmp	short @63@362
@63@314:
   ;	
   ;	   *(string+loop)=0;
   ;	
	mov	bx,word ptr [bp-4]
	mov	byte ptr [bx+di],0
	inc	word ptr [bp-4]
@63@362:
	mov	ax,word ptr [bp-4]
	cmp	ax,word ptr [bp+6]
	jl	short @63@314
   ;	
   ;	
   ;	 if (key==13)
   ;	
	cmp	byte ptr [bp-1],13
	jne	short @63@434
   ;	
   ;	   return 1;
   ;	
	mov	ax,1
	jmp	short @63@458
@63@434:
   ;	
   ;	 return 0;
   ;	
	xor	ax,ax
	jmp	short @63@458
@63@458:
   ;	
   ;	}
   ;	
	pop	di
	pop	si
	mov	sp,bp
	pop	bp
	ret	
_PInput	endp
_TEXT	ends
_DATA	segment word public 'DATA'
	db	48
	db	49
	db	50
	db	51
	db	52
	db	53
	db	54
	db	55
	db	56
	db	57
	db	65
	db	66
	db	67
	db	68
	db	69
	db	70
	db	2 dup (0)
_DATA	ends
_TEXT	segment byte public 'CODE'
   ;	
   ;	void PPrintHexB(unsigned char value)
   ;	
	assume	cs:_TEXT
_PPrintHexB	proc	near
	push	bp
	mov	bp,sp
	sub	sp,20
	push	ss
	lea	ax,word ptr [bp-20]
	push	ax
	push	ds
	mov	ax,offset DGROUP:d@+303
	push	ax
	mov	cx,16
	call	near ptr N_SCOPY@
	push	ss
	lea	ax,word ptr [bp-4]
	push	ax
	push	ds
	mov	ax,offset DGROUP:d@+319
	push	ax
	mov	cx,2
	call	near ptr N_SCOPY@
   ;	
   ;	{
   ;	 int loop;
   ;	 char hexstr[16]="0123456789ABCDEF",str[2]="";
   ;	
   ;	 for (loop=0;loop<2;loop++)
   ;	
	mov	word ptr [bp-2],0
	jmp	short @64@98
@64@50:
   ;	
   ;	   {
   ;	    str[0]=hexstr[(value>>(1-loop)*4)&15];
   ;	
	mov	al,byte ptr [bp+4]
	mov	ah,0
	mov	dl,1
	sub	dl,byte ptr [bp-2]
	shl	dl,1
	shl	dl,1
	mov	cl,dl
	sar	ax,cl
	and	ax,15
	lea	dx,word ptr [bp-20]
	add	ax,dx
	mov	bx,ax
	mov	al,byte ptr [bx]
	mov	byte ptr [bp-4],al
   ;	
   ;	    PPrint(str);
   ;	
	lea	ax,word ptr [bp-4]
	push	ax
	call	near ptr _PPrint
	pop	cx
	inc	word ptr [bp-2]
@64@98:
	cmp	word ptr [bp-2],2
	jl	short @64@50
   ;	
   ;	   }
   ;	}
   ;	
	mov	sp,bp
	pop	bp
	ret	
_PPrintHexB	endp
   ;	
   ;	void PPrintHex(unsigned value)
   ;	
	assume	cs:_TEXT
_PPrintHex	proc	near
	push	bp
	mov	bp,sp
   ;	
   ;	{
   ;	 PPrint("$");
   ;	
	mov	ax,offset DGROUP:s@+545
	push	ax
	call	near ptr _PPrint
	pop	cx
   ;	
   ;	 PPrintHexB(value>>8);
   ;	
	mov	ax,word ptr [bp+4]
	mov	cl,8
	shr	ax,cl
	push	ax
	call	near ptr _PPrintHexB
	pop	cx
   ;	
   ;	 PPrintHexB(value&0xff);
   ;	
	mov	al,byte ptr [bp+4]
	and	al,255
	push	ax
	call	near ptr _PPrintHexB
	pop	cx
   ;	
   ;	}
   ;	
	pop	bp
	ret	
_PPrintHex	endp
   ;	
   ;	void LoadCtrls (void)
   ;	
	assume	cs:_TEXT
_LoadCtrls	proc	near
	push	bp
	mov	bp,sp
	push	si
   ;	
   ;	{
   ;	  int handle;
   ;	
   ;	  if ((handle = open("CTLPANEL."EXTENSION, O_RDONLY | O_BINARY, S_IWRITE | S_IREAD)) == -1)
   ;	
	mov	ax,384
	push	ax
	mov	ax,32769
	push	ax
	mov	ax,offset DGROUP:s@+547
	push	ax
	call	near ptr _open
	add	sp,6
	mov	si,ax
	cmp	ax,65535
	jne	short @66@74
   ;	
   ;	  //
   ;	  // set up default control panel settings
   ;	  //
   ;	  {
   ;	    key[0] = 0x48;
   ;	
	mov	byte ptr DGROUP:_key,72
   ;	
   ;	    key[1] = 0x49;
   ;	
	mov	byte ptr DGROUP:_key+1,73
   ;	
   ;	    key[2] = 0x4d;
   ;	
	mov	byte ptr DGROUP:_key+2,77
   ;	
   ;	    key[3] = 0x51;
   ;	
	mov	byte ptr DGROUP:_key+3,81
   ;	
   ;	    key[4] = 0x50;
   ;	
	mov	byte ptr DGROUP:_key+4,80
   ;	
   ;	    key[5] = 0x4f;
   ;	
	mov	byte ptr DGROUP:_key+5,79
   ;	
   ;	    key[6] = 0x4b;
   ;	
	mov	byte ptr DGROUP:_key+6,75
   ;	
   ;	    key[7] = 0x47;
   ;	
	mov	byte ptr DGROUP:_key+7,71
   ;	
   ;	    keyB1 = 0x1d;
   ;	
	mov	byte ptr DGROUP:_keyB1,29
   ;	
   ;	    keyB2 = 0x38;
   ;	
	mov	byte ptr DGROUP:_keyB2,56
   ;	
   ;	  }
   ;	
	jmp	short @66@98
@66@74:
   ;	
   ;	  else
   ;	  {
   ;	    read(handle, &key, sizeof(key));
   ;	
	mov	ax,8
	push	ax
	mov	ax,offset DGROUP:_key
	push	ax
	push	si
	call	near ptr _read
	add	sp,6
   ;	
   ;	    read(handle, &keyB1, sizeof(keyB1));
   ;	
	mov	ax,1
	push	ax
	mov	ax,offset DGROUP:_keyB1
	push	ax
	push	si
	call	near ptr _read
	add	sp,6
   ;	
   ;	    read(handle, &keyB2, sizeof(keyB2));
   ;	
	mov	ax,1
	push	ax
	mov	ax,offset DGROUP:_keyB2
	push	ax
	push	si
	call	near ptr _read
	add	sp,6
   ;	
   ;	    read(handle, &highscore, sizeof(highscore));
   ;	
	mov	ax,4
	push	ax
	mov	ax,offset DGROUP:_highscore
	push	ax
	push	si
	call	near ptr _read
	add	sp,6
   ;	
   ;	    close(handle);
   ;	
	push	si
	call	near ptr _close
	pop	cx
@66@98:
   ;	
   ;	  }
   ;	}
   ;	
	pop	si
	pop	bp
	ret	
_LoadCtrls	endp
   ;	
   ;	void SaveCtrls (void)
   ;	
	assume	cs:_TEXT
_SaveCtrls	proc	near
	push	bp
	mov	bp,sp
	push	si
   ;	
   ;	{
   ;	  int handle;
   ;	
   ;	  if ((handle = open("CTLPANEL."EXTENSION, O_WRONLY | O_BINARY | O_CREAT | O_TRUNC, S_IREAD | S_IWRITE)) == -1)
   ;	
	mov	ax,384
	push	ax
	mov	ax,33538
	push	ax
	mov	ax,offset DGROUP:s@+560
	push	ax
	call	near ptr _open
	add	sp,6
	mov	si,ax
	cmp	ax,65535
	jne	short @67@74
   ;	
   ;	    return;
   ;	
	jmp	short @67@98
@67@74:
   ;	
   ;	
   ;	  write(handle, &key, sizeof(key));
   ;	
	mov	ax,8
	push	ax
	mov	ax,offset DGROUP:_key
	push	ax
	push	si
	call	near ptr _write
	add	sp,6
   ;	
   ;	  write(handle, &keyB1, sizeof(keyB1));
   ;	
	mov	ax,1
	push	ax
	mov	ax,offset DGROUP:_keyB1
	push	ax
	push	si
	call	near ptr _write
	add	sp,6
   ;	
   ;	  write(handle, &keyB2, sizeof(keyB2));
   ;	
	mov	ax,1
	push	ax
	mov	ax,offset DGROUP:_keyB2
	push	ax
	push	si
	call	near ptr _write
	add	sp,6
   ;	
   ;	  write(handle, &highscore, sizeof(highscore));
   ;	
	mov	ax,4
	push	ax
	mov	ax,offset DGROUP:_highscore
	push	ax
	push	si
	call	near ptr _write
	add	sp,6
   ;	
   ;	
   ;	  close(handle);
   ;	
	push	si
	call	near ptr _close
	pop	cx
@67@98:
   ;	
   ;	}
   ;	
	pop	si
	pop	bp
	ret	
_SaveCtrls	endp
_TEXT	ends
_BSS	segment word public 'BSS'
_ch	label	byte
	db	1 dup (?)
	db	1 dup (?)
_mapwidthextra	label	word
	db	2 dup (?)
_score	label	word
	db	4 dup (?)
_JoyXlow	label	word
	db	6 dup (?)
_JoyXhigh	label	word
	db	6 dup (?)
_JoyYlow	label	word
	db	6 dup (?)
_JoyYhigh	label	word
	db	6 dup (?)
_sx	label	word
	db	2 dup (?)
_nodearray	label	word
	db	1024 dup (?)
_keyB1	label	byte
	db	1 dup (?)
_keyB2	label	byte
	db	1 dup (?)
_str	label	byte
	db	80 dup (?)
_useegamem	label	word
	db	2 dup (?)
_pxl	label	word
	db	2 dup (?)
_pxh	label	word
	db	2 dup (?)
_key	label	byte
	db	8 dup (?)
_sy	label	word
	db	2 dup (?)
_bordercolor	label	word
	db	2 dup (?)
_charptr	label	dword
	db	4 dup (?)
_level	label	word
	db	2 dup (?)
_pyl	label	word
	db	2 dup (?)
_pyh	label	word
	db	2 dup (?)
_playermode	label	word
	db	6 dup (?)
_needgr	label	byte
	db	77 dup (?)
	db	1 dup (?)
_maprle	label	dword
	db	4 dup (?)
_spriteptr	label	dword
	db	4 dup (?)
_mapbwide	label	word
	db	2 dup (?)
_mapwwide	label	word
	db	2 dup (?)
_picptr	label	dword
	db	4 dup (?)
_leftedge	label	word
	db	2 dup (?)
_win_xl	label	word
	db	2 dup (?)
_win_xh	label	word
	db	2 dup (?)
_win_yl	label	word
	db	2 dup (?)
_win_yh	label	word
	db	2 dup (?)
_pictable	label	word
	db	296 dup (?)
_tileptr	label	dword
	db	4 dup (?)
_mapplane	label	dword
	db	16 dup (?)
_mapheight	label	word
	db	2 dup (?)
_grmode	label	word
	db	2 dup (?)
_grsegs	label	word
	db	154 dup (?)
_buttonflip	label	word
	db	2 dup (?)
_highscore	label	word
	db	4 dup (?)
_videocard	label	word
	db	2 dup (?)
_levelheader	label	dword
	db	4 dup (?)
	?debug	C E9
_BSS	ends
_DATA	segment word public 'DATA'
s@	label	byte
	db	'Joystick Configuration'
	db	10
	db	0
	db	'Hold the joystick in the UPPER LEFT'
	db	10
	db	0
	db	'corner and press a button:'
	db	0
	db	10
	db	'Hold the joystick in the LOWER RIGHT'
	db	10
	db	0
	db	'corner and press a button:'
	db	0
	db	10
	db	'(F)ire or (A)fterburn with B1 ?'
	db	0
	db	'ESC'
	db	0
	db	'BKSP'
	db	0
	db	'TAB'
	db	0
	db	'CTRL'
	db	0
	db	'LSHIFT'
	db	0
	db	'SPACE'
	db	0
	db	'CAPSLK'
	db	0
	db	'F'
	db	0
	db	'F11'
	db	0
	db	'F12'
	db	0
	db	'SCRLLK'
	db	0
	db	'ENTER'
	db	0
	db	'RSHIFT'
	db	0
	db	'PRTSC'
	db	0
	db	'ALT'
	db	0
	db	'HOME'
	db	0
	db	'PGUP'
	db	0
	db	'END'
	db	0
	db	'PGDN'
	db	0
	db	'INS'
	db	0
	db	'DEL'
	db	0
	db	'NUMLK'
	db	0
	db	'UP'
	db	0
	db	'DOWN'
	db	0
	db	'LEFT'
	db	0
	db	'RIGHT'
	db	0
	db	'Keyboard Configuration'
	db	0
	db	10
	db	'1 north'
	db	0
	db	10
	db	'2 east'
	db	0
	db	10
	db	'3 south'
	db	0
	db	10
	db	'4 west'
	db	0
	db	10
	db	'5 button1'
	db	0
	db	10
	db	'6 button2'
	db	0
	db	10
	db	'Modify which action:'
	db	0
	db	':'
	db	0
	db	':'
	db	0
	db	':'
	db	0
	db	10
	db	'Press the new key:'
	db	0
	db	':'
	db	0
	db	'BloadinMM: Can'
	db	39
	db	't find file '
	db	0
	db	'HUFF'
	db	0
	db	'Tried to expand a file that isn'
	db	39
	db	't HUFF!'
	db	0
	db	'RLEWExpand error!'
	db	0
	db	'$'
	db	0
	db	'%'
	db	0
	db	'1'
	db	0
	db	'0'
	db	0
	db	'$'
	db	0
	db	'CTLPANEL.HOV'
	db	0
	db	'CTLPANEL.HOV'
	db	0
_DATA	ends
_TEXT	segment byte public 'CODE'
_TEXT	ends
	public	_CenterWindow
	public	_CalibrateJoy
	public	_InputInt
	public	_printscan
	public	_SetScreenMode
	public	_PWrap
	public	_PrintBin
	extrn	_NBKascii:word
	extrn	_DrawPchar:near
	extrn	_filelength:near
	public	_PGet
	public	_PrintHex
	public	_PrintC
	public	_GenYlookup
	public	_ReadJoystick
	extrn	_write:near
	public	_levelheader
	extrn	_DrawChar:near
	extrn	_linewidth:word
	public	_videocard
	public	_highscore
	public	_HuffExpand
	public	_Input
	extrn	_MMFreePtr:near
	public	_buttonflip
	public	_grsegs
	public	_Ack
	extrn	_NBKscan:word
	public	_grmode
	public	_Print
	public	_FadeDown
	public	_PPrintUnsigned
	public	_SaveCtrls
	public	_mapheight
	extrn	_MMGetPtr:near
	extrn	_keydown:byte
	public	_mapplane
	public	_tileptr
	public	_pictable
	public	_win_yh
	public	_win_yl
	public	_win_xh
	public	_win_xl
	public	_OptimizeNodes
	public	_SaveFile
	public	_FadeOut
	extrn	_CallTimer:near
	public	_leftedge
	public	_PPrintHexB
	public	_picptr
	public	_mapwwide
	public	_mapbwide
	public	_PInput
	public	_EGAVirtualScreen
	public	_spriteptr
	public	_maprle
	public	_ClearKeys
	public	_screencentery
	public	_screencenterx
	public	_StopDrive
	public	_RLEWExpand
	public	_RLEBExpand
	public	_PPrintLong
	public	_needgr
	public	_ControlJoystick
	extrn	_memset:near
	public	_playermode
	public	_Verify
	public	_PPrintInt
	public	_pyh
	public	_pyl
	public	_EGASplitScreen
	public	_BloadinHUFFMM
	extrn	_ylookup:word
	public	_level
	public	_charptr
	public	_PPrintHex
	public	_ControlPlayer
	public	_BloadinRLEMM
	extrn	_strncmp:near
	public	_bordercolor
	extrn	_Quit:near
	public	_sy
	extrn	_read:near
	public	_ExpWinV
	public	_ExpWinH
	extrn	_strcpy:near
	public	_CPPrint
	extrn	_py:word
	public	_FadeUp
	public	_key
	public	_PPrint
	extrn	_close:near
	public	_Get
	public	_ColorBorder
	extrn	_WaitVBL:near
	extrn	_fontcolor:word
	extrn	_strlen:near
	extrn	N_SCOPY@:far
	public	_FadeIn
	public	_ExpWin
	extrn	_movedata:near
	public	_CharBar
	extrn	_Bar:near
	public	_JoyButton
	extrn	_strcat:near
	public	_SetNormalPalette
	public	_pxh
	public	_pxl
	public	_LoadCtrls
	public	_BloadinMM
	extrn	_ltoa:near
	public	_SetDefaultColors
	extrn	_itoa:near
	public	_useegamem
	extrn	_screenseg:word
	extrn	_atol:near
	public	_str
	extrn	N_LDIV@:far
	public	_keyB2
	public	_keyB1
	public	_nodearray
	extrn	_NoBiosKey:near
	extrn	_EGAplane:near
	public	_LoadFile
	extrn	_open:near
	public	_sx
	public	_LoadPage
	public	_JoyYhigh
	public	_JoyYlow
	public	_JoyXhigh
	public	_JoyXlow
	public	_colors
	extrn	_px:word
	public	_calibratekeys
	public	_PSize
	extrn	_toupper:near
	public	_PrintHexB
	extrn	_fontseg:word
	public	_score
	public	_mapwidthextra
	public	_DrawWindow
	extrn	N_PADD@:far
	public	_HuffExpandFile
	extrn	N_PSBA@:far
	extrn	N_PADA@:far
	public	_CRTCstart
	public	_PrintLong
	public	_ch
	public	_SetLineWidth
	public	_DrawFrame
	public	_ControlKBD
	public	_Printxy
	public	_PrintInt
	end
