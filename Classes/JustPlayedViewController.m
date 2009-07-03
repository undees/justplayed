//
//  JustPlayedViewController.m
//  JustPlayed
//
//  Created by Ian Dees on 4/19/09.
//  Copyright 25y26z 2009. See LICENSE.txt for details.
//

#import "JustPlayedViewController.h"
#import "Snap.h"
#import "ASIHTTPRequest.h"
#import "ASINetworkQueue.h"


enum {
	StationSection = 0,
	SnapSection
};


enum {
	StationTag = 1,
	SnapTag,
	TitleTag,
	SubtitleTag,
	DownloadingTag,
	HelpTag,
	LocationTag,
};


NSString * const EmptyCell = @"EmptyCell";
NSString * const StationCell = @"StationCell";
NSString * const SnapCell = @"SnapCell";

NSString * const DefaultServer = @"http://justplayed.heroku.com";
NSString * const DefaultLocation = @"Portland";


@implementation JustPlayedViewController


@synthesize snapsTable, toolbar, lookupServer, location, testTime;


// Table cell helpers, called by our GUI callbacks when we need
// to fill in a cell of a particular type.


// Empty cell with a simple howto message.
//
- (UITableViewCell *)emptyCellWithView:(UITableView *)tableView;
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:EmptyCell];
	if (cell == nil)
	{
		CGRect frame = CGRectMake(0, 0, 300, 44);
		cell = [[[UITableViewCell alloc] initWithFrame:frame reuseIdentifier:EmptyCell] autorelease];
		
		cell.tag = StationTag;
		
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 30000
		UILabel *custom = cell.textLabel;
#else
		UITableViewCell *custom = cell;
#endif
		custom.font = [UIFont systemFontOfSize:12.0];
		custom.textColor = [UIColor lightGrayColor];
		custom.textAlignment = UITextAlignmentCenter;
		custom.text = @"connect to network and press Locate";
	}
	
	return cell;
}

// Cell with a radio station name.
//
- (UITableViewCell *)stationCellWithView:(UITableView *)tableView;
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:StationCell];
	if (cell == nil)
	{
		CGRect frame = CGRectMake(0, 0, 300, 44);
		cell = [[[UITableViewCell alloc] initWithFrame:frame reuseIdentifier:StationCell] autorelease];
		cell.tag = StationTag;
		
		// Hey Apple, how about a +buttonTitleColor for system colors?
		UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		UIColor *textColor = button.currentTitleColor;
		
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 30000
		UILabel *custom = cell.textLabel;
#else
		UITableViewCell *custom = cell;
#endif
		
		custom.font = [UIFont boldSystemFontOfSize:15.0];
		custom.textAlignment = UITextAlignmentCenter;
		custom.textColor = textColor;
	}
	
	return cell;
}


// Cell with either a station/time, or a title/artist.
//
- (UITableViewCell *)snapCellWithView:(UITableView *)tableView;
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:SnapCell];
	if (cell == nil)
	{
		CGRect frame = CGRectMake(0, 0, 290, 60);
		cell = [[[UITableViewCell alloc] initWithFrame:frame reuseIdentifier:SnapCell] autorelease];
		cell.tag = SnapTag;
		
		UILabel *snapTitle = [[[UILabel alloc] initWithFrame:CGRectMake(10, 10, 280, 25)] autorelease];
		snapTitle.tag = TitleTag;
		[cell.contentView addSubview:snapTitle];
		
		UILabel *snapSubtitle = [[[UILabel alloc] initWithFrame:CGRectMake(10, 33, 280, 25)] autorelease];
		snapSubtitle.tag = SubtitleTag;
		snapSubtitle.font = [UIFont systemFontOfSize:12.0];
		snapSubtitle.textColor = [UIColor lightGrayColor];
		[cell.contentView addSubview:snapSubtitle];
	}
	
	return cell;
}


// Bookmark the fact that we are listening to the given station right now.
//
- (void)addSnapForStation:(NSString *)station;
{
	// First insert the new snap into the in-memory list...
	NSDate *date = (self.testTime ? self.testTime : [NSDate date]);
	Snap *snap = [[[Snap alloc] initWithStation:station creationTime:date] autorelease];
	[snaps insertObject:snap atIndex:0];
	
	// ... and then add it to the GUI.
	NSIndexPath *path = [NSIndexPath indexPathForRow:0 inSection:SnapSection];
	NSArray *paths = [NSArray arrayWithObject:path];
	[snapsTable insertRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationTop];
	[self refreshView];
}


