//
//  WhatJustPlayedViewController.m
//  WhatJustPlayed
//
//  Created by Ian Dees on 4/19/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "WhatJustPlayedViewController.h"
#import "SnapsController.h"


const int StationSection = 0;
const int SnapSection = 1;

const int TitleTag = 1;
const int SubtitleTag = 2;

const int StationTag = 3;

NSString* const StationCell = @"StationCell";
NSString* const SnapCell = @"SnapCell";


@implementation WhatJustPlayedViewController


@synthesize snapsController;

- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView
{
	return 2;
}


- (NSString *)tableView:(UITableView*)tableView titleForHeaderInSection:(NSInteger)section
{
	if (StationSection == section)
		return @"Stations";
	else
		return @"Snaps";
}


- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section;
{
	if (StationSection == section)
		return 1;
	else
		return [snapsController countOfList];
}

-(CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath;
{
	return (StationSection == indexPath.section ? 44 : 60);
}


- (void)addSnap;
{
	[snapsController addData:@"Snap"];

	NSIndexPath* path = [NSIndexPath indexPathForRow:0 inSection:SnapSection];
	NSArray* paths = [NSArray arrayWithObject:path];
	UITableView *tv = (UITableView *)self.view;
	[tv insertRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationTop];

	[tv reloadData];
}


- (UITableViewCell*)stationCellWithView:(UITableView*)tableView;
{
	UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:StationCell];
	if (cell == nil)
	{
		CGRect frame = CGRectMake(0, 0, 300, 44);
		cell = [[[UITableViewCell alloc] initWithFrame:frame reuseIdentifier:StationCell] autorelease];

		UIButton* button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		[button setFrame:frame];
		button.tag = StationTag;
		[button addTarget:self action:@selector(addSnap) forControlEvents:UIControlEventTouchUpInside];
		[cell.contentView addSubview:button];
	}

	return cell;
}


- (UITableViewCell*)snapCellWithView:(UITableView*)tableView;
{
	UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:SnapCell];
	if (cell == nil)
	{
		CGRect frame = CGRectMake(0, 0, 290, 60);
		cell = [[[UITableViewCell alloc] initWithFrame:frame reuseIdentifier:SnapCell] autorelease];

		UILabel* snapTitle = [[[UILabel alloc] initWithFrame:CGRectMake(10, 10, 280, 25)] autorelease];
		snapTitle.tag = TitleTag;
		[cell.contentView addSubview:snapTitle];

		UILabel* snapSubtitle = [[[UILabel alloc] initWithFrame:CGRectMake(10, 33, 280, 25)] autorelease];
		snapSubtitle.tag = SubtitleTag;
		snapSubtitle.font = [UIFont systemFontOfSize:12.0];
		snapSubtitle.textColor = [UIColor lightGrayColor];
		[cell.contentView addSubview:snapSubtitle];
	}

	return cell;
}


- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath;
{
	if (StationSection == indexPath.section)
	{
		UITableViewCell* cell = [self stationCellWithView:tableView];
		UIButton* button = (UIButton*)[cell.contentView viewWithTag:StationTag];
		[button setTitle:@"KNRK" forState:UIControlStateNormal];

		return cell;
	}
	else
	{
		UITableViewCell* cell = [self snapCellWithView:tableView];

		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		cell.selectionStyle = UITableViewCellSelectionStyleNone;

		UILabel* snapTitle = (UILabel*)[cell.contentView viewWithTag:TitleTag];
		UILabel* snapSubtitle = (UILabel *)[cell.contentView viewWithTag:SubtitleTag];

		snapTitle.text = @"KNRK";
		snapSubtitle.text = @"now";

		return cell;
	}
}


- (void)viewDidLoad {
    [super viewDidLoad];
	self.snapsController = [[SnapsController alloc] init];
}


- (void)didReceiveMemoryWarning;
{
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

- (void)dealloc;
{
    [super dealloc];
}


@end
