# RandomWords

A random text (Lorem Ipsum) generator.

```ruby
require 'random-words'

rw = RandomWords::Generator.new(:corporate)
rw.paragraph_length = 5
rw.sentence_length = :short
puts rw.paragraph
```

