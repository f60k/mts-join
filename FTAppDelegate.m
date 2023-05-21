//
//  FTAppDelegate.m
//  MTSJoin
//
//  Created by 柳 大介 on 2013/02/04.
//  Copyright (c) 2013年 HERGO INC. All rights reserved.
//

#import "FTAppDelegate.h"


@implementation FTAppDelegate

@synthesize modal = _modal;
@synthesize tableViewController = _tableViewController;
@synthesize window = _window;;
@synthesize running = _running;
@synthesize max = _max;
@synthesize current = _current;
@synthesize fileOutputPath = _fileOutputPath;


- (void)dealloc
{
    [super dealloc];
    
    [_fileOutputPath release], _fileOutputPath = nil;
    [_modal release], _modal = nil;
    [_tableViewController release], _tableViewController = nil;
    [_window release], _window = nil;
    
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    
}

- (void)_closeModal
{
    if (self.modal)
    {
        [NSApp endSheet:self.modal returnCode:NSCancelButton];
    }
}

- (void)_resetProps
{
    _cancelRequested = YES;
    self.running = NO;
}

- (IBAction)stop:(id)sender
{
    MTS_PutFlag(MTS_FLAG_STOP);
    [self _resetProps];
    [NSThread sleepForTimeInterval:5];
    [self _closeModal];
    
}

- (void)joinTask:(id)param
{
    NSMutableDictionary *info = nil;
    
    info = [self.tableViewController.dataList objectAtIndex:self.current];
    const char *InputFile = [[info objectForKey:@"file"] UTF8String];
    
    strcpy(targ.inFilename, InputFile);
    MTS_Join( &targ );

}

