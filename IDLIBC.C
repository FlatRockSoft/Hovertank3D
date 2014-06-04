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

#include "IDLIB.H"
#pragma hdrstop

/*
=============================================================================

		  Library, C section

=============================================================================
*/

#define BLANKCHAR	9

char	ch,str[80];	// scratch space


inputtype playermode[3];

int JoyXlow [3], JoyXhigh [3], JoyYlow [3], JoyYhigh [3], buttonflip;

char key[8],keyB1,keyB2;


////////////////////
//
// prototypes
//
////////////////////

void CalibrateJoy (int joynum);
void Printscan (int sc);
void calibratekeys (void);

//=========================================================================



////////////////
//
// CalibrateJoy
// Brings up a dialog and has the user calibrate
// either joystick1 or joystick2
//
////////////////

void CalibrateJoy (int joynum)
{
  int stage,dx,dy,xl,yl,xh,yh;
  ControlStruct ctr;

  ExpWin (34,11);


  fontcolor=13;
  CPPrint("Joystick Configuration\n");
  py+=6;
  fontcolor=15;
  PPrint("Hold the joystick in the UPPER LEFT\n");
  PPrint("corner and press a button:");
  stage=15;
  sx=(px+7)/8;
  do				// wait for a button press
  {
    DrawChar (sx,py,stage);
    WaitVBL (3);
    if (++stage==23)
      stage=15;
    ReadJoystick (joynum,&xl,&yl);
    ctr = ControlJoystick(joynum);
    if (keydown[1])
      return;
  } while (ctr.button1!= 1 && ctr.button2!=1);
   DrawChar(sx,py,BLANKCHAR);
  do                  		// wait for the button release
  {
    ctr = ControlJoystick(joynum);
  } while (ctr.button1);
  WaitVBL (4);			// so the button can't bounce

  py+=6;
  PPrint("\nHold the joystick in the LOWER RIGHT\n");
  PPrint("corner and press a button:");
  do				// wait for a button press
  {
    DrawChar (sx,py,stage);
    WaitVBL (3);
    if (++stage==23)
      stage=15;
    ReadJoystick (joynum,&xh,&yh);
    ctr = ControlJoystick(joynum);
    if (keydown[1])
      return;
  } while (ctr.button1!= 1 && ctr.button2!=1);
  DrawChar (sx,py,BLANKCHAR);
  do                  		// wait for the button release
  {
    ctr = ControlJoystick(joynum);
  } while (ctr.button1);

  //
  // figure out good boundaries
  //

  dx=(xh-xl) / 6;
  dy=(yh-yl) / 6;
  JoyXlow[joynum]=xl+dx;
  JoyXhigh[joynum]=xh-dx;
  JoyYlow[joynum]=yl+dy;
  JoyYhigh[joynum]=yh-dy;
  if (joynum==1)
    playermode[1]=joystick1;
  else
    playermode[1]=joystick2;

  py+=6;
  PPrint ("\n(F)ire or (A)fterburn with B1 ?");
  ch = PGet();
  if ( ch == 'A' || ch == 'a')
    buttonflip = 1;
  else
    buttonflip = 0;
}

/////////////////////////////
//
// print a representation of the scan code key
//
////////////////////////////
void printscan (int sc)
{
 char static chartable[128] =
 {'?','?','1','2','3','4','5','6','7','8','9','0','-','+','?','?',
  'Q','W','E','R','T','Y','U','I','O','P','[',']','|','?','A','S',
  'D','F','G','H','J','K','L',';','"','?','?','?','Z','X','C','V',
  'B','N','M',',','.','/','?','?','?','?','?','?','?','?','?','?',
  '?','?','?','?','?','?','?','?', 15,'?','-', 21,'5', 17,'+','?',
   19,'?','?','?','?','?','?','?','?','?','?','?','?','?','?','?',
  '?','?','?','?','?','?','?','?','?','?','?','?','?','?','?','?',
  '?','?','?','?','?','?','?','?','?','?','?','?','?','?','?','?'};

 sc = sc & 0x7f;

 if (sc==1)
   PPrint ("ESC");
 else if (sc==0xe)
   PPrint ("BKSP");
 else if (sc==0xf)
   PPrint ("TAB");
 else if (sc==0x1d)
   PPrint ("CTRL");
 else if (sc==0x2A)
   PPrint ("LSHIFT");
 else if (sc==0x39)
   PPrint ("SPACE");
 else if (sc==0x3A)
   PPrint ("CAPSLK");
 else if (sc>=0x3b && sc<=0x44)
 {
   char str[3];
   PPrint ("F");
   itoa (sc-0x3a,str,10);
   PPrint (str);
 }
 else if (sc==0x57)
   PPrint ("F11");
 else if (sc==0x59)
   PPrint ("F12");
 else if (sc==0x46)
   PPrint ("SCRLLK");
 else if (sc==0x1c)
   PPrint ("ENTER");
 else if (sc==0x36)
   PPrint ("RSHIFT");
 else if (sc==0x37)
   PPrint ("PRTSC");
 else if (sc==0x38)
   PPrint ("ALT");
 else if (sc==0x47)
   PPrint ("HOME");
 else if (sc==0x49)
   PPrint ("PGUP");
 else if (sc==0x4f)
   PPrint ("END");
 else if (sc==0x51)
   PPrint ("PGDN");
 else if (sc==0x52)
   PPrint ("INS");
 else if (sc==0x53)
   PPrint ("DEL");
 else if (sc==0x45)
   PPrint ("NUMLK");
 else if (sc==0x48)
   PPrint ("UP");
 else if (sc==0x50)
   PPrint ("DOWN");
 else if (sc==0x4b)
   PPrint ("LEFT");
 else if (sc==0x4d)
   PPrint ("RIGHT");
 else
 {
   str[0]=chartable[sc];
   str[1]=0;
   PPrint (str);
 }
}

