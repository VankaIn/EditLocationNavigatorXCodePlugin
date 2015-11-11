//
//  ELModel.m
//  EditLocator
//
//  Created by LevinYan on 15/11/5.
//  Copyright © 2015年 LevinYan. All rights reserved.
//

#import "ELModel.h"


#import "ELModel.h"
#import <objc/runtime.h>





@interface IDEStructureNavigator : NSObject
@property (retain) NSArray* selectedObjects;
@end
@interface IDENavigableItemCoordinator : NSObject
- (id)structureNavigableItemForDocumentURL:(id)arg1 inWorkspace:(id)arg2 error:(id*)arg3;
@end

@interface IDENavigatorArea : NSObject
@property NSArrayController* extensionsController;
- (id)currentNavigator;
@end

@interface IDEWorkspaceTabController : NSObject
@property (readonly) IDENavigatorArea* navigatorArea;
@property (readonly) IDEWorkspaceTabController* structureEditWorkspaceTabController;
@end

@interface IDEDocumentController : NSDocumentController
+ (IDEDocumentController*)sharedDocumentController;
+ (id)editorDocumentForNavigableItem:(id)arg1;
+ (id)retainedEditorDocumentForNavigableItem:(id)arg1 error:(id*)arg2;
+ (void)releaseEditorDocument:(id)arg1;
@end

@interface IDESourceCodeDocument : NSDocument
- (NSUndoManager*)undoManager;
@end

@interface IDESourceCodeComparisonEditor : NSObject
@property (readonly) NSTextView* keyTextView;
@property (retain) NSDocument* primaryDocument;
@end

@interface IDESourceCodeEditor : NSObject
@property (retain) NSTextView* textView;
- (IDESourceCodeDocument*)sourceCodeDocument;
@end

@interface IDEEditorContext : NSObject
- (id)editor; // returns the current editor. If the editor is the code editor, the class is `IDESourceCodeEditor`
@end

@interface IDEEditorArea : NSObject
- (IDEEditorContext*)lastActiveEditorContext;
@end

@interface IDEConsoleArea : NSObject
- (IDEEditorContext*)lastActiveEditorContext;
@end



@interface IDEWorkspaceWindowController : NSObject
@property (readonly) IDEWorkspaceTabController* activeWorkspaceTabController;
- (IDEEditorArea*)editorArea;
@end



@interface IDEWorkspaceDocument : NSDocument
@end



@implementation ELEditItem

- (instancetype)initWithFilePath:(NSString*)filePath line:(NSUInteger)line
{
    self = [super init];
    if(self){
        _filePath = filePath;
        _line = line;
    }
    return self;
}

@end

static NSBundle* pluginBundle;
static const NSUInteger kDefaultHistoryMax = 100;

@interface ELModel()

@property (nonatomic, strong) NSMutableArray *historyEditItem;
@property (nonatomic, assign) NSUInteger index;

@end



@implementation ELModel

- (instancetype)init
{
    self = [super init];
    if(self)
    {
        _historyEditItem = [NSMutableArray array];
    }
    return self;
}

+ (IDEWorkspaceWindowController*)currentWorkspaceWindowController
{
    NSWindowController* currentWindowController = [[NSApp mainWindow] windowController];
    if ([currentWindowController isKindOfClass:NSClassFromString(@"IDEWorkspaceWindowController")]) {
        return (IDEWorkspaceWindowController*)currentWindowController;
    }
    return  nil;
}

+ (id)currentEditor
{
    IDEWorkspaceWindowController *workspaceController = [ELModel currentWorkspaceWindowController];
    if(workspaceController){
        IDEEditorArea* editorArea = [workspaceController editorArea];
        IDEEditorContext* editorContext = [editorArea lastActiveEditorContext];
        return [editorContext editor];
    }
    return nil;
}
+ (IDEWorkspaceDocument*)currentWorkspaceDocument
{
    NSWindowController* currentWindowController =
    [[NSApp mainWindow] windowController];
    id document = [currentWindowController document];
    if (currentWindowController &&
        [document isKindOfClass:NSClassFromString(@"IDEWorkspaceDocument")]) {
        return (IDEWorkspaceDocument*)document;
    }
    return nil;
}

