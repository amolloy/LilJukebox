//
//  ASMFlipsideViewController.m
//  LilJukeBox
//
//  Created by Andrew Molloy on 5/24/12.
//  Copyright (c) 2012 Andy Molloy. All rights reserved.
//

#import "ASMFlipsideViewController.h"
#import "ASMSongCollection.h"
#import "ASMMainViewController.h"

enum 
{
   kSongsSection,
   kConfigurationSection,
   
   kNumSections
};

@interface ASMFlipsideViewController ()
- (void)addSongs:(id)sender;
- (void)done:(id)sender;
- (void)deleteAllSongs:(id)sender;
- (void)configSwitchChanged:(UISwitch*)sender;

- (void)setupButtonStates;
- (UIImage*)imageForRow:(NSUInteger)row;

@property (strong, nonatomic) UIActionSheet* deleteActionSheet;
@property (strong, nonatomic) UIBarButtonItem* trashButton;
@property (strong, nonatomic) UIBarButtonItem* addButton;
@property (strong, nonatomic) UIBarButtonItem* helpMessageItem;
@property (strong, nonatomic) UISwitch* hideConfigSwitch;
@property (strong, nonatomic) IBOutlet UIView *helpView;
@property (strong, nonatomic) IBOutlet UILabel *helpLabel;

@end

@implementation ASMFlipsideViewController

@synthesize delegate;
@synthesize mediaPickerController;
@synthesize deleteActionSheet;
@synthesize trashButton;
@synthesize addButton;
@synthesize helpMessageItem;
@synthesize hideConfigSwitch;
@synthesize helpView;
@synthesize helpLabel;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self)
    {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationItem.rightBarButtonItem = self.editButtonItem;

    UIBarButtonItem* doneButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                                                     target:self
                                                                                     action:@selector(done:)];
    
    self.navigationItem.leftBarButtonItem = doneButtonItem;
    
    self.navigationController.toolbarHidden = NO;
	
	if ([self.tableView respondsToSelector:@selector(setBackgroundView:)])
	{
		self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"WhiteLinen"]];
	}
	
	self.hideConfigSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
	[self.hideConfigSwitch addTarget:self
							  action:@selector(configSwitchChanged:)
					forControlEvents:UIControlEventValueChanged];
	
	self.hideConfigSwitch.on = [[NSUserDefaults standardUserDefaults] boolForKey:kHideConfigUserDefaultsKey];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.trashButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash
                                                                      target:self
                                                                      action:@selector(deleteAllSongs:)];
    
	UIBarButtonItem* flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                    target:nil
                                                                                    action:nil];
	
	self.helpMessageItem = [[UIBarButtonItem alloc] initWithTitle:@""
															 style:UIBarButtonItemStylePlain
															target:nil
															action:nil];
	
    self.addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                    target:self
                                                                    action:@selector(addSongs:)];
    
    NSArray* toolbarItems = [NSArray arrayWithObjects:self.trashButton, flexibleSpace, self.helpMessageItem, self.addButton, nil];
    [self setToolbarItems:toolbarItems animated:NO];
    
    [self setupButtonStates];

	self.helpLabel.text = NSLocalizedString(@"Tap the plus to select songs:", @"Prompt to press the + symbol to add songs");
}

- (UIImage*)imageForRow:(NSUInteger)row
{
	UIImage* img = nil;
	
	if (row < [ASMSongCollection sharedSongCollection].playableSongCount)
	{
		const CGSize imageSize = { 30, 30 };
		
		if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)])
		{
			UIGraphicsBeginImageContextWithOptions(imageSize,
												   NO,
												   [UIScreen mainScreen].scale);
		}
		else
		{
			UIGraphicsBeginImageContext(imageSize);
		}
		
		CGContextRef ctx = UIGraphicsGetCurrentContext();
		CGContextSetFillColorWithColor(ctx, [ASMSongCollection colorForSongIndex:row].CGColor);
		CGContextFillEllipseInRect(ctx, CGRectMake(0, 0, 30, 30));
		
		img = UIGraphicsGetImageFromCurrentImageContext();
		
		UIGraphicsEndImageContext();
	}
	
	return img;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    
    [self setupButtonStates];
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	CGFloat height = 44;
	if (indexPath.section == kConfigurationSection && indexPath.row == 1)
	{
		height*= 2;
	}
	
	return height;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return kNumSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numRows = 0;
    
    switch (section) 
    {
        case kSongsSection:
        {
            numRows = [[ASMSongCollection sharedSongCollection] songCount];
            break;
        }
            
        case kConfigurationSection:
        {
			if (self.hideConfigSwitch.on)
			{
				numRows = 2;
			}
			else
			{
				numRows = 1;
			}
            break;
        }
            
        default:
        {
		    break;
        }
    }
   

    return numRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = nil;
    
    switch (indexPath.section)
    {
        case kSongsSection:
        {
            static NSString *SongCellIdentifier = @"SongCell";
            cell = [tableView dequeueReusableCellWithIdentifier:SongCellIdentifier];
            
            if (nil == cell)
            {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:SongCellIdentifier];
            }
            
            MPMediaItem* item = [[[ASMSongCollection sharedSongCollection] songs] objectAtIndex:indexPath.row];
            
            cell.textLabel.text = [item valueForProperty:MPMediaItemPropertyTitle];
            cell.detailTextLabel.text = [item valueForProperty:MPMediaItemPropertyArtist];
            cell.imageView.image = [self imageForRow:indexPath.row];
			
            break;
        }
            
        case kConfigurationSection:
        {
            if (0 == indexPath.row)
            {
                static NSString *ConfigCellIdentifier = @"ConfigCell";
                cell = [tableView dequeueReusableCellWithIdentifier:ConfigCellIdentifier];
                
                if (nil == cell)
                {
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ConfigCellIdentifier];
                }
                
                cell.accessoryView = self.hideConfigSwitch;
                cell.textLabel.text = NSLocalizedString(@"Hide Configuration Button", @"Hide Configuration Button");
            }
            else if (1 == indexPath.row)
            {
                static NSString *ConfigDescCellIdentifier = @"ConfigDescCell";
                cell = [tableView dequeueReusableCellWithIdentifier:ConfigDescCellIdentifier];
                
                if (nil == cell)
                {
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ConfigDescCellIdentifier];
					cell.textLabel.lineBreakMode = UILineBreakModeWordWrap;
					cell.textLabel.numberOfLines = 0;
                }
                
                cell.textLabel.text = NSLocalizedString(@"To re-enable the configuration button, visit the Settings app.", @"How to re-enable the config button");
            }
            break;
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        [[ASMSongCollection sharedSongCollection] removeSongAtIndex:indexPath.row];
        
        [tableView beginUpdates];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [tableView endUpdates];
    }
}

