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

/*

NOTICE TO ANYONE READING THIS:

This is the last gasp of our old routines!  Everything is being rewritten
from scratch to work with new graphic modes and utilities.  This code
stinks!

*/


/*
=============================================================================

			       GLOBALS

=============================================================================
*/

int SNDstarted,KBDstarted;	// whether int handlers were started

int grhandle,levelhandle,soundhandle;

typedef struct
{
  int headersize;
  long dictionary;
  long dataoffsets;
} grheadtype;

grheadtype	*grhead;	// sets grhuffman and grstarts from here
huffnode	*grhuffman;	// huffman dictionary for egagraph
long		*grstarts;	// array of offsets in egagraph, -1 for sparse
int		grhandle;	// handle to egagraph, kept open allways
long		grposition;	// current seek position in file
long		chunkcomplen;	// compressed length of a chunk


int soundblaster;		// present?

int levelhandle,soundhandle;

#define BUFFERSIZE	1024
memptr	bufferseg;		// small general purpose memory block

memptr	levelseg;

int tedlevel,ingame,resetgame;

memptr scalesegs[NUMPICS];

/*
=============================================================================
*/


/*
=============
=
= DoHelpText
=
=============
*/

void DoHelpText(void)
{
  CenterWindow (38,14);

  fontcolor = 13;
  CPPrint ("HoverTank Commands\n");
  fontcolor = 15;
  py+=6;
  PPrint (
"F2  : Sound on / off\n"
"F3  : Keyboard mode / custom\n"
"F4  : Joystick mode\n"
"F5  : Reset game\n"
"ESC : Quit\n");

  py+=6;
  PPrint (
"UP / DOWN : forward/reverse\n"
"LEFT / RIGHT : turn\n");

  py+=6;
  CPPrint ("<MORE>");
  Ack();
  EraseWindow ();

  CPPrint ("Button 1 / Ctrl\n");
  CPPrint ("---------------\n\n");

  PPrint (
/*.....................................*/
"Charge cannon.  A fully charged cannon\n"
"can shoot through multiple targets.\n"
"While the cannon is charging, your\n"
"tanks turning speed is halved for fine\n"
"aiming adjustments.\n\n");

  CPPrint ("<MORE>");
  Ack();
  EraseWindow ();

  CPPrint ("Button 2 / Alt\n");
  CPPrint ("---------------\n\n");
  PPrint (
/*.....................................*/
"Afterburner thrusting.  Doubles your\n"
"forward or backwards speed, but does\n"
"not effect your turning speed.\n");

  Ack();

}


/*
==================
=
= DebugMemory
=
==================
*/

void DebugMemory (void)
{
  CenterWindow (16,7);

  CPPrint ("Memory Usage\n");
  CPPrint ("------------");
  PPrint ("\nTotal     :");
  PPrintUnsigned (totalmem/64);
  PPrint ("k\nFree      :");
  PPrintUnsigned (MMUnusedMemory()/64);
  PPrint ("k\nWith purge:");
  PPrintUnsigned (MMTotalFree()/64);
  PPrint ("k\n");
  CPPrint ("");
  PGet();
}




/*
================
=
= DebugKeys
=
================
*/
void DebugKeys (void)
{
  int i;

  if (keydown[0x22])		// G = god mode
  {
    ExpWin (12,1);
    if (godmode)
      CPPrint ("God mode off");
    else
      CPPrint ("God mode on");
    Ack();
    godmode ^= 1;
  }
  else if (keydown[0x32])	// M = memory info
  {
	DebugMemory();
  }
  if (keydown[0x19])		// P = pause with no screen disruptioon
  {
	singlestep=1;
  }
  if (keydown[0x1f])		// S = shield point
  {
	screenofs = 0;
	HealPlayer();
  }
  else if (keydown[0x14])	// T = free time
  {
	if (timestruct.min<9)
	  timestruct.min++;
	screenofs = 0;
	DrawPic (6,48,DIGIT0PIC+timestruct.min);
  }
  else if (keydown[0x11])	// W = warp to level
  {
    ExpWin(26,1);
    PPrint("Warp to which level(1-20):");
    i = InputInt();
    if (i>=1 && i<=21)
    {
      level = i-1;
      leveldone=1;
    }
  }

}

