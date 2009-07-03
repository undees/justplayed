//
//  Snap.m
//  JustPlayed
//
//  Created by Ian Dees on 4/28/09.
//  Copyright 25y26z 2009. See LICENSE.txt for details.
//

#import "Snap.h"


@implementation Snap


@synthesize title, subtitle, createdAt, needsLookup;


// Returns a key/value representation of an array of snaps.
// Used for saving user data.
//
+ (NSArray *)propertyListsFromSnaps:(NSArray *)snaps;
{
	NSMutableArray *array =
		[NSMutableArray arrayWithCapacity:[snaps count]];

	NSEnumerator *e = [snaps objectEnumerator];
	id snap;
	
	while ((snap = [e nextObject]))
	{
		[array addObject:[snap propertyList]];
	}	
	
	return array;
}


// Creates an array of Snap objects from an array
// of dictionaries.  Used for loading user data.
//
+ (NSArray *)snapsFromPropertyLists:(NSArray *)plists;
{
	NSMutableArray *array =
		[NSMutableArray arrayWithCapacity:[plists count]];

	NSEnumerator *e = [plists objectEnumerator];
	id plist;
	
	while ((plist = [e nextObject]))
	{
		[array addObject:[[[Snap alloc] initWithPropertyList:plist] autorelease]];
	}	
	
	return array;
}


// Returns a key/value representation of this Snap.
//
- (NSDictionary *)propertyList;
{
	NSDictionary *plist =
		[NSDictionary dictionaryWithObjectsAndKeys:
			title, @"title",
			subtitle, @"subtitle",
			createdAt, @"createdAt",
			[NSNumber numberWithBool:needsLookup], @"needsLookup", nil];

	return plist;
}


// Initializes a new Snap from a loaded key/value representation.
//
- (id)initWithPropertyList:(NSDictionary *)plist;
{
	if (self = [super init])
	{
		title = [[plist objectForKey:@"title"] retain];
		subtitle = [[plist objectForKey:@"subtitle"] retain];

		NSDate *date = [[plist objectForKey:@"createdAt"] retain];
		createdAt = (date ? date : [[NSDate alloc] init]);

		NSNumber *number = [plist objectForKey:@"needsLookup"];
		needsLookup = (number ? [number boolValue] : YES);
	}
	return self;
}


// Returns the timestamp for this Snap as a wall clock time.
//
- (NSString *)stringFromCreationDate;
{
	NSDateFormatter *dateFormat =
		[[[NSDateFormatter alloc] init] autorelease];
	[dateFormat setDateStyle:NSDateFormatterNoStyle];
	[dateFormat setTimeStyle:NSDateFormatterShortStyle];

	return [dateFormat stringFromDate:createdAt];
}


// Initializes a new Snap where the title and author are already known.
//
- (id)initWithTitle:(NSString *)newTitle artist:(NSString *)newArtist;
{
	if (self = [super init])
	{
		title = [newTitle retain];
		createdAt = [[NSDate alloc] init];
		subtitle = [newArtist retain];
		needsLookup = NO;
	}
	return self;
}


// Initializes a new Snap where only the radio station and time are known.
//
- (id)initWithStation:(NSString *)newStation creationTime:(NSDate *)when;
{
	if (self = [super init])
	{
		title = [newStation retain];
		createdAt = [when retain];
		subtitle = [[self stringFromCreationDate] retain];
		needsLookup = YES;
	}
	return self;
}


// Initializes a new Snap for a radio station playing right now.
//
- (id)initWithStation:(NSString *)newStation;
{
	return [self initWithStation:newStation creationTime:[NSDate date]];
}


// Initializes a new Snap for right now, with no radio station.
//
- (id)init
{
	return [self initWithStation:@""];
}


- (void)dealloc
{
	[title release];
	[subtitle release];
	[createdAt release];
	[super dealloc];
}


@end
