//
//  MSAudioViewController.h
//  Modern Sabahlar
//
//  Created by Onur Baykal on 11.12.2012.
//  Copyright (c) 2012 Onur Baykal. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Podcast;

@interface MSAudioViewController : UIViewController

@property (nonatomic, weak) Podcast * playingPodcast;

@end
