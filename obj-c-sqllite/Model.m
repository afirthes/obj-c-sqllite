//
//  AppDelegate.h
//  obj-c-sqllite
//
//  Created by sehio on 11.07.2021.
//

#import "Model.h"

// declare the database:
static sqlite3 *database;

@implementation Model

- (id)init
{
    self = [super init];
    if (self) {
        // get the path to the db in the bundle:
        NSString *dbBundlePath = [[NSBundle mainBundle] pathForResource:@"schema" ofType:@"sqlite3"];
        
        // check the documents directory for the file:
        NSFileManager *manager = [NSFileManager defaultManager];
        NSError *error;
        if (![manager fileExistsAtPath:[self dbDocPath]]) {
            // copy the file from the bundle to the documents
            // directory if it does not exist:
            [manager copyItemAtPath:dbBundlePath toPath:[self dbDocPath] error:&error];
            if (error) {
                NSLog(@"Error copying file: %@", [error description]);
            }
        }
    }
    return self;
}

- (NSString *) dbDocPath
{
    // get the path to the documents directory:
    NSArray *docPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [[docPaths objectAtIndex:0] stringByAppendingPathComponent:@"schema.sqlite3"];
    return path;
}

- (void) openDB
{
    if ( (sqlite3_open([[self dbDocPath] UTF8String], &database)) != SQLITE_OK )
        NSLog(@"Error: cannot open database");
}

- (void) closeDB
{
    sqlite3_close(database);
}

@end
