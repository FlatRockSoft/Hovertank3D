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

//==========================================================================

//
// map arrays
//
unsigned tilemap[MAPSIZE][MAPSIZE];


//
// play stuff
//

int godmode,singlestep,leveldone,startlevel,bestlevel;

timetype timestruct;

objtype objlist[MAXOBJECTS],obon,*new,*obj,*lastobj,*check;

ControlStruct c;

int numrefugees,totalrefugees,savedcount,killedcount;

int bordertime;

//
// actor stuff
//
fixed warpx,warpy;	// where to spawn warp gate
fixed xmove,ymove;


#define TIMEPOINTS	100
#define REFUGEEPOINTS	10000

//==========================================================================

void DrawCockpit (void);
void DrawScore (void);
void FindFreeObj (void);
void StartLevel (unsigned far *plane1);
void DropTime (void);
void ClipMove (void);
void Thrust (void);
void Reverse (void);
void AfterBurn (void);
void CalcBounds (void);
void TransformObon (void);

void SpawnPlayer (fixed gx, fixed gy);
void PlayerThink (void);
void SpawnShot (fixed gx, fixed gy, int angle, classtype class);
void ShotThink (void);
void ExplodeThink (void);
void SpawnRefugee (fixed gx, fixed gy, int sex);
void KillRefugee (objtype *hit);
void RefugeeThink (void);
void SpawnDrone (fixed gx, fixed gy);
void DroneThink (void);
void SpawnTank (fixed gx, fixed gy);
void TankThink (void);
void SpawnMutant (fixed gx, fixed gy);
void MutantThink (void);
void SpawnWarp (fixed gx, fixed gy);
void WarpThink (void);

void PlayLoop (void);
void PlayGame (void);

//==========================================================================

/*
==================
=
= DrawCockpit
=
==================
*/

void DrawCockpit (void)
{
  screenofs = 0;

  screencenterx=19;
  screencentery=7;

  EGAWRITEMODE(0);
  DrawPic (0,0,DASHPIC);
  DrawScore ();
}

//==========================================================================

/*
===================
=
= DrawScore
=
===================
*/

void DrawScore (void)
{
  int i;

  ltoa(score,str,10);
  sx = 22-strlen(str);
  sy = 7;
  screenofs = linewidth*2;
  for (i=0;i<strlen(str);i++)
    str[i]-= ('0' - 23);	// the digit pictures start at 23
  Print (str);
  screenofs = 0;
}

//==========================================================================


void BadThink (void)
{
  Quit ("BadThink called!");
}


/*
===============
=
= FindFreeobj
=
= Assigned global variable *new to a free spot in the object list
=
===============
*/

void FindFreeObj (void)
{
  new=&objlist[1];
  while (new->class != nothing && new<=lastobj)
    new++;

  if (new>lastobj)
  {
    lastobj++;
    if (lastobj>=&objlist[MAXOBJECTS])
      Quit("Object list overflow!");
  }

  memset (new,0,sizeof(*new));

  new->think = BadThink;
}


//==========================================================================

/*
==================
=
= StartLevel
=
==================
*/

void StartLevel (unsigned far *plane1)
{
  unsigned x,y,tile,dir;
  int angle;
  fixed gx,gy;

  numrefugees = 0;

  for (y=0;y<levelheader->height;y++)
    for (x=0;x<levelheader->width;x++)
      if ( (tile=*plane1++) > 0 )
      {
	dir = tile>>8;			// high byte gives starting dir
	tile &= 0xff;
	gx = x*TILEGLOBAL+TILEGLOBAL/2;
	gy = y*TILEGLOBAL+TILEGLOBAL/2;
	switch (tile)
	{
	  case 1:
	    SpawnRefugee (gx,gy,1);
	    break;
	  case 2:
	    SpawnDrone (gx+TILEGLOBAL/2,gy+TILEGLOBAL/2);
	    break;
	  case 3:
	    SpawnTank (gx+TILEGLOBAL/2,gy+TILEGLOBAL/2);
	    break;
	  case 4:
	    SpawnMutant (gx+TILEGLOBAL/2,gy+TILEGLOBAL/2);
	    break;
	  case 5:
	    SpawnShield (gx,gy);
	    break;
	  case 6:
	    SpawnRefugee (gx,gy,0);
	    break;
	  case 0xfe:
	    warpx =gx;		// warp gate is spawned when all men are done
	    warpy =gy;
	    break;
	  case 0xff:
	    SpawnPlayer (gx,gy);
	    angle = ANGLES/4-dir*ANGLES/4;
	    if (angle<0)
	      angle+= ANGLES;
	    objlist[0].angle = angle;
	    break;
	}
      }

  totalrefugees = numrefugees;
}


