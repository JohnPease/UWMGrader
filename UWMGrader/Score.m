//
//  Score.m
//  UWMGrader
//
//  Created by John Pease on 3/27/14.
//  Copyright (c) 2014 John Pease. All rights reserved.
//

#import "Score.h"

@implementation Score

- (id)init {
	return [self initWithNumerator:0 denominator:0];
}

- (id)initWithNumerator:(double)numerator denominator:(double)denominator {
	self = [super init];
	if (self) {
		_numerator = numerator;
		_denominator = denominator;
	}
	return self;
}

@end
