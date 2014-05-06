//
//  course.m
//  UWMGrader
//
//  Created by John Pease on 3/26/14.
//  Copyright (c) 2014 John Pease. All rights reserved.
//

#import "Course.h"
#import "gradeSection.h"

@implementation Course

- (id)init {
	return [self initWithName:nil];
}

- (id)initWithName:(NSString *)name {
	self = [super init];
	if (self) {
		_name = name;
		_gradeSections = [[NSMutableArray alloc] init];
	}
	return self;
}

- (void)addGradeSection:(gradeSection *)gradeSection {
	[_gradeSections addObject:gradeSection];
}

@end
