//
//  History.h
//  ProTubeClone
//
//  Created by Hoang on 3/15/15.
//  Copyright (c) 2015 Future Work. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface History : NSManagedObject

@property (nonatomic, retain) NSDate * created;
@property (nonatomic, retain) NSString * duration;
@property (nonatomic, retain) NSString * subTitle;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * urlThumbnail;
@property (nonatomic, retain) NSString * videoId;
@property (nonatomic, retain) NSNumber * likeCount;
@property (nonatomic, retain) NSNumber * dislikeCount;
@property (nonatomic, retain) NSString * publicAt;
@property (nonatomic, retain) NSString * channelTitle;

@end
