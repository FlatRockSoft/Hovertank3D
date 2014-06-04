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

#define EXTENSION	"HOV"

#include "GRAPHHOV.H"
#include "SNDSHOV.H"

#include <stdarg.h>
#include <dos.h>
#include <mem.h>
#include <sys\stat.h>
#include <fcntl.h>
#include <stdlib.h>
#include <alloc.h>
#include <io.h>

#ifndef __jm__
typedef enum {false,true} boolean;
typedef unsigned char byte;
#endif

#define TRUE	1
#define FALSE	0


char extern ch,str[80];		// scratch variables

#define SIGN(x) ((x)>0?1:-1)
#define ABS(x) ((int)(x)>0?(x):-(x))
#define LABS(x) ((long)(x)>0?(x):-(x))

/*
============================================================================

			MEMORY MANAGER

============================================================================
*/


typedef void _seg * memptr;

#define MEMPTR(x) ((memptr)((unsigned)x))

extern unsigned totalmem;		// total paragraphs available
extern int	EMSpresent,XMSpresent;


//==========================================================================

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

void PatchPointers (void);	// must be present in the main program

/*
============================================================================

** Sound routines
** Ties into INT 8, with a timer tic at 8 * normal rate (144/sec)

============================================================================
*/

typedef enum {off,spkr,adlib} soundtype;

typedef struct {unsigned start;
		byte priority;
		byte samplerate;
		char name[12];} spksndtype;

typedef struct {char id[4];
		unsigned filelength;
		unsigned filler[5];
		spksndtype sounds[63];
		unsigned freqdata[];} SPKRtable;


soundtype extern soundmode;

extern	unsigned timerspeed;
extern	int	dontplay;
extern	unsigned inttime;
extern	long	timecount;

extern	unsigned int8hook;	// address of function to call every tic

extern	memptr	soundseg;
extern	unsigned sndptr;

void StartupSound (void);
void CallTimer (void);
void ShutdownSound (void);
void PlaySound (int sound);
void PauseSound (void);
void ContinueSound (void);
void StopSound (void);
void WaitEndSound (void);


/*
============================================================================

** Control routines
** Ties into INT 9 to intercept all key presses, but passes on to BIOS
** The control panel handles all this stuff!

============================================================================
*/

typedef enum {north,northeast,east,southeast,south,southwest,west,
	      northwest,nodir} dirtype;

typedef struct {dirtype dir;
		boolean button1,button2;} ControlStruct;

typedef enum {keyboard,mouse,joystick1,joystick2,demo} inputtype;

enum demoenum {notdemo,demoplay,recording};
enum demoenum extern indemo;

inputtype	extern	playermode[3];
char		extern	keydown[128];
int		extern	JoyXlow[3],
			JoyXhigh[3],
			JoyYlow [3],
			JoyYhigh [3];	// 1&2 are used, 0 is just space

int		extern	MouseSensitivity;
char		extern	key[8], keyB1, keyB2;	// scan codes for key control


void StartupKbd (void);						/* ASM */
void ShutdownKbd (void);                                        /* ASM */

void ReadJoystick (int joynum,int *xcount,int *ycount);

int JoyButton (void);
void CalibrateJoy (int joynum);
void Printscan (int sc);
void calibratekeys (void);

ControlStruct ControlKBD (void);
ControlStruct ControlMouse (void);
ControlStruct ControlJoystick (int joynum);
ControlStruct ControlPlayer (int player);

int NoBiosKey(int parm);
extern int	NBKscan,NBKascii,lastkey;

/*
===========================================================================

** Miscellaneous library routines

===========================================================================
*/

typedef struct
{
  unsigned bit0,bit1;	// 0-255 is a character, > is a pointer to a node
} huffnode;

extern int useegamem;

long unsigned int LoadFile(char *filename,char huge *buffer);
void SaveFile(char *filename,char huge *buffer, long size);
long Verify(char *filename);
void StopDrive (void);

void BloadinMM (char *filename,memptr *spot);
void BloadinRLEMM (char *filename,memptr *spot);
void BloadinHUFFMM (char *filename,memptr *spot);

void HuffExpandFile (unsigned char huge *infile,
  unsigned char huge *outfile);

