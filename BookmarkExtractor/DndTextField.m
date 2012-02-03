//
//  DndTextField.m
//  BookmarkExtractor
//
//  Created by Lucas Goss on 1/29/12.
//  Copyright (c) 2012 Waterbolt. All rights reserved.
//

#import "DndTextField.h"

@implementation DndTextField

-(void)awakeFromNib
{
	[super awakeFromNib];
	
	[self registerForDraggedTypes:[NSArray arrayWithObject:NSURLPboardType]];
}

-(NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender
{
	[self becomeFirstResponder];
	
	return [super draggingEntered:sender];
}

@end
