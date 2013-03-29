# Objective-C Lorem Ipsum Generator

## About

A very simple and not very clever class that generates N words of lorem ipsum text.

Maybe this will save you the 15 minutes I spent writing it. I based it from http://www.ruby-forum.com/topic/101574

## Example
   #import "LoremIpsum.h"

    LoremIpsum* loremIpsum = [LoremIpsum new];
    NSString* defaultText = [loremIpsum words:15];
    _textView.text = defaultText;
    [loremIpsum release];

## License

Public domain where appropriate; free for everyone, for all usages, elsewhere.
