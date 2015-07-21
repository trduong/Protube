//
//  Videos.h
//  ProTubeClone
//
//  Created by admin on 2/8/15.
//  Copyright (c) 2015 Future Work. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MyList;

@interface Videos : NSManagedObject

@property (nonatomic, retain) NSString * channelId;
@property (nonatomic, retain) NSString * channelTitle;
@property (nonatomic, retain) NSString * chThumbnails;
@property (nonatomic, retain) NSString * commentCount;
@property (nonatomic, retain) NSString * date;
@property (nonatomic, retain) NSString * des;
@property (nonatomic, retain) NSString * dislikeCount;
@property (nonatomic, retain) NSString * duration;
@property (nonatomic, retain) NSString * favoriteCount;
@property (nonatomic, retain) NSString * folder;
@property (nonatomic, retain) NSString * likeCount;
@property (nonatomic, retain) NSString * publishedAt;
@property (nonatomic, retain) NSString * thumbnails;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSString * videoId;
@property (nonatomic, retain) NSString * viewCount;
@property (nonatomic, retain) MyList *mylist;

@end
