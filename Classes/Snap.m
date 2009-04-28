//
//  Snap.m
//  WhatJustPlayed
//
//  Created by Ian Dees on 4/28/09.
//  Copyright 2009 Ian Dees. All rights reserved.
//

#import "Snap.h"


@implementation Snap


@synthesize createdAt;

- (id) initWithStation:(NSString*)newStation creationTime:(NSDate*)when;
{
	self = [super init];
	if (self != nil) {
		station = [newStation retain];
		createdAt = [when retain];
	}
	return self;
}

- (id) initWithStation:(NSString*)newStation;
{
	return [self initWithStation:newStation creationTime:[NSDate date]];
}

- (id) init
{
	return [self initWithStation:@""];
}


- (NSString*) title;
{
	return station;
}

- (NSString*) subtitle;
{
	NSDateFormatter *dateFormat =
		[[[NSDateFormatter alloc] init] autorelease];
	[dateFormat setDateStyle:NSDateFormatterNoStyle];
	[dateFormat setTimeStyle:NSDateFormatterShortStyle];
	
	return [dateFormat stringFromDate:createdAt];
}

- (BOOL) needsLookup;
{
	return YES;
}

- (void) dealloc
{
	[station release];
	[createdAt release];
	[super dealloc];
}


@end
