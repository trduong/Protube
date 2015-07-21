//
//  ContentDetails.h
//  ProTubeClone
//
//  Created by Hoang on 1/19/15.
//  Copyright (c) 2015 Future Work. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ContentDetails : NSObject

@property (strong, nonatomic) NSString  *caption;
@property (strong, nonatomic) NSString  *definition;
@property (strong, nonatomic) NSString  *dimension;
@property (strong, nonatomic) NSString  *duration;
@property (strong, nonatomic) NSString  *licensedContent;
@property (strong, nonatomic) NSString  *publishAt;

@property (assign, nonatomic) NSInteger itemCount;

// Activity content detail
@property (strong, nonatomic) NSString * videoUploadId;

@end
