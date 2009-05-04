//
//  WhatJustPlayedViewController.m
//  WhatJustPlayed
//
//  Created by Ian Dees on 4/19/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "WhatJustPlayedViewController.h"
#import "SnapsController.h"
#import "RegexKitLite.h"


const int StationSection = 0;
const int SnapSection = 1;

const int StationTag = 1;

const int SnapTag = 2;
const int TitleTag = 3;
const int SubtitleTag = 4;

NSString* const StationCell = @"StationCell";
NSString* const SnapCell = @"SnapCell";


@implementation WhatJustPlayedViewController


@synthesize snapsController, snapsTable, toolbar, lookupPattern, testTime;


+ (NSString*) defaultLookupPattern;
{
	/* This is just an example.  Be mindful of your responsibilities with people's servers. */
	return @"http://mobile.yes.com/song.jsp?city=24&station=KNRK_94.7&hm=:time&a=0";	
}


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


- (void)addSnap:(id)sender;
{
	NSString* title = [sender titleForState:UIControlStateNormal];

	NSDate* createdAt =
		self.testTime ?
		self.testTime :
		[NSDate date];

	NSDateFormatter *dateFormat =
		[[[NSDateFormatter alloc] init] autorelease];
	[dateFormat setDateStyle:NSDateFormatterNoStyle];
	[dateFormat setTimeStyle:NSDateFormatterShortStyle];
	
	NSString* subtitle = [dateFormat stringFromDate:createdAt];

	NSDictionary* snap =
		[NSDictionary dictionaryWithObjectsAndKeys:
		 title, @"title",
		 subtitle, @"subtitle",
		 createdAt, @"createdAt",
		 [NSNumber numberWithBool:YES], @"needsLookup",
		 nil];

	[snapsController addData:snap];
	[snapsController saveSnaps];

	NSIndexPath* path = [NSIndexPath indexPathForRow:0 inSection:SnapSection];
	NSArray* paths = [NSArray arrayWithObject:path];
	[snapsTable insertRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationTop];
	[snapsTable reloadData];
}


- (void)setSnaps:(NSArray*) snaps;
{
	[snapsController setSnaps:[NSMutableArray arrayWithArray:snaps]];
	[snapsController saveSnaps];
	[snapsTable reloadData];
}


- (void)reloadData;
{
	NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
	NSArray* snaps = [userDefaults arrayForKey:@"snaps"];
	[self setSnaps:snaps];
}


- (NSString*)songHTMLForStation:(NSString*)station date:(NSDate*)date;
{
	NSDateFormatter* dateFormat = [[[NSDateFormatter alloc]
									initWithDateFormat:@"%H%M" allowNaturalLanguage:NO] autorelease];
	NSString* snappedAt = [dateFormat stringFromDate:date];
	NSString* filledPattern = [lookupPattern stringByReplacingOccurrencesOfString:@":time" withString:snappedAt];
	NSURL* lookupURL = [NSURL URLWithString:filledPattern];

	NSData* data = [NSData dataWithContentsOfURL:lookupURL];
	return [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
}


- (NSString*)titleForResult:(NSString*)result;
{
	NSString* regex = @"<td>([^\\<]+)<br\\/>";
	NSRange range = [result rangeOfRegex:regex capture:1];
	if (range.length > 0)
	{
		return [result substringWithRange:range];
	}
	else
	{
		return nil;
	}
}


- (NSString*)artistForResult:(NSString*)result;
{
	NSString* regex = @"<br\\/>by ([^\\<]+)<br\\/>";
	NSRange range = [result rangeOfRegex:regex capture:1];
	if (range.length > 0)
	{
		return [result substringWithRange:range];
	}
	else
	{
		return nil;
	}
}


- (IBAction)lookupButtonPressed:(id)sender;
{
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];

	unsigned numSnaps = [snapsController countOfList];

	for (unsigned i = 0; i < numSnaps; i++)
	{
		NSDictionary* snap = [snapsController objectInListAtIndex:i];
		NSNumber* needsLookup = [snap objectForKey:@"needsLookup"];

		if ([needsLookup boolValue])
		{
			NSString* station = [snap objectForKey:@"title"];
			NSDate* createdAt = [snap objectForKey:@"createdAt"];

			NSString* result = [self songHTMLForStation:station date:createdAt];
			NSString* title = [self titleForResult:result];
			NSString* artist = [self artistForResult:result];
			
			if (title && artist)
			{
				NSDictionary* song =
					[NSDictionary dictionaryWithObjectsAndKeys:
					 title, @"title",
					 artist, @"subtitle",
					 [NSNumber numberWithBool:NO], @"needsLookup",
					 nil];
				[snapsController replaceDataAtIndex:i withData:song];
			}
		}
	}
	
	[snapsController saveSnaps];
	[snapsTable reloadData];

	[pool release];
}


- (IBAction)deleteButtonPressed:(id)sender;
{
	UIActionSheet* confirmation =
		[[UIActionSheet alloc] 
		 initWithTitle:nil
		 delegate:self
		 cancelButtonTitle:@"Cancel"
		 destructiveButtonTitle:@"Delete All Snaps"
		 otherButtonTitles:nil];
	
	[confirmation showFromToolbar:toolbar];
	[confirmation release];
}


- (void)actionSheet:(UIActionSheet*)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex;
{
	if (0 == buttonIndex)
	{
		[self setSnaps:[NSArray array]];
	}
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
		[button addTarget:self action:@selector(addSnap:) forControlEvents:UIControlEventTouchUpInside];
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
		cell.tag = SnapTag;

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

		cell.selectionStyle = UITableViewCellSelectionStyleNone;

		UILabel* snapTitle = (UILabel*)[cell.contentView viewWithTag:TitleTag];
		UILabel* snapSubtitle = (UILabel *)[cell.contentView viewWithTag:SubtitleTag];

		NSDictionary* snap = [snapsController objectInListAtIndex:[indexPath row]];

		snapTitle.text = [snap objectForKey:@"title"];
		snapSubtitle.text = [snap objectForKey:@"subtitle"];

		NSNumber* needsLookup = [snap objectForKey:@"needsLookup"];
		cell.accessoryType =
			[needsLookup boolValue] ?
			UITableViewCellAccessoryNone :
			UITableViewCellAccessoryDisclosureIndicator;

		return cell;
	}
}


- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath;
{
	NSDictionary* snap = [snapsController objectInListAtIndex:[indexPath row]];

	NSNumber* needsLookup = [snap objectForKey:@"needsLookup"];
	if (![needsLookup boolValue])
	{
		NSString* title = [snap objectForKey:@"title"];
		NSString* artist = [snap objectForKey:@"subtitle"];

		NSString* link =
			[NSString stringWithFormat:@"http://ax.phobos.apple.com.edgesuite.net/WebObjects/MZStoreServices.woa/wa/itmsSearch?WOURLEncoding=ISO8859_1&lang=1&output=lm&country=US&term=\"%@\" \"%@\"&media=all",
			 title,
			 artist];
		NSString* escapedLink =
			[link stringByAddingPercentEscapesUsingEncoding:
			 NSASCIIStringEncoding];
		NSURL* url = [NSURL URLWithString:escapedLink];

		[[UIApplication sharedApplication] openURL:url];
	}
}


- (void)viewDidLoad {
    [super viewDidLoad];
	self.snapsController = [[SnapsController alloc] init];
	self.lookupPattern = [WhatJustPlayedViewController defaultLookupPattern];
	self.testTime = nil;

	[self reloadData];
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
