//
//  ConstantValues.h
//  ProTubeClone
//
//  Created by Hoang on 12/31/14.
//  Copyright (c) 2014 Future Work. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ConstantValues : NSObject

extern int  gIndexTabbarItem;
extern int  gIndexTabSearch;
extern int  gIndexOfTabHome;
extern int  numberOfPlaylistItem;

extern BOOL isChannelView;
extern BOOL isSearching;
extern BOOL isSearchPlayList ;
extern BOOL isMoveToPlayVideoFromHome;
extern BOOL isPlayingVideo;
extern BOOL isActivityPage;
extern BOOL isLogged;
extern BOOL isSelectedFromMenu;
extern BOOL isSubscription;
extern BOOL isPlaylistItem;


#pragma mark Device

#define IDIOM    UI_USER_INTERFACE_IDIOM()
#define IPAD     UIUserInterfaceIdiomPad
#define IS_IPAD  (IDIOM == UIUserInterfaceIdiomPad)

/*
 *  System Versioning Preprocessor Macros
 */

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

/* Color */
#define gColorNavigation    [UIColor colorWithRed:245/255.0f green:245/255.0f blue:245/255.0f alpha:1.0f]

#pragma mark API KEY
#define API_URL @"https://www.googleapis.com"

// Google
#define GOOGLE_KEY  @"AIzaSyADMJu_68msQpWhuHv3b3xeodcOpYZCRyI"

// Notification
#define gNotificationVideoSelected      @"NotificationVideoSelected"
#define NOTIFICATION_UPDATE_MY_LIST     @"NOTIFICATION_UPDATE_MY_LIST"
#define NOTIFICATION_UPDATE_MY_LIST_2   @"NOTIFICATION_UPDATE_MY_LIST_2"

// Image
#define IMAGE_BACK          [UIImage imageNamed:@"back"]
@end
