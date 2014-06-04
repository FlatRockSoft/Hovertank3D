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

//==========================================================================

#define GUNARM		50
#define GUNCHARGE	70

#define EXPLODEANM	8
#define SHOTSPEED	8192l
#define MSHOTSPEED	6000l

#define REFUGEEANM	30
#define WARPANM		10

#define SPDMUTANT	2500l
#define MUTANTANM	20
#define MUTANTATTACK	120

#define	SPDDRONE	16384l
#define DRONEANM	10

#define TANKRELOAD	200

#define ANGLESTEP	1
#define PLAYERTHRUST	4096l
#define PLAYERREVERSE   2048l
#define PLAYERAFTERBURN	8192l

#define SHIELDANM	10

#define MINCHASE	4096

dirtype opposite[9] =
  {south,southwest,west,northwest,north,northeast,east,southeast,nodir};


//==========================================================================

enum {rearming,ready,charging,maxpower} gunstate;
int guncount;

//==========================================================================

void SpawnPlayer (fixed gx, fixed gy);
void GetRefugee (objtype *hit);
void CheckFire (void);
void DamagePlayer (void);
void Thrust (void);
void Reverse (void);
void AfterBurn (void);
void PlayerThink (void);

void SpawnShot (fixed gx, fixed gy, int angle, classtype class);
void ExplodeShot(void);
int ClipPointMove (void);
void ShotThink (void);
void InertThink (void);
void ExplodeThink (void);

void SpawnWarp (fixed gx, fixed gy);
void WarpThink (void);

void SpawnRefugee (fixed gx, fixed gy,int sex);
void KillRefugee (objtype *hit);
void RefugeeThink (void);

void SpawnDrone (fixed gx, fixed gy);
void KillDrone (objtype *hit);
void DroneThink (void);

void SpawnTank (fixed gx, fixed gy);
void KillTank (objtype *hit);
void AimAtPlayer (void);
void TankThink (void);

void SpawnMutant (fixed gx, fixed gy);
void KillMutant (objtype *hit);
int Walk (void);
void ChaseThing (objtype *chase);
void MutantThink (void);

void SpawnShield (fixed gx, fixed gy);
void ShieldThink (void);

/*
=============================================================================

			   PLAYER

=============================================================================
*/


/*
===================
=
= SpawnPlayer
=
===================
*/

void SpawnPlayer (fixed gx, fixed gy)
{
  objlist[0].x = gx;
  objlist[0].y = gy;
  objlist[0].angle = 0;
  objlist[0].think = PlayerThink;
  objlist[0].class = playerobj;
  objlist[0].size = MINDIST;
  objlist[0].radarcolor = 15;
  objlist[0].hitpoints = 3;

  objlist[0].xl = objlist[0].x - objlist[0].size;
  objlist[0].xh = objlist[0].x + objlist[0].size;
  objlist[0].yl = objlist[0].y - objlist[0].size;
  objlist[0].yh = objlist[0].y + objlist[0].size;

  gunstate = ready;
}


/*
===================
=
= GetRefugee
=
===================
*/

void GetRefugee (objtype *hit)
{
  PlaySound (SAVEHOSTAGESND);
  hit->class = nothing;
  if (hit->radarx)
    XPlot (hit->radarx,hit->radary,hit->radarcolor);
  DrawPic (2*savedcount+1,6,SAVEDGUYPIC);
  savedcount++;
  if (!--numrefugees)
  {
    PlaySound (LASTHOSTAGESND);
    SpawnWarp (warpx,warpy);
  }
}

/*
===================
=
= CheckFire
=
===================
*/

