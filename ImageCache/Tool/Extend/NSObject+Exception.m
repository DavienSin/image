//
//  NSObject+Exception.m
//  da
//
//  Created by Davien Sin on 2022/11/13.
//

#import "NSObject+Exception.h"
#import <objc/runtime.h>

@implementation NSObject(Exception)

//首次加载类时触发
+ (void)load{
    //保证在app生命周期内方法只被交换一次
    static dispatch_once_t once;
    dispatch_once(&once, ^{
       
        
       
      //  NSLog(@"%@",[self sele])
    });
}










@end
