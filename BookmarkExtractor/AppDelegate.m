//
//  AppDelegate.m
//  BookmarkExtractor
//
//  Created by Lucas Goss on 1/28/12.
//  Copyright (c) 2012 Waterbolt. All rights reserved.
//

#import "AppDelegate.h"
#import "BookData.h"

@interface AppDelegate()

@property (nonatomic,retain) NSMutableArray* books;
@property (nonatomic,retain) NSMutableDictionary* booksFound;
@property (nonatomic,retain) NSMutableArray* bookmarks;

-(NSString*)textForBookKey:(NSString*)key;

@end

@implementation AppDelegate

@synthesize window = _window;
@synthesize booksTextField = _booksTextField;
@synthesize booksDataTextField = _booksDataTextField;
@synthesize highlightsCheckbox = _highlightsCheckbox;
@synthesize contextCheckbox = _contextCheckbox;
@synthesize annotationsCheckBox = _annotationsCheckBox;
@synthesize bookmarkTextView = _bookmarkTextView;
@synthesize booksTableView = _booksTableView;
@synthesize extractProgress = _extractProgress;

@synthesize books;
@synthesize booksFound;
@synthesize bookmarks;

//=============================================================================
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	[_booksTextField becomeFirstResponder];
}

-(BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
	return YES;
}

-(IBAction)getBooksFile:(id)sender
{
	NSOpenPanel* openPanel = [NSOpenPanel openPanel];
	
	[openPanel setCanChooseFiles:YES];
	
	if([openPanel runModal] == NSOKButton)
	{
		NSURL* url = [openPanel URL];
		[_booksTextField setStringValue:[url path]];
	}
}

-(IBAction)getBooksDataFile:(id)sender
{
	NSOpenPanel* openPanel = [NSOpenPanel openPanel];
	
	[openPanel setCanChooseFiles:YES];
	
	if([openPanel runModal] == NSOKButton)
	{
		NSURL* url = [openPanel URL];
		[_booksDataTextField setStringValue:[url path]];
	}
}

-(void)setupBooks
{
	books = nil;
	booksFound = nil;
	books = [[NSMutableArray alloc] initWithCapacity:10];
	booksFound = [[NSMutableDictionary alloc] initWithCapacity:10];
	
	if([_booksTextField.stringValue isEqualToString:@""]) return;
	
	NSMutableDictionary* dict = [NSMutableDictionary
		dictionaryWithContentsOfFile:_booksTextField.stringValue
	];
	
	NSArray* keys = [dict allKeys];
	
	for(NSString* key in keys)
	{
		if([key isEqualToString:@"Books"])
		{
			NSArray* objs = [dict objectForKey:key];
			
			for(NSDictionary* bObj in objs)
			{
				BookData* book = [[BookData alloc] init];
				book.packageHash = [bObj objectForKey:@"Package Hash"];
				book.name = [bObj objectForKey:@"Name"];
				
				if(book.packageHash != nil && book.name != nil)
				{
					[books addObject:book];
					[booksFound setValue:book.name forKey:book.packageHash];
				}
			}
		}
	}	
}