void CheckFire (void)
{
  if (gunstate == rearming)
  {
    if ( (guncount+=tics) > GUNARM)
    {
      gunstate = ready;
      PlaySound(GUNREADYSND);
      DrawPic (14,40,READYPIC);
    }
    return;
  }

  if (c.button1)
  {
  // holding down button
    if (gunstate==ready)
    {
      gunstate = charging;
      DrawPic (14,40,CHARGINGPIC);
      guncount = 0;
    }
    if ( gunstate == charging && (guncount+=tics) > GUNCHARGE)
    {
      PlaySound(MAXPOWERSND);
      gunstate = maxpower;
      DrawPic (14,40,MAXPOWERPIC);
    }
  }
  else
  // button up
    if (gunstate>ready)	// fire small shot if charging, large if maxed
    {
      DrawPic (14,40,REARMINGPIC);
      guncount = 0;
      SpawnShot (obon.x,obon.y,obon.angle,pshotobj+(gunstate-charging));
      gunstate = rearming;
      PlaySound (FIRESND);
    }
}


/*
===================
=
= DamagePlayer
=
===================
*/

void DamagePlayer (void)
{
  PlaySound (TAKEDAMAGESND);
  if (!godmode && !--objlist[0].hitpoints)
  {
    PlaySound(PLAYERDEADSND);
    while (SoundPlaying())
    ;
    leveldone = -1;		// all hit points gone
  }
  else
    DrawPic (24,36,SHIELDLOWPIC+1-objlist[0].hitpoints);
  ColorBorder(12);
  bordertime = 60;
}

void HealPlayer (void)
{
  PlaySound (ARMORUPSND);
  if (objlist[0].hitpoints<3)
    objlist[0].hitpoints++;
  DrawPic (24,36,SHIELDLOWPIC+1-objlist[0].hitpoints);
  ColorBorder(9);
  bordertime = 60;
}


/*
===================
=
= Thrust
=
===================
*/

void Thrust (void)
{
  xmove = FixedByFrac(PLAYERTHRUST*tics,costable[obon.angle]);
  ymove = FixedByFrac(PLAYERTHRUST*tics,sintable[obon.angle])^SIGNBIT;
  ClipMove();
}


/*
===================
=
= Reverse
=
===================
*/

void Reverse (void)
{
  xmove = FixedByFrac(PLAYERREVERSE*tics,costable[obon.angle])^SIGNBIT;
  ymove = FixedByFrac(PLAYERREVERSE*tics,sintable[obon.angle]);
  ClipMove();
}


/*
===================
=
= AfterBurn
=
===================
*/

void AfterBurn (void)
{
  xmove = FixedByFrac(PLAYERAFTERBURN*tics,costable[obon.angle]);
  ymove = FixedByFrac(PLAYERAFTERBURN*tics,sintable[obon.angle])^SIGNBIT;
  ClipMove();
  if (!SoundPlaying())
    PlaySound(AFTERBURNSND);
}

void BeforeBurn (void)
{
  xmove = FixedByFrac(PLAYERAFTERBURN*tics,costable[obon.angle]^SIGNBIT);
  ymove = FixedByFrac(PLAYERAFTERBURN*tics,sintable[obon.angle]);
  ClipMove();
  if (!SoundPlaying())
    PlaySound(AFTERBURNSND);
}


/*
===================
=
= PlayerThink
=
===================
*/

void PlayerThink (void)
{
  int anglechange;
  objtype *check;

  if (c.button1)		// hold down fire for slow adjust
  {
    if (tics<=4)
    {
      anglechange = ANGLESTEP*tics/2;
      if (!anglechange)
	anglechange=1;
    }
    else
      anglechange = ANGLESTEP*2;
  }
  else
    anglechange = ANGLESTEP*tics;

  if (c.dir==west || c.dir==northwest || c.dir==southwest)
  {
    obon.angle+=anglechange;

    if ( obon.angle >= ANGLES )
      obon.angle -= ANGLES;
  }
  else if (c.dir==east || c.dir==northeast || c.dir==southeast)
  {
    obon.angle-=anglechange;

    if ( obon.angle < 0)
      obon.angle += ANGLES;
  }

  if (c.button2 && (c.dir==south || c.dir==southeast || c.dir==southwest) )
    BeforeBurn();
  else if (c.button2)
    AfterBurn();
  else if (c.dir==north || c.dir==northeast || c.dir==northwest)
    Thrust();
  else if (c.dir==south || c.dir==southeast || c.dir==southwest)
    Reverse();

  CheckFire ();

  for (check = &objlist[1];check<=lastobj;check++)
    if
    (check->class
    && check->xl <= obon.xh
    && check->xh >= obon.xl
    && check->yl <= obon.yh
    && check->yh >= obon.yl)
    {
      switch (check->class)
      {
	case refugeeobj:
	  GetRefugee (check);
	  break;

	case shieldobj:
	  objlist[0] = obon;
	  HealPlayer ();
	  obon = objlist[0];
	  check->class = nothing;
	  if (check->radarx)
	    XPlot (check->radarx,check->radary,check->radarcolor);
	  break;

	case warpobj:
	  leveldone = 1;
	  break;
      }
    }

  StartView();			// calculate view position and trace walls
				// FinishView in PlayLoop draws everything
}