/*=========================================================================*/

/*
=============
=
= CheckKeys
=
= Checks to see if an F-key is being pressed and handles it
=
=============
*/

int CheckKeys(void)
{
  if (!NBKscan)
    return 0;

  switch (NBKscan&0x7f)
  {
    case 0x3b:			// F1 = help
      ClearKeys ();
      DoHelpText ();
      break;
    case 0x3c:			// F2 = sound on/off
      ClearKeys ();
      ExpWin (13,1);
      PPrint ("Sound (Y/N)?");
	  ch=toupper(PGet());
      if (ch=='N')
	soundmode = false;
      else if (ch=='Y')
	soundmode = true;
      break;
    case 0x3d:			// F3 = keyboard mode
      ClearKeys ();
      calibratekeys ();
      break;
    case 0x3e:			// F4 = joystick mode
      ClearKeys ();
      CalibrateJoy (1);
      break;
    case 0x3f:			// F5 = reset game
      ClearKeys ();
      ExpWin (18,1);
      PPrint ("RESET GAME (Y/N)?");
      ch=toupper(PGet());
      if (ch=='Y')
      {
	resetgame = 1;
	leveldone = -99;
      }
      break;

    case 0x58:			// F12 + ? = debug keys
      DebugKeys();
      break;
	 case 1:			// ESC = quit
      ClearKeys ();
      ExpWin (12,1);
		PPrint ("QUIT (Y/N)?");
      ch=toupper(PGet());
      if (ch=='Y')
	Quit ("");
      break;


    default:
      return 0;
  }


  ClearKeys ();
  return 1;
}


//==========================================================================

/*
============================
=
= GetChunkLength
=
= Seeks into the igrab data file at the start of the given chunk and
= reads the uncompressed length (first four bytes).  The file pointer is
= positioned so the compressed data can be read in next.
= ChunkCompLen is set to the calculated compressed length
=
============================
*/

long GetChunkLength (int chunk)
{
  long len;

  lseek(grhandle,grstarts[chunk],SEEK_SET);
  read(grhandle,&len,sizeof(len));
  chunkcomplen = grstarts[chunk+1]-grstarts[chunk]-4;

  return len;
}

//==========================================================================

/*
============================
=
= LoadNearData
=
= Load stuff into data segment before memory manager is
= started (which takes all available memory, near and far)
=
============================
*/

void LoadNearData (void)
{
  int handle;
  long length;

//
// load egahead.ext (offsets and dictionary for graphics file)
//
  if ((handle = open("EGAHEAD."EXTENSION, O_RDONLY | O_BINARY, S_IWRITE | S_IREAD)) == -1)
	 Quit ("Can't open EGAHEAD."EXTENSION"!");

  length = filelength(handle);
  grhead = malloc(length);

  read(handle, grhead, length);

  close(handle);


}

//==========================================================================

/*
==========================
=
= SegRead
=
= Read from a file to a segment pointer
=
==========================
*/

void SegRead (int handle, memptr dest, long length)
{
  if (length>0xffffl)
	 Quit ("SegRead doesn't support 64K reads yet!");

asm		push	ds
asm		mov	bx,[handle]
asm		mov	cx,[WORD PTR length]
asm		mov	dx,0			// segment aligned
asm		mov	ds,[dest]
asm		mov	ah,3fh			// READ w/handle
asm		int	21h
asm		pop	ds

}

//==========================================================================



/////////////////////////////////////////////////////////
//
// InitGrFile
//
/////////////////////////////////////////////////////////

