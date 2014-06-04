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

IDEAL
MODEL	SMALL,C

;============================================================================
;
;                 Gamer's Edge Library, ASM section
;
;============================================================================



;=======================================================================
;
;                     KEYBOARD ROUTINES
;
;=======================================================================


DATASEG
EVEN

oldint9	dd	0
keydown	db	128 dup (0)
NBKscan	dw	0
NBKascii dw	0

scanascii db	0,27,49,50,51,52,53,54,55,56,57,48,45,61,8,9,113 ;'q'
	db	119,101,114,116,121,117,105,111,112,91,93,13,0,97,115 ;'s'
	db	100,102,103,104,106,107,108,59,39,96,0,92,122,120,99 ;'c'
	db	118,98,110,109,44,46,47,0,42,0,32,0,1,1,1,1,1,1,1,1,1,1 ;f10
	db	0,0,1,1,1,45,1,1,1,43,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0 ;shift-f10
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 ;ctl-home
	db	0,0,0,0,0,0,0,0,0,0,0,0,0

PUBLIC	keydown,NBKscan,NBKascii

CODESEG

;========
;
; StartupKbd
;
; Sets up the new INT 8 ISR and various internal pointers.
; Assumes that the calling program has pointer soundseg to something
; meaningful...
;
;========

PROC	StartupKbd
PUBLIC	StartupKbd

	mov	ax,3509h	;call bios to get int 9
	int	21h
	mov	[WORD oldint9],bx
	mov	ax,es
	mov	[WORD oldint9+2],ax

	push	ds

	push	cs
	pop	ds
	lea	dx,[Int9Isr]
	mov	ax,2509h	;call bios to set int 9
	int	21h

	pop	ds

	ret

ENDP



;========
;
; ShutdownKbd
;
;========

PROC	ShutdownKbd
PUBLIC	ShutdownKbd

	push	ds

	mov	dx,[WORD Oldint9]
	mov	ds,[WORD Oldint9+2]
	mov	ax,2509h	;call bios to set int 8
	int	21h

	mov	ax,40h 		;clear ctrl/alt/shift flags
	mov	ds,ax
	mov	ax,[17h]
	and	ax,1111110011110000b
	mov	[17h],ax

	pop	ds
	ret

ENDP


;========
;
; NoBiosKey
;
;========

PROC	NoBiosKey	parm:WORD
PUBLIC	NoBiosKey

	xor	bh,bh
	mov	ax,[parm]
	or	ax,ax
	jnz     @@bioskey1
@@waitforkey:
	mov	bl,[BYTE NBKscan]
	or	bl,bl
	jns	@@waitforkey
	mov	al,[BYTE NBKascii]
	or	al,al
	jz	@@waitforkey
	mov	ah,[BYTE NBKscan]
	and	[BYTE NBKscan],7fh
	ret
@@bioskey1:
	mov	al,[BYTE NBKascii]
	mov	ah,[BYTE NBKscan]
	and	ah,7fh
	or	al,al
	jnz	@@ok
	xor	ah,ah		; just a modifier key
@@ok:
	ret

ENDP



;========
;
; Int9ISR
; only called by interrupt $9!
;
;=========

PROC	Int9ISR FAR
PUBLIC	Int9ISR

	push	ax
	push	bx
	push	ds

	xor	ah,ah
	in	al,60h		;get the key pressed
	push	ax

	in	al,61h
	mov	ah,al
	or	al,80h
	out	61h,al
	mov	al,ah
	out	61h,al

	mov	bx,_DATA
	mov	ds,bx		;ds to this data segment

	pop	ax
	or	al,al

	jns	@@keydown
;
; key released
;
	and	al,7fh
	mov	bx,ax
	mov	[keydown+BX],ah	;keydown[key] = false
	jmp	@@done

@@keydown:
	mov	[BYTE NBKscan],al
	or	[BYTE NBKscan],80h	;high bit set after press, cleared
	mov	bx,ax			;after NoBiosKey gets it
	mov	al,1
	mov	[keydown+BX],al	;keydown[key] = true
	mov	al,[scanascii+bx]
	mov	[BYTE NBKascii],al	;set the ascii code of key
