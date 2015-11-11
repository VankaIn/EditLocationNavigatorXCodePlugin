//
//  ELModel.h
//  EditLocator
//
//  Created by LevinYan on 15/11/5.
//  Copyright © 2015年 LevinYan. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

typedef NS_ENUM(NSUInteger, EL_Orient)
{
    EL_OrientForward = 0,
    EL_OrientBack,
};


@interface IDESourceTextView : NSObject
- (NSUInteger)_currentLineNumber;
@end


@interface ELEditItem : NSObject

@property (nonatomic, strong) NSString *filePath;
@property (nonatomic, assign) NSUInteger line;

- (instancetype)initWithFilePath:(NSString*)filePath line:(NSUInteger)line;

@end


@interface ELModel : NSObject


+ (NSDocument*)currentSourceCodeDocument;

- (void)openItem:(ELEditItem*)item;

- (void)addEditItem:(ELEditItem*)item;

- (void)moveToLastEdit;

- (ELEditItem*)getHistoryEditItem:(EL_Orient)orient;

- (BOOL)validateMenuItem:(EL_Orient)orient;

@end

