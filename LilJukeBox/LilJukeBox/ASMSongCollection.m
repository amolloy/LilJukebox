//
//  ASMSongCollection.m
//  LilJukeBox
//
//  Created by Andrew Molloy on 5/31/12.
//  Copyright (c) 2012 Andy Molloy. All rights reserved.
//

#import "ASMSongCollection.h"

static NSString* kSongIdentifiersKey = @"kSongIdentifiersKey";
static ASMSongCollection *sSharedSongCollection = nil;

@interface ASMSongCollection ()
@property (retain, nonatomic) NSArray* songs;
@end

@implementation ASMSongCollection

@synthesize songs = mSongs;

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

- (void)setSongsWithCollection:(MPMediaItemCollection*)collection
{
    self.songs = collection.items;
    
    NSMutableArray* identifiers = [NSMutableArray arrayWithCapacity:[self.songs count]];
    
    for (MPMediaItem* item in self.songs)
    {
        [identifiers addObject:[item valueForProperty:MPMediaItemPropertyPersistentID]];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:identifiers
                                              forKey:kSongIdentifiersKey];
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