- (void)longTask:(id)param
{
    id pool = [NSAutoreleasePool new];
    
    
    memset( &targ, 0, sizeof(targ) );
    
    char *OutputFile = (char*)[self.fileOutputPath UTF8String];
    MTS_JoinOpenOutput(OutputFile);
    
    strcpy(targ.outFilename, OutputFile);
    
    int status = 0;
    int totalCount = 0;
    int counter = 0;
    
    typedef enum
    {
        FTPrcsTypeReady=0,
        FTPrcsTypeProcessing,
        FTPrcsTypeDone,
        FTPrcsTypeAllDone,
        
    }FTPrcsType;
    
    FTPrcsType processType = FTPrcsTypeReady;
    
    NSMutableDictionary *info = nil;
    
    
    
    while (self.running && !_cancelRequested)
    {
        
        switch (processType)
        {
            case FTPrcsTypeReady:
            {
//                info = [self.tableViewController.dataList objectAtIndex:self.current];
//                const char *InputFile = [[info objectForKey:@"file"] UTF8String];
//                
//                strcpy(targ.inFilename, InputFile);
//                MTS_Join( &targ );

                [NSThread detachNewThreadSelector:@selector(joinTask:) toTarget:self withObject:nil];
                [NSThread sleepForTimeInterval:.1];
                processType = FTPrcsTypeProcessing;

            
                info = [self.tableViewController.dataList objectAtIndex:self.current];
                
                [info setValue:@"Processing" forKey:@"status"];
                [info setValue:[NSColor colorWithCalibratedRed:0.117 green:0.484 blue:0.232 alpha:1.000] forKey:@"color"];

            
            }
                
                break;

            case FTPrcsTypeProcessing:
            {
                MTS_GetStatus(&status, &counter, &totalCount);
                
                if (status > 1)
                {
                    NSDictionary *errStatusTable = @{
                                                     [NSNumber numberWithInt:0x0010]: @"ERR: open source file",
                                                     [NSNumber numberWithInt:0x0020]: @"ERR: open target file",
                                                     [NSNumber numberWithInt:0x0030]: @"ERR: read source file",
                                                     [NSNumber numberWithInt:0x0040]: @"ERR: wrtie target file",
                                                     [NSNumber numberWithInt:0x0100]: @"ERR: malloc/free error",
                                                     [NSNumber numberWithInt:0x0200]: @"ERR: MTS analyz error",
                                                     [NSNumber numberWithInt:0x0400]: @"ERR: header error",
                                                     [NSNumber numberWithInt:0x0800]: @"ERR: TS Rate too high",
                                                     [NSNumber numberWithInt:0x1000]: @"ERR: TS Rate too low",
                                                     [NSNumber numberWithInt:0x2000]: @"OK (Video Rate too high)",
                                                     [NSNumber numberWithInt:0x4000]: @"OK (Video Rate too low)",
                                                     [NSNumber numberWithInt:0x8000]: @"ERR: SI/PSI",
                                                     };
                    
                    NSString *errStr = [NSString stringWithFormat:@"%@", [errStatusTable objectForKey:[NSNumber numberWithInt:status]]];
                    
                    info = [self.tableViewController.dataList objectAtIndex:self.current];
                    [info setValue:errStr forKey:@"status"];
                    [info setValue:[NSColor colorWithCalibratedRed:0.697 green:0.066 blue:0.071 alpha:1.000] forKey:@"color"];
                    
                    processType = FTPrcsTypeDone;
                    
                }
                else if(status == 1)
                {
                    
                    info = [self.tableViewController.dataList objectAtIndex:self.current];
                    
                    NSString *progressStr = [NSString stringWithFormat:@"Processing...%d%%", 100 - ((counter * 100)/ totalCount)];
                    
                    NSLog(@"(((( %d, %d ))))", counter, totalCount);
                    
                    
                    [info setValue:progressStr forKey:@"status"];
                    [info setValue:[NSColor colorWithCalibratedRed:0.169 green:0.390 blue:0.888 alpha:1.000] forKey:@"color"];
                }
                else //if(status == 0)
                {
                    [info setValue:@"OK" forKey:@"status"];
                    [info setValue:[NSColor colorWithCalibratedRed:0.117 green:0.484 blue:0.232 alpha:1.000] forKey:@"color"];
                    
                    processType = FTPrcsTypeDone;
                }
                
                
                [self.tableViewController reloadSubviews];
                [NSThread sleepForTimeInterval:.2];
                
            }
                break;
                
            case FTPrcsTypeDone:
            {
                info = [self.tableViewController.dataList objectAtIndex:self.current];
                
                /*
                [info setValue:@"UOKK" forKey:@"status"];
                [info setValue:[NSColor colorWithCalibratedRed:0.117 green:0.484 blue:0.232 alpha:1.000] forKey:@"color"];
                */
                
                
                if (_current == _max - 1)
                {
                    processType = FTPrcsTypeAllDone;
                }
                else
                {
                    self.current = _current + 1;
                    processType = FTPrcsTypeReady;
                }
                
                [self.tableViewController reloadSubviews];
            }
                break;
                
            case FTPrcsTypeAllDone:
            {
                
                self.running = NO;
                
            }
                break;
        }
        
    }
    
    if (_cancelRequested)
    {
        info = [self.tableViewController.dataList objectAtIndex:self.current];
        [info setValue:@"STOPPED" forKey:@"status"];
        [info setValue:[NSColor colorWithCalibratedRed:0.697 green:0.066 blue:0.071 alpha:1.000] forKey:@"color"];
        
    }
    
    MTS_JoinCloseOutput( );
    
    [self _closeModal];
    [self _resetProps];
    
    [self.tableViewController reloadSubviews];
    
    [pool drain];
}

- (void)openSheet:(id)sender withDataList:(NSArray*)dataList filePathForOutput:(NSString *)filePath
{
    if (!filePath)
    {
        return;
    }
    
    if (!dataList || [dataList count] < 2)
    {
        return;
    }
    
    [NSApp beginSheet:self.modal
       modalForWindow:self.window
        modalDelegate:self didEndSelector:@selector(panelDidEnd:returnCode:contextInfo:)
          contextInfo:nil];
    
    self.fileOutputPath = filePath;
    self.current = 0;
    self.max = [dataList count];
    self.running = YES;
    _cancelRequested = NO;
    [NSThread detachNewThreadSelector:@selector(longTask:) toTarget:self withObject:nil];
    
    self.current = 0;
}



- (void)panelDidEnd:(id)panel returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
	if (returnCode == NSOKButton)
    {

	}
    else
    {
        [self.modal orderOut:nil];
	}
}


// ウィンドウクローズ確認
- (BOOL)windowShouldClose:(id)sender
{
    // ウィンドウクローズでアプリケーションも終了
    [NSApp terminate:self];
    return YES;
}

@end