@@done:
	mov	al,20h
	out	20h,al		;we got the interrupt here

	pop	ds
	pop	bx
	pop	ax

	iret


ENDP


;============================================================================
;
;                           SOUND ROUTINES
;
;============================================================================

	DATASEG

;
;offsets into .SPK file at segment SPKRfile, offset 0
;
;sound records each take up 16 bytes, and start at $10, and continue to $3F0

snd_start	equ	0
snd_priority	equ	2
snd_samples	equ	3
snd_name	equ	4

timerspeed	dw	0	;clock speed for tic counting

LABEL	inttime WORD
timecount	dd	0,0	;fast timer tics since startup

SPKactive dw    0                   ;set non zero when started

soundmode	dw	1       ;0=nosound, 1=SPKR, 2= adlib...
OldInt8		dd	?	;StartupSPK saves here, Shutdown restores
Intcount	db	?	;counter for extraints, call OldInt8 at 0

SndPtr		dw	?	;Pointer to frequency of current sound
SndPriority	db	?	;current sound's priority

pausesndptr	dw	?
pausepriority	db	?
pauseintcount	db	?

dontplay	dw	0	;set to 1 to avoid all interrupt and timer stuff

int8hook	dw	0	;gets called every tic if not null

soundseg	dw	?

PUBLIC soundmode,dontplay,timecount,inttime,timerspeed,int8hook,soundseg,sndptr
PUBLIC SndPriority

EXTRN	soundblaster:WORD

        CODESEG


;========
;
; StartupSound
;
; Sets up the new INT 8 ISR and various internal pointers.
; Assumes that the calling program has pointer soundseg to something
; meaningful...
;
;========

PROC StartupSound
	PUBLIC	StartupSound

	test	[dontplay],0ffffh
	je	@@dowork
	ret
@@dowork:
	test	[SPKactive],0FFFFh	;see if library is active
	jne	@@started		;library was allready started

@@start:
	call	NEAR PTR StopSound 	;make sure nothing is playing

	mov	ax,3508h	;call bios to get int 8
	int	21h
	mov	[WORD oldint8],bx
	mov	ax,es
	mov	[WORD oldint8+2],ax

	push	ds

	push	cs
	pop	ds
	lea	dx,[UpdateSPKR]
	mov	ax,2508h	;call bios to set int 8
	int	21h

	pop	ds

	mov	bx,[timerspeed]
	cli
	mov	al,36h		;tell the timer chip we are going to
	out	43h,al		;change the speed of timer 0
	mov	al,0
	mov	al,bl
	out	40h,al		;low
	mov	al,bh
	out	40h,al		;high
	sti

	inc	[SPKactive]	;sound routines are now active

@@started:
	mov	ax,1
	mov	[soundmode],ax ;set soundmode to SPKR
	ret

ENDP


;========
;
; CallTimer
;
; Call the bios int8 to turn off drive motors
;
;========

PROC	CallTimer
PUBLIC CallTimer

	test	[WORD OldInt8+2],0ffffh
	jz	@@done

	pushf
	call	[OldInt8]
@@done:
	ret
ENDP


;========
;
; ShutdownSound
;
;========

PROC	ShutdownSound
	PUBLIC ShutdownSound

	test	[dontplay],0ffffh
	je	@@dowork
	ret
@@dowork:
	cli
	mov	al,36h		;tell the timer chip we are going to
	out	43h,al		;change the speed of timer 0
	mov	al,0		;system expects 0000 for rate
	out	40h,al		;low
	out	40h,al		;high
	sti

	mov	ax,[SPKactive]
	cmp	ax,0
	je	@@done		;sound library wasn't started...

	push	ds

	mov	dx,[WORD Oldint8]
	mov	ax,[WORD Oldint8+2]
	mov	ds,ax
	mov	ax,2508h	;call bios to set int 8
	int	21h

	pop	ds

	mov	[SPKactive],0	;sound routines are now inactive

	cli
	in	al,61h		;get peripheral (speaker) port value
	and	al,11111101b	;turn speaker off
	out	61h,al
	sti
@@done:
	ret

ENDP



