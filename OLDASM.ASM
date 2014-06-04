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

;============================================================================
;
; DELTA ENGINE CODE
;
; Call DE_ClearOld to initialize tables
;
; Repeat:
;
;   Call DE_NewFrame to ready the next frame
;   Call DE_AddLine to add line segments to the new frame
;   Call DE_StraightDraw or DE_DeltaDraw to draw the marked lines
;
;============================================================================

IDEAL

MODEL SMALL,C

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

;==================
;
; View area equates
;
;==================

VIEWX		=	(4*8)
VIEWY		=	(4*8)
VIEWWIDTH	=	(32*8)
VIEWHEIGHT	=	(12*8)
VIEWXH		=	(VIEWX+VIEWWIDTH-1)
VIEWYH		=	(VIEWY+VIEWHEIGHT-1)


;=======================
;
; The delta tables hold linked line segments to be drawn
;
;=======================

FARDATA

MAXSEGS =	2000

SG_START =	0
SG_END	=	2
SG_COLOR =	4
SG_NEXT	=	6

SEGSIZE	=	8

deltatable1	db	SEGSIZE*MAXSEGS dup (?)
deltatable2	db	SEGSIZE*MAXSEGS dup (?)
deltatable3	db	SEGSIZE*MAXSEGS dup (?)

startline	dw	0,VIEWX-1,99,redrawline
endline		dw	VIEWXH+1,9999,99,0
blankline	dw	VIEWX,VIEWXH,0,endline
redrawline	dw	VIEWX,VIEWXH,-1,endline

;==========================
;
; dataseg
;
;==========================

DATASEG

freesegment	dw	?	; pointer to next free spot in deltatable?
freestarttable	dw      deltatable1,deltatable2,deltatable3

linestart1	dw	VIEWHEIGHT dup(?)
linestart2	dw	VIEWHEIGHT dup(?)
linestart3	dw	VIEWHEIGHT dup(?)
linestartptr	dw	?	; pointer to linestart[tableon]
linestarttable	dw      linestart1,linestart2,linestart3

tableon		dw	?

PUBLIC	tableon,linestart1,linestart2,linestart3,linestartptr,freesegment

;
; parameters for AddLine
;
al_xl	dw	?
al_xh	dw	?
al_y	dw	?
al_color dw	?

PUBLIC	al_xl,al_xh,al_y,al_color


CODESEG

;====================
;
; DE_AddLine
;
; Adds a new segment to the current line list
; Takes globall variables al_??? as parameters
;
; AX = scratch
; BX = previous segment ptr
; CX = al_xl
; DX = al_xh
; SI = start segment ptr
; DI = new segment ptr
; BP = end segment ptr
;
;====================

PROC	DE_AddLine
PUBLIC	DE_AddLine
USES	si,di,bp

	mov	ax,@FARDATA
	mov	es,ax			; es points to tables

	mov	cx,[al_xl]
	mov	dx,[al_xh]
;
; find the first segment on line al_y that contains the new line
;
	mov	bx,[al_y]
	sub	bx,VIEWY
	shl	bx,1
	add	bx,[linestartptr]
	mov     bx,[bx]			; bx = prev segment
	mov	si,[es:bx+SG_NEXT]	; si = start pointer
@@findfirst:
	cmp	cx,[es:si+SG_END]
	jle	@@gotfirst
	mov	bx,si			; pre = start
	mov	si,[es:si+SG_NEXT]	; start = start->next
	jmp	@@findfirst

@@gotfirst:
	mov	di,[freesegment]	; new = freesegment++
	add	[freesegment],SEGSIZE
	mov	[es:di+SG_START],cx	; new->start = xl
	mov	[es:di+SG_END],dx	; new->end = xh
	mov	ax,[al_color]
	mov	[es:di+SG_COLOR],ax	; new->color = color

	cmp	[es:si+SG_END],dx
	jge	@@isge
	jmp	@@notge
;
; the entire new segment fits inside start seg
; start->end >= xh
;
@@isge:
	cmp	[es:si+SG_COLOR],ax	; ax still holds [al_color]
	jne	@@different
	ret				; same color as old line, do nothing
