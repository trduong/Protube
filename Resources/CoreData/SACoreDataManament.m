//
//  SACoreDataManament.m
//  salesapp
//
//  Created by Branding Engineer inc. on 12/4/14.
//  Copyright (c) 2014 Branding Engineer inc. All rights reserved.
//
#import "NSManagedObjectContext+SRFetchAsync.h"
#import "SACoreDataManament.h"
#import "NSManagedObject+TBAdditions.h"
#import "MyList.h"
#import "History.h"

@implementation SACoreDataManament

@synthesize managedObjectContext = __managedObjectContext;
@synthesize managedObjectModel = __managedObjectModel;
@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;

+ (SACoreDataManament *)sharedCoreDataManament
{
    static SACoreDataManament *_sharedInstance = nil;
    
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[SACoreDataManament alloc] init];
    });
    
    return _sharedInstance;
}

#pragma mark Public methods
- (void)fetchAllMyListWithCompletion:(void (^)(NSArray *objects, NSError *error))completion
{
    NSManagedObjectContext *mainContext = [TBCoreDataStoreS1 mainQueueContext];
    [mainContext performBlock:^{
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"MyList"];
        
        NSError *error;
        NSArray *results = [mainContext executeFetchRequest:fetchRequest
                                                      error:&error];
        completion(results, error);
    }];
}
/*!
 * Save my list
 */
- (void)saveMyListWithName:(NSString*)nameMyList completion:(void (^)(NSArray *objects, NSError *error))completion
{
    NSManagedObjectContext *mainContext = [TBCoreDataStoreS1 mainQueueContext];
    [mainContext performBlock:^{
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"MyList"];
        NSPredicate *predicate = [NSPredicate
                                  predicateWithFormat:@"nameList = %@", nameMyList];
        [fetchRequest setPredicate:predicate];
        
        NSError *error;
        NSArray *results = [mainContext executeFetchRequest:fetchRequest
                                                        error:&error];
        
        if (results.count == 0) {
            NSManagedObjectContext *mainContext = [TBCoreDataStoreS1 mainQueueContext];
            [mainContext performBlock:^{
        
                // Save my list
                NSManagedObject *myList = [NSEntityDescription
                                           insertNewObjectForEntityForName:@"MyList"
                                           inManagedObjectContext:mainContext];
                
                [myList setValue:nameMyList forKey:@"nameList"];
                [self saveMainContext];
            }];
        }
        
        completion(results, error);
    }];
    
}

/*!
 * Delete my list
 */
- (void)deleteMyListWithName:(NSString*)nameMyList
                  completion:(void (^)(NSError *error))completion
{
    NSManagedObjectContext *mainContext = [TBCoreDataStoreS1 mainQueueContext];
    [mainContext performBlock:^{
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"MyList"];
        NSPredicate *predicate = [NSPredicate
                                  predicateWithFormat:@"nameList = %@", nameMyList];
        [fetchRequest setPredicate:predicate];
        
        NSError *error;
        NSArray *results = [mainContext executeFetchRequest:fetchRequest
                                                      error:&error];
        
        if (!error) {
            for (NSManagedObject * myList in results) {
                [mainContext deleteObject:myList];
                
                NSError *saveError = nil;
                [mainContext save:&saveError];
            }
            
            [self saveMainContext];
        }
        
        completion(error);
    }];
    
}

/*!
 * Add video to my list
 */
- (void)addVideoToMyList:(NSString*)nameList video:(CategoryVideo*)video
{
    NSManagedObjectContext *mainContext = [TBCoreDataStoreS1 mainQueueContext];
    [mainContext performBlock:^{
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"MyList"];
        NSPredicate *predicate = [NSPredicate
                                  predicateWithFormat:@"nameList = %@", nameList];
        [fetchRequest setPredicate:predicate];
        
        NSError *error;
        NSArray *results = [mainContext executeFetchRequest:fetchRequest
                                                      error:&error];
        
        if (!error) {
            MyList * myList = [results objectAtIndex:0];
            
            // Create video
            NSEntityDescription *entityVideo = [NSEntityDescription entityForName:@"Videos" inManagedObjectContext:mainContext];
            NSManagedObject *newVideo = [[NSManagedObject alloc] initWithEntity:entityVideo insertIntoManagedObjectContext:mainContext];
            
            Snippet *snippet = video.snippet;
            Statistics *statistics = video.statistics;
            ContentDetails *contentDetails = video.contentDetails;
            VideoThumbnail *highThumbnail = snippet.highThumbnail;
            
            // set properties
            [newVideo setValue:snippet.channelId forKey:@"channelId"];
            [newVideo setValue:snippet.channelTitle forKey:@"channelTitle"];
            [newVideo setValue:@"" forKey:@"chThumbnails"];
            [newVideo setValue:[NSString stringWithFormat:@"%ld",(long)statistics.commentCount] forKey:@"commentCount"];
            //[newVideo setValue:[NSDate date] forKey:@"date"];
            [newVideo setValue:snippet.descriptionSnippet forKey:@"des"];
            [newVideo setValue:[NSString stringWithFormat:@"%ld",(long)statistics.dislikeCount] forKey:@"dislikeCount"];
            [newVideo setValue:contentDetails.duration forKey:@"duration"];
            [newVideo setValue:[NSString stringWithFormat:@"%ld",(long)statistics.favoriteCount] forKey:@"favoriteCount"];
            [newVideo setValue:[NSString stringWithFormat:@"%ld",(long)statistics.likeCount] forKey:@"likeCount"];
            [newVideo setValue:contentDetails.publishAt forKey:@"publishedAt"];
            [newVideo setValue:highThumbnail.urlThumbnail forKey:@"thumbnails"];
            [newVideo setValue:snippet.titleSnippet forKey:@"title"];
            [newVideo setValue:@"" forKey:@"type"];
            [newVideo setValue:video.videoId forKey:@"videoId"];
            [newVideo setValue:[NSString stringWithFormat:@"%ld",(long)statistics.viewCount] forKey:@"viewCount"];
            
            
            // Add video to list
            [myList addVideo:[NSSet setWithObject:newVideo]];
            
            // Save Managed Object Context
            NSError *error = nil;
            [mainContext save:&error];
            
            [self saveMainContext];
        }
    }];
}

