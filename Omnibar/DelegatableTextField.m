//  Copyright © 2018 Christian Tietze. All rights reserved. Distributed under the MIT License.

#import "DelegatableTextField.h"

@implementation DelegatableTextField

- (BOOL)del_textView:(NSTextView *)textView shouldChangeTextInRange:(NSRange)affectedCharRange replacementString:(NSString *)replacementString {
    if (![self.cell respondsToSelector:@selector(textView:shouldChangeTextInRange:replacementString:)]) {
        NSAssert(false, @"NSTextFieldCell should respond to NSTextViewDelegate functions");
        return true;
    }
    return [((id<NSTextViewDelegate>)self.cell) textView:textView shouldChangeTextInRange:affectedCharRange replacementString:replacementString];
}
@end
