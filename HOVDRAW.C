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
#pragma hdrstop

long bytecount,endcount;		// for profiling

/*
============================================================================

		       3 - D  DEFINITIONS

============================================================================
*/

fixed tileglobal = TILEGLOBAL;
fixed focallength = FOCALLENGTH;
fixed mindist = MINDIST;
int viewheight = VIEWHEIGHT;
fixed scale;


tilept	tile,lasttile,		// tile of wall being followed
	focal,			// focal point in tiles
	left,mid,right;		// rightmost tile in view

globpt edge,view;

int	segstart[VIEWHEIGHT],	// addline tracks line segment and draws
	segend[VIEWHEIGHT],
	segcolor[VIEWHEIGHT];	// only when the color changes


#define ADDLINE(a,b,y,c)						\
{									\
  if (a>segend[y]+1)							\
  {                                                                     \
    if (y>CENTERY)                                                      \
      DrawLine(segend[y]+1,a-1,y,8);					\
    else                                                                \
      DrawLine(segend[y]+1,a-1,y,0);					\
  }									\
  DrawLine(a,a,y,0);							\
  if (a+1<=b)								\
    DrawLine(a+1,b,y,c);						\
  segend[y]=b;								\
}


#define MAXWALLS	100
#define	MIDWALL		(MAXWALLS/2)

walltype	walls[MAXWALLS],*leftwall,*rightwall;


//==========================================================================

//
// refresh stuff
//

//
// calculate location of screens in video memory so they have the
// maximum possible distance seperating them (for scaling overflow)
//

#define EXTRALINES	(0x10000l/SCREENWIDTH-STATUSLINES-VIEWHEIGHT*3)

unsigned screenloc[3]=
{
  ((STATUSLINES+EXTRALINES/4)*SCREENWIDTH)&0xff00,
  ((STATUSLINES+EXTRALINES/2+VIEWHEIGHT)*SCREENWIDTH)&0xff00,
  ((STATUSLINES+3*EXTRALINES/4+2*VIEWHEIGHT)*SCREENWIDTH)&0xff00
};

int screenpage,tics;

long lasttimecount;

#define SHIFTFRAMES	256
int yshift[SHIFTFRAMES];	// screen sliding variables
unsigned slideofs;

//
// rendering stuff
//

int firstangle,lastangle;

fixed prestep;

fixed sintable[ANGLES+ANGLES/4],*costable = sintable+(ANGLES/4);

fixed	viewx,viewy;			// the focal point
int	viewangle;
fixed	viewsin,viewcos;

int	zbuffer[VIEWXH+1];	// holds the height of the wall at that point

//==========================================================================

void	DrawLine (int xl, int xh, int y,int color);
void	DrawWall (walltype *wallptr);
void	TraceRay (unsigned angle);
fixed	FixedByFrac (fixed a, fixed b);
fixed	FixedAdd (fixed a, fixed b);
fixed	TransformX (fixed gx, fixed gy);
int	FollowTrace (fixed tracex, fixed tracey, long deltax, long deltay, int max);
int	BackTrace (int finish);
void	ForwardTrace (void);
int	TurnClockwise (void);
int	TurnCounterClockwise (void);
void	FollowWall (void);

void	NewScene (void);
void	BuildTables (void);

//==========================================================================


/*
==================
=
= DrawLine
=
= Must be in write mode 2 with all planes enabled
= The bit mask is left set to the end value, so clear it after all lines are
= drawn
=
==================
*/

unsigned char leftmask[8] = {0xff,0x7f,0x3f,0x1f,0xf,7,3,1};
unsigned char rightmask[8] = {0x80,0xc0,0xe0,0xf0,0xf8,0xfc,0xfe,0xff};

