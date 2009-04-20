//
//  WhatJustPlayedAppDelegate.h
//  WhatJustPlayed
//
//  Created by Ian Dees on 4/19/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

#ifdef BROMINE_ENABLED
#import "HTTPServer.h"
#endif

@class WhatJustPlayedViewController;

@interface WhatJustPlayedAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    WhatJustPlayedViewController *viewController;

#ifdef BROMINE_ENABLED
	HTTPServer *httpServer;
#endif
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet WhatJustPlayedViewController *viewController;

@end