/*
=============================================================================

			   SHOTS

=============================================================================
*/

/*
====================
=
= SpawnShot
=
====================
*/

void SpawnShot (fixed gx, fixed gy, int angle, classtype class)
{
  FindFreeObj();
  new->x = gx;
  new->y = gy;
  new->angle = angle;
  new->think = ShotThink;
  new->class = class;
  new->size = TILEGLOBAL/8;
  switch (class)
  {
    case pshotobj:
      new->shapenum = PSHOTPIC;
      new->speed = SHOTSPEED;
      break;
    case pbigshotobj:
      new->shapenum = BIGSHOTPIC;
      new->speed = SHOTSPEED;
      break;
    case mshotobj:
      new->shapenum = MSHOTPIC;
      new->speed = MSHOTSPEED;
      break;
  }
  CalcBoundsNew();
}


/*
===================
=
= ExplodeShot
=
===================
*/

void ExplodeShot(void)
{
  PlaySound (SHOOTWALLSND);
  obon.class = inertobj;
  obon.shapenum = obon.temp1 = SHOTDIE1PIC;
  obon.think = ExplodeThink;
  obon.stage = 0;
  TransformObon();
}


/*
====================
=
= ClipPointMove
=
====================
*/

#define SHOTCLIP	0x1000		// explode 1/16th tile from wall

int ClipPointMove (void)
{
  int xt,yt;
  long xclipdist,yclipdist,intersect,basex,basey;
  unsigned inside,total;

  xmove = FixedByFrac(obon.speed*tics,costable[obon.angle]);
  if (xmove<0)
    xmove=-(xmove^SIGNBIT);
  ymove = FixedByFrac(obon.speed*tics,sintable[obon.angle])^SIGNBIT;
  if (ymove<0)
    ymove=-(ymove^SIGNBIT);

  obon.x += xmove;
  obon.y += ymove;

  xt = obon.x>>TILESHIFT;
  yt = obon.y>>TILESHIFT;
  if (!tilemap[xt][yt])
    return 0;

//
// intersect the path with the tile edges to determine point of impact
//
  basex = obon.x & 0xffff0000;
  basey = obon.y & 0xffff0000;
  obon.x &= 0xffff;	// move origin to ul corner of tile
  obon.y &= 0xffff;

  if (xmove>0)
  {
    inside = obon.x;
    total = xmove;
    intersect = obon.y - ymove*inside/total;
    if (intersect <= TILEGLOBAL)
    {
      obon.x = basex - SHOTCLIP;
      obon.y = basey + intersect;
      return 1;
    }
  }
  else if (xmove<0)
  {
    inside = TILEGLOBAL-obon.x;
    total = -xmove;
    intersect = obon.y - ymove*inside/total;
    if (intersect <= TILEGLOBAL)
    {
      obon.x = basex + TILEGLOBAL + SHOTCLIP;
      obon.y = basey + intersect;
      return 1;
    }
  }

  if (ymove>0)
  {
    inside = obon.y;
    total = ymove;
    intersect = obon.x - xmove*inside/total;
    if (intersect <= TILEGLOBAL)
    {
      obon.x = basex + intersect;
      obon.y = basey - SHOTCLIP;
      return 1;
    }
  }
  else if (ymove < 0)
  {
    inside = TILEGLOBAL-obon.y;
    total = -ymove;
    intersect = obon.x - xmove*inside/total;
    if (intersect <= TILEGLOBAL)
    {
      obon.x = basex + intersect;
      obon.y = basey + TILEGLOBAL + SHOTCLIP;
      return 1;
    }
  }

  return 1;
}