void DrawLine (int xl, int xh, int y,int color)
{
  unsigned dest,xlb,xhb,maskleft,maskright,mid;

  xlb=xl/8;
  xhb=xh/8;

  if (xh<xl)
    Quit("DrawLine: xh<xl");
  if (y<VIEWY)
    Quit("DrawLine: y<VIEWY");
  if (y>VIEWYH)
    Quit("DrawLine: y>VIEWYH");

  maskleft = leftmask[xl&7];
  maskright = rightmask[xh&7];

  mid = xhb-xlb-1;
  dest = screenofs+ylookup[y]+xlb;

  if (xlb==xhb)
  {
  //
  // entire line is in one byte
  //

    maskleft&=maskright;

    asm	mov	es,[screenseg]
    asm	mov	di,[dest]
    asm	mov	dx,GC_INDEX

    asm	mov	al,GC_BITMASK
    asm	mov	ah,[BYTE PTR maskleft]
    asm	out	dx,ax		// mask off pixels

    asm	mov	al,[BYTE PTR color]
    asm	xchg	al,[es:di]	// load latches and write pixels

    return;
  }

asm	mov	es,[screenseg]
asm	mov	di,[dest]
asm	mov	dx,GC_INDEX
asm	mov	bh,[BYTE PTR color]

//
// draw left side
//
asm	mov	al,GC_BITMASK
asm	mov	ah,[BYTE PTR maskleft]
asm	out	dx,ax		// mask off pixels

asm	mov	al,bh
asm	mov	bl,[es:di]	// load latches
asm	stosb

//
// draw middle
//
asm	mov	ax,GC_BITMASK + 255*256
asm	out	dx,ax		// no masking

asm	mov	al,bh
asm	mov	cx,[mid]
asm	rep	stosb

//
// draw right side
//
asm	mov	al,GC_BITMASK
asm	mov	ah,[BYTE PTR maskright]
asm	out	dx,ax		// mask off pixels

asm	xchg	bh,[es:di]	// load latches and write pixels

}

//==========================================================================


/*
===================
=
= DrawWall
=
= Special polygon with vertical edges and symetrical top / bottom
= Clips horizontally to clipleft/clipright
= Clips vertically to VIEWY/VIEWYH
= Should only be called if the wall is at least partially visable
=
==================
*/

void DrawWall (walltype *wallptr)
{
  walltype 	static wall;
  int 		static	y1l,y1h,y2l,y2h;

  int		i;
  unsigned	leftheight,rightheight;
  long		height,heightstep;


  int temp,insight,x,y,slope,endfrac,end;
  int start,ysteps,left,right;


  wall = *wallptr;
  i = wall.height1/2;
  y1l = CENTERY-i;
  y1h = CENTERY+i;
  i = wall.height2/2;
  y2l = CENTERY-i;
  y2h = CENTERY+i;

  if (wall.x1>wall.leftclip)
    wall.leftclip = wall.x1;
  if (wall.x2<wall.rightclip)
    wall.rightclip = wall.x2;

//
// fill in the zbuffer
//
  height = (long)wall.height1<<16;
  if (wall.x2 != wall.x1)
    heightstep = ((long)(wall.height2-wall.height1)<<16)/(int)(wall.x2-wall.x1);
  else
    heightstep = 0;

  i = wall.leftclip-wall.x1;
  if (i)
    height += heightstep*i;		// adjust for clipped area

  for (x=wall.leftclip;x<=wall.rightclip;x++)
  {
    zbuffer[x] = height>>16;
    height+=heightstep;
  }

//
// draw the wall to the line buffer
//

  if (y1l==y2l)
  {
  //
  // rectangle, no slope
  //
    if (y1l<VIEWY)
      y1l=VIEWY;
    if (y1h>VIEWYH)
      y1h=VIEWYH;
    for (y=y1l;y<=y1h;y++)
      ADDLINE(wall.leftclip,wall.rightclip,y,wall.color);
    return;
  }



  if (y1l<y2l)
  {
  //
  // slopes down to the right
  //
    slope = ((long)(wall.x2-wall.x1)<<6)/(y2l-y1l);	// in 128ths

    ysteps = y2l-y1l;
    if (y1l<VIEWY)
      ysteps -= VIEWY-y1l;
    endfrac = wall.x2<<6;
    for (y=1;y<ysteps;y++)	// top and bottom slopes
    {
      endfrac-=slope;
      end=endfrac>>6;
      if (end>wall.rightclip)
	end=wall.rightclip;
      else
	if (end<wall.leftclip)	// the rest is hidden
	  break;

      ADDLINE(wall.leftclip,end,y2l-y,wall.color);
      ADDLINE(wall.leftclip,end,y2h+y,wall.color);
    }
    if (y2l<VIEWY)
      y2l=VIEWY;
    if (y2h>VIEWYH)
      y2h=VIEWYH;
    for (y=y2l;y<=y2h;y++)	// middle
      ADDLINE(wall.leftclip,wall.rightclip,y,wall.color);
  }
  else
  {
  //
  // slopes down to the left
  //
    slope = ((long)(wall.x2-wall.x1)<<6)/(y1l-y2l);	// in 128ths

    ysteps = y1l-y2l;
    if (y2l<VIEWY)
      ysteps -= VIEWY-y2l;
    endfrac = wall.x1<<6;
    for (y=1;y<ysteps;y++)	// top and bottom slopes
    {
      endfrac+=slope;
      end=endfrac>>6;
      if (end<wall.leftclip)
	end=wall.leftclip;
      else
       if (end>wall.rightclip)	// the rest is hidden
	 break;

      ADDLINE(end,wall.rightclip,y1l-y,wall.color);
      ADDLINE(end,wall.rightclip,y1h+y,wall.color);
    }
    if (y1l<VIEWY)
      y1l=VIEWY;
    if (y1h>VIEWYH)
      y1h=VIEWYH;
    for (y=y1l;y<=y1h;y++)	// middle
      ADDLINE(wall.leftclip,wall.rightclip,y,wall.color);

  }

}



