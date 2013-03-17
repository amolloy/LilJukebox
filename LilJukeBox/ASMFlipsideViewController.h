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

@interface ASMFlipsideViewController : UITableViewController <MPMediaPickerControllerDelegate, UIActionSheetDelegate>

@property (unsafe_unretained, nonatomic) id <ASMFlipsideViewControllerDelegate> delegate;
@property (strong, nonatomic) MPMediaPickerController* mediaPickerController;

@end
