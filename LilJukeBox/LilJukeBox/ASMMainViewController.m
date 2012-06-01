//
//  ASMMainViewController.m
//  LilJukeBox
//
//  Created by Andy Molloy on 5/21/12.
//  Copyright (c) 2012 Andy Molloy. All rights reserved.
//

#import "ASMMainViewController.h"
#import "UIDevice+SafeUserInterfaceIdiom.h"

@interface ASMMainViewController ()

@end

@implementation ASMMainViewController

@synthesize flipsidePopoverController = _flipsidePopoverController;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
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

@end
