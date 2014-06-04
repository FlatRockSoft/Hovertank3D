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

include "GRAPHHOV.EQU"

;============================================================================
;
;                      EGA Graphic routines
;
;============================================================================

SC_INDEX	=	03C4h
SC_RESET	=	0
SC_CLOCK	=	1
SC_MAPMASK	=	2
SC_CHARMAP	=	3
SC_MEMMODE	=	4

CRTC_INDEX	=	03D4h
CRTC_H_TOTAL	=	0
CRTC_H_DISPEND	=	1
CRTC_H_BLANK	=	2
CRTC_H_ENDBLANK	=	3
CRTC_H_RETRACE	=	4
CRTC_H_ENDRETRACE =	5
CRTC_V_TOTAL	=	6
CRTC_OVERFLOW	=	7
CRTC_ROWSCAN	=	8
CRTC_MAXSCANLINE =	9
CRTC_CURSORSTART =	10
CRTC_CURSOREND	=	11
CRTC_STARTHIGH	=	12
CRTC_STARTLOW	=	13
CRTC_CURSORHIGH	=	14
CRTC_CURSORLOW	=	15
CRTC_V_RETRACE	=	16
CRTC_V_ENDRETRACE =	17
CRTC_V_DISPEND	=	18
CRTC_OFFSET	=	19
CRTC_UNDERLINE	=	20
CRTC_V_BLANK	=	21
CRTC_V_ENDBLANK	=	22
CRTC_MODE	=	23
CRTC_LINECOMPARE =	24


GC_INDEX	=	03CEh
GC_SETRESET	=	0
GC_ENABLESETRESET =	1
GC_COLORCOMPARE	=	2
GC_DATAROTATE	=	3
GC_READMAP	=	4
GC_MODE		=	5
GC_MISCELLANEOUS =	6
GC_COLORDONTCARE =	7
GC_BITMASK	=	8

ATR_INDEX	=	03c0h
ATR_MODE	=	16
ATR_OVERSCAN	=	17
ATR_COLORPLANEENABLE =	18
ATR_PELPAN	=	19
ATR_COLORSELECT	=	20


SCREENWIDTH	equ	40

;
; offsets into sprite/pictable
;
PICWIDTHOFS	equ	0
PICHEIGHTOFS	equ	2


DATASEG

screenseg	dw	0a000h
otherseg	dw	0
screenofs	dw	0
screenorigin	dw	0
planemask	dw	0
planecount	dw	0
linewidth	dw	0

PUBLIC	screenseg,screenofs,screenorigin,otherseg,linewidth

EXTRN	pictable:WORD
EXTRN	spritetable:WORD
EXTRN	grsegs:WORD		; master location table for all graphics

ylookup	dw	256 dup (?)
PUBLIC ylookup

;============================================================================
CODESEG
;============================================================================

MACRO	WORDOUT
	out	dx,al
	inc	dx
	xchg	al,ah
	out	dx,al
	dec	dx
	xchg	al,ah
ENDM


;====================
;
; EGAplane
; Sets read/write mode 0 and selects the given plane (0-3)
; for reading and writing
;
;====================

PROC	EGAplane plane:WORD
	PUBLIC	EGAplane

	cli

	mov	dx,GC_INDEX
	mov	ax,GC_MODE
	WORDOUT			;set read / write mode 0

	mov	dx,GC_INDEX
	mov	al,4		;read map select
	mov	ah,[BYTE plane] ;read from this plane number
	out	dx,ax
	mov	dx,SC_INDEX
	mov	al,SC_MAPMASK
	mov	ah,1
	mov	cl,[BYTE plane]	;write to this plane only
	shl	ah,cl
	WORDOUT

	sti
	ret

ENDP


;==============
;
; SetScreen
;
;==============

;
; EGA registers
;
HPELPAN		equ	20h or 13h

PROC	SetScreen  crtc:WORD, pel:WORD
PUBLIC	SetScreen

;
; set the CRTC start registers for the screen just drawn
;

; wait for no display enable and no vertical sync, so the raster is in a
; horizontal sync, not on the last line!

	cli

	mov	dx,CRTC_INDEX+6
@@waitnovbl:
	in	al,dx
	test	al,00001000b
	jnz	@@waitnovbl	;vertical syncing now
	or	al,1
	jz	@@waitnovbl	;in the middle of a scan line


	mov	cx,[crtc]
	mov	dx,3d4h		;CRTC address register
	mov	al,0ch		;start address high register
	out	dx,al
	inc	dx
	mov	al,ch
	out	dx,al   	;set the high byte
	dec	dx
	mov	al,0dh		;start address low register
	out	dx,al
	inc	dx
	mov	al,cl
	out	dx,al		;set the low byte

	sti

	mov	dx,CRTC_INDEX+6
@@waitvbl:
	in	al,dx
	test	al,00001000b	;look for vertical retrace
	jz	@@waitvbl

;
; set horizontal panning
;
	cli

	mov	bx,[pel]
	mov	dx,CRTC_INDEX+6
	in	al,dx
	mov	dx,ATR_INDEX
	mov	al,HPELPAN
	out	dx,al
	mov	ax,bx		;pel pan value
	out	dx,al

	sti

	ret

ENDP



;=============
;
; XorBar
;
; xcoord in bytes, ycoord in pixels
;
;=============

PROC	XorBar xl:WORD, yl:WORD, wide:WORD, height:WORD
USES	SI,DI
PUBLIC	XorBar

; set write mode 0
	mov	dx,GC_INDEX
	mov	ax,GC_MODE
	WORDOUT

; set xor mode
	mov	ax,GC_DATAROTATE + 11000b * 256
	WORDOUT

	mov	dx,[wide]	;bytes / line
	mov	ch,[BYTE height] ;lines

	mov	bx,[yl]
	shl	bx,1
	mov	di,[ylookup+bx]
	add	di,[screenofs]
	add	di,[xl]

	mov	es,[screenseg]

	mov	ah,0ffh

; ch = vertical loops
; cl = horizontal loops

@@vertloop:
	mov	cl,dl
	xor	bx,bx
