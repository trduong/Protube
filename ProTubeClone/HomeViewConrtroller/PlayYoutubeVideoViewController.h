//
//  PlayVideoViewController.h
//  ProTubeClone
//
//  Created by KODY on 1/24/15.
//  Copyright (c) 2015 Future Work. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CategoryVideo.h"
#import "LBYouTube.h"
@interface PlayYoutubeVideoViewController : UIViewController<LBYouTubePlayerControllerDelegate>
- (instancetype)initWithVideo:(CategoryVideo *)video;
@end
