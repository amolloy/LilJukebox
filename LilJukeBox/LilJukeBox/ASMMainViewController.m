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

enum {
	kButtonSize = 64,
	kMinButtonSpacing = 10,
};

@interface ASMMainViewController ()

@property (retain, nonatomic) IBOutlet UIButton *flipViewButton;
@property (retain, nonatomic) NSArray* songButtons;
@property (retain, nonatomic) IBOutlet UIView *containerView;
@property (retain, nonatomic) IBOutlet UIView *infoContainerView;
@property (retain, nonatomic) IBOutlet UIView *buttonContainerView;

- (void)songButtonPressed:(UIButton *)sender;
- (void)songButtonChangedState:(UIButton *)sender;

@end

@implementation ASMMainViewController

- (void)songButtonChangedState:(UIButton*)sender
{
	if (sender.isHighlighted)
	{
		sender.backgroundColor = [ASMSongCollection hightlightColorForSongIndex:sender.tag - 1];
		sender.layer.borderColor = [ASMSongCollection colorForSongIndex:sender.tag - 1].CGColor;
	}
	else
	{
		sender.backgroundColor = [ASMSongCollection colorForSongIndex:sender.tag - 1];
		sender.layer.borderColor = [ASMSongCollection hightlightColorForSongIndex:sender.tag - 1].CGColor;
	}
}

- (void)setupSongButtons
{
	for (UIButton* button in self.songButtons)
	{
		[button removeFromSuperview];
	}

	NSInteger maxButtons = (NSInteger)floorf(self.buttonContainerView.frame.size.width / (CGFloat)(kButtonSize + kMinButtonSpacing));
	NSInteger numButtons = [[ASMSongCollection sharedSongCollection] songCount];
	if (numButtons > maxButtons)
	{
		numButtons = maxButtons;
	}
	NSInteger buttonXInc = (NSInteger)((self.buttonContainerView.frame.size.width - kButtonSize) / (numButtons - 1));
	
	NSMutableArray* buttons = [NSMutableArray arrayWithCapacity:numButtons];
	
	for (NSInteger i = 0; i < numButtons; ++i)
	{
		UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
		button.frame = CGRectMake(i * buttonXInc, 0, kButtonSize, kButtonSize);
		button.tag = i + 1;
		[self songButtonChangedState:button];
		
		button.layer.cornerRadius = button.frame.size.width / 2;
		button.layer.borderWidth = 3;
		
		[button addTarget:self
				   action:@selector(songButtonPressed:)
		 forControlEvents:UIControlEventTouchUpInside];
		[button addTarget:self
				   action:@selector(songButtonChangedState:)
		 forControlEvents:UIControlEventAllTouchEvents];
		
		[buttons addObject:button];
		[self.buttonContainerView addSubview:button];
	}
	
	self.songButtons = [[buttons copy] autorelease];
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	self.containerView.layer.cornerRadius = 10;
	self.containerView.layer.borderColor = [UIColor darkGrayColor].CGColor;
	self.containerView.layer.borderWidth = 5;
	
	self.infoContainerView.layer.cornerRadius = 10;
	self.infoContainerView.layer.borderColor = [UIColor darkGrayColor].CGColor;
	self.infoContainerView.layer.borderWidth = 5;
}

- (void)viewWillAppear:(BOOL)animated
{
    self.flipViewButton.hidden = [[NSUserDefaults standardUserDefaults] boolForKey:kHideConfigUserDefaultsKey];
	
	[self setupSongButtons];
}

- (void)viewDidUnload
{
	[self setContainerView:nil];
	[self setInfoContainerView:nil];
	[self setButtonContainerView:nil];
    [super viewDidUnload];
    self.songButtons = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return UIInterfaceOrientationIsLandscape(interfaceOrientation);
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
	[_buttonContainerView release];
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

- (void)songButtonPressed:(UIButton *)sender
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
	
	for (UIButton* button in self.songButtons)
	{
		if (button != sender)
		{
			[self songButtonChangedState:button];
		}
	}
}

@end

