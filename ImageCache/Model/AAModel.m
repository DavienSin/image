//
//  AAStorage.m
//  ImageCache
//
//  Created by Davien Sin on 2022/12/14.
//

#import "AAModel.h"

@implementation AAModel

/**
 支持加密编码
 */
+ (BOOL)supportsSecureCoding{
    return YES;
}

-(instancetype)init{
    self = [super init];
    if(self){
        _imageData = nil;
        
    }
    return self;
}

// 编码
- (void)encodeWithCoder:(NSCoder *)aCoder{
    
    [aCoder encodeObject:_imageData forKey:@"imageData"];
}
 
// 解码
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    if (self) {
        _imageData = [aDecoder decodeObjectForKey:@"imageData"];
    }
    return self;
}
@end
