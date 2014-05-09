//
//  Parser.m
//  UWMGrader
//
//  Created by John Pease on 4/22/14.
//  Copyright (c) 2014 John Pease. All rights reserved.
//

#import "Parser.h"
#import "Course.h"
#import "GradeSection.h"
#import "Grade.h"

@implementation Parser

- (id)init {
	self = [super init];
	if (self) {
		//nothing to do here
	}
	return self;
}

/**
 *  Returns an array of course objects containing names and urls
 *
 *  @param HTML the HTML from the webview that will be parsed
 *
 *  @return an array of course objects parsed from HTML
 */
- (NSMutableArray*)getCoursesFrom:(NSString*)HTML {
	NSMutableArray* courses = [[NSMutableArray alloc] init];
	
	NSRange courseLineStart = [HTML rangeOfString:@"<li class=\"d2l-itemlist-simple d2l-itemlist-arrow d2l-itemlist-short\">"];
	NSRange coursesEnd = [HTML rangeOfString:@"<li class=\"d2l-itemlist-loadmore"];
	while (courseLineStart.length != 0) {
		NSRange courseLineEnd = [HTML rangeOfString:@"</span><div class=\"d2l-clear\"></div>" options:NSLiteralSearch range:NSMakeRange(courseLineStart.location, courseLineStart.location+1)];
		if (courseLineEnd.location == NSNotFound) break; /* FIX THIS ASAP */
		NSRange liRange = NSMakeRange(courseLineStart.location, (courseLineEnd.location	- courseLineStart.location));
		NSString* wholeLine = [HTML substringWithRange:liRange];
		if ([wholeLine rangeOfString:@"ended on 5/"].location == NSNotFound) break;
		
		/* get js link */
		NSRange jsStart = [HTML rangeOfString:@"onclick=\"" options:NSLiteralSearch range:NSMakeRange(courseLineStart.location, courseLineStart.location+1)];
		NSRange jsEnd = [HTML rangeOfString:@"><div class=\"d2l-itemlist-nowrap\">" options:NSLiteralSearch range:NSMakeRange(jsStart.location, jsStart.location)];
		NSRange jsRange = NSMakeRange(jsStart.location+9, (jsEnd.location - jsStart.location - 10));
		NSString* js = [HTML substringWithRange:jsRange];
		
		/* get class name */
		NSRange courseNameStart = [HTML rangeOfString:@"d2l-itemlist-title\">" options:NSLiteralSearch range:NSMakeRange(jsEnd.location, jsEnd.location+1)];
		NSRange courseNameEnd = [HTML rangeOfString:@"<" options:NSLiteralSearch range:NSMakeRange(courseNameStart.location+20, courseLineEnd.location - courseNameStart.location)];
		NSRange courseNameRange = NSMakeRange(courseNameStart.location+20, (courseNameEnd.location - courseNameStart.location - 20));
		NSString* courseName = [HTML substringWithRange:courseNameRange];
		
		/* create course object and add it to array */
		Course* course = [[Course alloc] initWithName:courseName];
		course.url = [js stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\""];
		[courses addObject:course];
		
		courseLineStart = [HTML rangeOfString:@"<li class=\"d2l-itemlist-simple d2l-itemlist-arrow d2l-itemlist-short\">" options:NSLiteralSearch range:NSMakeRange(courseLineEnd.location, HTML.length - coursesEnd.location - courseLineEnd.location)];
	}
	return courses;
}

/**
 *  Gets array of gradesection objects
 *
 *  @param HTML the HTML from the webview that will be parsed
 *
 *  @return an array of gradesection objects parsed from HTML
 */
