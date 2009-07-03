//
//  JustPlayedAppDelegate.h
//  JustPlayed
//
//  Created by Ian Dees on 4/19/09.
//  Copyright 25y26z 2009. See LICENSE.txt for details.
//

#import <UIKit/UIKit.h>

#ifdef BROMINET_ENABLED
#import "HTTPServer.h"
#endif

@class JustPlayedViewController;

@interface JustPlayedAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    JustPlayedViewController *viewController;

#ifdef BROMINET_ENABLED
	HTTPServer *httpServer;
#endif
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet JustPlayedViewController *viewController;

@end

