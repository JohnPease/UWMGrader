//
//  grade.h
//  UWMGrader
//
//  Created by John Pease on 3/26/14.
//  Copyright (c) 2014 John Pease. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Score;

@interface Grade : NSObject

@property NSString* name;
@property NSString* score;
@property NSString* weightAchieved;
@property NSString* feedback;


- (id)init;
- (id)initWithName:(NSString*)name;

@end