//==========================================================================

/*
=====================
=
= DropTime
=
=====================
*/

void DropTime (void)
{
  static long secondtics;
  int now;

  secondtics+= tics;
  if (secondtics<70)
    return;

  secondtics=0;			// give the slow systems a little edge

  if (--timestruct.sec<0)
  {
    timestruct.sec = 59;
    if (--timestruct.min<0)
      leveldone = -1;
    else
//
// draw new minutes
//
      DrawPic (6,48,DIGIT0PIC+timestruct.min);
  }
//
// draw new seconds
//
  DrawPic (9,48,DIGIT0PIC+timestruct.sec/10);
  DrawPic (11,48,DIGIT0PIC+timestruct.sec%10);

  if (timestruct.min==0 && timestruct.sec<=20)
    PlaySound (LOWTIMESND);
}

//==========================================================================

/*
===================
=
= ClipMove
=
= Only checks corners, so the object better be less than one tile wide!
=
===================
*/

void ClipMove (void)
{
  int	xl,yl,xh,yh,tx,ty,nt1,nt2;
  long	intersect,basex,basey,pointx,pointy;
  unsigned inside,total;

//
// move player and check to see if any corners are in solid tiles
//

  if (xmove<0)
    xmove=-(xmove^SIGNBIT);
  if (ymove<0)
    ymove=-(ymove^SIGNBIT);

  obon.x += xmove;
  obon.y += ymove;

  CalcBounds ();

  xl = obon.xl>>TILESHIFT;
  yl = obon.yl>>TILESHIFT;

  xh = obon.xh>>TILESHIFT;
  yh = obon.yh>>TILESHIFT;


  if (!tilemap[xl][yl] && !tilemap[xh][yl]
  && !tilemap[xh][yh] && !tilemap[xl][yh] )
    return;		// no corners in wall

  if (!SoundPlaying())
    PlaySound (BUMPWALLSND);


//
// intersect the path with the tile edges to determine point of impact
//

//
// clip to east / west walls
//
  if (xmove>0)
  {
    inside = obon.xh & 0xffff;
    total = xmove;
    if (inside<=total)
    {
      if (total>1)
	intersect = ymove*inside/(total-1);
      else
	intersect = ymove;
      nt1 = (obon.yl-intersect)>>TILESHIFT;
      nt2 = (obon.yh-intersect)>>TILESHIFT;
      if ( ( tilemap[xh][nt1] && !tilemap[xh-1][nt1] )
	|| ( tilemap[xh][nt2] && !tilemap[xh-1][nt2] ) )
	obon.x = (obon.xh & 0xffff0000) - (MINDIST + 1);
    }
  }
  else if (xmove<0)
  {
    inside = TILEGLOBAL- (obon.xl & 0xffff);
    total = -xmove;
    if (inside<=total)
    {
      if (total>1)
	intersect = ymove*inside/(total-1);
      else
	intersect = ymove;
      nt1 = (obon.yl-intersect)>>TILESHIFT;
      nt2 = (obon.yh-intersect)>>TILESHIFT;
      if ( ( tilemap[xl][nt1] && !tilemap[xl+1][nt1] )
	|| ( tilemap[xl][nt2] && !tilemap[xl+1][nt2] ) )
	obon.x = (obon.xl & 0xffff0000) + TILEGLOBAL + (MINDIST + 1);
    }
  }

//
// clip to north / south walls
//
  if (ymove>0)
  {
    inside = obon.yh & 0xffff;
    total = ymove;
    if (inside<=total)
    {
      if (total>1)
	intersect = xmove*inside/(total-1);
      else
	intersect = xmove;
      nt1 = (obon.xl-intersect)>>TILESHIFT;
      nt2 = (obon.xh-intersect)>>TILESHIFT;
      if ( ( tilemap[nt1][yh] && !tilemap[nt1][yh-1] )
	|| ( tilemap[nt2][yh] && !tilemap[nt2][yh-1] ) )
	obon.y = (obon.yh & 0xffff0000) - (MINDIST + 1);
    }
  }
  else if (ymove<0)
  {
    inside = TILEGLOBAL- (obon.yl & 0xffff);
    total = -ymove;
    if (inside<=total)
    {
      if (total>1)
	intersect = xmove*inside/(total-1);
      else
	intersect = xmove;
      nt1 = (obon.xl-intersect)>>TILESHIFT;
      nt2 = (obon.xh-intersect)>>TILESHIFT;
      if ( ( tilemap[nt1][yl] && !tilemap[nt1][yl+1] )
	|| ( tilemap[nt2][yl] && !tilemap[nt2][yl+1] ) )
	obon.y = (obon.yl & 0xffff0000) + TILEGLOBAL + (MINDIST + 1);
    }
  }

}


