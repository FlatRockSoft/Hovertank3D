/* Hovertank 3-D Source Code
 * Copyright (C) 1993-2014 Flat Rock Software
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with this program; if not, write to the Free Software Foundation, Inc.,
 * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
 */

#include "HOVERDEF.H"

/*
=============================================================================

		  Id Software EGA scaling routines

		      by John Carmack, 4-16-91

		      ------------------------


These routines implement SPARSE SCALING, a very fast way to draw a given
shape at various sizes.

SC_Setup
--------
Builds tables used by the drawing routines to select which pixels to draw
at different scales.  A scale of 256 is regular size, 128 half size, 512
double size, etc.  Usually you won't need exact precision in scaling, so
some tables are used for a few scales.  Basetables convert from a given
pixel offset on the original shape to pixels on the scaled shape, screentables
convert from a scaled offset to the original offset.

SC_MakeShape
------------
Converts a standard four plane pic or sprite of the given width/height to
sparse scaling format.  The pixels are converted from four individual bits
to segments of byte values (0-15).  Pixels of BACKGROUND color are considered
masks, and will not apear in the scaled shape.  By considering the shape
as a list of vertical line segments no masking is needed, as only visable
pixels are scaled.

SC_ScaleShape
-------------
Draws the shape CENTERED at the given x,y at the given scale, clipped to
scalexl,scalexh,scaleyl,scaleyh (inclusive).  The drawing is done vertically
so the bit mask register need only be set once for each line.

SC_ScaleLine (ASM)
------------
Low level scaling routine to scale a given source of byte values (0-15) to
a given point on the screen.  No bounds checking.  This is self modifying
unwound code (coding purists go hide), with a string of 200 scaling
operations that get a RET stuck in the code after the number of pixels
that need to be scaled have been.


DEPENDENCIES
------------


LIMITATIONS
-----------
Shapes must never scale over MAXHEIGHT pixels high, or the scale tables are
invalid.  Greater than 256 character height is impossible without major
changes in any case.

The clipping bounds must be between 0 and 320 horizontally or the byte/mask
tables are invalid.

The segmented scaling isn't perfect


POSSIBLE IMPROVEMENTS
---------------------
256 color VGA scaling can be done over twice as fast as 16 color EGA
because the pixels can be written out without having to load the latches!
Sparsing the shape with horizontal scans would also make an improvement.

SCALESTEP probably shouldn't be linear, as size change perception varies
with the original size

Seperate horizontal/vertical scaling for stretching effects

vertical clipping

Bitmap holography... (coming soon!)

=============================================================================
*/

#define MAXPICHEIGHT	256	// tallest pic to be scaled
#define BACKGROUND	5 	// background pixel for make shape

#define BASESCALE	64	// normal size
#define MAXSCALE	256	// largest scale possible
#define SCALESTEP	3
#define DISCREETSCALES	(MAXSCALE/SCALESTEP)



typedef struct scseg
{
  int		start;		// relative to top of shape
  int		length;		// pixels in this segment
  unsigned	next;		// offset from segment, NULL if last segment
  char		data[];		// pixel values
} scaleseg;

typedef struct
{
  int 		width;		// number of vertical lines
  int		height;		// only used for centering
  unsigned	first[];	// offsets from segment to topmost segment on
				// each line, NULL if no pixels on line
} scaleshape;


#define SCREENPIXELS	320

unsigned char bytetable[SCREENPIXELS],masktable[SCREENPIXELS];

memptr	basetableseg,screentableseg;	// segment of basetables and screentables
unsigned basetables[DISCREETSCALES],	// offsets in basetableseg
	screentables[DISCREETSCALES];	// offsets in screentableseg

int	 	scalexl = 0,
		scalexh = 319,
		scaleyl = 0,
		scaleyh = 144;

unsigned	scaleblockwidth,
		scaleblockheight,
		scaleblockdest;

//==========================================================================

/*
===========================
=
= SC_Setup
=
===========================
*/

