//
//  WhatJustPlayedAppDelegate.h
//  WhatJustPlayed
//
//  Created by Ian Dees on 4/19/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WhatJustPlayedViewController;

@interface WhatJustPlayedAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    WhatJustPlayedViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet WhatJustPlayedViewController *viewController;

@end

