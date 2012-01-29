//
//  AppDelegate.h
//  BookmarkExtractor
//
//  Created by Lucas Goss on 1/28/12.
//  Copyright (c) 2012 Waterbolt. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <
	NSApplicationDelegate,
	NSTableViewDelegate,
	NSTableViewDataSource
>

@property (assign) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSTextField *booksTextField;
@property (weak) IBOutlet NSTextField *booksDataTextField;
@property (weak) IBOutlet NSButton *highlightsCheckbox;
@property (weak) IBOutlet NSButton *contextCheckbox;
@property (weak) IBOutlet NSButton *annotationsCheckBox;
@property (unsafe_unretained) IBOutlet NSTextView *bookmarkTextView;
@property (weak) IBOutlet NSTableView *booksTableView;
@property (weak) IBOutlet NSProgressIndicator *extractProgress;

-(IBAction)getBooksFile:(id)sender;
-(IBAction)getBooksDataFile:(id)sender;
-(IBAction)runExtractor:(id)sender;

-(IBAction)highlightsToggle:(id)sender;
-(IBAction)contextToggle:(id)sender;
-(IBAction)annotationToggle:(id)sender;

@end
