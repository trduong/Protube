//
//  SACoreDataManament.h
//  salesapp
//
//  Created by Branding Engineer inc. on 12/4/14.
//  Copyright (c) 2014 Branding Engineer inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TBCoreDataStoreS2.h"
#import "TBCoreDataStoreS1.h"
#import "CategoryVideo.h"

@interface SACoreDataManament : NSObject

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

+ (SACoreDataManament *)sharedCoreDataManament;
/*!
 * Save core data in main context
 */
- (void)saveMainContext;

/*!
 * Save core data in private context, only notification to merge data
 */
- (void)savePrivateContext;

/*!
 * Get all list name
 */
- (void)fetchAllMyListWithCompletion:(void (^)(NSArray *objects, NSError *error))completion;

/*!
 * Save my list 
 */
- (void)saveMyListWithName:(NSString*)nameMyList
                completion:(void (^)(NSArray *objects, NSError *error))completion;

/*!
 * Delete my list
 */
- (void)deleteMyListWithName:(NSString*)nameMyList
                  completion:(void (^)(NSError *error))completion;

/*!
 * Add video to my list
 */
- (void)addVideoToMyList:(NSString*)nameList video:(CategoryVideo*)video;

/*!
 * Delete video in my list 
 */
- (void)deleteVideoInMyList:(NSString*)nameList videoId:(NSString*)videoId completion:(void (^)(BOOL success, NSError *error))completion;

/*!
 * Get all videos in list name
 */
- (void)getAllVideosInListName:(NSString*)listName  completion:(void (^)(NSArray *objects, NSError *error))completion;

/*!
 * Rename my list 
 */
- (void)renameMyListWithNewName:(NSString*)newName oldName:(NSString*)oldName completion:(void (^)(BOOL success, NSError *error))completion;

/*!
 * Add video to history
 */
- (void)addVideoToHistory:(id)video;

/*!
 * Get all videos in history
 */
- (void)getAllVideoInHistoryWithCompletion:(void (^)(NSArray *objects, NSError *error))completion;

/*!
 * Delete video in history
 */
- (void)deleteVideoInHistoryWithId:(NSString*)videoId completion:(void (^)(BOOL success, NSError *error))completion;

/*!
 * Delete all history
 */
- (void)deleteAllVideoWithCompletion:(void (^)(BOOL success, NSError *error))completion;
@end
