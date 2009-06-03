//
//  JustPlayedViewController.h
//  JustPlayed
//
//  Created by Ian Dees on 4/19/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SnapsController;
@class ASINetworkQueue;

@interface JustPlayedViewController :
	UIViewController
		<UITableViewDataSource,
		 UITableViewDelegate,
		 UIActionSheetDelegate>
{
	NSArray* stations;
	SnapsController* snapsController;
	IBOutlet UITableView* snapsTable;
	IBOutlet UIToolbar* toolbar;
	NSString* lookupServer;
	NSDate* testTime;
	ASINetworkQueue* networkQueue;
}

- (void)setStations:(NSArray*)newStations;
- (void)setSnaps:(NSArray*)snaps;

- (void)setToFactoryDefaults;
- (void)loadUserData;
- (void)saveUserData;
- (void)refreshView;

- (IBAction)lookupButtonPressed:(id)sender;
- (IBAction)deleteButtonPressed:(id)sender;

@property (nonatomic, retain) NSArray* stations;
@property (nonatomic, retain) SnapsController* snapsController;

@property (nonatomic, retain) UITableView* snapsTable;
@property (nonatomic, retain) UIToolbar* toolbar;

@property (nonatomic, retain) NSString* lookupServer;
@property (nonatomic, retain) NSDate* testTime;

@end