- (void)resetCellImages
{
	for (NSInteger i = 0; i < [[ASMSongCollection sharedSongCollection] songCount]; ++i)
	{
		UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
		cell.imageView.image = [self imageForRow:i];
	}
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    [[ASMSongCollection sharedSongCollection] moveSongFromIndex:fromIndexPath.row
                                                        toIndex:toIndexPath.row];
	[NSTimer scheduledTimerWithTimeInterval:0
									 target:self
								   selector:@selector(resetCellImages)
								   userInfo:nil
									repeats:NO];
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    BOOL canMove = NO;
    
    if (kSongsSection == indexPath.section)
    {
        canMove = YES;
    }
    
    return canMove;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    BOOL canEdit = NO;
    
    if (kSongsSection == indexPath.section)
    {
        canEdit = YES;
    }
    
    return canEdit;
}

- (void)done:(id)sender
{
    [self.delegate flipsideViewControllerDidFinish:self];
}

- (void)addSongs:(id)sender
{
    if (nil == self.mediaPickerController)
    {
        self.mediaPickerController = [[MPMediaPickerController alloc] initWithMediaTypes:MPMediaTypeAnyAudio];
        self.mediaPickerController.allowsPickingMultipleItems = YES;
        self.mediaPickerController.delegate = self;
    
		if ([self.mediaPickerController respondsToSelector:@selector(setModalPresentationStyle:)])
		{
			self.mediaPickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
			self.mediaPickerController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
		}
	}
    
    [self.navigationController presentModalViewController:self.mediaPickerController animated:YES];
}

- (void)deleteAllSongs:(id)sender
{
    self.deleteActionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Remove all songs, are you sure?", @"Prompt to delete all songs")
                                                             delegate:self
                                                    cancelButtonTitle:NSLocalizedString(@"No", @"Decline to remove all songs")
                                               destructiveButtonTitle:NSLocalizedString(@"Yes", @"Accept to remove all songs")
                                                    otherButtonTitles:nil];

    if ([self.deleteActionSheet respondsToSelector:@selector(showFromBarButtonItem:animated:)])
    {
        [self.deleteActionSheet showFromBarButtonItem:self.trashButton
                                             animated:YES];
    }
    else
    {
        [self.deleteActionSheet showFromToolbar:self.navigationController.toolbar];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (0 == buttonIndex)
    {
        [[ASMSongCollection sharedSongCollection] removeAllSongs];
        [self.tableView reloadData];
		[self setupButtonStates];
    }
    
    self.deleteActionSheet = nil;
}

- (void)mediaPicker: (MPMediaPickerController *)mediaPicker didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection
{
    [self.navigationController dismissModalViewControllerAnimated:YES];
    
    [[ASMSongCollection sharedSongCollection] mergeSongsWithCollection:mediaItemCollection];
    
    [self.tableView reloadData];
    
    self.mediaPickerController = nil;
	
	[self setupButtonStates];
}

- (void)mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker
{
    [self.navigationController dismissModalViewControllerAnimated:YES];

    self.mediaPickerController = nil;
}

- (void)setupButtonStates
{
    NSInteger songCount = [[ASMSongCollection sharedSongCollection] songCount];
	self.trashButton.enabled = (songCount > 0);
	
	if ([[ASMSongCollection sharedSongCollection] songCount] == 0)
	{
		if ([self.tableView respondsToSelector:@selector(setBackgroundView:)])
		{
			[self.tableView.backgroundView addSubview:self.helpView];
		}
		else
		{
			self.helpMessageItem.title = NSLocalizedString(@"Tap the plus to select songs:", @"Prompt to press the + symbol to add songs");
		}
		
		CGRect helpViewFrame = self.helpView.frame;
		helpViewFrame.origin = CGPointMake(CGRectGetMaxX(self.tableView.frame) - 40 - helpViewFrame.size.width,
										   CGRectGetMaxY(self.tableView.frame) - helpViewFrame.size.height);
		self.helpView.frame = helpViewFrame;
		
		self.helpView.alpha = 0;
		[UIView beginAnimations:@"fade in" context:nil];
		self.helpView.alpha = 1;
		[UIView commitAnimations];
	}
	else
	{
		[self.helpView removeFromSuperview];
		self.helpMessageItem.title = @"";
	}
}

- (void)configSwitchChanged:(UISwitch*)sender
{
    [[NSUserDefaults standardUserDefaults] setBool:self.hideConfigSwitch.on
                                            forKey:kHideConfigUserDefaultsKey];
	[self.tableView reloadData];
}

@end