@@horizloop:
	mov	al,[es:di+bx]	;load latches
	mov	[es:di+bx],ah	;xor in $ff
	inc	bx

	dec	cl
	jnz	@@horizloop
	add	di,SCREENWIDTH
	dec	ch
	jnz	@@vertloop

; set copy mode
	mov	dx,GC_INDEX
	mov	ax,GC_DATAROTATE
	WORDOUT

; set mapmask to all
	mov	dx,SC_INDEX
	mov	ax,SC_MAPMASK + 15*256
	WORDOUT

	ret
ENDP


;=============
;
; XPlot
;
; Xdraws one point
;
;=============

PROC	XPlot x:WORD, y:WORD, color:WORD
USES	SI,DI
PUBLIC	XPlot

; set write mode 0
	mov	dx,GC_INDEX
	mov	ax,GC_MODE
	WORDOUT

; set xor mode
	mov	ax,GC_DATAROTATE + 11000b * 256
	WORDOUT

; set mapmask to color
	mov	dx,SC_INDEX
	mov	al,SC_MAPMASK
	mov	ah,[BYTE color]
	WORDOUT

; calculate screen location
	mov	bx,[y]
	shl	bx,1
	mov	di,[ylookup+bx]
	add	di,[screenofs]
	mov	ax,[x]
	mov	bx,ax
	shr	bx,1
	shr	bx,1
	shr	bx,1
	add	di,bx		; byte value of x
	and	ax,7
	mov	cx,7
	sub	cx,ax		; bit position
	mov	ax,100h
	shl	ax,cl		; high byte holds mask

; set bitmask to pixel
	mov	dx,GC_INDEX
	mov	al,GC_BITMASK
	WORDOUT

	mov	es,[screenseg]
	mov	al,[es:di]	; load latches
	mov	[BYTE es:di],0ffh	; xor out 1s to active planes/bits

; set copy mode
	mov	dx,GC_INDEX
	mov	ax,GC_DATAROTATE
	WORDOUT

; set mapmask to all
	mov	dx,SC_INDEX
	mov	ax,SC_MAPMASK + 15*256
	WORDOUT

; set bitmask to pixel
	mov	dx,GC_INDEX
	mov	ax,GC_BITMASK + 255*256
	WORDOUT
	ret
ENDP


;=============
;
; DrawChar (int xcoord, int ycoord, int charnum)
;
; xcoord in bytes, ycoord in pixels
;
; Source is grsegs[STARTTILE8+charnum]
;
;=============

PROC	DrawChar xcoord:WORD, ycoord:WORD, charnum:WORD
USES	SI,DI
PUBLIC	DrawChar

	mov	es,[screenseg]

	mov	di,[screenofs]
	add	di,[xcoord]
	mov	bx,[ycoord]
	shl	bx,1
	add	di,[ylookup+bx]	;screen destination

	cld

	mov	bx,[linewidth]
	dec	bx

	mov	si,[charnum]
	shl	si,1
	shl	si,1
	shl	si,1
	shl	si,1
	shl	si,1

	mov	ds,[grsegs+STARTTILE8*2] ; segment for all tile8s


;
; start drawing
;

	cli
	mov	dx,GC_INDEX		;set write mode 0
	mov	ax,GC_MODE
	WORDOUT
	sti

	mov	cx,4		;planes to draw
	mov	[ss:planemask],0001b	;map mask

	mov	bx,6

@@planeloop:
	cli
	mov	dx,SC_INDEX
	mov	al,SC_MAPMASK
	mov	ah,[BYTE ss:planemask]
	shl	[ss:planemask],1
	WORDOUT
	sti
	mov	dx,[ss:linewidth]
	dec	dx
	dec	bx
	dec	bx


	push	di

REPT	7
	movsb
	add	di,dx
ENDM
	movsb

	pop	di

	loop	@@planeloop

	cli
	mov	dx,SC_INDEX
	mov	ax,SC_MAPMASK+15*256	;write to all planes
	WORDOUT
	sti

	mov	ax,ss
	mov	ds,ax		;restore turbo's data segment

	ret

ENDP

;=======================================================================

;============
;
; DrawPic (int xcoord, int ycoord, int picnum)
;
; xcoord in bytes, ycoord in pixels
;
;============

DATASEG

picwidth	dw	?
picxcoord	dw	?
picheight	dw	?

picoffset	dw	?	;offset into data planes

PUBLIC picoffset

CODESEG

PROC	DrawPic xcoord:WORD, ycoord:WORD, picnum:WORD
USES	SI,DI
PUBLIC	DrawPic


	mov	si,[picnum]
	shl	si,1
	shl	si,1

	mov	ax,[pictable+si+PICWIDTHOFS]
	mov	[picwidth],ax
	mov	ax,[pictable+si+PICHEIGHTOFS]
	mov	[picheight],ax

	mov	es,[screenseg]

	mov	di,[screenofs]
	add	di,[xcoord]
	mov	bx,[ycoord]
	shl	bx,1
	add	di,[ylookup+bx]	;screen destination

	cld

