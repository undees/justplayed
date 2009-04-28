//
//  WhatJustPlayedAppDelegate.m
//  WhatJustPlayed
//
//  Created by Ian Dees on 4/19/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "WhatJustPlayedAppDelegate.h"
#import "WhatJustPlayedViewController.h"
#import "Snap.h"

#ifdef BROMINE_ENABLED
	#import "ScriptRunner.h"
	#import "MyHTTPConnection.h"
#endif

@implementation WhatJustPlayedAppDelegate

@synthesize window;
@synthesize viewController;


- (void)applicationDidFinishLaunching:(UIApplication *)application {    
    [window addSubview:viewController.view];
    [window makeKeyAndVisible];
	
#ifdef BROMINE_ENABLED
	NSString *root = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) objectAtIndex:0];
	httpServer = [HTTPServer new];
	[httpServer setName:@"the iPhone"];
	[httpServer setType:@"_http._tcp."];
	[httpServer setConnectionClass:[MyHTTPConnection class]];
	[httpServer setDocumentRoot:[NSURL fileURLWithPath:root]];
	[httpServer setPort:50000];
	
	NSError *error;
	if(![httpServer start:&error])
	{
		NSLog(@"Error starting HTTP Server: %@", error);
	}
	
	[[[ScriptRunner alloc] init] autorelease];
#endif
}


- (void)resetApp:(NSDictionary*)data {
	[viewController setSnaps:[NSArray array]];
	[viewController setLookupPattern:[WhatJustPlayedViewController defaultLookupPattern]];
	[viewController setTestTime:nil];
}


- (void)setTestData:(NSDictionary*)data {
	NSArray* table = [data objectForKey:@"snaps"];
	if (table)
	{
		NSMutableArray* snaps = [NSMutableArray array];
		NSEnumerator* e = [table objectEnumerator];
		NSDictionary* dict;
		
		while ((dict = [e nextObject]))
		{
			NSString* station = [dict objectForKey:@"station"];
			NSString* time = [dict objectForKey:@"time"];
			NSDateFormatter *dateFormat =
				[[[NSDateFormatter alloc] init] autorelease];
			[dateFormat setDateStyle:NSDateFormatterNoStyle];
			[dateFormat setTimeStyle:NSDateFormatterShortStyle];
			NSDate* date = [dateFormat dateFromString:time];
			
			Snap* snap = [[Snap alloc] initWithStation:station creationTime:date];
			[snaps addObject:snap];
		}
		
		[viewController setSnaps:snaps];
	}

	NSString* lookupPattern = [data objectForKey:@"lookupPattern"];
	if (lookupPattern)
	{
		[viewController setLookupPattern:lookupPattern];
	}

	NSString* testTime = [data objectForKey:@"testTime"];
	if (testTime)
	{
		NSDateFormatter* dateFormat = [[[NSDateFormatter alloc]
										initWithDateFormat:@"%I:%M" allowNaturalLanguage:NO] autorelease];
		NSDate* date = [dateFormat dateFromString:testTime];
		
		[viewController setTestTime:date];
	}
}


- (void)dealloc {
    [viewController release];
    [window release];
    [super dealloc];
}


@end
