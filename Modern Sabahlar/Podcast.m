//
//  Podcast.m
//  Modern Sabahlar
//
//  Created by Onur Baykal on 04.12.2012.
//  Copyright (c) 2012 Onur Baykal. All rights reserved.
//

#import "Podcast.h"


@implementation Podcast

@dynamic date;
@dynamic isPlayed;
@dynamic audioPath;
@dynamic duration;

- (NSString *) description
{    
    return [NSString stringWithFormat:@"Date: %@ isPlayed: %@  path: %@ duration: %@", self.date, self.isPlayed, self.audioPath, self.duration, nil];
}

@end
