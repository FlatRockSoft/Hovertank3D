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

typedef void _seg * memptr;

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