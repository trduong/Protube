//
//  YoutubeObject.h
//  ProTubeClone
//
//  Created by Hoang on 2/8/15.
//  Copyright (c) 2015 Future Work. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Snippet.h"
#import "Statistics.h"
#import "ContentDetails.h"

@interface YoutubeObject : NSObject

@property (strong, nonatomic) NSString *objectId;
@property (strong, nonatomic) Snippet   *snippet;
@property (strong, nonatomic) Statistics    *statistics;
@property (strong, nonatomic) ContentDetails    *contentDetails;

@end
