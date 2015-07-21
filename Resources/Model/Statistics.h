//
//  Statistics.h
//  ProTubeClone
//
//  Created by Hoang on 1/6/15.
//  Copyright (c) 2015 Future Work. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Statistics : NSObject

@property (assign, nonatomic) NSInteger commentCount;
@property (assign, nonatomic) NSInteger dislikeCount;
@property (assign, nonatomic) NSInteger favoriteCount;
@property (assign, nonatomic) NSInteger likeCount;
@property (assign, nonatomic) NSInteger viewCount;

@property (assign, nonatomic) NSInteger subscriberCount;
@property (assign, nonatomic) NSInteger videoCount;
@property (assign, nonatomic) NSInteger hiddenSubscriberCount;

@end
