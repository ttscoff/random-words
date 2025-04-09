

[![RubyGems.org](https://img.shields.io/gem/v/snibbets)](https://rubygems.org/gems/snibbets)

A random text (Lorem Ipsum) generator.

### Installation

    gem install random-words

Depending on your setup, you may need `gem install --user-install random-words`, or in worst case scenario, `sudo gem install random-words`. You can also use `brew gem install random-words` if you use [Homebrew](https://brew.sh).

### CLI

The gem installs a binary `randw`. It can generate random characters, sentences, paragraphs, and passwords.

```console
Usage: randw [options]
Options:
    -S, --source [SOURCE]            Specify the source language (default: latin)
    -l [short|medium|long|very_long],
        --length                     Specify the length of the sentence
        --graf-length [NUMBER]       Specify the number of sentences in a paragraph
    -s, --sentences [NUMBER]         Generate random sentences
    -p, --paragraphs [NUMBER]        Generate random paragraphs
    -w, --words [NUMBER]             Generate random words
    -c, --characters [NUMBER]        Generate random characters
        --password                   Generate a random password
        --separator [CHAR]           Specify the separator character for the password
    -n, --no-whitespace              Specify whether to remove whitespace in generated text (characters only)
    -d, --debug                      Enable debug mode, displays sentence/word/character counts
    -h, --help                       Display this help message
    -v, --version                    Display the version
    -t, --test                       Run the full debug test
```

### Library

```ruby
require 'random-words'

# Argument defines source dictionary (latin, english, corporate, bacon)
rw = RandomWords::Generator.new(:corporate)
# Change source dictionary and re-init
rw.source = :bacon

rw.paragraph_length = 5 # Number of sentences in a paragraph (default 3)
rw.sentence_length = :short # :short, :medium, :long, :verylong (default :medium)

# Redefine lengths, can include :short, :medium, :long, and :verylong
rw.lengths = { short: 100, medium: 300 }

## Characters
# Outputs words but limits total to characters
puts rw.characters(20)
# limits total characters, allowing truncation
puts rw.characters(20, whole_words: false)

## Sentences
# Output a sentence based on @sentence_length
puts rw.sentence
# Output a sentence with a specific number of characters
puts rw.sentence(300)
# Output an array of # sentences
puts rw.sentences(3)

## Paragraphs
# Output a paragraph based on @paragraph_length
puts rw.paragraph
# Output a paragraph with a specified number of sentences
# Sentence length is still determined by @sentence_length
puts rw.paragraph(2)

## Attributes
# Parts of speech (arrays, r/w)
rw.adjectives
rw.articles
rw.clauses
rw.nouns
rw.plural_nouns
rw.verbs
rw.plural_verbs
rw.subordinate_conjunctions
rw.numbers

# Other attributes (r/w)
rw.source
rw.paragraph_length
rw.sentence_length
```
