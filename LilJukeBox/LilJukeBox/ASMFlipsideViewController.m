//
//  ASMFlipsideViewController.m
//  LilJukeBox
//
//  Created by Andy Molloy on 5/21/12.
//  Copyright (c) 2012 Andy Molloy. All rights reserved.
//

#import "ASMFlipsideViewController.h"

@interface ASMFlipsideViewController ()

@end

@implementation ASMFlipsideViewController

@synthesize delegate = _delegate;

-(id)initWithNibName:(NSString*)nibNameOrNil bundle:(NSBundle*)nibBundleOrNil
{
   self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
   if (self) 
   {
      self.contentSizeForViewInPopover = CGSizeMake(320.0, 480.0);
   }
   return self;
}

-(void)viewDidLoad
{
   [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

-(void)viewDidUnload
{
   [super viewDidUnload];
   // Release any retained subviews of the main view.
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
   if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) 
   {
      return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
   }
   else 
   {
      return YES;
   }
}

#pragma mark - Actions

-(IBAction)done:(id)sender
{
   [self.delegate flipsideViewControllerDidFinish:self];
}

-(IBAction)selectMusicButtonPressed:(UIButton *)sender 
{
   MPMediaPickerController* picker = [[MPMediaPickerController alloc] initWithMediaTypes: MPMediaTypeAnyAudio];
   
   [picker setDelegate:self];
   [picker setAllowsPickingMultipleItems:YES];
   picker.prompt = NSLocalizedString (@"Add songs to play",
                                      "Prompt in media item picker");
   
   [self presentModalViewController:picker animated: YES];
   [picker release];
}

-(void)mediaPicker:(MPMediaPickerController*)mediaPicker didPickMediaItems:(MPMediaItemCollection*)mediaItemCollection
{
   if ([mediaItemCollection count] > 10)
   {
      NSLog(@"Picked too many");
   }
   
   NSLog(@"Picked:");
   NSLog(@"%@", mediaItemCollection);
}
@end
