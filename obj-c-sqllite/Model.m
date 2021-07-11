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

/*
 CREATE TABLE Names (
 ID integer not null primary key,
 FirstName text,
 LastName text);
 
 CREATE TABLE Phones (
 ID integer not null primary key,
 NameID integer not null,
 Phone text not null);
 */

- (id)init
{
    self = [super init];
    if (self) {
        // get the path to the db in the bundle:
        NSString *dbBundlePath = [[NSBundle mainBundle] pathForResource:@"db" ofType:@"sqlite3"];
        
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
    NSString *path = [[docPaths objectAtIndex:0] stringByAppendingPathComponent:@"db.sqlite3"];
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

- (void) addEmployeeWithFirstName:(NSString *)firstName
                              lastName:(NSString *)lastName
                                 phone:(NSString *)phone
{
    long long empID;
    [self openDB];
    
    //prepare query for the Names table:
    NSString *insertSQL =
    [NSString stringWithFormat:@"INSERT INTO Names (firstName, lastName) VALUES ('%@', '%@')", firstName, lastName];
    NSLog(@"%@", insertSQL);
    const char* query1 = [insertSQL UTF8String];
    sqlite3_stmt *query1_stmt = NULL;
    if (sqlite3_prepare_v2(database, query1, -1, &query1_stmt, NULL) != SQLITE_OK) {
        NSLog(@"Error preparing %@", insertSQL);
        return;
    }
    //insert Names table data:
    if (sqlite3_step(query1_stmt) != SQLITE_DONE) {
        NSLog(@"Error running insert: %s", query1);
        return;
    }
    //get the row id:
    empID = sqlite3_last_insert_rowid(database);
    
    //prepare query for the Phones table:
    insertSQL =
    [NSString stringWithFormat:@"INSERT INTO Phones (NameID, Phone) VALUES (%lld, '%@')", empID, phone];
    const char* query2 = [insertSQL UTF8String];
    sqlite3_stmt *query2_stmt = NULL;
    if (sqlite3_prepare_v2(database, query2, -1, &query2_stmt, NULL) != SQLITE_OK) {
        NSLog(@"Error preparing %@", insertSQL);
        [self closeDB];
        return;
    }
    //insert Phones table data:
    if (sqlite3_step(query2_stmt) != SQLITE_DONE) {
        NSLog(@"Error running insert: %s", query1);
        [self closeDB];
        return;
    }
    
    sqlite3_finalize(query1_stmt);
    sqlite3_finalize(query2_stmt);
    [self closeDB];
    
}

- (void) deleteEmployeeWithID:(NSNumber *)empID
{
    [self openDB];
    long long llEmpID = [empID longLongValue];
    // set up the delete queries:
    NSString *deleteNamesSQL = [NSString stringWithFormat:@"DELETE FROM Names WHERE ID = %lld", llEmpID];
    NSString *deletePhonesSQL = [NSString stringWithFormat:@"DELETE FROM Phones WHERE NameID = %lld", llEmpID];
    const char* namesQuery = [deleteNamesSQL UTF8String];
    const char* phonesQuery = [deletePhonesSQL UTF8String];
    sqlite3_stmt *query_dNames = NULL;
    sqlite3_stmt *query_dPhones = NULL;
    
    //delete from the Names table:
    if (sqlite3_prepare_v2(database, namesQuery, -1, &query_dNames, NULL) != SQLITE_OK) {
        NSLog(@"Error preparing %@", deleteNamesSQL);
        [self closeDB];
        return;
    }
    if (sqlite3_step(query_dNames) != SQLITE_DONE) {
        NSLog(@"Error running delete: %s", namesQuery);
        [self closeDB];
        return;
    }
    
    //delete from the Phones table:
    if (sqlite3_prepare_v2(database, phonesQuery, -1, &query_dPhones, NULL) != SQLITE_OK) {
        NSLog(@"Error preparing %@", deletePhonesSQL);
        [self closeDB];
        return;
    }
    if (sqlite3_step(query_dPhones) != SQLITE_DONE) {
        NSLog(@"Error running delete: %s", phonesQuery);
        [self closeDB];
        return;
    }
    
    sqlite3_finalize(query_dNames);
    sqlite3_finalize(query_dPhones);
    [self closeDB];
}

- (NSArray *)allEmployees
{
    [self openDB];
    NSMutableArray *employeeData = [[NSMutableArray alloc] initWithCapacity:5];
    
    //prepare the select query:
    NSString *selectSQL = @"SELECT Names.ID, firstName, lastName, phone FROM Names INNER JOIN Phones WHERE Names.ID = Phones.NameID";
    const char* query = [selectSQL UTF8String];
    sqlite3_stmt *query_stmt = NULL;
    if (sqlite3_prepare_v2(database, query, -1, &query_stmt, NULL) != SQLITE_OK) {
        NSLog(@"Error preparing %@", selectSQL);
        return nil;
    }
    while (sqlite3_step(query_stmt) == SQLITE_ROW) {
        // for each row, bind the values to C types, then
        // convert to Objects.
        long long ID = sqlite3_column_int(query_stmt, 0);
        char *fName = (char *) sqlite3_column_text(query_stmt, 1);
        char *lName = (char *) sqlite3_column_text(query_stmt, 2);
        char *pNumber = (char *) sqlite3_column_text(query_stmt, 3);
        NSNumber *rowID = [NSNumber numberWithLongLong:ID];
        NSString *firstName = [[NSString alloc] initWithUTF8String:fName];
        NSString *lastName = [[NSString alloc] initWithUTF8String:lName];
        NSString *phoneNumber = [[NSString alloc] initWithUTF8String:pNumber];
        
        // marshal the data:
        NSArray *entry = @[rowID, firstName, lastName, phoneNumber];
        [employeeData addObject:entry];
    }
    
    sqlite3_finalize(query_stmt);
    [self closeDB];
    return employeeData;
}

@end
