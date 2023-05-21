//
//  FTAppDelegate.h
//  MTSJoin
//
//  Created by 柳 大介 on 2013/02/04.
//  Copyright (c) 2013年 HERGO INC. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "FTTableViewController.h"
#import "libmts.h"

@interface FTAppDelegate : NSObject <NSApplicationDelegate>
{
    NSWindow *_window;
    FTTableViewController *_tableViewController;
    NSPanel *_modal;
    
    BOOL _cancelRequested;
    
    int _current;
    int _max;
    BOOL _running;
    
    NSString *_fileOutputPath;
    
    THREAD_JOINARG targ;
    
}

@property (assign) IBOutlet NSWindow *window;

@property (nonatomic, strong) IBOutlet FTTableViewController *tableViewController;
@property (nonatomic, strong) IBOutlet NSPanel *modal;

@property BOOL running;
@property int current;
@property int max;
@property (nonatomic, strong) NSString *fileOutputPath;

- (IBAction)stop:(id)sender;

- (void)openSheet:(id)sender withDataList:(NSArray*)dataList filePathForOutput:(NSString*)filePath;

@end