;
; start drawing
;

	cli
	mov	dx,GC_INDEX		;set write mode 0
	mov	ax,GC_MODE
	WORDOUT
	sti

	mov	[planecount],3
	mov	[planemask],0001b	;map mask

	mov	si,[picnum]
	shl	si,1
	mov	ds,[grsegs+STARTPICS*2+si]	; segment of pictures (PARA'd)
	xor	si,si			; segment aligned

	mov	bx,6

@@planeloop:
	cli
	mov	dx,SC_INDEX
	mov	al,SC_MAPMASK
	mov	ah,[BYTE ss:planemask]
	shl	[ss:planemask],1
	WORDOUT
	sti
	mov	dx,[ss:linewidth]
	sub	dx,[ss:picwidth]
	mov	bx,[ss:planecount]
	shl	bx,1

	push	di

	mov	bx,[ss:picheight]
@@lineloop:
	mov	cx,[ss:picwidth]
	rep movsb
	add	di,dx

	dec	bx
	jnz	@@lineloop

	pop	di

	dec	[ss:planecount]
	jns	@@planeloop

	cli
	mov	dx,SC_INDEX
	mov	ax,SC_MAPMASK+15*256	;write to all planes
	WORDOUT
	sti

	mov	ax,ss
	mov	ds,ax		;restore turbo's data segment

	ret


	ret

ENDP



;============
;
; Bar (int xl,yl,width,height)
;
; xcoord in bytes, ycoord in pixels
;
;============

PROC	Bar xl:WORD, yl:WORD, wide:WORD, height:WORD, fill:WORD
USES	SI,DI
PUBLIC	Bar

	mov	di,[screenofs]
	mov	bx,[yl]
	shl	bx,1
	add	di,[ylookup+bx]
	add	di,[xl]

	mov	es,[screenseg]

	cld
	cli			;no interrupts during EGA stuff!

	mov	dx,GC_INDEX
	mov	ax,GC_MODE	;write mode 0
	WORDOUT

	mov	dx,SC_INDEX
	mov	ax,SC_MAPMASK+15*256
	WORDOUT

	sti

	mov	bx,[ss:linewidth]
	sub	bx,[wide]
	mov	al,[BYTE fill]
@@drawrow:
	mov	cx,[wide]
	rep	stosb
	add	di,bx
	dec	[height]
	jnz	@@drawrow

	mov	ax,ss
	mov	ds,ax		;restore turbo's data segment

	ret

ENDP



;============
;
; CopyEGA
;
; Must be in latch mode
;
;============

PROC	CopyEGA  wide:WORD, height:WORD, source:word, dest:word
PUBLIC	CopyEGA
USES	SI,DI

	mov	ax,0a000h
	mov	ds,ax
	mov	es,ax
@@zapasprite:
;
; erase a sprite by copying a block from the master screen
;
	mov	ah,[BYTE wide]		;width of block
	mov	bx,[WORD height]	;height of block
	mov	di,[dest]	;destination to erase
	mov	si,[source]

	mov	dx,[ss:linewidth]
	sub	dl,ah
	xor	ch,ch
EVEN
@@clearloop:
	mov	cl,ah
	rep	movsb
	add	si,dx
	add	di,dx
	dec	bx
	jnz	@@clearloop

	mov	ax,ss
	mov	ds,ax		;restore ds

	ret
ENDP



if NUMFONT+NUMFONTM

;===========================================================================
;
;                          SHIFT TABLES
;
;===========================================================================

DATASEG


LABEL shiftdata0 WORD
    dw     0,    1,    2,    3,    4,    5,    6,    7,    8,    9,   10,   11,   12,   13
    dw    14,   15,   16,   17,   18,   19,   20,   21,   22,   23,   24,   25,   26,   27
    dw    28,   29,   30,   31,   32,   33,   34,   35,   36,   37,   38,   39,   40,   41
    dw    42,   43,   44,   45,   46,   47,   48,   49,   50,   51,   52,   53,   54,   55
    dw    56,   57,   58,   59,   60,   61,   62,   63,   64,   65,   66,   67,   68,   69
    dw    70,   71,   72,   73,   74,   75,   76,   77,   78,   79,   80,   81,   82,   83
    dw    84,   85,   86,   87,   88,   89,   90,   91,   92,   93,   94,   95,   96,   97
    dw    98,   99,  100,  101,  102,  103,  104,  105,  106,  107,  108,  109,  110,  111
    dw   112,  113,  114,  115,  116,  117,  118,  119,  120,  121,  122,  123,  124,  125
    dw   126,  127,  128,  129,  130,  131,  132,  133,  134,  135,  136,  137,  138,  139
    dw   140,  141,  142,  143,  144,  145,  146,  147,  148,  149,  150,  151,  152,  153
    dw   154,  155,  156,  157,  158,  159,  160,  161,  162,  163,  164,  165,  166,  167
    dw   168,  169,  170,  171,  172,  173,  174,  175,  176,  177,  178,  179,  180,  181
    dw   182,  183,  184,  185,  186,  187,  188,  189,  190,  191,  192,  193,  194,  195
    dw   196,  197,  198,  199,  200,  201,  202,  203,  204,  205,  206,  207,  208,  209
    dw   210,  211,  212,  213,  214,  215,  216,  217,  218,  219,  220,  221,  222,  223
    dw   224,  225,  226,  227,  228,  229,  230,  231,  232,  233,  234,  235,  236,  237
    dw   238,  239,  240,  241,  242,  243,  244,  245,  246,  247,  248,  249,  250,  251
    dw   252,  253,  254,  255

LABEL shiftdata1 WORD
    dw     0,32768,    1,32769,    2,32770,    3,32771,    4,32772,    5,32773,    6,32774
    dw     7,32775,    8,32776,    9,32777,   10,32778,   11,32779,   12,32780,   13,32781
    dw    14,32782,   15,32783,   16,32784,   17,32785,   18,32786,   19,32787,   20,32788
    dw    21,32789,   22,32790,   23,32791,   24,32792,   25,32793,   26,32794,   27,32795
    dw    28,32796,   29,32797,   30,32798,   31,32799,   32,32800,   33,32801,   34,32802
    dw    35,32803,   36,32804,   37,32805,   38,32806,   39,32807,   40,32808,   41,32809
    dw    42,32810,   43,32811,   44,32812,   45,32813,   46,32814,   47,32815,   48,32816
    dw    49,32817,   50,32818,   51,32819,   52,32820,   53,32821,   54,32822,   55,32823
    dw    56,32824,   57,32825,   58,32826,   59,32827,   60,32828,   61,32829,   62,32830
    dw    63,32831,   64,32832,   65,32833,   66,32834,   67,32835,   68,32836,   69,32837
    dw    70,32838,   71,32839,   72,32840,   73,32841,   74,32842,   75,32843,   76,32844
    dw    77,32845,   78,32846,   79,32847,   80,32848,   81,32849,   82,32850,   83,32851
    dw    84,32852,   85,32853,   86,32854,   87,32855,   88,32856,   89,32857,   90,32858
    dw    91,32859,   92,32860,   93,32861,   94,32862,   95,32863,   96,32864,   97,32865
    dw    98,32866,   99,32867,  100,32868,  101,32869,  102,32870,  103,32871,  104,32872
    dw   105,32873,  106,32874,  107,32875,  108,32876,  109,32877,  110,32878,  111,32879
    dw   112,32880,  113,32881,  114,32882,  115,32883,  116,32884,  117,32885,  118,32886
    dw   119,32887,  120,32888,  121,32889,  122,32890,  123,32891,  124,32892,  125,32893
    dw   126,32894,  127,32895

LABEL shiftdata2 WORD
    dw     0,16384,32768,49152,    1,16385,32769,49153,    2,16386,32770,49154,    3,16387
    dw 32771,49155,    4,16388,32772,49156,    5,16389,32773,49157,    6,16390,32774,49158
    dw     7,16391,32775,49159,    8,16392,32776,49160,    9,16393,32777,49161,   10,16394
    dw 32778,49162,   11,16395,32779,49163,   12,16396,32780,49164,   13,16397,32781,49165
    dw    14,16398,32782,49166,   15,16399,32783,49167,   16,16400,32784,49168,   17,16401
    dw 32785,49169,   18,16402,32786,49170,   19,16403,32787,49171,   20,16404,32788,49172
    dw    21,16405,32789,49173,   22,16406,32790,49174,   23,16407,32791,49175,   24,16408
    dw 32792,49176,   25,16409,32793,49177,   26,16410,32794,49178,   27,16411,32795,49179
    dw    28,16412,32796,49180,   29,16413,32797,49181,   30,16414,32798,49182,   31,16415
    dw 32799,49183,   32,16416,32800,49184,   33,16417,32801,49185,   34,16418,32802,49186
    dw    35,16419,32803,49187,   36,16420,32804,49188,   37,16421,32805,49189,   38,16422
    dw 32806,49190,   39,16423,32807,49191,   40,16424,32808,49192,   41,16425,32809,49193
    dw    42,16426,32810,49194,   43,16427,32811,49195,   44,16428,32812,49196,   45,16429
    dw 32813,49197,   46,16430,32814,49198,   47,16431,32815,49199,   48,16432,32816,49200
    dw    49,16433,32817,49201,   50,16434,32818,49202,   51,16435,32819,49203,   52,16436
    dw 32820,49204,   53,16437,32821,49205,   54,16438,32822,49206,   55,16439,32823,49207
    dw    56,16440,32824,49208,   57,16441,32825,49209,   58,16442,32826,49210,   59,16443
    dw 32827,49211,   60,16444,32828,49212,   61,16445,32829,49213,   62,16446,32830,49214
    dw    63,16447,32831,49215

LABEL shiftdata3 WORD
    dw     0, 8192,16384,24576,32768,40960,49152,57344,    1, 8193,16385,24577,32769,40961
    dw 49153,57345,    2, 8194,16386,24578,32770,40962,49154,57346,    3, 8195,16387,24579
    dw 32771,40963,49155,57347,    4, 8196,16388,24580,32772,40964,49156,57348,    5, 8197
    dw 16389,24581,32773,40965,49157,57349,    6, 8198,16390,24582,32774,40966,49158,57350
    dw     7, 8199,16391,24583,32775,40967,49159,57351,    8, 8200,16392,24584,32776,40968
    dw 49160,57352,    9, 8201,16393,24585,32777,40969,49161,57353,   10, 8202,16394,24586
    dw 32778,40970,49162,57354,   11, 8203,16395,24587,32779,40971,49163,57355,   12, 8204
    dw 16396,24588,32780,40972,49164,57356,   13, 8205,16397,24589,32781,40973,49165,57357
    dw    14, 8206,16398,24590,32782,40974,49166,57358,   15, 8207,16399,24591,32783,40975
    dw 49167,57359,   16, 8208,16400,24592,32784,40976,49168,57360,   17, 8209,16401,24593
    dw 32785,40977,49169,57361,   18, 8210,16402,24594,32786,40978,49170,57362,   19, 8211
    dw 16403,24595,32787,40979,49171,57363,   20, 8212,16404,24596,32788,40980,49172,57364
    dw    21, 8213,16405,24597,32789,40981,49173,57365,   22, 8214,16406,24598,32790,40982
    dw 49174,57366,   23, 8215,16407,24599,32791,40983,49175,57367,   24, 8216,16408,24600
    dw 32792,40984,49176,57368,   25, 8217,16409,24601,32793,40985,49177,57369,   26, 8218
    dw 16410,24602,32794,40986,49178,57370,   27, 8219,16411,24603,32795,40987,49179,57371
    dw    28, 8220,16412,24604,32796,40988,49180,57372,   29, 8221,16413,24605,32797,40989
    dw 49181,57373,   30, 8222,16414,24606,32798,40990,49182,57374,   31, 8223,16415,24607
    dw 32799,40991,49183,57375

LABEL shiftdata4 WORD
    dw     0, 4096, 8192,12288,16384,20480,24576,28672,32768,36864,40960,45056,49152,53248
    dw 57344,61440,    1, 4097, 8193,12289,16385,20481,24577,28673,32769,36865,40961,45057
    dw 49153,53249,57345,61441,    2, 4098, 8194,12290,16386,20482,24578,28674,32770,36866
    dw 40962,45058,49154,53250,57346,61442,    3, 4099, 8195,12291,16387,20483,24579,28675
    dw 32771,36867,40963,45059,49155,53251,57347,61443,    4, 4100, 8196,12292,16388,20484
    dw 24580,28676,32772,36868,40964,45060,49156,53252,57348,61444,    5, 4101, 8197,12293
    dw 16389,20485,24581,28677,32773,36869,40965,45061,49157,53253,57349,61445,    6, 4102
    dw  8198,12294,16390,20486,24582,28678,32774,36870,40966,45062,49158,53254,57350,61446
    dw     7, 4103, 8199,12295,16391,20487,24583,28679,32775,36871,40967,45063,49159,53255
    dw 57351,61447,    8, 4104, 8200,12296,16392,20488,24584,28680,32776,36872,40968,45064
    dw 49160,53256,57352,61448,    9, 4105, 8201,12297,16393,20489,24585,28681,32777,36873
    dw 40969,45065,49161,53257,57353,61449,   10, 4106, 8202,12298,16394,20490,24586,28682
    dw 32778,36874,40970,45066,49162,53258,57354,61450,   11, 4107, 8203,12299,16395,20491
    dw 24587,28683,32779,36875,40971,45067,49163,53259,57355,61451,   12, 4108, 8204,12300
    dw 16396,20492,24588,28684,32780,36876,40972,45068,49164,53260,57356,61452,   13, 4109
    dw  8205,12301,16397,20493,24589,28685,32781,36877,40973,45069,49165,53261,57357,61453
    dw    14, 4110, 8206,12302,16398,20494,24590,28686,32782,36878,40974,45070,49166,53262
    dw 57358,61454,   15, 4111, 8207,12303,16399,20495,24591,28687,32783,36879,40975,45071
    dw 49167,53263,57359,61455

LABEL shiftdata5 WORD
    dw     0, 2048, 4096, 6144, 8192,10240,12288,14336,16384,18432,20480,22528,24576,26624
    dw 28672,30720,32768,34816,36864,38912,40960,43008,45056,47104,49152,51200,53248,55296
    dw 57344,59392,61440,63488,    1, 2049, 4097, 6145, 8193,10241,12289,14337,16385,18433
    dw 20481,22529,24577,26625,28673,30721,32769,34817,36865,38913,40961,43009,45057,47105
    dw 49153,51201,53249,55297,57345,59393,61441,63489,    2, 2050, 4098, 6146, 8194,10242
    dw 12290,14338,16386,18434,20482,22530,24578,26626,28674,30722,32770,34818,36866,38914
    dw 40962,43010,45058,47106,49154,51202,53250,55298,57346,59394,61442,63490,    3, 2051
    dw  4099, 6147, 8195,10243,12291,14339,16387,18435,20483,22531,24579,26627,28675,30723
    dw 32771,34819,36867,38915,40963,43011,45059,47107,49155,51203,53251,55299,57347,59395
    dw 61443,63491,    4, 2052, 4100, 6148, 8196,10244,12292,14340,16388,18436,20484,22532
    dw 24580,26628,28676,30724,32772,34820,36868,38916,40964,43012,45060,47108,49156,51204
    dw 53252,55300,57348,59396,61444,63492,    5, 2053, 4101, 6149, 8197,10245,12293,14341
    dw 16389,18437,20485,22533,24581,26629,28677,30725,32773,34821,36869,38917,40965,43013
    dw 45061,47109,49157,51205,53253,55301,57349,59397,61445,63493,    6, 2054, 4102, 6150
    dw  8198,10246,12294,14342,16390,18438,20486,22534,24582,26630,28678,30726,32774,34822
    dw 36870,38918,40966,43014,45062,47110,49158,51206,53254,55302,57350,59398,61446,63494
    dw     7, 2055, 4103, 6151, 8199,10247,12295,14343,16391,18439,20487,22535,24583,26631
    dw 28679,30727,32775,34823,36871,38919,40967,43015,45063,47111,49159,51207,53255,55303
    dw 57351,59399,61447,63495

LABEL shiftdata6 WORD
    dw     0, 1024, 2048, 3072, 4096, 5120, 6144, 7168, 8192, 9216,10240,11264,12288,13312
    dw 14336,15360,16384,17408,18432,19456,20480,21504,22528,23552,24576,25600,26624,27648
    dw 28672,29696,30720,31744,32768,33792,34816,35840,36864,37888,38912,39936,40960,41984
    dw 43008,44032,45056,46080,47104,48128,49152,50176,51200,52224,53248,54272,55296,56320
    dw 57344,58368,59392,60416,61440,62464,63488,64512,    1, 1025, 2049, 3073, 4097, 5121
    dw  6145, 7169, 8193, 9217,10241,11265,12289,13313,14337,15361,16385,17409,18433,19457
    dw 20481,21505,22529,23553,24577,25601,26625,27649,28673,29697,30721,31745,32769,33793
    dw 34817,35841,36865,37889,38913,39937,40961,41985,43009,44033,45057,46081,47105,48129
    dw 49153,50177,51201,52225,53249,54273,55297,56321,57345,58369,59393,60417,61441,62465
    dw 63489,64513,    2, 1026, 2050, 3074, 4098, 5122, 6146, 7170, 8194, 9218,10242,11266
    dw 12290,13314,14338,15362,16386,17410,18434,19458,20482,21506,22530,23554,24578,25602
    dw 26626,27650,28674,29698,30722,31746,32770,33794,34818,35842,36866,37890,38914,39938
    dw 40962,41986,43010,44034,45058,46082,47106,48130,49154,50178,51202,52226,53250,54274
    dw 55298,56322,57346,58370,59394,60418,61442,62466,63490,64514,    3, 1027, 2051, 3075
    dw  4099, 5123, 6147, 7171, 8195, 9219,10243,11267,12291,13315,14339,15363,16387,17411
    dw 18435,19459,20483,21507,22531,23555,24579,25603,26627,27651,28675,29699,30723,31747
    dw 32771,33795,34819,35843,36867,37891,38915,39939,40963,41987,43011,44035,45059,46083
    dw 47107,48131,49155,50179,51203,52227,53251,54275,55299,56323,57347,58371,59395,60419
    dw 61443,62467,63491,64515

LABEL shiftdata7 WORD
    dw     0,  512, 1024, 1536, 2048, 2560, 3072, 3584, 4096, 4608, 5120, 5632, 6144, 6656
    dw  7168, 7680, 8192, 8704, 9216, 9728,10240,10752,11264,11776,12288,12800,13312,13824
    dw 14336,14848,15360,15872,16384,16896,17408,17920,18432,18944,19456,19968,20480,20992
    dw 21504,22016,22528,23040,23552,24064,24576,25088,25600,26112,26624,27136,27648,28160
    dw 28672,29184,29696,30208,30720,31232,31744,32256,32768,33280,33792,34304,34816,35328
    dw 35840,36352,36864,37376,37888,38400,38912,39424,39936,40448,40960,41472,41984,42496
    dw 43008,43520,44032,44544,45056,45568,46080,46592,47104,47616,48128,48640,49152,49664
    dw 50176,50688,51200,51712,52224,52736,53248,53760,54272,54784,55296,55808,56320,56832
    dw 57344,57856,58368,58880,59392,59904,60416,60928,61440,61952,62464,62976,63488,64000
    dw 64512,65024,    1,  513, 1025, 1537, 2049, 2561, 3073, 3585, 4097, 4609, 5121, 5633
    dw  6145, 6657, 7169, 7681, 8193, 8705, 9217, 9729,10241,10753,11265,11777,12289,12801
    dw 13313,13825,14337,14849,15361,15873,16385,16897,17409,17921,18433,18945,19457,19969
    dw 20481,20993,21505,22017,22529,23041,23553,24065,24577,25089,25601,26113,26625,27137
    dw 27649,28161,28673,29185,29697,30209,30721,31233,31745,32257,32769,33281,33793,34305
    dw 34817,35329,35841,36353,36865,37377,37889,38401,38913,39425,39937,40449,40961,41473
    dw 41985,42497,43009,43521,44033,44545,45057,45569,46081,46593,47105,47617,48129,48641
    dw 49153,49665,50177,50689,51201,51713,52225,52737,53249,53761,54273,54785,55297,55809
    dw 56321,56833,57345,57857,58369,58881,59393,59905,60417,60929,61441,61953,62465,62977
    dw 63489,64001,64513,65025


shifttabletable	dw	shiftdata0,shiftdata1,shiftdata2,shiftdata3
		dw	shiftdata4,shiftdata5,shiftdata6,shiftdata7

shiftdrawtable	dw      egafont1,egafont1,egafont2,egafont3

fontcolor	dw	15		;0-16 mapmask value
px		dw	0
py		dw	0
pdrawmode	dw	11000b
fontseg		dw	?

PUBLIC	fontcolor,px,py,pdrawmode,fontseg

pcharheight	equ	0		;lines high
charloc		equ	2		;address of every character
charwidth	equ     514		;width in pixels


; temporary variables, to be optimised out later

sourceptr	dw	0
destptr		dw	0
shiftptr	dw	0
drawptr		dw	0

egaxor		dw	0

CODESEG


;==================
;
; DrawPchar
; Draws a proportional character at px,py, and increments px
;
;==================

PROC	DrawPchar	charnum:WORD
PUBLIC	DrawPchar
USES	si,di

; set write mode 0
	mov	dx,GC_INDEX
	mov	ax,GC_MODE
	WORDOUT

; set xor mode
	mov	al,GC_DATAROTATE
	mov	ah,[BYTE pdrawmode]
	WORDOUT

; set mapmask to color
	mov	dx,SC_INDEX
	mov	al,SC_MAPMASK
	mov	ah,[BYTE fontcolor]
	WORDOUT

	mov	es,[fontseg]	;font segment

;
; calculate destination on screen
;
	mov	bx,[py]
	shl	bx,1
	mov	di,[ylookup+bx]
	add	di,[screenofs]

	mov	bx,[px]
	mov	ax,bx
	shr	ax,1
	shr	ax,1
	shr	ax,1		;x location in bytes
	add	di,ax
	mov	[destptr],di	; DI holds destination <<<<<========

;
; look up which shift table to use, based on x coordinate
;
	and	bx,7		;low bits of x location
	shl	bx,1
	mov	ax,[shifttabletable+bx]
	mov	[shiftptr],ax	;<<<<<<=========

;
; find character location, width, and height
;
	mov	bx,[charnum]	;move source for pic into bx
	mov	si,[es:charwidth+bx]
	and	si,0ffh
	shl	bx,1
	mov	ax,[es:charloc+bx]
	mov	[sourceptr],ax	;<<<<<<=========

	add	[px],si	;move the location for the next drawing
	add	si,7
	shr	si,1
	shr	si,1
	shr	si,1

; advance past mask for or only
	mov	ax,si
	mov	dx,[es:pcharheight]
	mul	dl
	add	[sourceptr],ax
;

	shl	si,1   		;bytes wide
	mov	ax,[shiftdrawtable+si]	;procedure to draw this width
	mov	[drawptr],ax	;<<<<<<=========

; xor in data
	mov	bx,[sourceptr]
	mov	bp,[shiftptr]
	mov	cx,[es:pcharheight]
	mov	es,[screenseg]
	mov	ds,[fontseg]
	call	[ss:drawptr]

; set copy mode
	mov	dx,GC_INDEX
	mov	ax,GC_DATAROTATE
	WORDOUT

; set mapmask to all
	mov	dx,SC_INDEX
	mov	ax,SC_MAPMASK + 15*256
	WORDOUT

	mov	ax,ss
	mov	ds,ax
	ret

ENDP

; ax scratch
; bx source location
; cx height counter
; dx xor value
; si byte value*2, to look up in scale table
; di screen location
; bp scale table to use
;
; ds source segment
; es screenseg
; ss table segment


MACRO	SHIFTXOR
	mov	al,[bx]			;source data
	xor	ah,ah
	shl	ax,1
	mov	si,ax

	mov	al,[es:di]		;load latches
	mov	ax,[bp+si]              ;shift into two bytes
	xor	ax,dx
	stosb				;write latches
	mov	al,[es:di]		;load latches
	mov	[es:di],ah		;write latches
	inc	bx
ENDM

MACRO	SHIFTNOXOR
	mov	al,[bx]			;source data
	xor	ah,ah
	shl	ax,1
	mov	si,ax

	mov	al,[es:di]		;load latches
	mov	ax,[bp+si]              ;shift into two bytes
	stosb				;write latches
	mov	al,[es:di]		;load latches
	mov	[es:di],ah		;write latches
	inc	bx
ENDM


EVEN
egafont1:	; draw a font that is 1 byte wide
	mov	dx,[ss:linewidth]
	dec	dx
EVEN
@@loop1:
	SHIFTNOXOR
	add	di,dx
	loop	@@loop1
	ret


EVEN
egafont2:	; draw a font that is 2 byte wide
	mov	dx,[ss:linewidth]
	dec	dx
	dec	dx
EVEN
@@loop2:
	SHIFTNOXOR
	SHIFTNOXOR

	add	di,dx
	loop	@@loop2
	ret


EVEN
egafont3:	; draw a font that is 3 byte wide
	mov	dx,[ss:linewidth]
	dec	dx
	dec	dx
EVEN
@@loop3:
	SHIFTNOXOR
	SHIFTNOXOR
	SHIFTNOXOR

	add	di,dx
	loop	egafont3
	ret


endif		; if fonts

;===========================================================================
;
;                    SCALING GRAPHICS
;
;===========================================================================



MACRO	MAKELAB NUM

lab&NUM:

ENDM

MACRO	MAKEREF NUM

dw OFFSET lab&NUM

ENDM


;=========================================================================

MAXSCALES equ 256

	DATASEG

LABEL endtable WORD
labcount = 0
REPT MAXSCALES
MAKEREF %labcount
labcount = labcount + 1
ENDM


	CODESEG

;==================================================
;
; void scaleline (int scale, unsigned picseg, unsigned maskseg,
;                 unsigned screen, unsigned width)
;
;==================================================

PROC	ScaleLine pixels:word, scaleptr:dword, picptr:dword, screen:word
USES	si,di
PUBLIC	ScaleLine

;
; modify doline procedure for proper width
;
	mov    	bx,[pixels]
	cmp	bx,MAXSCALES
	jbe	@@scaleok
	mov     bx,MAXSCALES
@@scaleok:
	shl	bx,1
	mov	bx,[endtable+bx]
	push	[cs:bx]			;save the code that will be modified over
	mov	[WORD cs:bx],0d18eh	;mov ss,cx
	push	[cs:bx+2]		;save the code that will be modified over
	mov	[WORD cs:bx+2],90c3h	;ret / nop
	push	bx

	mov	dx,[linewidth]

	mov	di,[WORD screen]
	mov	es,[screenseg]

	mov	si,[WORD scaleptr]
	mov	ds,[WORD scaleptr+2]

	mov	bx,[WORD picptr]
	mov	ax,[WORD picptr+2]	;will be moved into ss after call

	mov	bp,bx

	cli
	call	doline
	sti
;
; restore doline to regular state
;
	pop	bx		;address of modified code
	pop     [cs:bx+2]
	pop     [cs:bx]

	mov	ax,ss
	mov	ds,ax
	ret

;================
;
; doline
;
; Big unwound scaling routine
;
; ds:si = scale table
; ss:bx = pic data
; es:di = screen location
;
;================

doline:

	mov	cx,ss
	mov	ss,ax		;can't call a routine with ss used...

labcount = 0

REPT MAXSCALES

MAKELAB %labcount
labcount = labcount + 1

	lodsb			; get scaled pixel number
	xlat	[ss:bx]		; look it up in the picture
	xchg	[es:di],al	; load latches and write pixel to screen
	add	di,dx		; down to next line

ENDM

	mov	ss,cx
	ret

ENDP

;===========================================================================
;
; SPRITE routines
;
;===========================================================================

if NUMSPRITES

;============
;
; DrawSprite
;
; Source is a (void _seg *) to the sprite
;
; Must be in write mode 0
;
;============

DATASEG

EGAdraws	dw	BadSize,EGAone,EGAtwo,EGAthree,EGAfour,EGAfive,EGAsix
		dw	EGAseven,EGAeight,EGAnine,EGAten
		dw	10 dup (BadSize)
EGAdrawsOdd	dw	BadSize,EGAone,EGAtwoOdd,EGAthreeOdd,EGAfourOdd
		dw	EGAfiveOdd,EGAsixOdd,EGAsevenOdd,EGAeightOdd
		dw	EGAnineOdd,EGAtenOdd
		dw	10 dup (BadSize)

spriteroutine 	dw 	?

blocksize	dw	?
blockheight	dw	?
blockdest	dw	?

CODESEG

PROC	DrawSpriteT wide:WORD, height:WORD, source:WORD, dest:WORD, plsize:WORD
USES	SI,DI
PUBLIC	DrawSpriteT

	mov	ax,[dest]
	mov	[blockdest],ax
	mov	ax,[height]
	mov	[blockheight],ax
	mov	ax,[plsize]
	mov	[blocksize],ax
	mov	bx,ax
	shl	bx,1
	shl	bx,1			;mask is four planes from first byte

	mov	si,[wide]
	mov	dx,[linewidth]
	sub	dx,si			;dx is delta to next line (move to bp)

	shl	si,1
	mov	di,[dest]
	test	di,1
	jz	@@evens
	mov	ax,[EGAdrawsOdd+si]
	jmp	@@gotit
@@evens:
	mov	ax,[EGAdraws+si]
@@gotit:
	mov	[spriteroutine],ax

	mov	es,[screenseg]
	mov	ds,[source]
	mov	bp,dx
	xor	si,si

;=================
;
; AX: scratch
; BX: offset to mask
; CX: height
; DX: scratch
; SI: source in sprite
; DI: screen
; BP: delta to next line
; DS: sprite
; ES: screen
; SS: stack
;
;=================

;
; draw plane 0
;
	mov	dx,SC_INDEX
	mov	ax,1*256+SC_MAPMASK
	WORDOUT
	add	dx,GC_INDEX-SC_INDEX
	mov	ax,0*256+GC_READMAP
	WORDOUT
	mov	cx,[ss:blockheight]
	mov	di,[ss:blockdest]
	call	[ss: spriteroutine]		;draw the plane's data

;
; draw plane 1
;
	mov	dx,SC_INDEX
	mov	ax,2*256+SC_MAPMASK
	WORDOUT
	add	dx,GC_INDEX-SC_INDEX
	mov	ax,1*256+GC_READMAP
	WORDOUT
	sub	bx,[ss:blocksize]
	mov	cx,[ss:blockheight]
	mov	di,[ss:blockdest]
	call	[ss:spriteroutine]		;draw the plane's data

;
; draw plane 2
;
	mov	dx,SC_INDEX
	mov	ax,4*256+SC_MAPMASK
	WORDOUT
	add	dx,GC_INDEX-SC_INDEX
	mov	ax,2*256+GC_READMAP
	WORDOUT
	sub	bx,[ss:blocksize]
	mov	cx,[ss:blockheight]
	mov	di,[ss:blockdest]
	call	[ss:spriteroutine]		;draw the plane's data

;
; draw plane 3
;
	mov	dx,SC_INDEX
	mov	ax,8*256+SC_MAPMASK
	WORDOUT
	add	dx,GC_INDEX-SC_INDEX
	mov	ax,3*256+GC_READMAP
	WORDOUT
	sub	bx,[ss:blocksize]
	mov	cx,[ss:blockheight]
	mov	di,[ss:blockdest]
	call	[ss:spriteroutine]		;draw the plane's data

	mov	ax,ss
	mov	ds,ax

	ret

ENDP

;=================
PROC	BadSize

	mov	ax,@Data
	mov	ds,ax
	mov	ss,ax
	ret
ENDP

;===========================================================================
;
; sprite macros
;
;===========================================================================

MACRO	MASKBYTE
	mov	dl,[es:di]   		;background
	and	dl,[si+bx]		;mask
	lodsb				;data
	or	al,dl
	stosb				;screen
ENDM

MACRO	MASKWORD
	mov	dx,[es:di]   		;background
	and	dx,[si+bx]		;mask
	lodsw        			;data
	or	ax,dx
	stosw				;screen
ENDM

;=================
;
; AX: scratch
; BX: offset to mask
; CX: height
; DX: scratch
; SI: source in sprite
; DI: screen
; BP: delta to next line
; DS: sprite
; ES: screen
; SS: stack
;
;=================


;===========================================================================
;
; even shifts
;
;===========================================================================


EVEN
PROC	EGAone
	MASKBYTE
	add     di,bp
	loop	EGAone
	ret
ENDP

;=================

EVEN
PROC	EGAtwo
	MASKWORD
	add     di,bp
	loop	EGAtwo
	ret
ENDP

;=================

EVEN
PROC	EGAthree
	MASKWORD
	MASKBYTE
	add     di,bp
	loop	EGAthree
	ret
ENDP

;=================

EVEN
PROC	EGAfour
	MASKWORD
	MASKWORD
	add     di,bp
	loop	EGAfour
	ret
ENDP

;=================

EVEN
PROC	EGAfive
	MASKWORD
	MASKWORD
	MASKBYTE
	add     di,bp
	loop	EGAfive
	ret
ENDP

;=================

EVEN
PROC	EGAsix
	MASKWORD
	MASKWORD
	MASKWORD
	add     di,bp
	loop	EGAsix
	ret
ENDP

;=================

EVEN
PROC	EGAseven
	MASKWORD
	MASKWORD
	MASKWORD
	MASKBYTE
	add     di,bp
	loop	EGAseven
	ret
ENDP

;=================

EVEN
PROC	EGAeight
	MASKWORD
	MASKWORD
	MASKWORD
	MASKWORD
	add     di,bp
	loop	EGAeight
	ret
ENDP

;=================

EVEN
PROC	EGAnine
	MASKWORD
	MASKWORD
	MASKWORD
	MASKWORD
	MASKBYTE
	add     di,bp
	loop	EGAnine
	ret
ENDP

;=================

EVEN
PROC	EGAten
	MASKWORD
	MASKWORD
	MASKWORD
	MASKWORD
	MASKWORD
	add     di,bp
	loop	EGAten
	ret
ENDP


;===========================================================================
;
; odd shifts
;
;===========================================================================


EVEN
PROC	EGAoneOdd
	MASKBYTE
	add     di,bp
	loop	EGAoneOdd
	ret
ENDP

;=================

EVEN
PROC	EGAtwoOdd
	MASKBYTE
	MASKBYTE
	add     di,bp
	loop	EGAtwoOdd
	ret
ENDP

;=================

EVEN
PROC	EGAthreeOdd
	MASKBYTE
	MASKWORD
	add     di,bp
	loop	EGAthreeOdd
	ret
ENDP

;=================

EVEN
PROC	EGAfourOdd
	MASKBYTE
	MASKWORD
	MASKBYTE
	add     di,bp
	loop	EGAfourOdd
	ret
ENDP

;=================

EVEN
PROC	EGAfiveOdd
	MASKBYTE
	MASKWORD
	MASKWORD
	add     di,bp
	loop	EGAfiveOdd
	ret
ENDP

;=================

EVEN
PROC	EGAsixOdd
	MASKBYTE
	MASKWORD
	MASKWORD
	MASKBYTE
	add     di,bp
	loop	EGAsixOdd
	ret
ENDP

;=================

EVEN
PROC	EGAsevenOdd
	MASKBYTE
	MASKWORD
	MASKWORD
	MASKWORD
	add     di,bp
	loop	EGAsevenOdd
	ret
ENDP

;=================

EVEN
PROC	EGAeightOdd
	MASKBYTE
	MASKWORD
	MASKWORD
	MASKWORD
	MASKBYTE
	add     di,bp
	loop	EGAeightOdd
	ret
ENDP

;=================

EVEN
PROC	EGAnineOdd
	MASKBYTE
	MASKWORD
	MASKWORD
	MASKWORD
	MASKWORD
	add     di,bp
	loop	EGAnineOdd
	ret
ENDP

;=================

EVEN
PROC	EGAtenOdd
	MASKBYTE
	MASKWORD
	MASKWORD
	MASKWORD
	MASKWORD
	MASKBYTE
	add     di,bp
	loop	EGAtenOdd
	ret
ENDP


endif		; if numsprites

END