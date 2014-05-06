//
//  user.m
//  UWMGrader
//
//  Created by John Pease on 3/27/14.
//  Copyright (c) 2014 John Pease. All rights reserved.
//

#import "User.h"

@implementation User

- (id)init {
	return [self initWithUsername:@"Brutus" Password:@"BadPassword"];
}

- (id) initWithUsername:(NSString *)userName Password:(NSString *)password {
	self = [super init];
	if (self) {
		_usermame = userName;
		_password = password;
		_courses = [[NSMutableArray alloc] init];
	}
	return self;
}

- (void)addCourse:(Course *)course {
	[_courses addObject:course];
}

@end