- (NSMutableArray*)getGradeSectionsFrom:(NSString*)HTML {
//	NSLog(@"%@", HTML);
	NSMutableArray* gradeSections = [[NSMutableArray alloc] init];
	
	int gradeSectionCount = [self numberOfOccurrencesOf:@"<th scope=\"row\"  colspan=\"2\" class=\"d_gt d_ich\" style=\"border-left:none;\"><div class=\"dco\"><div class=\"dco_c\"><div class=\"dco\"><div class=\"dco_c\"><strong>" in:HTML];
	
	if (gradeSectionCount == 0) return [self getGradesFrom:HTML];
	
	NSRange gradeSectionStart = NSMakeRange(0, 0);
	for (int i = 0; i <	 gradeSectionCount; ++i) {
		
		if (gradeSectionStart.length == 0 && gradeSectionStart.length == 0) {
			/* first run through */
			gradeSectionStart = [HTML rangeOfString:@"<th scope=\"row\"  colspan=\"2\" class=\"d_gt d_ich\" style=\"border-left:none;\"><div class=\"dco\"><div class=\"dco_c\"><div class=\"dco\"><div class=\"dco_c\">" options:NSLiteralSearch range:NSMakeRange(1, HTML.length-1)];
		} else {
			/* nth run through */
			gradeSectionStart = [HTML rangeOfString:@"<th scope=\"row\"  colspan=\"2\" class=\"d_gt d_ich\" style=\"border-left:none;\"><div class=\"dco\"><div class=\"dco_c\"><div class=\"dco\"><div class=\"dco_c\">" options:NSLiteralSearch range:NSMakeRange(gradeSectionStart.location+1, HTML.length - gradeSectionStart.location-1)];
		}
		
		NSRange gradeSectionEnd = [HTML rangeOfString:@"<th scope=\"row\"  colspan=\"2\" class=\"d_gt d_ich\" style=\"border-left:none;\"><div class=\"dco\"><div class=\"dco_c\"><div class=\"dco\"><div class=\"dco_c\">" options:NSLiteralSearch range:NSMakeRange(gradeSectionStart.location+1, HTML.length - gradeSectionStart.location-1)];
		
		/* get grade section name */
		NSRange gradeSectionNameStart	= [HTML rangeOfString:@"<strong>" options:NSLiteralSearch range:NSMakeRange(gradeSectionStart.location, HTML.length - gradeSectionStart.location)];
		NSRange gradeSectionNameEnd		= [HTML rangeOfString:@"</strong>" options:NSLiteralSearch range:NSMakeRange(gradeSectionNameStart.location, HTML.length - gradeSectionNameStart.location)];
		NSRange gradeSectionNameRange	= NSMakeRange(gradeSectionNameStart.location+8, gradeSectionNameEnd.location-gradeSectionNameStart.location-8);
		NSString* gradeSectionName		= [HTML substringWithRange:gradeSectionNameRange];
		
		NSRange gradeStart = [HTML rangeOfString:@"<th scope=\"row\"" options:NSLiteralSearch range:NSMakeRange(gradeSectionNameEnd.location, HTML.length - gradeSectionNameEnd.location)];
		
		NSString* gradeSectionWeight;
		if (gradeStart.location != NSNotFound) {
			
			/* get weight */
			NSRange gradeSectionWeightStart = [HTML rangeOfString:@"<label id=\"z_" options:NSLiteralSearch range:NSMakeRange(gradeSectionNameEnd.location, gradeStart.location - gradeSectionNameEnd.location)];
			NSRange gradeSectionWeightEnd = gradeSectionNameEnd;
			if (gradeSectionWeightStart.location != NSNotFound) {
				gradeSectionWeightStart = [HTML rangeOfString:@">" options:NSLiteralSearch range:NSMakeRange(gradeSectionWeightStart.location, gradeStart.location - gradeSectionWeightStart.location)];
				gradeSectionWeightEnd = [HTML rangeOfString:@"<" options:NSLiteralSearch range:NSMakeRange(gradeSectionWeightStart.location, gradeStart.location - gradeSectionWeightStart.location)];
				NSRange gradeSectionWeightRange = NSMakeRange(gradeSectionWeightStart.location+1, gradeSectionWeightEnd.location-gradeSectionWeightStart.location-1);
				gradeSectionWeight = [HTML substringWithRange:gradeSectionWeightRange];
			}
		}
		
		/* get grade section score! */
		
		GradeSection* gradeSection = [[GradeSection alloc] initWithName:gradeSectionName];
		gradeSection.weightAchieved = gradeSectionWeight;
		
		NSLog(@"section name: %@, weight: %@", gradeSectionName, gradeSectionWeight);
		
		
		
		while (gradeStart.location != NSNotFound && gradeStart.location < gradeSectionEnd.location) {
			NSRange gradeEnd		= [HTML rangeOfString:@"</tr>" options:NSLiteralSearch range:NSMakeRange(gradeStart.location, HTML.length - gradeStart.location)];
			
			/* get grade name */
			NSRange gradeNameStart	= [HTML rangeOfString:@"<strong>" options:NSLiteralSearch range:NSMakeRange(gradeStart.location, gradeEnd.location - gradeStart.location)];
			NSRange gradeNameEnd	= [HTML rangeOfString:@"</strong>" options:NSLiteralSearch range:NSMakeRange(gradeNameStart.location, gradeEnd.location - gradeNameStart.location)];
			NSRange gradeNameRange	= NSMakeRange(gradeNameStart.location+8, gradeNameEnd.location-gradeNameStart.location-8);
			NSString* gradeName		= [HTML substringWithRange:gradeNameRange];
			
			/* get grade value */
			NSRange gradeValueStart = [HTML rangeOfString:@"<label id=\"z_" options:NSLiteralSearch range:NSMakeRange(gradeNameEnd.location, gradeEnd.location - gradeNameEnd.location)];
			NSRange gradeValueEnd = gradeNameEnd;
			NSString* gradeValue = @"Not provided";
			if (gradeValueStart.location != NSNotFound) {
				gradeValueStart			= [HTML rangeOfString:@">" options:NSLiteralSearch range:NSMakeRange(gradeValueStart.location, gradeEnd.location - gradeValueStart.location)];
				gradeValueEnd	= [HTML rangeOfString:@"<" options:NSLiteralSearch range:NSMakeRange(gradeValueStart.location, gradeEnd.location - gradeValueStart.location)];
				NSRange gradeValueRange = NSMakeRange(gradeValueStart.location+1, gradeValueEnd.location-gradeValueStart.location-1);
				gradeValue				= [HTML substringWithRange:gradeValueRange];
			}
			
			/* get weight */
			NSRange gradeWeightStart = [HTML rangeOfString:@"<label id=\"z_" options:NSLiteralSearch range:NSMakeRange(gradeValueEnd.location, gradeEnd.location - gradeValueEnd.location)];
			NSRange gradeWeightEnd = gradeNameEnd;
			NSString* gradeWeight;
			if (gradeWeightStart.location != NSNotFound) {
				gradeWeightStart = [HTML rangeOfString:@">" options:NSLiteralSearch range:NSMakeRange(gradeWeightStart.location, gradeEnd.location - gradeWeightStart.location)];
				gradeWeightEnd = [HTML rangeOfString:@"<" options:NSLiteralSearch range:NSMakeRange(gradeWeightStart.location, gradeEnd.location - gradeWeightStart.location)];
				NSRange gradeWeightRange = NSMakeRange(gradeWeightStart.location+1, gradeWeightEnd.location-gradeWeightStart.location-1);
				gradeWeight = [HTML substringWithRange:gradeWeightRange];
			}
			
			/* handle dropped grades */
			if ([gradeWeight isEqualToString:@"0 / 0"]) {
				gradeWeight = @"Dropped!";
			}
			
			/* get feedback */
			NSRange gradeFeedbackStart = [HTML rangeOfString:@"Individual Feedback" options:NSLiteralSearch range:NSMakeRange(gradeWeightEnd.location, gradeEnd.location - gradeWeightEnd.location)];
			NSRange gradeFeedbackEnd = gradeNameEnd;
			NSString* gradeFeedback;
			if (gradeFeedbackStart.location != NSNotFound) {
				gradeFeedbackStart = [HTML rangeOfString:@"<p>" options:NSLiteralSearch range:NSMakeRange(gradeFeedbackStart.location, gradeEnd.location - gradeFeedbackStart.location)];
				gradeFeedbackEnd = [HTML rangeOfString:@"</p>" options:NSLiteralSearch range:NSMakeRange(gradeFeedbackStart.location, gradeEnd.location - gradeFeedbackStart.location)];
				NSRange gradeFeedbackRange = NSMakeRange(gradeFeedbackStart.location+3, gradeFeedbackEnd.location-gradeFeedbackStart.location-3);
				gradeFeedback = [HTML substringWithRange:gradeFeedbackRange];
			}
			
			NSLog(@"\tgrade name: %@, grade value: %@, grade weight: %@", gradeName, gradeValue, gradeWeight);
			
			/* create grade object and add it to gradesection */
			Grade* grade = [[Grade alloc] initWithName:gradeName];
			grade.score = gradeValue;
			grade.gradeSection = gradeSectionName;
			grade.weightAchieved = gradeWeight;
			grade.feedback = gradeFeedback;
			[gradeSection.grades addObject:grade];
			
			gradeStart = [HTML rangeOfString:@"<th scope=\"row\"" options:NSLiteralSearch range:NSMakeRange(gradeEnd.location, HTML.length-gradeEnd.location)];
		}
		[gradeSections addObject:gradeSection];
	}
	return gradeSections;
}

