//
//  JustPlayedViewController.h
//  JustPlayed
//
//  Created by Ian Dees on 4/19/09.
//  Copyright 25y26z 2009. See LICENSE.txt for details.
//

#import <UIKit/UIKit.h>

@class ASINetworkQueue;

@interface JustPlayedViewController :
	UIViewController
		<UITableViewDataSource,
		 UITableViewDelegate,
		 UIActionSheetDelegate>
{
	NSMutableArray *stations;
	NSMutableArray *snaps;

	IBOutlet UITableView *snapsTable;
	IBOutlet UIToolbar *toolbar;
	IBOutlet UIActivityIndicatorView *downloadProgress;

	NSString *lookupServer;
	NSString *location;
	NSDate *testTime;
	ASINetworkQueue *networkQueue;
}

- (void)setStations:(NSArray *)newStations;
- (void)setSnaps:(NSArray *)newSnaps;

- (void)setToFactoryDefaults;
- (void)loadUserData;
- (void)clearUserData;
- (void)saveUserData;
- (void)refreshView;

- (IBAction)locationButtonPressed:(id)sender;
- (IBAction)lookupButtonPressed:(id)sender;
- (IBAction)deleteButtonPressed:(id)sender;
- (IBAction)helpButtonPressed:(id)sender;

@property (nonatomic, retain) UITableView *snapsTable;
@property (nonatomic, retain) UIToolbar *toolbar;

@property (nonatomic, retain) NSString *lookupServer;
@property (nonatomic, retain) NSString *location;
@property (nonatomic, retain) NSDate *testTime;

@end
