//
//  ASMMainViewController.h
//  LilJukeBox
//
//  Created by Andy Molloy on 5/21/12.
//  Copyright (c) 2012 Andy Molloy. All rights reserved.
//

#import "ASMFlipsideViewController.h"

extern NSString* kHideConfigUserDefaultsKey;

@interface ASMMainViewController : UIViewController <ASMFlipsideViewControllerDelegate>

@property (strong, nonatomic) UIPopoverController* flipsidePopoverController;

-(IBAction)showInfo:(id)sender;

@end
