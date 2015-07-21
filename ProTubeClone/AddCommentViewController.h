//
//  AddCommentViewController.h
//  ProTubeClone
//
//  Created by Kaur on 13/09/14.
//  Copyright (c) 2014 Future Work. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AppDelegate;
@interface AddCommentViewController : UIViewController
{
    AppDelegate *appDelegate;
}

@property (strong, nonatomic) IBOutlet UITextView *tvComent;
@property (strong, nonatomic) NSString *videoId;

- (IBAction)cancel:(id)sender;
- (IBAction)send:(id)sender;


@end
