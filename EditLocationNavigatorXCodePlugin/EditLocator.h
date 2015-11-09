//
//  EditLocator.h
//  EditLocator
//
//  Created by LevinYan on 15/11/4.
//  Copyright © 2015年 LevinYan. All rights reserved.
//

#import <AppKit/AppKit.h>


@class EditLocator;

static EditLocator *sharedPlugin;

@interface EditLocator : NSObject

+ (instancetype)sharedPlugin;
- (id)initWithBundle:(NSBundle *)plugin;

@property (nonatomic, strong, readonly) NSBundle* bundle;
@end