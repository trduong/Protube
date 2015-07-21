//
//  AdViewController.m
//  ProTubeClone
//
//  Created by Hoang on 3/28/15.
//  Copyright (c) 2015 Future Work. All rights reserved.
//

#import "AdViewController.h"

@interface AdViewController ()

@end

@implementation AdViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.view addSubview:self.adsBannerView];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Getters
- (GADBannerView*)adsBannerView
{
    if (!_adsBannerView) {
        if (IS_IPAD) {
            _adsBannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeLeaderboard origin:CGPointMake(CGRectGetWidth(self.view.frame) - 768.0f, CGRectGetHeight(self.view.frame) - 49.0f - 90.0f - 47.0f - 15.0f)];
        } else {
            _adsBannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeSmartBannerPortrait origin:CGPointMake(0.0f, CGRectGetHeight(self.view.frame) - 49.0f - 50.0f - 47.0f - 15.0f)];
        }
        
        _adsBannerView.adUnitID = @"ca-app-pub-3940256099942544/2934735716";
        _adsBannerView.rootViewController = self;
        _adsBannerView.delegate = self;

        
        GADRequest *request = [GADRequest request];
        // Enable test ads on simulators.
        //request.testDevices = @[ GAD_SIMULATOR_ID ];
        request.testDevices = @[ @"70aad6557d72a9ebbbe7cafc70420b3e" ];
        [_adsBannerView loadRequest:request];
    }
    return _adsBannerView;
}

- (void)adViewDidReceiveAd:(GADBannerView *)bannerView {
    [UIView beginAnimations:@"BannerSlide" context:nil];
    self.adsBannerView.frame = CGRectMake(0.0,
                                  self.view.frame.size.height -
                                          self.adsBannerView.frame.size.height - (IS_IPAD?50.0f: 49.0f),
                                  self.adsBannerView.frame.size.width,
                                  self.adsBannerView.frame.size.height);
    [UIView commitAnimations];
}

- (void)adView:(GADBannerView *)bannerView
didFailToReceiveAdWithError:(GADRequestError *)error {
    NSLog(@"adView:didFailToReceiveAdWithError:%@", [error localizedDescription]);
}

@end