/*!
 * Delete video in my list
 */
- (void)deleteVideoInMyList:(NSString*)nameList videoId:(NSString*)videoId completion:(void (^)(BOOL success, NSError *error))completion
{
    NSManagedObjectContext *mainContext = [TBCoreDataStoreS1 mainQueueContext];
    [mainContext performBlock:^{
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"MyList"];
        NSPredicate *predicate = [NSPredicate
                                  predicateWithFormat:@"nameList = %@", nameList];
        [fetchRequest setPredicate:predicate];
        
        NSError *error;
        NSArray *results = [mainContext executeFetchRequest:fetchRequest
                                                      error:&error];
        
        if (!error) {
            MyList * myList = [results objectAtIndex:0];
            
            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
            
            NSEntityDescription *entity = [NSEntityDescription entityForName:@"Videos"
                                                      inManagedObjectContext:mainContext];
            NSPredicate * predicate =[NSPredicate predicateWithFormat:@"mylist == %@",myList];
            
            [fetchRequest setEntity:entity];
            [fetchRequest setPredicate:predicate];
            
            NSError *error;
            NSArray *results = [mainContext executeFetchRequest:fetchRequest
                                                          error:&error];
            
            if (!error) {
                for (NSManagedObject *item in results) {
                    NSString *value = [item valueForKey:@"videoId"];
                    if ([value isEqualToString:videoId]) {
                        [mainContext deleteObject:item];
                        
                        NSError *saveError = nil;
                        [mainContext save:&saveError];
                        
                        [self saveMainContext];
                        
                        if (!error) {
                            completion(YES, nil);
                        } else {
                            completion(NO, error);
                        }
                        
                        break;
                    }
                }
            }
        }
    }];
}

/*!
 * Get all videos in list name
 */
- (void)getAllVideosInListName:(NSString*)listName  completion:(void (^)(NSArray *objects, NSError *error))completion
{
    NSManagedObjectContext *mainContext = [TBCoreDataStoreS1 mainQueueContext];
    [mainContext performBlock:^{
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"MyList"];
        NSPredicate *predicate = [NSPredicate
                                  predicateWithFormat:@"nameList = %@", listName];
        [fetchRequest setPredicate:predicate];
        
        NSError *error;
        NSArray *results = [mainContext executeFetchRequest:fetchRequest
                                                      error:&error];
        
        if (!error) {
            MyList * myList = [results objectAtIndex:0];
            
            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
            
            NSEntityDescription *entity = [NSEntityDescription entityForName:@"Videos"
                                                      inManagedObjectContext:mainContext];
            NSPredicate * predicate =[NSPredicate predicateWithFormat:@"mylist == %@",myList];

            [fetchRequest setEntity:entity];
            [fetchRequest setPredicate:predicate];
            
            NSError *error;
            NSArray *results = [mainContext executeFetchRequest:fetchRequest
                                                          error:&error];
            if (!error) {
                completion(results, error);
            }
        }
    }];
}

/*!
 * Rename my list
 */
- (void)renameMyListWithNewName:(NSString*)newName oldName:(NSString*)oldName completion:(void (^)(BOOL success, NSError *error))completion
{
    NSManagedObjectContext *mainContext = [TBCoreDataStoreS1 mainQueueContext];
    [mainContext performBlock:^{
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"MyList"];
        NSPredicate *predicate = [NSPredicate
                                  predicateWithFormat:@"nameList = %@", oldName];
        [fetchRequest setPredicate:predicate];
        
        NSError *error;
        NSArray *results = [mainContext executeFetchRequest:fetchRequest
                                                      error:&error];
        if (!error) {
            MyList * myList = results[0];
            [myList setValue:newName forKey:@"nameList"];
    
            // Save Managed Object Context
            NSError *error = nil;
            [mainContext save:&error];
            
            [self saveMainContext];
            
            completion(YES, nil);
            
        } else {
            completion(NO, error);
        }
    }];
}