;===========
;
; PlaySoundSPK (soundnum)
;
; If the sound's priority is >= the current priority, SoundPtr, SndPriority,
; and the timer speed are changed
;
; Hacked for sound blaster support!
;
;===========

EXTRN	jmPlaySample:PROC

PROC	PlaySound playnum:WORD
	USES	SI
	PUBLIC PlaySound

	test	[dontplay],-1	;for profiler
	jne	@@playdone
	test	[soundmode],-1	;f2 to turn off sound blaster also
	je	@@playdone

	mov	ax,[playnum]	;index into the sound headers

	mov	si,ax
	shl	si,1
	shl	si,1
	shl	si,1
	shl	si,1

	mov	es,[soundseg]		;point es: to the spkr file

	mov	al,[es:si+snd_Priority]	;priority table (one byte each)
	cmp	al,[SndPriority]
	jb	@@playdone	;current sound has higher priority
	mov	[SndPriority],al

	test	[soundblaster],-1
	jz	@@pc

	push	[playnum]
	call	jmPlaySample
	pop	ax
	ret

@@pc:
	mov	ax,[es:si+snd_Start]	;offset in .SPK file
	mov	[SndPtr],ax	;store it in the sound playing table


@@playdone:
	ret

ENDP


;======================================================================

;===========
;
; StopSound
;
;===========

PROC	StopSound
	PUBLIC	StopSound

	test	[dontplay],0ffffh
	je	@@dowork
	ret
@@dowork:
	xor	ax,ax		;set to 0
	mov	[SndPtr],ax
	mov	[SndPriority],al

	cli

	in	al,61h		;get peripheral (speaker) port value
	and	al,11111101b	;turn speaker off
	out	61h,al

	sti

	ret
ENDP

;======================================================================

;===========
;
; PauseSound
;
;===========

PROC	PauseSound
	PUBLIC	PauseSound

	test	[dontplay],0ffffh
	je	@@dowork
	ret
@@dowork:
	mov	ax,[SndPtr]	;save off the current values
	mov	[pausesndptr],ax
	mov	al,[SndPriority]
	mov	[pausepriority],al
	mov	al,[intcount]
	mov	[pauseintcount],al
	call	StopSound
	ret
ENDP

;======================================================================

;===========
;
; ContinueSound
;
;===========

PROC	ContinueSound
	PUBLIC	ContinueSound

	test	[dontplay],0ffffh
	je	@@dowork
	ret
@@dowork:
	mov	ax,[pausesndptr]
	mov	[SndPtr],ax	;restore the old values
	mov	al,[pausepriority]
	mov	[SndPriority],al
	mov	al,[pauseintcount]
	mov	[intcount],al

	ret
ENDP

;======================================================================

;========
;
; WaitendSound
; Just waits around until the current sound stops playing
;
;========

PROC	WaitEndSound
	PUBLIC WaitEndSound

	test	[dontplay],0ffffh
	je	@@dowork
	ret
@@dowork:
	pushf
	call FAR PTR UpdateSPKR	;in case a sound was just started and hasn't
				;been hit by an INT yet
@@wait:
	mov	ax,[sndptr]
	cmp	ax,0		;when the ptr is 0, nothing is on
	jne	@@wait

	ret

ENDP

;=========================================================================

;========
;
; UpdateSPKR
; only called by interrupt $8!
;
;=========

DATASEG

EVEN

oldss	dw	?
oldsp	dw	?

fakestack	dw	64 dup (?)

PUBLIC fakestack

CODESEG

PROC	UpdateSPKR FAR
PUBLIC	UpdateSPKR

	push	ax
	push	bx
	push	cx
	push	si
	push	ds
	push	es

	mov	al,20h
	out	20h,al		;we got the interrupt here

	mov	ax,@Data
	mov	ds,ax		;ds to this data segment

	add	[WORD timecount],1 ;inced once every VBL time
	adc	[WORD timecount+2],0

