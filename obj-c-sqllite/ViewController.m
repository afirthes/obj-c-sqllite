//
//  ViewController.m
//  obj-c-sqllite
//
//  Created by sehio on 11.07.2021.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (Model *)model {
    if (!_model) {
        _model = [[Model alloc] init];
    }
    return _model;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.model openDB];
    [self.model closeDB];
}


@end
