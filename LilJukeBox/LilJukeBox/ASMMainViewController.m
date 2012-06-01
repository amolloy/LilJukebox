//
//  ASMMainViewController.m
//  LilJukeBox
//
//  Created by Andy Molloy on 5/21/12.
//  Copyright (c) 2012 Andy Molloy. All rights reserved.
//

#import "ASMMainViewController.h"
#import "UIDevice+SafeUserInterfaceIdiom.h"
#import "ASMSongCollection.h"
#import <MediaPlayer/MediaPlayer.h>

@interface ASMMainViewController ()

@property (retain, nonatomic) IBOutlet UIButton *songButton0;
@property (retain, nonatomic) IBOutlet UIButton *songButton1;
@property (retain, nonatomic) IBOutlet UIButton *songButton2;
@property (retain, nonatomic) IBOutlet UIButton *songButton3;
@property (retain, nonatomic) IBOutlet UIButton *songButton4;
@property (retain, nonatomic) IBOutlet UIButton *songButton5;
@property (retain, nonatomic) IBOutlet UIButton *songButton6;
@property (retain, nonatomic) IBOutlet UIButton *songButton7;
@property (retain, nonatomic) IBOutlet UIButton *songButton8;
@property (retain, nonatomic) IBOutlet UIButton *songButton9;

@property (retain, nonatomic) NSArray* songButtons;

- (IBAction)songButtonPressed:(UIButton *)sender;

@end

@implementation ASMMainViewController

@synthesize songButton0 = _songButton0;
@synthesize songButton1 = _songButton1;
@synthesize songButton2 = _songButton2;
@synthesize songButton3 = _songButton3;
@synthesize songButton4 = _songButton4;
@synthesize songButton5 = _songButton5;
@synthesize songButton6 = _songButton6;
@synthesize songButton7 = _songButton7;
@synthesize songButton8 = _songButton8;
@synthesize songButton9 = _songButton9;
@synthesize songButtons = _songButtons;

@synthesize flipsidePopoverController = _flipsidePopoverController;

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.songButtons = [NSArray arrayWithObjects:
                        self.songButton0,
                        self.songButton1,
                        self.songButton2,
                        self.songButton3,
                        self.songButton4,
                        self.songButton5,
                        self.songButton6,
                        self.songButton7,
                        self.songButton8,
                        self.songButton9,
                        nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    NSArray* songs = [[ASMSongCollection sharedSongCollection] songs];
    NSUInteger songCount = [songs count];
    
    for (NSUInteger i = 0; i < 10; ++i)
    {
        UIButton* button = [self.songButtons objectAtIndex:i];

        BOOL songAvailable = (i < songCount);
        
        button.enabled = songAvailable;
        
        NSString* title = @"";
        
        if (songAvailable)
        {
            MPMediaItem* item = [songs objectAtIndex:i];
            title = [item valueForProperty:MPMediaItemPropertyTitle];
        }

        [button setTitle:title
                forState:UIControlStateNormal];
    }
}

- (void)viewDidUnload
{
    [self setSongButton0:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] safeUserInterfaceIdiom] == UISafeUserInterfaceIdiomPhone)
    {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    }
    else
    {
        return YES;
    }
}

#pragma mark - Flipside View Controller

- (void)flipsideViewControllerDidFinish:(ASMFlipsideViewController *)controller
{
    if ([[UIDevice currentDevice] safeUserInterfaceIdiom] == UISafeUserInterfaceIdiomPhone)
    {
        [self dismissModalViewControllerAnimated:YES];
    }
    else
    {
        [self.flipsidePopoverController dismissPopoverAnimated:YES];
    }
}

- (void)dealloc
{
    [_flipsidePopoverController release];
    [_songButton0 release];
    [super dealloc];
}

- (IBAction)showInfo:(id)sender
{
    if ([[UIDevice currentDevice] safeUserInterfaceIdiom] == UISafeUserInterfaceIdiomPhone)
    {
        ASMFlipsideViewController *controller = [[[ASMFlipsideViewController alloc] initWithNibName:@"ASMFlipsideViewController" bundle:nil] autorelease];
        controller.delegate = self;
        controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        
        UINavigationController *navController = [[[UINavigationController alloc] initWithRootViewController:controller] autorelease];
        navController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        
        [self presentModalViewController:navController animated:YES];
    }
    else
    {
        if (!self.flipsidePopoverController)
        {
            ASMFlipsideViewController *controller = [[[ASMFlipsideViewController alloc] initWithNibName:@"ASMFlipsideViewController" bundle:nil] autorelease];
            controller.delegate = self;

            UINavigationController *navController = [[[UINavigationController alloc] initWithRootViewController:controller] autorelease];
            navController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;

            self.flipsidePopoverController = [[[UIPopoverController alloc] initWithContentViewController:navController] autorelease];
        }
        
        if ([self.flipsidePopoverController isPopoverVisible])
        {
            [self.flipsidePopoverController dismissPopoverAnimated:YES];
        }
        else
        {
            [self.flipsidePopoverController presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        }
    }
}

- (IBAction)songButtonPressed:(UIButton *)sender
{
    NSUInteger tag = sender.tag;
    NSArray* songs = [[ASMSongCollection sharedSongCollection] songs];
    
    MPMediaItem* item = [songs objectAtIndex:tag];
    
    [self dismissModalViewControllerAnimated: YES];

    MPMediaItemCollection* collection = [MPMediaItemCollection collectionWithItems:[NSArray arrayWithObject:item]];
    
    MPMusicPlayerController* appMusicPlayer = [MPMusicPlayerController applicationMusicPlayer];
    [appMusicPlayer setQueueWithItemCollection:collection];
    [appMusicPlayer play];
}

@end

