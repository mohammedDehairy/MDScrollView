//
//  MDScrollView.m
//  MDScrollView
//
//  Created by mohamed mohamed El Dehairy on 9/24/14.
//  Copyright (c) 2014 mohamed mohamed El Dehairy. All rights reserved.
//

#import "MDScrollView.h"

@implementation MDScrollView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        // setup content view
        contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 0)];
        [self addSubview:contentView];
        contentView.contentMode = UIViewContentModeTop;
        [contentView sizeToFit];
        contentView.backgroundColor = [UIColor whiteColor];
        
        // setup vertical scroll bar
        verticalScrollBar = [[UIView alloc] initWithFrame:CGRectMake(self.frame.size.width-7, 0, 7, self.bounds.size.height)];
        [self addSubview:verticalScrollBar];
        verticalScrollBar.backgroundColor = [UIColor colorWithWhite:0.2 alpha:0.5];
        verticalScrollBar.layer.cornerRadius = verticalScrollBar.bounds.size.width/2;
        
        
        // setup horizontal scroll bar
        horizontalScrollBar = [[UIView alloc] initWithFrame:CGRectMake(0, self.bounds.size.height-7, self.bounds.size.width, 7)];
        [self addSubview:horizontalScrollBar];
        horizontalScrollBar.backgroundColor = [UIColor colorWithWhite:0.2 alpha:0.5];
        horizontalScrollBar.layer.cornerRadius = horizontalScrollBar.bounds.size.height/2;
        
        
        // setup pan gesture recognizer for scrolling
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(scrolling:)];
        [self addGestureRecognizer:panGesture];
        
        
        // setup pinch gesture for zooming
        UIPinchGestureRecognizer *pihcGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinch:)];
        [self addGestureRecognizer:pihcGesture];
        
        
        // initail value for zooming scale is 1.0
        currentScale = 1.0;
        
        // initial value for minimum and maximum zooming scale
        maximumZoomingScale = 2.0;
        minimumZoomingScale = 0.5;
        
        // decceleration
        //decceleration = 2;
    }
    return self;
}
-(void)scrolling:(UIPanGestureRecognizer*)panGesture
{
    if(panGesture.state == UIGestureRecognizerStateBegan)
    {
        [deccelerationTimer invalidate];
    }else if(panGesture.state == UIGestureRecognizerStateChanged)
    {
        // get location of scroll touch
        CGPoint location = [panGesture locationInView:contentView];
        
        // get delta x and delta y
        CGFloat dy = location.y - previousTouchLocation.y;
        CGFloat dx = location.x - previousTouchLocation.x;
        
        // scroll by delta y and delta x
        [self scrollWithDY:dy withDX:dx];
        
    }else
    {
     
        
        // bounce back if content view is out of bounds
        [self bounceBack];
        
        [self deccelerateWithInitialVelocity:[panGesture velocityInView:contentView]];
        
    }
    
    
    previousTouchLocation = [panGesture locationInView:contentView];
}
-(void)deccelerateWithInitialVelocity:(CGPoint)initialVelocity
{
    CGFloat time = 0.001;
    initialDeccelerationVelociy = initialVelocity;
    
    deccelerationTimer = [NSTimer scheduledTimerWithTimeInterval:time target:self selector:@selector(updateDeceleration:) userInfo:nil repeats:YES];
    
    
}
-(void)updateDeceleration:(NSTimer*)timer
{
    CGFloat xV = initialDeccelerationVelociy.x;
    CGFloat yV = initialDeccelerationVelociy.y;
    
    decceleration.x = -1 * initialDeccelerationVelociy.x * 0.01;
    decceleration.y = -1 * initialDeccelerationVelociy.y * 0.01;
    
    BOOL hitedge = [self scrollWithDY:initialDeccelerationVelociy.y*0.001 withDX:initialDeccelerationVelociy.x*0.001];
    
    initialDeccelerationVelociy.x += decceleration.x;
    
    initialDeccelerationVelociy.y += decceleration.y;
    
    
    
    if(xV * initialDeccelerationVelociy.x <= 0 )
    {
        initialDeccelerationVelociy.x = 0;
    }
    
    if(yV * initialDeccelerationVelociy.y <= 0)
    {
        initialDeccelerationVelociy.y = 0;
    }
    
    if(initialDeccelerationVelociy.y == 0 && initialDeccelerationVelociy.x == 0)
    {
        [deccelerationTimer invalidate];
    }
    
    if(hitedge)
    {
        [deccelerationTimer invalidate];
        [self bounceBack];
    }
    
    
}
-(void)pinch:(UIPinchGestureRecognizer*)pinchGesture
{
    if(pinchGesture.state == UIGestureRecognizerStateEnded)
    {
        // bounce back if content view is out of bounds
        [self bounceBack];
    }
    
    CGFloat scale = pinchGesture.scale;
    
    // no zooming more than maximum and less than maximum
    if(currentScale*scale <= minimumZoomingScale || currentScale*scale >= maximumZoomingScale)
    {
        return;
    }
    
    // scale with respect to current scale
    currentScale *= scale;
    
    
    [self zoomWithScale:currentScale];
    
    
    

}
-(void)setContentSize:(CGSize)contentSize
{
    CGRect contentFrame = contentView.frame;
    
    contentFrame.size = contentSize;
    contentView.frame = contentFrame;
    
    [self scaleScrollBarsToContentSize:contentSize];
}
-(void)addSubview:(UIView *)view
{
    if(view != contentView && view != verticalScrollBar && view != horizontalScrollBar)
    {
        //any subview other than content view and scroll bars are added to content view
        [contentView addSubview:view];
        
    }else
    {
        [super addSubview:view];
    }
    
}
-(void)zoomWithScale:(CGFloat)scale
{
    // save initial Origin
    CGPoint initialOrigin = contentView.frame.origin;
    
    // zoom using core graphics
    CGAffineTransform scaleTransform = CGAffineTransformMakeScale(scale, scale);
    contentView.transform = scaleTransform;
    
    
    
    // maintain initial origin scaled
    CGRect contentFrame = contentView.frame;
    contentFrame.origin.x = initialOrigin.x*scale;
    contentFrame.origin.y = initialOrigin.y*scale;
    
    if(contentView.frame.size.width < self.frame.size.width)
    {
        contentFrame.origin.x = (self.frame.size.width-contentView.frame.size.width)/2;
    }
    
    if(contentView.frame.size.height < self.frame.size.height)
    {
        contentFrame.origin.y = (self.frame.size.height-contentView.frame.size.height)/2;
    }
    
    contentView.frame = contentFrame;
    
    // scale scroll bars
    [self scaleScrollBarsToContentSize:CGSizeMake(contentView.frame.size.width*scale, contentView.frame.size.height*scale)];
    
    currentScale = scale;
}
-(void)scaleScrollBarsToContentSize:(CGSize)size
{
    // scale scroll bars to have size relative to self the same as self size is to content size
    
    CGRect vScrollBarFrame = verticalScrollBar.frame;
    vScrollBarFrame.size.height = (self.frame.size.height/size.height)*self.frame.size.height;
    verticalScrollBar.frame = vScrollBarFrame;
    
    CGRect hScrollBarFrame = horizontalScrollBar.frame;
    hScrollBarFrame.size.width = (self.frame.size.width/size.width)*self.frame.size.width;
    horizontalScrollBar.frame = hScrollBarFrame;
}
/*-(UIView*)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    delayedTouchedView = [contentView hitTest:point withEvent:event];
    return self;
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    
    initialTouch = [touch locationInView:contentView];
    lastTouch = initialTouch;
    
    lastTouchTimeStamp = [event timestamp];
    
    delayedTouches = touches;
    delayedTouchEvent = event;
}
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    
    CGPoint location = [touch locationInView:contentView];
    
    
    CGFloat dy = location.y - [touch previousLocationInView:contentView].y;
    CGFloat dx = location.x - [touch previousLocationInView:contentView].x;
    
    [self scrollWithDY:dy withDX:dx];

    
    currentTouchTimeStamp = [event timestamp];
    
    timeSinceLastEvent = currentTouchTimeStamp - lastTouchTimeStamp;
    
    toucheMoved = YES;
    
}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(!toucheMoved && delayedTouchEvent)
    {
        
        [delayedTouchedView touchesBegan:delayedTouches withEvent:delayedTouchEvent];
        return;
    }
    
    [self bounceBack];
    
    
    UITouch *touch = [touches anyObject];
    
    CGFloat dy = [touch locationInView:contentView].y - [touch previousLocationInView:contentView].y;
    CGFloat dx = [touch locationInView:contentView].x - [touch previousLocationInView:contentView].x;
    
    
    decceleratingDx = dx;
    decceleratingDy = dy;
    
    
   // timer = [NSTimer scheduledTimerWithTimeInterval:timeSinceLastEvent target:self selector:@selector(deccelerate:) userInfo:nil repeats:YES];
    
    toucheMoved = NO;
    delayedTouchEvent = nil;
    delayedTouches = nil;
    delayedTouchedView = nil;
    
}*/
-(CGRect)scaledContentRect
{
    CGRect scaledContentRect = contentView.frame;
    scaledContentRect.size = CGSizeMake(scaledContentRect.size.width*1.0, scaledContentRect.size.height*1.0);
    scaledContentRect.origin.x *= 1.0;
    scaledContentRect.origin.y *= 1.0;
    return scaledContentRect;
}
-(void)bounceBack
{
    if(!bounces)
    {
        return;
    }
    
    CGRect contentFrame = contentView.frame;
    CGRect vScrollFrame = verticalScrollBar.frame;
    CGRect hScrollFrame = horizontalScrollBar.frame;
    
    // the time it takes content view to bounce bake when its origin get out of bounds of scroll view is inversely proportional to the distance from the edge
    
    // bounceTime = timeFactor / (distance from the edge + additionFactor)
    CGFloat timeFactor = 1.5;
    
    // the addition factor is necessary to avoid dividing by zero or very small number
    CGFloat additionFactor = 20;
    
    // spring damping factor and initial spring velocity
    CGFloat springDampingFactor = 10;
    CGFloat initialSpringVelocity = 10;
    
    
    
    
    
    
    // bounce time for y position
    CGFloat ytime = 0.0;
    
    CGRect scaledContentRect = [self scaledContentRect];
    
    
    // check if content view origin y position got out of bounds and calculate the bounce time
    if(scaledContentRect.origin.y > 0 )
    {
        ytime = timeFactor / (scaledContentRect.origin.y + additionFactor) ;
        
        
        contentFrame.origin.y = 0;
        vScrollFrame.origin.y = 0;
        
        
    }else if (scaledContentRect.origin.y < self.bounds.size.height-scaledContentRect.size.height)
    {
        ytime = timeFactor / ((self.bounds.size.height-scaledContentRect.size.height - scaledContentRect.origin.y ) + additionFactor);
        
        
        contentFrame.origin.y = self.frame.size.height - scaledContentRect.size.height;
        vScrollFrame.origin.y = self.bounds.size.height - verticalScrollBar.bounds.size.height;
    }
    
    
    
    
    
    
    
    // bounce factor for x position
    CGFloat xtime = 0.0;
    
    
    // check if content view x position got out of bounds and calculate the bounce time
    if(scaledContentRect.origin.x > 0)
    {
        
        xtime = timeFactor / ((scaledContentRect.origin.x) + additionFactor);
        
        contentFrame.origin.x = 0;
        hScrollFrame.origin.x = 0;
        
    }else if (scaledContentRect.origin.x < self.bounds.size.width-scaledContentRect.size.width)
    {
        xtime = timeFactor / ((self.bounds.size.width-scaledContentRect.size.width - scaledContentRect.origin.x ) + additionFactor);
        
        
        contentFrame.origin.x = self.frame.size.width - scaledContentRect.size.width;
        hScrollFrame.origin.x = self.bounds.size.width - horizontalScrollBar.bounds.size.width;
        
    }
    
    
    
    animating = YES;
    
    scaledContentRect = contentFrame;
    
    
    
    // over all bounce time is the vector magnitude of both the x bounce time and y bounce time
    CGFloat overAllTime = sqrtf(ytime*ytime+xtime*xtime);
    
    
    // animate the bounce
    [UIView animateWithDuration:overAllTime delay:0.0 usingSpringWithDamping:springDampingFactor initialSpringVelocity:initialSpringVelocity options:UIViewAnimationOptionCurveEaseOut animations:^(void){
        
        
        contentView.frame = scaledContentRect;
        verticalScrollBar.frame = vScrollFrame;
        horizontalScrollBar.frame = hScrollFrame;
        
    } completion:^(BOOL finished){
        
        animating = NO;
        
        
    }];
}
/*-(void)deccelerate:(NSTimer*)time
{
    
    CGFloat dampingFactor = 0.8;
    
    decceleratingDy *= dampingFactor;
    decceleratingDx *= dampingFactor;
    
    BOOL hitEdge = [self scrollWithDY:decceleratingDy withDX:decceleratingDx];
    
    if((decceleratingDx == 0 && decceleratingDy == 0) || hitEdge)
    {
        [timer invalidate];
        [self bounceBack];
        decceleratingDx = 0.0;
        decceleratingDy = 0.0;
    }
}*/