//==========================================================================

/*
==================
=
= CalcBounds
=
==================
*/
void CalcBounds (void)
{
//
// calculate hit rect
//
  obon.xl = obon.x - obon.size;
  obon.xh = obon.x + obon.size;
  obon.yl = obon.y - obon.size;
  obon.yh = obon.y + obon.size;
}

void CalcBoundsNew (void)
{
//
// calculate hit rect
//
  new->xl = new->x - new->size;
  new->xh = new->x + new->size;
  new->yl = new->y - new->size;
  new->yh = new->y + new->size;
}

//==========================================================================

/*
==================
=
= TransformObon
=
= Calculates transformed position and updates radar
=
==================
*/

void TransformObon (void)
{
  int ratio,screenx,pixelscale;
  fixed gx,gy,gxt,gyt;
  long absdx,absdy;

//
// translate point to view centered coordinates
//
  gx = FixedAdd(obon.x,viewx|SIGNBIT);
  gy = FixedAdd(obon.y,viewy|SIGNBIT);

//
// calculate newx
//
  gxt = FixedByFrac(gx,viewcos);
  gyt = FixedByFrac(gy,viewsin);
  obon.viewx = FixedAdd(gxt,gyt^SIGNBIT);

//
// calculate newy
//
  gxt = FixedByFrac(gx,viewsin);
  gyt = FixedByFrac(gy,viewcos);
  obon.viewy = FixedAdd(gyt,gxt);

//
// update radar
//
  if (obon.radarx)
    XPlot (obon.radarx,obon.radary,obon.radarcolor);

  absdx = obon.viewx&(~SIGNBIT);
  absdy = obon.viewy&(~SIGNBIT);

  if (obon.viewx<0)
    obon.viewx = -absdx;
  if (obon.viewy<0)
    obon.viewy = -absdy;

  if (absdx<RADARRANGE && absdy<RADARRANGE)
  {
    obon.radarx= RADARX + obon.viewy/RADARSCALE;
    obon.radary= RADARY - obon.viewx/RADARSCALE;
    XPlot (obon.radarx,obon.radary,obon.radarcolor);
  }
  else
    obon.radarx = 0;

}


//==========================================================================

/*
=====================
=
= WarpEffect
=
=====================
*/

void Block (x,y,color)
{
  int dest;

  dest = ylookup[y<<3]+x+screenofs;

asm {
	mov	es,[screenseg]
	mov	di,[dest]
	mov	al,[BYTE PTR color]
	mov	[es:di],al
	mov	[es:di+SCREENWIDTH*1],al
	mov	[es:di+SCREENWIDTH*2],al
	mov	[es:di+SCREENWIDTH*3],al
	mov	[es:di+SCREENWIDTH*4],al
	mov	[es:di+SCREENWIDTH*5],al
	mov	[es:di+SCREENWIDTH*6],al
	mov	[es:di+SCREENWIDTH*7],al
  }
}