//==========================================================================


/*
=================
=
= TraceRay
=
= Used to find the left and rightmost tile in the view area to be traced from
= Follows a ray of the given angle from viewx,viewy in the global map until
= it hits a solid tile
= sets:
=   tile.x,tile.y	: tile coordinates of contacted tile
=   tilecolor	: solid tile's color
=
==================
*/

int tilecolor;

void TraceRay (unsigned angle)
{
  long tracex,tracey,tracexstep,traceystep,searchx,searchy;
  fixed fixtemp;
  int otx,oty,searchsteps;

  tracexstep = costable[angle];
  traceystep = sintable[angle];

//
// advance point so it is even with the view plane before we start checking
//
  fixtemp = FixedByFrac(prestep,tracexstep);
  tracex = FixedAdd (viewx,fixtemp);
  fixtemp = FixedByFrac(prestep,traceystep);
  tracey = FixedAdd (viewy,fixtemp^SIGNBIT);

  if (tracexstep&SIGNBIT)	// use 2's complement, not signed magnitude
    tracexstep = -(tracexstep&~SIGNBIT);

  if (traceystep&SIGNBIT)	// use 2's complement, not signed magnitude
    traceystep = -(traceystep&~SIGNBIT);

  tile.x = tracex>>TILESHIFT;	// starting point in tiles
  tile.y = tracey>>TILESHIFT;

//
// we assume viewx,viewy is not inside a solid tile, so go ahead one step
//


  do	// until a solid tile is hit
  {
    otx = tile.x;
    oty = tile.y;
    tracex += tracexstep;
    tracey -= traceystep;
    tile.x = tracex>>TILESHIFT;
    tile.y = tracey>>TILESHIFT;

    if (tile.x!=otx && tile.y!=oty && (tilemap[otx][tile.y] || tilemap[tile.x][oty]) )
    {
      //
      // trace crossed two solid tiles, so do a binary search along the line
      // to find a spot where only one tile edge is crossed
      //
      searchsteps = 0;
      searchx = tracexstep;
      searchy = traceystep;
      do
      {
	searchx/=2;
	searchy/=2;
	if (tile.x!=otx && tile.y!=oty)
	{
	 // still too far
	  tracex -= searchx;
	  tracey += searchy;
	}
	else
	{
	 // not far enough, no tiles crossed
	  tracex += searchx;
	  tracey -= searchy;
	}

	//
	// if it is REAL close, go for the most clockwise intersection
	//
	if (++searchsteps == 16)
	{
	  tracex = (long)otx<<TILESHIFT;
	  tracey = (long)oty<<TILESHIFT;
	  if (tracexstep>0)
	  {
	    if (traceystep<0)
	    {
	      tracex += TILEGLOBAL-1;
	      tracey += TILEGLOBAL;
	    }
	    else
	    {
	      tracex += TILEGLOBAL;
	    }
	  }
	  else
	  {
	    if (traceystep<0)
	    {
	      tracex --;
	      tracey += TILEGLOBAL-1;
	    }
	    else
	    {
	      tracey --;
	    }
	  }
	}

	tile.x = tracex>>TILESHIFT;
	tile.y = tracey>>TILESHIFT;

      } while (( tile.x!=otx && tile.y!=oty) || (tile.x==otx && tile.y==oty) );
    }
  } while (!(tilecolor = tilemap[tile.x][tile.y]) );

}

