//
//  UIControl+Runtime.m
//  Runtime
//
//  Created by N年後 on 2017/6/8.
//  Copyright © 2017年 TRZX. All rights reserved.
//

#import "UIControl+TouchEvent.h"
#import <objc/runtime.h>

// 每一个关联的关键字必须是唯一的。通常都是会采用静态变量来作为关键字
static const char *UIControl_acceptEventInterval = "UIControl_acceptEventInterval";

@implementation UIControl (TouchEvent)

//  实现文件中通过runtime的关联对象的方式添加属性
- (NSTimeInterval)acceptEventInterval
{
    return [objc_getAssociatedObject(self, UIControl_acceptEventInterval) doubleValue];
}

- (void)setAcceptEventInterval:(NSTimeInterval)acceptEventInterval
{
    objc_setAssociatedObject(self, UIControl_acceptEventInterval, @(acceptEventInterval), OBJC_ASSOCIATION_RETAIN_NONATOMIC); // 强引用关联
}

- (BOOL)my_ignoreEvent
{
    return [objc_getAssociatedObject(self, UIControl_acceptEventInterval) doubleValue];
}

// 交换系统方法
+ (void)load
{
    Method a = class_getInstanceMethod(self, @selector(sendAction:to:forEvent:));
    Method b = class_getInstanceMethod(self, @selector(my_sendAction:to:froEvent:));

    method_exchangeImplementations(a, b);
}

- (void)my_sendAction:(SEL)action to:(id)target froEvent:(UIEvent *)event
{
    if (self.acceptEventInterval > 0) {
        if (self.userInteractionEnabled) {

            [self my_sendAction:action to:target froEvent:event];
        }
        // 关闭用户交互
        self.userInteractionEnabled = NO;

        // GCD 延迟执行 self.acceptEventInterval：为延迟时间
        __weak typeof (self) weakSelf = self;
        dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.acceptEventInterval * NSEC_PER_SEC));

        // 开启用户交互
        dispatch_after(delayTime, dispatch_get_main_queue(), ^{
            weakSelf.userInteractionEnabled = YES;
        });

    } else {
        [self my_sendAction:action to:target froEvent:event];
    }

}

@end
