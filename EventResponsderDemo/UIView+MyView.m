//
//  UIView+MyView.m
//  EventResponsderDemo
//
//  Created by Jobs on 16/2/25.
//  Copyright © 2016年 Jobs. All rights reserved.
//

#import "UIView+MyView.h"
#import <objc/runtime.h>

#ifdef DEBUG
#define NSLog(FORMAT, ...) fprintf(stderr,"%s\n",[[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);
#else
#define NSLog(...)
#endif

@implementation UIView (MyView)

+ (void)load{
    Method origin = class_getInstanceMethod([UIView class], @selector(touchesBegan:withEvent:));
    Method custom = class_getInstanceMethod([UIView class], @selector(lxd_touchesBegan:withEvent:));
    method_exchangeImplementations(origin, custom);

    origin = class_getInstanceMethod([UIView class], @selector(touchesMoved:withEvent:));
    custom = class_getInstanceMethod([UIView class], @selector(lxd_touchesMoved:withEvent:));
    method_exchangeImplementations(origin, custom);

    origin = class_getInstanceMethod([UIView class], @selector(touchesEnded:withEvent:));
    custom = class_getInstanceMethod([UIView class], @selector(lxd_touchesEnded:withEvent:));
    method_exchangeImplementations(origin, custom);
}

- (void)lxd_touchesBegan: (NSSet<UITouch *> *)touches withEvent: (UIEvent *)event
{
    NSLog(@"%@ --- begin", self.class);
    [self lxd_touchesBegan: touches withEvent: event];
}

- (void)lxd_touchesMoved: (NSSet<UITouch *> *)touches withEvent: (UIEvent *)event
{
    NSLog(@"%@ --- move", self.class);
    [self lxd_touchesMoved: touches withEvent: event];
}

- (void)lxd_touchesEnded: (NSSet<UITouch *> *)touches withEvent: (UIEvent *)event
{
    NSLog(@"%@ --- end", self.class);
    [self lxd_touchesEnded: touches withEvent: event];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UIResponder * next = [self nextResponder];
    NSMutableString * prefix = @"".mutableCopy;
    
    while (next != nil) {
        NSLog(@"%@%@", prefix, [next class]);
        [prefix appendString: @"--"];
        next = [next nextResponder];
    }
}
- (nullable UIView *)hitTest:(CGPoint)point withEvent:(nullable UIEvent *)event;{
    UIView *touchView = self;
    if ([self pointInside:point withEvent:event]) {
        for (UIView *subView in self.subviews) {
            //注意，这里有坐标转换，将point点转换到subview中，好好理解下
            CGPoint subPoint = CGPointMake(point.x - subView.frame.origin.x,
                                           point.y - subView.frame.origin.y);
            UIView *subTouchView = [subView hitTest:subPoint withEvent:event];
            if (subTouchView) {
                //找到touch事件对应的view，停止遍历
                NSLog(@"hit view: %@",[touchView class]);
                touchView = subTouchView;
                break;
            }
        }
    }else{
        //此点不在该View中，那么连遍历也省了，直接返回nil
        NSLog(@"hit view: %@",[touchView class]);
        touchView = nil;
    }
    return touchView;
}
- (BOOL)pointInside:(CGPoint)point withEvent:(nullable UIEvent *)event;{
    if ( CGRectContainsPoint(self.bounds, point) ){
        NSLog(@"%@ can answer",[self class]);
        return YES;
    }else {
        NSLog(@"%@ can`t answer ",[self class]);
        return NO;
    }
}

@end
