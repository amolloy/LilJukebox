//
//  ASMFlipsideViewController.h
//  LilJukeBox
//
//  Created by Andy Molloy on 5/21/12.
//  Copyright (c) 2012 Andy Molloy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

@class ASMFlipsideViewController;

@protocol ASMFlipsideViewControllerDelegate
- (void)flipsideViewControllerDidFinish:(ASMFlipsideViewController *)controller;
@end

@interface ASMFlipsideViewController : UIViewController <MPMediaPickerControllerDelegate>

@property (assign, nonatomic) id <ASMFlipsideViewControllerDelegate> delegate;

-(IBAction)done:(id)sender;
-(IBAction)selectMusicButtonPressed:(UIButton*)sender;

@end
