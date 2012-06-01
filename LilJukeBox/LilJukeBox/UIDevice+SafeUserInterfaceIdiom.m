//
//  UIDevice+SafeUserInterfaceIdiom.m
//  LilJukeBox
//
//  Created by Andrew Molloy on 6/1/12.
//  Copyright (c) 2012 Andy Molloy. All rights reserved.
//

#import "UIDevice+SafeUserInterfaceIdiom.h"

@implementation UIDevice (SafeUserInterfaceIdiom)

-(UISafeUserInterfaceIdiom)safeUserInterfaceIdiom
{
    UISafeUserInterfaceIdiom idiom = UISafeUserInterfaceIdiomPhone;
    
    if ([self respondsToSelector:@selector(userInterfaceIdiom)])
    {
        idiom = (UISafeUserInterfaceIdiom)[self userInterfaceIdiom];
    }
    
    return idiom;
}

@end