/*
===================
=
= ShotThink
=
===================
*/

void ShotThink (void)
{
  int i,xt,yt;

  objtype *check;

  for (i=0;i<3;i++)	// so it can move over one tile distance
  {
    if (ClipPointMove())
    {
      ExplodeShot();
      return;
    }

    CalcBounds();

    for (check = &objlist[0];check<=lastobj;check++)
      if
      (check->class
      && check->xl <= obon.xh
      && check->xh >= obon.xl
      && check->yl <= obon.yh
      && check->yh >= obon.yl)
      {
	switch (check->class)
	{
	  case playerobj:
	    if (obon.class == mshotobj)
	    {
	      DamagePlayer ();
	      obon.class = nothing;
	      return;
	    }
	    break;

	  case refugeeobj:
	    KillRefugee (check);
	    if (obon.class == pbigshotobj)
	      break;
	    obon.class = nothing;
	    return;

	  case mutantobj:
	    KillMutant (check);
	    if (obon.class == pbigshotobj)
	      break;
	    obon.class = nothing;
	    return;

	  case tankobj:
	    if (obon.class != mshotobj)
	    {
	      KillTank (check);
	      if (obon.class == pbigshotobj)
		break;
	      obon.class = nothing;
	      return;
	    }
	    break;

	  case droneobj:
	    KillDrone (check);
	    if (obon.class == pbigshotobj)
	      break;
	    obon.class = nothing;
	    return;
	}
      }

  }

  TransformObon();
}


/*
==================
=
= InertThink
=
= Corpses, etc...
=
==================
*/

void InertThink (void)
{
  TransformObon();
}


/*
===================
=
= ExplodeThink
=
===================
*/

void ExplodeThink (void)
{
  obon.ticcount+=tics;
  if (obon.ticcount>EXPLODEANM)
  {
    obon.ticcount -= EXPLODEANM;
    if (++obon.stage == 5)
    {
      if (obon.temp1 == SHOTDIE1PIC)	// shopt explosions go away
	obon.class = nothing;
      else
	obon.think = InertThink;
      return;
    }
    obon.shapenum = obon.temp1 + obon.stage;
  }

  TransformObon();
}


/*
=============================================================================

			   WARP GATE

=============================================================================
*/

/*
==================
=
= SpawnWarp
=
==================
*/

void SpawnWarp (fixed gx, fixed gy)
{
  FindFreeObj();
  new->x = gx;
  new->y = gy;
  new->angle = 0;
  new->think = WarpThink;
  new->class = warpobj;
  new->size = MINDIST;
  new->radarcolor = 14;
  new->shapenum = WARP1PIC;
  CalcBoundsNew();
}


/*
===================
=
= WarpThink
=
===================
*/

void WarpThink (void)
{
  obon.ticcount+=tics;
  if (obon.ticcount>WARPANM)
  {
    obon.ticcount -= WARPANM;
    if (++obon.stage == 4)
      obon.stage = 0;
    obon.shapenum = WARP1PIC + obon.stage;
  }

  TransformObon();
}



/*
=============================================================================

			   REFUGEE

=============================================================================
*/

/*
==================
=
= SpawnRefugee
=
= obon.temp2 is true if a drone is seeking it
=
==================
*/

void SpawnRefugee (fixed gx, fixed gy,int sex)
{
  numrefugees++;

  FindFreeObj();
  new->x = gx;
  new->y = gy;
  new->angle = 0;
  new->think = RefugeeThink;
  new->class = refugeeobj;
  new->size = TILEGLOBAL/3;
  new->radarcolor = 15;
  if (sex)
  {
    new->shapenum = MAN1PIC;
    new->temp1 = MAN1PIC;
  }
  else
  {
    new->shapenum = WOMAN1PIC;
    new->temp1 = WOMAN1PIC;
  }
  new->temp2 = 0;
  new->ticcount = Rnd(REFUGEEANM*3);
  CalcBoundsNew();
}