@@different:
	cmp	[es:si+SG_START],cx	; if (start->start == xl)
	jne	@@notstarteq		; cover first part of old segment
	mov	[es:bx+SG_NEXT],di	; pre->next = new
	cmp	[es:si+SG_END],dx
	jne	@@notexact		; cover it exactly?
	mov	ax,[es:si+SG_NEXT]
	mov	[es:di+SG_NEXT],ax	; new->next = start->next
	ret
@@notexact:
	mov	[es:di+SG_NEXT],si	; new->next = start
	mov	ax,dx
	inc	ax
	mov	[es:si+SG_START],ax	; start->start = xh+1
	ret

@@notstarteq:
	cmp	[es:si+SG_END],dx	; if (start->end == xh)
	jne	@@notendeq		; cover last part of old segment
	mov	ax,[es:si+SG_NEXT]
	mov	[es:di+SG_NEXT],ax	; new->next = start->next
	mov	[es:si+SG_NEXT],di	; start->next = new
	mov	ax,cx
	dec	ax
	mov	[es:si+SG_END],ax	; start->end = xl-1
	ret
@@notendeq:
	mov	bp,[freesegment]	; cover the middle of old segment
	add	[freesegment],SEGSIZE	; end = freesegment++
	mov	ax,dx
	inc	ax
	mov	[es:bp+SG_START],ax	; end->start = xh+1
	mov	ax,[es:si+SG_END]
	mov	[es:bp+SG_END],ax	; end->end = start->end
	mov	ax,[es:si+SG_NEXT]
	mov	[es:bp+SG_NEXT],ax	; end->next = start->next
	mov	ax,[es:si+SG_COLOR]
	mov	[es:bp+SG_COLOR],ax	; end->color = start->color
	mov	ax,cx
	dec	ax
	mov	[es:si+SG_END],ax	; start->end = xl-1
	mov	[es:si+SG_NEXT],di	; start->next = new
	mov	[es:di+SG_NEXT],bp	; new->next = end
	ret
;
;
; partially cover start seg, and scan ahead to cover more
;
@@notge:
	mov	bp,[es:si+SG_NEXT]	; end = start->next