;
; call a user routine if needed
;
	mov	ax,[int8hook]
	or	ax,ax
	jz	@@userdone
	push	ax
	push	bx
	push	cx
	push	dx
	push	si
	push	di
	push	bp
	push	es
	push	ds
	pushf

	mov	[oldss],ss	;because we might not be in our stack!
	mov	[oldsp],sp
	mov	bx,ds
	mov	ss,bx		;make SURE the stack is = ds
	mov	sp,OFFSET fakestack+60
	call	ax		;user routine that gets called every tic
	mov	ss,[oldss]
	mov	sp,[oldsp]

	popf
	pop	ds
	pop	es
	pop	bp
	pop	di
	pop	si
	pop	dx
	pop	cx
	pop	bx
	pop	ax

@@userdone:
	mov	es,[soundseg]		;es to sound file
;
; play the speaker
;
	mov	si,[SndPtr]
	cmp	si,0
	je	@@nosound	;nothing playing

	mov	bx,[es:si]
	inc	[SndPtr]
	inc	[SndPtr]

	cmp	bx,0
	je	@@nosound	;a zero frequency is no sound, but don't stop

	cmp	bx,-1		;a -1 frequency is end of sound
	jne	@@playfreq

	call	StopSound
	jmp	@@doneplay

@@nosound:
	in	al,61h		;get peripheral (speaker) port value
	and	al,11111100b	;turn speaker off
	out	61h,al
	jmp	@@doneplay

@@playfreq:
	test	[soundmode],0FFh	;if soundon=0, don't play anything
	je	@@nosound

	mov	al,10110110b	;write to channel 2 (speaker) timer
	out	43h,al
	mov	al,bl
	out	42h,al		;low byte
	mov	al,bh
	out	42h,al		;high byte

	in	al,61h		;get peripheral (speaker) port value
	or	al,00000011b	;turn speaker on to timer
	out	61h,al

@@doneplay:

	pop	es
	pop	ds
	pop	si
	pop	cx
	pop	bx
	pop	ax

	iret


ENDP


;============================================================================
;
;                           RANDOM ROUTINES
;
;============================================================================

	DATASEG

rndindex	dw	?

rndtable db    0,   8, 109, 220, 222, 241, 149, 107,  75, 248, 254, 140,  16,  66
    db   74,  21, 211,  47,  80, 242, 154,  27, 205, 128, 161,  89,  77,  36
    db   95, 110,  85,  48, 212, 140, 211, 249,  22,  79, 200,  50,  28, 188
    db   52, 140, 202, 120,  68, 145,  62,  70, 184, 190,  91, 197, 152, 224
    db  149, 104,  25, 178, 252, 182, 202, 182, 141, 197,   4,  81, 181, 242
    db  145,  42,  39, 227, 156, 198, 225, 193, 219,  93, 122, 175, 249,   0
    db  175, 143,  70, 239,  46, 246, 163,  53, 163, 109, 168, 135,   2, 235
    db   25,  92,  20, 145, 138,  77,  69, 166,  78, 176, 173, 212, 166, 113
    db   94, 161,  41,  50, 239,  49, 111, 164,  70,  60,   2,  37, 171,  75
    db  136, 156,  11,  56,  42, 146, 138, 229,  73, 146,  77,  61,  98, 196
    db  135, 106,  63, 197, 195,  86,  96, 203, 113, 101, 170, 247, 181, 113
    db   80, 250, 108,   7, 255, 237, 129, 226,  79, 107, 112, 166, 103, 241
    db   24, 223, 239, 120, 198,  58,  60,  82, 128,   3, 184,  66, 143, 224
    db  145, 224,  81, 206, 163,  45,  63,  90, 168, 114,  59,  33, 159,  95
    db   28, 139, 123,  98, 125, 196,  15,  70, 194, 253,  54,  14, 109, 226
    db   71,  17, 161,  93, 186,  87, 244, 138,  20,  52, 123, 251,  26,  36
    db   17,  46,  52, 231, 232,  76,  31, 221,  84,  37, 216, 165, 212, 106
    db  197, 242,  98,  43,  39, 175, 254, 145, 190,  84, 118, 222, 187, 136
    db  120, 163, 236, 249


;
; Random # Generator vars
;
indexi		dw	?	;Rnd#Generator
indexj		dw	?
LastRnd		dw	?
RndArray	dw	17 dup (?)

