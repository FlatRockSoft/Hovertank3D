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

// MEMMGR.C
#include "IDLIB.H"
#pragma hdrstop

#define EMSINT		0x67

#define EXTRASTACKSIZE	0x1000
#define MAXBLOCKS	1500
#define LOCKBIT		0x8000	// if set in attributes, block cannot be moved
#define PURGEBITS	3	// 0-3 level, 0= unpurgable, 3= purge first

#define BASEATTRIBUTES	0	// unlocked, non purgable

unsigned totalmem;		// total paragraphs available with 64k EMS
int	EMSpresent,XMSpresent;


void far *farheap;
void *nearheap;

int	numblocks;
struct {
	 unsigned start; 	// in paragraphs
	 unsigned length;
	 unsigned attributes;
	 memptr *useptr;
       } blocks[MAXBLOCKS],tempblock;

//==========================================================================

//
// local prototypes
//
void CheckForEMS (void);
int FindBlock (memptr *ptr);
void RemoveBlock (int block);
void InsertBlock (int block);


//
// public prototypes
//

void MMStartup (void);
void MMShutdown (void);
void MMMapEMS (void);
void MMGetPtr (memptr *baseptr,long size);
void MMFreePtr (memptr *baseptr);
void MMSetPurge (memptr *baseptr, int purge);
void MMSortMem (void);
void MMBlockDump (void);
unsigned MMUnusedMemory (void);
unsigned MMTotalFree (void);

//==========================================================================


//
// CheckForEMS
//
// Routine from p36 of Extending DOS
//
void CheckForEMS (void)
{
  char	emmname[9] = "EMMXXXX0";

asm	mov	dx,OFFSET emmname
asm	mov	ax,0x3d00
asm	int	0x21		// try to open EMMXXXX0 device
asm	jc	error

asm	mov	bx,ax
asm	mov	ax,0x4400

asm	int	0x21		// get device info
asm	jc	error

asm	and	dx,0x80
asm	jz	error

asm	mov	ax,0x4407

asm	int	0x21		// get status
asm	jc	error
asm	or	al,al
asm	jz	error

asm	mov	ah,0x3e
asm	int	0x21		// close handle
asm	jc	error

//
// EMS is good
//


  return;

error:
//
// EMS is bad
//
  EMSpresent = 0;

}

//==========================================================================


//
// FindBlock
//
int FindBlock (memptr *ptr)
{
  int i;
  for (i=1;i<numblocks;i++)
    if (blocks[i].useptr == ptr)
      return i;

  Quit ("Memory manager error: Block not found!");
  return -1;
}

//
// RemoveBlock
// 0 the pointer, close the block array down, and decrement numblocks
//
void RemoveBlock (int block)
{
  void far *source, far *dest;
  unsigned length;

  *blocks[block].useptr = NULL;
  if (block!=numblocks-1)
  {
    source = &blocks[block+1];
    dest = &blocks[block];
    length = (numblocks-1-block)*sizeof(blocks[0]);
    movedata (FP_SEG(source),FP_OFF(source),FP_SEG(dest),FP_OFF(dest),length);
  }
  numblocks--;
}

//
// InsertBlock
// Inserts space in the block array AFTER parameter and increments numblocks
//
void InsertBlock (int block)
{
  unsigned source,dest,length;

  if (block!=numblocks-1)
  {
    source = ((unsigned)&blocks[numblocks])-2;
    dest = ((unsigned)&blocks[numblocks+1])-2;
    length = (numblocks-1-block)*sizeof(blocks[0])/2;
asm	mov	cx,length
asm	mov	si,source
asm	mov	di,dest
asm	mov	ax,ds
asm	mov	es,ax
asm	std
asm	rep	movsw
asm	cld
  }
  if (++numblocks>=MAXBLOCKS)
    Quit ("Memory manager error: Too many blocks!");
}



// check numblocks<MAXBLOCKS

//==========================================================================

/*
===================
=
= MMStartup
=
= Initializes the memory manager and returns the total
= allocatable free space.
=
= Grabs all space from turbo with farmalloc
=
===================
*/