void HuffExpand (unsigned char huge *source, unsigned char huge *dest,
  long length,huffnode *hufftable);

void RLEBExpand (unsigned char far *source, unsigned char far *dest);

void RLEExpand (char far *surce,char far *dest,long length);
unsigned RLECompress (char far *source, unsigned Length, char far *dest);

void InitRnd (boolean randomize);				/* ASM */
int Rnd (int max);                                              /* ASM */
void InitRndT (boolean randomize);                              /* ASM */
int RndT (void);                                                /* ASM */

void ClearKeys (void);


/*
============================================================================

** Graphic routines
** Edge graphic file not needed
**
** Many of these #defines are duplicates as EQUs in EDGEASM, and must be ==

============================================================================
*/

#define SC_INDEX	0x3C4
#define SC_RESET	0
#define SC_CLOCK	1
#define SC_MAPMASK	2
#define SC_CHARMAP	3
#define SC_MEMMODE	4

#define CRTC_INDEX	0x3D4
#define CRTC_H_TOTAL	0
#define CRTC_H_DISPEND	1
#define CRTC_H_BLANK	2
#define CRTC_H_ENDBLANK	3
#define CRTC_H_RETRACE	4
#define CRTC_H_ENDRETRACE 5
#define CRTC_V_TOTAL	6
#define CRTC_OVERFLOW	7
#define CRTC_ROWSCAN	8
#define CRTC_MAXSCANLINE 9
#define CRTC_CURSORSTART 10
#define CRTC_CURSOREND	11
#define CRTC_STARTHIGH	12
#define CRTC_STARTLOW	13
#define CRTC_CURSORHIGH	14
#define CRTC_CURSORLOW	15
#define CRTC_V_RETRACE	16
#define CRTC_V_ENDRETRACE 17
#define CRTC_V_DISPEND	18
#define CRTC_OFFSET	19
#define CRTC_UNDERLINE	20
#define CRTC_V_BLANK	21
#define CRTC_V_ENDBLANK	22
#define CRTC_MODE	23
#define CRTC_LINECOMPARE 24


#define GC_INDEX	0x3CE
#define GC_SETRESET	0
#define GC_ENABLESETRESET 1
#define GC_COLORCOMPARE	2
#define GC_DATAROTATE	3
#define GC_READMAP	4
#define GC_MODE		5
#define GC_MISCELLANEOUS 6
#define GC_COLORDONTCARE 7
#define GC_BITMASK	8

#define ATR_INDEX	0x3c0
#define ATR_MODE	16
#define ATR_OVERSCAN	17
#define ATR_COLORPLANEENABLE 18
#define ATR_PELPAN	19
#define ATR_COLORSELECT	20

#define SCREENWIDTH	40

#define EGAWRITEMODE(x) asm{cli;mov dx,GC_INDEX;mov ax,GC_MODE+256*x;out dx,ax;sti;}
#define EGABITMASK(x) asm{mov dx,GC_INDEX;mov ax,GC_BITMASK+256*x;out dx,ax;sti;}
#define EGAMAPMASK(x) asm{cli;mov dx,SC_INDEX;mov ax,SC_MAPMASK+x*256;out dx,ax;sti;}

typedef enum {text,CGAgr,EGAgr,VGAgr} grtype;
typedef enum {NOcard,MDAcard,CGAcard,EGAcard,MCGAcard,VGAcard,
	      HGCcard=0x80,HGCPcard,HICcard} cardtype;

grtype extern grmode;
cardtype extern videocard;
unsigned extern ylookup[256];
int	extern	bordercolor;


void SetScreenMode (grtype mode);	// sets graphic mode
void WaitVBL (int num);			// waits for no sync, then sync

void LoadPage(char *filename,unsigned dest);

void EGAPlane (int plane);		// read / write from plane 0-4
void EGASplitScreen (int linenum);	// splits a 200 line screen
void CRTCstart (unsigned start);	// set crtc high/low registers
void EGAVirtualScreen (int width);	// sets screen width
void ColorBorder (int color);		// sets overscan color

cardtype VideoID (void);		// returns the display adapter installed

