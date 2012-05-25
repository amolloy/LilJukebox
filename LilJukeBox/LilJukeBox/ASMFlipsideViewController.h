//
//  ASMFlipsideViewController.h
//  LilJukeBox
//
//  Created by Andrew Molloy on 5/24/12.
//  Copyright (c) 2012 Andy Molloy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

@class ASMFlipsideViewController;

@protocol ASMFlipsideViewControllerDelegate
- (void)flipsideViewControllerDidFinish:(ASMFlipsideViewController *)controller;
@end

@interface ASMFlipsideViewController : UITableViewController

@property (assign, nonatomic) id <ASMFlipsideViewControllerDelegate> delegate;

@end
