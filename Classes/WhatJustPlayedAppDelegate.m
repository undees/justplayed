//
//  WhatJustPlayedAppDelegate.m
//  WhatJustPlayed
//
//  Created by Ian Dees on 4/19/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "WhatJustPlayedAppDelegate.h"
#import "WhatJustPlayedViewController.h"

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


- (void)restoreDefaults:(NSDictionary*)ignored {
	[viewController setSnaps:[NSArray array]];
	viewController.lookupServer = [WhatJustPlayedViewController defaultLookupServer];
	viewController.testTime = nil;
}


- (void)restartApp:(NSDictionary*)ignored {
	[viewController reloadData];
}


- (void)setTestData:(NSDictionary*)data {
	NSArray* table = [data objectForKey:@"snaps"];
	if (table)
	{
		[viewController setSnaps:table];
	}

	NSString* lookupServer = [data objectForKey:@"lookupServer"];
	if (lookupServer)
	{
		[viewController setLookupServer:lookupServer];
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
