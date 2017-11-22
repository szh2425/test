//
//  CTCDaoTest.h
//
//  Created by Byron Ruth on 4/6/10.
//  Copyright 2010 The Children's Hospital of Philadelphia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <SenTestingKit/SenTestingKit.h>
#import "CTCDao.h"
#import "CTCConstants.h"


@interface CTCDaoTest : SenTestCase {
	CTCDao *dao;
}

@property(retain) CTCDao *dao;

- (NSArray *) eventGrades;

@end
