//
//  APIYoutubeManagement.m
//  ProTubeClone
//
//  Created by Hoang on 1/6/15.
//  Copyright (c) 2015 Future Work. All rights reserved.
//

#import "APIYoutubeManagement.h"
#import <AFHTTPRequestOperationManager.h>

@implementation APIYoutubeManagement

+ (APIYoutubeManagement *)sharedAPIYoutubeManagement
{
    static APIYoutubeManagement *_sharedInstance = nil;

    static dispatch_once_t oncePredicate;

    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[APIYoutubeManagement alloc] init];
    });
    
    return _sharedInstance;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:API_URL]];
        [self.manager.requestSerializer setTimeoutInterval:10.0f];
    }
    return self;
}

// Get list video in category
- (void)getListVideoCategoryWithPart:(NSString*)part
                     videoCategoryId:(NSInteger)videoCategoryId
                          regionCode:(NSString*)regionCode
                           maxResult:(NSInteger)maxResult
                               chart:(NSString*)chart
                                 key:(NSString*)key
                           pageToken:(NSString*)pageToken
                          completion:(APIManagerHandler)completion;
{
    NSDictionary *params =
    @{
      @"part": part, // snippet,statistics,contentDetails
      @"videoCategoryId": [NSString stringWithFormat:@"%ld", (long)videoCategoryId],
      @"regionCode": regionCode,
      @"maxResults": [NSString stringWithFormat:@"%ld", (long)maxResult],
      @"chart": chart, // mostPopular
      @"key": key,
      @"pageToken": pageToken,
      };
    
    NSString *url = @"/youtube/v3/videos";
    [self.manager GET:url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        completion(responseObject, nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completion(operation.response, error);
    }];
}

// Search video
- (void)searchVideoWithString:(NSString*)searchString
                  pageToken:(NSString*)pageToken
                  maxResult:(NSInteger)maxResult
                      order:(NSString*)order
              videoDuration:(NSString*)videoDuration
             publishedAfter:(NSString*)publishedAfter
            publishedBefore:(NSString*)publishedBefore
                 completion:(APIManagerHandler)completion
{
    NSDictionary *params =
    @{
      @"part": @"snippet", // snippet,statistics,contentDetails
      @"maxResults": [NSString stringWithFormat:@"%ld", (long)maxResult],
      @"pageToken": pageToken,
      @"q": searchString,
      @"type": @"video", // channel, playlist, video
      @"key": GOOGLE_KEY,
      @"order": order,
      @"videoDuration": videoDuration,
      @"videoType" : @"any",
//      @"publishedAfter": publishedAfter,
//      @"publishedBefore" : publishedBefore,
    };
    
    NSString *url = @"/youtube/v3/search";
    [self.manager GET:url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        completion(responseObject, nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completion(operation.response, error);
    }];
}

// Search chanel
- (void)searchChannelWithString:(NSString*)searchString
                      maxResult:(NSInteger)maxResult
                      pageToken:(NSString*)pageToken
                     completion:(APIManagerHandler)completion;
{
    NSDictionary *params =
    @{
      @"part": @"snippet", // snippet,statistics,contentDetails
      @"maxResults": [NSString stringWithFormat:@"%ld", (long)maxResult],
      @"pageToken": pageToken,
      @"q": searchString,
      @"type": @"channel", // channel, playlist, video
      @"key": GOOGLE_KEY,
      };
    
    NSString *url = @"/youtube/v3/search";
    [self.manager GET:url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        completion(responseObject, nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completion(operation.response, error);
    }];
}

// Search playlists
- (void)searchPlaylistsWithString:(NSString*)searchString
                        maxResult:(NSInteger)maxResult
                        pageToken:(NSString*)pageToken
                       completion:(APIManagerHandler)completion
{
    NSDictionary *params =
    @{
      @"part": @"snippet", // snippet,statistics,contentDetails
      @"maxResults": [NSString stringWithFormat:@"%ld", (long)maxResult],
      @"pageToken": pageToken,
      @"q": searchString,
      @"type": @"playlist", // channel, playlist, video
      @"key": GOOGLE_KEY,
      };
    
    NSString *url = @"/youtube/v3/search";
    [self.manager GET:url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        completion(responseObject, nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completion(operation.response, error);
    }];
}

