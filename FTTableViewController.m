//
//  FTTableViewController.m
//  MTSJoin
//
//  Created by 柳 大介 on 2013/02/04.
//  Copyright (c) 2013年 HERGO INC. All rights reserved.
//

#import "FTTableViewController.h"
#import "FTAppDelegate.h"
#import "NSMutableArray+move.h"

#define MTSDataRowType @"aa"
#define MTSARROWED_TYPES [NSArray arrayWithObjects:@"mts",@"MTS",nil]

@implementation FTTableViewController

@synthesize dataList = _dataList;
@synthesize mergeItem = _mergeItem;
@synthesize godownButton = _godownButton;
@synthesize goupButton = _goupButton;
@synthesize removeButton = _removeButton;
@synthesize tableView = _tableView;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        self.dataList=[[[NSMutableArray alloc] initWithCapacity:1] autorelease];
        
    }
    
    return self;
}

- (void)dealloc
{
    [super dealloc];
    
    [_dataList release], _dataList = nil;
    [_mergeItem release], _mergeItem = nil;
    [_goupButton release], _goupButton = nil;
    [_godownButton release], _godownButton = nil;
    [_removeButton release], _removeButton = nil;
    [_tableView release], _tableView = nil;
}

- (void)awakeFromNib
{
    [self.tableView registerForDraggedTypes:[NSArray arrayWithObjects:NSFilenamesPboardType,MTSDataRowType, nil]];
    [self.tableView setAllowsMultipleSelection:YES];
}

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem
{
    if ([menuItem action] == @selector(mergeFiles:))
    {
        return ([self.dataList count] > 1);
    }
    
    return YES;
}

-(BOOL)validateToolbarItem:(NSToolbarItem *)toolbarItem
{
    if ([[toolbarItem itemIdentifier] isEqual:@"MergeItemIdentifier"])
    {
        return ([self.dataList count] > 1);
    }
    
    return YES;
}

- (void)tableView:(NSTableView *)tableView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    NSTextFieldCell *aCell = (NSTextFieldCell*)cell;
    NSDictionary *info = [self.dataList objectAtIndex:row];
    aCell.textColor = [info objectForKey:@"color"];
}

- (id)tableView:(NSTableView *)aTableView
objectValueForTableColumn:(NSTableColumn *)aTableColumn
            row:(NSInteger)rowIndex
{
    
    id returnValue=nil;
    NSDictionary *line=(NSDictionary*)[self.dataList objectAtIndex:rowIndex];
    NSString *columnIdentifer = [aTableColumn identifier];
    
    
    if([columnIdentifer isEqualToString:@"no"])
    {
        
        returnValue = [NSNumber numberWithInteger:rowIndex + 1];
        
    }
    else if([columnIdentifer isEqualToString:@"file"])
    {
        NSString *path = [line objectForKey:@"file"];
        if (path)
        {
            returnValue = [[NSFileManager defaultManager] displayNameAtPath:path];
        }
        
    }
    else if([columnIdentifer isEqualToString:@"status"])
    {
        returnValue = [line objectForKey:@"status"];
    }
    return returnValue;
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return [_dataList count];
}

- (void)tableView:(NSTableView *)aTableView
   setObjectValue:(id)anObject
   forTableColumn:(NSTableColumn *)aTableColumn
              row:(NSInteger)rowIndex
{
}

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
    
    [self reloadSubviews];
    
}


- (void)reloadSubviews
{
    [self.tableView reloadData];
    
    if ([self.dataList count] < 1)
    {
        [self.godownButton setEnabled:NO];
        [self.goupButton setEnabled:NO];
        [self.removeButton setEnabled:NO];
    }

    
    NSIndexSet *set=[self.tableView selectedRowIndexes];
    
    [self.godownButton setEnabled:[set count]];
    [self.goupButton setEnabled:[set count]];
    [self.removeButton setEnabled:[set count]];
    
    
}

- (IBAction)goUpFile:(id)sender
{
    NSIndexSet *set=[self.tableView selectedRowIndexes];
    if ([set count] < 1)
    {
        return;
    }
    if ([self.dataList count] == [set count])
    {
        return;
    }
    
    if ([set containsIndex:0])
    {
        return;
    }
    
    NSUInteger index = [set firstIndex];
    NSMutableIndexSet *newSet = [NSMutableIndexSet indexSet];
    while (index != NSNotFound)
    {
        
        NSUInteger dstIndex = index-1;
        [self.dataList moveObjectFromIndex:index toIndex:dstIndex];
        [newSet addIndex:dstIndex];
        index = [set indexGreaterThanIndex: index];
    }
    
    
    [self.tableView selectRowIndexes:newSet byExtendingSelection:NO];
    
    
    [self reloadSubviews];
}

