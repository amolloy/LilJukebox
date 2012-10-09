//
//  main.m
//  LilJukeBox
//
//  Created by Andy Molloy on 5/21/12.
//  Copyright (c) 2012 Andy Molloy. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ASMAppDelegate.h"

int main(int argc, char *argv[])
{
	NSAutoreleasePool* ap = [[NSAutoreleasePool alloc] init];
	int result = UIApplicationMain(argc, argv, nil, NSStringFromClass([ASMAppDelegate class]));
	[ap release];
	
	return result;
}
