//
//  WhatJustPlayedViewController.m
//  WhatJustPlayed
//
//  Created by Ian Dees on 4/19/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "WhatJustPlayedViewController.h"

@implementation WhatJustPlayedViewController


@synthesize myView;


- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView
{
	return 1;
}


- (NSString *)tableView:(UITableView*)tableView titleForHeaderInSection:(NSInteger)section
{
	return @"Snaps";
}


- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section;
{
	return 0;
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath;
{
	UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
	if (cell == nil)
	{
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"Cell"] autorelease];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}

	cell.text = @"Snap";
	
	return cell;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)dealloc {
    [super dealloc];
}

@end
