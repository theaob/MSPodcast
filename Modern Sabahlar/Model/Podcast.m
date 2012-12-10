//
//  Podcast.m
//  Modern Sabahlar
//
//  Created by Onur Baykal on 04.12.2012.
//  Copyright (c) 2012 Onur Baykal. All rights reserved.
//

#import "Podcast.h"


@implementation Podcast

@dynamic title;
@dynamic isPlayed;
@dynamic audioPath;
@dynamic duration;
@dynamic finished;

- (NSString *) description
{    
    return [NSString stringWithFormat:@"Title: %@ isPlayed: %@  path: %@ duration: %@ finished: %@", self.title, self.isPlayed, self.audioPath, self.duration, self.finished, nil];
}

@end
