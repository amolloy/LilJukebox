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

NSString* kShowAlbumArtworkKey = @"ShowAlbumArtwork";
NSString* kHideConfigUserDefaultsKey = @"HideConfig";

enum {
	kButtonSize = 64,
	kMinButtonSpacing = 6,
};

@interface ASMMainViewController ()

@property (retain, nonatomic) IBOutlet UIButton *flipViewButton;
@property (retain, nonatomic) NSArray* songButtons;
@property (retain, nonatomic) IBOutlet UIView *containerView;
@property (retain, nonatomic) IBOutlet UIView *infoContainerView;
@property (retain, nonatomic) IBOutlet UIView *buttonContainerView;
@property (retain, nonatomic) IBOutlet UIImageView *albumArtworkView;
@property (retain, nonatomic) IBOutlet UILabel *artistNameLabel;
@property (retain, nonatomic) IBOutlet UILabel *songNameLabel;
@property (retain, nonatomic) IBOutlet UILabel *helpLabel;

- (void)songButtonPressed:(UIButton *)sender;
- (void)songButtonChangedState:(UIButton *)sender;

@end

@implementation ASMMainViewController

@synthesize flipViewButton;
@synthesize songButtons;
@synthesize containerView;
@synthesize infoContainerView;
@synthesize buttonContainerView;
@synthesize albumArtworkView;
@synthesize artistNameLabel;
@synthesize songNameLabel;
@synthesize helpLabel;
@synthesize flipsidePopoverController;

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
	
#ifdef FAKE_FOR_SCREENSHOTS
	numButtons = 10000;
#endif
	
	if (numButtons > maxButtons)
	{
		numButtons = maxButtons;
	}
	NSInteger buttonXInc = (NSInteger)((self.buttonContainerView.frame.size.width - kButtonSize) / (numButtons - 1));
	
	NSMutableArray* buttons = [NSMutableArray arrayWithCapacity:numButtons];
	
	static BOOL sFirstRun = YES;
	
	for (NSInteger i = 0; i < numButtons; ++i)
	{
		UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
		
		if (numButtons == 1)
		{
			button.frame = CGRectMake(self.buttonContainerView.frame.size.width / 2 - kButtonSize / 2, 0, kButtonSize, kButtonSize);
		}
		else
		{
			button.frame = CGRectMake(i * buttonXInc, 0, kButtonSize, kButtonSize);
		}
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
		
		
		NSArray* songs = [[ASMSongCollection sharedSongCollection] songs];
		MPMediaItem* item = [songs objectAtIndex:i];
		
		NSString* artistName = [item valueForKey:MPMediaItemPropertyArtist];
		if (!artistName) artistName = NSLocalizedString(@"Uknown artist", @"assistive description for an artist with an unknown name.");
		
		NSString* songName = [item valueForKey:MPMediaItemPropertyTitle];
		if (!songName) songName = NSLocalizedString(@"Uknown song", @"assistive description for song with an unknown title.");
		
		NSString* assistiveDesc = [NSString stringWithFormat:NSLocalizedString(@"Play %1$@ by %2$@", @"Assistive description for song buttons. %1$@ is the song title, %2$@ is the artist's name"),
								   songName,
								   artistName];
		button.accessibilityLabel = assistiveDesc;

		[self.buttonContainerView addSubview:button];
		
		if (sFirstRun)
		{
			button.alpha = 0;
			[UIView beginAnimations:@"fade in buttons" context:nil];
			[UIView setAnimationDuration:1];
			button.alpha = 1;
			[UIView commitAnimations];
		}
	}

	self.songButtons = [[buttons copy] autorelease];

	if (sFirstRun)
	{
		sFirstRun = NO;
	}

	self.helpLabel.text = @"";
	if (0 == numButtons)
	{
		if (self.flipViewButton.hidden)
		{
			self.helpLabel.text = NSLocalizedString(@"To add songs, enable configuration in the Settings app.", @"Prompt to parents when there are no songs and the configure button has been hidden.");
			self.helpLabel.textAlignment = UITextAlignmentCenter;
		}
		else
		{
			self.helpLabel.text = NSLocalizedString(@"Parents: Tap here to add songs:", @"Prompt to parents when there are no songs and the configure button is visible.");
			self.helpLabel.textAlignment = UITextAlignmentRight;
		}
		
		[UIView beginAnimations:@"fade in" context:nil];
		[UIView setAnimationDuration:1];
		self.helpLabel.alpha = 1;
		[UIView commitAnimations];
	}
	
	[ASMSongCollection sharedSongCollection].playableSongCount = maxButtons;
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
	
	self.songNameLabel.text = @"";
	self.artistNameLabel.text = @"";
	
	self.albumArtworkView.layer.cornerRadius = 5;
	self.albumArtworkView.layer.borderColor = [UIColor blackColor].CGColor;
	self.albumArtworkView.layer.borderWidth = 2;
	self.albumArtworkView.alpha = 0;

	self.helpLabel.alpha = 0;
}

