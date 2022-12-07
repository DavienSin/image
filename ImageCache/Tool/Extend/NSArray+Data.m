//
//  NSObject.m
//  ImageCache
//
//  Created by Davien Sin on 2022/12/4.
//

#import "NSArray+Data.h"

@implementation NSArray(Data)

+(instancetype)arrayInCount:(NSInteger)count fill:(id)object{
    NSMutableArray *arr = [NSMutableArray arrayWithCapacity:count];
    for (NSInteger i = 0 ; i < count; i++) {
        [arr addObject:object];
    }
    return arr;
}




@end
