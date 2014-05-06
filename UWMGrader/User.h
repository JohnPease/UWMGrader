//
//  user.h
//  UWMGrader
//
//  Created by John Pease on 3/27/14.
//  Copyright (c) 2014 John Pease. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Course;

@interface User : NSObject

@property NSString* usermame;
@property NSString* password; //figure out better way to save password
@property NSMutableArray* courses;

- (id)init;
- (id)initWithUsername:(NSString*)userName Password:(NSString*)password;
- (void)addCourse:(Course*)course;

@end
