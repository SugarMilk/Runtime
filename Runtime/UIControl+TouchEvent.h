//
//  UIControl+Runtime.h
//  Runtime
//
//  Created by N年後 on 2017/6/8.
//  Copyright © 2017年 TRZX. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIControl (TouchEvent)
/**
 设置Touch事件间隔时间
 */
@property (assign, nonatomic) NSTimeInterval acceptEventInterval;

@end
