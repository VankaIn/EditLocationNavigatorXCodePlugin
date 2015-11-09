//
//  NSObject_Extension.m
//  EditLocationNavigatorXCodePlugin
//
//  Created by LevinYan on 15/11/9.
//  Copyright © 2015年 LevinYan. All rights reserved.
//


#import "NSObject_Extension.h"
#import "EditLocationNavigatorXCodePlugin.h"

@implementation NSObject (Xcode_Plugin_Template_Extension)

+ (void)pluginDidLoad:(NSBundle *)plugin
{
    static dispatch_once_t onceToken;
    NSString *currentApplicationName = [[NSBundle mainBundle] infoDictionary][@"CFBundleName"];
    if ([currentApplicationName isEqual:@"Xcode"]) {
        dispatch_once(&onceToken, ^{
            sharedPlugin = [[EditLocationNavigatorXCodePlugin alloc] initWithBundle:plugin];
        });
    }
}
@end