baseRndArray	dw	1,1,2,3,5,8,13,21,54,75,129,204
   		dw	323,527,850,1377,2227

	CODESEG

;=================================================
;
; InitRnd (boolean randomize)
; if randomize is false, the counter is set to 0
;
;=================================================

PROC	InitRnd	randomize:word
	USES	SI,DI
	public	InitRnd

	mov	ax,ds
	mov	es,ax
	mov	di,offset RndArray
	mov	si,offset baseRndArray
	mov	cx,17
	cld
	rep	movsw		;set up the table (which is constantly changed)

	mov	[LastRnd],0
	mov	[indexi],17*2
	mov	[indexj],5*2

	mov	ax,[randomize]
	cmp	ax,0
	je	@@setit		;if randomize is true, really random

	mov	ah,2ch
	int	21h			;GetSystemTime

	mov	[RndArray+34-2],dx
	xor dx,cx				;init w/seconds values
	mov	[RndArray+10-2],dx

@@setit:
	mov	ax,0ffffh
	push	ax
	call	Rnd			;warm up generator!
	pop	ax

	ret

ENDP

;=================================================
;
; unsigned Random (unsigned maxval)
; Return a random # between 0-?
;
;=================================================

PROC	Rnd	maxval:WORD
	USES	SI
	public	Rnd

	mov	ax,[maxval]

	push	ax			;save max value
;
; create a mask to cut down on the # of SUBTRACTS!
;
	mov	dx,0ffffh		;full-mask
@@0:
	shl	ax,1
	jc	@@0a
	shr	dx,1
	jmp	@@0
@@0a:
	mov	bx,[indexi]		;this routine was converted from
	mov	si,[indexj]		;the Random macro on Merlin GS
	mov	ax,[RndArray-2+bx]
	adc	ax,[RndArray-2+si]
	mov	[RndArray-2+bx],ax
	add	ax,[LastRnd]
	mov	[LastRnd],ax
	dec	bx
	dec	bx
	jne	@@1
	mov	bx,17*2
@@1:
	dec	si
	dec	si
	jne	@@2
	mov	si,17*2
@@2:
	mov	[indexi],bx
	mov	[indexj],si
	pop	cx                      ;loop -- returns value in range
	and	ax,dx			;AND our mask!
@@3:
	cmp	ax,cx			;SUBTRACT to be within range
	jbe	@@4
	shr	ax,1
@@4:
	ret

ENDP



;=================================================
;
; InitRndT (boolean randomize)
; Init table based RND generator
; if randomize is false, the counter is set to 0
;
;=================================================

PROC	InitRndT randomize:word
	uses	si,di
	public	initrndt

	mov	ax,[randomize]
	or	ax,ax
	jne	@@timeit		;if randomize is true, really random

	mov	dx,0			;set to a definate value
	jmp	@@setit

@@timeit:
	mov	ah,2ch
	int	21h			;GetSystemTime
	and	dx,0ffh

@@setit:
	mov	[rndindex],dx

	ret

ENDP

;=================================================
;
; int RandomT (void)
; Return a random # between 0-255
; Exit : AX = value
;
;=================================================
PROC	RndT
	public	RndT

	mov	bx,[rndindex]
	inc	bx
	and	bx,0ffh
	mov	[rndindex],bx
	mov	al,[rndtable+BX]
	xor	ah,ah

	ret

ENDP

;============================================================================
;
;                           MISC VIDEO ROUTINES
;
;============================================================================

;========
;
; WaitVBL (int number)
;
;========
STATUS_REGISTER_1     =	03dah

PROC	WaitVBL number:WORD
	PUBLIC	WaitVBL

	mov	dx,STATUS_REGISTER_1

	mov	cx,[number]

waitvbl1:
	in	al,dx
	test	al,00001000b	;look for vbl
	jnz	waitvbl1

waitvbl2:
	in	al,dx
	test	al,00001000b	;look for vbl
	jz	waitvbl2

	loop	waitvbl1

	ret

ENDP


;===========================================================================


	MASM
