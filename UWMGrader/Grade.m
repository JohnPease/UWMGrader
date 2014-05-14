//
//  grade.m
//  UWMGrader
//
//  Created by John Pease on 3/26/14.
//  Copyright (c) 2014 John Pease. All rights reserved.
//

#import "Grade.h"

@implementation Grade

- (id)init {
	return [self initWithName:@"empty"];
}

- (id)initWithName:(NSString *)name {
	self = [super init];
	if (self) {
		_name = name;
	}
	return self;
}


- (double)getPoints {
	if ([self.score isEqualToString:@"Not provided"]) {
		return -1.0;
	}
	NSArray* split = [[self.score stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] componentsSeparatedByString:@"/"];
	if ([[split objectAtIndex:0] isEqualToString:@"-"]) {
		return -1.0;
	} else {
		return [[split objectAtIndex:0] doubleValue];
	}
}

- (double)getMax {
	if ([self.score isEqualToString:@"Not provided"]) {
		return -1.0;
	}
	NSArray* split = [[self.score stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] componentsSeparatedByString:@"/"];
	if ([[split objectAtIndex:1] isEqualToString:@"-"]) {
		return -1.0;
	} else {
		return [[split objectAtIndex:1] doubleValue];
	}
}

@end
