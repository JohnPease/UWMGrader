//
//  Parser.h
//  UWMGrader
//
//  Created by John Pease on 4/22/14.
//  Copyright (c) 2014 John Pease. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Parser : NSObject

- (id)init;

- (NSArray*)getCoursesFrom:(NSString*)HTML;
- (NSArray*)getGradeSectionsFrom:(NSString*)HTML;

@end
