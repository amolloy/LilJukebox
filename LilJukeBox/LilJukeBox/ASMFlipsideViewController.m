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

@property (retain, nonatomic) UIActionSheet* deleteActionSheet;
@property (retain, nonatomic) UIBarButtonItem* trashButton;
@property (retain, nonatomic) UIBarButtonItem* addButton;
@property (retain, nonatomic) UISwitch* hideConfigSwitch;

@end

@implementation ASMFlipsideViewController

@synthesize delegate = _delegate;
@synthesize mediaPickerController = _mediaPickerController;
@synthesize deleteActionSheet = _deleteActionSheet;
@synthesize trashButton = _trashButton;
@synthesize addButton = _addButton;
@synthesize hideConfigSwitch = _hideConfigSwitch;

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

    UIBarButtonItem* doneButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                                                     target:self
                                                                                     action:@selector(done:)] autorelease];
    
    self.navigationItem.leftBarButtonItem = doneButtonItem;
    
    self.navigationController.toolbarHidden = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.trashButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash
                                                                      target:self
                                                                      action:@selector(deleteAllSongs:)] autorelease];
    UIBarButtonItem* flexibleSpace = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                    target:nil
                                                                                    action:nil] autorelease];
    self.addButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                    target:self
                                                                    action:@selector(addSongs:)] autorelease];
    
    NSArray* toolbarItems = [NSArray arrayWithObjects:self.trashButton, flexibleSpace, self.addButton, nil];
    [self setToolbarItems:toolbarItems animated:NO];
    
    [self setupButtonStates];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    self.trashButton = nil;
    self.addButton = nil;
    self.mediaPickerController = nil;
    self.deleteActionSheet = nil;
    self.hideConfigSwitch = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    
    [self setupButtonStates];
}

#pragma mark - Table view data source

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
            NSUInteger songCount = [[ASMSongCollection sharedSongCollection] songCount];
            
            if (songCount > 10000) // TODO
            {
                self.navigationItem.title = NSLocalizedString(@"Too many songs selected, please remove some.", @"Message when there are too many songs selected");
                self.editing = YES;
            }
            else
            {
                self.navigationItem.title = @"";
            }
            
            [self setupButtonStates];

		    numRows = songCount;
            
		    break;
        }
            
        case kConfigurationSection:
        {
            numRows = 2;
            
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
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:SongCellIdentifier] autorelease];
            }
            
            MPMediaItem* item = [[[ASMSongCollection sharedSongCollection] songs] objectAtIndex:indexPath.row];
            
            cell.textLabel.text = [item valueForProperty:MPMediaItemPropertyTitle];
            cell.detailTextLabel.text = [item valueForProperty:MPMediaItemPropertyArtist];
            
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
                    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:ConfigCellIdentifier] autorelease];
                }
                
                if (nil == self.hideConfigSwitch)
                {
                    self.hideConfigSwitch = [[[UISwitch alloc] initWithFrame:CGRectZero] autorelease];
                    [self.hideConfigSwitch addTarget:self
                                              action:@selector(configSwitchChanged:)
                                    forControlEvents:UIControlEventValueChanged];
                }
                
                self.hideConfigSwitch.on = [[NSUserDefaults standardUserDefaults] boolForKey:kHideConfigUserDefaultsKey];
                
                cell.accessoryView = self.hideConfigSwitch;
                cell.textLabel.text = NSLocalizedString(@"Hide Configuration Button", @"Hide Configuration Button");
            }
            else if (1 == indexPath.row)
            {
                static NSString *ConfigDescCellIdentifier = @"ConfigDescCell";
                cell = [tableView dequeueReusableCellWithIdentifier:ConfigDescCellIdentifier];
                
                if (nil == cell)
                {
                    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:ConfigDescCellIdentifier] autorelease];
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

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    [[ASMSongCollection sharedSongCollection] moveSongFromIndex:fromIndexPath.row
                                                        toIndex:toIndexPath.row];
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
        self.mediaPickerController = [[[MPMediaPickerController alloc] initWithMediaTypes:MPMediaTypeAnyAudio] autorelease];
        self.mediaPickerController.allowsPickingMultipleItems = YES;
        
//        NSInteger songCount = [[ASMSongCollection sharedSongCollection] songCount];
        NSInteger songsRemaining = 10000;// TODO [ASMSongCollection maxSongs] - songCount;
        if (songsRemaining < 0)
        {
            songsRemaining = 0;
        }
        
        NSString* promptFmt = NSLocalizedString(@"Please pick up to %1$i songs", @"Pick 10 Songs");
        NSString* prompt = [NSString stringWithFormat:promptFmt,songsRemaining];
        
        self.mediaPickerController.prompt = prompt;
        self.mediaPickerController.delegate = self;
    }
    
    [self.navigationController presentModalViewController:self.mediaPickerController animated:YES];
}

- (void)deleteAllSongs:(id)sender
{
    self.deleteActionSheet = [[[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Remove all songs, are you sure?", @"Prompt to delete all songs")
                                                             delegate:self
                                                    cancelButtonTitle:NSLocalizedString(@"No", @"Decline to remove all songs")
                                               destructiveButtonTitle:NSLocalizedString(@"Yes", @"Accept to remove all songs")
                                                    otherButtonTitles:nil] autorelease];

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
    }
    
    self.deleteActionSheet = nil;
}

- (void)mediaPicker: (MPMediaPickerController *)mediaPicker didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection
{
    [self.navigationController dismissModalViewControllerAnimated:YES];
    
    [[ASMSongCollection sharedSongCollection] mergeSongsWithCollection:mediaItemCollection];
    
    [self.tableView reloadData];
    
    self.mediaPickerController = nil;
}

- (void)mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker
{
    [self.navigationController dismissModalViewControllerAnimated:YES];

    self.mediaPickerController = nil;
}

- (void)setupButtonStates
{
    NSInteger songCount = [[ASMSongCollection sharedSongCollection] songCount];
	// TODO
	/*
	 BOOL isEditing = self.editing;
	 
    self.navigationItem.leftBarButtonItem.enabled = !isEditing && (songCount <= [ASMSongCollection maxSongs]);
    self.addButton.enabled = (songCount < [ASMSongCollection maxSongs]);
	 */
	 self.trashButton.enabled = (songCount > 0);
}

- (void)configSwitchChanged:(UISwitch*)sender
{
    [[NSUserDefaults standardUserDefaults] setBool:self.hideConfigSwitch.on
                                            forKey:kHideConfigUserDefaultsKey];
}


@end
