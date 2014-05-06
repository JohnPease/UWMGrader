//
//  ViewController.m
//  UWMGrader
//
//  Created by John Pease on 3/26/14.
//  Copyright (c) 2014 John Pease. All rights reserved.
//

#import "LogInViewController.h"
#import "ClassTableViewController.h"
#import "Parser.h"

@interface LogInViewController ()
@property(nonatomic)int webViewLoads_;
@end

@implementation LogInViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

//	NSURL* d2lLoginUrl = [NSURL URLWithString:@"https://uwm.courses.wisconsin.edu/Shibboleth.sso/Login?target=https://uwm.courses.wisconsin.edu/d2l/shibbolethSSO/deepLinkLogin.d2l"];
	
	NSURLRequest* d2lLoginRequest = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:D2LLoginUrl]];
	self.d2lWebView.delegate = self;

	[self.d2lWebView loadRequest:d2lLoginRequest];
	
	/* REMOVE THIS BEFORE SUBMITTING */
	self.userNameTextField.text = @"jjpease";
	self.passwordTextField.text = @"test";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)logInButtonPressed {
	NSString* login = @"document.forms.item(0).submit();";
	NSString* usernameSet = [NSString stringWithFormat:@"document.getElementById('j_username').value = \"%@\"", self.userNameTextField.text];
	NSString* passwordSet = [NSString stringWithFormat:@"document.getElementById('j_password').value = \"%@\"", self.passwordTextField.text];
	
	if ([self.userNameTextField.text isEqualToString:@""] || [self.passwordTextField.text isEqualToString:@""]) {
		UIAlertView* error = [[UIAlertView alloc] initWithTitle:@"error will robinson" message:@"please enter a username and password before logging in" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[error show];
	} else {
		[self.d2lWebView stringByEvaluatingJavaScriptFromString:usernameSet];
		[self.d2lWebView stringByEvaluatingJavaScriptFromString:passwordSet];
		[self.d2lWebView stringByEvaluatingJavaScriptFromString:login];
	}
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	if (textField == self.userNameTextField) {
		[textField resignFirstResponder];
		[self.passwordTextField becomeFirstResponder];
	} else if (textField == self.passwordTextField) {
		[textField resignFirstResponder];
	}
	return NO;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
	self.webViewLoads_++;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
	self.webViewLoads_--;
	NSString* html = [NSString stringWithContentsOfURL:webView.request.URL encoding:NSASCIIStringEncoding error:nil];
	if ([webView.request.URL.absoluteString isEqualToString:@"https://uwm.courses.wisconsin.edu/d2l/m/home"]) {
		[self performSegueWithIdentifier:@"LoginSegue" sender:self];
	} else if ([html rangeOfString:@"Bad username or password"].location != NSNotFound) {
		UIAlertView* error = [[UIAlertView alloc] initWithTitle:@"you done messed up" message:@"please enter a valid username and password" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[error show];
	}
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UINavigationController* dest = segue.destinationViewController;
    ClassTableViewController* destination = [dest.childViewControllers objectAtIndex:0];
	Parser* p = [[Parser alloc] init];
	destination.courses = [p getCoursesFrom:[NSString stringWithContentsOfURL:self.d2lWebView.request.URL encoding:NSASCIIStringEncoding error:nil]];
	destination.d2lWebView = self.d2lWebView;
}

@end