void Frame(xl,yl,xh,yh,color)
{
  int x,y;

  for (x=xl;x<=xh;x++)
  {
    Block (x,yl,color);
    Block (x,yh,color);
  }
  for (y=yl+1;y<yh;y++)
  {
    Block (xl,y,color);
    Block (xh,y,color);
  }
}

#define NUMCYCLES	3
#define WARPSTEPS	200
#define CYCLETIME	6
#define FOCUS		10

int cyclecolors[NUMCYCLES] = {3,3,11};

void WarpEffect (void)
{
  int i,size;
  long oldtime,time;

  screenofs = screenloc[screenpage];
  SetScreen ( screenofs,0);

  memset (zbuffer,0,sizeof(zbuffer));

  EGAWRITEMODE(2);

  for (size=0;size<8;size++)
  {
    screenofs = screenloc[screenpage];
    Frame (size,size,39-size,15-size,cyclecolors[size%NUMCYCLES]);
    screenofs = screenloc[(screenpage+1)%3];
    Frame (size,size,39-size,15-size,cyclecolors[(size+1)%NUMCYCLES]);
    screenofs = screenloc[(screenpage+2)%3];
    Frame (size,size,39-size,15-size,cyclecolors[(size+2)%NUMCYCLES]);
  }

  oldtime = timecount;

  PlaySound (WARPGATESND);

  do
  {
    time = timecount - oldtime;
    if (time > WARPSTEPS)
      time = WARPSTEPS;

    screenofs = screenloc[(screenpage+ time/CYCLETIME )%3];

    SC_ScaleShape (CENTERX,64,255*FOCUS / (WARPSTEPS+FOCUS-time),
      scalesegs[WARP1PIC+ (time/CYCLETIME)%4] );

    SetScreen (screenloc[(screenpage+ time/CYCLETIME )%3],0);
  } while (time<WARPSTEPS && NBKascii != 27);

  ClearKeys();

  EGAWRITEMODE(0);
  EGABITMASK(255);
}

//==========================================================================

/*
=====================
=
= GameOver
=
=====================
*/

void GameOver (void)
{
  if (level != 21)
  {
    FadeUp();
    CacheDrawPic(DEATHPIC);
    PlaySound (NUKESND);
    FadeDown();
    Ack();
  }

//
// high score?
//

  if (score>highscore)
  {
    PlaySound (HIGHSCORESND);
    ExpWin(18,11);
    py+=3;
    CPPrint ("New High Score!\n");
    py+=5;
    CPPrint ("Score\n");
    ltoa(score,str,10);
    CPPrint (str);
    PPrint ("\n\n");
    CPPrint ("Old\n");
    ltoa(highscore,str,10);
    CPPrint (str);
    PPrint ("\n");
    py+=5;
    CPPrint ("Congratulations!\n");
    CPPrint ("");
    Ack();
    highscore = score;
  }

}

//==========================================================================

/*
=====================
=
= Victory
=
=====================
*/

void Victory (void)
{
  FadeOut();
  CacheDrawPic(ENDPIC);
  FadeIn();
  DrawWindow (0,0,39,6);
  CPPrint ("Crowds of cheering people surround\n");
  CPPrint ("your tank. Cargo lifts deliver your\n");
  CPPrint ("impressive bounty. The crowd quiets\n");
  CPPrint ("as a distinguished man steps forward.\n");

  Ack();
  EraseWindow();

  CPPrint ("'Well done,' says the UFA President.\n");
  CPPrint ("'You have saved many deserving people.'\n");
  CPPrint ("\n");
  CPPrint ("'Mr. Sledge?  I said you've done well.'\n");

  Ack();
  EraseWindow();

  CPPrint ("You ignore him and count the reward\n");
  CPPrint ("again. He says, 'Too bad about those\n");
  CPPrint ("ones you lost...'\n");
  CPPrint ("'What?  I dropped some bills?' you say.\n");

  Ack();

  DrawWindow (10,21,30,24);
  py+=3;
  CPPrint ("Game Over!");

  Ack();
}

