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
	while (courseLineStart.length != 0) {
		NSRange courseLineEnd = [HTML rangeOfString:@"</span></div><div class=\"d2l-itemlist-nowrap\"><span class=\"d2l-itemlist-subtitle1\">" options:NSLiteralSearch range:NSMakeRange(courseLineStart.location, courseLineStart.location+1)];
		NSRange liRange = NSMakeRange(courseLineStart.location, (courseLineEnd.location	- courseLineStart.location));
		NSString* wholeLine = [HTML substringWithRange:liRange];
		if ([wholeLine rangeOfString:@"ended on"].location != NSNotFound) break;
		
		/* get js link */
		NSRange jsStart = [HTML rangeOfString:@"onclick=\"" options:NSLiteralSearch range:NSMakeRange(courseLineStart.location, courseLineStart.location+1)];
		NSRange jsEnd = [HTML rangeOfString:@"><div class=\"d2l-itemlist-nowrap\">" options:NSLiteralSearch range:NSMakeRange(jsStart.location, jsStart.location)];
		NSRange jsRange = NSMakeRange(jsStart.location+9, (jsEnd.location - jsStart.location - 10));
		NSString* js = [HTML substringWithRange:jsRange];
		
		/* get class name */
		NSRange courseNameStart = [HTML rangeOfString:@"d2l-itemlist-title\">" options:NSLiteralSearch range:NSMakeRange(jsEnd.location, jsEnd.location+1)];
		NSRange courseNameRange = NSMakeRange(courseNameStart.location+20, (courseLineEnd.location - courseNameStart.location - 20));
		NSString* courseName = [HTML substringWithRange:courseNameRange];
		
		/* create course object and add it to array */
		Course* course = [[Course alloc] initWithName:courseName];
		course.url = [js stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\""];
		[courses addObject:course];
		
		courseLineStart = [HTML rangeOfString:@"<li class=\"d2l-itemlist-simple d2l-itemlist-arrow d2l-itemlist-short\">" options:NSLiteralSearch range:NSMakeRange(courseLineEnd.location, courseLineEnd.location+1)];
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
		
		/* get grade section name */
		NSRange gradeSectionNameStart	= [HTML rangeOfString:@"<strong>" options:NSLiteralSearch range:NSMakeRange(gradeSectionStart.location, HTML.length - gradeSectionStart.location)];
		NSRange gradeSectionNameEnd		= [HTML rangeOfString:@"</strong>" options:NSLiteralSearch range:NSMakeRange(gradeSectionNameStart.location, HTML.length - gradeSectionNameStart.location)];
		NSRange gradeSectionNameRange	= NSMakeRange(gradeSectionNameStart.location+8, gradeSectionNameEnd.location-gradeSectionNameStart.location-8);
		NSString* gradeSectionName		= [HTML substringWithRange:gradeSectionNameRange];
		
		NSLog(@"grade section name: %@", gradeSectionName);
		
		/* get grade section weight? */
		
		/* get grade section score! */
		
		GradeSection* gradeSection = [[GradeSection alloc] initWithName:gradeSectionName];
		
		NSRange gradeStart = [HTML rangeOfString:@"<th scope=\"row\" class=\"d_gt d_ich\"" options:NSLiteralSearch range:NSMakeRange(gradeSectionStart.location, HTML.length - gradeSectionStart.location)];
		while (gradeStart.location != NSNotFound) {
			NSRange gradeEnd		= [HTML rangeOfString:@"</tr>" options:NSLiteralSearch range:NSMakeRange(gradeStart.location, HTML.length - gradeStart.location)];
			
			/* get grade name */
			NSRange gradeNameStart	= [HTML rangeOfString:@"<strong>" options:NSLiteralSearch range:NSMakeRange(gradeStart.location, HTML.length - gradeStart.location)];
			NSRange gradeNameEnd	= [HTML rangeOfString:@"<" options:NSLiteralSearch range:NSMakeRange(gradeNameStart.location, HTML.length - gradeNameStart.location)];
			NSRange gradeNameRange	= NSMakeRange(gradeStart.location+8, gradeNameEnd.location-gradeStart.location-8);
			NSString* gradeName		= [HTML substringWithRange:gradeNameRange];
			
			/* get grade value */
			NSRange gradeValueStart = [HTML rangeOfString:@"<label id=\"z_" options:NSLiteralSearch range:NSMakeRange(gradeStart.location, HTML.length - gradeStart.location)];
			NSString* gradeValue = @"----";
			if (gradeValueStart.location != NSNotFound) {
				gradeValueStart			= [HTML rangeOfString:@">" options:NSLiteralSearch range:NSMakeRange(gradeValueStart.location, HTML.length - gradeStart.location)];
				NSRange gradeValueEnd	= [HTML rangeOfString:@"<" options:NSLiteralSearch range:NSMakeRange(gradeValueStart.location, HTML.length - gradeValueStart.location)];
				NSRange gradeValueRange = NSMakeRange(gradeValueStart.location+1, gradeValueEnd.location-gradeValueStart.location-1);
				gradeValue				= [HTML substringWithRange:gradeValueRange];
			}
			
			/* get feedback ? */
			
			/* get weight ? */
			
			NSLog(@"grade section: %@, grade name: %@, grade value: %@", gradeSectionName, gradeName, gradeValue);
			
			/* create grade object and add it to gradesection */
			Grade* grade = [[Grade alloc] initWithName:gradeName];
			grade.score = gradeValue;
			[gradeSection.grades addObject:grade];
			
			gradeStart = [HTML rangeOfString:@"" options:NSLiteralSearch range:NSMakeRange(gradeEnd.location, HTML.length-gradeEnd.location)];
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
	NSMutableArray* grades = [[NSMutableArray alloc] init];
	GradeSection* gradeSection = [[GradeSection alloc] initWithName:@"Grades"];
	
	NSRange gradeStart = [HTML rangeOfString:@"<th scope=\"row\"  class=\"d_gt d_ich\"><div class=\"dco\"><div class=\"dco_c\"><div class=\"dco\"><div class=\"dco_c\"><strong>"];
	NSLog(@"start.location = %i, start.length = %i, html.length = %i", gradeStart.location, gradeStart.length, HTML.length);
	while (gradeStart.location != NSNotFound) {
		NSRange gradeEnd = [HTML rangeOfString:@"</div></div></div></div>" options:NSLiteralSearch range:NSMakeRange(gradeStart.location, HTML.length - gradeStart.location)];
		
		/* get grade name */
		NSRange gradeNameEnd = [HTML rangeOfString:@"</strong>" options:NSLiteralSearch range:NSMakeRange(gradeStart.location, HTML.length - gradeStart.location)];
		NSRange gradeNameRange = NSMakeRange(gradeStart.location+116, gradeNameEnd.location-gradeStart.location-116);
		NSString* gradeName = [HTML substringWithRange:gradeNameRange];
		
		/* get grade value */
		NSRange gradeValueStart = [HTML rangeOfString:@"<label id=\"z_" options:NSLiteralSearch range:NSMakeRange(gradeStart.location, HTML.length - gradeStart.location)];
		NSString* gradeValue = @"----";
		if (gradeValueStart.location != NSNotFound) {
			gradeValueStart = [HTML rangeOfString:@">" options:NSLiteralSearch range:NSMakeRange(gradeValueStart.location, HTML.length - gradeValueStart.location)];
			NSRange gradeValueEnd = [HTML rangeOfString:@"</label>" options:NSLiteralSearch range:NSMakeRange(gradeValueStart.location, HTML.length - gradeValueStart.location)];
			NSRange gradeValueRange = NSMakeRange(gradeValueStart.location+1, gradeValueEnd.location-gradeValueStart.location-1);
			gradeValue = [HTML substringWithRange:gradeValueRange];
		}
		
		NSLog(@"grade name: %@, grade value: %@", gradeName, gradeValue);
		
		/* create grade object */
		Grade* grade = [[Grade alloc] initWithName:gradeName];
		grade.score = gradeValue;
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