;อออออออออออออออออออออออออออออออออออออออออออออออออออออออออ
;
; Name:	VideoID
;
; Function:	Detects the presence of various video subsystems
;
; int VideoID;
;
; Subsystem ID values:
; 	 0  = (none)
; 	 1  = MDA
; 	 2  = CGA
; 	 3  = EGA
; 	 4  = MCGA
; 	 5  = VGA
; 	80h = HGC
; 	81h = HGC+
; 	82h = Hercules InColor
;
;อออออออออออออออออออออออออออออออออออออออออออออออออออออออออ

;อออออออออออออออออออออออออออออออออออออออออออออออออออออออออ
;
; Equates
;
;อออออออออออออออออออออออออออออออออออออออออออออออออออออออออ
VIDstruct	STRUC		; corresponds to C data structure

Video0Type	DB	?	; first subsystem type
Display0Type	DB	? 	; display attached to first subsystem

Video1Type	DB	?	; second subsystem type
Display1Type	DB	?	; display attached to second subsystem

VIDstruct	ENDS


Device0	EQU	word ptr Video0Type[di]
Device1	EQU	word ptr Video1Type[di]


MDA	EQU	1	; subsystem types
CGA	EQU	2
EGA	EQU	3
MCGA	EQU	4
VGA	EQU	5
HGC	EQU	80h
HGCPlus	EQU	81h
InColor	EQU	82h

MDADisplay	EQU	1	; display types
CGADisplay	EQU	2
EGAColorDisplay	EQU	3
PS2MonoDisplay	EQU	4
PS2ColorDisplay	EQU	5

TRUE	EQU	1
FALSE	EQU	0

;อออออออออออออออออออออออออออออออออออออออออออออออออออออออออ
;
; Program
;
;อออออออออออออออออออออออออออออออออออออออออออออออออออออออออ

Results	VIDstruct <>	;results go here!

EGADisplays	DB	CGADisplay	; 0000b, 0001b	(EGA switch values)
	DB	EGAColorDisplay	; 0010b, 0011b
	DB	MDADisplay	; 0100b, 0101b
	DB	CGADisplay	; 0110b, 0111b
	DB	EGAColorDisplay	; 1000b, 1001b
	DB	MDADisplay	; 1010b, 1011b

DCCtable	DB	0,0	; translate table for INT 10h func 1Ah
	DB	MDA,MDADisplay
	DB	CGA,CGADisplay
	DB	0,0
	DB	EGA,EGAColorDisplay
	DB	EGA,MDADisplay
	DB	0,0
	DB	VGA,PS2MonoDisplay
	DB	VGA,PS2ColorDisplay
	DB	0,0
	DB	MCGA,EGAColorDisplay
	DB	MCGA,PS2MonoDisplay
	DB	MCGA,PS2ColorDisplay

TestSequence	DB	TRUE	; this list of flags and addresses
	DW	FindPS2	;  determines the order in which this
			;  program looks for the various
EGAflag	DB	?	;  subsystems
	DW	FindEGA

CGAflag	DB	?
	DW	FindCGA

Monoflag	DB	?
	DW	FindMono

NumberOfTests	EQU	($-TestSequence)/3


	PUBLIC	VideoID
VideoID	PROC	near

	push	bp	; preserve caller registers
	mov	bp,sp
	push	ds
	push	si
	push	di

	push	cs
	pop	ds
	ASSUME	DS:@Code

; initialize the data structure that will contain the results

	lea	di,Results	; DS:DI -> start of data structure

	mov	Device0,0	; zero these variables
	mov	Device1,0

; look for the various subsystems using the subroutines whose addresses are
; tabulated in TestSequence; each subroutine sets flags in TestSequence
; to indicate whether subsequent subroutines need to be called

	mov	byte ptr CGAflag,TRUE
	mov	byte ptr EGAflag,TRUE
	mov	byte ptr Monoflag,TRUE

	mov	cx,NumberOfTests
	mov	si,offset TestSequence

@@L01:	lodsb		; AL := flag
	test	al,al
	lodsw		; AX := subroutine address
	jz	@@L02	; skip subroutine if flag is false

	push	si
	push	cx
	call	ax	; call subroutine to detect subsystem
	pop	cx
	pop	si

