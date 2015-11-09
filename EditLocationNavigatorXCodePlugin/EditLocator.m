//
//  EditLocator.m
//  EditLocator
//
//  Created by LevinYan on 15/11/4.
//  Copyright © 2015年 LevinYan. All rights reserved.
//

#import "EditLocator.h"
#import "ELModel.h"

static  NSString *const kGoForwardTitile = @"Go Forward";
static  NSString *const kGoBackTitle = @"Go Back";
@interface EditLocator()

@property (nonatomic, strong, readwrite) NSBundle *bundle;
@property (nonatomic, strong)  ELModel *model;
@property (nonatomic, assign) BOOL isEditing;

@end

@implementation EditLocator

+ (instancetype)sharedPlugin
{
    return sharedPlugin;
}

- (id)initWithBundle:(NSBundle *)plugin
{
    if (self = [super init]) {
        // reference to plugin's bundle, for resource access
        _bundle = plugin;
        _model = [[ELModel alloc] init];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didApplicationFinishLaunchingNotification:)
                                                     name:NSApplicationDidFinishLaunchingNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleTextDidChange:)
                                                     name:NSTextDidChangeNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleChangeLineSelection:) name:
         NSTextViewDidChangeSelectionNotification object:nil];
    }
    return self;
}

- (void)handleChangeLineSelection:(NSNotification*)notification
{
    if(notification.object && [notification.object isKindOfClass:NSClassFromString(@"DVTSourceTextView")]){
        if(self.isEditing){
            [self.model moveToLastEdit];
            self.isEditing = NO;
        }
    }
}

- (void)handleTextDidChange:(NSNotification*)notification
{
    if(notification.object && [notification.object isKindOfClass:NSClassFromString(@"DVTSourceTextView")]){
        
        IDESourceTextView *sourceTextView =  notification.object;
        NSDocument *document = [ELModel currentSourceCodeDocument];
        ELEditItem *item = [[ELEditItem alloc] initWithFilePath:document.fileURL.absoluteString line:sourceTextView._currentLineNumber];
        [self.model addEditItem:item];
        self.isEditing = YES;
    }
    
}
- (void)setMenu
{
    NSMenu *navMenu = [[[NSApp mainMenu] itemWithTitle:@"Navigate"] submenu];
    
    NSMenuItem *goForwardMenuItem = [navMenu itemWithTitle:kGoForwardTitile];
    NSMenuItem *goBackMenuItem = [navMenu itemWithTitle:kGoBackTitle];
    NSUInteger index = [navMenu indexOfItem:goForwardMenuItem];
 
    
    unichar leftArrowKey = NSLeftArrowFunctionKey;
    unichar rightArrrowKey = NSRightArrowFunctionKey;
    
    NSMenuItem *newGoForwardMenuItem = [[NSMenuItem alloc] initWithTitle:kGoForwardTitile action:@selector(goFoward) keyEquivalent:[NSString stringWithCharacters:&rightArrrowKey length:1]];
    NSMenuItem *newGoBackMenuItem = [[NSMenuItem alloc] initWithTitle:kGoBackTitle action:@selector(goBack) keyEquivalent:[NSString stringWithCharacters:&leftArrowKey length:1]];
    
    [newGoForwardMenuItem setKeyEquivalentModifierMask: NSControlKeyMask|NSCommandKeyMask];
    [newGoBackMenuItem setKeyEquivalentModifierMask: NSControlKeyMask|NSCommandKeyMask];
    
    newGoForwardMenuItem.target = self;
    newGoBackMenuItem.target = self;
    
    [navMenu insertItem:newGoForwardMenuItem atIndex:index];
    [navMenu insertItem:newGoBackMenuItem atIndex:index+1];

    [navMenu removeItem:goForwardMenuItem];
    [navMenu removeItem:goBackMenuItem];
}

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem
{
    if([menuItem.title isEqualToString:kGoForwardTitile]){
        
        return [self.model validateMenuItem:EL_OrientForward];
        
    }else if([menuItem.title isEqualToString:kGoBackTitle]){
    
        return [self.model validateMenuItem:EL_OrientBack];
    }
    return NO;
}
- (void)goFoward
{
    [ELModel openItem:[self.model getHistoryEditItem:EL_OrientForward]];
}
- (void)goBack
{
    [ELModel openItem:[self.model getHistoryEditItem:EL_OrientBack]];
}
- (void)didApplicationFinishLaunchingNotification:(NSNotification*)noti
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSApplicationDidFinishLaunchingNotification object:nil];
    [self setMenu];
}



- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
