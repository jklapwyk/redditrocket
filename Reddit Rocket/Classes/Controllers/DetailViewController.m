//
//  DetailViewController.m
//  Reddit Rocket
//
//  Created by James Klapwyk on 2017-04-19.
//  Copyright © 2017 James Klapwyk. All rights reserved.
//

#import "DetailViewController.h"

@interface DetailViewController ()

@end

@implementation DetailViewController

- (void)configureView {
    // Update the user interface for the Article item.
    if (self.articleItem) {
        
        //Load Html into UIWebView
        UIWebView *webView = (UIWebView *)[self.view viewWithTag:1];
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.articleItem.link]];
        [webView loadRequest:request];
        
        //Set Controller Title to the Article Title
        self.title = self.articleItem.title;
    }
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self configureView];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Managing the detail item

- (void)setArticleItem:(Article *)newArticleItem {
    if (_articleItem != newArticleItem) {
        _articleItem = newArticleItem;
        
        // Update the view.
        [self configureView];
    }
}


@end
