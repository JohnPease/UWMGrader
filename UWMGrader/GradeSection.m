//
//  gradeSection.m
//  UWMGrader
//
//  Created by John Pease on 3/27/14.
//  Copyright (c) 2014 John Pease. All rights reserved.
//

#import "GradeSection.h"

@implementation GradeSection

- (id)init {
	return [self initWithName:@"CS"];
}

- (id)initWithName:(NSString *)name {
	self = [super init];
	if (self) {
		_name = name;
		_grades = [[NSMutableArray alloc] init];
	}
	return self;
}

@end
