//
//  APIYoutubeManagement.h
//  ProTubeClone
//
//  Created by Hoang on 1/6/15.
//  Copyright (c) 2015 Future Work. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AFHTTPRequestOperationManager;

typedef void (^APIManagerHandler)(id result, NSError *error);

@interface APIYoutubeManagement : NSObject

@property (nonatomic, strong) AFHTTPRequestOperationManager *manager;

+ (APIYoutubeManagement *)sharedAPIYoutubeManagement;

// Get list video in category
- (void)getListVideoCategoryWithPart:(NSString*)part
                     videoCategoryId:(NSInteger)videoCategoryId
                          regionCode:(NSString*)regionCode
                           maxResult:(NSInteger)maxResult
                               chart:(NSString*)chart
                                 key:(NSString*)key
                           pageToken:(NSString*)pageToken
                          completion:(APIManagerHandler)completion;

// Search video
- (void)searchVideoWithString:(NSString*)searchString
                    pageToken:(NSString*)pageToken
                    maxResult:(NSInteger)maxResult
                        order:(NSString*)order
                videoDuration:(NSString*)videoDuration
               publishedAfter:(NSString*)publishedAfter
              publishedBefore:(NSString*)publishedBefore
                   completion:(APIManagerHandler)completion;

// Search chanel
- (void)searchChannelWithString:(NSString*)searchString
                      maxResult:(NSInteger)maxResult
                      pageToken:(NSString*)pageToken
                     completion:(APIManagerHandler)completion;

//Watch To Watch
- (void)getWatchToWatchWithToken:(NSString*)accessToken pageToken:(NSString*)pageToken completion:(APIManagerHandler)completion;

//Get Playlist
- (void)getPlaylistWithToken:(NSString*)accessToken pageToken:(NSString*)pageToken completion:(APIManagerHandler)completion;

// Search playlists
- (void)searchPlaylistsWithString:(NSString*)searchString
                        maxResult:(NSInteger)maxResult
                        pageToken:(NSString*)pageToken
                       completion:(APIManagerHandler)completion;

// Request a specifity video
- (void)requestVideoWithId:(NSString*)videoId completion:(APIManagerHandler)completion;


// Suggest name
- (void)suggestNameWithText:(NSString*)text completion:(APIManagerHandler)completion;

// Get activities
- (void)getListActivitiesWithPart:(NSString*)part chanelId:(NSString*)chanelId pageToken:(NSString*)pageToken maxResult:(NSInteger)maxResult completion:(APIManagerHandler)completion;

// Get playlist of matching with channel
- (void)getPlaylistWithChannelId:(NSString*)channelId pageToken:(NSString*)pageToken maxResult:(NSInteger)maxResult completion:(APIManagerHandler)completion;

// Get channel's info
- (void)getChannelInfoWithId:(NSString*)channelId Completion:(APIManagerHandler)completion;

// Get videos in subscription mathching with channel
- (void)getVideosWithChannel:(NSString*)channelId pageToken:(NSString*)pageToken maxResult:(NSInteger)maxResult Completion:(APIManagerHandler)completion;

// Get playlist items
- (void)getPlaylistItemWithId:(NSString*)playlistId accessToken:(NSString*)accessToken pageToken:(NSString*)pageToken completion:(APIManagerHandler)completion;

// Get subcriptions
- (void)getSubciptionWithAccessToken:(NSString*)accessToken pageToken:(NSString*)pageToken completion:(APIManagerHandler)completion;

// POST: Add playlist
- (void)addPlaylistWithTitle:(NSString*)title accessToken:(NSString*)accessToken completion:(APIManagerHandler)completion;

// DELETE: delete playlist
- (void)deletePlaylistWithId:(NSString*)playlistId accessToken:(NSString*)accessToken completion:(APIManagerHandler)completion;
@end
