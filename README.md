# mongoid-siblings [![Build Status](https://secure.travis-ci.org/DouweM/mongoid-siblings.png?branch=master)](http://travis-ci.org/DouweM/mongoid-siblings)

mongoid-siblings adds methods to enable you to easily access your Mongoid 
document's siblings.

## Requirements

* mongoid (~> 3.0)

## Installation

Add the following to your Gemfile:

```ruby
gem "mongoid-siblings", require: "mongoid/siblings"
```

And tell Bundler to install the new gem:

```
bundle install
```

## Usage

Include the `Mongoid::Siblings` module in your document class:

```ruby
class Book
  include Mongoid::Document
  include Mongoid::Siblings

  belongs_to :publisher
  belongs_to :author

  ...
end
```

You will now have access to the following methods:

```ruby
# Find all books by this book's author, not including this book.
book.siblings(scope: :author)

# Find all books by this book's author.
book.siblings_and_self(scope: :author)

# Check whether a certain book was published by the same publisher as this book.
book.sibling_of?(other_book, scope: :publisher)

# Make this book a sibling of a book with another author and publisher.
# This will set this books author and publisher to match that of the other book.
book.become_sibling_of!(other_book, scope: [:author, :publisher])
```

## Full documentation
See [this project's RubyDoc.info page](http://rubydoc.info/github/DouweM/mongoid-siblings/master/frames).

## Known issues
See [the GitHub Issues page](https://github.com/DouweM/mongoid-siblings/issues).

## License
Copyright (c) 2012 Douwe Maan

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.