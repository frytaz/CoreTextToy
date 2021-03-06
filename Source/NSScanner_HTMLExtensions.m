//
//  NSScanner_HTMLExtensions.m
//  TouchCode
//
//  Created by Jonathan Wight on 9/21/11.
//  Copyright 2011 toxicsoftware.com. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without modification, are
//  permitted provided that the following conditions are met:
//
//     1. Redistributions of source code must retain the above copyright notice, this list of
//        conditions and the following disclaimer.
//
//     2. Redistributions in binary form must reproduce the above copyright notice, this list
//        of conditions and the following disclaimer in the documentation and/or other materials
//        provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED BY 2011 TOXICSOFTWARE.COM ``AS IS'' AND ANY EXPRESS OR IMPLIED
//  WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
//  FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL 2011 TOXICSOFTWARE.COM OR
//  CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
//  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
//  SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
//  ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
//  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
//  ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
//  The views and conclusions contained in the software and documentation are those of the
//  authors and should not be interpreted as representing official policies, either expressed
//  or implied, of 2011 toxicsoftware.com.

#import "NSScanner_HTMLExtensions.h"

@implementation NSScanner (HTMLExtensions)


// <a href="\""> // Not currently supported.
// <a href="">
// <a foo>
// <a>

- (BOOL)scanOpenTag:(NSString **)outTag attributes:(NSDictionary **)outAttributes
    {
    NSUInteger theSavedScanLocation = self.scanLocation;
    NSCharacterSet *theSavedCharactersToBeSkipped = self.charactersToBeSkipped;

    if ([self scanString:@"<" intoString:NULL] == NO)
        {
        self.scanLocation = theSavedScanLocation;
        self.charactersToBeSkipped = theSavedCharactersToBeSkipped;
        return(NO);
        }

    self.charactersToBeSkipped = [NSCharacterSet whitespaceAndNewlineCharacterSet];

    NSString *theTag = NULL;
    if ([self scanCharactersFromSet:[NSCharacterSet letterCharacterSet] intoString:&theTag] == NO)
        {
        self.scanLocation = theSavedScanLocation;
        self.charactersToBeSkipped = theSavedCharactersToBeSkipped;
        return(NO);
        }

    NSMutableDictionary *theAttributes = [NSMutableDictionary dictionary];
    while (self.isAtEnd == NO)
        {
        NSString *theAttributeName = NULL;
        if ([self scanCharactersFromSet:[NSCharacterSet letterCharacterSet] intoString:&theAttributeName] == NO)
            {
            break;
            }

        id theAttributeValue = [NSNull null];

        if ([self scanString:@"=" intoString:NULL] == YES)
            {
            if ([self scanString:@"\"" intoString:NULL] == NO)
                {
                self.scanLocation = theSavedScanLocation;
                self.charactersToBeSkipped = theSavedCharactersToBeSkipped;
                return(NO);
                }

            if ([self scanUpToString:@"\"" intoString:&theAttributeValue] == NO)
                {
                self.scanLocation = theSavedScanLocation;
                self.charactersToBeSkipped = theSavedCharactersToBeSkipped;
                return(NO);
                }

            if ([self scanString:@"\"" intoString:NULL] == NO)
                {
                self.scanLocation = theSavedScanLocation;
                self.charactersToBeSkipped = theSavedCharactersToBeSkipped;
                return(NO);
                }
            }

        [theAttributes setObject:theAttributeValue forKey:theAttributeName];
        }

    if ([self scanString:@">" intoString:NULL] == NO)
        {
        self.scanLocation = theSavedScanLocation;
        self.charactersToBeSkipped = theSavedCharactersToBeSkipped;
        return(NO);
        }

    if (outTag)
        {
        *outTag = theTag;
        }

    if (outAttributes && [theAttributes count] > 0)
        {
        *outAttributes = [theAttributes copy];
        }

    self.charactersToBeSkipped = theSavedCharactersToBeSkipped;
    return(YES);
    }

@end