+ (IDESourceCodeDocument*)currentSourceCodeDocument
{
    
    IDESourceCodeEditor* editor = [self currentEditor];
    
    if ([editor isKindOfClass:NSClassFromString(@"IDESourceCodeEditor")]) {
        return editor.sourceCodeDocument;
    }
    
    if ([editor
         isKindOfClass:NSClassFromString(@"IDESourceCodeComparisonEditor")]) {
        if ([[(IDESourceCodeComparisonEditor*)editor primaryDocument]
             isKindOfClass:NSClassFromString(@"IDESourceCodeDocument")]) {
            return (id)[(IDESourceCodeComparisonEditor*)editor primaryDocument];
        }
    }
    
    return nil;
}






- (void)highlightItem:(ELEditItem*)item inTextView:(NSTextView*)textView
{
    NSUInteger lineNumber = item.line - 1;
    NSString* text = [textView string];
    
    NSRegularExpression* re =
    [NSRegularExpression regularExpressionWithPattern:@"\n"
                                              options:0
                                                error:nil];
    
    NSArray* result = [re matchesInString:text
                                  options:NSMatchingReportCompletion
                                    range:NSMakeRange(0, text.length)];
    
    if (result.count <= lineNumber) {
        return;
    }
    
    NSUInteger location = 0;
    NSTextCheckingResult* aim = result[lineNumber];
    location = aim.range.location;
    NSRange range = [text lineRangeForRange:NSMakeRange(location, 0)];
    range.length = 0;
    
    
    [textView scrollRangeToVisible:range];
    [textView setSelectedRange:range];
}

- (void)openItem:(ELEditItem*)item
{
    
    NSWindowController* currentWindowController =
    [[NSApp mainWindow] windowController];
    
    
    if ([currentWindowController
         isKindOfClass:NSClassFromString(@"IDEWorkspaceWindowController")]) {
        
        id<NSApplicationDelegate> appDelegate = (id<NSApplicationDelegate>)[NSApp delegate];
        if ([appDelegate application:NSApp openFile:item.filePath]) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                IDESourceCodeEditor* editor = [ELModel currentEditor];
                if ([editor isKindOfClass:NSClassFromString(@"IDESourceCodeEditor")]) {
                    NSTextView* textView = editor.textView;
                    if (textView) {
                        [self highlightItem:item inTextView:textView];
                        
                    }
                }
                
            });
            
            
        }
        return;
    }
    
    // open the file
    BOOL result = [[NSWorkspace sharedWorkspace] openFile:item.filePath
                                          withApplication:@"Xcode"];
    
    // open the line
    if (result) {
        
        // pretty slow to open file with applescript
        
        NSString* theSource = [NSString
                               stringWithFormat:
                               @"do shell script \"xed --line %ld \" & quoted form of \"%@\"",
                               item.line, item.filePath];
        NSAppleScript* theScript = [[NSAppleScript alloc] initWithSource:theSource];
        [theScript performSelectorInBackground:@selector(executeAndReturnError:)
                                    withObject:nil];
        
    }
    
}





- (void)moveToLastEdit
{
    self.index = self.historyEditItem.count;
}

- (void)addEditItem:(ELEditItem *)item
{
    ELEditItem *lastEdit = self.historyEditItem.lastObject;
    if(lastEdit){
        if(![lastEdit.filePath isEqualToString:item.filePath] || lastEdit.line != item.line){
            [self _addEditItem:item];
        }
    }else{
        [self _addEditItem:item];
    }
    
    
}


- (void)_addEditItem:(ELEditItem*)item
{
    [self.historyEditItem addObject:item];
    if(self.historyEditItem.count > kDefaultHistoryMax)
        [self.historyEditItem removeObjectAtIndex:0];
    
    self.index = self.historyEditItem.count - 1;
}
- (ELEditItem*)getHistoryEditItem:(EL_Orient)orient
{
    ELEditItem *item = nil;
    if(orient == EL_OrientForward){
        self.index++;
        item = self.historyEditItem[self.index];
    }else if(orient == EL_OrientBack){
        self.index--;
        item = self.historyEditItem[self.index];
    }
    
    return item;
}
- (BOOL)validateMenuItem:(EL_Orient)orient
{
    if(self.historyEditItem.count == 0)
        return NO;
    
    if(orient == EL_OrientForward){
        if(self.index < (self.historyEditItem.count - 1))
            return YES;
        else
            return NO;
    }else if(orient == EL_OrientBack){
        if(self.index > 0)
            return YES;
        else
            return NO;
    }
    
    return NO;
}


@end
