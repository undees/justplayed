//
//  WhatJustPlayedViewController.h
//  WhatJustPlayed
//
//  Created by Ian Dees on 4/19/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SnapsController;

@interface WhatJustPlayedViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
	SnapsController* snapsController;
	IBOutlet UITableView* snapsTable;
	NSString* lookupPattern;
	NSDate* testTime;
}

+ (NSString*) defaultLookupPattern;
- (void)setSnaps:(NSArray*) snaps;
- (IBAction)lookupButtonPressed:(id)sender;

@property (nonatomic, retain) SnapsController* snapsController;
@property (nonatomic, retain) UITableView* snapsTable;
@property (nonatomic, retain) NSString* lookupPattern;
@property (nonatomic, retain) NSDate* testTime;

@end