// Redraw the table in light of new data.
//
- (void)refreshView;
{
	[self.snapsTable reloadData];
}


// Table view functions called by Cocoa Touch in response to GUI events.


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 2;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	if (StationSection == section)
		return @"Stations";
	else
		return @"Snaps";
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
	if (StationSection == section)
	{
		NSUInteger count = [stations count];

		return (count == 0 ? 1 : count); // show a help message when there are no stations
	}
	else
	{
		return [snaps count];
	}
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
	return (StationSection == indexPath.section ? 44 : 60);
}


// Called by Cooca Touch when it's time to fill a cell with data and show it.
//
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
	if (StationSection == indexPath.section)
	{
		// Show the nth radio station, or a helper message
		// if there aren't any stations.
		
		if ([stations count] > 0)
		{
			UITableViewCell *cell = [self stationCellWithView:tableView];
			NSString *title = [stations objectAtIndex:[indexPath row]];
			
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
		// Show a station/time snapshot, or a title/artist cell.
		
		UITableViewCell *cell = [self snapCellWithView:tableView];
		
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		
		UILabel *snapTitle = (UILabel *)[cell.contentView viewWithTag:TitleTag];
		UILabel *snapSubtitle = (UILabel  *)[cell.contentView viewWithTag:SubtitleTag];
		
		Snap *snap = [snaps objectAtIndex:[indexPath row]];
		snapTitle.text = snap.title;
		snapSubtitle.text = snap.subtitle;
		
		cell.accessoryType =
		snap.needsLookup ?
		UITableViewCellAccessoryNone :
		UITableViewCellAccessoryDisclosureIndicator;
		
		return cell;
	}
}


// Called when the user taps on a cell.
//
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
	if (StationSection == indexPath.section)
	{
		// If he clicked on a station (as opposed to the help message),
		// record the station and time.
		if ([stations count] > 0)
		{
			NSString *station = [stations objectAtIndex:[indexPath row]];
			[self addSnapForStation:station];
		}
		
		[tableView deselectRowAtIndexPath:indexPath animated:YES];
	}
	else
	{
		Snap *snap = [snaps objectAtIndex:[indexPath row]];
		
		// If he clicked on a title/artist cell, go to the iTunes Store
		// to search for that song.
		if (!snap.needsLookup)
		{
			NSString *link =
				[NSString stringWithFormat:@"itms://phobos.apple.com/WebObjects/MZSearch.woa/wa/com.apple.jingle.search.DirectAction/search?term=%@ %@",
				 snap.title,
				 snap.subtitle];

			NSString *escapedLink =
				[link stringByAddingPercentEscapesUsingEncoding:
				 NSASCIIStringEncoding];
				NSURL *url = [NSURL URLWithString:escapedLink];

			[[UIApplication sharedApplication] openURL:url];
		}
	}
}


// Called when the user deletes a station.
//
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath  *)indexPath;
{
	if (StationSection == indexPath.section)
	{
		if ([stations count] == 0)
			return;
		
		// Remove the station from the in-memory list...
		[stations removeObjectAtIndex:indexPath.row];
		
		// ... and from the GUI (leave behind a helper message if he deleted the last one).
		if ([stations count] > 0)
		{
			NSArray *doomed = [NSArray arrayWithObject:indexPath];
			[tableView deleteRowsAtIndexPaths:doomed withRowAnimation:UITableViewRowAnimationBottom];
		}
		
		[self refreshView];
	}
}


// Only station cells can be individually deleted.
//
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath;
{
	if (StationSection == indexPath.section)
		return UITableViewCellEditingStyleDelete;
	else
		return UITableViewCellEditingStyleNone;
}


// GUI helpers.


// Indicate whether or not a download is in progress.
//
- (void)showProgressIndicator:(BOOL)show;
{
	[downloadProgress setTag:(show ? DownloadingTag : 0)];
	[downloadProgress performSelector:
	 (show ? @selector(startAnimating) : @selector(stopAnimating))];
}


// GUI callbacks.


