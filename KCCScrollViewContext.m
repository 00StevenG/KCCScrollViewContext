//
//  KCCScrollViewContext.m
//  KCCScrollViewContext
//
//  Created by Steven Grace on 6/15/15.
//  Copyright (c) 2015 Steven Grace. All rights reserved.
//

#import "KCCScrollViewContext.h"


// Private Interface
@interface KCCScrollViewContext ()

@property (nonatomic, readwrite ,weak) UIScrollView *scrollView;

@property (nonatomic, readwrite, assign) BOOL isScrolling;
@property (nonatomic, readwrite, assign) BOOL isAnimating;

@property (nonatomic, readwrite, copy) void (^scrollAnimationCompleteBlock)(void);

@property (nonatomic, readwrite, assign) CGPoint scrollingBeganOffset;
@property (nonatomic, readwrite, assign) CGPoint expectedScrollingEndOffset;
@property (nonatomic, readwrite, assign) CGPoint proposedScrollingEndOffset;

@property (nonatomic, readwrite, assign) CGPoint scrollingEndedOffset;

@property (nonatomic, readwrite, assign) CGPoint lastContentOffset;
@property (nonatomic, readwrite, assign) CGPoint scrollingVelocity;

@property (nonatomic, readwrite ,assign) UIRectEdge scrollingToHorizontalEdge;
@property (nonatomic, readwrite ,assign) UIRectEdge scrollingToVerticalEdge;

@property (nonatomic, readwrite ,assign) CGFloat zoomingBeganScale;

@property (nonatomic, readwrite ,assign) UIRectEdge bouncingEdge;

@end

@implementation KCCScrollViewContext


#pragma mark - init

- (instancetype)initWithScrollView:(UIScrollView*)scrollView andDelegate:(id<KCCScrollViewContextDelegate>)delegate {
    
    if ([super init]) {
        _scrollDelegate = delegate;
        _scrollView = scrollView;
        _scrollView.delegate = self;
        _lastContentOffset = _scrollView.contentOffset;
        [_scrollView.panGestureRecognizer addTarget:self action:@selector(scrollViewPanGestureHandler:)];
    }
    return self;
    
}

- (void)dealloc {
    
    [_scrollView.panGestureRecognizer removeTarget:self action:@selector(scrollViewPanGestureHandler:)];
}

- (void)sendScroll:(UIScrollView *)scroll messageIfNeeded:(SEL)message {
    
    if ([self.scrollDelegate respondsToSelector:message]) {
#       pragma clang diagnostic push
#       pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [self.scrollDelegate performSelector:message withObject:scroll];
#       pragma clang diagnostic pop
        
    }
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    
    BOOL result = [super respondsToSelector:aSelector];
    if (!result) {
        result = [self.scrollDelegate respondsToSelector:aSelector];
    }
    return result;
}

- (id)forwardingTargetForSelector:(SEL)aSelector {
    
    if ([self.scrollDelegate respondsToSelector:aSelector]) {
        return self.scrollDelegate;
    }
    return [super forwardingTargetForSelector:aSelector];
}

#pragma mark - Setters 

- (void)setIsScrolling:(BOOL)isScrolling {
    
    if (_isScrolling == isScrolling) {
        return;
    }
    
    _isScrolling = isScrolling;
    
    self.scrollingVelocity = CGPointZero;
    
    self.scrollingToHorizontalEdge = UIRectEdgeNone;
    self.scrollingToVerticalEdge = UIRectEdgeNone;
    
    self.bouncingEdge = UIRectEdgeNone;
    
    if (_isScrolling) {
        self.expectedScrollingEndOffset = CGPointMake(NAN,NAN);
        self.scrollingBeganOffset = self.scrollView.contentOffset;
        self.scrollingEndedOffset = CGPointZero;
    }
    else{
        self.scrollingEndedOffset = self.scrollView.contentOffset;
        
        if ([self.scrollDelegate respondsToSelector:@selector(scrollViewDidScroll:toOffset:)]) {
            [self.scrollDelegate scrollViewDidScroll:self toOffset:self.scrollingEndedOffset];
        }
        
        self.expectedScrollingEndOffset = CGPointMake(NAN,NAN);
    }
}

#pragma mark - Internal

