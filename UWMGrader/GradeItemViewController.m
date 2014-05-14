//
//  GradeItemViewController.m
//  UWMGrader
//
//  Created by John Pease on 4/7/14.
//  Copyright (c) 2014 John Pease. All rights reserved.
//

#import "GradeItemViewController.h"
#import "Grade.h"
#import "Reachability.h"

@interface GradeItemViewController ()
@property(nonatomic)Reachability* reachability;
@end

@implementation GradeItemViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
	self.reachability = [[Reachability alloc] init];
	
	self.gradeValue.text = [NSString stringWithFormat:@"score: %@", self.grade.score];
	
	if (self.grade.weightAchieved == nil) self.weightAchieved.text = @"Weight not provided";
	else self.weightAchieved.text = [NSString stringWithFormat:@"weight achieved: %@", self.grade.weightAchieved];
	
	if (self.grade.feedback == nil) self.feedbackFromGrader.text = @"No feedback given";
	else self.feedbackFromGrader.text = self.grade.feedback;
	
}

- (void)viewWillAppear:(BOOL)animated {
	
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)shareToTwitter {
	if (![self.reachability networkConnection]) {
		UIAlertView* error = [[UIAlertView alloc] initWithTitle:@"Network Connection Error" message:@"You need a network connection to tweet" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[error show];
		return;
	}
	
	if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
		SLComposeViewController* tweetView = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
		NSString* tweet = [NSString stringWithFormat:@"%@\n- sent via UWMGrader", [self generateSocialMessage]];
		
		[tweetView setInitialText:tweet];
		[self presentViewController:tweetView animated:YES completion:nil];
	} else {
		UIAlertView* error = [[UIAlertView alloc] initWithTitle:@"Log into twitter!" message:@"You must be logged into twitter on this device to use this feature" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[error show];
	}
}

- (IBAction)shareToFacebook {
	if (![self.reachability networkConnection]) {
		UIAlertView* error = [[UIAlertView alloc] initWithTitle:@"Network Connection Error" message:@"You need a network connection to do use facebook" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[error show];
		return;
	}
	
	if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
		SLComposeViewController* facebookView = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
		NSString* status = [NSString stringWithFormat:@"%@\n- sent via UWMGrader", [self generateSocialMessage]];
		
		[facebookView setInitialText:status];
		[self presentViewController:facebookView animated:YES completion:nil];
	} else {
		UIAlertView* error = [[UIAlertView alloc] initWithTitle:@"Log into twitter!" message:@"You must be logged into Facebook on this device to use this feature" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[error show];
	}
}

- (NSString*)generateSocialMessage {
	
	if ([self.grade.score isEqualToString:@"Not provided"]) {
		return @"You sure you want to share this even though it has no score?";
	}
	
	double pointsAchieved = [self.grade getPoints];
	double maxPoints = [self.grade getMax];
	
	if (pointsAchieved == -1.0 || maxPoints == -1.0) {
		return @"Hooray for grades not entered!";
	} else {
		double score = pointsAchieved / maxPoints;
		NSString* adj;
		if (score < .1) {
			adj = @"whyamisharingthis";
		} else if (score < .5) {
			//get from bad section
			adj = [self getAdjective:@"bad"];
		} else if (score < .7) {
			//get from mid section
			adj = [self getAdjective:@"mid"];
		} else {
			//get from good section
			adj = [self getAdjective:@"good"];
		}
		
		NSString* msg = @"DANGER WILL ROBINSON";
		
		if ([adj isEqualToString:@""]) {
			msg = [NSString stringWithFormat:@"I got a %@ on %@ in %@!", self.grade.score, self.grade.name, self.courseName];
		} else {
			msg = [NSString stringWithFormat:@"I got a %@ on %@ in %@!, %@", self.grade.score, self.grade.name, self.courseName, adj];
		}
		return msg;
	}
	
	return @"enter a message here";
}

- (NSString*)getAdjective:(NSString*)scoreType {
	NSString* filePath = [[NSBundle mainBundle] pathForResource:scoreType ofType:@"txt"];
	NSError* error;
	NSString* fileContents = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error];
	if (error) {
		return @"error";
	}
	
	NSArray* fileLines = [fileContents componentsSeparatedByString:@"\n"];
	return [fileLines objectAtIndex:arc4random_uniform((int)[fileLines count])];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