//==========================================================================

#include "HOVTEXT.C"

/*
=====================
=
= BaseScreen
=
= Drop off hostages, get score, start new level
=
=====================
*/

void BaseScreen (void)
{
  int i;
  unsigned topofs;

#ifdef TESTCASE
  level++;
  LoadLevel();
  StopDrive();
  return;
#endif


  CachePic (STARTPICS+MISSIONPIC);
//
// cash screen
//
  if (level!=startlevel)	// send them straight into the first level
  {
#ifndef PROFILE
    WarpEffect();
#endif

    CachePic (STARTPICS+UFAPIC);
    DrawPic (0,0,UFAPIC);
    if (killedcount>=savedcount)
    {
      CachePic (STARTPICS+MADUFAPIC);
      DrawPic (0,0,MADUFAPIC);
      MMSetPurge (&grsegs[STARTPICS+MADUFAPIC],3);
    }
    MMSetPurge (&grsegs[STARTPICS+UFAPIC],3);

    pxl= 176;
    pxh= 311;

    py=10;
    CPPrint ("UFA Headquarters\n");
    py += 5;
    PPrint ("Saved:");
    PPrintInt (savedcount);
    PPrint ("\nLost:");
    PPrintInt (killedcount);
    topofs = screenofs;


    py += 5;
    PPrint ("\nSavior reward...");
    screenofs = 0;		// draw into the split screen

    //
    // points for saving refugees
    //
    for (i=1;i<=savedcount;i++)
    {
      DrawPic (1+2*(savedcount-i),6,EMPTYGUYPIC);
      score += REFUGEEPOINTS;
      PlaySound (GUYSCORESND);
      DrawScore ();
#ifndef PROFILE
      if (NBKascii != 27)
	WaitVBL(30);
#endif
    }

    screenofs = topofs;
    py += 5;
    PPrint ("\nTime bonus...\n");
    screenofs = 0;		// draw into the split screen

    //
    // points for time remaining
    //
    while (timestruct.sec || timestruct.min)
    {
      score += TIMEPOINTS;

      if (--timestruct.sec<0)
      {
	timestruct.sec = 59;
	if (--timestruct.min<0)
	{
	  timestruct.sec = timestruct.min = 0;
	}
	DrawPic (6,48,DIGIT0PIC+timestruct.min);
      }
      DrawPic (9,48,DIGIT0PIC+timestruct.sec/10);
      DrawPic (11,48,DIGIT0PIC+timestruct.sec%10);

      if ( !(timestruct.sec%5) )
	PlaySound (TIMESCORESND);
      DrawScore ();
#ifndef PROFILE
      if (NBKascii != 27)
	WaitVBL(2);
#endif
    }

    if (objlist[0].hitpoints<3)
    {
      screenofs = topofs;
      PPrint ("\nRepairing tank...");
      screenofs = 0;		// draw into the split screen
      //
      // heal tank
      //
      while (objlist[0].hitpoints<3 && score>10000)
      {
	score -= 10000;
	DrawScore ();
	HealPlayer ();
#ifndef PROFILE
	if (NBKascii != 27)
	  WaitVBL(60);
#endif
	ColorBorder (0);
	bordertime = 0;
      }
    }

    screenofs = topofs;
    py = 110;
    if (level == NUMLEVELS)
      CPPrint ("Mission completed!");
    else
      CPPrint ("GO TO NEXT SECTOR");

    StopDrive ();

#ifndef PROFILE
    Ack();
#endif

    if (level == NUMLEVELS)
    {
      Victory();
      level++;
      return;
    }
  }

  MMSetPurge (&grsegs[STARTPICS+MISSIONPIC],3);
  MMSortMem();			// push all purgable stuff high for good cache
  FadeOut();

//
// briefing screen
//
  level++;
  LoadLevel();
  StopDrive();

  EGAWRITEMODE(0);
  _fmemset (MK_FP(0xa000,0),0,0xffff);
  EGASplitScreen(200-STATUSLINES);
  SetLineWidth(SCREENWIDTH);
  DrawCockpit();

//
// draw custom dash stuff
//
  DrawPic (1,48,DIGIT0PIC+level/10);
  DrawPic (3,48,DIGIT0PIC+level%10);
  for (i=0;i<numrefugees;i++)
    DrawPic (1+2*i,6,EMPTYGUYPIC);

//
// do mission briefing
//

  screenofs = screenloc[0];
  SetScreen (screenofs,0);
  DrawPic (0,0,MISSIONPIC);

  pxl= 10;
  pxh= 310;

  py = 10;
  CPPrint (levnames[level-1]);

  py=37;
  px=pxl;

  PPrint (levtext[level-1]);

  FadeIn();
  ClearKeys();
#ifndef PROFILE
  Ack();

  WarpEffect();
#endif
}