// The user has requested a lookup of all snaps.
//
- (IBAction)lookupButtonPressed:(id)sender;
{
	if (0 == [snaps count])
		return;
	
	for (unsigned i = 0; i < [snaps count]; i++)
	{
		Snap *snap = [snaps objectAtIndex:i];
		
		// Some snaps in the list will already have been successfully looked up.
		if (snap.needsLookup)
		{
			// URL will look like http://justplayed.heroku.com/KNRK/2009-07-03T10:00
			
			NSDateFormatter *dateFormat = [[[NSDateFormatter alloc] init] autorelease];
			[dateFormat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
			
			NSString *snappedAt = [dateFormat stringFromDate:snap.createdAt];
			NSString *lookup = [NSString stringWithFormat:@"%@/%@/%@",
								self.lookupServer,
								snap.title,
								snappedAt];
			NSURL *lookupURL = [NSURL URLWithString:lookup];
			
			ASIHTTPRequest *request = [[[ASIHTTPRequest alloc] initWithURL:lookupURL] autorelease];
			
			// Tie the HTTP request to this snap, so we'll know where to route the results.
			[[request userInfo] setValue:snap forKey:@"snap"];
			
			// Tell the network queue what to do after the lookup is complete.
			NSDictionary *context = [NSDictionary dictionaryWithObjectsAndKeys:
									 @"snapFetchComplete:", @"selector",
									 snap, @"snap",
									 nil];
			[request setUserInfo:context];

			[request setUseCookiePersistance:NO];
			
			[networkQueue addOperation:request];
		}
	}
	
	[networkQueue go];
	[self showProgressIndicator:YES];
}


// The user has requested that we delete all his snaps.
//
- (IBAction)deleteButtonPressed:(id)sender;
{
	UIActionSheet *confirmation =
	[[UIActionSheet alloc]
	 initWithTitle:nil
	 delegate:self
	 cancelButtonTitle:@"Cancel"
	 destructiveButtonTitle:@"Delete All Snaps"
	 otherButtonTitles:nil];
	
	[confirmation showFromToolbar:toolbar];
	[confirmation release];
}


// The user has confirmed that he really, really
// wants to delete all his snaps.
//
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex;
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


// Go to the online help, which conveniently resides
// on the same server that hosts the data.
//
- (IBAction)helpButtonPressed:(id)sender;
{
	NSURL *url = [NSURL URLWithString:DefaultServer];
	[[UIApplication sharedApplication] openURL:url];
}


// Network helpers used by the HTTP request callbacks.


// We've received a dictionary of stations (keys = call letters, values = links).
// Fill the stations list with the new data.
//
- (void)stationFetchComplete:(ASIHTTPRequest *)request;
{
	NSData *data = [request responseData];
	
	NSDictionary *details =
	[NSPropertyListSerialization
	 propertyListFromData:data
	 mutabilityOption:NSPropertyListImmutable
	 format:nil
	 errorDescription:nil];
	
	NSArray *newStations = [[details allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
	
	[self performSelectorOnMainThread:@selector(setStations:)
						   withObject:newStations
						waitUntilDone:NO];
}


// We've received one title/artist result from the network,
// on the networking thread.  Bundle it up and send it to
// the GUI thread for updating.
// 
- (void)snapFetchComplete:(ASIHTTPRequest *)request;
{
	NSData *data = [request responseData];
	NSDictionary *snap = [[request userInfo] objectForKey:@"snap"];
	
	NSDictionary *details =
	[NSPropertyListSerialization
	 propertyListFromData:data
	 mutabilityOption:NSPropertyListImmutable
	 format:nil
	 errorDescription:nil];
	
	NSString *title = [details objectForKey:@"title"];
	NSString *artist = [details objectForKey:@"artist"];
	
	if (!title || !artist || !snap)
		return;
	
	Snap *song = [[[Snap alloc] initWithTitle:title	artist:artist] autorelease];
	
	NSArray *snapAndSong =
	[NSArray arrayWithObjects:snap, song, nil];
	
	[self performSelectorOnMainThread:@selector(updateSnap:)
						   withObject:snapAndSong
						waitUntilDone:NO];
}


// Find and replace a station/time pair
// with a title/artist pair.
//
- (void)updateSnap:(NSArray *)snapAndSong
{
	Snap *snap = [snapAndSong objectAtIndex:0];
	Snap *song = [snapAndSong objectAtIndex:1];
	
	NSUInteger found = [snaps indexOfObject:snap];
	
	if (NSNotFound == found)
		return;
	
	[snaps replaceObjectAtIndex:found withObject:song];
	[self refreshView];
}


// HTTP request callbacks


- (void)lookupDidFinish:(ASINetworkQueue *)queue;
{
	[self showProgressIndicator:NO];
}


- (void)lookupDidFail:(ASINetworkQueue *)queue;
{
	BOOL alreadyWarnedUser = ![downloadProgress isAnimating];
	if (alreadyWarnedUser)
		return;
	
	NSString *title = @"Temporary difficulties";
	NSString *message = @"Looks like someone kicked out the plug \
	at the other end of the network connection. \
	Sorry about that!";
	
	UIAlertView *alert =
	[[UIAlertView alloc]
	 initWithTitle:title
	 message:message
	 delegate:nil
	 cancelButtonTitle:@"Close"
	 otherButtonTitles:nil];
	
	[alert show];
	[alert release];
	[self showProgressIndicator:NO];
}


// We've received a radio station or a title/artist from the network.
// Route the data to the handler that's expecting it.
//
- (void)fetchComplete:(ASIHTTPRequest *)request;
{
	NSString *selectorName = [[request userInfo] objectForKey:@"selector"];
	if (!selectorName)
		return;

	SEL selector = NSSelectorFromString(selectorName);
	[self performSelector:selector withObject:request];
}


// The user has requested a list of all radio stations near him.
//
- (IBAction)locationButtonPressed:(id)sender;
{
	// URL will look like http://justplayed.heroku.com/stations/Portland

	NSString *lookup = [NSString stringWithFormat:@"%@/stations/%@",
						self.lookupServer,
						self.location];
	NSURL *lookupURL = [NSURL URLWithString:lookup];
	
	ASIHTTPRequest *request =
		[[[ASIHTTPRequest alloc] initWithURL:lookupURL] autorelease];

	// Tell the HTTP request what to do after it finishes.
	NSDictionary *context =
		[NSDictionary dictionaryWithObjectsAndKeys:@"stationFetchComplete:", @"selector", nil];
	[request setUserInfo:context];

	[request setUseCookiePersistance:NO];

	[networkQueue addOperation:request];
	[networkQueue go];

	[self showProgressIndicator:YES];
}


// Property setters for stations and snaps.
// Like standard Cocoa setters, but these
// also direct the GUI to update itself afterward.

- (void)setStations:(NSArray *)newStations;
{
	if (newStations == stations)
		return;
	
	[stations release];
	stations = [newStations mutableCopy];
	
	[self refreshView];
}


- (void)setSnaps:(NSArray *)newSnaps;
{
	if (newSnaps == snaps)
		return;
	
	[snaps release];
	snaps = [newSnaps mutableCopy];
	
	[self refreshView];
}


// Store user defaults (location, server) and data (stations, snaps)
// in the property list file attached to this app.


- (void)loadUserData;
{
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	
	[self setStations:[userDefaults arrayForKey:@"stations"]];
	[self setSnaps:[Snap snapsFromPropertyLists:[userDefaults arrayForKey:@"snaps"]]];
	[self setLookupServer:[userDefaults stringForKey:@"lookupServer"]];
	[self setLocation:[userDefaults stringForKey:@"location"]];
	
	[self refreshView];
}


- (void)clearUserData;
{
	[stations removeAllObjects];
	[snaps removeAllObjects];
	[self setLookupServer:@""];
	[self setLocation:@""];
	
	[self refreshView];
}


- (void)saveUserData;
{
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	
	[userDefaults setObject:stations forKey:@"stations"];
	[userDefaults
	 setObject:[Snap propertyListsFromSnaps:snaps]
	 forKey:@"snaps"];
	[userDefaults setObject:self.lookupServer forKey:@"lookupServer"];
	[userDefaults setObject:self.location forKey:@"location"];
}


// Wipe all data by clearing / reloading the plist file.
//
- (void)setToFactoryDefaults;
{
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults removeObjectForKey:@"stations"];
	[userDefaults removeObjectForKey:@"snaps"];
	[userDefaults removeObjectForKey:@"lookupServer"];
	[userDefaults removeObjectForKey:@"location"];
	
	self.testTime = nil;
	
	[self loadUserData];
}


// The view is ready, so we can safely create all the sub-objects.
//
- (void)viewDidLoad;
{
	[super viewDidLoad];
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *appDefaults =
		[NSDictionary dictionaryWithObjectsAndKeys:
			[NSArray array], @"stations",
			[NSArray array], @"snaps",
			DefaultServer, @"lookupServer",
			DefaultLocation, @"location", nil];
    [defaults registerDefaults:appDefaults];

	[self loadUserData];

	networkQueue = [[ASINetworkQueue alloc] init];
	[networkQueue setRequestDidFinishSelector:@selector(fetchComplete:)];
	[networkQueue setQueueDidFinishSelector:@selector(lookupDidFinish:)];
	[networkQueue setRequestDidFailSelector:@selector(lookupDidFail:)];
	[networkQueue setDelegate:self];
}


// Remember our settings and data before shutting down.
//
- (void)viewWillDisappear:(BOOL)animated;
{
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