/////////////////////////////
//
// calibratekeys
//
////////////////////////////
void calibratekeys (void)
{
  char ch;
  int hx,hy,i,select,new;

  ExpWin (22,12);
  fontcolor=13;
  CPPrint ("Keyboard Configuration");
  fontcolor=15;
  PPrint ("\n1 north");
  PPrint ("\n2 east");
  PPrint ("\n3 south");
  PPrint ("\n4 west");
  PPrint ("\n5 button1");
  PPrint ("\n6 button2");
  PPrint ("\nModify which action:");
  hx=(px+7)/8;
  hy=py;
  for (i=0;i<4;i++)
  {
    px=pxl+8*12;
    py=pyl+10*(1+i);
    PPrint(":");
    printscan (key[i*2]);
  }
  px=pxl+8*12;
  py=pyl+10*5;
  PPrint(":");
  printscan (keyB1);
  px=pxl+8*12;
  py=pyl+10*6;
  PPrint(":");
  printscan (keyB2);

  do
  {
    px=hx*8;
    py=hy;
    DrawChar (hx,hy,BLANKCHAR);
    ch=PGet() % 256;
    if (ch<'1' || ch>'6')
      continue;
    select = ch - '1';
    DrawPchar (ch);
    PPrint ("\nPress the new key:");
    ClearKeys ();
    new=-1;
    while (!keydown[++new])
      if (new==0x79)
	new=-1;
      else if (new==0x29)
	new++;				// skip STUPID left shifts!
    Bar(leftedge,py,22,10,0xff);
    if (select<4)
      key[select*2]=new;
    if (select==4)
      keyB1=new;
    if (select==5)
      keyB2=new;
    px=pxl+8*12;
	py=pyl+(select+1)*10;
    Bar(px/8,py,9,10,0xff);
    PPrint (":");
    printscan (new);
    ClearKeys ();
    ch='0';				// so the loop continues
  } while (ch>='0' && ch<='9');
  playermode[1]=keyboard;
}

//=========================================================================

/*
===========================
=
= ControlKBD
=
===========================
*/

ControlStruct ControlKBD ()
{
 int xmove=0,
     ymove=0;
 ControlStruct action;

 if (keydown [key[north]])
  ymove=-1;
 if (keydown [key[east]])
  xmove=1;
 if (keydown [key[south]])
  ymove=1;
 if (keydown [key[west]])
  xmove=-1;

 if (keydown [key[northeast]])
 {
   ymove=-1;
   xmove=1;
 }
 if (keydown [key[northwest]])
 {
   ymove=-1;
   xmove=-1;
 }
 if (keydown [key[southeast]])
 {
   ymove=1;
   xmove=1;
 }
 if (keydown [key[southwest]])
 {
   ymove=1;
   xmove=-1;
 }

  switch (ymove*3+xmove)
 {
   case -4: action.dir = northwest; break;
   case -3: action.dir = north; break;
   case -2: action.dir = northeast; break;
   case -1: action.dir = west; break;
   case  0: action.dir = nodir; break;
   case  1: action.dir = east; break;
   case  2: action.dir = southwest; break;
   case  3: action.dir = south; break;
   case  4: action.dir = southeast; break;
 }

 action.button1 = keydown [keyB1];
 action.button2 = keydown [keyB2];

 return (action);
}


/*
===============================
=
= ReadJoystick
= Just return the resistance count of the joystick
=
===============================
*/

void ReadJoystick (int joynum,int *xcount,int *ycount)
{
 int portval,a1,a2,xbit,ybit;

 if (joynum==1)
 {
  xbit=1;
  ybit=2;
 }
 else
 {
  xbit=4;
  ybit=8;
 }

 *xcount = 0;
 *ycount = 0;

 outportb (0x201,inportb (0x201));	/* start the signal pulse */

 asm cli;

 do
 {
   portval = inportb (0x201);
   a1 = (portval & xbit) != 0;
   a2 = (portval & ybit) != 0;
   *xcount+=a1;
   *ycount+=a2;
 } while ((a1+a2!=0) && (*xcount<500) && (*ycount<500));

 asm sti;
}


/*
=============================
=
= JoyButton
=
= Returns the joystick button pressed, or 0
=
=============================
*/

int JoyButton (void)
{
 int buttons = inportb (0x201);	/* Get all four button status */
 if ((buttons & 0x10) == 0)
   return 1;
 if ((buttons & 0x20) == 0)
   return 2;

 return 0;
}


/*
=============================
=
= ControlJoystick (joy# = 1 / 2)
=
=============================
*/

ControlStruct ControlJoystick (int joynum)
{
 int joyx = 0,joyy = 0,		/* resistance in joystick */
     xmove = 0,
     ymove = 0,
     buttons;
 ControlStruct action;

 ReadJoystick (joynum,&joyx,&joyy);
 if ( (joyx>500) | (joyy>500) )
 {
   joyx=JoyXlow [joynum] + 1;	/* no joystick connected, do nothing */
   joyy=JoyYlow [joynum] + 1;
 }

 if (joyx > JoyXhigh [joynum])
   xmove = 1;
 else if (joyx < JoyXlow [joynum])
   xmove = -1;
 if (joyy > JoyYhigh [joynum])
   ymove = 1;
 else if (joyy < JoyYlow [joynum])
   ymove = -1;

 switch (ymove*3+xmove)
 {
   case -4: action.dir = northwest; break;
   case -3: action.dir = north; break;
   case -2: action.dir = northeast; break;
   case -1: action.dir = west; break;
   case  0: action.dir = nodir; break;
   case  1: action.dir = east; break;
   case  2: action.dir = southwest; break;
   case  3: action.dir = south; break;
   case  4: action.dir = southeast; break;
 }

 buttons = inportb (0x201);	/* Get all four button status */
 if (joynum == 1)
 {
   action.button1 = ((buttons & 0x10) == 0);
   action.button2 = ((buttons & 0x20) == 0);
 }
 else
 {
   action.button1 = ((buttons & 0x40) == 0);
   action.button2 = ((buttons & 0x80) == 0);
 }
 if (buttonflip)
 {
   buttons = action.button1;
   action.button1 = action.button2;
   action.button2 = buttons;
 }
 return (action);
}


/*
=============================
=
= ControlPlayer
=
= Expects a 1 or a 2
=
=============================
*/

