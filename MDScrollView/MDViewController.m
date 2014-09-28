//
//  MDViewController.m
//  MDScrollView
//
//  Created by mohamed mohamed El Dehairy on 9/24/14.
//  Copyright (c) 2014 ___FULLUSERNAME___. All rights reserved.
//

#import "MDViewController.h"

@interface MDViewController ()

@end

@implementation MDViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	MDScrollView *scroll = [[MDScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    
    UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 480, scroll.bounds.size.height)];
    image.image = [UIImage imageNamed:@"splash640Rebranding.png"];
    image.contentMode = UIViewContentModeScaleAspectFit;
    [scroll addSubview:image];
    
    UIImageView *image1 = [[UIImageView alloc] initWithFrame:CGRectMake(0, image.bounds.size.height, 480, scroll.bounds.size.height)];
    image1.image = [UIImage imageNamed:@"splash640Rebranding.png"];
    image1.contentMode = UIViewContentModeScaleAspectFit;
    [scroll addSubview:image1];
    
    [self.view addSubview:scroll];
    
    scroll.backgroundColor = [UIColor redColor];
    [scroll setContentSize:CGSizeMake(480, scroll.frame.size.height*2)];
    
    UISegmentedControl *segment = [[UISegmentedControl alloc] initWithItems:@[@"one",@"two",@"three"]];
    segment.frame = CGRectMake(50, 50, 200, 50);
    [scroll addSubview:segment];
    
    [scroll zoomWithScale:1.0];
}
-(void)touchBtn
{
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
