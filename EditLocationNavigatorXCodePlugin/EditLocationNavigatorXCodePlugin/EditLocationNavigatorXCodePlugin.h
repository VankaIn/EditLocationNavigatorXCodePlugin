//
//  EditLocationNavigatorXCodePlugin.h
//  EditLocationNavigatorXCodePlugin
//
//  Created by LevinYan on 15/11/9.
//  Copyright © 2015年 LevinYan. All rights reserved.
//

#import <AppKit/AppKit.h>

@class EditLocationNavigatorXCodePlugin;

static EditLocationNavigatorXCodePlugin *sharedPlugin;

@interface EditLocationNavigatorXCodePlugin : NSObject

+ (instancetype)sharedPlugin;
- (id)initWithBundle:(NSBundle *)plugin;

@property (nonatomic, strong, readonly) NSBundle* bundle;
@end