- (void)informDelegeateOfScrollingToContentEdgeIfNeededWillScroll:(BOOL)willScroll {
    
    if (![self.scrollDelegate respondsToSelector:@selector(scrollViewDidScroll:toContentEdge:)]) {
        return;
    }
    
    CGPoint offset = willScroll ? self.proposedScrollingEndOffset : self.scrollView.contentOffset;
    
    UIRectEdge edge= UIRectEdgeNone;

    if ([self contentMarginForOffset:offset fromEdge:UIRectEdgeTop]<0) {
        edge = UIRectEdgeTop;
    }
    else if([self contentMarginForOffset:offset fromEdge:UIRectEdgeBottom]<0) {
        edge = UIRectEdgeBottom;
    }
    else if([self contentMarginForOffset:offset fromEdge:UIRectEdgeRight]<0) {
        edge = UIRectEdgeRight;
    }
    else if([self contentMarginForOffset:offset fromEdge:UIRectEdgeLeft]<0) {
        edge = UIRectEdgeLeft;
    }
    
    if (edge==UIRectEdgeNone) {
        return;
    }

    
    if (willScroll) {
        [self.scrollDelegate scrollViewWillScroll:self toContentEdge:edge];
    }
    else{
        [self.scrollDelegate scrollViewDidScroll:self toContentEdge:edge];
    }
    
}

- (void)informDelegateOfBounceEventIfNeeded {
    
    if (!self.scrollView.bounces) {
        return;
    }
    
    if (![self.scrollDelegate respondsToSelector:@selector(scrollViewWillBounce:toEdge:)]) {
        return;
    }
    
    
    UIRectEdge edge= UIRectEdgeNone;
    
    if([self contentMarginForOffset:self.proposedScrollingEndOffset fromEdge:UIRectEdgeTop]<0) {
        edge= UIRectEdgeTop;
    }
    else if ([self contentMarginForOffset:self.proposedScrollingEndOffset fromEdge:UIRectEdgeBottom]<0){
        edge = UIRectEdgeBottom;
    }
    else if([self contentMarginForOffset:self.proposedScrollingEndOffset fromEdge:UIRectEdgeRight]<0) {
        edge= UIRectEdgeRight;
    }
    else if ([self contentMarginForOffset:self.proposedScrollingEndOffset fromEdge:UIRectEdgeLeft]<0){
        edge = UIRectEdgeLeft;
    }
    
    if (edge==UIRectEdgeNone) {
        return;
    }
    
    self.bouncingEdge = edge;
    
    [self.scrollDelegate scrollViewWillBounce:self toEdge:edge];
}

- (void)scrollViewPanGestureHandler:(UIPanGestureRecognizer *)sender {
    
    _lastKnownTrackingPoint = [sender locationInView:sender.view];
}

#pragma mark - Getters

-(CGPoint)maxOffset {
    
   return CGPointMake(self.scrollView.contentSize.width-CGRectGetWidth(self.scrollView.frame),self.scrollView.contentSize.height-CGRectGetHeight(self.scrollView.frame));
}

#pragma mark - Public

-(CGFloat)contentMarginForOffset:(CGPoint)point fromEdge:(UIRectEdge)edge {
    
    switch (edge) {
        case UIRectEdgeTop:
            return point.y-self.scrollView.contentInset.top;
        case UIRectEdgeBottom:
            return (self.scrollView.contentSize.height - (point.y + CGRectGetHeight(self.scrollView.frame))) + self.scrollView.contentInset.bottom;
        case UIRectEdgeLeft:
            return point.x-self.scrollView.contentInset.left;
        case UIRectEdgeRight:
            return (self.scrollView.contentSize.width - (point.x + CGRectGetWidth(self.scrollView.frame))) + self.scrollView.contentInset.bottom;
        default:
            break;
    }
    return 0;
}

- (void)setContentOffset:(CGPoint)offset animated:(BOOL)animated complete:(void (^)(void))complete {
 
    if (CGPointEqualToPoint(self.scrollView.contentOffset,offset)) {
        complete();
        return;
    }
    
    self.scrollAnimationCompleteBlock = complete;
    self.isAnimating = YES;
    [self.scrollView setContentOffset:offset animated:animated];
}

- (void)scrollRectToVisible:(CGRect)rect animated:(BOOL)animated complete:(void (^)(void))complete {
    
    self.scrollAnimationCompleteBlock = complete;
    self.isAnimating = YES;
    [self.scrollView scrollRectToVisible:rect animated:animated];
}

