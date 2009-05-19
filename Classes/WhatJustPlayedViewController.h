//
//  WhatJustPlayedViewController.h
//  WhatJustPlayed
//
//  Created by Ian Dees on 4/19/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SnapsController;

@interface WhatJustPlayedViewController :
	UIViewController
		<UITableViewDataSource,
		 UITableViewDelegate,
		 UIActionSheetDelegate>
{
	SnapsController* snapsController;
	IBOutlet UITableView* snapsTable;
	IBOutlet UIToolbar* toolbar;
	NSString* lookupServer;
	NSDate* testTime;
}

+ (NSString*)defaultLookupServer;
- (void)setSnaps:(NSArray*) snaps;
- (void)reloadData;
- (IBAction)lookupButtonPressed:(id)sender;
- (IBAction)deleteButtonPressed:(id)sender;

@property (nonatomic, retain) SnapsController* snapsController;
@property (nonatomic, retain) UITableView* snapsTable;
@property (nonatomic, retain) UIToolbar* toolbar;
@property (nonatomic, retain) NSString* lookupServer;
@property (nonatomic, retain) NSDate* testTime;

@end

