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
const int LocationTag = 7;

NSString* const EmptyCell = @"EmptyCell";
NSString* const StationCell = @"StationCell";
NSString* const SnapCell = @"SnapCell";

NSString* const DefaultServer = @"http://justplayed.heroku.com";
NSString* const DefaultLocation = @"Portland";

@implementation JustPlayedViewController


@synthesize snapsTable, toolbar, lookupServer, location, testTime;


- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView
{
	return 2;
}


- (NSString*)tableView:(UITableView*)tableView titleForHeaderInSection:(NSInteger)section
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
		return [snaps count];
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
	stations = [newStations mutableCopy];
	
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

	[self setStations:[userDefaults arrayForKey:@"stations"]];
	[self setSnaps:[Snap snapsFromPropertyLists:[userDefaults arrayForKey:@"snaps"]]];
	self.lookupServer = [userDefaults stringForKey:@"lookupServer"];
	self.location = [userDefaults stringForKey:@"location"];
	
	[self refreshView];
}


- (void)clearUserData;
{
	[self setStations:[NSMutableArray array]];
	[snaps removeAllObjects];
	self.lookupServer = @"";
	self.location = @"";

	[self refreshView];
}


- (void)saveUserData;
{
	NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];

	[userDefaults setObject:stations forKey:@"stations"];
	[userDefaults
		setObject:[Snap propertyListsFromSnaps:snaps]
		forKey:@"snaps"];
	[userDefaults setObject:self.lookupServer forKey:@"lookupServer"];
	[userDefaults setObject:self.location forKey:@"location"];
}


- (void)refreshView;
{
	[self.snapsTable reloadData];
}


- (void)stationFetchComplete:(ASIHTTPRequest*)request;
{
	NSData* data = [request responseData];

	NSDictionary* details =
		[NSPropertyListSerialization
		 propertyListFromData:data
		 mutabilityOption:NSPropertyListImmutable
		 format:nil
		 errorDescription:nil];
	
	NSArray* newStations = [[details allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];

	[self performSelectorOnMainThread:@selector(setStations:)
		withObject:newStations
		waitUntilDone:NO];
}


- (void)updateSnap:(NSArray*)snapAndSong
{
	Snap* snap = [snapAndSong objectAtIndex:0];
	NSDictionary* song = [snapAndSong objectAtIndex:1];
	
	NSUInteger found = [snaps indexOfObject:snap];
	
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
	[downloadProgress setTag:(show ? DownloadingTag : 0)];
	[downloadProgress performSelector:
		(show ? @selector(startAnimating) : @selector(stopAnimating))];
}


- (void)lookupDidFinish:(ASINetworkQueue*)queue;
{
	[self showProgressBar:NO];
}


- (void)lookupDidFail:(ASINetworkQueue*)queue;
{
	BOOL alreadyWarnedUser = ![downloadProgress isAnimating];
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


- (IBAction)locationButtonPressed:(id)sender;
{
	NSString* lookup = [NSString stringWithFormat:@"%@/stations/%@",
						self.lookupServer,
						self.location];
	NSURL* lookupURL = [NSURL URLWithString:lookup];
	
	[networkQueue setRequestDidFinishSelector:@selector(fetchComplete:)];
	[networkQueue setQueueDidFinishSelector:@selector(lookupDidFinish:)];
	[networkQueue setRequestDidFailSelector:@selector(lookupDidFail:)];
	[networkQueue setDelegate:self];
	
	ASIHTTPRequest *request;
	request = [[[ASIHTTPRequest alloc] initWithURL:lookupURL] autorelease];
	NSDictionary* context = [NSDictionary dictionaryWithObjectsAndKeys:@"stationFetchComplete:", @"selector", nil];
	[request setUserInfo:context];
	[networkQueue addOperation:request];

	[networkQueue go];
	[self showProgressBar:YES];
}


- (IBAction)lookupButtonPressed:(id)sender;
{
	[networkQueue setRequestDidFinishSelector:@selector(fetchComplete:)];
	[networkQueue setQueueDidFinishSelector:@selector(lookupDidFinish:)];
	[networkQueue setRequestDidFailSelector:@selector(lookupDidFail:)];
	[networkQueue setDelegate:self];

	unsigned numSnaps = [snaps count];
	
	if (0 == numSnaps)
		return;

	for (unsigned i = 0; i < numSnaps; i++)
	{
		Snap* snap = [snaps objectAtIndex:i];

		if (snap.needsLookup)
		{
			NSDateFormatter* dateFormat = [[[NSDateFormatter alloc] init] autorelease];
			[dateFormat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
			
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
	NSURL* url = [NSURL URLWithString:DefaultServer];
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

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 30000
		UILabel* custom = cell.textLabel;
#else
		UITableViewCell* custom = cell;
#endif
		custom.font = [UIFont systemFontOfSize:12.0];
		custom.textColor = [UIColor lightGrayColor];
		custom.textAlignment = UITextAlignmentCenter;
		custom.text = @"connect to network and press Locate";
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

		// Hey, Apple, how about a +buttonTitleColor for system colors?
		UIButton* button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		UIColor* textColor = button.currentTitleColor;
		
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 30000
		UILabel* custom = cell.textLabel;
#else
		UITableViewCell* custom = cell;
#endif
		
		custom.font = [UIFont boldSystemFontOfSize:15.0];
		custom.textAlignment = UITextAlignmentCenter;
		custom.textColor = textColor;
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

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 30000
			cell.textLabel.text = title;
#else
			cell.text = title;
#endif

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

		Snap* snap = [snaps objectAtIndex:[indexPath row]];
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
		if ([stations count] > 0)
		{
			NSString* station = [stations objectAtIndex:[indexPath row]];
			[self addSnapForStation:station];
		}

		[tableView deselectRowAtIndexPath:indexPath animated:YES];
	}
	else
	{
		Snap* snap = [snaps objectAtIndex:[indexPath row]];

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


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath;
{
	if (StationSection == indexPath.section)
	{
		if ([stations count] == 0)
			return;

		[stations removeObjectAtIndex:indexPath.row];

		if ([stations count] > 0)
		{
			NSArray* doomed = [NSArray arrayWithObject:indexPath];
			[tableView deleteRowsAtIndexPaths:doomed withRowAnimation:UITableViewRowAnimationBottom];
		}

		[self refreshView];
	}
}

- (BOOL)tableView:(UITableView*)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath*)indexPath;
{
	return NO;
}

- (UITableViewCellEditingStyle)tableView:(UITableView*)tableView editingStyleForRowAtIndexPath:(NSIndexPath*)indexPath;
{
	if (StationSection == indexPath.section)
		return UITableViewCellEditingStyleDelete;
	else
		return UITableViewCellEditingStyleNone;
}


- (void)setToFactoryDefaults;
{
	NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults removeObjectForKey:@"stations"];
	[userDefaults removeObjectForKey:@"snaps"];
	[userDefaults removeObjectForKey:@"lookupServer"];
	[userDefaults removeObjectForKey:@"location"];
	
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
			DefaultServer, @"lookupServer",
			DefaultLocation, @"location", nil];
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
