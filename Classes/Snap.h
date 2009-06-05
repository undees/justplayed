//
//  Snap.h
//  JustPlayed
//
//  Created by Ian Dees on 4/28/09.
//  Copyright 2009 Ian Dees. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Snap : NSObject {
	NSString* title;
	NSString* subtitle;
	NSDate* createdAt;
	BOOL needsLookup;
}

@property(nonatomic, readonly, retain) NSString* title;
@property(nonatomic, readonly, retain) NSString* subtitle;
@property(nonatomic, readonly, retain) NSDate* createdAt;
@property(nonatomic, readonly) BOOL needsLookup;

+ (NSArray*)propertyListsFromSnaps:(NSArray*)snaps;
+ (NSArray*)snapsFromPropertyLists:(NSArray*)plists;

- (NSDictionary*)propertyList;
- (id)initWithPropertyList:(NSDictionary*)plist;

- (id)initWithStation:(NSString*)newStation;
- (id)initWithStation:(NSString*)newStation creationTime:(NSDate*)when;
- (id)initWithTitle:(NSString*)newTitle artist:(NSString*)newArtist;


@end
