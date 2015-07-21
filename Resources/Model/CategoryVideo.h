//
//  CategoryVideo.h
//  ProTubeClone
//
//  Created by Hoang on 1/6/15.
//  Copyright (c) 2015 Future Work. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YoutubeObject.h"

@interface CategoryVideo : YoutubeObject

@property (strong, nonatomic) NSString *videoId;
@property (nonatomic, assign) BOOL isLoadedVideo;

@property (assign, nonatomic) BOOL isHomeVideo;
@property (assign, nonatomic) BOOL isChannelVideo;

@property (nonatomic, strong) NSDate *date;

@end
