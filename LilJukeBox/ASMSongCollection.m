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

@interface UIColor (Crayons)
+(id)crayonColorWithRedGreenBlue:(NSInteger)c;
@end

@implementation UIColor (Crayons)
+(id)crayonColorWithRedGreenBlue:(NSInteger)c
{
	unsigned char rgb[3];
	for(NSInteger i = 0; i < 3; ++i)
	{
		rgb[2-i] = c & 0xFF;
		c >>= 8;
	}
	
	return [UIColor colorWithRed:rgb[0] / (float)0xFF
						   green:rgb[1] / (float)0xFF
							blue:rgb[2] / (float)0xFF
						   alpha:1];
}
@end


@interface ASMSongCollection ()
@property (strong, nonatomic) NSArray* songs;

- (void)updateUserDefaults;
@end

@implementation ASMSongCollection

@synthesize songs = _songs;
@synthesize playableSongCount = _playableSongCount;

+ (UIColor*)colorForSongIndex:(NSUInteger)i
{
	static NSArray* sSongColors = nil;
	if (nil == sSongColors)
	{
		sSongColors = [NSArray arrayWithObjects:
						[UIColor crayonColorWithRedGreenBlue:0xECEABE],
						[UIColor crayonColorWithRedGreenBlue:0xCDC5C2],
						[UIColor crayonColorWithRedGreenBlue:0xB0B7C6],
						[UIColor crayonColorWithRedGreenBlue:0xFF9BAA],
						[UIColor crayonColorWithRedGreenBlue:0xC5E384],
						[UIColor crayonColorWithRedGreenBlue:0x77DDE7],
						[UIColor crayonColorWithRedGreenBlue:0x1CAC78],
						[UIColor crayonColorWithRedGreenBlue:0xFF43A4],
						[UIColor crayonColorWithRedGreenBlue:0x80DAEB],
						[UIColor crayonColorWithRedGreenBlue:0xFFB653],
						[UIColor crayonColorWithRedGreenBlue:0x9D81BA],
						[UIColor crayonColorWithRedGreenBlue:0xE7C697],
						nil];
	}
	
	return [sSongColors objectAtIndex:i];
}

+ (UIColor*)hightlightColorForSongIndex:(NSUInteger)i
{
	UIColor* baseColor = [self colorForSongIndex:i];
	const CGFloat* components = CGColorGetComponents(baseColor.CGColor);
	return [UIColor colorWithRed:components[0] * 0.90f
						   green:components[1] * 0.90f
							blue:components[2] * 0.90f
						   alpha:components[3] * 0.90f];
}

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

- (void)removeSongAtIndex:(NSUInteger)idx
{
    NSMutableArray* mutableSongs = [self.songs mutableCopy];
    [mutableSongs removeObjectAtIndex:idx];
    self.songs = [mutableSongs copy];
    
    [self updateUserDefaults];
}

- (void)moveSongFromIndex:(NSUInteger)srcIndex toIndex:(NSUInteger)destIndex
{
    if (srcIndex != destIndex)
    {
        NSMutableArray* mutableSongs = [self.songs mutableCopy];
        
        id obj = [mutableSongs objectAtIndex:srcIndex];
        [mutableSongs removeObjectAtIndex:srcIndex];
        if (destIndex >= [mutableSongs count])
        {
            [mutableSongs addObject:obj];
        }
        else
        {
            [mutableSongs insertObject:obj atIndex:destIndex];
        }
        
        self.songs = [mutableSongs copy];

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
    return [self sharedSongCollection];
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

@end