-(IBAction)runExtractor:(id)sender
{
	[_extractProgress setHidden:NO];
	[_extractProgress startAnimation:self];
	
	[_booksTableView setDataSource:nil];
	[_bookmarkTextView setString:@""];
	[_bookmarkTextView setNeedsDisplay:YES];
	
	[self setupBooks];
	
	bookmarks = nil;
	bookmarks = [[NSMutableArray alloc] initWithCapacity:10];
	
	NSMutableDictionary* dict = [NSMutableDictionary
		dictionaryWithContentsOfFile:_booksDataTextField.stringValue
	];
	
	NSArray* keys = [dict allKeys];
	for(NSString* key in keys)
	{
		NSDictionary* dictSub1 = [dict objectForKey:key];
		NSArray* keysSub1 = [dictSub1 allKeys];
		
		for(NSString* key1 in keysSub1)
		{
			if([key1 isEqualToString:@"BKBookmark"])
			{
				bookmarks = [dictSub1 objectForKey:key1];
				
				for(NSDictionary* dObj in bookmarks)
				{
					if([dObj objectForKey:@"bookDatabaseKey"] != nil)
					{
						NSString* bdk = [dObj objectForKey:@"bookDatabaseKey"];
						
						if([booksFound objectForKey:bdk] == nil)
						{
							BookData* book = [[BookData alloc] init];
							book.packageHash = bdk;
							book.name = [NSString stringWithFormat:@"Unknown: %@", book.packageHash];
							[books addObject:book];
							[booksFound setValue:book.name forKey:bdk];
						}
					}
				}
			}
		}
	}
	
	// Remove books that don't have any bookmarks
	keys = nil;
	keys = [booksFound allKeys];
	
	for(NSString* bk in keys)
	{
		NSString* text = [self textForBookKey:bk];
		
		if([text isEqualToString:@""])
		{
			int i = 0;
			
			for(; i < [books count]; i++)
			{
				BookData* bd = [books objectAtIndex:i];
				
				if(bd.packageHash == bk)
					break;
			}
			
			[books removeObjectAtIndex:i];
		}
	}
	
	[_booksTextField setStringValue:@""];
	[_booksDataTextField setStringValue:@""];
	
	[_booksTableView setDataSource:self];
	[_booksTableView setNeedsDisplay];
	
	[_extractProgress stopAnimation:self];
	[_extractProgress setHidden:YES];
}

-(NSString*)textForBookKey:(NSString*)key
{
	NSString* text = @"";
	
	for(NSDictionary* dObj in bookmarks)
	{
		NSString* dkObj = nil;
		
		if([dObj objectForKey:@"bookDatabaseKey"] != nil)
		{
			dkObj = [dObj objectForKey:@"bookDatabaseKey"];
		}
		
		if(dkObj == nil || ![dkObj isEqualToString:key])
			continue;
		
		BOOL showObj = NO;
		NSString* objText = @"";
		NSString* objContext = @"";
		NSString* objAnnotation = @"";
		
		if([dObj objectForKey:@"text"] != nil)
		{
			objText = [dObj objectForKey:@"text"];
			showObj = YES;
		}
		
		if([dObj objectForKey:@"textualContext"] != nil)
		{
			objContext = [dObj objectForKey:@"textualContext"];
			showObj = YES;
		}
		
		if([dObj objectForKey:@"annotation"] != nil)
		{
			objAnnotation = [dObj objectForKey:@"annotation"];
			showObj = YES;
		}
		
		if(showObj)
		{
			if([_highlightsCheckbox state] == NSOnState)
			{
				text = [text stringByAppendingString:
					[NSString stringWithFormat:@"%@\n\n", objText]
				];
			}
			
			if([_contextCheckbox state] == NSOnState)
			{
				text = [text stringByAppendingString:
					[NSString stringWithFormat:@"-%@-\n\n", objContext]
				];
			}
			
			if([_annotationsCheckBox state] == NSOnState)
			{
				text = [text stringByAppendingString:
					[NSString stringWithFormat:@"*%@*\n\n", objAnnotation]
				];
			}
			
			NSString* endLine = @"========================================\n\n";
			text = [text stringByAppendingString:endLine];
		}
	}
	
	return text;
}

-(void)updateBookmarksForBookKey:(NSString*)key
{
	[_bookmarkTextView setString:[self textForBookKey:key]];
	[_bookmarkTextView setNeedsDisplay:YES];
}

-(void)updateBookmarksTextView
{
	NSInteger row = [_booksTableView selectedRow];
	
	if(row > -1)
	{
		BookData* book = (BookData*)[books objectAtIndex:row];
		[self updateBookmarksForBookKey:book.packageHash];
	}
}

-(IBAction)highlightsToggle:(id)sender
{
	[self updateBookmarksTextView];
}

-(IBAction)contextToggle:(id)sender
{
	[self updateBookmarksTextView];
}

-(IBAction)annotationToggle:(id)sender
{
	[self updateBookmarksTextView];
}

#pragma mark TableView

-(void)tableViewSelectionDidChange:(NSNotification *)notification
{
	[self updateBookmarksTextView];
}

#pragma mark TableViewDataSource

-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
	return [books count];
}

-(id)tableView:(NSTableView *)tableView
	objectValueForTableColumn:(NSTableColumn *)tableColumn
	row:(NSInteger)row
{
	BookData* book = (BookData*)[books objectAtIndex:row];
	return book.name;
}

@end
