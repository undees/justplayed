//
//  JustPlayedViewController.m
//  JustPlayed
//
//  Created by Ian Dees on 4/19/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "JustPlayedViewController.h"
#import "Snap.h"
#import "ASIHTTPRequest.h"
#import "ASINetworkQueue.h"


const int StationSection = 0;
const int SnapSection = 1;

const int StationTag = 1;
const int SnapTag = 2;
const int TitleTag = 3;
const int SubtitleTag = 4;
const int DownloadingTag = 5;
const int HelpTag = 6;

NSString* const EmptyCell = @"EmptyCell";
NSString* const StationCell = @"StationCell";
NSString* const SnapCell = @"SnapCell";

NSString* const DefaultServer = @"http://justplayed.heroku.com/pdx";
NSString* const HelpLocation = @"http://justplayed.heroku.com";

@implementation JustPlayedViewController


@synthesize stations, snaps, snapsTable, toolbar, lookupServer, testTime;


- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView
{
	return 2;
}


- (CGFloat)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section
{
	return 44;
}


- (UIView*)tableView:(UITableView*)tableView viewForHeaderInSection:(NSInteger)section
{
	UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 44)];

	UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(19, 10, headerView.bounds.size.width, 30)];
	label.backgroundColor = [UIColor clearColor];
	label.font = [UIFont boldSystemFontOfSize:17];
	label.textColor = [UIColor colorWithRed:0.243 green:0.306 blue:0.435 alpha:1.0]; //http://bit.ly/1tMGn9
	label.shadowColor = [UIColor whiteColor];
	label.shadowOffset = CGSizeMake(0, 1);
	
	label.text = (StationSection == section ? @"Stations" : @"Snaps");
	[headerView addSubview:label];

	if (StationSection == section)
	{
		UIButton *button = [UIButton buttonWithType:UIButtonTypeInfoDark];
		button.center = CGPointMake(291, 28);
		button.alpha = 0.6;
		button.tag = HelpTag;

		[button addTarget:self action:@selector(helpButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
		[headerView addSubview:button];
	}
	
	return headerView;
}


- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section;
{
	if (StationSection == section)
	{
		NSUInteger count = [self.stations count];
		return (count == 0 ? 1 : count);
	}
	else
	{
		return [self.snaps count];
	}
}

-(CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath;
{
	return (StationSection == indexPath.section ? 44 : 60);
}


- (void)addSnapForStation:(NSString*)station;
{
	NSDate* date = (self.testTime ? self.testTime : [NSDate date]);
	Snap* snap = [[[Snap alloc] initWithStation:station creationTime:date] autorelease];
	
	[snaps insertObject:snap atIndex:0];

	NSIndexPath* path = [NSIndexPath indexPathForRow:0 inSection:SnapSection];
	NSArray* paths = [NSArray arrayWithObject:path];
	[snapsTable insertRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationTop];

	[self refreshView];
}


- (void)setStations:(NSArray*)newStations;
{
	if (newStations == stations)
		return;
	
	[stations release];
	stations = [newStations retain];
	
	[self refreshView];
}


- (void)setSnaps:(NSArray*)newSnaps;
{
	if (newSnaps == snaps)
		return;

	[snaps release];
	snaps = [newSnaps mutableCopy];

	[self refreshView];
}


- (void)loadUserData;
{
	NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];

	self.stations = [userDefaults arrayForKey:@"stations"];;
	self.snaps = [Snap snapsFromPropertyLists:[userDefaults arrayForKey:@"snaps"]];
	self.lookupServer = [userDefaults stringForKey:@"lookupServer"];
	
	[self refreshView];
}


- (void)clearUserData;
{
	self.stations = [NSArray array];
	[snaps removeAllObjects];
	self.lookupServer = @"";

	[self refreshView];
}


- (void)saveUserData;
{
	NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults setObject:self.stations forKey:@"stations"];
	[userDefaults setObject:self.lookupServer forKey:@"lookupServer"];
	[userDefaults
		setObject:[Snap propertyListsFromSnaps:self.snaps]
		forKey:@"snaps"];
}


- (void)refreshView;
{
	[self.snapsTable reloadData];
}


