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

/*
**	jm_sb.c
**	Jason's Music routines for games
**	SoundBlaster Stuff
**	v1.0d4
*/

#include <dos.h>

#include "jm_sb.h"

#pragma	warn	-pia	// Because I use if (x = y) alot...

// Macros for SoundBlaster stuff
#define	sbOut(n,b)	outportb((n) + sbLocation,b)
#define	sbIn(n)		inportb((n) + sbLocation)
#define	sbWriteDelay()	while (sbIn(sbWriteStat) & 0x80);
#define	sbReadDelay()	while (sbIn(sbDataAvail) & 0x80);

//
//	Stuff I need
//
static	boolean			sbSamplePlaying = false;
static	byte			sbOldIntMask = -1;
static	byte			huge *sbNextSegPtr;
static	int				sbLocation = -1,sbInterrupt = 7,sbIntVec = 0xf,
						sbIntVectors[] = {-1,-1,0xa,0xb,-1,0xd,-1,0xf};
static	longword		sbNextSegLen;
static	SampledSound	huge *sbSamples;
static	void interrupt	(*sbOldIntHand)(void);

//
//	jmDelay(usec) - Delays for usec micro-seconds
//
static void
jmDelay(int usec)
{
// DEBUG - use real timing routines
	int	i;

	while (usec--)
		for (i = 0;i < 1000;i++)
			;
}

//
//	SoundBlaster code
//

//
//	Plays a chunk of sampled sound
//
static longword
jmPlaySeg(byte huge *data,longword length)
{
	unsigned		datapage;
	longword		dataofs,uselen;

	uselen = length;
	datapage = FP_SEG(data) >> 12;
	dataofs = ( (FP_SEG(data)&0xfff)<<4 ) + FP_OFF(data);
	if (dataofs>=0x10000)
	{
	  datapage++;
	  dataofs-=0x10000;
	}

	if (dataofs + uselen > 0x10000)
		uselen = 0x10000 - dataofs;

	uselen--;	// DEBUG

	// Program the DMA controller
	outportb(0x0a,5);							// Mask off channel 1 DMA
	outportb(0x0c,0);							// Clear byte ptr F/F to lower byte
	outportb(0x0b,0x49);						// Set transfer mode for D/A conv
	outportb(0x02,(byte)dataofs);				// Give LSB of address
	outportb(0x02,(byte)(dataofs >> 8));		// Give MSB of address
	outportb(0x83,(byte)datapage);				// Give page of address
	outportb(0x03,(byte)uselen);				// Give LSB of length
	outportb(0x03,(byte)(uselen >> 8));			// Give MSB of length
	outportb(0x0a,1);							// Turn on channel 1 DMA

	// Start playing the thing
	sbWriteDelay();
	sbOut(sbWriteCmd,0x14);
	sbWriteDelay();
	sbOut(sbWriteData,(byte)uselen);
	sbWriteDelay();
	sbOut(sbWriteData,(byte)(uselen >> 8));

	return(++uselen);
}

//
//	Services the SoundBlaster DMA interrupt
//
void interrupt
jmSBService(void)
{
	longword	used;

	sbIn(sbDataAvail);
	outportb(0x20,0x20);

	if (sbNextSegPtr)
	{
		used = jmPlaySeg(sbNextSegPtr,sbNextSegLen);
		if (sbNextSegLen <= used)
			sbNextSegPtr = nil;
		else
		{
			sbNextSegPtr += used;
			sbNextSegLen -= used;
		}
	}
	else
		jmStopSample();
}

