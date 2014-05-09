//
//  gradeSection.h
//  UWMGrader
//
//  Created by John Pease on 3/27/14.
//  Copyright (c) 2014 John Pease. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Score;

@interface GradeSection : NSObject

@property NSString* name;
@property NSString* points;
@property NSString* weightAchieved;
@property NSMutableArray* grades;

- (id)initWithName:(NSString*)name;

@end
