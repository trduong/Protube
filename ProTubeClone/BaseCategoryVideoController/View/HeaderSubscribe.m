//
//  HeaderSubscribe.m
//  ProTubeClone
//
//  Created by Hoang on 1/18/15.
//  Copyright (c) 2015 Future Work. All rights reserved.
//

#import "HeaderSubscribe.h"
#import <AFHTTPRequestOperationManager.h>

@interface HeaderSubscribe()<UIActionSheetDelegate>

@property (copy, nonatomic) void (^didSubcribeBlock)(id sender);

@end

@implementation HeaderSubscribe

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.imageBackgroundView];
        [self addSubview:self.avatarImageView];
        [self addSubview:self.userNameLabel];
        [self addSubview:self.subscriberLabel];
        [self addSubview:self.subcriberButton];
        
        [self setBackgroundColor:[UIColor whiteColor]];
    }
    return self;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

#pragma mark Getters
- (UIImageView*)imageBackgroundView
{
    if (!_imageBackgroundView) {
        _imageBackgroundView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame) - 44.0f)];
        _imageBackgroundView.contentMode = UIViewContentModeScaleAspectFill;
        _imageBackgroundView.clipsToBounds = YES;
        _imageBackgroundView.image = [UIImage imageNamed:@"channel_default_banner"];
    }
    return _imageBackgroundView;
}

- (UIImageView*)avatarImageView
{
    if(!_avatarImageView){
        _avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(12.0f, 0.0f, 66.0f, 66.0f)];
        _avatarImageView.contentMode = UIViewContentModeScaleAspectFill;
        _avatarImageView.clipsToBounds = YES;
        _avatarImageView.image = [UIImage imageNamed:@"img_avatar"];
    }
    return _avatarImageView;
}

- (UILabel*)userNameLabel
{
    if(!_userNameLabel){
        _userNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(12.0f, CGRectGetHeight(self.imageBackgroundView.frame) + 5.0f, CGRectGetWidth(self.frame) - 24.0f, 18.0f)];
        [_userNameLabel setBackgroundColor:[UIColor clearColor]];
        [_userNameLabel setFont:[UIFont systemFontOfSize:15.0f]];
        [_userNameLabel setTextColor:[UIColor colorWithRed:30/255.0f green:30/255.0f blue:30/255.0f alpha:1.0f]];
        [_userNameLabel setText:@"Phan Quang Hoang"];
    }
    return _userNameLabel;
}

- (UILabel*)subscriberLabel
{
    if(!_subscriberLabel){
        _subscriberLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.userNameLabel.frame), CGRectGetMaxY(self.userNameLabel.frame) + 1.0f, CGRectGetWidth(self.frame) - 24.0f - 100.0f, 15.0f)];
        [_subscriberLabel setBackgroundColor:[UIColor clearColor]];
        [_subscriberLabel setFont:[UIFont systemFontOfSize:13.0f]];
        [_subscriberLabel setTextColor:[UIColor colorWithRed:149/255.0f green:149/255.0f blue:149/255.0f alpha:1.0f]];
        [_subscriberLabel setText:@"0 subcribers"];
    }
    return _subscriberLabel;
}

- (UIButton*)subcriberButton
{
    if (!_subcriberButton) {
        _subcriberButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.frame) - 110.0f - 8.0f, CGRectGetHeight(self.imageBackgroundView.frame) + (44 - 32.0f)/2, 110.0f, 32.0f)];
        
        [_subcriberButton setTitleColor:[UIColor colorWithRed:165/255.0f green:165/255.0f blue:165/255.0f alpha:1.0f] forState:UIControlStateNormal];
        [_subcriberButton.titleLabel setFont:[UIFont systemFontOfSize:13.0f]];
        
        [_subcriberButton setTitle:@"Subcribed" forState:UIControlStateNormal];
        [_subcriberButton setImage:[UIImage imageNamed:@"unsubcribe"] forState:UIControlStateNormal];
        
        _subcriberButton.titleEdgeInsets = UIEdgeInsetsMake(0.0f, 20.0f, 0.0f, 0.0f);
        _subcriberButton.imageEdgeInsets = UIEdgeInsetsMake(0.0f, 10.0f, 0.0f, 0.0f);
        [_subcriberButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        
        _subcriberButton.layer.borderWidth = 1.0f;
        _subcriberButton.layer.borderColor = [UIColor colorWithRed:165/255.0f green:165/255.0f blue:165/255.0f alpha:1.0f].CGColor;
        [_subcriberButton addTarget:self action:@selector(subcriberButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.subcriberButton addSubview:self.indicatorView];
        //[self.indicatorView startAnimating];
    }
    return _subcriberButton;
}

