//
//  ASMSongCollection.h
//  LilJukeBox
//
//  Created by Andrew Molloy on 5/31/12.
//  Copyright (c) 2012 Andy Molloy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

@interface ASMSongCollection : NSObject {
    NSArray* mSongs;
}

+ (ASMSongCollection*)sharedSongCollection;

- (void)setSongsWithCollection:(MPMediaItemCollection*)collection;
- (void)mergeSongsWithCollection:(MPMediaItemCollection*)collection;
- (void)removeSongAtIndex:(NSUInteger)index;
- (void)moveSongFromIndex:(NSUInteger)srcIndex toIndex:(NSUInteger)destIndex;

@property (retain, readonly, nonatomic) NSArray* songs;

@end