/*
===================
=
= KillRefugee
=
===================
*/

void KillRefugee (objtype *hit)
{
  PlaySound (HOSTAGEDEADSND);
  if (hit->radarx)
    XPlot (hit->radarx,hit->radary,hit->radarcolor);
  killedcount++;
  DrawPic (2*(totalrefugees-killedcount)+1,6,DEADGUYPIC);
  if (!--numrefugees)
  {
    PlaySound (WARPGATESND);
    SpawnWarp (warpx,warpy);
  }

  hit->radarcolor = 0;
  hit->class = inertobj;
  if (hit->temp1 == MAN1PIC)
    hit->shapenum = hit->temp1 = MANDIE1PIC;
  else
    hit->shapenum = hit->temp1 = WOMANDIE1PIC;
  hit->think = ExplodeThink;
  hit->stage = hit->ticcount = 0;
}



/*
===================
=
= RefugeeThink
=
===================
*/

void RefugeeThink (void)
{
  obon.ticcount+=tics;
  if (obon.ticcount>REFUGEEANM)
  {
    obon.ticcount -= REFUGEEANM;
    if (++obon.stage == 2)
      obon.stage = 0;
    obon.shapenum = obon.temp1 + obon.stage;
  }

  TransformObon();
}


/*
=============================================================================

			     DRONE

=============================================================================
*/



/*
==================
=
= SpawnDrone
=
= obon.temp1 is a pointer to the refugee the drone is currently seeking
=
==================
*/

void SpawnDrone (fixed gx, fixed gy)
{
  FindFreeObj();
  new->x = gx;
  new->y = gy;
  new->angle = 0;
  new->think = DroneThink;
  new->class = droneobj;
  new->size = MINDIST;
  new->radarcolor = 10;
  new->hitpoints = 2;
  new->shapenum = DRONE1PIC;
  new->ticcount = Rnd(DRONEANM*3);
  new->temp1 = (int)new;	// will hunt first think
  CalcBoundsNew();
}


/*
===================
=
= KillDrone
=
===================
*/

void KillDrone (objtype *hit)
{
  PlaySound (SHOOTTHINGSND);
  if (hit->radarx)
    XPlot (hit->radarx,hit->radary,hit->radarcolor);

  hit->radarcolor = 0;
  hit->class = inertobj;
  hit->shapenum = hit->temp1 = DRONEDIE1PIC;
  hit->think = ExplodeThink;
  hit->stage = hit->ticcount = 0;
}



/*
==================
=
= DroneLockOn
=
==================
*/

void DroneLockOn (void)
{
  objtype *check;

  for (check=&objlist[2];check<lastobj;check++)
    if (check->class == refugeeobj && !check->temp2)
    {
      check->temp2++;
      obon.temp1 = (int)check;
      return;
    }

  obon.temp1 = (int)&objlist[0];	// go after player last
}

/*
===================
=
= DroneThink
=
===================
*/

void DroneThink (void)
{
  if ( ((objtype *)obon.temp1)->class != refugeeobj &&
       ((objtype *)obon.temp1)->class != playerobj)
    DroneLockOn ();		// target died

  obon.ticcount+=tics;
  if (obon.ticcount>DRONEANM)
  {
    obon.ticcount -= DRONEANM;
    if (++obon.stage == 4)
      obon.stage = 0;
    obon.shapenum = DRONE1PIC + obon.stage;
  }

  ChaseThing ((objtype *)obon.temp1);

  CalcBounds ();

  TransformObon();

  for (check = &objlist[0];check<=lastobj;check++)
    if
    (check->class
    && check->xl <= obon.xh
    && check->xh >= obon.xl
    && check->yl <= obon.yh
    && check->yh >= obon.yl)
    {
      switch (check->class)
      {
	case playerobj:		// kill player and blow up
	  DamagePlayer ();
	  PlaySound (SHOOTTHINGSND);
	  if (obon.radarx)
	    XPlot (obon.radarx,obon.radary,obon.radarcolor);

	  obon.radarcolor = 0;
	  obon.class = inertobj;
	  obon.shapenum = obon.temp1 = DRONEDIE1PIC;
	  obon.think = ExplodeThink;
	  obon.stage = obon.ticcount = 0;
	  return;

	case refugeeobj:
	  KillRefugee (check);
	  break;
      }
    }
}