-(BOOL)scrollWithDY:(CGFloat)dy withDX:(CGFloat)dx
{
    if(animating)
    {
        return NO;
    }
    
    
    BOOL hitEdge = NO;
    
    CGRect scaledContentRect = [self scaledContentRect];
    
    
    CGRect contentFrame = scaledContentRect;
    
    CGFloat factor = 0.1 * (scaledContentRect.origin.y + dy);
    
    
    if(scaledContentRect.origin.y + dy > 0)
    {
        if(bounces)
        {
            dy /= factor;
            hitEdge = YES;
        }else
        {
            dy = 0;
        }
        
        
    }else if (scaledContentRect.origin.y + dy < self.bounds.size.height-scaledContentRect.size.height)
    {
        if(bounces)
        {
            factor = 0.1 * (self.bounds.size.height-scaledContentRect.size.height - scaledContentRect.origin.y - dy);
            dy /= factor;
            hitEdge = YES;
        }else
        {
            dy = 0;
        }
        
    }
    
    contentFrame.origin.y += dy;
    
    
    
    
    
    CGFloat xfactor = 0.1 * (scaledContentRect.origin.x + dx);
    
    if(scaledContentRect.origin.x + dx > 0)
    {
        if(bounces)
        {
            dx /= xfactor;
            hitEdge = YES;
        }else
        {
            dx = 0;
        }
        
    }else if (scaledContentRect.origin.x + dx < self.bounds.size.width-scaledContentRect.size.width)
    {
        if(bounces)
        {
            xfactor = 0.1 * (self.bounds.size.width-scaledContentRect.size.width-scaledContentRect.origin.x - dx);
            dx /= xfactor;
            hitEdge = YES;
        }else
        {
            dx = 0;
        }
        
    }
    contentFrame.origin.x += dx;
    
    
    
    CGRect hScrollFrame = horizontalScrollBar.frame;
    hScrollFrame.origin.x -= dx/(contentFrame.size.width/self.bounds.size.width);
    horizontalScrollBar.frame = hScrollFrame;
    
    CGRect vScrollFrame = verticalScrollBar.frame;
    vScrollFrame.origin.y -= dy/(contentFrame.size.height/self.bounds.size.height);
    verticalScrollBar.frame = vScrollFrame;
    
    scaledContentRect = contentFrame;
    contentView.frame = scaledContentRect;
    
    
    
    
    return hitEdge;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
