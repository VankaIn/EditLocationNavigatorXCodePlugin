//
//  NSObject_Extension.m
//  EditLocator
//
//  Created by LevinYan on 15/11/4.
//  Copyright © 2015年 LevinYan. All rights reserved.
//


#import "NSObject_Extension.h"
#import "EditLocator.h"

@implementation NSObject (Xcode_Plugin_Template_Extension)

+ (void)pluginDidLoad:(NSBundle *)plugin
{
    static dispatch_once_t onceToken;
    NSString *currentApplicationName = [[NSBundle mainBundle] infoDictionary][@"CFBundleName"];
    if ([currentApplicationName isEqual:@"Xcode"]) {
        dispatch_once(&onceToken, ^{
            sharedPlugin = [[EditLocator alloc] initWithBundle:plugin];
        });
    }
}
@end
