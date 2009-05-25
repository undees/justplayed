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

const int StationTag = 1;

const int SnapTag = 2;
const int TitleTag = 3;
const int SubtitleTag = 4;

NSString* const EmptyCell = @"EmptyCell";
NSString* const StationCell = @"StationCell";
NSString* const SnapCell = @"SnapCell";


@implementation WhatJustPlayedViewController


@synthesize snapsTable, toolbar, lookupServer, testTime;


+ (NSString*)defaultLookupServer;
{
	return @"http://dielectric.heroku.com";	
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
	{
		NSUInteger count = [stations count];
		return (count == 0 ? 1 : count);
	}
	else
	{
		return [snapsController countOfList];
	}
}

-(CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath;
{
	return (StationSection == indexPath.section ? 44 : 60);
}


- (void)addSnap:(NSString*)station;
{
	NSString* title = station;

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


- (void)setStations:(NSArray*)newStations;
{
	[stations autorelease];
	stations = [newStations copy];

	NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults setValue:stations forKey:@"stations"];
}


- (void)setSnaps:(NSArray*)snaps;
{
	[snapsController setSnaps:[NSMutableArray arrayWithArray:snaps]];
	[snapsController saveSnaps];
	[snapsTable reloadData];
}


- (void)reloadData;
{
	NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
	NSArray* defStations = [userDefaults arrayForKey:@"stations"];
	stations = defStations;
	
	userDefaults = [NSUserDefaults standardUserDefaults];
	NSArray* snaps = [userDefaults arrayForKey:@"snaps"];
	[self setSnaps:snaps];

	NSString* server = [userDefaults stringForKey:@"lookupServer"];
	[self setLookupServer:server];
}


- (NSData*)stationXML;
{
	NSString* lookup = [NSString stringWithFormat:@"%@/%@",
						[self lookupServer],
						@"stations"];
	NSURL* lookupURL = [NSURL URLWithString:lookup];
	return [NSData dataWithContentsOfURL:lookupURL];
}


- (NSData*)songXMLForStation:(NSString*)station date:(NSDate*)date;
{
	NSDateFormatter* dateFormat = [[[NSDateFormatter alloc] init] autorelease];
	NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
	[dateFormat setTimeZone:timeZone];
	[dateFormat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
	
	NSString* snappedAt = [dateFormat stringFromDate:date];
	NSString* lookup = [NSString stringWithFormat:@"%@/%@/%@",
						[self lookupServer],
						station,
						snappedAt];

	NSURL* lookupURL = [NSURL URLWithString:lookup];
	return [NSData dataWithContentsOfURL:lookupURL];
}


- (IBAction)lookupButtonPressed:(id)sender;
{
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];

	NSData* stationData = [self stationXML];
	NSArray* newStations = 
	[NSPropertyListSerialization
	 propertyListFromData:stationData
	 mutabilityOption:NSPropertyListMutableContainers
	 format:nil
	 errorDescription:nil];
	if (newStations)
		[self setStations:newStations];
	
	unsigned numSnaps = [snapsController countOfList];

	for (unsigned i = 0; i < numSnaps; i++)
	{
		NSDictionary* snap = [snapsController objectInListAtIndex:i];
		NSNumber* needsLookup = [snap objectForKey:@"needsLookup"];

		if ([needsLookup boolValue])
		{
			NSString* station = [snap objectForKey:@"title"];
			NSDate* createdAt = [snap objectForKey:@"createdAt"];

			NSData* result = [self songXMLForStation:station date:createdAt];
			NSDictionary* details = 
				[NSPropertyListSerialization
				 propertyListFromData:result
				 mutabilityOption:NSPropertyListMutableContainers
				 format:nil
				 errorDescription:nil];			
			
			NSString* title = [details objectForKey:@"title"];
			NSString* artist = [details objectForKey:@"artist"];
			
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


- (UITableViewCell*)emptyCellWithView:(UITableView*)tableView;
{
	UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:EmptyCell];
	if (cell == nil)
	{
		CGRect frame = CGRectMake(0, 0, 300, 44);
		cell = [[[UITableViewCell alloc] initWithFrame:frame reuseIdentifier:EmptyCell] autorelease];
		
		cell.tag = StationTag;
		cell.font = [UIFont systemFontOfSize:12.0];
		cell.textColor = [UIColor lightGrayColor];
		cell.textAlignment = UITextAlignmentCenter;
		cell.text = @"connect to network and press Refresh";
	}
	
	return cell;
}


- (UITableViewCell*)stationCellWithView:(UITableView*)tableView;
{
	UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:StationCell];
	if (cell == nil)
	{
		CGRect frame = CGRectMake(0, 0, 300, 44);
		cell = [[[UITableViewCell alloc] initWithFrame:frame reuseIdentifier:StationCell] autorelease];
		cell.tag = StationTag;
		cell.font = [UIFont boldSystemFontOfSize:15.0];
		cell.textAlignment = UITextAlignmentCenter;

		// Hey, Apple, how about a +buttonTitleColor for system colors?
		UIButton* button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		cell.textColor = button.currentTitleColor;
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
		if ([stations count] > 0)
		{
			UITableViewCell* cell = [self stationCellWithView:tableView];
			NSString* title = [stations objectAtIndex:[indexPath row]];
			[cell setText:title];

			return cell;
		}
		else
		{
			return [self emptyCellWithView:tableView];
		}
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
	if (StationSection == indexPath.section)
	{
		if ([stations count] > 0)
		{
			NSString* station = [stations objectAtIndex:[indexPath row]];
			[self addSnap:station];
		}

		[tableView deselectRowAtIndexPath:indexPath animated:YES];
	}
	else
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
}


- (void)viewDidLoad {
    [super viewDidLoad];

	stations = [[NSArray alloc] init];
	snapsController = [[SnapsController alloc] init];

	self.lookupServer = [WhatJustPlayedViewController defaultLookupServer];
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
	[stations release];
	[snapsController release];

    [super dealloc];
}


@end
