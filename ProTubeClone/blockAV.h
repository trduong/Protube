//
//  blockAV.h
//  ProTubeClone
//
//  Created by Apple on 12/08/14.
//  Copyright (c) 2014 Future Work. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface blockAV : UIAlertView<UIAlertViewDelegate>
- (id) initWithTitle:(NSString *)title message:(NSString *)message block: (void (^)(NSInteger buttonIndex))block
   cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ...  NS_AVAILABLE(10_6, 4_0);

@end