ControlStruct ControlPlayer (int player)
{
 ControlStruct ret;

 switch (playermode[player])
 {
   case keyboard : return ControlKBD ();
   case joystick1: return ControlJoystick(1);
   case joystick2: return ControlJoystick(2);
 }

 return ControlKBD();
}


#define DRAWCHAR(x,y,n) DrawChar(x,(y)*8,n)

/*
=============================================================================
**
** Miscellaneous library routines
**
=============================================================================
*/


///////////////////////////////
//
// ClearKeys
// Clears out the bios buffer and zeros out the keydown array
//
///////////////////////////////

void ClearKeys (void)
{
  int i;
  NBKscan=NBKascii=0;
  memset (keydown,0,sizeof(keydown));
}


/*
===============
=
= Ack
=
= Waits for a keypress or putton press
=
===============
*/

void Ack(void)
{
  ControlStruct c;

  ClearKeys();
  while (1)
  {
    if (NBKscan>127)
    {
      NBKscan&=0x7f;
      return;
    }
    c = ControlPlayer(1);
    if (c.button1 || c.button2)
      return;
  }
}


//==========================================================================

/////////////////////////////////////////////////////////
//
// Load a LARGE file into a FAR buffer!
//
/////////////////////////////////////////////////////////
unsigned long LoadFile(char *filename,char huge *buffer)
{
 unsigned handle,flength1=0,flength2=0,buf1,buf2,foff1,foff2,
	  len1,len2;

 buf1=FP_OFF(buffer);
 buf2=FP_SEG(buffer);

asm		mov	WORD PTR foff1,0  	// file offset = 0 (start)
asm		mov	WORD PTR foff2,0

asm		mov	dx,filename
asm		mov	ax,3d00h		// OPEN w/handle (read only)
asm		int	21h
asm		jc	out

asm		mov	handle,ax
asm		mov	bx,ax
asm		xor	cx,cx
asm		xor	dx,dx
asm		mov	ax,4202h
asm		int	21h			// SEEK (find file length)
asm		jc	out

asm		mov	flength1,ax
asm		mov	len1,ax
asm		mov	flength2,dx
asm		mov	len2,dx

asm		mov	bx,handle
asm		xor	cx,cx
asm		xor	dx,dx
asm		mov	ax,4200h
asm		int	21h			// SEEK (to file start)
asm		jc	out

asm		cmp	WORD PTR len2,0			// MULTI-SEGMENTAL?
asm		je      L_2

L_1:

asm		push	ds
asm		mov	bx,handle
asm		mov	cx,8000h		// read 32K chunks
asm		mov	dx,buf1
asm		mov	ax,buf2
asm		mov	ds,ax
asm		mov	ah,3fh			// READ w/handle
asm		int	21h
asm		pop	ds
asm		jc	out

asm		add	buf2,800h
asm		sub	len1,8000h
asm		sbb	WORD PTR len2,0
asm		cmp	WORD PTR len2,0
asm		ja	L_1
asm		cmp	len1,8000h
asm		jae	L_1

L_2:

asm		push	ds
asm		mov	bx,handle
asm		mov	cx,len1
asm		mov	dx,buf1
asm		mov	ax,buf2
asm		mov	ds,ax
asm		mov	ah,3fh			// READ w/handle
asm		int	21h
asm		pop	ds

out:

asm		mov	bx,handle		// CLOSE w/handle
asm		mov	ah,3eh
asm		int	21h


return (flength2*0x10000+flength1);

}


//===========================================================================

/*
==============================================
=
= Save a *LARGE* file far a FAR buffer!
= by John Romero (C) 1990 PCRcade
=
==============================================
*/

void SaveFile(char *filename,char huge *buffer, long size)
{
 unsigned int handle,buf1,buf2,foff1,foff2;

 buf1=FP_OFF(buffer);
 buf2=FP_SEG(buffer);

asm		mov	WORD PTR foff1,0  		// file offset = 0 (start)
asm		mov	WORD PTR foff2,0

asm		mov	dx,filename
asm		mov	ax,3c00h		// CREATE w/handle (read only)
asm		xor	cx,cx
asm		int	21h
asm		jc	out

asm		mov	handle,ax
asm		cmp	word ptr size+2,0	// larger than 1 segment?
asm		je	L2

L1:

asm		push	ds
asm		mov	bx,handle
asm		mov	cx,8000h
asm		mov	dx,buf1
asm		mov	ax,buf2
asm		mov	ds,ax
asm		mov	ah,40h			// WRITE w/handle
asm		int	21h
asm		pop	ds

asm		add	buf2,800h		// bump ptr up 1/2 segment
asm		sub	WORD PTR size,8000h	// done yet?
asm		sbb	WORD PTR size+2,0
asm		cmp	WORD PTR size+2,0
asm		ja	L1
asm		cmp	WORD PTR size,8000h
asm		jae	L1

L2:

asm		push	ds
asm		mov	bx,handle
asm		mov	cx,WORD PTR size
asm		mov	dx,buf1
asm		mov	ax,buf2
asm		mov	ds,ax
asm		mov	ah,40h			// WRITE w/handle
asm		int	21h
asm		pop	ds
asm		jmp	out

out:

asm		mov	bx,handle		// CLOSE w/handle
asm		mov	ah,3eh
asm		int	21h

}

//==========================================================================


/*
====================================
=
= BloadinMM
=
====================================
*/

void BloadinMM (char *filename,memptr *spot)
{
  int handle;
  long length;
  char huge *location;
  char error[80];

  if ( (handle = open (filename,O_BINARY)) != -1 )
  {
    length = filelength (handle);
    MMGetPtr (spot,length);
    close (handle);
    LoadFile (filename,*spot);
  }
  else
  {
    strcpy (error,"BloadinMM: Can't find file ");
    strcat (error,filename);
    Quit (error);
  }
}


/*
========================================
=
= BloadinRLEMM
= Returns a paraligned pointer to a file that has been unpacked off disk
=
========================================
*/

void BloadinRLEMM (char *filename,memptr *spot)
{
  long length;
  memptr org;

  BloadinMM (filename,&org);
  length = *(long _seg *)org;	// rleb compressed length
  MMGetPtr (spot,length);
  RLEBExpand ((unsigned char far *)org,(unsigned char far *)*spot);
  MMFreePtr (&org);
}


