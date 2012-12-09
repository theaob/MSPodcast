//
//  MSPodcastCell.h
//  Modern Sabahlar
//
//  Created by Onur Baykal on 08.12.2012.
//  Copyright (c) 2012 Onur Baykal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MSUnplayedSwitch.h"
#import "GSProgressView.h"

@interface MSPodcastCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *podcastLabel;
@property (weak, nonatomic) IBOutlet UILabel *lengthLabel;
@property (weak, nonatomic) IBOutlet GSProgressView *progressView;

@end