void SC_Setup (void)
{
  unsigned mask,i,step,scale,space;
  unsigned char far *baseptr, far *screenptr;
  unsigned offset1,offset2,size;

  //
  // fast ploting tables
  //
  mask = 128;
  for (i=0;i<320;i++)
  {
    bytetable[i]=i/8;
    masktable[i]=mask;
    if (!(mask>>=1))
      mask = 128;
  }

  //
  // fast scaling tables
  //

  offset1 = offset2 = 0;

  for (step=0;step<DISCREETSCALES;step++)
  {
    screentables [step] = offset1;
    scale = (step+1)*SCALESTEP;
    size = scale*MAXPICHEIGHT/BASESCALE;
    offset1 += size+1;
    basetables [step] = offset2;
    offset2 += MAXPICHEIGHT;
  }

  MMGetPtr(&basetableseg,offset2);
  MMGetPtr(&screentableseg,offset1);

  for (step=0;step<DISCREETSCALES;step++)
  {
    baseptr = (unsigned char _seg *)basetableseg + basetables[step];
    screenptr = (unsigned char _seg *)screentableseg + screentables[step];

    scale = (step+1)*SCALESTEP;
    size = scale*MAXPICHEIGHT/BASESCALE;

    for (i=0;i<MAXPICHEIGHT;i++)
      *baseptr++ = scale*i/BASESCALE;			// basetable

    for (i=0;i<=size;i++)
      *screenptr++ = i*BASESCALE/scale;			// screentable
  }

}

//==========================================================================

/*
===========================
=
= MakeShape
=
= Takes a raw bit map of width bytes by height and creates a scaleable shape
=
= Returns the length of the shape in bytes
=
===========================
*/


void SC_MakeShape (memptr src,int width,int height, memptr *shapeseg)
{
  int pixwidth,x,y;

//
// bit plane to byte vars
//
  unsigned char far *plane0,far *plane1,far *plane2,far *plane3;
  unsigned char by0,by1,by2,by3;
  unsigned b,offset,color,shift;

//
// sparse convert vars
//
  int hitpixel,start,length;
  unsigned far *segptr;
  char far *saveptr;
  char far *byteptr, far *dataptr;
  memptr byteseg;
  scaleshape _seg *tempseg;


  pixwidth = width*8;

  MMGetPtr(&(memptr)tempseg,pixwidth*(height+20));	// larger than needed buffer

  tempseg->width = pixwidth;	// pixel dimensions
  tempseg->height = height;

//
// convert ega pixels to byte color values in a temp buffer
//
// Stored in a collumn format, not rows!
//
  MMGetPtr(&byteseg,pixwidth*height);

  byteptr = (char far *)byteseg;

  plane0 = src;
  plane1 = plane0 + width*height;
  plane2 = plane1 + width*height;
  plane3 = plane2 + width*height;

  for (x=0;x<width;x++)
    for (b=0;b<8;b++)
    {
      shift=8-b;
      offset = x;

      for (y=0;y<height;y++)
      {
	by0 = *(plane0+offset);
	by1 = *(plane1+offset);
	by2 = *(plane2+offset);
	by3 = *(plane3+offset);
	offset+=width;

	color = 0;
	asm	mov	cl,[BYTE PTR shift]
	asm	mov	al,[BYTE PTR by3]
	asm	rcr	al,cl;
	asm	rcl	[BYTE PTR color],1;

	asm	mov	cl,[BYTE PTR shift]
	asm	mov	al,[BYTE PTR by2]
	asm	rcr	al,cl;
	asm	rcl	[BYTE PTR color],1;

	asm	mov	cl,[BYTE PTR shift]
	asm	mov	al,[BYTE PTR by1]
	asm	rcr	al,cl;
	asm	rcl	[BYTE PTR color],1;

	asm	mov	cl,[BYTE PTR shift]
	asm	mov	al,[BYTE PTR by0]
	asm	rcr	al,cl;
	asm	rcl	[BYTE PTR color],1;

	*byteptr++ = color;
      }				// Y

    }				// B / X

//
// convert byte map to sparse scaling format
//
  saveptr = (char far *)&tempseg->first[pixwidth];
  // start filling in data after all pointers to line segments

  byteptr = byteseg;			// first pixel in byte array

  for (x=0;x<pixwidth;x++)
  {
//
// each vertical line can have 0 or more segments of pixels in it
//
    y= 0;
    segptr = (unsigned far *)&tempseg->first[x];
    *segptr = 0;			// in case there are no segments on line
    do
    {
      // scan for first pixel to be scaled
      while (*byteptr == BACKGROUND && y<height)
      {
	byteptr++;
	y++;
      }
      if (y==height)			// if not, the line is finished
	continue;

//
// start a segment by pointing the last link (either shape.first[x] if it
// is the first segment, or a seg.next if not) to the current spot in
// the tempseg, setting segptr to this segments next link, and copying
// all the pixels in the segment
//
      *segptr = FP_OFF(saveptr);	// pointer to start of this segment

      start = y;
      length = 0;

      dataptr = &((scaleseg far *)saveptr)->data[0];

      //
      // copy bytes in the segment to the shape
      //
      while (*byteptr != BACKGROUND && y<height)
      {
	length++;
	*dataptr++ = *byteptr++;
	y++;
      }
      ((scaleseg far *)saveptr)->start = start;
      ((scaleseg far *)saveptr)->length = length;
      ((scaleseg far *)saveptr)->next = 0;
      // get ready for next segment
      segptr = (unsigned far *)&((scaleseg far *)saveptr)->next;
      saveptr = dataptr;		// next free byte to be used

    } while (y<height);

  }

//
// allocate exact space needed and copy shape to it, then free buffers
//

  MMGetPtr (shapeseg,FP_OFF(saveptr));
  _fmemcpy (*shapeseg,tempseg,FP_OFF(saveptr));
  MMFreePtr (&byteseg);
  MMFreePtr (&(memptr)tempseg);
}