/*
========================================
=
= BloadinHUFFMM
= Returns a paraligned pointer to a file that has been unpacked off disk
=
========================================
*/

int useegamem;

void BloadinHUFFMM (char *filename,memptr *spot)
{
  long length;
  memptr org;

  if (useegamem)
  {
    org = (memptr)(0xa000+(linewidth*200)/16);
    LoadFile (filename,MK_FP(org,0));
  }
  else
    BloadinMM (filename,&org);

  length = *(((long _seg *)org)+1);	// huff compressed length
  MMGetPtr (spot,length);
  HuffExpandFile ((unsigned char far *)org,(unsigned char far *)*spot);

  if (!useegamem)
    MMFreePtr (&org);
}


////////////////////////////////////////////////////////////////////
//
// Verify a file's existence
//
////////////////////////////////////////////////////////////////////
long Verify(char *filename)
{
 int handle;
 long size;

 if ((handle=open(filename,O_BINARY))==-1) return 0;
 size=filelength(handle);
 close(handle);
 return size;
}


/*
====================
=
= StopDrive
=
= Stop a floppy drive after sounds have been started
=
====================
*/

void StopDrive (void)
{
  int i;

  for (i=0;i<100;i++)
    CallTimer();
}


/*
============================================================================

	    COMPRESSION routines, see JHUFF.C for more

============================================================================
*/

huffnode nodearray[256];	// 256 nodes is worst case

void OptimizeNodes (huffnode *table);

/*
==================
=
= HuffExpandFile
=
= Expands a file with all needed header info
=
==================
*/

void HuffExpandFile (unsigned char huge *infile,
  unsigned char huge *outfile)
{
  char header[4];
  unsigned tag;
  long length;

  header[0] = *infile;
  header[1] = *(infile+1);
  header[2] = *(infile+2);
  header[3] = *(infile+3);
  if (strncmp (header,"HUFF",4))
    Quit ("Tried to expand a file that isn't HUFF!");

  length = *(long huge *)(infile+4);

  movedata(FP_SEG(infile+8),FP_OFF(infile+8),_DS,(unsigned)&nodearray,1020);
  OptimizeNodes (nodearray);
  HuffExpand (infile+1028,outfile,length,nodearray);
}


/*
===============
=
= OptimizeNodes
=
= Goes through a huffman table and changes the 256-511 node numbers to the
= actular address of the node.  Must be called before HuffExpand
=
===============
*/

void OptimizeNodes (huffnode *table)
{
  huffnode *node;
  int i;

  node = table;

  for (i=0;i<255;i++)
  {
    if (node->bit0 >= 256)
      node->bit0 = (unsigned)(table+(node->bit0-256));
    if (node->bit1 >= 256)
      node->bit1 = (unsigned)(table+(node->bit1-256));
    node++;
  }
}



/*
======================
=
= HuffExpand
=
======================
*/

void HuffExpand (unsigned char huge *source, unsigned char huge *dest,
  long length,huffnode *hufftable)
{
  unsigned bit,byte,node,code;
  unsigned sourceseg,sourceoff,destseg,destoff,endseg,endoff;
  huffnode *nodeon,*headptr;

  headptr = hufftable+254;	// head node is allways node 254

#if0
  bit = 1;
  byte = *source++;

  while (length)
  {
    if (byte&bit)
      code = nodeon->bit1;
    else
      code = nodeon->bit0;

    bit<<=1;
    if (bit==256)
    {
      bit=1;
      byte = *source++;
    }

    if (code<256)
    {
      *dest++=code;
      nodeon=headptr;
      length--;
    }
    else
      nodeon = (huffnode *)code;
  }

#endif

  source++;	// normalize
  source--;
  dest++;
  dest--;

  sourceseg = FP_SEG(source);
  sourceoff = FP_OFF(source);
  destseg = FP_SEG(dest);
  destoff = FP_OFF(dest);

  length--;
//
// al = source byte
// cl = bit in source (1,2,4,8,...)
// dx = code
//
// ds:si source
// es:di dest
// ss:bx node pointer
//

asm     mov	bx,[headptr]
asm	mov	cl,1

asm	mov	si,[sourceoff]
asm	mov	di,[destoff]
asm	mov	es,[destseg]
asm	mov	ds,[sourceseg]

asm	lodsb			// load first byte

expand:
asm	test	al,cl		// bit set?
asm	jnz	bit1
asm	mov	dx,[ss:bx]	// take bit0 path from node
asm	jmp	gotcode
bit1:
asm	mov	dx,[ss:bx+2]	// take bit1 path

gotcode:
asm	shl	cl,1		// advance to next bit position
asm	jnc	sourceup
asm	lodsb
asm	cmp	si,0x10		// normalize ds:si
asm  	jb	sinorm
asm	mov	cx,ds
asm	inc	cx
asm	mov	ds,cx
asm	xor	si,si
sinorm:
asm	mov	cl,1		// back to first bit

sourceup:
asm	or	dh,dh		// if dx<256 its a byte, else move node
asm	jz	storebyte
asm	mov	bx,dx		// next node = (huffnode *)code
asm	jmp	expand

storebyte:
asm	mov	[es:di],dl
asm	inc	di		// write a decopmpressed byte out
asm	mov	bx,[headptr]	// back to the head node for next bit

asm	cmp	di,0x10		// normalize es:di
asm  	jb	dinorm
asm	mov	dx,es
asm	inc	dx
asm	mov	es,dx
asm	xor	di,di
dinorm:

asm	sub	[WORD PTR ss:length],1
asm	jnc	expand
asm  	dec	[WORD PTR ss:length+2]
asm	jns	expand		// when length = ffff ffff, done

asm	mov	ax,ss
asm	mov	ds,ax

}

/*========================================================================*/


/*
======================
=
= RLEWexpand
=
======================
*/
#define RLETAG 0xFEFE

