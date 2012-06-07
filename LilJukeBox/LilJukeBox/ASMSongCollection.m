//
//  ASMSongCollection.m
//  LilJukeBox
//
//  Created by Andrew Molloy on 5/31/12.
//  Copyright (c) 2012 Andy Molloy. All rights reserved.
//

#import "ASMSongCollection.h"

static NSString* kSongIdentifiersKey = @"SongIdentifiers";
static ASMSongCollection *sSharedSongCollection = nil;

@interface ASMSongCollection ()
@property (retain, nonatomic) NSArray* songs;

- (void)updateUserDefaults;
@end

@implementation ASMSongCollection

@synthesize songs = _songs;

- (id)init
{
    self = [super init];
    if (nil != self)
    {
        NSArray* identifiers = [[NSUserDefaults standardUserDefaults] arrayForKey:kSongIdentifiersKey];
        
        if ([identifiers count] != 0)
        {
            NSMutableArray* setSongs = [NSMutableArray arrayWithCapacity:[identifiers count]];
            
            for (NSString* identifier in identifiers)
            {
                MPMediaQuery* mq = [MPMediaQuery songsQuery];
                
                MPMediaPredicate* mp = [MPMediaPropertyPredicate predicateWithValue:identifier
                                                                        forProperty:MPMediaItemPropertyPersistentID];
                [mq addFilterPredicate:mp];
                
                MPMediaItem* item = [mq.items lastObject];
                
                if (nil != item)
                {
                    [setSongs addObject:item];
                }
            }
            
            self.songs = setSongs;
        }
        else
        {
            self.songs = [NSArray array];
        }
    }
    
    return self;
}

- (void)dealloc
{
    self.songs = nil;
    [super dealloc];
}

- (void)setSongsWithCollection:(MPMediaItemCollection*)collection
{
    self.songs = collection.items;
    
    [self updateUserDefaults];
}

- (void)mergeSongsWithCollection:(MPMediaItemCollection*)collection
{
    NSMutableSet* mergedItems = [NSMutableSet setWithArray:collection.items];
    [mergedItems addObjectsFromArray:self.songs];
    
    self.songs = [mergedItems allObjects];

    [self updateUserDefaults];
}

- (void)updateUserDefaults
{
    NSMutableArray* identifiers = [NSMutableArray arrayWithCapacity:[self.songs count]];
    
    for (MPMediaItem* item in self.songs)
    {
        [identifiers addObject:[item valueForProperty:MPMediaItemPropertyPersistentID]];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:identifiers
                                              forKey:kSongIdentifiersKey];
}

- (void)removeSongAtIndex:(NSUInteger)index
{
    NSMutableArray* mutableSongs = [self.songs mutableCopy];
    [mutableSongs removeObjectAtIndex:index];
    self.songs = [[mutableSongs copy] autorelease];
    [mutableSongs release];
    
    [self updateUserDefaults];
}

- (void)moveSongFromIndex:(NSUInteger)srcIndex toIndex:(NSUInteger)destIndex
{
    if (srcIndex != destIndex)
    {
        NSMutableArray* mutableSongs = [self.songs mutableCopy];
        
        id obj = [[mutableSongs objectAtIndex:srcIndex] retain];
        [mutableSongs removeObjectAtIndex:srcIndex];
        if (destIndex >= [mutableSongs count])
        {
            [mutableSongs addObject:obj];
        }
        else
        {
            [mutableSongs insertObject:obj atIndex:destIndex];
        }
        [obj release];
        
        self.songs = [[mutableSongs copy] autorelease];
        [mutableSongs release];

        [self updateUserDefaults];
    }
}

- (void)removeAllSongs
{
    self.songs = [NSArray array];
    [self updateUserDefaults];
}

- (NSInteger)songCount
{
    return [self.songs count];
}

#pragma mark Singleton

+ (ASMSongCollection*)sharedSongCollection
{
    if (nil == sSharedSongCollection)
    {
        sSharedSongCollection = [[super allocWithZone:NULL] init];
    }
    return sSharedSongCollection;
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [[self sharedSongCollection] retain];
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (id)retain
{
    return self;
}

- (NSUInteger)retainCount
{
    return NSUIntegerMax;  //denotes an object that cannot be released
}

- (oneway void)release
{
    //do nothing
}

- (id)autorelease
{
    return self;
}

@end
