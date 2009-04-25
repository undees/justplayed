//
//  WhatJustPlayedViewController.h
//  WhatJustPlayed
//
//  Created by Ian Dees on 4/19/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SnapsController;

@interface WhatJustPlayedViewController : UITableViewController {
	SnapsController* snapsController;
}

@property (nonatomic, retain) SnapsController* snapsController;

@end

