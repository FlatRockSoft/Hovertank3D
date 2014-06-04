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

//
//	jm_sb.h
//	Constants, structs, and function prototypes for my SoundBlaster stuff
//
typedef unsigned char byte;
typedef unsigned boolean;


#ifndef	__jm__
#include "jm.h"
#endif

// Registers for the Sound Blaster card - needs to be offset by n0
#define	sbReset		0x206
#define	sbReadData	0x20a
#define	sbWriteCmd	0x20c
#define	sbWriteData	0x20c
#define	sbWriteStat	0x20c
#define	sbDataAvail	0x20e


typedef	struct
		{
			longword	offset,length,
						hertz;
			byte		bits,
						reference;
		} SampledSound;

//
//	Function prototypes
//

extern	void	jmStartSB(void),jmStopSB(void),
				jmSetSBInterrupt(int),
				jmSetSamplePtr(SampledSound huge *),
				jmPlaySample(int),jmStopSample(void);
extern	boolean	jmDetectSoundBlaster(int),
				jmSamplePlaying(void);
