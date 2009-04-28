//
//  Snap.h
//  WhatJustPlayed
//
//  Created by Ian Dees on 4/28/09.
//  Copyright 2009 Ian Dees. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Snap : NSObject {
	NSString* station;
	NSDate* createdAt;
}

@property (nonatomic, readonly, retain) NSDate* createdAt;

- (id) initWithStation:(NSString*)newStation;
- (id) initWithStation:(NSString*)newStation creationTime:(NSDate*)when;
- (NSString*) title;
- (NSString*) subtitle;
- (BOOL) needsLookup;

@end