- (IBAction)goDownFile:(id)sender
{
    NSIndexSet *set=[self.tableView selectedRowIndexes];
    if ([set count] < 1)
    {
        return;
    }
    if ([self.dataList count] == [set count])
    {
        return;
    }
    
    if ([set containsIndex:[self.dataList count]-1])
    {
        return;
    }
    
    NSUInteger index = [set lastIndex];
    NSMutableIndexSet *newSet = [NSMutableIndexSet indexSet];
    
    while (index != NSNotFound)
    {
        
        NSUInteger dstIndex = index+1;
        [self.dataList moveObjectFromIndex:index toIndex:dstIndex];
        [newSet addIndex:dstIndex];
        index = [set indexLessThanIndex: index];
    }
    
    [self.tableView selectRowIndexes:newSet byExtendingSelection:NO];
    
    
    [self reloadSubviews];
}

- (IBAction)removeFile:(id)sender
{
    NSIndexSet *set=[self.tableView selectedRowIndexes];
    if ([set count] < 1)
    {
        return;
    }

    [self.dataList removeObjectsAtIndexes:set];
    
    [self reloadSubviews];
}

- (IBAction)mergeFiles:(id)sender
{
    NSSavePanel *savePanel	= [NSSavePanel savePanel];
    [savePanel setPrompt:NSLocalizedString(@"ExportPanelButton", nil)];
    [savePanel setTitle:NSLocalizedString(@"ExportPanelName", nil)];
    [savePanel setNameFieldLabel:NSLocalizedString(@"ExportPanelPathTo", nil)];
//    [savePanel setNameFieldStringValue:@"output.mts"];
    
    
    
    [savePanel setExtensionHidden:YES];
    
    
    NSArray *allowedFileTypes = MTSARROWED_TYPES;
    [savePanel setAllowedFileTypes:allowedFileTypes];
    
    NSInteger returnCode = [savePanel runModalForDirectory:NSHomeDirectory() file:@"output.mts"];
    
    [self savePanelDidEnd:savePanel returnCode:returnCode contextInfo:nil];
}

- (IBAction)clearAllFiles:(id)sender
{
    self.dataList = [[[NSMutableArray alloc] initWithCapacity:1] autorelease];
    [self reloadSubviews];
}

#pragma mark - Panel Delegate

- (void)savePanelDidEnd:(NSSavePanel *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
    if (returnCode == NSOKButton)
    {
        for (NSDictionary *info in self.dataList)
        {
            [info setValue:@"Ready" forKey:@"status"];
            [info setValue:[NSColor colorWithCalibratedWhite:0.171 alpha:1.000] forKey:@"color"];
        }
        [self reloadSubviews];
        
        NSURL * filePath = [sheet URL];
        
        FTAppDelegate *app=(FTAppDelegate*)[NSApp delegate];
        [app openSheet:nil withDataList:self.dataList filePathForOutput:[filePath path]];
        
    }
}

- (void)openPanelDidEnd:(NSOpenPanel *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
    if (returnCode == NSOKButton)
    {
        NSArray *files = [sheet URLs];
        
        files = [files valueForKeyPath:@"path"];
        
        files = [self _directoryFilteredArrayWithArray:files];
        
        files = [self _mtsTypeFilteredArrayWithArray:files];
        
        for (int i = 0; i < [files count]; i++)
        {
            NSString *path = [files objectAtIndex:i];
            [self.dataList addObject:[self _createInfoForPath:path]];
            
        }
        
        [self reloadSubviews];
        
    }
}

- (IBAction)onSelectOpen:(id)sender
{
    
    NSOpenPanel *openPanel=[NSOpenPanel openPanel];
    [openPanel setAllowsMultipleSelection:YES];
    
    //ファイルタイプ
    NSArray *allowedFileTypes = MTSARROWED_TYPES;
    [openPanel setAllowedFileTypes:allowedFileTypes];
    
    NSInteger returnCode = [openPanel runModal];
    [self openPanelDidEnd:openPanel returnCode:returnCode contextInfo:nil];
    
}

//----------

