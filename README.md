# Project Generator

[![Cirrus CI - Base Branch Build Status](https://img.shields.io/cirrus/github/AlexWayfer/project_generator?style=flat-square)](https://cirrus-ci.com/github/AlexWayfer/project_generator)
[![Codecov branch](https://img.shields.io/codecov/c/github/AlexWayfer/project_generator/main.svg?style=flat-square)](https://codecov.io/gh/AlexWayfer/project_generator)
[![Code Climate](https://img.shields.io/codeclimate/maintainability/AlexWayfer/project_generator.svg?style=flat-square)](https://codeclimate.com/github/AlexWayfer/project_generator)
[![Inline docs](https://inch-ci.org/github/AlexWayfer/project_generator.svg?branch=main)](https://inch-ci.org/github/AlexWayfer/project_generator)
[![Gem](https://img.shields.io/gem/v/project_generator.svg?style=flat-square)](https://rubygems.org/gems/project_generator)
[![License](https://img.shields.io/github/license/AlexWayfer/project_generator.svg?style=flat-square)](LICENSE.txt)

Base for various CLI generation tools.

## Installation

It's designed as a base for developers to build specific generation CLIs,
so the common way is to add this gem as a runtime gem dependency.

For now it even has no executables.

## Usage

```ruby
require 'project_generator'

## Your specific generator, like a gem generator
module GemGenerator
  ## Inherit it's `Command` (`clamp`s CLI) from `ProjectGenerator::Command`
  class Command < ProjectGenerator::Command
    ## You have to define `NAME` and `TEMPLATE` parameters
    parameter 'NAME', 'name of a new gem'
    parameter 'TEMPLATE', 'template path of a new gem'

    def execute
      ## You can execute logic of a specific generator wherever you want

      check_target_directory

      refine_template_parameter if git?

      process_files

      initialize_git

      FileUtils.rm_r @git_tmp_dir if git?

      done
    end
  end
end
```

Built-in options:

*   `-i`, `--indentation`: indentation type in generated project (`tabs` or `spaces`).

    _Note: please, write templates with tabs to have this option working,
    because we can't safely transform number of spaces into tabs,
    but we can transform tabs into spaces._

## Development

After checking out the repo, run `bundle install` to install dependencies.

Then, run `bundle exec rspec` to run the tests.

To install this gem onto your local machine, run `toys gem install`.

To release a new version, run `toys gem release %version%`.
See how it works [here](https://github.com/AlexWayfer/gem_toys#release).

## Contributing

Bug reports and pull requests are welcome on [GitHub](https://github.com/AlexWayfer/project_generator).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