/*!
 * Add video to history
 */
- (void)addVideoToHistory:(id)object
{
    CategoryVideo *video = (CategoryVideo*)object;
    
    NSManagedObjectContext *mainContext = [TBCoreDataStoreS1 mainQueueContext];
    [mainContext performBlock:^{
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"History"];
        NSPredicate *predicate = [NSPredicate
                                  predicateWithFormat:@"videoId = %@", video.videoId];
        [fetchRequest setPredicate:predicate];
        
        NSError *error;
        NSArray *results = [mainContext executeFetchRequest:fetchRequest
                                                      error:&error];
        if (!error) {
            if (results.count > 0) {
                // Update video
                
            } else {
                // Add new video
                NSEntityDescription *entityVideo = [NSEntityDescription entityForName:@"History" inManagedObjectContext:mainContext];
                NSManagedObject *newVideo = [[NSManagedObject alloc] initWithEntity:entityVideo insertIntoManagedObjectContext:mainContext];
                
                [newVideo setValue:video.videoId forKey:@"videoId"];
                [newVideo setValue:[NSDate date] forKey:@"created"];
                [newVideo setValue:video.contentDetails.duration forKey:@"duration"];
                [newVideo setValue:video.snippet.titleSnippet forKey:@"title"];
                [newVideo setValue:video.snippet.descriptionSnippet forKey:@"subTitle"];
                [newVideo setValue:video.snippet.highThumbnail.urlThumbnail forKey:@"urlThumbnail"];
                [newVideo setValue:[NSNumber numberWithInteger:video.statistics.likeCount] forKey:@"likeCount"];
                [newVideo setValue:[NSNumber numberWithInteger:video.statistics.dislikeCount] forKey:@"dislikeCount"];
                [newVideo setValue:video.snippet.channelTitle forKey:@"channelTitle"];
                [newVideo setValue:video.contentDetails.publishAt forKey:@"publicAt"];
                
                // Save Managed Object Context
                NSError *error = nil;
                [mainContext save:&error];
                
                [self saveMainContext];
                
            }
        }
    }];
}

/*!
 * Get all videos in history
 */
- (void)getAllVideoInHistoryWithCompletion:(void (^)(NSArray *objects, NSError *error))completion
{
    NSManagedObjectContext *mainContext = [TBCoreDataStoreS1 mainQueueContext];
    [mainContext performBlock:^{
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"History"];
        NSSortDescriptor *sdSortDate = [NSSortDescriptor sortDescriptorWithKey:@"created" ascending:NO];
        fetchRequest.sortDescriptors = @[sdSortDate];

        NSError *error;
        NSArray *results = [mainContext executeFetchRequest:fetchRequest
                                                      error:&error];
        if (!error) {
            completion(results, nil);
        }
    }];
}

/*!
 * Delete video in history
 */
- (void)deleteVideoInHistoryWithId:(NSString*)videoId completion:(void (^)(BOOL success, NSError *error))completion
{
    NSManagedObjectContext *mainContext = [TBCoreDataStoreS1 mainQueueContext];
    [mainContext performBlock:^{
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"History"];
        NSPredicate *predicate = [NSPredicate
                                  predicateWithFormat:@"videoId = %@", videoId];
        [fetchRequest setPredicate:predicate];
        
        NSError *error;
        NSArray *results = [mainContext executeFetchRequest:fetchRequest
                                                      error:&error];
        
        if (!error) {
            for (NSManagedObject * history in results) {
                [mainContext deleteObject:history];
                
                NSError *saveError = nil;
                [mainContext save:&saveError];
            }
            
            [self saveMainContext];
            
            if (!error) {
                completion(YES, nil);
            }
        } else {
            completion(NO, error);
        }
    }];
}

/*!
 * Delete all history
 */
- (void)deleteAllVideoWithCompletion:(void (^)(BOOL success, NSError *error))completion
{
    NSManagedObjectContext *mainContext = [TBCoreDataStoreS1 mainQueueContext];
    [mainContext performBlock:^{
        NSFetchRequest * allHistories = [[NSFetchRequest alloc] init];
        [allHistories setEntity:[NSEntityDescription entityForName:@"History" inManagedObjectContext:mainContext]];
        [allHistories setIncludesPropertyValues:NO]; //only fetch the managedObjectID
        
        NSError * error = nil;
        NSArray * histories = [mainContext executeFetchRequest:allHistories error:&error];
        //error handling goes here
        for (NSManagedObject * history in histories) {
            [mainContext deleteObject:history];
        }
        //NSError *saveError = nil;
        [self saveMainContext];
        
        completion(YES, nil);
        
    }];
}

#pragma mark Save contexts
- (void)saveMainContext
{
    NSError *error = nil;
    NSManagedObjectContext *workerContext = [TBCoreDataStoreS1 mainQueueContext];
    if (workerContext != nil) {
        if ([workerContext hasChanges] && ![workerContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

- (void)savePrivateContext
{
    NSError *error = nil;
    NSManagedObjectContext *workerContext = [TBCoreDataStoreS1 privateQueueContext];
    [workerContext save:&error];
}

@end
