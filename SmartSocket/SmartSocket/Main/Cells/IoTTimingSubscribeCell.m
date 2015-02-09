/**
 * IoTTimingSubscribeCell.m
 *
 * Copyright (c) 2014~2015 Xtreme Programming Group, Inc.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#import "IoTTimingSubscribeCell.h"
#import "MultiSelectSegmentedControl.h"

@interface IoTTimingSubscribeCell()

@property (weak, nonatomic) IBOutlet MultiSelectSegmentedControl *multiSegment;

@property (nonatomic, strong) NSArray *tmpIndexes;

@end

@implementation IoTTimingSubscribeCell

- (void)awakeFromNib {
    // Initialization code
    self.indexes = self.tmpIndexes;
}

- (void)setDelegate:(id<IoTTimingSubscribeCellDelegate>)delegate
{
    _delegate = delegate;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (NSArray *)indexes
{
    //convert NSIndexSet to NSArray
    NSIndexSet *indexes = self.multiSegment.selectedSegmentIndexes;
    NSMutableArray *marray = [NSMutableArray array];
    NSUInteger index;
    for (index = [indexes firstIndex];
         index != NSNotFound; index = [indexes indexGreaterThanIndex: index])
        [marray addObject:@(index)];
    
    return [NSArray arrayWithArray:marray];
}

- (void)setIndexes:(NSArray *)indexes
{
    if(nil == self.multiSegment)
        self.tmpIndexes = indexes;
    else
    {
        self.tmpIndexes = nil;

        //convert NSArray to NSIndexSet
        NSMutableIndexSet *mindexes = [NSMutableIndexSet indexSet];
        for(NSNumber *index in indexes)
        {
            [mindexes addIndex:[index unsignedIntegerValue]];
        }
        self.multiSegment.selectedSegmentIndexes = mindexes;
    }
}

- (IBAction)onSelectedIndex:(MultiSelectSegmentedControl *)sender {

    if([_delegate respondsToSelector:@selector(IoTTimingSubscribeCell:indexes:)])
        [_delegate IoTTimingSubscribeCell:self indexes:[NSArray arrayWithArray:self.indexes]];
}

@end