// Request a specifity video
- (void)requestVideoWithId:(NSString*)videoId completion:(APIManagerHandler)completion
{
    NSDictionary *params =
    @{
      @"part": @"snippet,statistics,contentDetails",
      @"id": videoId,
      @"key": GOOGLE_KEY,
      };
    
    NSString *url = @"/youtube/v3/videos";
    [self.manager GET:url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        completion(responseObject, nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completion(operation.response, error);
    }];
}

// Suggest name
- (void)suggestNameWithText:(NSString*)text completion:(APIManagerHandler)completion;
{

    text = [text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://suggestqueries.google.com/complete/search?client=youtube&ds=yt&alt=json&q=%@", text]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    
    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    op.responseSerializer = [AFHTTPResponseSerializer serializer];
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        completion(responseObject, nil);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completion(operation.response, error);
        
    }];
    [op start];
}

// Get activities
- (void)getListActivitiesWithPart:(NSString*)part chanelId:(NSString*)chanelId pageToken:(NSString*)pageToken maxResult:(NSInteger)maxResult completion:(APIManagerHandler)completion
{
    NSDictionary *params =
    @{
      @"part": @"snippet,contentDetails",
      @"channelId": chanelId,
      @"key": GOOGLE_KEY,
      @"maxResults": [NSString stringWithFormat:@"%ld", (long)maxResult],
      @"pageToken": pageToken,
      };
    
    NSString *url = @"/youtube/v3/activities";
    [self.manager GET:url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        completion(responseObject, nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completion(operation.response, error);
    }];
}




// Get playlist of matching with channel
- (void)getPlaylistWithChannelId:(NSString*)channelId pageToken:(NSString*)pageToken maxResult:(NSInteger)maxResult completion:(APIManagerHandler)completion
{
    NSDictionary *params =
    @{
      @"part": @"snippet,contentDetails",
      @"channelId": channelId,
      @"key": GOOGLE_KEY,
      @"maxResults": [NSString stringWithFormat:@"%ld", (long)maxResult],
      @"pageToken": pageToken,
      };
    
    NSString *url = @"/youtube/v3/playlists";
    [self.manager GET:url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        completion(responseObject, nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completion(operation.response, error);
    }];
}

// Get channel's info
- (void)getChannelInfoWithId:(NSString*)channelId Completion:(APIManagerHandler)completion
{
    NSDictionary *params =
    @{
      @"part": @"statistics,status,brandingSettings",
      @"id": channelId,
      @"key": GOOGLE_KEY,
      };
    
    NSString *url = @"/youtube/v3/channels";
    [self.manager GET:url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        completion(responseObject, nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completion(operation.response, error);
    }];
}

// Get videos in subscription mathching with channel
- (void)getVideosWithChannel:(NSString*)channelId pageToken:(NSString*)pageToken maxResult:(NSInteger)maxResult Completion:(APIManagerHandler)completion
{
    NSDictionary *params =
    @{
      @"part": @"contentDetails",
      @"maxResults": [NSString stringWithFormat:@"%ld", (long)maxResult],
      @"id": channelId,
      @"key": GOOGLE_KEY,
      @"pageToken": pageToken,
      };
    
    NSString *url = @"/youtube/v3/channels";
    [self.manager GET:url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        completion(responseObject, nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completion(operation.response, error);
    }];
}

// Get playlist items
- (void)getPlaylistItemWithId:(NSString*)playlistId accessToken:(NSString*)accessToken pageToken:(NSString*)pageToken completion:(APIManagerHandler)completion
{
    NSDictionary *params = nil;
    
    if (accessToken) {
        params = @{
          @"part": @"snippet,contentDetails",
          @"maxResults": @"50",
          @"playlistId": playlistId,
          @"pageToken": pageToken,
          @"access_token": accessToken,
          };
    } else {
        params = @{
          @"part": @"snippet,contentDetails",
          @"maxResults": @"50",
          @"playlistId": playlistId,
          @"pageToken": pageToken,
          };
    }
    
    NSString *url = @"/youtube/v3/playlistItems";
    [self.manager GET:url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        completion(responseObject, nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completion(operation.response, error);
    }];
}