@@L02:	loop	@@L01

; determine which subsystem is active

	call	FindActive

	mov	al,Results.Video0Type
	mov	ah,0	; was:  Results.Display0Type

	pop	di	; restore caller registers and return
	pop	si
	pop	ds
	mov	sp,bp
	pop	bp
	ret

VideoID	ENDP


;
; FindPS2
;
; This subroutine uses INT 10H function 1Ah to determine the video BIOS
; Display Combination Code (DCC) for each video subsystem present.
;

FindPS2	PROC	near

	mov	ax,1A00h
	int	10h	; call video BIOS for info

	cmp	al,1Ah
	jne	@@L13	; exit if function not supported (i.e.,
			;  no MCGA or VGA in system)

; convert BIOS DCCs into specific subsystems & displays

	mov	cx,bx
	xor	bh,bh	; BX := DCC for active subsystem

	or	ch,ch
	jz	@@L11	; jump if only one subsystem present

	mov	bl,ch	; BX := inactive DCC
	add	bx,bx
	mov	ax,[bx+offset DCCtable]

	mov	Device1,ax

	mov	bl,cl
	xor	bh,bh	; BX := active DCC

@@L11:	add	bx,bx
	mov	ax,[bx+offset DCCtable]

	mov	Device0,ax

; reset flags for subsystems that have been ruled out

	mov	byte ptr CGAflag,FALSE
	mov	byte ptr EGAflag,FALSE
	mov	byte ptr Monoflag,FALSE

	lea	bx,Video0Type[di]  ; if the BIOS reported an MDA ...
	cmp	byte ptr [bx],MDA
	je	@@L12

	lea	bx,Video1Type[di]
	cmp	byte ptr [bx],MDA
	jne	@@L13

@@L12:	mov	word ptr [bx],0    ; ... Hercules can't be ruled out
	mov	byte ptr Monoflag,TRUE

@@L13:	ret

FindPS2	ENDP


;
; FindEGA
;
; Look for an EGA.  This is done by making a call to an EGA BIOS function
;  which doesn't exist in the default (MDA, CGA) BIOS.

FindEGA	PROC	near	; Caller:	AH = flags
			; Returns:	AH = flags
			;		Video0Type and
			;		 Display0Type updated

	mov	bl,10h	; BL := 10h (return EGA info)
	mov	ah,12h	; AH := INT 10H function number
	int	10h	; call EGA BIOS for info
			; if EGA BIOS is present,
			;  BL <> 10H
			;  CL = switch setting
	cmp	bl,10h
	je	@@L22	; jump if EGA BIOS not present

	mov	al,cl
	shr	al,1	; AL := switches/2
	mov	bx,offset EGADisplays
	xlat		; determine display type from switches
	mov	ah,al	; AH := display type
	mov	al,EGA	; AL := subystem type
	call	FoundDevice

	cmp	ah,MDADisplay
	je	@@L21	; jump if EGA has a monochrome display

	mov	CGAflag,FALSE	; no CGA if EGA has color display
	jmp	short @@L22

@@L21:	mov	Monoflag,FALSE	; EGA has a mono display, so MDA and
			;  Hercules are ruled out
@@L22:	ret

FindEGA	ENDP

;
; FindCGA
;
; This is done by looking for the CGA's 6845 CRTC at I/O port 3D4H.
;
FindCGA	PROC	near	; Returns:	VIDstruct updated

	mov	dx,3D4h	; DX := CRTC address port
	call	Find6845
	jc	@@L31	; jump if not present

	mov	al,CGA
	mov	ah,CGADisplay
	call	FoundDevice

@@L31:	ret

FindCGA	ENDP

;
; FindMono
;
; This is done by looking for the MDA's 6845 CRTC at I/O port 3B4H.  If
; a 6845 is found, the subroutine distinguishes between an MDA
; and a Hercules adapter by monitoring bit 7 of the CRT Status byte.
; This bit changes on Hercules adapters but does not change on an MDA.
;
; The various Hercules adapters are identified by bits 4 through 6 of
; the CRT Status value:
;
; 000b = HGC
; 001b = HGC+
; 101b = InColor card
;