void MMStartup (void)
{
  unsigned long length;
  void far *start;
  unsigned nearstart,farstart,EMSstart,seg;
  unsigned nearlength,farlength,emslength,xmslength;

//
// get all available near conventional memory
//
  length=coreleft();
  start = (void far *)(nearheap = malloc(length));

//
// paragraph align it and figure size
//
  length -= 16-(FP_OFF(start)&15);
  length -= EXTRASTACKSIZE;
  nearlength = length / 16;			// now in paragraphs
  nearstart = FP_SEG(start)+(FP_OFF(start)+15)/16;

//
// get all available far conventional memory
//
  length=farcoreleft();
  start = farheap = farmalloc(length);

//
// paragraph align it and figure size
//
  if (FP_OFF(start))
  {
    length -= 16-FP_OFF(start);
    start = (void far *)MK_FP(FP_SEG(start)+1,0);
  }
  farlength = length / 16;			// now in paragraphs
  farstart = FP_SEG(start);

  totalmem = nearlength + farlength;

//
// detect EMS and allocate 64K at page frame
//
  CheckForEMS();
  if (EMSpresent)
  {
    EMSstart = 0xffff;
    totalmem += 0x1000;				// 64k of EMS
    MMMapEMS();					// map in used pages
  }
  else
  {
    EMSstart = 0xffff;
  }

//
// set up locked blocks
//
  numblocks = 0;

  blocks[numblocks].start = 0;
  blocks[numblocks].length = nearstart;
  blocks[numblocks].attributes = LOCKBIT;

  numblocks++;

  blocks[numblocks].start = nearstart+nearlength;
  blocks[numblocks].length = farstart-(nearstart+nearlength);
  blocks[numblocks].attributes = LOCKBIT;

  numblocks++;

  blocks[numblocks].start = farstart+farlength;
  blocks[numblocks].length = EMSstart-(farstart+farlength);
  blocks[numblocks].attributes = LOCKBIT;

  numblocks++;


}

//==========================================================================

/*
====================
=
= MMShutdown
=
= Frees all conventional, EMS, and XMS allocated
=
====================
*/

void MMShutdown (void)
{
  farfree (farheap);
  free (nearheap);

}

//==========================================================================

/*
====================
=
= MMMapEMS
=
= Maps the 64k of EMS used by memory manager into the page frame
= for general use.
=
====================
*/

void MMMapEMS (void)
{

}

//==========================================================================

/*
====================
=
= MMGetPtr
=
= Allocates an unlocked, unpurgable block
= Start looking at the top of memory
=
====================
*/


void MMGetPtr (memptr *baseptr,long size)
{
  int i,j,k,try;
  unsigned start,end;
  extern int soundblaster;

  //
  // change size from bytes to paragraphs
  //
  size = (size+15)/16;

  //
  // try a normal scan, then compress if not found
  //
  for (try=0;try<2;try++)
  {
    for (i=0;i<numblocks-1;i++)
    {
      if (blocks[i].attributes & PURGEBITS )
	continue;
      //
      // blocks[i] cannot be written over, so try to allocate the
      // new block right after it
      //
      start = blocks[i].start + blocks[i].length;
      end = start + size;
      j=i+1;
      while (blocks[j].start < end)
      {
	if (!(blocks[j].attributes & PURGEBITS))
	{
	  i = j-1;
	  goto lookmore;		// a non purgable block is in the way
	}
	j++;
      }
      //
      // purge the blocks in the way
      //
      for (k=i+1;k<j;j--)
	RemoveBlock(k);
      //
      // allocate the new block
      //
      InsertBlock(i);
      *(unsigned *)baseptr = start;
      blocks[i+1].start = start;
      blocks[i+1].length = size;
      blocks[i+1].useptr = baseptr;
      blocks[i+1].attributes = BASEATTRIBUTES;
      return;
lookmore:;
    }
    //
    // didn't find any space, so compress and try again
    //
    if (try==0)
      MMSortMem();
  }

//puts("");
//MMBlockDump();	// DEBUG
  if (soundblaster)
    Quit ("Out of memory! Unload TSRs or run without Sound Blaster!");
  else
    Quit ("Memory manager error: Out of memory!");
}

