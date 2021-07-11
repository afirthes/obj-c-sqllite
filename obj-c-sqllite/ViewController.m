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
    
    // Test code: add an employee, show all employees,
    // delete the employee, show all employees
    [self.model addEmployeeWithFirstName:@"Jane" lastName:@"Smith" phone:@"578-555-1212"];
    NSArray *empArray = [self.model allEmployees];
    NSLog(@"%@", empArray);

    NSNumber *empID = [[empArray objectAtIndex:0] objectAtIndex:0];
    [self.model deleteEmployeeWithID:empID];
    empArray = [self.model allEmployees];
    NSLog(@"%@", empArray);
}


@end