FindMono	PROC	near	; Returns:	VIDstruct updated

	mov	dx,3B4h	; DX := CRTC address port
	call	Find6845
	jc	@@L44	; jump if not present

	mov	dl,0BAh	; DX := 3BAh (status port)
	in	al,dx
	and	al,80h
	mov	ah,al	; AH := bit 7 (vertical sync on HGC)

	mov	cx,8000h	; do this 32768 times
@@L41:	in	al,dx
	and	al,80h	; isolate bit 7
	cmp	ah,al
	loope	@@L41	; wait for bit 7 to change
	jne	@@L42	; if bit 7 changed, it's a Hercules

	mov	al,MDA	; if bit 7 didn't change, it's an MDA
	mov	ah,MDADisplay
	call	FoundDevice
	jmp	short @@L44

@@L42:	in	al,dx
	mov	dl,al	; DL := value from status port
	and	dl,01110000b	; mask bits 4 thru 6

	mov	ah,MDADisplay	; assume it's a monochrome display

	mov	al,HGCPlus	; look for an HGC+
	cmp	dl,00010000b
	je	@@L43	; jump if it's an HGC+

	mov	al,HGC	; look for an InColor card or HGC
	cmp	dl,01010000b
	jne	@@L43	; jump if it's not an InColor card

	mov	al,InColor	; it's an InColor card
	mov	ah,EGAColorDisplay

@@L43:	call	FoundDevice

@@L44:	ret

FindMono	ENDP

;
; Find6845
;
; This routine detects the presence of the CRTC on a MDA, CGA or HGC.
; The technique is to write and read register 0Fh of the chip (cursor
; low).  If the same value is read as written, assume the chip is
; present at the specified port addr.
;

Find6845	PROC	near	; Caller:  DX = port addr
			; Returns: cf set if not present
	mov	al,0Fh
	out	dx,al	; select 6845 reg 0Fh (Cursor Low)
	inc	dx
	in	al,dx	; AL := current Cursor Low value
	mov	ah,al	; preserve in AH
	mov	al,66h	; AL := arbitrary value
	out	dx,al	; try to write to 6845

	mov	cx,100h
@@L51:	loop	@@L51	; wait for 6845 to respond

	in	al,dx
	xchg	ah,al	; AH := returned value
			; AL := original value
	out	dx,al	; restore original value

	cmp	ah,66h	; test whether 6845 responded
	je	@@L52	; jump if it did (cf is reset)

	stc		; set carry flag if no 6845 present

@@L52:	ret

Find6845	ENDP


;
; FindActive
;
; This subroutine stores the currently active device as Device0.  The
; current video mode determines which subsystem is active.
;

FindActive	PROC	near

	cmp	word ptr Device1,0
	je	@@L63	; exit if only one subsystem

	cmp	Video0Type[di],4	; exit if MCGA or VGA present
	jge	@@L63	;  (INT 10H function 1AH
	cmp	Video1Type[di],4	;  already did the work)
	jge	@@L63

	mov	ah,0Fh
	int	10h	; AL := current BIOS video mode

	and	al,7
	cmp	al,7	; jump if monochrome
	je	@@L61	;  (mode 7 or 0Fh)

	cmp	Display0Type[di],MDADisplay
	jne	@@L63	; exit if Display0 is color
	jmp	short @@L62

@@L61:	cmp	Display0Type[di],MDADisplay
	je	@@L63	; exit if Display0 is monochrome

@@L62:	mov	ax,Device0	; make Device0 currently active
	xchg	ax,Device1
	mov	Device0,ax

@@L63:	ret

FindActive	ENDP


;
; FoundDevice
;
; This routine updates the list of subsystems.
;

FoundDevice	PROC	near	; Caller:    AH = display #
			;	     AL = subsystem #
			; Destroys:  BX
	lea	bx,Video0Type[di]
	cmp	byte ptr [bx],0
	je	@@L71	; jump if 1st subsystem

	lea	bx,Video1Type[di]	; must be 2nd subsystem

@@L71:	mov	[bx],ax	; update list entry
	ret

FoundDevice	ENDP


END
