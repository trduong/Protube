//
//  Copyright (c) 2013-2014 Cédric Luthi. All rights reserved.
//

#import "XCDYouTubeVideoPlayerViewController.h"

#import "XCDYouTubeClient.h"

#import <objc/runtime.h>

NSString *const XCDMoviePlayerPlaybackDidFinishErrorUserInfoKey = @"error"; // documented in -[MPMoviePlayerController initWithContentURL:]

NSString *const XCDYouTubeVideoPlayerViewControllerDidReceiveMetadataNotification = @"XCDYouTubeVideoPlayerViewControllerDidReceiveMetadataNotification";
NSString *const XCDMetadataKeyTitle = @"Title";
NSString *const XCDMetadataKeySmallThumbnailURL = @"SmallThumbnailURL";
NSString *const XCDMetadataKeyMediumThumbnailURL = @"MediumThumbnailURL";
NSString *const XCDMetadataKeyLargeThumbnailURL = @"LargeThumbnailURL";

NSString *const XCDYouTubeVideoPlayerViewControllerDidReceiveVideoNotification = @"XCDYouTubeVideoPlayerViewControllerDidReceiveVideoNotification";
NSString *const XCDYouTubeVideoUserInfoKey = @"Video";

@interface XCDYouTubeVideoPlayerViewController ()
@property (nonatomic, weak) id<XCDYouTubeOperation> videoOperation;
@property (nonatomic, assign, getter = isEmbedded) BOOL embedded;
@end

@implementation XCDYouTubeVideoPlayerViewController

/*
 * MPMoviePlayerViewController on iOS 7 and earlier
 * - (id) init
 *        `-- [super init]
 *
 * - (id) initWithContentURL:(NSURL *)contentURL
 *        |-- [self init]
 *        `-- [self.moviePlayer setContentURL:contentURL]
 *
 * MPMoviePlayerViewController on iOS 8 and later
 * - (id) init
 *        `-- [self initWithContentURL:nil]
 *
 * - (id) initWithContentURL:(NSURL *)contentURL
 *        |-- [super init]
 *        `-- [self.moviePlayer setContentURL:contentURL]
 */

- (instancetype) init
{
	return [self initWithVideoIdentifier:nil];
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-designated-initializers"
- (instancetype) initWithContentURL:(NSURL *)contentURL
{
	@throw [NSException exceptionWithName:NSGenericException reason:@"Use the `initWithVideoIdentifier:` method instead." userInfo:nil];
}

- (instancetype) initWithVideoIdentifier:(NSString *)videoIdentifier
{
	if ([[[UIDevice currentDevice] systemVersion] integerValue] >= 8)
		self = [super initWithContentURL:nil];
	else
		self = [super init];
	
	if (!self)
		return nil;
	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
	
	if (videoIdentifier)
		self.videoIdentifier = videoIdentifier;
	
	return self;
}
#pragma clang diagnostic pop

#pragma mark - Public

- (NSArray *) preferredVideoQualities
{
	if (_preferredVideoQualities.count == 1)
		_preferredVideoQualities = @[ XCDYouTubeVideoQualityHTTPLiveStreaming, @(XCDYouTubeVideoQualityHD720), @(XCDYouTubeVideoQualityMedium360), @(XCDYouTubeVideoQualitySmall240) ];
	
	return _preferredVideoQualities;
}



- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.moviePlayer pause];
}

- (void) setVideoIdentifier:(NSString *)videoIdentifier
{
	if ([videoIdentifier isEqual:self.videoIdentifier])
		return;
	
	_videoIdentifier = [videoIdentifier copy];
	
	[self.videoOperation cancel];
//    if (!videoQuality) {
//        videoQuality = (long)18;
//    }
	self.videoOperation = [[XCDYouTubeClient defaultClient] getVideoWithIdentifier:videoIdentifier completionHandler:^(XCDYouTubeVideo *video, NSError *error) {
		if (video)
		{
			NSURL *streamURL = nil;
			for (NSNumber *videoQuality in self.preferredVideoQualities)
			{
				streamURL = video.streamURLs[videoQuality];
				if (streamURL)
				{
					[self startVideo:video streamURL:streamURL];
					break;
				}
			}
			
			if (!streamURL)
			{
				NSError *noStreamError = [NSError errorWithDomain:XCDYouTubeVideoErrorDomain code:XCDYouTubeErrorNoStreamAvailable userInfo:nil];
				[self stopWithError:noStreamError];
			}
		}
		else
		{
			[self stopWithError:error];
		}
	}];
}

- (void) presentInView:(UIView *)view
{
	static void *XCDYouTubeVideoPlayerViewControllerKey = &XCDYouTubeVideoPlayerViewControllerKey;
	
	self.embedded = YES;
	
	self.moviePlayer.controlStyle = MPMovieControlStyleEmbedded;
	self.moviePlayer.view.frame = CGRectMake(0.f, 0.f, view.bounds.size.width, view.bounds.size.height);
	self.moviePlayer.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	if (![view.subviews containsObject:self.moviePlayer.view])
		[view addSubview:self.moviePlayer.view];
	objc_setAssociatedObject(view, XCDYouTubeVideoPlayerViewControllerKey, self, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - Private

- (void) startVideo:(XCDYouTubeVideo *)video streamURL:(NSURL *)streamURL
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
	NSMutableDictionary *userInfo = [NSMutableDictionary new];
	if (video.title)
		userInfo[XCDMetadataKeyTitle] = video.title;
	if (video.smallThumbnailURL)
		userInfo[XCDMetadataKeySmallThumbnailURL] = video.smallThumbnailURL;
	if (video.mediumThumbnailURL)
		userInfo[XCDMetadataKeyMediumThumbnailURL] = video.mediumThumbnailURL;
	if (video.largeThumbnailURL)
		userInfo[XCDMetadataKeyLargeThumbnailURL] = video.largeThumbnailURL;
	
	[[NSNotificationCenter defaultCenter] postNotificationName:XCDYouTubeVideoPlayerViewControllerDidReceiveMetadataNotification object:self userInfo:userInfo];
#pragma clang diagnostic pop
	
	[[NSNotificationCenter defaultCenter] postNotificationName:XCDYouTubeVideoPlayerViewControllerDidReceiveVideoNotification object:self userInfo:@{ XCDYouTubeVideoUserInfoKey: video }];
	
	self.moviePlayer.contentURL = streamURL;
   [self.moviePlayer prepareToPlay];
}

- (void) stopWithError:(NSError *)error
{
	NSDictionary *userInfo = @{ MPMoviePlayerPlaybackDidFinishReasonUserInfoKey: @(MPMovieFinishReasonPlaybackError),
	                            XCDMoviePlayerPlaybackDidFinishErrorUserInfoKey: error };
	[[NSNotificationCenter defaultCenter] postNotificationName:MPMoviePlayerPlaybackDidFinishNotification object:self.moviePlayer userInfo:userInfo];
}

-(void) enableRepeat
{
    [self.moviePlayer setRepeatMode:MPMovieRepeatModeOne];
}

-(void) disableRepeat
{
    [self.moviePlayer setRepeatMode:MPMovieRepeatModeNone];
}


@end