- (void)stationFetchComplete:(ASIHTTPRequest*)request;
{
	NSData* data = [request responseData];

	NSArray* newStations =
		[NSPropertyListSerialization
		 propertyListFromData:data
		 mutabilityOption:NSPropertyListImmutable
		 format:nil
		 errorDescription:nil];
	
	[self performSelectorOnMainThread:@selector(setStations:)
		withObject:newStations
		waitUntilDone:NO];
}


- (void)updateSnap:(NSArray*)snapAndSong
{
	Snap* snap = [snapAndSong objectAtIndex:0];
	NSDictionary* song = [snapAndSong objectAtIndex:1];
	
	NSUInteger found = [self.snaps indexOfObject:snap];
	
	if (NSNotFound == found)
		return;

	Snap* result = [[[Snap alloc] initWithPropertyList:song] autorelease];

	[snaps replaceObjectAtIndex:found withObject:result];
	[self refreshView];
}


- (void)snapFetchComplete:(ASIHTTPRequest*)request;
{
	NSData* data = [request responseData];
	NSDictionary* snap = [[request userInfo] objectForKey:@"snap"];
	
	NSDictionary* details =
		[NSPropertyListSerialization
		 propertyListFromData:data
		 mutabilityOption:NSPropertyListImmutable
		 format:nil
		 errorDescription:nil];
	
	NSString* title = [details objectForKey:@"title"];
	NSString* artist = [details objectForKey:@"artist"];
	
	if (!title || !artist || !snap)
		return;
	
	NSDictionary* song =
		[NSDictionary dictionaryWithObjectsAndKeys:
		 title, @"title",
		 artist, @"subtitle",
		 [NSNumber numberWithBool:NO], @"needsLookup",
		 nil];

	NSArray* snapAndSong =
		[NSArray arrayWithObjects:snap, song, nil];
	
	[self performSelectorOnMainThread:@selector(updateSnap:)
						   withObject:snapAndSong
						waitUntilDone:NO];
}


- (void)fetchComplete:(ASIHTTPRequest*)request;
{
	NSString* selectorName = [[request userInfo] objectForKey:@"selector"];
	if (!selectorName)
		return;

	SEL selector = NSSelectorFromString(selectorName);
	[self performSelector:selector withObject:request];
}


- (void)showProgressBar:(BOOL)show;
{
	[UIView beginAnimations:@"progressAnimations" context:nil];
	[UIView setAnimationDuration:0.3];

	[progressBar setHidden:!show];
	[progressBar setTag:(show ? DownloadingTag : 0)];

	[UIView commitAnimations];
}


- (void)lookupDidFinish:(ASINetworkQueue*)queue;
{
	[self showProgressBar:NO];
}


- (void)lookupDidFail:(ASINetworkQueue*)queue;
{
	BOOL alreadyWarnedUser = progressBar.hidden;
	if (alreadyWarnedUser)
		return;

	NSString* title = @"Temporary difficulties";
	NSString* message = @"Looks like someone kicked out the plug \
at the other end of the network connection. \
Sorry about that!";
	
	UIAlertView* alert =
		[[UIAlertView alloc]
			initWithTitle:title
			message:message
			delegate:nil
			cancelButtonTitle:@"Close"
			otherButtonTitles:nil];
	
	[alert show];
	[alert release];
	[self showProgressBar:NO];
}


