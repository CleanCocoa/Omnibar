//  Copyright © 2018 Christian Tietze. All rights reserved. Distributed under the MIT License.

#import <Cocoa/Cocoa.h>

@interface DelegatableTextField : NSTextField

- (BOOL)del_textView:(nonnull NSTextView *)textView shouldChangeTextInRange:(NSRange)affectedCharRange replacementString:(nullable NSString *)replacementString;

@end