//==========================================================================



/*
===================
=
= PlayLoop
=
===================
*/

void PlayLoop (void)
{
  do
  {
    c=ControlPlayer(1);

    screenofs = 0;	// draw in split screen (radar, time, etc)

    for (obj = &objlist[0];obj<=lastobj;obj++)
    {
      if (obj->class)
      {
	obon=*obj;
	obon.think();
	*obj=obon;
      }
    }

    DropTime();

    if (keydown[0x57])	// DEBUG!
    {
      DamagePlayer();
      ClearKeys();
    }

    if (bordertime && (bordertime-=tics) <=0)
    {
      bordertime = 0;
      ColorBorder (0);
    }

    FinishView();	// base drawn by player think
    CheckKeys();

  }while (!leveldone);

}



/*
===================
=
= PlayGame
=
===================
*/

int levmin[20] =
{
3,3,4,4,6,
5,5,5,5,5,
7,7,7,7,7,
9,9,9,9,9
};

void PlayGame (void)
{
  int i,xl,yl,xh,yh;
  char num[20];

  level = startlevel = 0;

  if (bestlevel>1)
  {
	ExpWin(28,3);
	py+=6;
	PPrint(" Start at what level (1-");
	itoa(bestlevel,str,10);
	PPrint (str);
	PPrint (")?");
	i = InputInt();
	if (i>=1 && i<=bestlevel)
	{
	  level = startlevel = i-1;
	}
  }

restart:

  resetgame = score = 0;

  do
  {

	lastobj = &objlist[0];

#ifdef TESTCASE
	level = 12;
#endif

	BaseScreen ();
	if (level==21)
	  break;

#ifdef TESTCASE
	objlist[0].x = 3126021;
	objlist[0].y = 522173;
	objlist[0].angle = 170;
#endif

	savedcount = killedcount = 0;

	timestruct.min = levmin[level-1];
	timestruct.sec = 0;
	if (level == 20)
	  timestruct.sec = 59;

    screenofs = 0;
    DrawPic (6,48,DIGIT0PIC+timestruct.min);
    DrawPic (9,48,DIGIT0PIC+timestruct.sec/10);
    DrawPic (11,48,DIGIT0PIC+timestruct.sec%10);

    lasttimecount = timecount;
    tics = 1;
    leveldone = 0;

	if (level>bestlevel)
	  bestlevel = level;

	PlayLoop ();

    screenofs = 0;
    for (obj=&objlist[1];obj<lastobj;obj++)
      if (obj->class && obj->radarx)
	XPlot (obj->radarx,obj->radary,obj->radarcolor);

    if (bordertime)
    {
      bordertime = 0;
      ColorBorder (0);
    }

  }
  while (leveldone>0);

  if (resetgame)
    return;

  GameOver();

//
// continue
//

  if (level>2 && level<21)
  {
    DrawWindow (10,20,30,23);
    py+=3;
    CPPrint ("Continue game ?");
    ClearKeys();
    ch = PGet();
    if (toupper(ch)=='Y')
    {
      level--;
      startlevel = level;	// don't show base screen
      goto restart;
    }
  }

}




