//
//  MSPodcastCell.h
//  Modern Sabahlar
//
//  Created by Onur Baykal on 08.12.2012.
//  Copyright (c) 2012 Onur Baykal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MSUnplayedSwitch.h"

@interface MSPodcastCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *podcastLabel;
- (IBAction)downloadButtonTouched:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet MSUnplayedSwitch *playedSwitch;

@end