/*
=============================================================================

			      TANK

=============================================================================
*/


/*
==================
=
= SpawnTank
=
==================
*/

void SpawnTank (fixed gx, fixed gy)
{
  FindFreeObj();
  new->x = gx;
  new->y = gy;
  new->angle = 0;
  new->think = TankThink;
  new->class = tankobj;
  new->size = MINDIST;
  new->shapenum = TANK1PIC;
  new->radarcolor = 13;
  new->hitpoints = 3;
  CalcBoundsNew();
}


/*
===================
=
= KillTank
=
===================
*/

void KillTank (objtype *hit)
{
  PlaySound (SHOOTTHINGSND);
  if (hit->radarx)
    XPlot (hit->radarx,hit->radary,hit->radarcolor);

  hit->radarcolor = 0;
  hit->class = inertobj;
  hit->shapenum = hit->temp1 = TANKDIE1PIC;
  hit->think = ExplodeThink;
  hit->stage = hit->ticcount = 0;
}


/*
======================
=
= AimAtPlayer
=
= Hunt for player
=
======================
*/

void AimAtPlayer (void)
{
  long deltax,deltay;
  int i,xstep,ystep,tx,ty,steps;
  dirtype d[3],tdir, olddir, turnaround;

  olddir=obon.dir;
  turnaround=opposite[olddir];

  deltax=objlist[0].x-obon.x;
  deltay=objlist[0].y-obon.y;

  d[1]=nodir;
  d[2]=nodir;

  if (deltax>MINCHASE)
    d[1]= east;
  else if (deltax<-MINCHASE)
    d[1]= west;
  if (deltay>MINCHASE)
    d[2]=south;
  else if (deltay<-MINCHASE)
    d[2]=north;

  if (LABS(deltay)<LABS(deltax))
  {
    tdir=d[1];
    d[1]=d[2];
    d[2]=tdir;
  }

  if (d[1]==turnaround)
    d[1]=nodir;
  if (d[2]==turnaround)
    d[2]=nodir;

//
// shoot at player if even aim and not reloading
//
  if (d[1]==nodir && !obon.stage)
  {
    xstep = ystep = 0;

    if (deltax>MINCHASE)
    {
      xstep = 1;
      steps = ((objlist[0].x - obon.x)>>TILESHIFT)-1;
      obon.angle = 0;
    }
    else if (deltax<-MINCHASE)
    {
      xstep = -1;
      steps = ((obon.x - objlist[0].x)>>TILESHIFT)-1;
      obon.angle = 180;
    }
    if (deltay>MINCHASE)
    {
      ystep = 1;
      steps = ((objlist[0].y - obon.y)>>TILESHIFT)-1;
      obon.angle = 270;
    }
    else if (deltay<-MINCHASE)
    {
      ystep = -1;
      steps = ((obon.y - objlist[0].y)>>TILESHIFT)-1;
      obon.angle = 90;
    }

    tx = obon.x >> TILESHIFT;
    ty = obon.y >> TILESHIFT;

    for (i=0;i<steps;i++)
    {
      tx += xstep;
      ty += ystep;
      if (tilemap[tx][ty])
	goto cantshoot;			// shot is blocked
    }
    PlaySound (FIRESND);
    SpawnShot (obon.x,obon.y,obon.angle,mshotobj);
    obon.ticcount = 0;
    obon.stage = 1;
  }


  if (d[1]!=nodir)
  {
    obon.dir=d[1];
    if (Walk())
      return;
  }

cantshoot:
  if (d[2]!=nodir)
  {
    obon.dir=d[2];
    if (Walk())
      return;
  }

/* there is no direct path to the player, so pick another direction */

  obon.dir=olddir;
  if (Walk())
    return;

  if (RndT()>128) 	/*randomly determine direction of search*/
  {
    for (tdir=north;tdir<=west;tdir+=2)
      if (tdir!=turnaround)
      {
	obon.dir=tdir;
	if (Walk())
	  return;
      }
  }
  else
  {
    for (tdir=west;tdir>=north;tdir-=2)
      if (tdir!=turnaround)
      {
	obon.dir=tdir;
	if (Walk())
	  return;
      }
  }

  obon.dir=turnaround;
  Walk();		// last chance, don't worry about returned value
}