- (UIActivityIndicatorView*)indicatorView
{
    if (!_indicatorView) {
        _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        CGFloat halfButtonHeight = self.subcriberButton.bounds.size.height / 2;
        _indicatorView.center = CGPointMake(halfButtonHeight , halfButtonHeight);
    }
    return _indicatorView;
}
#pragma marck Action
- (void)subcriberButtonPressed:(id)sender
{
    if (self.isSubscribe) {
        [self openActionSheet];
    } else {
        [self subscribeChannel];
    }
//    if (self.didSubcribeBlock) {
//        self.didSubcribeBlock(sender);
//    }
}

- (void)openActionSheet
{
    NSString *cancelTitle = @"Cancel";
    NSString *unscubribe = @"Unsubscribe";
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:nil
                                  delegate:self
                                  cancelButtonTitle:cancelTitle
                                  destructiveButtonTitle:unscubribe
                                  otherButtonTitles:nil];
    actionSheet.tag = 0;

    [actionSheet showInView:self.parentViewController.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [self cancelSubscribeChannel];
    }
}

#pragma mark API
-(void)subscribeChannel
{
    NSString *access_token=[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] valueForKey:@"access_token"]];
        
    NSString *cId = [NSString stringWithFormat:@"{\"snippet\": {    \"resourceId\": {    \"kind\": \"youtube#channel\",    \"channelId\": \"%@\"}}}",self.menuItem.menuId];
    
    NSString *url=[NSString stringWithFormat:@"https://www.googleapis.com/youtube/v3/subscriptions?part=snippet&access_token=%@",access_token];
    NSURL *ur=[NSURL URLWithString:url];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:ur
                                                               cachePolicy:NSURLRequestReloadIgnoringCacheData  timeoutInterval:10];
        
    [request setHTTPMethod:@"POST"];
    [request setValue: @"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody: [cId dataUsingEncoding:NSUTF8StringEncoding]];

    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    op.responseSerializer = [AFJSONResponseSerializer serializer];
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self.indicatorView stopAnimating];
        self.isSubscribe = YES;
        [self.subcriberButton setTitle:@"Subscribed" forState:UIControlStateNormal];
        [self.subcriberButton setImage:[UIImage imageNamed:@"unsubcribe"] forState:UIControlStateNormal];
                
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self.indicatorView stopAnimating];
        self.isSubscribe = NO;
        [self.subcriberButton setTitle:@"Subscribe" forState:UIControlStateNormal];
        [self.subcriberButton setImage:[UIImage imageNamed:@"add_subcribe"] forState:UIControlStateNormal];
    }];
    [op start];
    [self.subcriberButton setImage:[UIImage imageNamed:@"clear"] forState:UIControlStateNormal];
    [self.indicatorView startAnimating];
}

-(void)cancelSubscribeChannel
{
    NSString *access_token=[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults]valueForKey:@"access_token"]];
        
    NSString *url=[NSString stringWithFormat:@"https://www.googleapis.com/youtube/v3/subscriptions?id=%@&access_token=%@",self.menuItem.subsciptionId, access_token];
    NSURL *ur=[NSURL URLWithString:url];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:ur
                                                               cachePolicy:NSURLRequestReloadIgnoringCacheData  timeoutInterval:10];
        
    [request setHTTPMethod:@"DELETE"];
    
    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    op.responseSerializer = [AFJSONResponseSerializer serializer];
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self.subcriberButton setTitle:@"Subscribe" forState:UIControlStateNormal];
        [self.subcriberButton setImage:[UIImage imageNamed:@"add_subcribe"] forState:UIControlStateNormal];
        self.isSubscribe = NO;
        [self.indicatorView stopAnimating];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self.subcriberButton setTitle:@"Subcribed" forState:UIControlStateNormal];
        [self.subcriberButton setImage:[UIImage imageNamed:@"unsubcribe"] forState:UIControlStateNormal];
        self.isSubscribe = YES;
        [self.indicatorView stopAnimating];
    }];
    [op start];
    [self.subcriberButton setImage:[UIImage imageNamed:@"clear"] forState:UIControlStateNormal];
    [self.indicatorView startAnimating];
    
}

@end