- (IBAction)lookupButtonPressed:(id)sender;
{
	NSString* lookup = [NSString stringWithFormat:@"%@/%@",
						self.lookupServer,
						@"stations"];
	NSURL* lookupURL = [NSURL URLWithString:lookup];

	[networkQueue cancelAllOperations];
	[networkQueue setRequestDidFinishSelector:@selector(fetchComplete:)];
	[networkQueue setDownloadProgressDelegate:progressBar];
	[networkQueue setQueueDidFinishSelector:@selector(lookupDidFinish:)];
	[networkQueue setRequestDidFailSelector:@selector(lookupDidFail:)];
	[networkQueue setDelegate:self];

	[progressBar setProgress:0.0];
	
	ASIHTTPRequest *request;
	request = [[[ASIHTTPRequest alloc] initWithURL:lookupURL] autorelease];
	NSDictionary* context = [NSDictionary dictionaryWithObjectsAndKeys:@"stationFetchComplete:", @"selector", nil];
	[request setUserInfo:context];
	[networkQueue addOperation:request];
	
	unsigned numSnaps = [self.snaps count];

	for (unsigned i = 0; i < numSnaps; i++)
	{
		Snap* snap = [self.snaps objectAtIndex:i];

		if (snap.needsLookup)
		{
			NSDateFormatter* dateFormat = [[[NSDateFormatter alloc] init] autorelease];
			NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
			[dateFormat setTimeZone:timeZone];
			[dateFormat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
			
			NSString* snappedAt = [dateFormat stringFromDate:snap.createdAt];
			NSString* lookup = [NSString stringWithFormat:@"%@/%@/%@",
								self.lookupServer,
								snap.title,
								snappedAt];
			
			NSURL* lookupURL = [NSURL URLWithString:lookup];

			ASIHTTPRequest* request = [[[ASIHTTPRequest alloc] initWithURL:lookupURL] autorelease];
			[[request userInfo] setValue:snap forKey:@"snap"];
			NSDictionary* context = [NSDictionary dictionaryWithObjectsAndKeys:
										@"snapFetchComplete:", @"selector",
										snap, @"snap",
										nil];
			[request setUserInfo:context];
			[networkQueue addOperation:request];
		}
	}

	[networkQueue go];
	[self showProgressBar:YES];
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
		NSMutableArray *doomed = [NSMutableArray arrayWithCapacity:[snaps count]];
		for (int i = 0; i < [snaps count]; ++i)
		{
			NSIndexPath *path = [NSIndexPath indexPathForRow:i inSection:SnapSection];
			[doomed addObject:path];
		}

		[snaps removeAllObjects];
		[snapsTable deleteRowsAtIndexPaths:doomed withRowAnimation:UITableViewRowAnimationBottom];
		[self refreshView];
	}
}


- (IBAction)helpButtonPressed:(id)sender;
{
	NSURL* url = [NSURL URLWithString:HelpLocation];
	[[UIApplication sharedApplication] openURL:url];
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
		if ([self.stations count] > 0)
		{
			UITableViewCell* cell = [self stationCellWithView:tableView];
			NSString* title = [self.stations objectAtIndex:[indexPath row]];
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

		Snap* snap = [self.snaps objectAtIndex:[indexPath row]];
		snapTitle.text = snap.title;
		snapSubtitle.text = snap.subtitle;

		cell.accessoryType =
			snap.needsLookup ?
			UITableViewCellAccessoryNone :
			UITableViewCellAccessoryDisclosureIndicator;

		return cell;
	}
}


- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath;
{
	if (StationSection == indexPath.section)
	{
		if ([self.stations count] > 0)
		{
			NSString* station = [self.stations objectAtIndex:[indexPath row]];
			[self addSnapForStation:station];
		}

		[tableView deselectRowAtIndexPath:indexPath animated:YES];
	}
	else
	{
		Snap* snap = [self.snaps objectAtIndex:[indexPath row]];

		if (!snap.needsLookup)
		{
			NSString* link =
				[NSString stringWithFormat:@"itms://phobos.apple.com/WebObjects/MZSearch.woa/wa/com.apple.jingle.search.DirectAction/search?term=%@ %@",
				 snap.title,
				 snap.subtitle];
			NSString* escapedLink =
				[link stringByAddingPercentEscapesUsingEncoding:
				 NSASCIIStringEncoding];
			NSURL* url = [NSURL URLWithString:escapedLink];

			[[UIApplication sharedApplication] openURL:url];
		}
	}
}


- (void)setToFactoryDefaults;
{
	NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults removeObjectForKey:@"stations"];
	[userDefaults removeObjectForKey:@"snaps"];
	[userDefaults removeObjectForKey:@"lookupServer"];
	
	self.testTime = nil;
	
	[self loadUserData];
}


- (void)viewDidLoad;
{
	[super viewDidLoad];

	NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary* appDefaults =
		[NSDictionary dictionaryWithObjectsAndKeys:
			[NSArray array], @"stations",
			[NSArray array], @"snaps",
			DefaultServer, @"lookupServer", nil];
    [defaults registerDefaults:appDefaults];

	[self loadUserData];

	networkQueue = [[ASINetworkQueue alloc] init];
}


- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	[self saveUserData];
}


- (void)didReceiveMemoryWarning;
{
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

- (void)dealloc;
{
	[stations release];
	[snaps release];
	[networkQueue release];

    [super dealloc];
}


@end