/*
===================
=
= TankThink
=
===================
*/

void TankThink (void)
{
  if (obon.stage == 1)	// just fired?
  {
    if ( (obon.ticcount += tics) >= TANKRELOAD)
      obon.stage = 0;
  }

  AimAtPlayer ();
  TransformObon();
}


/*
=============================================================================

			      MUTANT

=============================================================================
*/


/*
==================
=
= SpawnMutant
=
==================
*/

void SpawnMutant (fixed gx, fixed gy)
{
  FindFreeObj();
  new->x = gx;
  new->y = gy;
  new->angle = 0;
  new->think = MutantThink;
  new->class = mutantobj;
  new->size = MINDIST;
  new->shapenum = MUTANT1PIC;
  new->radarcolor = 12;
  new->hitpoints = 1;
  new->ticcount = Rnd(MUTANTANM*3);
  CalcBoundsNew();
}



/*
===================
=
= KillMutant
=
===================
*/

void KillMutant (objtype *hit)
{
  PlaySound (SHOOTTHINGSND);
  if (hit->radarx)
    XPlot (hit->radarx,hit->radary,hit->radarcolor);

  hit->radarcolor = 0;
  hit->class = inertobj;
  hit->shapenum = hit->temp1 = MUTANTDIE1PIC;
  hit->think = ExplodeThink;
  hit->stage = hit->ticcount = 0;
}



/*
======================
=
= Walk
=
= Returns true if a movement of obon.dir/obon.speed is ok or causes
= an attack at player
=
======================
*/

#define WALLZONE	(2*TILEGLOBAL/3)

int Walk (void)
{
  int xmove,ymove,xl,yl,xh,yh,xt,yt;

  switch (obon.dir)
  {
    case north:
      xmove = 0;
      ymove = -SPDMUTANT;
      break;
    case east:
      xmove = SPDMUTANT;
      ymove = 0;
      break;
    case south:
      xmove = 0;
      ymove = SPDMUTANT;
      break;
    case west:
      xmove = -SPDMUTANT;
      ymove = 0;
      break;

    default:
      Quit ("Walk: Bad dir!");
  }

  obon.x += xmove;
  obon.y += ymove;

//
// calculate a hit rect to stay away from walls in
//
  obon.xl = obon.x - WALLZONE;
  obon.xh = obon.x + WALLZONE;
  obon.yl = obon.y - WALLZONE;
  obon.yh = obon.y + WALLZONE;

//
// tile coordinate edges
//
  xt = obon.x>>TILESHIFT;
  yt = obon.y>>TILESHIFT;

  xl = obon.xl>>TILESHIFT;
  yl = obon.yl>>TILESHIFT;

  xh = obon.xh>>TILESHIFT;
  yh = obon.yh>>TILESHIFT;

//
// check corners
//
  if (tilemap[xl][yl] || tilemap[xh][yl]
  || tilemap[xl][yh] || tilemap[xh][yh]
  || tilemap[xt][yh] || tilemap[xt][yl]
  || tilemap[xl][yt] || tilemap[xh][yt] )
  {
    obon.x -= xmove;
    obon.y -= ymove;
    return 0;
  }

//
// check contact with player
//

  return 1;
}



/*
======================
=
= ChaseThing
=
= Hunt for player
=
======================
*/

