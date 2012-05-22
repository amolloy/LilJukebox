//
//  ASMFlipsideViewController.h
//  LilJukeBox
//
//  Created by Andy Molloy on 5/21/12.
//  Copyright (c) 2012 Andy Molloy. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ASMFlipsideViewController;

@protocol ASMFlipsideViewControllerDelegate
- (void)flipsideViewControllerDidFinish:(ASMFlipsideViewController *)controller;
@end

@interface ASMFlipsideViewController : UIViewController

@property (assign, nonatomic) id <ASMFlipsideViewControllerDelegate> delegate;

- (IBAction)done:(id)sender;

@end
