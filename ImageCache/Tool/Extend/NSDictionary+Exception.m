//
//  NSDictionary.m
//  da
//
//  Created by Davien Sin on 2022/11/15.
//

#import "NSDictionary+Exception.h"
#import <objc/runtime.h>

@implementation NSDictionary(Expection)

+ (void)load{
    static  dispatch_once_t once;
    dispatch_once(&once, ^{
        // 对valueForKey方法进行异常处理
        Method func1 = class_getInstanceMethod(self, @selector(valueForKey:));
        Method func2 = class_getInstanceMethod(self, @selector(valueForKeyWithNilCheck:));
        method_exchangeImplementations(func1, func2);
    });
}


/// 对空值进行异常处理，避免运行崩溃
/// - Parameter key: key
-(id)valueForKeyWithNilCheck:(NSString *)key{
    if([key isEqualToString:@""]){
        return @"key is nil";
    }else{
        if([self isKindOfClass:[NSString class]] || [self isKindOfClass:[NSMutableString class]] || [self isKindOfClass:[NSData class]] || [self isKindOfClass:[NSMutableSet class]]){
            return [NSString stringWithFormat:@"%@ hasn't valueForKey Method",[self class]];
        }else{
            return [self valueForKeyWithNilCheck:key];
        }
    }
}

@end
