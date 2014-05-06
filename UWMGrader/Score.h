//
//  Score.h
//  UWMGrader
//
//  Created by John Pease on 3/27/14.
//  Copyright (c) 2014 John Pease. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Score : NSObject

@property double numerator;
@property double denominator;

- (id)initWithNumerator:(double)numerator denominator:(double)denominator;

@end
