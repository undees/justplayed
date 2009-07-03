//
//  Snap.m
//  JustPlayed
//
//  Created by Ian Dees on 4/28/09.
//  Copyright 2009 Ian Dees. All rights reserved.
//

#import "Snap.h"


@implementation Snap


@synthesize title, subtitle, createdAt, needsLookup;


+ (NSArray*)propertyListsFromSnaps:(NSArray*)snaps;
{
	NSMutableArray* array =
		[NSMutableArray arrayWithCapacity:[snaps count]];

	NSEnumerator *e = [snaps objectEnumerator];
	id snap;
	
	while ((snap = [e nextObject]))
	{
		[array addObject:[snap propertyList]];
	}	
	
	return array;
}

+ (NSArray*)snapsFromPropertyLists:(NSArray*)plists;
{
	NSMutableArray* array =
		[NSMutableArray arrayWithCapacity:[plists count]];

	NSEnumerator *e = [plists objectEnumerator];
	id plist;
	
	while ((plist = [e nextObject]))
	{
		[array addObject:[[[Snap alloc] initWithPropertyList:plist] autorelease]];
	}	
	
	return array;
}

- (NSDictionary*)propertyList;
{
	NSDictionary* plist =
		[NSDictionary dictionaryWithObjectsAndKeys:
			title, @"title",
			subtitle, @"subtitle",
			createdAt, @"createdAt",
			[NSNumber numberWithBool:needsLookup], @"needsLookup", nil];

	return plist;
}

- (id)initWithPropertyList:(NSDictionary*)plist;
{
	if (self = [super init])
	{
		title = [[plist objectForKey:@"title"] retain];
		subtitle = [[plist objectForKey:@"subtitle"] retain];

		NSDate* date = [[plist objectForKey:@"createdAt"] retain];
		createdAt = (date ? date : [[NSDate alloc] init]);

		NSNumber* number = [plist objectForKey:@"needsLookup"];
		needsLookup = (number ? [number boolValue] : YES);
	}
	return self;
}

- (NSString*)stringFromCreationDate;
{
	NSDateFormatter *dateFormat =
		[[[NSDateFormatter alloc] init] autorelease];
	[dateFormat setDateStyle:NSDateFormatterNoStyle];
	[dateFormat setTimeStyle:NSDateFormatterShortStyle];

	return [dateFormat stringFromDate:createdAt];
}

- (id)initWithTitle:(NSString*)newTitle artist:(NSString*)newArtist;
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

- (id)initWithStation:(NSString*)newStation creationTime:(NSDate*)when;
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

- (id)initWithStation:(NSString*)newStation;
{
	return [self initWithStation:newStation creationTime:[NSDate date]];
}

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
