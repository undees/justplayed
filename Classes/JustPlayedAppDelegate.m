//
//  JustPlayedAppDelegate.m
//  JustPlayed
//
//  Created by Ian Dees on 4/19/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "JustPlayedAppDelegate.h"
#import "JustPlayedViewController.h"
#import "Snap.h"

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

	ScriptRunner *runner = [[[ScriptRunner alloc] init] autorelease];
	[MyHTTPConnection setSharedObserver:runner];

	NSError *error;
	if(![httpServer start:&error])
	{
		NSLog(@"Error starting HTTP Server: %@", error);
	}
#endif
}


- (NSString*)restoreDefaults:(NSDictionary*)ignored {
	[viewController setToFactoryDefaults];

	return @"pass";
}


- (NSString*)terminateApp:(NSDictionary*)ignored {
	[viewController saveUserData];
	[[NSUserDefaults standardUserDefaults] synchronize];
	exit(0);

	return @"pass";
}


- (NSString*)getTestData:(NSDictionary*)data {
	NSString* key = [data objectForKey:@"key"];
	if ([key isEqualToString:@"lookupServer"])
	{
		NSData* data = [NSPropertyListSerialization
			dataFromPropertyList:(viewController.lookupServer)
			format:NSPropertyListXMLFormat_v1_0
			errorDescription:nil];
		return [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
	}
	else
	{
		return nil;
	}
}


- (NSDate*)dateFromClockTime:(NSString*)clockTime;
{
	NSDate* date = [NSDate date];
	NSCalendar* calendar = [NSCalendar currentCalendar];
	NSInteger dateUnits =
	NSYearCalendarUnit |
	NSMonthCalendarUnit |
	NSDayCalendarUnit;
	NSDateComponents* dateParts = [calendar components:dateUnits fromDate:date];
	
	NSDateFormatter* format = [[[NSDateFormatter alloc] init] autorelease];
	[format setDateFormat:@"HH:mm"];
	NSDate* time = [format dateFromString:clockTime];
	
	NSInteger timeUnits =
	NSHourCalendarUnit |
	NSMinuteCalendarUnit;
	NSDateComponents* timeParts = [calendar components:timeUnits fromDate:time];
	
	NSInteger hour = [timeParts hour];
	NSInteger minute = [timeParts minute];
	
	[dateParts setHour:hour];
	[dateParts setMinute:minute];
	
	return [calendar dateFromComponents:dateParts];
}


- (NSString*)setTestData:(NSDictionary*)data {
	NSArray* stations = [data objectForKey:@"stations"];
	if (stations)
	{
		viewController.stations = stations;
	}
	
	NSArray* plists = [data objectForKey:@"snaps"];
	if (plists)
	{
		[viewController setSnaps:[Snap snapsFromPropertyLists:plists]];
	}

	NSString* lookupServer = [data objectForKey:@"lookupServer"];
	if (lookupServer)
	{
		viewController.lookupServer = lookupServer;
	}

	NSString* testTime = [data objectForKey:@"testTime"];
	if (testTime)
	{
		viewController.testTime = [self dateFromClockTime:testTime];
	}
	
	[viewController refreshView];

	return @"pass";
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