//==========================================================================


/*
========================
=
= FixedByFrac
=
= multiply a 16/16 bit fixed point number by a 16 bit fractional number
= both unsigned (handle signs seperately)
=
========================
*/


fixed FixedByFrac (fixed a, fixed b)
{
  fixed value;

asm	mov	si,[WORD PTR a+2]
asm	xor	si,[WORD PTR b+2]
asm	and	si,0x8000		// si is high word of result (sign bit)

asm	mov	bx,[WORD PTR b]
asm	mov	ax,[WORD PTR a]
asm	mul	bx			// fraction*fraction
asm	mov	di,dx			// di is low word of result
asm	mov	ax,[WORD PTR a+2]
asm	and	ax,0x7fff		// strip sign bit
asm	mul	bx			// units*fraction
asm     add	ax,di
asm	adc	dx,0
asm	or	dx,si

asm	mov	[WORD PTR value],ax
asm	mov	[WORD PTR value+2],dx

  return value;
}


/*
=========================
=
= FixedAdd
=
= add two 16 bit fixed point numbers
= to subtract, invert the sign of B before invoking
=
=========================
*/

fixed FixedAdd (fixed a, fixed b)
{
  fixed value;

asm	mov	ax,[WORD PTR a]
asm	mov	dx,[WORD PTR a+2]

asm	mov	bx,[WORD PTR b]
asm	mov	cx,[WORD PTR b+2]

asm	or	dx,dx
asm	jns	aok:		// negative?
asm	and	dx,0x7fff
asm	not	ax		// convert a from signed magnitude to 2's compl
asm	not	dx
asm	add	ax,1
asm	adc	dx,0
aok:

asm	or	cx,cx
asm	jns	bok:		// negative?
asm	and	cx,0x7fff
asm	not	bx		// convert b from signed magnitude to 2's compl
asm	not	cx
asm	add	bx,1
asm	adc	cx,0
bok:

asm	add	ax,bx		// perform the addition
asm	adc	dx,cx
asm	jns	done

asm	and	dx,0x7fff	// value was negative
asm	not	ax		// back to signed magnitude
asm	not	dx
asm	add	ax,1
asm	adc	dx,0

done:

asm	mov	[WORD PTR value],ax
asm	mov	[WORD PTR value+2],dx

  return value;
}

//==========================================================================


/*
========================
=
= TransformPoint
=
= Takes paramaters:
=   gx,gy		: globalx/globaly of point
=
= globals:
=   viewx,viewy		: point of view
=   viewcos,viewsin	: sin/cos of viewangle
=
=
= defines:
=   CENTERX		: pixel location of center of view window
=   TILEGLOBAL		: size of one
=   FOCALLENGTH		: distance behind viewx/y for center of projection
=   scale		: conversion from global value to screen value
=
= returns:
=   screenx,screenheight: projected edge location and size
=
========================
*/

#define MINRATIO	16

