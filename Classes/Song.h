//
//  Song.h
//  WhatJustPlayed
//
//  Created by Ian Dees on 4/28/09.
//  Copyright 2009 Ian Dees. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Song : NSObject {
	NSString* title;
	NSString* artist;
}

- (id) initWithTitle:(NSString*)newTitle artist:(NSString*)artist;
- (NSString*) title;
- (NSString*) subtitle;
- (BOOL) needsLookup;

@end
