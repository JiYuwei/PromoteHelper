//
//  NSObject+PropertyListing.m
//  PromoteHelper
//
//  Created by 纪宇伟 on 15/11/25.
//  Copyright © 2015年 willing. All rights reserved.
//

#import "NSObject+PropertyListing.h"
#import <objc/runtime.h>

@implementation NSObject (PropertyListing)

- (NSDictionary *)properties_aps
{
    NSMutableDictionary *props = [NSMutableDictionary dictionary];
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList([self class], &outCount);
    for (i = 0; i<outCount; i++)
    {
        objc_property_t property = properties[i];
        const char* char_f =property_getName(property);
        NSString *propertyName = [NSString stringWithUTF8String:char_f];
        id propertyValue = [self valueForKey:(NSString *)propertyName];
        if (propertyValue) [props setObject:propertyValue forKey:propertyName];
    }
    free(properties);
    return props;
}

@end