#pragma mark  - Scroll View Delegate 

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    self.scrollingToVerticalEdge = (self.lastContentOffset.y != scrollView.contentOffset.y) ? ( (self.lastContentOffset.y<scrollView.contentOffset.y) ? UIRectEdgeBottom : UIRectEdgeTop ) : UIRectEdgeNone;
    self.scrollingToHorizontalEdge = (self.lastContentOffset.x != scrollView.contentOffset.x) ? ( (self.lastContentOffset.x<scrollView.contentOffset.x) ? UIRectEdgeLeft : UIRectEdgeRight ) : UIRectEdgeNone;

    
    self.lastContentOffset  = scrollView.contentOffset;
    
    [self sendScroll:scrollView messageIfNeeded:_cmd];

}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
    self.isScrolling = YES;
    [self sendScroll:scrollView messageIfNeeded:_cmd];
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    
    if ([self.scrollDelegate respondsToSelector:@selector(scrollViewWillEndDragging:withVelocity:targetContentOffset:)]) {
        [self.scrollDelegate scrollViewWillEndDragging:scrollView withVelocity:velocity targetContentOffset:targetContentOffset];
    }

    self.proposedScrollingEndOffset = CGPointMake(targetContentOffset->x,targetContentOffset->y);

    
    if ([self.scrollDelegate respondsToSelector:@selector(scrollViewWillScroll:toOffset:)]) {
        [self.scrollDelegate scrollViewWillScroll:self toOffset:self.proposedScrollingEndOffset];
    }
    
    
    CGPoint offset = CGPointZero;
    offset.x = targetContentOffset->x;
    offset.y = targetContentOffset->y;
    self.expectedScrollingEndOffset = offset;
    
    
    [self informDelegateOfBounceEventIfNeeded];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    
    self.isScrolling = decelerate;
    [self sendScroll:scrollView messageIfNeeded:_cmd];

    if (!decelerate) {
        [self informDelegeateOfScrollingToContentEdgeIfNeededWillScroll:NO];
    }

}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {

    [self sendScroll:scrollView messageIfNeeded:_cmd];
    
    [self informDelegeateOfScrollingToContentEdgeIfNeededWillScroll:YES];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {

    
    // check before setting scrollingIvar
    if (self.bouncingEdge != UIRectEdgeNone) {
        if ([self.scrollDelegate respondsToSelector:@selector(scrollViewDidBounce:fromEdge:)]) {
            [self.scrollDelegate scrollViewDidBounce:self fromEdge:self.bouncingEdge];
        }
    }
    
    self.isScrolling = NO;
    [self sendScroll:scrollView messageIfNeeded:_cmd];
    
    [self informDelegeateOfScrollingToContentEdgeIfNeededWillScroll:NO];
    
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {

    
    self.isScrolling = NO;
    self.isAnimating = NO;
    
    if (self.scrollAnimationCompleteBlock) {
        self.scrollAnimationCompleteBlock();
        self.scrollAnimationCompleteBlock = nil;
    }
    
    [self sendScroll:scrollView messageIfNeeded:_cmd];
}

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView {
    
    if ([self.scrollDelegate respondsToSelector:@selector(scrollViewShouldScrollToTop:)]) {
        return [self.scrollDelegate scrollViewShouldScrollToTop:scrollView];
    }
    
    return YES; // UIKit default
}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView {
    
    [self sendScroll:scrollView messageIfNeeded:_cmd];
}

#pragma mark - Zooming

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    
    if ([self.scrollDelegate respondsToSelector:@selector(viewForZoomingInScrollView:)]) {
        return [self.scrollDelegate viewForZoomingInScrollView:scrollView];
    }
    return nil;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    
    [self sendScroll:scrollView messageIfNeeded:_cmd];
    
    if (self.zoomingBeganScale == scrollView.minimumZoomScale && scrollView.zoomScale<scrollView.minimumZoomScale) {
        
        if([self.scrollDelegate respondsToSelector:@selector(scrollViewDidZoomPastMinimumScale:)])
            [self.scrollDelegate scrollViewDidZoomPastMinimumScale:self];
    }
    else if(self.zoomingBeganScale == scrollView.maximumZoomScale && scrollView.zoomScale>scrollView.maximumZoomScale) {

        if ([self.scrollDelegate respondsToSelector:@selector(scrollViewDidZoomPastMaximumScale:)]) {
            [self.scrollDelegate scrollViewDidZoomPastMaximumScale:self];
        }
    }
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view {

    self.zoomingBeganScale = scrollView.zoomScale;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
    
    [self sendScroll:scrollView messageIfNeeded:_cmd];
}

#pragma mark - Description

- (NSString *)description {

    return [NSString stringWithFormat:@"%@ isScrolling : %@ scrollingBeganOffset: %@ expectedScrollingEndOffst: %@ scrollingEndedOffset : %@ scrollingToHorizontalEdge: %@ scrollingToVerticalEdge: %@",
                                      NSStringFromClass([self class]),
                                      [NSNumber numberWithBool:self.isScrolling],
                                       NSStringFromCGPoint(self.scrollingBeganOffset),
                                       NSStringFromCGPoint(self.expectedScrollingEndOffset),
                                       NSStringFromCGPoint(self.scrollingEndedOffset),KCC_NSStringFromUIRectEdge(self.scrollingToHorizontalEdge),KCC_NSStringFromUIRectEdge(self.scrollingToVerticalEdge)];
}

@end

NSString* KCC_NSStringFromUIRectEdge(UIRectEdge edge) {
    
    switch (edge) {
        case UIRectEdgeLeft:
            return @"Left";
        case UIRectEdgeRight:
            return @"Right";
        case UIRectEdgeBottom:
            return @"Bottom";
        case UIRectEdgeTop:
            return @"Top";
        case UIRectEdgeAll:
            return @"All";
        case UIRectEdgeNone:
            return @"None";
    }
}
