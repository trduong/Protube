//
//  VideoThumbnail.h
//  ProTubeClone
//
//  Created by Hoang on 1/6/15.
//  Copyright (c) 2015 Future Work. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VideoThumbnail : NSObject

@property (assign, nonatomic) NSInteger height;
@property (strong, nonatomic) NSString  *urlThumbnail;
@property (assign, nonatomic) NSInteger width;

@end
