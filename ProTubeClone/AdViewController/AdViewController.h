//
//  AdViewController.h
//  ProTubeClone
//
//  Created by Hoang on 3/28/15.
//  Copyright (c) 2015 Future Work. All rights reserved.
//

#import <UIKit/UIKit.h>

@import GoogleMobileAds;

@interface AdViewController : UIViewController<GADBannerViewDelegate>

@property (strong, nonatomic) GADBannerView * adsBannerView;

@end
