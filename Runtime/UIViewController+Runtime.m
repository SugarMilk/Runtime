//
//  UIViewController+AutoLog.m
//  Runtime
//
//  Created by N年後 on 2017/6/8.
//  Copyright © 2017年 TRZX. All rights reserved.
//

#import "UIViewController+Runtime.h"
#import <objc/runtime.h>

void Swizzle(Class c, SEL orig, SEL new) {

    Method origMethod = class_getInstanceMethod(c, orig);
    Method newMethod = class_getInstanceMethod(c, new);
    // 1.添加方法
    if(class_addMethod(c, orig, method_getImplementation(newMethod), method_getTypeEncoding(newMethod)))

        class_replaceMethod(c, new, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));// 2.添加成功 替换方法
    else
        method_exchangeImplementations(origMethod, newMethod);// 3.交换方法
}


@implementation UIViewController (Runtime)


/**
 当程序加载到内存中的时候调用
 */
+(void)load{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Swizzle([UIViewController class], @selector(viewWillAppear:), @selector(newViewWillAppear:));
        Swizzle([UIViewController class], @selector(viewWillDisappear:), @selector(newViewWillDisappear:));
     });
}

-(void)printSender: (id)sender{
    NSLog(@"sender :  => %@", NSStringFromClass([sender class]));
}

-(void)newViewWillAppear: (BOOL) animated{
    NSLog(@"%@", NSStringFromClass([self class]));
    // 注意:这里是用了方法交换,不会调用自己
    [self newViewWillAppear:animated];
}
-(void)newViewWillDisappear: (BOOL) animated{
    // 注意:这里是用了方法交换,不会调用自己
    [self newViewWillDisappear:animated];
}
@end
