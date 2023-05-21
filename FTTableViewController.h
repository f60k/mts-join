//
//  FTTableViewController.h
//  MTSJoin
//
//  Created by 柳 大介 on 2013/02/04.
//  Copyright (c) 2013年 HERGO INC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FTTableViewController : NSObject <NSTableViewDataSource, NSTableViewDelegate>
{
    NSMutableArray *_dataList;
    
    NSTableView *_tableView;
    NSButton *_goupButton;
    NSButton *_godownButton;
    NSButton *_removeButton;
    NSToolbarItem *_mergeItem;
}

@property(nonatomic,retain) IBOutlet NSTableView *tableView;
@property(nonatomic,retain) IBOutlet NSButton *goupButton;
@property(nonatomic,retain) IBOutlet NSButton *godownButton;
@property(nonatomic,retain) IBOutlet NSButton *removeButton;


@property (nonatomic,retain)IBOutlet NSToolbarItem *mergeItem;



@property(nonatomic,retain) NSMutableArray *dataList;

- (void)reloadSubviews;
- (IBAction)goUpFile:(id)sender;
- (IBAction)goDownFile:(id)sender;
- (IBAction)removeFile:(id)sender;
- (IBAction)mergeFiles:(id)sender;

- (IBAction)clearAllFiles:(id)sender;

- (IBAction)onSelectOpen:(id)sender;

@end