void InitGrFile (void)
{
  memptr buffer;

//
// calculate some offsets in the header
//
  grhuffman = (huffnode *)( ((char *)grhead)+grhead->dictionary);
  grstarts = (long *)( ((char *)grhead)+grhead->dataoffsets);

  OptimizeNodes (grhuffman);

//
// Open the graphics file, leaving it open until the game is finished
//
  grhandle = open("EGAGRAPH."EXTENSION, O_RDONLY | O_BINARY);
  if (grhandle == -1)
	 Quit ("Cannot open EGAGRAPH."EXTENSION"!");


//
// load the pic and sprite headers into the data segment
//
#if NUMPICS>0
  needgr[STRUCTPIC] = 1;		// make sure this chunk never reloads
  grsegs[STRUCTPIC] = (memptr)0xffff;
  GetChunkLength(STRUCTPIC);		// position file pointer
  MMGetPtr(&buffer, chunkcomplen);
  SegRead (grhandle,buffer,chunkcomplen);
  HuffExpand ((unsigned char huge *)buffer, (unsigned char huge *)pictable,
    sizeof(pictable),grhuffman);
  MMFreePtr(&buffer);
#endif

#if NUMPICM>0
  needgr[STRUCTPICM] = 1;		// make sure this chunk never reloads
  grsegs[STRUCTPICM] = (memptr)0xffff;
  GetChunkLength(STRUCTPICM);		// position file pointer
  MMGetPtr(&buffer, chunkcomplen);
  SegRead (grhandle,buffer,chunkcomplen);
  HuffExpand (buffer, (unsigned char huge *)picmtable,
    sizeof(picmtable),grhuffman);
  MMFreePtr(&buffer);
#endif

#if NUMSPRITES>0
  needgr[STRUCTSPRITE] = 1;		// make sure this chunk never reloads
  grsegs[STRUCTSPRITE] = (memptr)0xffff;
  GetChunkLength(STRUCTSPRITE);	// position file pointer
  MMGetPtr(&buffer, chunkcomplen);
  SegRead (grhandle,buffer,chunkcomplen);
  HuffExpand (buffer, (unsigned char huge *)spritetable,
    sizeof(spritetable),grhuffman);
  MMFreePtr(&buffer);
#endif


}


//==========================================================================

/*
==========================
=
= CacheGrFile
=
= Goes through grneeded and grsegs, and makes sure
= everything needed is in memory
=
==========================
*/

// base tile sizes for EGA mode
#define BLOCK		32
#define MASKBLOCK	40

void CacheGrFile (void)
{
  int i;
  long filepos,newpos;		// current seek position in file
  long expanded,compressed;	// chunk lengths
  memptr bigbufferseg;		// for compressed

//
// make unneeded chunks purgable
//
  for (i=0;i<NUMCHUNKS;i++)
    if (grsegs[i] && !needgr[i])
      MMSetPurge(&grsegs[i],3);

  MMSortMem();

//
// load new stuff
//
  lseek(grhandle,0,SEEK_SET);
  filepos = 0;

  for (i=0;i<NUMCHUNKS;i++)
    if (!grsegs[i] && needgr[i])
    {
      newpos = grstarts[i];
      if (newpos!=filepos)
	lseek(grhandle,newpos-filepos,SEEK_CUR);

      compressed = grstarts[i+1]-grstarts[i]-4;

      if (i>=STARTTILE8)
      {
      //
      // tiles are of a known size
      //
	if (i<STARTTILE8M)		// tile 8s are all in one chunk!
	  expanded = BLOCK*NUMTILE8;
	else if (i<STARTTILE16)
	  expanded = MASKBLOCK*NUMTILE8M;
	else if (i<STARTTILE16M)	// all other tiles are one/chunk
	  expanded = BLOCK*4;
	else if (i<STARTTILE32)
	  expanded = MASKBLOCK*4;
	else if (i<STARTTILE32M)
	  expanded = BLOCK*16;
	else
	  expanded = MASKBLOCK*16;

	compressed = grstarts[i+1]-grstarts[i];
      }
      else
      {
      //
      // other things have a length header at start of chunk
      //
	read(grhandle,&expanded,sizeof(expanded));
	compressed = grstarts[i+1]-grstarts[i]-4;
      }

      //
      // allocate space for expanded chunk
      //
      MMGetPtr(&grsegs[i],expanded);

      //
      // if the entire compressed length can't fit in the general purpose
      // buffer, allocate a temporary memory block for it
      //
      if (compressed<=BUFFERSIZE)
      {
	SegRead(grhandle,bufferseg,compressed);
	HuffExpand (bufferseg, grsegs[i], expanded,grhuffman);
      }
      else
      {
	MMGetPtr(&bigbufferseg,compressed);
	SegRead(grhandle,bigbufferseg,compressed);
	HuffExpand (bigbufferseg, grsegs[i], expanded,grhuffman);
	MMFreePtr(&bigbufferseg);
      }

      filepos = grstarts[i+1];	// file pointer is now at start of next one
    }

}

