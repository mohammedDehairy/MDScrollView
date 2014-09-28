//
//  MDScrollView.h
//  MDScrollView
//
//  Created by mohamed mohamed El Dehairy on 9/24/14.
//  Copyright (c) 2014 mohamed mohamed El Dehairy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MDScrollView : UIView
{
    UIView *contentView;
    CGPoint previousTouchLocation;
    
    CGFloat maximumZoomingScale;
    CGFloat minimumZoomingScale;
    
    BOOL animating;
    
    
    NSTimer *deccelerationTimer;
    CGPoint decceleration;
    CGPoint initialDeccelerationVelociy;
    
    
    UIView *verticalScrollBar;
    UIView *horizontalScrollBar;
    
    
    CGFloat currentScale;
}
-(void)setContentSize:(CGSize)contentSize;
-(void)zoomWithScale:(CGFloat)scale;
@end
