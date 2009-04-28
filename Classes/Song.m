//
//  Song.m
//  WhatJustPlayed
//
//  Created by Ian Dees on 4/28/09.
//  Copyright 2009 Ian Dees. All rights reserved.
//

#import "Song.h"


@implementation Song

- (id) initWithTitle:(NSString*)newTitle artist:(NSString*)newArtist;
{
	self = [super init];
	if (self != nil) {
		title = [newTitle retain];
		artist = [newArtist retain];
	}
	return self;
}

- (id) init
{
	return [self initWithTitle:@"" artist:@""];
}


- (NSString*) title;
{
	return title;
}

- (NSString*) subtitle;
{
	return artist;
}

- (BOOL) needsLookup;
{
	return NO;
}

- (void) dealloc
{
	[title release];
	[artist release];
	[super dealloc];
}


@end