//==========================================================================

/*
=====================
=
= MMFreePtr
=
= Frees up a block and NULL's the pointer
=
=====================
*/

void MMFreePtr (memptr *baseptr)
{
  RemoveBlock(FindBlock (baseptr));
}


//==========================================================================

/*
=====================
=
= MMSetPurge
=
= Sets the purge level for a block
=
=====================
*/

void MMSetPurge (memptr *baseptr, int purge)
{
  int block;
  unsigned attr;

  block = FindBlock (baseptr);

  attr = blocks[block].attributes;
  attr &= 0xffff - PURGEBITS;
  attr |= purge;		// set bits in attributes
  blocks[block].attributes = attr;
}


/*
=============================================================================

			    MMSortMem

=============================================================================
*/

//
// MoveParas
//
void MoveParaBase (unsigned source, unsigned dest, unsigned words)
{
asm	mov	cx,words
asm	xor	si,si
asm	xor	di,di
asm	mov	ax,source
asm	mov	bx,dest
asm	mov	ds,source
asm	mov	es,dest
asm	rep	movsw
asm	mov	ax,ss
asm	mov	ds,ax
}

void MoveParaBaseUp (unsigned source, unsigned dest, unsigned words)
{
asm	mov	cx,words
asm	mov	si,cx
asm	dec	si
asm	shl	si,1
asm	mov	di,si
asm	mov	ax,source
asm	mov	bx,dest
asm	mov	ds,source
asm	mov	es,dest
asm	rep	movsw
asm	mov	ax,ss
asm	mov	ds,ax
}


void MoveParas (unsigned source, unsigned dest, unsigned paragraphs)
{
  if (source>dest)
  {
asm	cld
    while (paragraphs>0xfff)
    {
      MoveParaBase (source,dest,0xfff*8);
      source += 0xfff*8;
      dest += 0xfff*8;
      paragraphs -= 0xfff;
    }
    MoveParaBase (source,dest,paragraphs*8);
  }
  else
  {
asm	std
    source+=paragraphs;
    dest+=paragraphs;
    while (paragraphs>0xfff)
    {
      source-=0xfff;
      dest-=0xfff;
      MoveParaBaseUp (source,dest,0xfff*8);
      paragraphs -= 0xfff;
    }
    source-=paragraphs;
    dest-=paragraphs;
    MoveParaBaseUp (source,dest,paragraphs*8);
asm	cld
  }
}


/*
======================
=
= MMSortMem
=
= Sorts all non locked blocks so lower purge levels are lower in memory
= and all free space is at the top
=
======================
*/

int keyblock;

//
// PushUp
//
// Pushes the block (purgeable) as high in memory as possible
// must be BELOW keyblock
// If it can't fit above keyblock it will be freed
//
void PushUp (int move)
{
  unsigned source,dest,size;
  int i;

  size = blocks[move].length;
  source = blocks[move].start;

  for (i=numblocks-1;i>keyblock;i--)
  {
  //
  // if the block can fit under this block, move it
  //
    dest = blocks[i].start - size;
    if (blocks[i-1].start+blocks[i-1].length <= dest)
    {
    //
    // make a copy of block 'move' under block 'i'
    //
      InsertBlock (i-1);
      blocks[i] = blocks[move];
      blocks[i].start = dest;
      *(blocks[i].useptr) = (void _seg *)dest;	// modify the pointer to the new spot
      MoveParas (source,dest,size);
      break;
    }
  }

  //
  // erase original position
  //
  RemoveBlock (move);
  keyblock--;		// because a block below it was removed
}


