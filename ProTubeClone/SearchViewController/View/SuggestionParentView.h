//
//  SuggestionParentView.h
//  ProTubeClone
//
//  Created by Hoang on 1/31/15.
//  Copyright (c) 2015 Future Work. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SuggestionDelegate <NSObject>

@required
- (void)suggestDidSelectItem:(NSString*)textSuggest;

@end


@interface SuggestionParentView : UIView

@property (weak, nonatomic) id<SuggestionDelegate> delegate;

- (void)resizeViewWithHeight:(CGFloat)height;
- (void)reloadDatasource:(NSArray*)data;
@end