void TransformPoint (fixed gx, fixed gy, int *screenx, unsigned *screenheight)
{
  int ratio;
  fixed gxt,gyt,nx,ny;

//
// translate point to view centered coordinates
//
  gx = FixedAdd(gx,viewx|SIGNBIT);
  gy = FixedAdd(gy,viewy|SIGNBIT);

//
// calculate newx
//
  gxt = FixedByFrac(gx,viewcos);
  gyt = FixedByFrac(gy,viewsin);
  nx = FixedAdd(gxt,gyt^SIGNBIT);

//
// calculate newy
//
  gxt = FixedByFrac(gx,viewsin);
  gyt = FixedByFrac(gy,viewcos);
  ny = FixedAdd(gyt,gxt);

//
// calculate perspective ratio
//
  if (nx<0)
    nx = 0;

  ratio = nx*scale/FOCALLENGTH;

  if (ratio<=MINRATIO)
    ratio = MINRATIO;

  if (ny & SIGNBIT)
    *screenx = CENTERX - (ny&~SIGNBIT)/ratio;
  else
    *screenx = CENTERX + ny/ratio;

  *screenheight = TILEGLOBAL/ratio;

}

//==========================================================================

fixed TransformX (fixed gx, fixed gy)
{
  int ratio;
  fixed gxt,gyt,nx,ny;

//
// translate point to view centered coordinates
//
  gx = FixedAdd(gx,viewx|SIGNBIT);
  gy = FixedAdd(gy,viewy|SIGNBIT);

//
// calculate newx
//
  gxt = FixedByFrac(gx,viewcos);
  gyt = FixedByFrac(gy,viewsin);
  return FixedAdd(gxt,gyt^SIGNBIT);
}

//==========================================================================

/*
==================
=
= BuildTables
=
= Calculates:
=
= scale			projection constant
= sintable/costable	overlapping fractional tables
= firstangle/lastangle	angles from focalpoint to left/right view edges
= prestep		distance from focal point before checking for tiles
= yshift[]		screen bouncing patters
=
==================
*/
#define PI	3.141592657
#define ANGLEQUAD	(ANGLES/4)
void BuildTables (void)
{
  int i,intang;
  float angle,anglestep;
  fixed value;

//
// calculate scale value so one tile at mindist allmost fills the view vertical
//
  scale = GLOBAL1/VIEWWIDTH;	// GLOBALVIEWHEIGHT/viewheight;
  scale *= focallength;
  scale /= (focallength+mindist);

//
// costable overlays sintable with a quarter phase shift
// ANGLES is assumed to be divisable by four
//

  angle = 0;
  anglestep = PI/2/ANGLEQUAD;
  for (i=0;i<=ANGLEQUAD;i++)
  {
    value=GLOBAL1*sin(angle);
    sintable[i]=
      sintable[i+ANGLES]=
      sintable[ANGLES/2-i] = value;
    sintable[ANGLES-i]=
      sintable[ANGLES/2+i] = value | SIGNBIT;
    angle += anglestep;
  }

//
// figure trace angles for first and last pixel on screen
//
  angle = atan((float)VIEWWIDTH/2*scale/FOCALLENGTH);
  angle *= ANGLES/(PI*2);

  intang = (int)angle+1;
  firstangle = intang;
  lastangle = -intang;

  prestep = GLOBAL1*((float)FOCALLENGTH/costable[firstangle]);

//
// hover screen shifting
//
  for (i=0;i<SHIFTFRAMES;i++)
  {
    angle = (long)ANGLES*i/SHIFTFRAMES;
    value = FixedByFrac(7*GLOBAL1,sintable[angle]);
    yshift[i] = SCREENWIDTH*(FixedAdd(value,8*GLOBAL1)>>16);
  }

//
// misc stuff
//
  walls[0].x2 = VIEWX-1;
  walls[0].height2 = 32000;
}


//==========================================================================

/*
=================
=
= StartView
=
= Called by player think
=
=================
*/

void StartView (void)
{
  int tracedir;

//
// set up variables for this view
//
  viewangle = objlist[0].angle;
  viewsin = sintable[viewangle];
  viewcos = costable[viewangle];
  viewx = FixedAdd( objlist[0].x,FixedByFrac(FOCALLENGTH,viewcos)^SIGNBIT  );
  viewy = FixedAdd( objlist[0].y,FixedByFrac(FOCALLENGTH,viewsin) );

  focal.x = viewx>>TILESHIFT;
  focal.y = viewy>>TILESHIFT;

//
// find the rightmost visable tile in view
//
  tracedir = viewangle + lastangle;
  if (tracedir<0)
    tracedir+=ANGLES;
  else if (tracedir>=ANGLES)
    tracedir-=ANGLES;
  TraceRay( tracedir );
  right.x = tile.x;
  right.y = tile.y;

//
// find the leftmost visable tile in view
//
  tracedir = viewangle + firstangle;
  if (tracedir<0)
    tracedir+=ANGLES;
  else if (tracedir>=ANGLES)
    tracedir-=ANGLES;
  TraceRay( tracedir );

//
// follow the walls from there to the right
//
  rightwall = &walls[1];

  FollowWalls ();
}

