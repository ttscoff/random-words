

[![RubyGems.org](https://img.shields.io/gem/v/random-words)](https://rubygems.org/gems/random-words)[![](https://img.shields.io/github/license/ttscoff/random-words)](https://opensource.org/licenses/MIT)

A random text (Lorem Ipsum) generator.

### Installation

    gem install random-words

Depending on your setup, you may need
`gem install --user-install random-words`, or in
worst case scenario, `sudo gem install random-words`.
You can also use `brew gem install random-words` if
you use [Homebrew](https://brew.sh).

### CLI

The gem installs a binary `randw`. It can generate random
characters, sentences, paragraphs, markdown, html, and
passwords.

```console
Usage: randw [options]
OPTIONS:
    -S, --source SOURCE              Specify the source language (default: latin)
    -l, --length LENGTH              Specify the length of the sentence [short|medium|long|very_long]
        --graf-length NUMBER         Specify the number of sentences in a paragraph
        --[no-]extended              Specify whether to use extended punctuation in generated text
GENERATORS:
    -s, --sentences [NUMBER]         Generate NUMBER of random sentences (default: 3)
    -p, --paragraphs [NUMBER]        Generate NUMBER of random paragraphs (default: 3)
    -w, --words [NUMBER]             Generate NUMBER of random words (default: 10)
    -c, --characters [NUMBER]        Generate random characters of length (default: 100)
    -m, --markdown [SETTINGS]        Generate random markdown text, comma separated string like "latin,10,all"
                                     dec: add em and strong
                                     link: add links
                                     ul: add unordered lists
                                     ol: add ordered lists
                                     dl: add definition lists
                                     bq: add block quotes
                                     code: add code spans and block
                                     mark: add ==highlights==
                                     headers: add headlines
                                     image: add images
                                     table: add tables
    -H, --html [SETTINGS]            Generate random html text, comma separated string like "latin,10,all"
        --password [LENGTH]          Generate a random password of LENGTH (default: 20)
PASSWORD OPTIONS:
        --separator CHAR             Specify the separator character for the password (default: " ")
    -n, --[no-]whitespace            Specify whether to remove whitespace in generated text (characters only)
DICTIONARIES:
        --list-dictionaries          List available dictionaries
        --create-dictionary [NAME]   Create a new dictionary
OTHER OPTIONS:
    -d, --debug                      Enable debug mode, displays sentence/word/character counts
    -h, --help                       Display this help message
    -v, --version                    Display the version
    -t, --test                       Run the full debug test
```

#### Generating Markdown text

The `--markdown` flag takes a SETTINGS argument. This is a
comma- or slash-separated string that determines the
elements to include.

First, the source language (defaults to latin), then the
length of paragraphs and tables: e.g. `english/medium`. You
can add any digits to determine how many paragraphs are
generated (default 5), e.g. `corporate/medium/10`.

Then you can add individual elements, or use `/all` to
trigger all elements. The elements available are:

| trigger | element                   |
| :------ | :------------------------ |
| dec     | add em and strong         |
| link    | add links                 |
| ul      | add unordered lists       |
| ol      | add ordered lists         |
| dl      | add definition lists      |
| bq      | add block quotes          |
| code    | add code spans and blocks |
| mark    | add ==highlights==        |
| headers | add headlines             |
| image   | add images                |
| table   | add tables                |
| x       | add extended punctuation  |

The number of elements inserted depends on the length you specify.

Example commands:

```console
$ randw -m "latin/1/short/ol"

Illa brevis muros potior arcesso, apud multae octo centum nonaginta octo nodum! Haec ruosus misericordia mox contendo, apud nullus fors.


1. Hoc cognatus opus facile complor latus discendo
2. Aliqua apparens census quod nego
3. Nullus salvus dux apud habeo spectabilis
4. Quaedam sensus regnum cura gaudeo ornatus faeneo mox

$ randw -m "english,5,all"

# Any shiny napkin effectively picks

Neither sudden lake exceedingly works, outside a clarity even if which is a source of _an_ strength even if which holds _one subtle horse_ the future. Any lovable tank remarkabl...
```

#### Creating A New Dictionary

You can add your own sources for generating your random
text. A dictionary is a directory containing several text
files, one for each part of speech that RandomWords uses.
All of the parts must exist. The directory name is the same
as the name of the dictionary.

User dictionaries must be stored in `~/.config/random-words/words/[NAME]`.

The easiest way to generate a new language is to use the CLI:

```console
randw --create-dictionary [NAME]
```

Once this command is run, a new directory in
`~/.config/random-words/words` will be created containing
all of the necessary files with English defaults. Simply
edit these files, and then you'll be able to call the
language by its name (or triggers defined in the config, see
below). If a language of the same name exists, missing files
will be filled in, but existing files will not be
overwritten.

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
names.txt
nouns-plural.txt
nouns-singular.txt
numbers.txt
phrases.txt
prepositions.txt
terminators.txt
verbs-passive.txt
verbs-plural.txt
verbs-singular.txt
```

##### Language Configuration

The `config.yml` file in a language directory is a simple
YAML configuration. It contains the keys:

```yaml
---
name: english
description: English words
triggers: [english]
extended_punctuation: false
```

A default configuration file will be created when running `--create-dictionary` with the CLI.

- `name`: The name of the dictionary

    This should be the same as the directory name in most cases
- `description`: Just used for display when running `--list-dictionaries`
- `triggers`: An array of triggers that can be used to trigger the language.

    For example, the `bacon` language has the triggers
    `[bacon, meat, carnivore]`, so you can use `randw -S
    meat` on the command line (or with the library).
- `extended_punctuation`: Whether to include extended
  punctuation like parenthesis, quotes, and ellipsis.


##### Terminators

The `terminators.txt` file contains pairs of punctuation,
separated by commas, one per line. If a sentence terminator
doesn't have opening punctuation, start the line with a
comma. More than one character can be used in either side of
the pair. For example, to create a double quoted sentence
with a period inside the closing quote, you would use:

    ",."

A blank line (or any line not containing a comma) will
separate regular punctuation from extended punctuation. In
the default file, `.`, `?`, and `!` are considered regular
punctuation, and parenthesis and quotes are considered
extended punctuation. Extended punctuation is off by
default, but in the CLI can be enabled with `--extended`,
and using the library you can include
`use_extended_punctuation: true` in the options when
initializing, or use `@rw.use_extended_punctuation = true`
to set it after initializing.

Repeating words or terminators more than once in the config
files increases their likelihood of being used. In the
default terminator.txt files, the period, question mark, and
exclamation point are repeated multiple times to make them
the most likely to be used.

##### Names

The `names.txt` file is just used when creating random
names. Sections are split by blank lines: first names, last
names, and optionally full names. If the first line contains
characters other than letters, single quotes, and dashes, it
will be assumed that you've skipped straight to full names
and those will be used instead of generating random
combinations.

#### Language Notes

RandomWords loosely uses English rules for sentence construction, so non-English languages will likely generate even more nonsensical strings.

If you create a fun dictionary, please let me know (or make a PR) and I'll gladly include (most) new dictionaries in the main distribution.

> The easiest way to get words is with AI. A ChatGPT prompt like "give me 100 plural nouns related to the medical profession, in plain text, one per line, sorted alphabetically" will get you a good list of words you can then just paste into `nouns-plural.txt` in your dictionary.

### Library

```ruby
require 'random-words'

# Argument defines source dictionary (latin, english, corporate, bacon, etc.)
rw = RandomWords::Generator.new(:corporate)

rw.sources # List all available dictionaries

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