void RLEWExpand (unsigned far *source, unsigned far *dest)
{
  long length;
  unsigned value,count,i;
  unsigned far *start,far *end;

  length = *(long far *)source;
  end = dest + (length)/2;

  source+=2;		// skip length words
//
// expand it
//
  do
  {
    value = *source++;
    if (value != RLETAG)
    //
    // uncompressed
    //
      *dest++=value;
    else
    {
    //
    // compressed string
    //
      count = *source++;
      value = *source++;
      if (dest+count>end)
	Quit("RLEWExpand error!");

      for (i=1;i<=count;i++)
	*dest++ = value;
    }
  } while (dest<end);

}


#define RLEBTAG 0xFE


/*
======================
=
= RLEBExpand
=
======================
*/

void RLEBExpand (unsigned char far *source, unsigned char far *dest)
{
  long length;
  unsigned char value,count;
  unsigned i;
  unsigned char far *start,far *end;

  length = *(long far *)source;
  end = dest + (length);

  source+=4;		// skip length words
//
// expand it
//
  do
  {
    value = *source++;
    if (value != RLEBTAG)
    //
    // uncompressed
    //
      *dest++=value;
    else
    {
    //
    // compressed string
    //
      count = *source++;
      value = *source++;
      for (i=1;i<=count;i++)
	*dest++ = value;
    }
  } while (dest<end);

}


/*
============================================================================

			  GRAPHIC ROUTINES

============================================================================
*/

/*
** Graphic routines
*/

cardtype videocard;

void huge *charptr;		// 8*8 tileset
void huge *tileptr;		// 16*16 tileset
void huge *picptr;		// any size picture set
void huge *spriteptr;		// any size masked and hit rect sprites

grtype grmode;

int bordercolor;

/*
===============
=
= LoadPage
=
= Loads an rleb lbm2pic pic into latch memory
=
===============
*/
void LoadPage(char *filename,unsigned dest)
{
  memptr src;
  unsigned from,source;
  long length;
  int i,j,width,height,xx,x,y,plane;

//
// load the pic in
//

  BloadinHUFFMM (filename,&src);
  StopDrive();

  from = 8;
  width = *((int far *)src+2);
  height = *((int far *)src+3);
  for (i=0;i<4;i++)
  {
    EGAplane(i);
    for (j=0;j<height;j++)
      movedata((unsigned)src,from+width*j,0xa000,dest+linewidth*j,width);
   from += width*height;
  }
  MMFreePtr (&src);
}




/*
========================
=
= GenYlookup
=
= Builds ylookup based on linewidth
=
========================
*/

void GenYlookup (void)
{
  int i;

  for (i=0;i<256;i++)
    ylookup[i]=i*linewidth;
}


/*
========================
=
= SetScreenMode
= Call BIOS to set TEXT / CGAgr / EGAgr / VGAgr
=
========================
*/

