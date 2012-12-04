//
//  Podcast.h
//  Modern Sabahlar
//
//  Created by Onur Baykal on 04.12.2012.
//  Copyright (c) 2012 Onur Baykal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Podcast : NSManagedObject

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSNumber * isPlayed;
@property (nonatomic, retain) NSString * audioPath;
@property (nonatomic, retain) NSString * duration;

@end