//
// PushDown
//
// Push keyblock (unpurgable) as low in memory as possible
//
void PushDown (void)
{
  unsigned source,dest,size,end,lowblock,checkblock,i;

  size = blocks[keyblock].length;
  source = blocks[keyblock].start;

//
// find the lowest space it can be moved into
//
  for (lowblock = 0;lowblock<keyblock;lowblock++)
    if (!(blocks[lowblock].attributes & PURGEBITS) ||
	blocks[lowblock].attributes & LOCKBIT)
    {
    //
    // found a locked or nonpurgable block below keyblock
    //
    // see if there is enough space to move block
    //
      dest = blocks[lowblock].start + blocks[lowblock].length;
      end = dest+size;

    //
    // see if any of the blocks in the middle can be moved away
    //
      checkblock = lowblock+1;
      while (checkblock < keyblock && blocks[checkblock].start<end)
      {
	if (!(blocks[checkblock].attributes & PURGEBITS) )
	  goto nofit;   // can't fit between two locked blocks
	//
	// push the block up or remove it, in either case dropping
	// keyblock and changing blocks[checkblock]
	//
	PushUp (checkblock);
      }
//
// move it!
//
      if (dest != source)
      {
	MoveParas (source,dest,size);
	blocks[keyblock].start = dest;
	*(blocks[keyblock].useptr) = (void _seg *)dest;	// modify the pointer to the new spot
	if (lowblock<keyblock-1)
	{
	//
	// reorder the block records
	//
	  tempblock = blocks[keyblock];
	  for (i=keyblock;i>lowblock+1;i--)
	    blocks[i]=blocks[i-1];
	  blocks[lowblock+1] = tempblock;
	}

//MMBlockDump();	// DEBUG
      }
      return;

 nofit:;		// keep looking...

    }
}


//
// MMSortMem
//

void MMSortMem (void)
{
  unsigned i,source,dest;

  keyblock = 0;

  do
  {
    keyblock++;

    //
    // non-purgable, unlocked blocks will be pushed low in memory
    //
    if ( !(blocks[keyblock].attributes & PURGEBITS) &&
	 !(blocks[keyblock].attributes & LOCKBIT) )
      PushDown ();

  } while (keyblock<numblocks-1);


  for (i=numblocks-2;i>0;i--)
  {
    //
    // push all purgable blocks as high as possible
    // Currently they are NOT moved around locked blocks!
    //
    if ( blocks[i].attributes & PURGEBITS )
    {
      source= blocks[i].start;
      dest= blocks[i+1].start-blocks[i].length;
      if (source!=dest)
      {
	MoveParas (source,dest,blocks[i].length);
	blocks[i].start = dest;
	*(blocks[i].useptr) = (void _seg *)dest;	// modify the pointer to the new spot
      }
    }
  }

  PatchPointers();		// let the main program fix up any
				// internal references
}


//==========================================================================

/*
=======================
=
= MMBlockDump
=
= Dewbug tool
=
=======================
*/
#include <STDIO.H>

void MMBlockDump (void)
{
  int i;
  unsigned free;

  fprintf (stdprn,"-------------\n");
  for (i=0;i<numblocks;i++)
  {
    fprintf (stdprn,"Start:%4X\tLength:%4X\tAttr:%4X\tPtr:%p\n"
    ,blocks[i].start,blocks[i].length,blocks[i].attributes,blocks[i].useptr);
    if (i<numblocks-1)
    {
      free = blocks[i+1].start - (blocks[i].start+blocks[i].length);
      if (free)
	fprintf (stdprn,"### Free:%X\n",free);
    }
  }
  puts("");
}


//==========================================================================

/*
======================
=
= MMUnusedMemory
=
= Returns the total free space without purging
=
======================
*/

unsigned MMUnusedMemory (void)
{
  int i;
  unsigned free;

  free = 0;

  for (i=0;i<numblocks;i++)
  {
    if (i<numblocks-1)
      free += blocks[i+1].start - (blocks[i].start+blocks[i].length);
  }

  return free;
}

//==========================================================================


/*
======================
=
= MMTotalFree
=
= Returns the total free space with purging
=
======================
*/

unsigned MMTotalFree (void)
{
  int i;
  unsigned free;

  free = 0;

  for (i=0;i<numblocks;i++)
  {
    if (blocks[i].attributes & PURGEBITS)
      free += blocks[i].length;
    if (i<numblocks-1)
      free += blocks[i+1].start - (blocks[i].start+blocks[i].length);
  }

  return free;
}

//==========================================================================