// Get subcriptions
- (void)getSubciptionWithAccessToken:(NSString*)accessToken pageToken:(NSString*)pageToken completion:(APIManagerHandler)completion
{
    
    NSDictionary *params =
    @{
      @"part": @"snippet,contentDetails",
      @"maxResults": @"50",
      @"pageToken": pageToken,
      @"access_token": accessToken,
      @"home": @"true"
      };
    
    NSString *url = @"/youtube/v3/activities";
    [self.manager GET:url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        completion(responseObject, nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completion(operation.response, error);
    }];
}

// POST: Add playlist
- (void)addPlaylistWithTitle:(NSString*)title accessToken:(NSString*)accessToken completion:(APIManagerHandler)completion
{
    NSString *xmlString = @"<?xml version=\"1.0\" encoding=\"UTF-8\"?><entry xmlns=\"http://www.w3.org/2005/Atom\" xmlns:yt=\"http://gdata.youtube.com/schemas/2007\"><title type=\"text\">%@</title></entry>";
    NSString *xmlFormat = [NSString stringWithFormat:xmlString, title];
    
    NSString *urlStr= [NSString stringWithFormat:@"https://gdata.youtube.com/feeds/api/users/default/playlists"];
    NSURL *url = [NSURL URLWithString:urlStr];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    [request setHTTPMethod:@"POST"];
    
    [request setValue:@"application/atom+xml" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"key=%@",GOOGLE_KEY] forHTTPHeaderField:@"X-GData-Key"];
    [request setValue:[NSString stringWithFormat:@"Bearer %@",accessToken] forHTTPHeaderField:@"Authorization"];
    [request setValue:@"2" forHTTPHeaderField:@"GData-Version"];
    [request setValue:[NSString stringWithFormat:@"%d", [xmlFormat length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:[xmlFormat dataUsingEncoding:NSUTF8StringEncoding]];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
         completion(responseObject, nil);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        completion(operation.response, error);
        
    }];
    
    [operation start];
    
}

// DELETE: delete playlist
- (void)deletePlaylistWithId:(NSString*)playlistId accessToken:(NSString*)accessToken completion:(APIManagerHandler)completion
{
    NSString *urlStr= [NSString stringWithFormat:@"https://gdata.youtube.com/feeds/api/users/default/playlists/%@",playlistId];
    NSURL *url = [NSURL URLWithString:urlStr];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"DELETE"];
    [request setValue:@"application/atom+xml" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"key=%@",GOOGLE_KEY] forHTTPHeaderField:@"X-GData-Key"];
    [request setValue:[NSString stringWithFormat:@"Bearer %@",accessToken] forHTTPHeaderField:@"Authorization"];
    [request setValue:@"2" forHTTPHeaderField:@"GData-Version"];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        completion(responseObject, nil);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        completion(operation.response, error);
        
    }];
    
    [operation start];
    
}
// Get subcriptions
- (void)getWatchToWatchWithToken:(NSString*)accessToken pageToken:(NSString*)pageToken completion:(APIManagerHandler)completion
{
    
    NSDictionary *params =
    @{
      @"part": @"snippet,contentDetails",
      @"maxResults": @"50",
      @"pageToken": pageToken,
      @"access_token": accessToken,
      @"home": @"true"
      };
    
    NSString *url = @"/youtube/v3/activities";
    [self.manager GET:url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        completion(responseObject, nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completion(operation.response, error);
    }];
}


// Get subcriptions
- (void)getPlaylistWithToken:(NSString*)accessToken pageToken:(NSString*)pageToken completion:(APIManagerHandler)completion
{
    
    NSDictionary *params =
    @{
      @"part": @"snippet,contentDetails",
      @"maxResults": @"50",
      @"access_token": accessToken,
      @"mine": @"true"
      };
    
    NSString *url = @"/youtube/v3/playlists";
    [self.manager GET:url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        completion(responseObject, nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completion(operation.response, error);
    }];
}

@end