//==========================================================================

/*
=====================
=
= DrawWallList
=
= Clips and draws all the walls traced this refresh
=
=====================
*/

void DrawWallList (void)
{
  int i,leftx,newleft,rightclip;
  walltype *wall, *check;

  memset(segstart,0,sizeof(segstart));		// start lines at 0
  memset(segend,0xff,sizeof(segend));		// end lines at -1
  memset(segcolor,0xff,sizeof(segcolor));	// with color -1

  rightwall->x1 = VIEWXH+1;
  rightwall->height1 = 32000;
  (rightwall+1)->x1 = 32000;

  leftx = -1;

  for (wall=&walls[1];wall<rightwall && leftx<=VIEWXH ;wall++)
  {
    if (leftx >= wall->x2)
      continue;

    rightclip = wall->x2;

    check = wall+1;
    while (check->x1 <= rightclip && check->height1 >= wall->height2)
    {
      rightclip = check->x1-1;
      check++;
    }

    if (rightclip>VIEWXH)
      rightclip=VIEWXH;

    if (leftx < wall->x1 - 1)
      newleft = wall->x1-1;		// there was black space between walls
    else
      newleft = leftx;

    if (rightclip > newleft)
    {
      wall->leftclip = newleft+1;
      wall->rightclip = rightclip;
      DrawWall (wall);
      leftx = rightclip;
    }
  }

//
// finish all lines to the right edge
//
  for (i=0;i<CENTERY;i++)
    if (segend[i]<VIEWXH)
      DrawLine(segend[i]+1,VIEWXH,i,0);

  for (;i<VIEWHEIGHT;i++)
    if (segend[i]<VIEWXH)
      DrawLine(segend[i]+1,VIEWXH,i,8);

}

//==========================================================================

/*
=====================
=
= DrawScaleds
=
= Draws all objects that are visable
=
=====================
*/

int	depthsort[MAXOBJECTS],
	sortheight[MAXOBJECTS],
	obscreenx[MAXOBJECTS],
	obscreenheight[MAXOBJECTS],
	obshapenum[MAXOBJECTS];

void DrawScaleds (void)
{
  int i,j,least,leastnum,screenx,numvisable;
  unsigned ratio,screenratio,scaleratio,screenheight;
  fixed viewx;
  objtype *obj;

  numvisable = 0;

//
// calculate base positions of all objects
//
  for (obj = &objlist[1];obj<=lastobj;obj++)
    if (obj->class)
    {
      viewx = obj->viewx - obj->size;		// now value of nearest edge
      if (viewx >= FOCALLENGTH+MINDIST)
      {
	ratio = viewx*scale/FOCALLENGTH;
	screenx = CENTERX + obj->viewy/ratio;
	screenheight = TILEGLOBAL/ratio;
	if (screenx > -128 && screenx < 320+128)
	{
	  obscreenx[numvisable] = screenx;
	  obscreenheight[numvisable] = screenheight;
	  obshapenum[numvisable] = obj->shapenum;
	  numvisable++;
	}
      }
    }

  if (!numvisable)
    return;

//
// sort in order of increasing height
//
  for (i=0;i<numvisable;i++)
  {
    least = 32000;
    for (j=0;j<numvisable;j++)
      if (obscreenheight[j] < least)
      {
	leastnum = j;
	least = obscreenheight[j];
      }
    depthsort[i] = leastnum;
    sortheight[i] = least;
    obscreenheight[leastnum] = 32000;
  }

//
// draw in order
//
  for (i=0;i<numvisable;i++)
  {
    j = depthsort[i];
    SC_ScaleShape(obscreenx[j],CENTERY+5,sortheight[i]
      ,scalesegs[obshapenum[j]]);
  }
}

