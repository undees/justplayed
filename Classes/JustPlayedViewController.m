//
//  JustPlayedViewController.m
//  JustPlayed
//
//  Created by Ian Dees on 4/19/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "JustPlayedViewController.h"
#import "SnapsController.h"
#import "ASIHTTPRequest.h"
#import "ASINetworkQueue.h"


const int StationSection = 0;
const int SnapSection = 1;

const int StationTag = 1;

const int SnapTag = 2;
const int TitleTag = 3;
const int SubtitleTag = 4;

const int DownloadingTag = 5;

NSString* const EmptyCell = @"EmptyCell";
NSString* const StationCell = @"StationCell";
NSString* const SnapCell = @"SnapCell";


@implementation JustPlayedViewController


@synthesize stations, snapsController, snapsTable, toolbar, lookupServer, testTime;


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
		NSUInteger count = [self.stations count];
		return (count == 0 ? 1 : count);
	}
	else
	{
		return [self.snapsController countOfList];
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

	[self.snapsController addData:snap];

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


- (void)setSnaps:(NSArray*)snaps;
{
	[self.snapsController setSnaps:[NSMutableArray arrayWithArray:snaps]];
	[self refreshView];
}


- (void)loadUserData;
{
	NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
	NSArray* defStations = [userDefaults arrayForKey:@"stations"];
	self.stations = defStations;

	userDefaults = [NSUserDefaults standardUserDefaults];
	NSArray* snaps = [userDefaults arrayForKey:@"snaps"];
	[self setSnaps:snaps];

	NSString* server = [userDefaults stringForKey:@"lookupServer"];
	self.lookupServer = server;
	
	[self refreshView];
}


- (void)clearUserData;
{
	self.stations = [NSArray array];
	[self setSnaps:[NSArray array]];
	self.lookupServer = @"";
	[self refreshView];
}


- (void)saveUserData;
{
	NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults setValue:self.stations forKey:@"stations"];
	[userDefaults setValue:self.lookupServer forKey:@"lookupServer"];
	
	[self.snapsController saveSnaps];
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
	NSDictionary* snap = [snapAndSong objectAtIndex:0];
	NSDictionary* song = [snapAndSong objectAtIndex:1];
	
	NSMutableArray* snaps = [snapsController snaps];
	NSUInteger found = [snaps indexOfObject:snap];
	
	if (NSNotFound == found)
		return;

	[self.snapsController replaceDataAtIndex:found withData:song];
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
	[networkQueue setShowAccurateProgress:YES];
	[networkQueue setQueueDidFinishSelector:@selector(lookupDidFinish:)];
	[networkQueue setRequestDidFailSelector:@selector(lookupDidFail:)];
	[networkQueue setDelegate:self];

	[progressBar setProgress:0.0];
	
	ASIHTTPRequest *request;
	request = [[[ASIHTTPRequest alloc] initWithURL:lookupURL] autorelease];
	NSDictionary* context = [NSDictionary dictionaryWithObjectsAndKeys:@"stationFetchComplete:", @"selector", nil];
	[request setUserInfo:context];
	[networkQueue addOperation:request];
	
	unsigned numSnaps = [self.snapsController countOfList];

	for (unsigned i = 0; i < numSnaps; i++)
	{
		NSDictionary* snap = [self.snapsController objectInListAtIndex:i];
		NSNumber* needsLookup = [snap objectForKey:@"needsLookup"];

		if ([needsLookup boolValue])
		{
			NSDate* date = [snap objectForKey:@"createdAt"];
			NSString* station = [snap objectForKey:@"title"];
			
			NSDateFormatter* dateFormat = [[[NSDateFormatter alloc] init] autorelease];
			NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
			[dateFormat setTimeZone:timeZone];
			[dateFormat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
			
			NSString* snappedAt = [dateFormat stringFromDate:date];
			NSString* lookup = [NSString stringWithFormat:@"%@/%@/%@",
								self.lookupServer,
								station,
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

		NSDictionary* snap = [self.snapsController objectInListAtIndex:[indexPath row]];

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
		if ([self.stations count] > 0)
		{
			NSString* station = [self.stations objectAtIndex:[indexPath row]];
			[self addSnap:station];
		}

		[tableView deselectRowAtIndexPath:indexPath animated:YES];
	}
	else
	{
		NSDictionary* snap = [self.snapsController objectInListAtIndex:[indexPath row]];

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
	self.snapsController = [[[SnapsController alloc] init] autorelease];

	NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary* appDefaults =
		[NSDictionary dictionaryWithObjectsAndKeys:
			[NSArray array], @"stations",
			[NSArray array], @"snaps",
			@"http://dielectric.heroku.com", @"lookupServer", nil];
    [defaults registerDefaults:appDefaults];

	[self loadUserData];

	networkQueue = [[ASINetworkQueue alloc] init];
}


- (void)viewWillAppear:(BOOL)animated;
{
	[super viewWillAppear:animated];
	[self loadUserData];
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
	[snapsController release];
	[networkQueue release];

    [super dealloc];
}


@end
