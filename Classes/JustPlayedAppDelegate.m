//
//  JustPlayedAppDelegate.m
//  JustPlayed
//
//  Created by Ian Dees on 4/19/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "JustPlayedAppDelegate.h"
#import "JustPlayedViewController.h"

#ifdef BROMINET_ENABLED
	#import "ScriptRunner.h"
	#import "MyHTTPConnection.h"
#endif

@implementation JustPlayedAppDelegate

@synthesize window;
@synthesize viewController;


- (void)applicationDidFinishLaunching:(UIApplication *)application {
    [window addSubview:viewController.view];
    [window makeKeyAndVisible];

#ifdef BROMINET_ENABLED
	NSString *root = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) objectAtIndex:0];
	httpServer = [HTTPServer new];
	[httpServer setName:@"the iPhone"];
	[httpServer setType:@"_http._tcp."];
	[httpServer setConnectionClass:[MyHTTPConnection class]];
	[httpServer setDocumentRoot:[NSURL fileURLWithPath:root]];
	[httpServer setPort:50000];

	ScriptRunner *runner = [[ScriptRunner alloc] init];
	[MyHTTPConnection setSharedObserver:runner];

	NSError *error;
	if(![httpServer start:&error])
	{
		NSLog(@"Error starting HTTP Server: %@", error);
	}

	[[[ScriptRunner alloc] init] autorelease];
#endif
}


- (void)restoreDefaults:(NSDictionary*)ignored {
	[viewController setToFactoryDefaults];
	[viewController refreshView];
}


- (void)restartApp:(NSDictionary*)ignored {
	[viewController saveUserData];
	[viewController setToFactoryDefaults];
	[viewController loadUserData];
	[viewController refreshView];
}


- (void)setTestData:(NSDictionary*)data {
	NSArray* stations = [data objectForKey:@"stations"];
	if (stations)
	{
		viewController.stations = stations;
	}
	
	NSArray* snaps = [data objectForKey:@"snaps"];
	if (snaps)
	{
		[viewController setSnaps:snaps];
	}

	NSString* lookupServer = [data objectForKey:@"lookupServer"];
	if (lookupServer)
	{
		viewController.lookupServer = lookupServer;
	}

	NSString* testTime = [data objectForKey:@"testTime"];
	if (testTime)
	{
		NSCalendarDate* date = [NSCalendarDate calendarDate];
		NSInteger year = [date yearOfCommonEra];
		NSInteger month = [date monthOfYear];
		NSInteger day = [date dayOfMonth];

		NSCalendarDate* time =
			[NSCalendarDate dateWithString:testTime calendarFormat:@"%H:%M"];
		NSInteger hour = [time hourOfDay];
		NSInteger minute = [time minuteOfHour];
		
		NSCalendarDate* dateTime =
			[NSCalendarDate
			 dateWithYear:year
			 month:month
			 day:day
			 hour:hour
			 minute:minute
			 second:0
			 timeZone:[NSTimeZone localTimeZone]];

		viewController.testTime = dateTime;
	}
	
	[viewController refreshView];
}


- (void)dealloc {
#ifdef BROMINET_ENABLED
	[httpServer release];
	[MyHTTPConnection setSharedObserver:nil];
#endif

	[viewController release];
    [window release];
    [super dealloc];
}


@end