//==========================================================================

/*
====================
=
= DrawCrossHairs
=
= Should still be in write mode 2
=
====================
*/

#define CROSSSIZE	40

void DrawCrossHairs (void)
{
  EGABITMASK (60);

  asm	mov	es,[screenseg]
  asm	mov	cx,CROSSSIZE
  asm	mov	di,SCREENWIDTH*(64-CROSSSIZE/2)+20
  asm	add	di,[screenofs]
  asm	mov	dx,SCREENWIDTH
vert1:
  asm	mov	al,0
  asm	xchg	al,[BYTE PTR es:di]	// write color 0
  asm	add	di,dx
  asm	loop	vert1

  EGABITMASK (255);

  asm	mov	di,SCREENWIDTH*(82-CROSSSIZE/2)+18
  asm	add	di,[screenofs]
  asm	mov	al,0
  asm	mov	cx,5
  asm	rep	stosb
  asm	add	di,SCREENWIDTH-5
  asm	mov	cx,5
  asm	rep	stosb
  asm	add	di,SCREENWIDTH-5
  asm	mov	cx,5
  asm	rep	stosb
  asm	add	di,SCREENWIDTH-5
  asm	mov	cx,5
  asm	rep	stosb

  asm	mov	di,SCREENWIDTH*(83-CROSSSIZE/2)+19
  asm	add	di,[screenofs]
  asm	mov	al,15
  asm	mov	cx,3
  asm	rep	stosb
  asm	add	di,SCREENWIDTH-3
  asm	mov	cx,3
  asm	rep	stosb


  EGABITMASK (127);

  asm	mov	di,SCREENWIDTH*(83-CROSSSIZE/2)+18
  asm	add	di,[screenofs]
  asm	mov	al,15
  asm	xchg	al,[es:di]
  asm	mov	al,15
  asm	xchg	al,[es:di+SCREENWIDTH]

  EGABITMASK (254);

  asm	mov	di,SCREENWIDTH*(83-CROSSSIZE/2)+18
  asm	add	di,[screenofs]
  asm	mov	al,15
  asm	xchg	al,[es:di+4]
  asm	mov	al,15
  asm	xchg	al,[es:di+4+SCREENWIDTH]

  EGABITMASK (24);

  asm	mov	cx,CROSSSIZE-2
  asm	mov	di,SCREENWIDTH*(65-CROSSSIZE/2)+20
  asm	add	di,[screenofs]
  asm	mov	dx,SCREENWIDTH
vert2:
  asm	mov	al,15
  asm	xchg	al,[es:di]	// write color 15
  asm	add	di,dx
  asm	loop	vert2
}

//==========================================================================

/*
=====================
=
= FinishView
=
=====================
*/

void FinishView (void)
{
  int screenx,pixelscale,screenheight,ratio;

  if (++screenpage == 3)
    screenpage = 0;

  screenorigin = screenofs = screenloc[screenpage];

  EGAWRITEMODE(2);

//
// draw the wall list
//
  DrawWallList();

//
// draw all the scaled images
//
  DrawScaleds();

//
// show screen and time last cycle
//
  screenofs += yshift[(unsigned)inttime&0xff];	// hover effect

  DrawCrossHairs ();

  EGAWRITEMODE(0);

asm 	cli

asm	mov	dx,GC_INDEX
asm	mov	ax,GC_BITMASK + 255*256
asm	out	dx,ax			// no bit mask

asm	mov	cx,[screenofs]
asm	mov	dx,3d4h		// CRTC address register
asm	mov	al,0ch		// start address high register
asm	out	dx,al
asm	inc	dx
asm	mov	al,ch
asm	out	dx,al   	// set the high byte
asm	dec	dx
asm	mov	al,0dh		// start address low register
asm	out	dx,al
asm	inc	dx
asm	mov	al,cl
asm	out	dx,al		// set the low byte

asm	sti


#ifdef ADAPTIVE
  while ( (tics = (timecount - lasttimecount)/2)<2 )
  ;

  lasttimecount = timecount&(~1l);
#else
  tics = 2;
#endif

  if (tics>MAXTICS)
    tics = MAXTICS;

}


