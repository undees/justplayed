//
//  SnapsController.m
//  WhatJustPlayed
//
//  Created by Ian Dees on 4/19/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SnapsController.h"


@implementation SnapsController

@synthesize snaps;

- (id)init;
{
	if (self = [super init])
	{
		NSMutableArray* newSnaps = [[NSMutableArray alloc] init];
		self.snaps = newSnaps;
		[newSnaps release];
	}

	return self;
}

- (unsigned)countOfList;
{
	return [snaps count];
}

- (id)objectInListAtIndex:(unsigned)theIndex;
{
	return [snaps objectAtIndex:theIndex];
}

- (void)removeDataAtIndex:(unsigned)theIndex;
{
	[snaps removeObjectAtIndex:theIndex];
}

- (void)addData:(NSString*)data;
{
	[snaps insertObject:data atIndex:0];
}

- (void)setSnaps:(NSMutableArray*)newSnaps;
{
	if (snaps != newSnaps)
	{
		[snaps release];
		snaps = [newSnaps mutableCopy];
	}
}

- (void)dealloc;
{
	[snaps release];
	[super dealloc];
}

@end
