//
//  course.h
//  UWMGrader
//
//  Created by John Pease on 3/26/14.
//  Copyright (c) 2014 John Pease. All rights reserved.
//

#import <Foundation/Foundation.h>
@class gradeSection;

@interface Course : NSObject

@property NSString* name;
@property NSString* college;
@property NSString* year;
@property NSMutableArray* gradeSections;
@property NSString* url;

- (id)initWithName:(NSString*)name;

- (void)addGradeSection:(gradeSection*)gradeSection;

@end