//
//	Plays a sampled sound. Returns immediately and uses DMA to play the sound
//
void
jmPlaySample(sound)
	int	sound;
{
	byte			huge *data,
					timevalue;
	longword		used;
	SampledSound	sample;

	jmStopSample();

	sample = sbSamples[--sound];

	data = ((byte huge *)sbSamples) + sample.offset;
	timevalue = 256 - (1000000 / sample.hertz);

//	printf("sample #%d ",sound);
//	printf("%ld bytes, %ldHz, tc=%d\n",sample.length,sample.hertz,timevalue);

//	printf("setting time constant\n");
	// Set the SoundBlaster DAC time constant
	sbWriteDelay();
	sbOut(sbWriteCmd,0x40);
	sbWriteDelay();
	sbOut(sbWriteData,timevalue);

	used = jmPlaySeg(data,sample.length);
	if (sample.length <= used)
		sbNextSegPtr = nil;
	else
	{
		sbNextSegPtr = data + used;
		sbNextSegLen = sample.length - used;
	}

//	printf("enabling SB irq #%d\n",sbInterrupt);
	// Save old interrupt status and unmask ours
	sbOldIntMask = inportb(0x21);
	outportb(0x21,sbOldIntMask & ~(1 << sbInterrupt));

//	printf("enabling DSP DMA request\n");
	sbWriteDelay();
	sbOut(sbWriteCmd,0xd4);						// Make sure DSP DMA is enabled

//	printf("sound should be playing\n");
	sbSamplePlaying = true;
}

//
//	Stops any active sampled sound and causes DMA to cease
//
void
jmStopSample(void)
{
extern unsigned	SndPriority;
	byte	is;

	if (sbSamplePlaying)
	{
//		printf("turning off DSP DMA\n");
		sbWriteDelay();
		sbOut(sbWriteCmd,0xd0);	// Turn off DSP DMA

//		printf("restoring interrupt\n");
		is = inportb(0x21);	// Restore interrupt mask bit
		if (sbOldIntMask & (1 << sbInterrupt))
			is |= (1 << sbInterrupt);
		else
			is &= ~(1 << sbInterrupt);
		outportb(0x21,is);


		sbSamplePlaying = false;
		SndPriority = 0;	// JC: hack for playsound
	}
}
//
//	Checks to see if a SoundBlaster resides at a particular I/O location
//
static boolean
jmCheckSB(int port)
{
	int	i;

	sbLocation = port << 4;	// Initialize stuff for later use

	sbOut(sbReset,true);	// Reset the SoundBlaster DSP
	jmDelay(4);				// Wait 4usec
	sbOut(sbReset,false);	// Turn off sb DSP reset
	jmDelay(100);			// Wait 100usec
	for (i = 0;i < 100;i++)
	{
		if (sbIn(sbDataAvail) & 0x80)		// If data is available...
		{
			if (sbIn(sbReadData) == 0xaa)	// If it matches correct value
				return(true);
			else
			{
				sbLocation = -1;			// Otherwise not a SoundBlaster
				return(false);
			}
		}
	}
	sbLocation = -1;						// Retry count exceeded - fail
	return(false);
}

//
//	Checks to see if a SoundBlaster is in the system. If the port passed is
//		-1, then it scans through all possible I/O locations. If the port
//		passed is 0, then it uses the default (2). If the port is >0, then
//		it just passes it directly to jmCheckSB()
//
boolean
jmDetectSoundBlaster(int port)
{
	int	i;

	if (port == 0)					// If user specifies default address, use 2
		port = 2;
	if (port == -1)
	{
		for (i = 1;i <= 6;i++)		// Scan through possible SB locations
		{
			if (jmCheckSB(i))		// If found at this address,
				return(true);		//	return success
		}
		return(false);				// All addresses failed, return failure
	}
	else
		return(jmCheckSB(port));	// User specified address or default
}

//
//	Sets the interrupt number that my code expects the SoundBlaster to use
//
void
jmSetSBInterrupt(int num)
{
	sbInterrupt = num;
	sbIntVec = sbIntVectors[sbInterrupt];
}

void
jmStartSB(void)
{
//	printf("setting interrupt #0x%02x handler\n",sbIntVec);
	sbOldIntHand = getvect(sbIntVec);	// Get old interrupt handler
	setvect(sbIntVec,jmSBService);		// Set mine

//	printf("setting DSP modes\n");
	sbWriteDelay();
	sbOut(sbWriteCmd,0xd1);						// Turn on DSP speaker
}

void
jmShutSB(void)
{
	jmStopSample();

//	printf("restoring interrupt vector\n");
	setvect(sbIntVec,sbOldIntHand);	// Set vector back
}

boolean
jmSamplePlaying(void)
{
	return(sbSamplePlaying);
}

void
jmSetSamplePtr(s)
	SampledSound huge *s;
{
	sbSamples = s;
}
