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

@end