void SetDefaultColors(void);		// full bright palete
void FadeOut (void);			// EGA 16 color palette fade
void FadeIn (void);

void XorBar(int xl,int yl,int width,int height);
void Bar (int xl,int yl,int width,int height,int fill);

/*
============================================================================

		    IGRAB Graphic file routines

	 Based on number reported in GRAPHEXT.H header file!

============================================================================
*/

typedef struct
{
  int	width,
	height,
	orgx,orgy,
	xl,yl,xh,yh,
	shifts;
} spritetype;


typedef struct
{
 int width,height;
} pictype;


typedef struct
{
  int height;
  int location[256];
  char width[256];
} fontstruct;


extern unsigned screenseg;		// normally 0xa000
extern unsigned screenofs;		// adjustment for panning and buffers
					// from screenseg for UL corner
extern unsigned screenorigin;		// first byte viable on screen

unsigned extern linewidth;


//
// cachable locations
//

extern memptr	grsegs[NUMCHUNKS];
extern char	needgr[NUMCHUNKS];	// for caching

#if NUMPICS>0
extern pictype	pictable[NUMPICS];
#endif

#if NUMPICM>0
extern pictype	picmtable[NUMPICS];
extern unsigned picmsize[NUMPICS];	// plane size for drawing
#endif

#if NUMSPRITES>0
extern spritetype image, spritetable[NUMSPRITES];
extern unsigned spritesize[NUMSPRITES];	// plane size for drawing
#endif


//
// proportional font stuff
//
#if NUMFONT+NUMFONTM>0
extern unsigned fontcolor,pdrawmode;
extern unsigned px,py;
extern unsigned pxl,pxh,pyl,pyh;
extern fontstruct _seg * fontseg;

void DrawPchar (int picnum);
void DrawMPchar (int picnum);
#endif

//
// base drawing routines, x in bytes, y in lines
//

void DrawChar (int x, int y, int picnum);
void MaskChar (int x, int y, int picnum);
void CopyChar (int x, int y);
void DrawPic (int x, int y, int picnum);
void DrawSprite (int xcoord, int ycoord, int spritenum);
void DrawSpriteT (unsigned wide,unsigned height,unsigned source,
  unsigned dest, unsigned plsize);


/*
============================================================================

** Mid level graphic routines

============================================================================
*/

int extern sx,sy,leftedge, screencenterx ,screencentery, segoffset;

int Get (void);
int Input(char *string,int max);
unsigned InputInt(void);
void Print (const char *str);
void Printxy(int x,int y,char *string);
void PrintC(char *string);
void PrintHexB(unsigned char value);
void PrintHex(unsigned value);
void PrintBin(unsigned value);
void PrintInt (int val);
void PrintLong (long val);

void PPrint (const char *str);
void CPPrint (const char *str);
void PPrintInt (int val);
void PPrintUnsigned (unsigned val);

void DrawWindow (int xl, int yl, int xh, int yh);
void EraseWindow (void);
void CharBar (int xl,int yl, int xh, int yh, int ch);
void CenterWindow (int width, int height);
void ExpWin (int width, int height);
void ExpWinH (int width, int height);
void ExpWinV (int width, int height);
void DrawFrame(int x1,int y1,int x2,int y2,int type);


/*
============================================================================

** Game level routines

============================================================================
*/

long extern score,highscore;
int extern level;

typedef struct { int width;
		 int height;
		 int planes;
		 int screenx;
		 int screeny;
		 int screenw;
		 int screenh;
		 unsigned planesize;
	       } LevelDef;

LevelDef extern	far *levelheader;
unsigned extern	far *mapplane[4];		// points into map
int	extern	mapbwide,mapwwide,mapwidthextra,mapheight;


//
// get / set a tile value in the map
//
#define SETTILE(x,y,plane,value) *(mapplane[plane]+((y)*(unsigned)mapwwide+(x)))=value
#define GETTILE(x,y,plane) (*(mapplane[plane]+((y)*(unsigned)mapwwide+(x)) ))


void LoadCtrls (void);
void SaveCtrls (void);

/*
============================================================================

** Needed non library routines

============================================================================
*/

void Quit (char *);
void PatchPointers (void);	// called after the memory manager sorts blocks
