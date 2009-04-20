//
//  SnapsController.h
//  WhatJustPlayed
//
//  Created by Ian Dees on 4/19/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface SnapsController : NSObject {
	NSMutableArray* snaps;
}

- (unsigned)countOfList;
- (id)objectInListAtIndex:(unsigned)theIndex;
- (void)addData:(NSString*)data;
- (void)removeDataAtIndex:(unsigned)theIndex;

@property (nonatomic, copy, readwrite) NSMutableArray* snaps;

@end
