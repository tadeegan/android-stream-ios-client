//
//  AsMainViewController.m
//  Android Stream
//
//  Created by Thomas on 9/6/14.
//  Copyright (c) 2014 hackers. All rights reserved.
//

#import "ASMainViewController.h"
#import <AFNetworking/UIImageView+AFNetworking.h>

static const CGFloat frameRate = 20.0;

static const NSInteger touchPort = 8002;
static const NSInteger imagePort = 5000;

//static const NSString *baseURL = @"http://192.168.1.2"; netgear
static const NSString *baseURL = @"http://32.2.69.118"; //mwireless


typedef NS_ENUM(NSInteger, PushType) {
    Down,
    Up,
    Update
};

@interface ASMainViewController ()

@property (nonatomic) UIImageView *imageView;
@property (atomic) NSInteger activeRequests;
@end

@implementation ASMainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.activeRequests = 0;
        self.imageView = [[UIImageView alloc] initWithFrame:self.view.frame];
        self.imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self.view addSubview:self.imageView];
        //[NSTimer scheduledTimerWithTimeInterval:1.0/frameRate target:self selector:@selector(fetchImage:) userInfo:nil repeats:YES];
    }
    return self;
}

- (void)fetchImage:(id)sender
{
    if (self.activeRequests > 2) {
        return;
    }
    self.activeRequests ++;
    __weak typeof(self) weakSelf = self;
    
    NSString *address = [NSString stringWithFormat:@"%@:%@/",baseURL,@(imagePort)];
    NSURLRequest * request = [NSURLRequest requestWithURL:[NSURL URLWithString:address] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:1.0];
    NSLog(@"%@", request);
    [self.imageView setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        weakSelf.activeRequests --;
        weakSelf.imageView.image = image;
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        weakSelf.activeRequests --;
    }];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark touches

- (void)pushServer:(PushType)type x:(NSInteger)x y:(NSInteger)y {
    NSString *updateString = @"";
    if (type == Down){
        updateString = @"down";
    }
    else if(type == Up){
        updateString = @"up";
    }
    else if(type == Update){
        updateString = @"update";
    }else {
        return;
    }
    NSString *xString = [NSString stringWithFormat:@"%@",@(x)];
    NSString *yString = [NSString stringWithFormat:@"%@",@(y)];
    NSString *address = [NSString stringWithFormat:@"%@:%@/",baseURL,@(touchPort)];
    NSString *enquiryurl = [NSString stringWithFormat:@"%@?hi=%@&foo=%@&bar=%@",address,updateString,xString,yString];
    
    NSLog(@"%@",enquiryurl);
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[enquiryurl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request  delegate:self];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint touchPoint = [touch locationInView:self.view];
    [self pushServer:Down x:touchPoint.x y:touchPoint.y];
    [super touchesEnded: touches withEvent: event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint touchPoint = [touch locationInView:self.view];
    [self pushServer:Update x:touchPoint.x y:touchPoint.y];
    [super touchesEnded: touches withEvent: event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint touchPoint = [touch locationInView:self.view];
    NSLog(@"Touch x : %f y : %f", touchPoint.x, touchPoint.y);
    [self pushServer:Up x:touchPoint.x y:touchPoint.y];
    [super touchesEnded: touches withEvent: event];
}


@end