- (void)viewWillAppear:(BOOL)animated
{
    self.flipViewButton.hidden = [[NSUserDefaults standardUserDefaults] boolForKey:kHideConfigUserDefaultsKey];
	self.flipViewButton.accessibilityLabel = NSLocalizedString(@"Settings", @"Accessibility label for settings button, spoken aloud");
	
	static BOOL sFirstRun = YES;
	if (sFirstRun)
	{
		sFirstRun = NO;
		self.flipViewButton.alpha = 0;
		[UIView beginAnimations:@"fade in buttons" context:nil];
		[UIView setAnimationDuration:1];
		self.flipViewButton.alpha = 1;
		[UIView commitAnimations];
	}
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
	
	[self setupSongButtons];
}

- (void)dealloc
{
    [self.flipsidePopoverController release];
    [self.songButtons release];
	[self.containerView release];
	[self.infoContainerView release];
	[self.buttonContainerView release];
	[self.albumArtworkView release];
	[self.artistNameLabel release];
	[self.songNameLabel release];
	[self.helpLabel release];
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

	BOOL showAlbumArtwork = [[NSUserDefaults standardUserDefaults] boolForKey:kShowAlbumArtworkKey];

	MPMediaItemArtwork* artwork = [item valueForKey:MPMediaItemPropertyArtwork];
	UIImage* artworkImage = [artwork imageWithSize:self.albumArtworkView.frame.size];
	showAlbumArtwork&= artworkImage != nil;
	
	if (showAlbumArtwork)
	{
		CGFloat labelsX = CGRectGetMaxX(self.albumArtworkView.frame) + 10;
		CGFloat labelsWidth = self.infoContainerView.frame.size.width - 10 - labelsX;
		
		[UIView beginAnimations:@"move in" context:nil];
		CGRect workRect = self.artistNameLabel.frame;
		workRect.origin.x = labelsX;
		workRect.size.width = labelsWidth;
		self.artistNameLabel.frame = workRect;
		
		workRect = self.songNameLabel.frame;
		workRect.origin.x = labelsX;
		workRect.size.width = labelsWidth;
		self.songNameLabel.frame = workRect;
		
		self.albumArtworkView.alpha = 1;
		[UIView commitAnimations];
		
		self.albumArtworkView.image = artworkImage;
	}
	else
	{
		CGFloat labelsX = 10;
		CGFloat labelsWidth = self.infoContainerView.frame.size.width - 10 - labelsX;
		
		[UIView beginAnimations:@"move in" context:nil];
		CGRect workRect = self.artistNameLabel.frame;
		workRect.origin.x = labelsX;
		workRect.size.width = labelsWidth;
		self.artistNameLabel.frame = workRect;
		
		workRect = self.songNameLabel.frame;
		workRect.origin.x = labelsX;
		workRect.size.width = labelsWidth;
		self.songNameLabel.frame = workRect;

		self.albumArtworkView.alpha = 0;
		[UIView commitAnimations];
	}
	
	NSString* artistName = [item valueForKey:MPMediaItemPropertyArtist];
	if (!artistName) artistName = @"";
	self.artistNameLabel.text = artistName;
	
	NSString* songName = [item valueForKey:MPMediaItemPropertyTitle];
	if (!songName) songName = @"";
	self.songNameLabel.text = songName;
	
	for (UIButton* button in self.songButtons)
	{
		if (button != sender)
		{
			[self songButtonChangedState:button];
		}
	}
}

-(void)viewWillLayoutSubviews
{
	[super performSelector:@selector(viewWillLayoutSubviews)];
	[self setupSongButtons];
}

@end

