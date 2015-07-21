//
//  AddCommentViewController.m
//  ProTubeClone
//
//  Created by Kaur on 13/09/14.
//  Copyright (c) 2014 Future Work. All rights reserved.
//

#import "AddCommentViewController.h"
#import "AppDelegate.h"
#import "AFHTTPRequestOperation.h"

@interface AddCommentViewController ()

@end

@implementation AddCommentViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [_tvComent becomeFirstResponder];
    _tvComent.layer.cornerRadius=6;
    _tvComent.clipsToBounds=YES;
    
    appDelegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cancel:(id)sender {
    appDelegate.isSend = NO;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)send:(id)sender
{
    
    NSDateFormatter *DateFormatter=[[NSDateFormatter alloc] init];
    [DateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    NSLog(@"%@",[DateFormatter stringFromDate:[NSDate date]]);
    NSString *strDate = [DateFormatter stringFromDate:[NSDate date]];
    appDelegate.isSend = YES;
    appDelegate.aryComents = [NSMutableArray new];
    [appDelegate.aryComents addObject:[NSDictionary dictionaryWithObjectsAndKeys:_tvComent.text,@"content"
                            ,[[[NSUserDefaults standardUserDefaults]valueForKey:@"name"] capitalizedString],@"author"
                            ,strDate,@"published",nil]];
    [self dismissViewControllerAnimated:YES completion:nil];
    
    [self addCommentVideoWithString:_tvComent.text videoId:self.videoId];
}

-(void)addCommentVideoWithString:(NSString*)comment videoId:(NSString*)videoId
{
    NSString *access_token=[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] valueForKey:@"access_token"]];
    
    NSString *xmlString = @"<?xml version=\"1.0\" encoding=\"UTF-8\"?><entry xmlns=\"http://www.w3.org/2005/Atom\" xmlns:yt=\"http://gdata.youtube.com/schemas/2007\"><content>%@</content></entry>";
    NSString *xmlFormat = [NSString stringWithFormat:xmlString, comment];
    
    NSString *urlStr= [NSString stringWithFormat:@"https://gdata.youtube.com/feeds/api/videos/%@/comments",videoId];
    NSURL *url = [NSURL URLWithString:urlStr];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    [request setHTTPMethod:@"POST"];
    
    [request setValue:@"application/atom+xml" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"key=%@",GOOGLE_KEY] forHTTPHeaderField:@"X-GData-Key"];
    [request setValue:[NSString stringWithFormat:@"Bearer %@",access_token] forHTTPHeaderField:@"Authorization"];
    [request setValue:@"2" forHTTPHeaderField:@"GData-Version"];
    [request setValue:[NSString stringWithFormat:@"%d", [xmlFormat length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:[xmlFormat dataUsingEncoding:NSUTF8StringEncoding]];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"operation hasAcceptableStatusCode: %d", [operation.response statusCode]);
        
        NSLog(@"response string: %@ ", operation.responseString);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"error: %@", operation.responseString);
        
    }];
    
    [operation start];

}
@end