//==========================================================================


/*
=====================
=
= CachePic
=
= Make sure a graphic chunk is in memory
=
=====================
*/

void CachePic (int picnum)
{
  long expanded,compressed;	// chunk lengths
  memptr bigbufferseg;		// for compressed

  if (grsegs[picnum])
    return;

  lseek(grhandle,grstarts[picnum],SEEK_SET);

  compressed = grstarts[picnum+1]-grstarts[picnum]-4;

  if (picnum>=STARTTILE8)
  {
  //
  // tiles are of a known size
  //
    if (picnum<STARTTILE8M)		// tile 8s are all in one chunk!
      expanded = BLOCK*NUMTILE8;
    else if (picnum<STARTTILE16)
      expanded = MASKBLOCK*NUMTILE8M;
    else if (picnum<STARTTILE16M)	// all other tiles are one/chunk
      expanded = BLOCK*4;
    else if (picnum<STARTTILE32)
      expanded = MASKBLOCK*4;
    else if (picnum<STARTTILE32M)
      expanded = BLOCK*16;
    else
      expanded = MASKBLOCK*16;

    compressed = grstarts[picnum+1]-grstarts[picnum];
  }
  else
  {
  //
  // other things have a length header at start of chunk
  //
    read(grhandle,&expanded,sizeof(expanded));
    compressed = grstarts[picnum+1]-grstarts[picnum]-4;
  }

  //
  // allocate space for expanded chunk
  //
  MMGetPtr(&grsegs[picnum],expanded);

  MMGetPtr(&bigbufferseg,compressed);
  SegRead(grhandle,bigbufferseg,compressed);
  HuffExpand (bigbufferseg, grsegs[picnum], expanded,grhuffman);
  MMFreePtr(&bigbufferseg);
}

//==========================================================================

void PatchPointers (void)
{
  fontseg = grsegs[STARTFONT];

}

//==========================================================================

/*
=====================
==
== Quit
==
=====================
*/

void Quit (char *error)
{
//char extern far PIRACY;

  if (!(*error))
  {
	 SaveCtrls ();
  }

  if (KBDstarted)
	 ShutdownKbd ();	// shut down the interrupt driven stuff if needed
  if (SNDstarted)
	 ShutdownSound ();
  if (soundblaster)
	 jmShutSB ();

  if (grhandle>0)
	 close(grhandle);
  if (levelhandle>0)
	 close(levelhandle);
  if (soundhandle>0)
	 close(soundhandle);

  _AX = 3;
  geninterrupt (0x10);	// text mode

  if (!(*error) && !tedlevel)
  {
#if 0
	 movedata (FP_SEG(&PIRACY),FP_OFF(&PIRACY),0xb800,0,4000);
	 bioskey (0);
	 clrscr();
#endif

	_argc = 2;
	_argv[1] = "LAST.SHL";
	_argv[2] = "ENDSCN.SCN";
	_argv[3] = NULL;
	if (execv("LOADSCN.EXE", _argv) == -1)
	{
		clrscr();
		puts("Couldn't find executable LOADSCN.EXE.\n");
		exit(1);
	}

  }
  else
	 puts (error);


  exit (0);		// quit to DOS
}