void ChaseThing (objtype *chase)
{
  long deltax,deltay;
  int i;
  dirtype d[3],tdir, olddir, turnaround;

  olddir=obon.dir;
  turnaround=opposite[olddir];

  deltax=chase->x-obon.x;
  deltay=chase->y-obon.y;

  d[1]=nodir;
  d[2]=nodir;

  if (deltax>MINCHASE)
    d[1]= east;
  else if (deltax<-MINCHASE)
    d[1]= west;
  if (deltay>MINCHASE)
    d[2]=south;
  else if (deltay<-MINCHASE)
    d[2]=north;

  if (LABS(deltay)>LABS(deltax))
  {
    tdir=d[1];
    d[1]=d[2];
    d[2]=tdir;
  }

  if (d[1]==turnaround)
    d[1]=nodir;
  if (d[2]==turnaround)
    d[2]=nodir;


  if (d[1]!=nodir)
  {
    obon.dir=d[1];
    if (Walk())
    {
      if (d[2]!=nodir)
      {
	obon.dir=d[2];
	Walk();		// try to go diagonal if possible
      }
      return;
    }
  }

  if (d[2]!=nodir)
  {
    obon.dir=d[2];
    if (Walk())
      return;
  }

/* there is no direct path to the player, so pick another direction */

  obon.dir=olddir;
  if (Walk())
    return;

  if (RndT()>128) 	/*randomly determine direction of search*/
  {
    for (tdir=north;tdir<=west;tdir+=2)
      if (tdir!=turnaround)
      {
	obon.dir=tdir;
	if (Walk())
	  return;
      }
  }
  else
  {
    for (tdir=west;tdir>=north;tdir-=2)
      if (tdir!=turnaround)
      {
	obon.dir=tdir;
	if (Walk())
	  return;
      }
  }

  obon.dir=turnaround;
  Walk();		// last chance, don't worry about returned value
}


/*
===================
=
= MutantThink
=
===================
*/

#define ATTACKZONE	(TILEGLOBAL)

void MutantThink (void)
{
   obon.ticcount += tics;

  if (obon.stage==4)	// attack stage
  {
    if (obon.ticcount < MUTANTATTACK)
    {
      TransformObon();
      return;
    }
    obon.ticcount = MUTANTANM+1-tics;
    obon.stage = 0;
  }

  if (obon.ticcount>MUTANTANM)
  {
    obon.ticcount -= MUTANTANM;
    if (++obon.stage == 4)
      obon.stage = 0;
    obon.shapenum = MUTANT1PIC + obon.stage;
  }

  if (objlist[0].xl <= obon.x + ATTACKZONE
    && objlist[0].xh >= obon.x - ATTACKZONE
    && objlist[0].yl <= obon.y + ATTACKZONE
    && objlist[0].yh >= obon.y - ATTACKZONE)
  {
    obon.stage = 4;
    obon.ticcount = 0;
    obon.shapenum = MUTANTHITPIC;
    DamagePlayer();
  }
  else
    ChaseThing(&objlist[0]);

  CalcBounds ();

  TransformObon();


}

/*
=============================================================================

			      SHIELD

=============================================================================
*/


/*
==================
=
= SpawnShield
=
==================
*/

void SpawnShield (fixed gx, fixed gy)
{
  FindFreeObj();
  new->x = gx;
  new->y = gy;
  new->angle = 0;
  new->think = ShieldThink;
  new->class = shieldobj;
  new->size = MINDIST;
  new->shapenum = SHIELD1PIC;
  new->radarcolor = 9;
  new->hitpoints = 3;
  CalcBoundsNew();
}


/*
===================
=
= ShieldThink
=
===================
*/

void ShieldThink (void)
{
  obon.ticcount += tics;

  if (obon.ticcount>SHIELDANM)
  {
    obon.ticcount -= SHIELDANM;
    if (++obon.stage == 2)
      obon.stage = 0;
    obon.shapenum = SHIELD1PIC + obon.stage;
  }

  TransformObon();
}


