//
//  ActivityObject.h
//  ProTubeClone
//
//  Created by Hoang on 2/8/15.
//  Copyright (c) 2015 Future Work. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CategoryVideo.h"

@interface ActivityObject : CategoryVideo

@property (nonatomic, strong) NSString  * activityId;
@property (nonatomic, strong) NSString  * type;

@property (nonatomic, assign) BOOL isLoadedVideo;

@end
