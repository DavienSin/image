//
//  NSArry+Exception.m
//  da
//
//  Created by Davien Sin on 2022/11/15.
//

#import "NSArry+Exception.h"
#import <objc/runtime.h>

@implementation NSArray(Exception)

+ (void)load{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        // 对objectAtIndex方法进行异常处理,这里func1使用get-》self无法正确获取到objectAtIndex方法,通过终端信息显示的objectAtIndexedSubscript
        Method func1 = class_getInstanceMethod(objc_getClass("NSConstantArray"),@selector(objectAtIndexedSubscript:));
        Method func2 = class_getInstanceMethod(objc_getClass("NSConstantArray"),@selector(objectAtIndexedSubscriptWithNilCheck:));
        method_exchangeImplementations(func1, func2);
    });
}

-(id)objectAtIndexedSubscriptWithNilCheck:(NSInteger)index{
    if(self.count > index){
        return [self objectAtIndexedSubscriptWithNilCheck:index];
    }else{
        return [NSString stringWithFormat:@"ObjectAt[%lu] is nil",index];
    }
}


@end