@@findend:
	cmp	[es:bp+SG_END],dx	; while (end->end <= xh_
	jg      @@endfound
	mov	bp,[es:bp+SG_NEXT]	; end = end->next
	jmp	@@findend
@@endfound:
	cmp	[es:bp+SG_END],dx
	je	@@mergeend
	mov	ax,[es:al_color]
	cmp	[es:bp+SG_COLOR],ax
	jne	@@splitend
@@mergeend:			; if (end->end == xh || end->color == color)
	mov	ax,[es:bp+SG_NEXT]
	mov	[es:di+SG_NEXT],ax	; new->next = end->next
	jmp	@@enddone
@@splitend:			; else
	mov	ax,dx
	inc	ax
	mov	[es:bp+SG_START],ax	; end->start = xh+1
	mov	[es:di+SG_NEXT],bp	; new->next = end
@@enddone:
	cmp     [es:si+SG_START],cx
	je	@@mergestart
	mov	ax,[al_color]
	cmp	[es:si+SG_COLOR],ax
	jne	@@splitstart
@@mergestart:
	mov	[es:bx+SG_NEXT],si	; pre->next = new
	ret
@@splitstart:
	mov	ax,cx
	dec	ax
	mov	[es:si+SG_END],ax	; start->end = xl-1
	mov	[es:si+SG_NEXT],di	; start->next = new
	ret
ENDP


;=====================
;
; DE_StraightDraw
;
; Draws ALL line segments in current frame, with no delta work
;
;=====================

DATASEG

yline	dw	?
startptr dw	?
oldstartptr dw	?
newseg	dw	?

CODESEG

EXTRN	DrawLine:PROC


PROC	DE_StraightDraw
PUBLIC	DE_StraightDraw
USES	SI,DI

	mov	dx,GC_INDEX
	mov	ax,GC_MODE + 2*256
	out	dx,ax			; set EGA write mode 2

	mov	ax,@FARDATA
	mov	es,ax			; es points to tables

	mov	ax,[linestartptr]
	mov	[startptr],ax
	mov	[yline],VIEWY		; for (y=VIEWY;y<=VIEWYH;y++)

@@lineloop:
	mov	bx,[startptr]		; pointer to first seg on line
	add	[startptr],2		; point to next line
	mov	bx,[bx]			; point to first pointer
	mov	bx,[es:bx+SG_NEXT]	; first pointer is just junk
@@segmentloop:
	push	es
	push	bx			; save it off

	push	[es:bx+SG_COLOR]
	push	[yline]
	push	[es:bx+SG_END]
	push	[es:bx+SG_START]
	call	DrawLine		; DrawLine(start,end,y,color)
	add	sp,8

	pop	bx			; restore segment pointer
	pop	es

	mov	bx,[es:bx+SG_NEXT]	; next pointer
	cmp	[WORD es:bx+SG_START],VIEWXH
	jle	@@segmentloop		; while (seg->start <= VIEWXH)

	inc	[yline]
	cmp	[yline],VIEWYH
	jle	@@lineloop

	mov	dx,GC_INDEX
	mov	ax,GC_BITMASK+255*256
	out	dx,ax			; no pixel mask

	mov	dx,GC_INDEX
	mov	ax,GC_MODE + 2*256
	out	dx,ax		; set EGA write mode 0

	ret

ENDP



;=====================
;
; DE_DeltaDraw
;
; Draws only the pieces of the line segments needed to change old frame
;
; AX : scratch
; BX : scratch / line color
; CX : start
; DX : end
; SI : current table
; DI : old table
; BP : x
;
;=====================

PROC	DE_DeltaDraw
PUBLIC	DE_DeltaDraw
USES	SI,DI,BP

	mov	dx,GC_INDEX
	mov	ax,GC_MODE + 2*256
	out	dx,ax			; set EGA write mode 2

	mov	ax,@FARDATA
	mov	es,ax			; es points to tables

	mov	si,[tableon]		; figure out old table
	inc	si
	cmp	si,3
	jl	@@gottable
	xor	si,si
@@gottable:
	shl	si,1
	mov	ax,[linestarttable+si]
	mov	[oldstartptr],ax
	mov	ax,[linestartptr]
	mov	[startptr],ax

	mov	[yline],VIEWY		; for (y=VIEWY;y<=VIEWYH;y++)

;
; delta draw one line
;
@@lineloop:
	mov	bx,[startptr]
	mov	si,[bx]			; pointer to first pointer now
	add	bx,2
	mov	[startptr],bx
	mov	si,[es:si+SG_NEXT]	; first pointer is just junk
	mov	bx,[oldstartptr]
	mov	di,[bx]			; pointer to first pointer then
	add	bx,2
	mov	[oldstartptr],bx
	mov	di,[es:di+SG_NEXT]	; first pointer is just junk

	mov	bp,VIEWX		; x = VIEWX

@@segmentloop:
	mov	ax,[es:si+SG_COLOR]
	cmp	ax,[es:di+SG_COLOR]
	je	@@skipsome		; common line color?
;
; draw over some old segments
;
	mov	bx,[es:si+SG_COLOR]
	mov	cx,bp			; start = x
@@checkseg:
	mov	ax,[es:si+SG_END]
	cmp	ax,[es:di+SG_END]		; both end at same place?
	jne	@@notsameend
	mov	dx,ax			; end = newseg->end
	mov	si,[es:si+SG_NEXT]
	mov	di,[es:di+SG_NEXT] 	; bump both new and old
	mov	bp,[es:si+SG_START]	; x = newseg->start
	jmp	@@drawseg

@@notsameend:
	jg	@@newgreater		; new end before old?
	mov	dx,ax			; end = newseg->end
	mov	si,[es:si+SG_NEXT]		; bump si
	mov	bp,[es:si+SG_START]	; x = newseg->start
	jmp	@@drawseg

@@newgreater:
	mov	dx,[es:di+SG_END]		; end = oldseg->end
	mov	di,[es:di+SG_NEXT] 	; bump old
	mov	bp,[es:di+SG_START]	; x = oldseg->start
	cmp	bp,VIEWXH
	jg	@@drawseg		; if at end of line, draw, else
	mov	ax,[es:si+SG_COLOR]     ; if next old is still different
	cmp	ax,[es:di+SG_COLOR]     ; color, keep extending segment
	jne	@@checkseg
;
; Draw a line segment
;
@@drawseg:
	push	es			; drawline will save and restore SI/DI

	push	bx
	push	[yline]
	push	dx
	push	cx
	call	DrawLine		; DrawLine(start,end,y,color)
	add	sp,8

	pop	es

	jmp	@@while

;
; new line is same color as old,
; so skip some drawing
;
@@skipsome:
	mov	ax,[es:si+SG_END]
	cmp	ax,[es:di+SG_END]	; both end at same place?
	jne	@@notsameendsk
	mov	si,[es:si+SG_NEXT]
	mov	di,[es:di+SG_NEXT] 	; bump both new and old
	mov	bp,[es:si+SG_START]	; x = newseg->start
	jmp	@@while

@@notsameendsk:
	jg	@@newgreatersk		; new end before old?
	mov	si,[es:si+SG_NEXT]	; bump si
	mov	bp,[es:si+SG_START]	; x = newseg->start
	jmp	@@while

@@newgreatersk:
	mov	di,[es:di+SG_NEXT] 	; bump old
	mov	bp,[es:di+SG_START]	; x = oldseg->start

;
; is line done ?
;
@@while:
	cmp	bp,VIEWXH
	jg	@@segdone
	jmp	@@segmentloop
@@segdone:

	inc	[yline]
	cmp	[yline],VIEWYH
	jg	@@done
	jmp	@@lineloop

@@done:
;
; all lines are done
;
	mov	dx,GC_INDEX
	mov	ax,GC_BITMASK+255*256
	out	dx,ax			; no pixel mask

	mov	dx,GC_INDEX
	mov	ax,GC_MODE + 2*256
	out	dx,ax		; set EGA write mode 0

	ret


ENDP


;=====================
;
; DE_ClearOld
;
; Resets all frame segments so next two frames are completely drawn
;
; SI = table number clearing * 2
; DI = linestart pointer
;
;=====================

PROC	DE_ClearOld
PUBLIC	DE_ClearOld
USES	SI,DI

	mov	ax,ds
	mov	es,ax

	xor	si,si
@@tableloop:
	mov	di,[linestarttable + si] ; di points to start of pointer table

	mov	ax,OFFSET startline
	mov	cx,VIEWHEIGHT		; for (y=0;y<VIEWHEIGHT;y++)
	rep	stosw			; linestart[tableon][y] = redraw

	inc	si
	inc	si
	cmp	si,6
	jl	@@tableloop

	mov	[tableon],0		; next frame will start on table 1

	ret

ENDP


;=====================
;
; DE_NewFrame
;
; Bumps tableon and set up default values for new frame
;
; di = freesegment pointer
; bx = linestart pointer
;
;=====================

DATASEG

stubline	dw	0,VIEWX-1,99,0, VIEWX,VIEWXH,0,endline

CODESEG

PROC	DE_NewFrame
PUBLIC	DE_NewFrame
USES	si,di

	mov	ax,@FARDATA
	mov	es,ax			; es points to tables

	mov	si,[tableon]
	inc	si
	cmp	si,3
	jl	@@gottable
	xor	si,si
@@gottable:
	mov	[tableon],si
	shl	si,1
	mov	di,[freestarttable+si]	; di = pointer to free segments
	mov	bx,[linestarttable+si]	; bx = pointer to line start list
	mov	[linestartptr],bx

	mov	dx,VIEWHEIGHT		; for (y=viewheight;y>0;y--)
@@yloop:
;
; copy two segments to each line
;
	mov     [bx],di
	inc	bx
	inc	bx			; linestartptr++ = new
	mov	si,OFFSET stubline
	mov	ax,di
	add	ax,SEGSIZE
	mov	[si+SG_NEXT],ax		; patch pointer
	mov	cx,(SEGSIZE*2)/2
	rep	movsw			; copy two new segments

	dec	dx
	jnz	@@yloop

	mov	[freesegment],di

	ret

ENDP


END


