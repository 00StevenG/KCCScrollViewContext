//
//  DemoTextViewController.m
//  ScrollViewContext
//
//
//  Created by Steven Grace on 6/15/15.
//  Copyright (c) 2015 Steven Grace. All rights reserved.
//


#import "DemoTextViewController.h"
#import "KCCScrollViewContext.h"

@interface DemoTextViewController () <KCCScrollViewContextDelegate>

@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (strong, nonatomic, readwrite)KCCScrollViewContext *scrollContext;

@property (strong, nonatomic, readwrite) UIFont *font;
@property (assign, nonatomic, readwrite) NSRange redRange;


@end

@implementation DemoTextViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.font = self.textView.font;
    
    self.scrollContext = [[KCCScrollViewContext alloc]initWithScrollView:self.textView andDelegate:self];
}

#pragma mark - UIScrollViewDelegate 

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
    NSLog(@"%s",__PRETTY_FUNCTION__);
    
    if (self.redRange.length==0) {
        return;
    }
    
    // reset text to black
    [self.textView.textStorage beginEditing];
    [self.textView.textStorage setAttributes:@{NSForegroundColorAttributeName:[UIColor blackColor],NSFontAttributeName:self.font} range:self.redRange];
    [self.textView.textStorage endEditing];
}

#pragma mark - KCCScrollViewContextDelegate

- (void)scrollViewWillScroll:(KCCScrollViewContext *)context toContentEdge:(UIRectEdge)edge {
    NSLog(@"%s : %@",__PRETTY_FUNCTION__,KCC_NSStringFromUIRectEdge(edge));    
}

- (void)scrollViewDidScroll:(KCCScrollViewContext *)context toContentEdge:(UIRectEdge)edge {
    NSLog(@"%s : %@",__PRETTY_FUNCTION__,KCC_NSStringFromUIRectEdge(edge));
}

- (void)scrollViewWillBounce:(KCCScrollViewContext*)context toEdge:(UIRectEdge)edge{
    NSLog(@"%s : %@",__PRETTY_FUNCTION__,KCC_NSStringFromUIRectEdge(edge));
}

- (void)scrollViewDidBounce:(KCCScrollViewContext*)context fromEdge:(UIRectEdge)edge{
    NSLog(@"%s : %@",__PRETTY_FUNCTION__,KCC_NSStringFromUIRectEdge(edge));
}

- (void)scrollViewWillScroll:(KCCScrollViewContext *)context toOffset:(CGPoint)offset {
    
    NSLog(@"%s :%@",__PRETTY_FUNCTION__,NSStringFromCGPoint(offset));
    
    CGPoint adjustedOffset = offset;
    adjustedOffset.y = offset.y +[self.view convertPoint:self.scrollContext.lastKnownTrackingPoint fromView:self.textView].y;
    
    CGFloat points = 0;
    NSUInteger charIndex  =
    [self.textView.layoutManager characterIndexForPoint:adjustedOffset inTextContainer:self.textView.textContainer fractionOfDistanceBetweenInsertionPoints:&points];
    
    __block NSRange lineRange = NSMakeRange(0,0);
    
    [self.textView.attributedText.string enumerateSubstringsInRange:NSMakeRange(0,[self.textView.attributedText length]) options:NSStringEnumerationBySentences usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
        
        if (NSIntersectionRange(substringRange,NSMakeRange(charIndex,1)).length>0) {
            
            lineRange = substringRange;
            *stop = YES;
        }
        
    }];

    if (lineRange.length==0) {
        return;
    }
    
    self.redRange = lineRange;
    
    // set the range to Red
    [self.textView.textStorage beginEditing];
    [self.textView.textStorage setAttributes:@{NSForegroundColorAttributeName:[UIColor redColor],NSFontAttributeName:self.font} range:self.redRange];
    [self.textView.textStorage endEditing];
}
@end