//==========================================================================

/*
======================
=
= LoadLevel
=
= Loads LEVEL00.EXT (00 = global variable level)
=
======================
*/

void LoadLevel(void)
{
  unsigned far *planeptr;
  int loop,x,y,i,j;
  unsigned length;
  char filename[30];
  char num[3];
  memptr bufferseg;


//
// load the new level in and decompress
//
  if (level<10)
  {
    itoa (level,num,10);
    strcpy (filename,"LEVEL0");
  }
  else
  {
    itoa (level,num,10);
    strcpy (filename,"LEVEL");
  }

  strcat (filename,num);
  strcat (filename,"."EXTENSION);

  BloadinMM(filename,&bufferseg);

  length = *(unsigned _seg *)bufferseg;

  if (levelseg)
    MMFreePtr (&levelseg);

  MMGetPtr (&levelseg,length);

  RLEWExpand ((unsigned far *)bufferseg,(unsigned far *)levelseg);

  MMFreePtr (&bufferseg);

  levelheader = (LevelDef far *)levelseg;

//
// copy plane 0 to tilemap
//
  planeptr= (unsigned far *)((char _seg *)levelseg+32);
  for (y=0;y<levelheader->height;y++)
    for (x=0;x<levelheader->width;x++)
      tilemap[x][y]=*planeptr++;


//
// spawn tanks
//
  planeptr= (unsigned far *)((char _seg *)levelseg+32+levelheader->planesize);
  StartLevel (planeptr);

  MMFreePtr (&levelseg);

}

//==========================================================================


/*
=================
=
= CacheDrawPic
=
=================
*/

void CacheDrawPic(int picnum)
{
  int i;

  CachePic (STARTPICS+picnum);

  EGASplitScreen(200);
  SetScreen(0,0);
  SetLineWidth(80);
  screenofs = 0;

  EGAWRITEMODE(0);
  DrawPic (0,0,picnum);

  EGAWRITEMODE(1);
  EGAMAPMASK(15);
  CopyEGA(80,200,0,0x4000);
  EGAWRITEMODE(0);

  MMSetPurge (&grsegs[STARTPICS+picnum],3);

}


//==========================================================================

int SoundPlaying (void)
{
  if (soundblaster)
    return jmSamplePlaying();
  else
    return sndptr;
}

#if 0

/*
=====================
=
= PlaySound
=
= Dispatches to either pc speaker sound routines or sound blaster
= digitized routines
=
=====================
*/

void PlaySound (int num)
{
  if (soundblaster)
    jmPlaySample(num);
  else
    PlaySoundSPK(num);
}

#endif

//==========================================================================


/*
=====================
=
= Intro
=
=====================
*/

