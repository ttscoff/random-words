# RandomWords
<!--README-->

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
Dictionaries:
        --list-dictionaries          List available dictionaries
        --create-dictionary [NAME]   Create a new dictionary
    -d, --debug                      Enable debug mode, displays sentence/word/character counts
    -h, --help                       Display this help message
    -v, --version                    Display the version
    -t, --test                       Run the full debug test
```

#### Creating A New Dictionary

You can add your own sources for generating your random text. A dictionary is a directory containing several text files, one for each part of speech that RandomWords uses. All of the parts must exist. The directory name is the same as the name of the dictionary.

User dictionaries must be stored in `~/.config/random-words/words/[NAME]`.

The easiest way to generate a new language is to use the CLI:

```console
randw --create-dictionary [NAME]
```

Once this command is run, a new directory in `~/.config/random-words/words` will be created containing all of the necessary files with English defaults. Simply edit these files, and then you'll be able to call the language by its name (or triggers defined in the config, see below). If a language of the same name exists, missing files will be filled in, but existing files will not be overwritten.

The necessary files are:

```console
adjectives.txt
adverbs.txt
articles-plural.txt
articles-singular.txt
clauses.txt
config.yml
conjunctions-coordinating.txt
conjunctions-subordinate.txt
nouns-plural.txt
nouns-singular.txt
numbers.txt
prepositions.txt
terminators.txt
verbs-passive.txt
verbs-plural.txt
verbs-singular.txt
```

##### Language Configuration

The `config.yml` file in a language directory is a simple YAML configuration. It contains the keys:

```yaml
---
name: english
description: English words
triggers: [english]
```

A default configuration file will be created when running `--create-dictionary` with the CLI.

- `name`: The name of the dictionary, which should be the same as the directory name in most cases
- `description`: Just used for display when running `--list-dictionaries`
- `triggers`: An array of triggers that can be used to trigger the language. For example, the `bacon` language has the triggers `[bacon, meat, carnivore]`, so you can use `randw -S meat` on the command line (or with the library).

> RandomWords loosely uses English rules for sentence construction, so non-English languages will likely generate even more nonsensical strings.

If you create a fun dictionary, please let me know (or make a PR) and I'll gladly include (most) new dictionaries in the main distribution.

> The easiest way to get words is with AI. A ChatGPT prompt like "give me 100 plural nouns related to the medical profession, in plain text, one per line, sorted alphabetically" will get you a good list of words you can then just paste into `nouns-plural.txt` in your dictionary.

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
<!--END README-->
