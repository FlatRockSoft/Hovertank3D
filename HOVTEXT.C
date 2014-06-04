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

char *levnames[20] =
{/*......................................*/
  "Zone 1: Langston Research Facility",
  "Zone 2: Gardens of Marvin M. Mitchell",
  "Zone 3: Caves, Brazos de la Madre",
  "Zone 4: Fort Smith",
  "Zone 5: Coyote Canyon",
  "Zone 6: Santa Maria Cathedral",
  "Zone 7: Pax Humana Commune",
  "Zone 8: Sewers below New Trenton",
  "Zone 9: Old UFA Headquarters",
  "Zone 10: Braker's Mountain",
  "Zone 11: Wounded Village",
  "Zone 12: Murder Hill",
  "Zone 13: TerraChem Corp.",
  "Zone 14: Gulf Tech University",
  "Zone 15: Agromatic Inc. Farm",
  "Zone 16: National Agency for Defense",
  "Zone 17: Jackson International Airport",
  "Zone 18: Museum of Modern Art",
  "Zone 19: AUF Headquarters",
  "Zone 20: UFA Headquarters",
};


char *levtext[20] =
{/*......................................*/
  "Your first assignment is to rescue a\n"
  "bunch of scientists who have\n"
  "barracaded themselves inside the\n"
  "Langston Research Facility. They were\n"
  "working on a new, clean fuel until\n"
  "some big oil corporations decided to\n"
  "buy Langston out. Now insiders say\n"
  "the corporation is going to nuke them.\n"

,/*......................................*/
  "The Mitchell estate is home to many of\n"
	"the world's most famous activists,\n"
	"philanthropists, and do-gooders.\n"
	"We've just found out that a group of\n"
	"extremely rich industrialists have\n"
	"funded a tactical strike on the estate\n"
	"after some of the activists irritated\n"
	"some of their interests.\n"

,/*......................................*/
  "A group of terrorists known as The Dark\n"
	"Legion are holding a bunch of children\n"
	"hostage until their demands are met.\n"
	"The goverment has decided, with their\n"
	"usual compassion, to nuke the Legion\n"
	"along with their hostages. Get the\n"
	"hostages out of there.\n"

,/*......................................*/
  "The last renegades of the local\n"
	"resistance are imprisoned for holding\n"
	"rallies and publishing their anti-\n"
	"government pamphlets. A superpower is\n"
	"is planning to nuke Fort Smith for its\n"
	"strategic importance.  We want those\n"
	"renegades.\n"

,/*......................................*/
  "A brilliant scientist and his daughter\n"
	"are living on a missile site in the\n"
	"canyon. The site is a military target,\n"
	"and we want you to get Professor\n"
	"Phillips back safely to Headquarters.\n"

,/*......................................*/
  "A group of priests have been tending\n"
	"the dying at the cathedral, even\n"
	"though their area is likely to be\n"
	"bombed again. The mutants swarming\n"
	"the area are insane.  Be careful!\n"

,/*......................................*/
  "This commune of peace demonstrators is\n"
	"about to be toasted by the NMC -- the\n"
	"National Munitions Corporation. Pax\n"
	"Humana has been a thorn in their side\n"
	"for many years. The thorn is about to\n"
	"be removed...by nuclear means.\n"

,/*......................................*/
  "This city's sewers hold the survivors\n"
	"of the last nuclear attack. Unlucky\n"
	"for them, the last one wasn't the\n"
	"last one....\n"

,/*......................................*/
  "Some operatives remain at the old\n"
	"headquarters after the move, and\n"
	"those looking for us have finally\n"
	"located the old base. You'll have\n"
	"to work fast.\n"

,/*......................................*/
  "A dangerous horde of mutants are\n"
	"holding humans prisoner inside the\n"
	"mountain.  Rescue them before the\n"
	"area is 'sanitized.'\n"

,/*......................................*/
  "Drones have gone rampant and are\n"
	"killing the population of this\n"
	"village.  Before the situation is\n"
	"'gotten under control,' you need to\n"
	"get those people out of there.\n"

,/*......................................*/
  "A tank brigade is hunting down AWOL\n"
	"soldiers. Little do they know that\n"
	"the whole area is about be baked by\n"
	"enemy missiles. Those soldiers have\n"
	"some interesting information that we\n"
	"would like to acquire.\n"

,/*......................................*/
  "There are engineers trapped in the\n"
	"TerraChem building.  Get them back so\n"
	"they can testify against TerraChem.\n"
	"But hurry, the whole building's gonna\n"
	"blow!\n"

,/*......................................*/
  "Terrorists are about to bomb Gulf Tech\n"
	"University off the face of the earth.\n"
	"We haven't been able to reach the\n"
	"scientists there. Get them out of there!\n"

,/*......................................*/
  "The Agromatic Inc. Corporate farm is\n"
	"being nuked by their competitors at\n"
	"at TerraTronic Inc.  Get the innocent\n"
	"farmers to safety.\n"

,/*......................................*/
  "Some of our UFA spies are trapped in\n"
	"NAD headquarters. Rescue them before\n"
	"the enemy missiles get there.\n"

,/*......................................*/
  "The airport is under siege by\n"
	"terrorist forces. Get the civilians \n"
	"out before the Company takes care of\n"
	"the situation.\n"

,/*......................................*/
  "The Museum is going to be bombed by\n"
	"by Dadaists.  The bombing is their\n"
	"form of anti-expression. They've\n"
	"barred the exits and the missiles are\n"
	"coming.  Good luck.\n"

,/*......................................*/
  "Our competitors, the Alliance for a\n"
	"Utopian Future, are getting a little\n"
	"too good to ignore. We're nuking them.\n"
	"However, we really don't want to kill\n"
	"anyone, so get them out of there\n"
	"before our missiles get there.\n"
	"It's just a matter of business, you\n"
	"understand..."

,/*......................................*/
  "The AUF apparently had a backup strike\n"
	"force that we didn't know about. All\n"
	"our people are alerted, but there are\n"
	"a number of people on the lower levels\n"
	"that won't be able to get out in time.\n"
	"Get them quick!  Meet you at Basepoint\n"
	"Delta!\n"

};