void Intro (void)
{
  memptr shapeseg;
  int i,f,sx,sy,page;
  unsigned pageptr[2],pagewidth[2],pageheight[2];
  float x,y,z,angle,step,sn,cs,maxz,sizescale,maxy,coordscale,scale;
  float ytop,xmid,minz,worldycenter,worldxcenter;

  FadeOut();

  SetLineWidth(SCREENWIDTH);

  screenofs=0;

  CacheDrawPic (STARSPIC);
  pxl=0;
  pxh=320;
  py=180;
  CPPrint ("Copyright (c) 1991 Softdisk inc.\n");
  CPPrint ("'I' for information");
  EGAWRITEMODE(1);
  EGAMAPMASK(15);
  CopyEGA(40,200,0,0x4000);
  CopyEGA(40,200,0,0x8000);
  CopyEGA(40,200,0,0xc000);
  StopDrive();

  CachePic (STARTPICS+LOGOPIC);

  SC_MakeShape(
    grsegs[STARTPICS+LOGOPIC],
    pictable[LOGOPIC].width,
    pictable[LOGOPIC].height,
    &shapeseg);

  MMFreePtr(&grsegs[STARTPICS+LOGOPIC]);

  FadeIn();

  sx=160;
  sy=180;

  memset (zbuffer,0,sizeof(zbuffer));

/*
=============================================================================

		  SCALED PICTURE DIRECTOR

=============================================================================
*/

#define PICHEIGHT       64	// full size height of scaled pic
#define NUMFRAMES	300.0
#define MAXANGLE	(3.141592657*0.6)	// go from 0 to this in numframes
#define RADIUS		1000.0 	// world coordinates
#define DISTANCE	1000.0	// center point z distance

  minz = cos(MAXANGLE)*RADIUS;	// closest point
  minz += DISTANCE;
  sizescale = 256*minz;		// closest point will be full size
  ytop = 80 - (PICHEIGHT/2)*(sizescale/DISTANCE)/256;
  z = sizescale/(DISTANCE*256);
  ytop = ytop/z;	// world coordinates
  worldycenter=ytop-RADIUS;
  xmid=sin(MAXANGLE)*RADIUS/2;
  worldxcenter=-xmid;

  f=1;
  page = inttime = screenofs = pagewidth[0] = pagewidth[1] = 0;
  do
  {
    step = f/NUMFRAMES;
    angle=MAXANGLE*step;
    sn=sin(angle);
    cs=cos(angle);
    x=worldxcenter+sn*RADIUS/2;
    y=worldycenter+sn*RADIUS;
    z=DISTANCE+cs*RADIUS;
    scale = sizescale/z;
    sx=160+ (int)(x*scale/256);
    sy=100- (int)(y*scale/256);

    inttime=0;
    sound((int)(sn*1500));

//
// erase old position
//
    if (pagewidth[page])
    {
      EGAWRITEMODE(1);
      EGAMAPMASK(15);
      CopyEGA(pagewidth[page],pageheight[page],
      pageptr[page]+0x8000,pageptr[page]);
    }

//
// draw new position
//
    EGAWRITEMODE(2);
    if (SC_ScaleShape(sx,sy,(int)scale<40 ? 10 : scale/4,shapeseg))
    {
      pagewidth[page]=scaleblockwidth;
      pageheight[page]=scaleblockheight;
      pageptr[page]=scaleblockdest;
    }
    else
      pagewidth[page]=0;

    EGAWRITEMODE(0);
    EGABITMASK(255);

//
// display it
//
    SetScreen(screenofs,0);

    page^=1;
    screenofs = 0x4000*page;

    f++;

    if (f<NUMFRAMES)
    {
      f+=inttime;
      if (f>NUMFRAMES)
	f=NUMFRAMES;
    }
    else
     f++;	// last frame is shown

    if (NBKscan>0x7f)
      break;
  } while (f<=NUMFRAMES);
  nosound();

  for (i=0;i<200;i++)
  {
    WaitVBL(1);
    if (NBKscan>0x7f)
    {
      if (NBKscan==0x97)		//'I' for info
      {
	screenofs^=0x4000;
  CenterWindow(24,10);
	py+=2;
  CPPrint ("Hovertank v1.17\n\n");
	CPPrint ("Softdisk Publishing delivers a\n");
	CPPrint ("high quality EGA game to\n");
	CPPrint ("your door every month!\n");
	CPPrint ("Call 1-800-831-2694 for\n");
	CPPrint ("subscription rates and\n");
	CPPrint ("back issues.\n");
	ClearKeys();
	Ack();
      }
      ClearKeys();
      break;
    }
  }

  MMFreePtr(&shapeseg);
}

//==========================================================================