/**
 *  Returns 1 grade section with all of the grades
 *
 *  @param HTML the HTML from the webview that will be parsed
 *
 *  @return an array of gradesection objects
 */
- (NSMutableArray*)getGradesFrom:(NSString*)HTML {
//	NSLog(@"%@", HTML);
	NSMutableArray* grades = [[NSMutableArray alloc] init];
	GradeSection* gradeSection = [[GradeSection alloc] initWithName:@"Grades"];
	
	NSRange gradeStart = [HTML rangeOfString:@"<th scope=\"row\"  class=\"d_gt d_ich\"><div class=\"dco\"><div class=\"dco_c\"><div class=\"dco\"><div class=\"dco_c\"><strong>"];
	
	while (gradeStart.location != NSNotFound) {
		NSRange gradeEnd = [HTML rangeOfString:@"</tr>" options:NSLiteralSearch range:NSMakeRange(gradeStart.location, HTML.length - gradeStart.location)];
		
		/* get grade name */
		NSRange gradeNameEnd = [HTML rangeOfString:@"</strong>" options:NSLiteralSearch range:NSMakeRange(gradeStart.location, gradeEnd.location - gradeStart.location)];
		NSRange gradeNameRange = NSMakeRange(gradeStart.location+116, gradeNameEnd.location-gradeStart.location-116);
		NSString* gradeName = [HTML substringWithRange:gradeNameRange];
		
		/* get grade value */
		NSRange gradeValueStart = [HTML rangeOfString:@"<label id=\"z_" options:NSLiteralSearch range:NSMakeRange(gradeNameEnd.location, gradeEnd.location - gradeNameEnd.location)];
		NSRange gradeValueEnd = gradeNameEnd;
		NSString* gradeValue = @"Not provided";
		if (gradeValueStart.location != NSNotFound) {
			gradeValueStart = [HTML rangeOfString:@">" options:NSLiteralSearch range:NSMakeRange(gradeValueStart.location, gradeEnd.location - gradeValueStart.location)];
			gradeValueEnd = [HTML rangeOfString:@"</label>" options:NSLiteralSearch range:NSMakeRange(gradeValueStart.location, gradeEnd.location - gradeValueStart.location)];
			NSRange gradeValueRange = NSMakeRange(gradeValueStart.location+1, gradeValueEnd.location-gradeValueStart.location-1);
			gradeValue = [HTML substringWithRange:gradeValueRange];
		}
		
		/* get grade weight */
		NSRange gradeWeightStart = [HTML rangeOfString:@"<label id=\"z_" options:NSLiteralSearch range:NSMakeRange(gradeValueEnd.location, gradeEnd.location - gradeValueEnd.location)];
		NSRange gradeWeightEnd = gradeNameEnd;
		NSString* gradeWeight;
		if (gradeWeightStart.location != NSNotFound) {
			gradeWeightStart = [HTML rangeOfString:@">" options:NSLiteralSearch range:NSMakeRange(gradeWeightStart.location, gradeEnd.location - gradeWeightEnd.location)];
			gradeWeightEnd = [HTML rangeOfString:@"</label>" options:NSLiteralSearch range:NSMakeRange(gradeWeightStart.location, gradeEnd.location - gradeWeightStart.location)];
			NSRange gradeWeightRange = NSMakeRange(gradeWeightStart.location+1, gradeWeightEnd.location-gradeWeightStart.location-1);
			gradeWeight = [HTML substringWithRange:gradeWeightRange];
		}
		
		/* handle dropped grades */
		if ([gradeWeight isEqualToString:@"0 / 0"]) {
			gradeWeight = @"Dropped!";
		}
		
		NSLog(@"grade name: %@, grade value: %@, grade weight: %@", gradeName, gradeValue, gradeWeight);
		
		/* create grade object */
		Grade* grade = [[Grade alloc] initWithName:gradeName];
		grade.score = gradeValue;
		grade.gradeSection = @"Grades";
		grade.weightAchieved = gradeWeight;
		[gradeSection.grades addObject:grade];
		
		gradeStart = [HTML rangeOfString:@"<th scope=\"row\"  class=\"d_gt d_ich\"><div class=\"dco\"><div class=\"dco_c\"><div class=\"dco\"><div class=\"dco_c\"><strong>" options:NSLiteralSearch range:NSMakeRange(gradeEnd.location, HTML.length-gradeEnd.location)];
	}
	
	[grades addObject:gradeSection];
	return grades;
}

- (NSUInteger)numberOfOccurrencesOf:(NSString*)subString in:(NSString*)string {
	NSUInteger count = 0, length = [string length];
	NSRange range = NSMakeRange(0, length);
	while(range.location != NSNotFound)
	{
		range = [string rangeOfString: subString options:0 range:range];
		if(range.location != NSNotFound)
		{
			range = NSMakeRange(range.location + range.length, length - (range.location + range.length));
			count++;
		}
	}
	
	return count;
}

@end