//==========================================================================


/*
====================
=
= SC_ScaleShape
=
= Scales the shape centered on x,y to size scale (256=1:1, 512=2:1, etc)
=
= Clips to scalexl/scalexh, scaleyl/scaleyh
= Returns true if something was drawn
=
= Must be called in write mode 2!
=
====================
*/
int SC_ScaleShape (int x,int y,unsigned scale, memptr shape)
{
  int scalechop;
  unsigned fullwidth,fullheight,scalewidth,scaleheight;
  int xl,xh,yl,yh,sx,sy,sxl,sxh,syl,syh;
  unsigned screencorner,screen,yoffset,shapeofs,xbyte,mask;
  int shapex,i,blockx,blocky;
  scaleseg far *shapeptr;
  unsigned char far *basetoscreenptr, far *screentobaseptr;
  unsigned char far *masterptr;

  scalechop = scale/SCALESTEP - 1;

  if (scalechop<0)
    return 0;		// can't scale this size

  if (scalechop>=DISCREETSCALES)
    scalechop = DISCREETSCALES-1;

  basetoscreenptr = (unsigned char _seg *)basetableseg + basetables[scalechop];
  screentobaseptr = (unsigned char _seg *)screentableseg + screentables[scalechop];


//
// figure bounding rectangle for scaled image
//
  fullwidth = ((scaleshape _seg *)shape)->width;
  fullheight = ((scaleshape _seg *)shape)->height;

  scalewidth = fullwidth*((scalechop+1)*SCALESTEP)/BASESCALE; //basetoscreenptr[fullwidth-1];
  scaleheight = basetoscreenptr[fullheight-1];

  xl=x-scalewidth/2;
  xh=xl+scalewidth-1;
  yl=y-scaleheight/2;
  yh=yl+scaleheight-1;


// off screen?

  if (xl>scalexh || xh<scalexl || yl>scaleyh || yh<scaleyl)
    return 0;

//
// clip to sides of screen
//
  if (xl<scalexl)
    sxl=scalexl;
  else
    sxl=xl;
  if (xh>scalexh)
    sxh=scalexh;
  else
    sxh=xh;

//
// clip both sides to zbuffer
//
  sx=sxl;
  while (zbuffer[sx]>scale && sx<=sxh)
    sx++;
  sxl=sx;

  sx=sxh;
  while (zbuffer[sx]>scale && sx>sxl)
    sx--;
  sxh=sx;

  if (sxl>sxh)
    return 0;   		// behind a wall

//
// save block info for background erasing
//
  screencorner = screenofs+yl*linewidth;

  scaleblockdest = screencorner + sxl/8;
  scaleblockwidth = sxh/8-sxl/8+1;
  scaleblockheight = yh-yl+1;


//
// start drawing
//


  for (sx=sxl;sx<=sxh;sx++)
  {
    shapex=screentobaseptr[sx-xl];

    if ( (shapeofs = ((scaleshape _seg *)shape)->first[shapex]) != 0)
    {
      xbyte = bytetable[sx];
      mask = masktable[sx];
      if (scale>BASESCALE)
      {
      //
      // make a multiple pixel scale pass if possible
      //
	while ( ( (sx&7) != 7) && (screentobaseptr[sx+1-xl] == shapex) )
	{
	  sx++;
	  mask |= masktable[sx];
	}
      }

      //
      // set bit mask
      //
asm	mov	ah,[BYTE PTR mask]
asm	mov	al,GC_BITMASK
asm	mov	dx,GC_INDEX
asm	out	dx,ax

      do
      {
	shapeptr=MK_FP(FP_SEG(shape),shapeofs);
	yoffset=basetoscreenptr[shapeptr->start];// pixels on screen to be skipped
	screen=screencorner+ylookup[yoffset]+xbyte;

	ScaleLine
	  (basetoscreenptr[shapeptr->length],
	  screentobaseptr,
	  &shapeptr->data[0],
	  screen);

	shapeofs = shapeptr->next;
      } while (shapeofs);
    }
  }

  return 1;
}