/*
=====================
==
== DemoLoop
==
=====================
*/
#define PAUSE	300
void DemoLoop (void)
{
  int i,originx;
  ControlStruct c;

  FadeOut();

  CacheDrawPic (TITLEPIC);
  StopDrive();	// make floppy motors turn off

  FadeIn ();

  originx=0;
  i=100;
  while (1)
  {
    if (i>PAUSE && i<=PAUSE+80)
      originx+=4;

    if (i>PAUSE*2 && i<=PAUSE*2+80)
      originx-=4;

    if (i>PAUSE*2+80)
      i=0;

    SetScreen(originx/8,originx%8);

    i++;

    screenofs = originx/8;
    if (CheckKeys())
    {
      EGAWRITEMODE(1);
      EGAMAPMASK(15);
      CopyEGA(80,200,0x4000,0);
    }
    c=ControlPlayer(1);
    if (c.button1 || c.button2)
      break;
    if (keydown[0x39])
      break;
  }

  ClearKeys();
}


//==========================================================================

/*
====================
=
= SetupGraphics
=
====================
*/
void SetupGraphics (void)
{
  int i;

  InitGrFile ();	// load the graphic file header

//
// go through the pics and make scalable shapes, the discard the pic
//
  for (i=MAN1PIC;i<DASHPIC;i++)
  {
    CachePic (STARTPICS+i);
    SC_MakeShape(
      grsegs[STARTPICS+i],
      pictable[i].width,
      pictable[i].height,
      &scalesegs[i]);
    MMFreePtr (&grsegs[STARTPICS+i]);
  }

//
// load the basic graphics
//

  needgr[STARTFONT] = 1;
  needgr[STARTTILE8] = 1;

  for (i=DASHPIC;i<ENDPIC;i++)
    needgr[STARTPICS+i]=1;

  CacheGrFile ();	// load all graphics now (no caching)

  fontseg = grsegs[STARTFONT];
}

//==========================================================================

//////////////////////////////////////////////////////
//
// Hardware Error Handler - called only by MS-DOS
//
//////////////////////////////////////////////////////

#define IGNORE  0
#define RETRY   1
#define ABORT   2

int ErrorHandler(int errval,int ax,int bx,int si)
{
  unsigned key;

  key=ax+bx+si+errval;

//  screenofs=screenorigin=0;
//  SetScreen(0,0);
  CenterWindow(32,3);
  py++;
  CPPrint("Disk I/O error! Press ENTER to\n");
  CPPrint("resume, or ESC to abort:");
  SetNormalPalette();

  ClearKeys();

  do{
	 key=(PGet()&0xff);
	} while(key!=27 && key!=13);

  if (key!=27)
	hardresume(RETRY);

  _AX = 3;
  geninterrupt (0x10);	// text mode

  if (KBDstarted)
	ShutdownKbd ();	// shut down the interrupt driven stuff if needed
  if (SNDstarted)
	ShutdownSound ();

  return ABORT;
}



/*=========================================================================*/

////////////////////////////////////////////////////////////
//
// Allocate memory and load file in
//
////////////////////////////////////////////////////////////
void LoadIn(char *filename,char huge **baseptr)
{
 int handle;
 long len;
 unsigned datapage;


 if ((handle=open(filename,O_BINARY))==-1)
   {
	printf("Error loading file '%s'!\n",filename);
	exit(1);
   }

 len=filelength(handle);
 *baseptr=(char huge *)farmalloc(len);

 LoadFile(filename,*baseptr);
}

