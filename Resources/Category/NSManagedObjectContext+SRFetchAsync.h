//
//  NSManagedObjectContext+SRFetchAsync.h
//  salesapp
//
//  Created by admin on 12/6/14.
//  Copyright (c) 2014 QuangHoang. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObjectContext (SRFetchAsync)

//- (void)sr_executeFetchRequest:(NSFetchRequest *)request completion:(void (^)(NSArray *objects, NSError *error))completion;

- (void)sr_executeFetchRequest:(NSFetchRequest *)request managedObjectContext:(NSManagedObjectContext*)managedObjectContext completion:(void (^)(NSArray *objects, NSError *error))completion;
@end
