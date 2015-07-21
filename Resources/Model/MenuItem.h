//
//  MenuItem.h
//  ProTubeClone
//
//  Created by Hoang on 2/9/15.
//  Copyright (c) 2015 Future Work. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MenuItem : NSObject

@property (strong, nonatomic) NSString * titleMenu;
@property (strong, nonatomic) NSString * imageName;
@property (strong, nonatomic) NSString * menuId;
@property (strong, nonatomic) NSString * subsciptionId;

@property (assign, nonatomic) BOOL  isKindChannel;
@property (assign, nonatomic) BOOL  isKindSubscription;
@property (assign, nonatomic) BOOL  isKindWatchToWatch;

@property (assign, nonatomic) int orderItem;

@end