///////////////////////////////////////////////////////////////////////////
//
//	US_CheckParm() - checks to see if a string matches one of a set of
//		strings. The check is case insensitive. The routine returns the
//		index of the string that matched, or -1 if no matches were found
//
///////////////////////////////////////////////////////////////////////////
int
US_CheckParm(char *parm,char **strings)
{
	char	cp,cs,
			*p,*s;
	int		i;

	while (!isalpha(*parm))	// Skip non-alphas
		parm++;

	for (i = 0;*strings && **strings;i++)
	{
		for (s = *strings++,p = parm,cs = cp = 0;cs == cp;)
		{
			cs = *s++;
			if (!cs)
				return(i);
			cp = *p++;

			if (isupper(cs))
				cs = tolower(cs);
			if (isupper(cp))
				cp = tolower(cp);
		}
	}
	return(-1);
}
///////////////////////////////////////////////////////////////////////////

/*
=================
=
= main
=
=================
*/

static	char			*EntryParmStrings[] = {"detour",0};

void main(void)
{
  int i,x,xl,xh,y,plane,size;
  SampledSound huge *samples;

	boolean LaunchedFromShell = false;

	if (stricmp(_argv[1], "/VER") == 0)
	{
		printf("HOVER TANK\n");
		printf("Copyright 1992 Softdisk Publishing\n");
		printf("Version 1.16\n");
		exit(0);
	}

	for (i = 1;i < _argc;i++)
	{
		switch (US_CheckParm(_argv[i],EntryParmStrings))
		{
		case 0:
			LaunchedFromShell = true;
			break;
		}
	}

	if (!LaunchedFromShell)
	{
		clrscr();
		puts("You must type START at the DOS prompt to run HOVER TANK.");
		exit(0);
	}


//  puts("Hover Tank is executing...");

//
// detect video
//
  videocard = VideoID ();

  if (videocard == EGAcard) {}
//    puts ("EGA card detected");
  else if (videocard == VGAcard) {}
//    puts ("VGA card detected");
  else
  {
	 puts ("Hey, I don't see an EGA or VGA card here!  Do you want to run the program ");
	 puts ("anyway (Y = go ahead, N = quit to dos) ?");
	 ClearKeys ();
	 i = toupper(bioskey(0) & 0xff);
	 if (i!='Y')
		exit (1);
  }

  grmode = EGAgr;

//
// setup for sound blaster
//
  if (_argc == 1)	// command line override
	 soundblaster = jmDetectSoundBlaster(-1);
  else
	 soundblaster = 0;

  if (soundblaster)
  {
//	 puts ("Sound Blaster detected! (HOVER NOBLASTER to void detection)");
	 LoadIn ("DSOUND.HOV",&(char huge *)samples);
	 jmStartSB ();
	 jmSetSamplePtr (samples);
  }
  else
//	 puts ("Sound Blaster not detected");


  LoadNearData ();	// load some stuff before starting the memory manager

  MMStartup ();
  MMGetPtr(&bufferseg,BUFFERSIZE);	// small general purpose buffer

  BloadinMM ("SOUNDS."EXTENSION,&soundseg);

  harderr(ErrorHandler);	// critical error handler

#ifdef ADAPTIVE
  timerspeed = 0x2147;	// 140 ints / second (2/VBL)
  StartupSound ();	// interrupt handlers that must be removed at quit
  SNDstarted = 1;
#endif

  StartupKbd ();
  KBDstarted = 1;

  SetupGraphics ();

  InitRndT (1);		// setup random routines
  InitRnd (1);

  LoadCtrls ();

  puts ("Calculating...");
  BuildTables();
  SC_Setup();

  SetScreenMode(grmode);
  SetLineWidth (SCREENWIDTH);

  screencenterx=19;
  screencentery=12;

#if !(defined (PROFILE) || defined (TESTCASE))
  if (!keydown[1])		// hold ESC to bypass intro
    Intro ();
#endif

#ifdef PROFILE
JoyXlow[1]=JoyYlow[1]=16;
JoyXhigh[1]=JoyYhigh[1]=70;
playermode[1] = joystick1;
#endif

  while (1)
  {
#if !(defined (PROFILE) || defined (TESTCASE))
    DemoLoop ();		// do title, demo, etc
#endif
    PlaySound (STARTGAMESND);
    PlayGame();
  }

}