- (NSMutableDictionary*)_createInfoForPath:(NSString*)path
{
    NSMutableDictionary *info = [[@{
                           @"file": path,
                           @"status":@"Ready",
                           @"color":[NSColor colorWithCalibratedWhite:0.171 alpha:1.000]
                           } mutableCopy] autorelease];
    
    return info;
}

- (void)_replaceObject:(NSDictionary*)anObject AtRow:(NSInteger)row withSrcRow:(NSInteger)originalRow
{
    if(row < 0) row = 0;
    [self.dataList insertObject:anObject atIndex:row];
    
    if(originalRow > row)originalRow++;
    [self.dataList removeObjectAtIndex:originalRow];
    
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:row-1];
    if(originalRow > row)indexSet = [NSIndexSet indexSetWithIndex:row];
    [self.tableView selectRowIndexes:indexSet byExtendingSelection:NO];
    
}

- (NSArray*)_directoryFilteredArrayWithArray:(NSArray*)files
{
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:1];
    for (int i = 0; i < [files count]; i++)
    {
        BOOL isDir;
        NSString *path = [files objectAtIndex:i];
        if ([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir] && !isDir)
        {
            
            [result addObject:path];
            
        }
        
    }
    return result;
}

- (NSArray*)_mtsTypeFilteredArrayWithArray:(NSArray*)files
{
    NSPredicate *fltr = [NSPredicate predicateWithFormat:@"self ENDSWITH '.mts' OR self ENDSWITH '.MTS'"];
    return [files filteredArrayUsingPredicate:fltr];
}

- (BOOL)tableView:(NSTableView *)tableView acceptDrop:(id<NSDraggingInfo>)info row:(NSInteger)row dropOperation:(NSTableViewDropOperation)dropOperation
{
    NSPasteboard *pboard;
    pboard = [info draggingPasteboard];

    if ( [[pboard types] containsObject:NSFilenamesPboardType] )
    {
        NSArray *files = [pboard propertyListForType:NSFilenamesPboardType];
        
        files = [self _directoryFilteredArrayWithArray:files];
        
        files = [self _mtsTypeFilteredArrayWithArray:files];
        
        for (int i = 0; i < [files count]; i++)
        {
            NSString *path = [files objectAtIndex:i];
            [self.dataList addObject:[self _createInfoForPath:path]];
        
        }
        
        [self reloadSubviews];
    }
    else if([[pboard types] containsObject:MTSDataRowType])
    {
        
        
        
        NSInteger originalRow = [[pboard propertyListForType:@"originalRow"] integerValue];
        
        NSArray *arr = [NSKeyedUnarchiver unarchiveObjectWithData:[pboard dataForType:MTSDataRowType]];
        
        if(row < 0) row = 0;
        
        if ([arr count] == 1)
        {
            NSDictionary *anObject = [arr lastObject];
            [self _replaceObject:anObject AtRow:row withSrcRow:originalRow];
        }
        
        [self reloadSubviews];
        
    }
    return YES;
}

- (NSDragOperation)tableView:(NSTableView *)tableView validateDrop:(id<NSDraggingInfo>)info proposedRow:(NSInteger)row proposedDropOperation:(NSTableViewDropOperation)dropOperation
{
    
    [tableView setDropRow:row dropOperation:NSTableViewDropAbove];
    
    if ([info draggingSource] == tableView)
    {
        return NSDragOperationMove;
    }
    return NSDragOperationGeneric;
}

//- (NSArray*)tableView:(NSTableView *)tableView namesOfPromisedFilesDroppedAtDestination:(NSURL *)dropDestination forDraggedRowsWithIndexes:(NSIndexSet *)indexSet
//{
//    
//}

- (BOOL)tableView:(NSTableView *)tableView writeRowsWithIndexes:(NSIndexSet *)rowIndexes toPasteboard:(NSPasteboard *)pboard
{
    
    [pboard declareTypes:[NSArray arrayWithObject:MTSDataRowType] owner:self];
    //get an array of URIs for the selected objects
    NSMutableArray * rows = [NSMutableArray array];
    NSArray * selectedObjects = [self.dataList objectsAtIndexes:rowIndexes];
    for (NSDictionary *info in selectedObjects) {
        [rows addObject:info];
    }
    NSData * encodedIDs = [NSKeyedArchiver archivedDataWithRootObject:rows];
    [pboard setData:encodedIDs forType:MTSDataRowType];
    
    
    
    [pboard setPropertyList:[NSNumber numberWithInteger:[rowIndexes lastIndex]] forType:@"originalRow"];
    
    
    return YES;
}




@end