void SetScreenMode (grtype mode)
{
  switch (mode)
  {
    case text:  _AX = 3;
		geninterrupt (0x10);
		screenseg=0xb000;
		break;
    case CGAgr: _AX = 4;
		geninterrupt (0x10);
		screenseg=0xb800;
		break;
    case EGAgr: _AX = 0xd;
		geninterrupt (0x10);
		screenseg=0xa000;
		break;
#ifdef VGAGAME
    case VGAgr:{
		char extern VGAPAL;	// deluxepaint vga pallet .OBJ file
		void far *vgapal = &VGAPAL;
		SetCool256 ();		// custom 256 color mode
		screenseg=0xa000;
		_ES = FP_SEG(vgapal);
		_DX = FP_OFF(vgapal);
		_BX = 0;
		_CX = 0x100;
		_AX = 0x1012;
		geninterrupt(0x10);			// set the deluxepaint pallet

		break;
#endif
  }
}


/*
========================
=
= egasplitscreen
=
========================
*/

void EGASplitScreen (int linenum)
{
  WaitVBL (1);
  if (videocard==VGAcard)
    linenum=linenum*2-1;
  outportb (CRTC_INDEX,CRTC_LINECOMPARE);
  outportb (CRTC_INDEX+1,linenum % 256);
  outportb (CRTC_INDEX,CRTC_OVERFLOW);
  outportb (CRTC_INDEX+1, 1+16*(linenum/256));
  if (videocard==VGAcard)
  {
    outportb (CRTC_INDEX,CRTC_MAXSCANLINE);
    outportb (CRTC_INDEX+1,inportb(CRTC_INDEX+1) & (255-64));
  }
}


/*
========================
=
= EGAVirtualScreen
=
========================
*/

void EGAVirtualScreen (int width)	// sets screen width
{
  WaitVBL (1);
  outportb(CRTC_INDEX,CRTC_OFFSET);
  outportb(CRTC_INDEX+1,width/2);		// wide virtual screen
}


/*
========================
=
= ColorBorder
=
========================
*/

void ColorBorder (int color)
{
  _AH=0x10;
  _AL=1;
  _BH=color;
  geninterrupt (0x10);        	// color the border
}


/*
========================
=
= crtcstart
=
========================
*/

void CRTCstart (unsigned start)
{
  WaitVBL (1);
  outportb (CRTC_INDEX,CRTC_STARTLOW);
  outportb (CRTC_INDEX+1,start % 256);
  outportb (CRTC_INDEX,CRTC_STARTHIGH);
  outportb (CRTC_INDEX+1,start / 256);
}



////////////////////////////////////////////////////////////////////
//
// Fade EGA screen in
//
////////////////////////////////////////////////////////////////////
 char colors[7][17]=
{{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
 {0,0,0,0,0,0,0,0,0,1,2,3,4,5,6,7,0},
 {0,0,0,0,0,0,0,0,0x18,0x19,0x1a,0x1b,0x1c,0x1d,0x1e,0x1f,0},
 {0,1,2,3,4,5,6,7,0x18,0x19,0x1a,0x1b,0x1c,0x1d,0x1e,0x1f,0},
 {0,1,2,3,4,5,6,7,0x1f,0x1f,0x1f,0x1f,0x1f,0x1f,0x1f,0x1f,0},
 {0x1f,0x1f,0x1f,0x1f,0x1f,0x1f,0x1f,0x1f,0x1f,0x1f,0x1f,0x1f,0x1f,0x1f,0x1f,0x1f,0x1f}};


void SetDefaultColors(void)
{
  colors[3][16] = bordercolor;
  _ES=FP_SEG(&colors[3]);
  _DX=FP_OFF(&colors[3]);
  _AX=0x1002;
  geninterrupt(0x10);
}


void FadeIn(void)
{
 int i;

 for (i=0;i<4;i++)
 {
   colors[i][16] = bordercolor;
   _ES=FP_SEG(&colors[i]);
   _DX=FP_OFF(&colors[i]);
   _AX=0x1002;
   geninterrupt(0x10);
   WaitVBL(6);
 }
}


void FadeUp(void)
{
 int i;

 for (i=3;i<6;i++)
 {
   colors[i][16] = bordercolor;
   _ES=FP_SEG(&colors[i]);
   _DX=FP_OFF(&colors[i]);
   _AX=0x1002;
   geninterrupt(0x10);
   WaitVBL(6);
 }
}

void FadeDown(void)
{
 int i;

 for (i=5;i>2;i--)
 {
   colors[i][16] = bordercolor;
   _ES=FP_SEG(&colors[i]);
   _DX=FP_OFF(&colors[i]);
   _AX=0x1002;
   geninterrupt(0x10);
   WaitVBL(6);
 }
}

void SetNormalPalette(void)
{
 int i;

 colors[3][16] = bordercolor;
 _ES=FP_SEG(&colors[3]);
 _DX=FP_OFF(&colors[3]);
 _AX=0x1002;
 geninterrupt(0x10);
}


////////////////////////////////////////////////////////////////////
//
// Fade EGA screen out
//
////////////////////////////////////////////////////////////////////
void FadeOut(void)
{

 int i;

 for (i=3;i>=0;i--)
 {
   colors[i][16] = bordercolor;
   _ES=FP_SEG(&colors[i]);
   _DX=FP_OFF(&colors[i]);
   _AX=0x1002;
   geninterrupt(0x10);
   WaitVBL(6);
 }
}

/*
====================
=
= SetLineWidth
=
====================
*/

void SetLineWidth (int width)
{
  EGAVirtualScreen(width);
  linewidth = width;
  GenYlookup();
}


/*
============================================================================

			      IGRAB STUFF

============================================================================
*/


memptr	grsegs[NUMCHUNKS];
char	needgr[NUMCHUNKS];	// for caching

#if NUMPICS>0
pictype	pictable[NUMPICS];
#endif

#if NUMPICM>0
pictype	picmtable[NUMPICS];
unsigned picmsize[NUMPICS];	// plane size for drawing
#endif

#if NUMSPRITES>0
spritetype image, spritetable[NUMSPRITES];
unsigned spritesize[NUMSPRITES];	// plane size for drawing
#endif

#if NUMFONTS+NUMFONTSM>0
unsigned fontcolor,pdrawmode;
unsigned px,py;
unsigned pxl,pxh,pyl,pyh;

fontstruct _seg * fontseg;	// used by drawpchar and drawmpchar
#endif



#if NUMSPRITES

/*
============
=
= DrawSprite
=
============
*/

void DrawSprite (int xcoord, int ycoord, int spritenum)
{
  int shapenum;
  unsigned dest;

  shapenum = spritenum;

  switch (spritetable[spritenum].shifts)
  {
    case 2:
      shapenum += (xcoord&7)/4;
      break;
    case 4:
      shapenum += (xcoord&7)/2;
      break;
    case 8:
      shapenum += (xcoord&7);
      break;
  }

  xcoord = (xcoord+64)/8-8;
  dest = ycoord*linewidth+xcoord+screenofs;

  EGAWRITEMODE(0);

  DrawSpriteT (spritetable[shapenum].width,spritetable[shapenum].height,
    (unsigned)grsegs[shapenum+STARTSPRITES],dest,spritesize[shapenum]);
}

#endif


/*
============================================================================

			MID LEVEL GRAPHIC ROUTINES

============================================================================
*/


int win_xl,win_yl,win_xh,win_yh;

int sx,sy,leftedge;

int screencenterx = 20,screencentery = 11;


//////////////////////////
//
// DrawWindow
// draws a bordered window and homes the cursor
//
//////////////////////////

void DrawWindow (int xl, int yl, int xh, int yh)
{
 int x,y;
 win_xl=xl;
 pxl = xl*8+8;
 win_yl=yl;
 win_xh=xh;
 pxh = xh*8;
 win_yh=yh;		// so the window can be erased

 DRAWCHAR (xl,yl,1);
 for (x=xl+1;x<xh;x++)
   DRAWCHAR (x,yl,2);
 DRAWCHAR (xh,yl,3);
 for (y=yl+1;y<yh;y++)
 {
   DRAWCHAR (xl,y,4);
   for (x=xl+1;x<xh;x++)
     DRAWCHAR (x,y,9);
   DRAWCHAR (xh,y,5);
 }
 DRAWCHAR (xl,yh,6);
 for (x=xl+1;x<xh;x++)
   DRAWCHAR (x,yh,7);
 DRAWCHAR (xh,yh,8);

 sx = leftedge = xl+1;
 sy = yl+1;
 px=sx*8;
 py=pyl=sy*8;
}


void EraseWindow (void)
{
 int x,y;

 for (y=win_yl+1;y<win_yh;y++)
   for (x=win_xl+1;x<win_xh;x++)
     DRAWCHAR (x,y,9);

 sx = leftedge = win_xl+1;
 sy = win_yl+1;
 px=sx*8;
 py=pyl=sy*8;
}

/////////////////////////////
//
// CenterWindow
// Centers a DrawWindow of the given size
//
/////////////////////////////

void CenterWindow (int width, int height)
{
  int xl = screencenterx-width/2;
  int yl = screencentery-height/2;

  DrawWindow (xl,yl,xl+width+1,yl+height+1);
}


/////////////////////
//
// CharBar
//
/////////////////////
void CharBar (int xl, int yl, int xh, int yh, int ch)
{
  int x,y;

  for (y=yl;y<=yh;y++)
    for (x=xl;x<=xh;x++)
      DRAWCHAR (x,y,ch);
}



///////////////////////////////
//
// ExpWin {h / v}
// Grows the window outward
//
///////////////////////////////
void ExpWin (int width, int height)
{
  if (width > 2)
  {
    if (height >2)
      ExpWin (width-2,height-2);
    else
      ExpWinH (width-2,height);
  }
  else
    if (height >2)
      ExpWinV (width,height-2);

  WaitVBL (1);
  CenterWindow (width,height);
}

void ExpWinH (int width, int height)
{
  if (width > 2)
    ExpWinH (width-2,height);

  WaitVBL (1);
  CenterWindow (width,height);
}

void ExpWinV (int width, int height)
{
  if (height >2)
    ExpWinV (width,height-2);

  WaitVBL (1);
  CenterWindow (width,height);
}


//////////////////////////////////////////////////
//
// Draw Frame 0/1 (for flashing)
//
//////////////////////////////////////////////////
void DrawFrame(int x1,int y1,int x2,int y2,int type)
{
 int loop;

 type=type*22+1;

 for (loop=x1+1;loop<x2;loop++)
   {
    DRAWCHAR(loop,y1,type+1);
    DRAWCHAR(loop,y2,type+6);
   }
 for (loop=y1+1;loop<y2;loop++)
   {
    DRAWCHAR(x1,loop,type+3);
    DRAWCHAR(x2,loop,type+4);
   }

 DRAWCHAR(x1,y1,type);
 DRAWCHAR(x2,y1,type+2);
 DRAWCHAR(x2,y2,type+7);
 DRAWCHAR(x1,y2,type+5);
}


/////////////////////////
//
// Get
// Flash a cursor at sx,sy and waits for a user NoBiosKey
//
/////////////////////////

int Get (void)
{
 int cycle,key;

 ClearKeys();
 do
 {
   cycle = 9;
   while (!(key = NoBiosKey(1)) && cycle<13)
   {
     DRAWCHAR (sx,sy,cycle++);
     WaitVBL (5);
   }
 } while (key == 0);
 DRAWCHAR (sx,sy,' ');
 return NoBiosKey(0);		// take it out of the buffer
}

/*
===========================================================================

		 CHARACTER BASED PRINTING ROUTINES

===========================================================================
*/


/////////////////////////
//
// Print
// Prints a string at sx,sy.  No clipping!!!
//
/////////////////////////

void Print (const char *str)
{
  unsigned char ch;

  while ((ch=*str++) != 0)
    if (ch == '\n')
    {
      sy++;
      sx=leftedge;
    }
    else if (ch == '\r')
      sx=leftedge;
    else
      DRAWCHAR (sx++,sy,ch);
}


///////////////////////////////////////////////////////////
//
// printxy
//
///////////////////////////////////////////////////////////
void Printxy(int x,int y,char *string)
{
 int osx,osy;

 osx=sx;
 osy=sy;
 sx=x;
 sy=y;
 Print(string);
 sx=osx;
 sy=osy;
}


///////////////////////////
//
// PrintInt / PrintLong
// Converts the value to a string and Prints it
//
///////////////////////////

void PrintInt (int val)
{
  itoa(val,str,10);
  Print (str);
}

void PrintLong (long val)
{
  ltoa(val,str,10);
  Print (str);
}


////////////////////////////////////////////////////////////////////
//
// Print hex byte
//
////////////////////////////////////////////////////////////////////
void PrintHexB(unsigned char value)
{
 int loop;
 char hexstr[16]="0123456789ABCDEF",str[2]="";

 for (loop=0;loop<2;loop++)
   {
    str[0]=hexstr[(value>>(1-loop)*4)&15];
    Print(str);
   }
}




////////////////////////////////////////////////////////////////////
//
// Print hex
//
////////////////////////////////////////////////////////////////////
void PrintHex(unsigned value)
{
 Print("$");
 PrintHexB(value>>8);
 PrintHexB(value&0xff);
}




////////////////////////////////////////////////////////////////////
//
// Print bin
//
////////////////////////////////////////////////////////////////////
void PrintBin(unsigned value)
{
 int loop;

 Print("%");
 for (loop=0;loop<16;loop++)
    if ((value>>15-loop)&1) Print("1"); else Print("0");
}




////////////////////////////////////////////////////////////////////
//
// center Print
//
////////////////////////////////////////////////////////////////////
void PrintC(char *string)
{
 sx=1+screencenterx-(strlen(string)/2);
 Print(string);
}




////////////////////////////////////////////////////////////////////
//
// Input unsigned
//
////////////////////////////////////////////////////////////////////
unsigned InputInt(void)
{
 char string[18]="",digit,hexstr[16]="0123456789ABCDEF";
 unsigned value,loop,loop1;

 Input(string,2);
 if (string[0]=='$')
   {
    int digits;

    digits=strlen(string)-2;
    if (digits<0) return 0;

    for (value=0,loop1=0;loop1<=digits;loop1++)
      {
       digit=toupper(string[loop1+1]);
       for (loop=0;loop<16;loop++)
	  if (digit==hexstr[loop])
	    {
	     value|=(loop<<(digits-loop1)*4);
	     break;
	    }
      }
   }
 else if (string[0]=='%')
   {
    int digits;

    digits=strlen(string)-2;
    if (digits<0) return 0;

    for (value=0,loop1=0;loop1<=digits;loop1++)
      {
       if (string[loop1+1]<'0' || string[loop1+1]>'1') return 0;
       value|=(string[loop1+1]-'0')<<(digits-loop1);
      }
   }
 else value=atoi(string);
 return value;
}




////////////////////////////////////////////////////////////////////
//
// line Input routine (PROPORTIONAL)
//
////////////////////////////////////////////////////////////////////
int Input(char *string,int max)
{
 char key;
 int count=0,loop;
 int pxt[90];

 pxt[0]=px;

 do {
     key=toupper(PGet()&0xff);
     if ((key==127 || key==8)&&count>0)
       {
	count--;
	px=pxt[count];
	DrawPchar(string[count]);
	px=pxt[count];
       }

     if (key>=' ' && key<='z' && count<max)
       {
	*(string+count++)=key;
	DrawPchar(key);
	pxt[count]=px;
       }

    } while (key!=27 && key!=13);

 for (loop=count;loop<max;loop++) *(string+loop)=0;

 if (key==13) return 1;
 return 0;
}

/*
===========================================================================

		 PROPORTIONAL PRINTING ROUTINES

===========================================================================
*/

unsigned pxl,pxh,pyl,pyh;

/////////////////////////
//
// PPrint
// Prints a string at px,py.  No clipping!!!
//
/////////////////////////

void PPrint (const char *str)
{
  unsigned char ch;

  while ((ch=*str++) != 0)
    if (ch == '\n')
    {
      py+=10;
      px=pxl;
    }
    else if (ch == '')
      fontcolor=(*str++)-'A';	// set color A-P
    else
      DrawPchar (ch);
}



/////////////////////////
//
// PGet
// Flash a cursor at px,py and waits for a user NoBiosKey
//
/////////////////////////

int PGet (void)
{
 int oldx;

 oldx=px;

 ClearKeys();
 while (!(NoBiosKey(1)&0xff))
 {
   DrawPchar ('_');
   WaitVBL (5);
   px=oldx;
   DrawPchar ('_');
   px=oldx;
   if (NoBiosKey(1)&0xff)		// slight response improver
     break;
   WaitVBL (5);
 }
 px=oldx;
 return NoBiosKey(0);		// take it out of the buffer
}


/////////////////////////
//
// PSize
// Return the pixels required to proportionaly print a string
//
/////////////////////////

int PSize (const char *str)
{
  int length=0;
  unsigned char ch;

  while ((ch=*str++) != 0)
  {
    if (ch=='')	// skip color changes
    {
      str++;
      continue;
    }
    length += ((fontstruct _seg *)fontseg)->width[ch];
  }

  return length;
}


/////////////////////////
//
// CPPrint
// Centers the string between pxl/pxh
//
/////////////////////////

void CPPrint (const char *str)
{
  int width;

  width = PSize(str);
  px=pxl+(int)(pxh-pxl-width)/2;
  PPrint (str);
}


/////////////////////////
//
// PWarap
// Prints a string at px,py, word wrapping to pxl/pxh
//
/////////////////////////

void PWrap (const char *str)
{
  unsigned char ch;

  while ((ch=*str++) != 0)
    if (ch == '\n')
    {
      py+=10;
      px=leftedge;
    }
    else if (ch == '\r')
      px=leftedge;
    else
      DrawPchar (ch);
}


void PPrintInt (int val)
{
  itoa(val,str,10);
  PPrint (str);
}

void PPrintUnsigned (unsigned val)
{
  ltoa((long)val,str,10);
  PPrint (str);
}

void PPrintLong (long val)
{
  ltoa((long)val,str,10);
  PPrint (str);
}



////////////////////////////////////////////////////////////////////
//
// line Input routine with default string
//
////////////////////////////////////////////////////////////////////
int PInput(char *string,int max)
{
 char key;
 int count,loop,oldx;

 count = strlen(string);
 PPrint (str);

 do {
     key=toupper(PGet()&0xff);
     if ((key==127 || key==8)&&count>0)
       {
	px-= ((fontstruct _seg *)fontseg)->width[ch];
	oldx=px;
	count--;
	DrawPchar(string[count]);
	px=oldx;
       }

     if (key>=' ' && key<='z' && count<max)
       {
	*(string+count++)=key;
	DrawPchar(key);
       }

    } while (key!=27 && key!=13);

 for (loop=count;loop<max;loop++)
   *(string+loop)=0;

 if (key==13)
   return 1;
 return 0;
}



////////////////////////////////////////////////////////////////////
//
// Print hex byte
//
////////////////////////////////////////////////////////////////////
void PPrintHexB(unsigned char value)
{
 int loop;
 char hexstr[16]="0123456789ABCDEF",str[2]="";

 for (loop=0;loop<2;loop++)
   {
    str[0]=hexstr[(value>>(1-loop)*4)&15];
    PPrint(str);
   }
}



////////////////////////////////////////////////////////////////////
//
// Print hex
//
////////////////////////////////////////////////////////////////////
void PPrintHex(unsigned value)
{
 PPrint("$");
 PPrintHexB(value>>8);
 PPrintHexB(value&0xff);
}


/*
===========================================================================

			     GAME ROUTINES

===========================================================================
*/

long score,highscore;
int level,bestlevel;

char far *maprle;

LevelDef far *levelheader;
unsigned far *mapplane[4];		// points into map
int	mapbwide,mapwwide,mapwidthextra,mapheight;


////////////////////////
//
// loadctrls
// Tries to load the control panel settings
// creates a default if not present
//
////////////////////////

void LoadCtrls (void)
{
  int handle;

  if ((handle = open("CTLPANEL."EXTENSION, O_RDONLY | O_BINARY, S_IWRITE | S_IREAD)) == -1)
  //
  // set up default control panel settings
  //
  {
    key[0] = 0x48;
    key[1] = 0x49;
    key[2] = 0x4d;
    key[3] = 0x51;
    key[4] = 0x50;
    key[5] = 0x4f;
    key[6] = 0x4b;
    key[7] = 0x47;
    keyB1 = 0x1d;
    keyB2 = 0x38;
  }
  else
  {
    read(handle, &key, sizeof(key));
	read(handle, &keyB1, sizeof(keyB1));
	read(handle, &keyB2, sizeof(keyB2));
	read(handle, &highscore, sizeof(highscore));
	read(handle, &bestlevel, sizeof(bestlevel));
	close(handle);
  }
}

void SaveCtrls (void)
{
  int handle;

  if ((handle = open("CTLPANEL."EXTENSION, O_WRONLY | O_BINARY | O_CREAT | O_TRUNC, S_IREAD | S_IWRITE)) == -1)
	return;

  write(handle, &key, sizeof(key));
  write(handle, &keyB1, sizeof(keyB1));
  write(handle, &keyB2, sizeof(keyB2));
  write(handle, &highscore, sizeof(highscore));
  write(handle, &bestlevel, sizeof(bestlevel));

  close(handle);
}

