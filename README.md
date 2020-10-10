<img src="static/img/rog_logo.png" width="69">

# rubyongo

[![Build Status](https://travis-ci.org/kitschmaster/rubyongo.svg?branch=master)](https://travis-ci.org/kitschmaster/rubyongo)

Welcome to rubyongo ~ a webshop framework.

NOTE: This is still alpha software. It's under construction, but if you love this idea, please check back soon or join [The Manitu Pack](https://manitu.si/page/pack) and contribute!

## Installation

Install the framework:

    $ gem install rubyongo

Please also install the static site generator Hugo:

    https://gohugo.io/getting-started/installing/

You should now be able to run `rog` the rubyongo CLI.

## Quick start usage

### Create a new website:

    $ rog new myawesomeshop.com

This will generate a new rubyongo webshop in the subdirectory `myawesomeshop.com`.

It will also extract your deployment username and hostname from the passed in string. In this case our user is `myawesomeshop` and our host becomes `myawesomeshop.com`.
When you want to customize, pass the deployment username and hostname after the Name string:

    $ rog new myawesomeshop.com custom_user custom_domain.xyz


The generated folder structure is very similar to a regular Hugo static site template with some extra folders and files inside. Included is a __`panel`__ folder for the ruby Panel UI, which is also the place where you write your Ruby code / microservices.

### The three config files

You shall notice these config files:

+ __panel.yml__ ~ ruby microservice backend + Panel UI settings
+ __config.ru__ ~ only needed for Rack type deployment
+ __config.toml__ ~ static site config (Hugo), editable through the Panel UI

You will mostly be editing the Hugo configuration.

### Testing

Write tests in the test folder and run them with:

    $ rake test

### Developing a site

Start the Panel UI + backend app (Sinatra):

    $ rog s

Visit `localhost:9393` to see the panel, edit content...

Edit microservice code in the generated __`panel`__ folder.

Start the static site server (Hugo):

    $ rog h

Visit `localhost:1313` to see the static site.

Edit the content and theme folders. You can use your editor to do this or use the built in backend Panel UI. You can work with the static-site part of a rubyongo project as if working with a regular Hugo project. Read the [Hugo docs](https://gohugo.io/documentation/).

## Deploying static, serving dynamic

rubyongo is designed to "run fast by default", even in cheap memory-poor environments, like shared hosting. It cuts down on deployment costs by staying fully static on the frontend, highly deployable, yet allowing adding microservices at the backend with very little effort.

## Minimal requirements:

+ go 1.6
+ ruby 2.5+
+ the host needs to support running Ruby Rack.
+ Hugo, the static site generator is a dependency currently and is used as the default static site generator.
+ (optional) the host needs to support running go web apps (for example on Dreamhost this is achieved by FCGI). In case you want to run go microservices next to the ruby microservices.

## Deployment system commands

The folder `sys` contains Ansible playbooks and bash scripts to allow setting up domains and deploying to them.

### rog init

After creating a new site you can immediately `rog init` the deployment system and get a fully deployable site in a minute or so. Before initing make sure the following is true:

+ the hosting domain `myawesomeshop.com` is accessible via SSH,
+ the SSH username is named the same as the second-level domain name (`myawesomeshop` in this case) and you have the password ready
+ init sets up SSH key-based authentication, so make sure your localhost has a valid public key in `~/.ssh/id_rsa.pub`
+ your host already has ruby pre-installed, the init script will install go and Hugo

Currently using the sys cli command `rog init` the __`content`__ folder is set up as a separate git repo. This way you get full separation between your code and your content. You can git push your content separately from the code.

#### Caveat

Currently this gem is not yet published. If you want to try out the framework you need to know how to set up a local git repo on your hosting server, so that you can host the gem.

Here's a quick example on how you might do this:


    ssh myawesomeshop@myawesomeshop.com "mkdir repo; mkdir repo/gems"
    cd ~/opensource/kitschmaster/rubyongo; rake build
    scp pkg/rubyongo-0.1.3.alpha.gem myawesomeshop@myawesomeshop.com:~/repo/gems
    ssh myawesomeshop@myawesomeshop.com "cd ~/repo; gem generate_index"

The generated Gemfile should be able to automatically detect your local gem source as long as you put them in `~/repo`:

    source 'file:///home/myawesomeshop/repo' if File.exists?("/home/myawesomeshop/repo") # If there's a custom gem repository available, use it.

### rog equip

This command is already executed during a `rog init`, but you can always re-run it.

It will 'equip' your server environment with whatever you might need by running the main `env.yml` playbook from the sys folder.

### rog deploy

Once inited and well equipped, code can be deployed. You can do that by running `rog deploy` after commiting and git pushing your changes.

You should deploy after making changes in your `panel` folder. This command will also rebuild the static site, not just re-boot the backend.

### rog content

Similar to deploying code, you can deploy content by runnig `rog content`. This will rebuild the static site.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To build the gem run `rake build`.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `ROG_VERSION`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/kitschmaster/rubyongo. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
