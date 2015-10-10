kor-input-yaml
===

[![Build Status](https://travis-ci.org/ksss/kor-input-yaml.svg)](https://travis-ci.org/ksss/kor-input-yaml)

YAML input plugin for [kor](https://github.com/ksss/kor).

# Usage

```
$ cat table.yaml
---
foo: 100
bar: 200
---
bar: 500
baz: 600

$ kor yaml csv < table.yml
foo,bar,baz
100,200,
,500,600

$ kor yaml markdown < table.yml
| foo | bar | baz |
| --- | --- | --- |
| 100 | 200 |  |
|  | 500 | 600 |

$ kor yaml --key=bar,foo markdown < table.yml
| bar | foo |
| --- | --- |
| 200 | 100 |
| 500 |  |
```

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'kor-input-yaml'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install kor-input-yaml

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ksss/kor-input-yaml. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

## Refs

- https://github.com/ksss/kor
