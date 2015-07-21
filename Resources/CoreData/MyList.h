//
//  MyList.h
//  ProTubeClone
//
//  Created by admin on 2/8/15.
//  Copyright (c) 2015 Future Work. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Videos;

@interface MyList : NSManagedObject

@property (nonatomic, retain) NSString * nameList;
@property (nonatomic, retain) NSSet *video;
@end

@interface MyList (CoreDataGeneratedAccessors)

- (void)addVideoObject:(Videos *)value;
- (void)removeVideoObject:(Videos *)value;
- (void)addVideo:(NSSet *)values;
- (void)removeVideo:(NSSet *)values;

@end
