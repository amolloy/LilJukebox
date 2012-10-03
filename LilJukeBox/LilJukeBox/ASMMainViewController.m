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
#import <QuartzCore/QuartzCore.h>

NSString* kHideConfigUserDefaultsKey = @"HideConfig";

@interface ASMMainViewController ()

@property (retain, nonatomic) IBOutlet UIButton *flipViewButton;
@property (retain, nonatomic) NSArray* songButtons;
@property (retain, nonatomic) IBOutlet UIView *containerView;
@property (retain, nonatomic) IBOutlet UIView *infoContainerView;

- (IBAction)songButtonPressed:(UIButton *)sender;

@end

@implementation ASMMainViewController

@synthesize flipViewButton = _flipViewButton;

@synthesize flipsidePopoverController = _flipsidePopoverController;

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	NSMutableArray* buttons = [NSMutableArray arrayWithCapacity:[ASMSongCollection maxSongs]];
	
	for (NSUInteger i = 0; i < [ASMSongCollection maxSongs]; ++i)
	{
		UIView* songButton = [self.view viewWithTag:i + 1]; // Start tags at 1
		[buttons addObject:songButton];
		
		songButton.backgroundColor = [ASMSongCollection colorForSongIndex:i];
		songButton.layer.cornerRadius = songButton.frame.size.width / 2;
	}
	
	self.songButtons = [buttons copy];
	
	self.containerView.layer.cornerRadius = 10;
	self.containerView.layer.borderColor = [UIColor darkGrayColor].CGColor;
	self.containerView.layer.borderWidth = 5;
	
	self.infoContainerView.layer.cornerRadius = 10;
	self.infoContainerView.layer.borderColor = [UIColor darkGrayColor].CGColor;
	self.infoContainerView.layer.borderWidth = 5;
}

- (void)viewWillAppear:(BOOL)animated
{
    NSArray* songs = [[ASMSongCollection sharedSongCollection] songs];
    NSUInteger songCount = [songs count];
    
    for (NSUInteger i = 0; i < [ASMSongCollection maxSongs]; ++i)
    {
        UIButton* button = [self.songButtons objectAtIndex:i];

        BOOL songAvailable = (i < songCount);
        
        button.enabled = songAvailable;
		
		if (songAvailable)
		{
			button.backgroundColor = [ASMSongCollection colorForSongIndex:i];
		}
		else
		{
			button.backgroundColor = [UIColor darkGrayColor];
		}
    }
    
    self.flipViewButton.hidden = [[NSUserDefaults standardUserDefaults] boolForKey:kHideConfigUserDefaultsKey];
}

- (void)viewDidUnload
{
	[self setContainerView:nil];
	[self setInfoContainerView:nil];
    [super viewDidUnload];
    self.songButtons = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

- (BOOL)shouldAutorotate
{
	return NO;
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
    [self.flipsidePopoverController release];
    [self.songButtons release];
	[_containerView release];
	[_infoContainerView release];
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
    NSUInteger songIndex = tag - 1;
	
	NSArray* songs = [[ASMSongCollection sharedSongCollection] songs];
	
	if (tag > [songs count])
	{
		NSLog(@"Selected invalid button, shouldn't be possible");
		return;
	}

    MPMediaItem* item = [songs objectAtIndex:songIndex];
    
    [self dismissModalViewControllerAnimated: YES];

    MPMediaItemCollection* collection = [MPMediaItemCollection collectionWithItems:[NSArray arrayWithObject:item]];
    
    MPMusicPlayerController* appMusicPlayer = [MPMusicPlayerController applicationMusicPlayer];
    [appMusicPlayer setQueueWithItemCollection:collection];
    [appMusicPlayer play];
}

@end

