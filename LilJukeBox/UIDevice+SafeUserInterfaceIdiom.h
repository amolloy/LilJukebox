//
//  UIDevice+SafeUserInterfaceIdiom.h
//  LilJukeBox
//
//  Created by Andrew Molloy on 6/1/12.
//  Copyright (c) 2012 Andy Molloy. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    UISafeUserInterfaceIdiomPhone,           // iPhone and iPod touch style UI
    UISafeUserInterfaceIdiomPad,             // iPad style UI
} UISafeUserInterfaceIdiom;

@interface UIDevice (SafeUserInterfaceIdiom)

// Identicial to userInterfaceIdiom, except that it is safe to call it on devices with iOS < 3.2 (in which case it returns UISafeUserInterfaceIdiomPhone).
-(UISafeUserInterfaceIdiom)safeUserInterfaceIdiom;

@end
