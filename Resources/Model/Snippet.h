//
//  Snippet.h
//  ProTubeClone
//
//  Created by Hoang on 1/6/15.
//  Copyright (c) 2015 Future Work. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VideoThumbnail.h"

@interface Snippet : NSObject

@property (strong, nonatomic) NSString *categoryId;
@property (strong, nonatomic) NSString  *channelId;
@property (strong, nonatomic) NSString  *channelTitle;
@property (strong, nonatomic) NSString  *descriptionSnippet;
@property (strong, nonatomic) NSString  *titleSnippet;

@property (strong, nonatomic) VideoThumbnail    *defaultThumbnail;
@property (strong, nonatomic) VideoThumbnail    *highThumbnail;
@property (strong, nonatomic) VideoThumbnail    *mediumThumbnail;
@property (strong, nonatomic) VideoThumbnail    *standardhumbnail;

// Snippet activity
@property (strong, nonatomic) NSString  * type;
@end
