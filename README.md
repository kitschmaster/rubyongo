<img src="static/img/rog_logo.png" width="69">

# Ruby On Go

[![Build Status](https://travis-ci.org/kitschmaster/rubyongo.svg?branch=master)](https://travis-ci.org/kitschmaster/rubyongo)

Welcome to Ruby On Go ~ a webshop framework.

NOTE: This is still alpha software. It's under construction, but if you love this idea, please check back soon or join team kitschmaster and contribute!

## Installation

Install the framework:

    $ gem install rubyongo

Please also install the static site generator Hugo:

    https://gohugo.io/getting-started/installing/

You should now be able to run `rog` the Ruby On Go CLI.

## Quick start usage

### Create a new website:

    $ rog new domain.name

This will generate a new Ruby On Go webshop in the subdirectory `domain.name`.

The folders are very similar to a regular Hugo static site template. They include a `panel` folder for the ruby Panel UI, which is also the place where you write your Ruby microservices.

### The three config files

You shall notice these config files:

+ __panel.yml__ ~ ruby microservice backend + Panel UI settings
+ __config.ru__ ~ only needed for Rack type deployment
+ __config.toml__ ~ static site config (Hugo), editable through the Panel UI

### Testing

Write tests in the test folder and run them with:

    $ rake test

### Developing a site

Start the Panel UI + backend app (Sinatra):

    $ rog s

Visit `localhost:9393` to see the panel, edit content...

Start the static site server (Hugo):

    $ rog h

Visit `localhost:1313` to see the static site.

## Deploying static, serving dynamic

Ruby On Go is designed to "run fast by default", even in cheap memory-poor environments, like shared hosting. It cuts down on deployment costs by staying fully static on the frontend, highly deployable, yet allowing adding microservices at the backend with very little effort.


## Minimal requirements:

+ go 1.6
+ ruby 2.5+
+ the host needs to support running Ruby Rack.
+ Hugo, the static site generator is a dependency currently and is used as the default static site generator.
+ (optional) the host needs to support running go web apps (for example on Dreamhost this is achieved by FCGI). In case you want to run go microservices next to the ruby microservices.

## Deployment system commands

The folder `sys` contains Ansible playbooks and bash scripts to allow setting up domains and deploy to them.

TODO

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To build the gem run `rake build`.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `ROG_VERSION`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/kitschmaster/rubyongo. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
