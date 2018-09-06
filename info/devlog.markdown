some issues ii want to go through soon:

++ make the 'default' theme responsive. verify on multiple device sizes.
++ improve the 'default' theme look & feel for responsivness and ease of use, do the same on the Panel level
++ add BTC payments (scanning an address for a payment, generating an address on the fly, measuring time between the start of checkout and payment or not, when to send item)
++ testing: find the best way to add the ability to test the static site rendering and behavior...(probably involves running the built in hugo server during the test run)
++ testing: add tests for the Panel functionality
++ testing: measure performance of the Panel and optimise accordingly

did some security related improvements:
 + removed the session secret from the panel.yml
 + creating a new rog with deploy settings - can pass usr and host with rog new
 + removed panel.yml from repo, replaced with panel.yml.example
 + removed config.toml from repo, replaced with config.toml.example
 + added a .gitignore entry for both settings files, so that one can have different settings locally and on deployment host

now ii have a small problem, need to make sure, during Travis CI test the config files are present.

#06.09.2018 11:12:02 CodingSession::BEGIN

#05.09.2018 17:04:08 CodingSession::END

working on the default theme, which is a very important building block for the initial webshop framework.
in the future there will be more themes for rog, but first need to get this one going strong.

having fun learning more about Hugo templating, as well as golang.

here's a nice snippet for listing all the taxonomy of a site:
  <section>
    <ul id="all-taxonomies">
      {{ range $taxonomyname, $taxonomy := .Site.Taxonomies }}
        <li><a href="{{ "/" | relLangURL}}{{ $taxonomyname | urlize }}">{{ $taxonomyname }}</a>
          <ul>
            {{ range $key, $value := $taxonomy }}
            <li> {{ $key }} </li>
                  <ul>
                  {{ range $value.Pages }}
                      <li hugo-nav="{{ .RelPermalink}}"><a href="{{ .Permalink}}"> {{ .LinkTitle }} </a> </li>
                  {{ end }}
                  </ul>
            {{ end }}
          </ul>
        </li>
      {{ end }}
    </ul>
  </section>

am playing with the idea that on the SHOP menu ii want to display only up to N items, if there are more, ii want to show a list of categories instead...

am upgrading my setup, installing Go Guru first:
  go get -u golang.org/x/tools/cmd/guru

the above command did not do anything? where's my GOPATH? since it is not explicitly set, go assumes ~/go.

https://alvarolm.github.io/GoGuru/

ctrl+shift+g works, but there is no output from the command. ii'll keep playing with it.

#05.09.2018 10:10:35 CodingSession::BEGIN

#04.09.2018 19:53:40 CodingSession::END

the about page on rubyongo.org is missing, let's add that...

in order to add a page, all ii need to do is add a file inside "content/page/", give it a front matter and run hugo to regenerate the static.
all of this can be done via the panel UI.

hm, having some issues with the panel UI, which was kinda expected, now reviewing and fixing...

not sure why, but this frontmatter entry in an archetype errors out:

  title: "{{ replace .Name "-" " " | title }}"

saying:  line 1: did not find expected key. ii guess .Name should be simply "new", but it's not...
am now upgrading golang and hugo, let's see if the problem persists on the latest and greatest.

golang is now 1.11, and hugo is at 0.48.

installing golang is a matter of extracting a zip: /usr/local> sudo tar -C /usr/local -xzf ~/Downloads/go1.11.darwin-amd64.tar.gz
installing hugo is similar, unzip hugo_0.48_macOS-64bit.tar, then copy the hugo binary to /usr/local/bin.

and yes, now it works. adding the upgraded binaries to sys/src and then ii'll "rogup" and we should have the new stuff online.

nope, got this while pushing: remote: error: File sys/src/go1.11.linux-amd64.tar.gz is 121.27 MB; this exceeds GitHub's file size limit of 100.00 MB
let's see, if ii can get this downloading with ansible...

got it installed on rubyongo.org. the ansible scripts are very rough right now, I can improve that later, let's move on with the panel..

nope, after the upgrade the path /item returns: Not found
but only on the web host, locally it works. this is one of those moments in programming when you want to destroy something...

if ii access https://rubyongo.org/item, it does not find it,
but adding a trailing slash https://rubyongo.org/item/, works?

must be some kind of server problem, checking my .htaccess... nah, the problem was in config.toml, ii added the slash there:

  [[menu.main]]
      name = "Shop"
      url = "/item/"
      weight = 5

exploring further, the images in the shop section do not appear ~ checking.

the rog_logo.png image was missing. added and now it works nicely.

and yes, there is still plenty of little details to work through. little steps and the larger picture will come alive...

#04.09.2018 15:04:54 CodingSession::BEGIN

#04.09.2018 13:44:27 CodingSession::END

good morning, working on the "rogup" script...

at #04.09.2018 11:33:29 I can access rubyongo.org static site. but it seems to not load javascript correctly, investigating...

adding deploy script "rogd".

right now, all these scripts need to be run from the "sys" folder. later these will be spawned from the main "rog" CLI. something like: "rog deploy", "rog init", "rog up"...

oh yes, javascript loading fixed from config.toml by adjusting the baseURL = "https://rubyongo.org/" to "https".

we now have a working rubyongo.org static site, with a backend panel running nicely... nope, the ruby part is not yet up, getting:

  Undefined local variable or method `git_source' for Gemfile
          from /home/rubyongo/rubyongo.org/Gemfile:3 (Bundler::GemfileError)

am deploying to ruby1.9.3, and bundler is too old:
  bundle -v
  Bundler version 1.3.5

added an ansible task to install bundler on "rogup". also added a "bundle" command to the "rogd" deployment script.

but still no go with the "git_source" method, since we're too old... so let's get rid of it for now.

okay, now ii see this piece of garbage:

  Bundler could not find compatible versions for gem "bundler":
    In Gemfile:
      bundler (~> 1.16) ruby

    Current Bundler version:
      bundler (1.3.5)

  This Gemfile requires a different version of Bundler.
  Perhaps you need to update Bundler by running `gem install bundler`?

but it only happens when running "bundle" command via ssh script. if ii try to gem install bundler from the rogd script, ii get:

  ERROR:  While executing gem ... (Gem::FilePermissionError)
    You don't have write permissions into the /var/lib/gems/1.9.1 directory.

so am thinking some path is not properly set during ssh script... let's check bashrc and bash_profile...
actually, just printing out with export shows this path: GEM_PATH="/usr/lib/ruby/gems/1.8", but it should be something else...

forced the proper paths, but still getting the above problem. removing the bundler version from gemspec, and let's see if that makes a change...

it worked, and it is using bundler 1.3.5 during bundle, crazy... sshing in and doing gem list bundler, it shows:

  *** LOCAL GEMS ***

  bundler (1.16.4)

so where does bundler 1.3.5 come from, during ssh script run? it's here: /usr/lib/ruby/vendor_ruby/gems/bundler-1.3.5/lib

hitting the next problem:

No such file or directory - log/production.log (Errno::ENOENT)
  /home/rubyongo/rubyongo.org/lib/rubyongo/panel/kit.rb:27:in `initializ

ok, let's create the log dir...

panel is up at #04.09.2018 13:43:06.

#04.09.2018 09:00:26 CodingSession::BEGIN

#03.09.2018 17:00:27 CodingSession::END

back at it. re-focusing. what to do first.

ii want to start spinning up the first shop, but have not yet done the deployment stuff... so doing it today...

have the init script up and running. ii did a run on rubyongo.org, as expected ii am seeing this:

    Undefined local variable or method `git_source' for Gemfile
        from /home/rubyongo/rubyongo.org/Gemfile:3 (Bundler::GemfileError)

so tomorrow will be continuing with the "rogup" script, which will run Ansible scripts and setup ruby, go, etc...

#03.09.2018 09:18:18 CodingSession::BEGIN

#08.06.2018 22:44:16 ComSession::END

the mountain was epic, now let's build an epic shop.

am thinking about bitcoin payments... if ii use the transaction id ii will be vulnerable to malleability. requesting the transaction id from the customer is also reducing privacy for both parties. so am thinking it is better to generate a new address for each possible transaction (shop item with a price) and check that enough bitcoin was transfered to that address in some timeframe.

...

so many options to choose from, APIs all over, but nothing quite what I want.

need to do more research.

#08.06.2018 08:41:14 ComSession::BEGIN

#06.06.2018 09:39:39 CodingSession::END

ii am heading out for a walk in the mountains, can't help my self not to do some quick edits...

little steps can climb mountains. :) and off for an epic walk..

#06.06.2018 08:30:07 CodingSession::BEGIN

#05.06.2018 19:20:10 CodingSession::END

working on the logo...

realised ii need to develop the theme with sass... so installing:

  > brew install --devel sass/sass/sass

nope, does not work!

had to do it like this:

  > brew install sass/sass/sass

obviously this also installs dart. so if one wants to use sass in a theme, it's up to the theme developer.
ii will not integrate sass, just provide some examples on how to use it in a theme...

one could also do:

  > gem install sass

which would install the ruby sass... but the newest sass is dart-sass, so using that one.

watching files during theme development:

  > sass --watch themes/default/assets/:themes/default/static/css/

what? that gives me: `Could not find an option named "watch".`

oh, surely dart-sass does not support the --watch flag yet: https://github.com/sass/dart-sass/issues/264

so changing plan here... let's just use the ruby sass for now...

and nope:

  Fetching: sass-3.5.6.gem (100%)
  ERROR:  Error installing sass:
    sass requires Ruby version >= 2.0.0.

so what can I do to stay on ruby 1.9.3? just ditch the damn thing? nah, ii need to move on,... so ok, ii'll use the dart-sass and run it manually for now...

more trouble... after generating, ii get the following subfolder: `themes/default/css/sass`, why is it doing this?

because ii need to write:

  > sass themes/default/assets/sass:themes/default/static/css/

and this finally worked.

for some reason, Chrome does not load the new stylesheet, what is going on? clearing the cache helped.

created a quick build command for my Sublime Text 3 editor... when ii make a change in the sass file ii can hit `cmd+b` which runs this:

  {
    "cmd": ["sass", "--update", "$file:${file_path}/../../static/css/${file_base_name}.css"],
  }

this is enough for now, ii can quickly edit the sass and generate the css too.

btw, [seeing golang variables in a hugo template is a matter of printing them out](https://discourse.gohugo.io/t/howto-show-what-values-are-passed-to-a-template/41)

plus... after plenty of re-evaluating and cleaning up the initial code ii had from before, removing, removing... less is more...

at this point ii don't care what you think about this software, ii am writing it to make money with it.

let me do a quick commit, before ii continue...

it is amazing how much investigation ii have to go through before ii can combine my old code with improvements.

but that is how programming works.

ii am attempting to understang what this .singlepage concept is. ii can not remember, ii did not document it.

so what is this:

  {{ partial "header.html" . }}
  <div class="singlepage">
    {{ partial "item-content.html" . }}
  </div>
  {{ partial "footer.html" . }}

why did ii have to do this in the mojerokavice.com webshlop... ii have to investigate...

the difference from this:

  {{ partial "header.html" . }}

  {{ partial "cart.html" . }}

  <div class="container">
      <div class="">
          <!--{{ partial "item-header.html" . }}-->

          {{ partial "item-content.html" . }}

          {{ partial "item-footer.html" . }}

          {{ partial "disqus.html" . }}
      </div>
  </div>
  {{ partial "footer.html" . }}

VS the shorter `.singlepage` version is in just a different layout. ii am confused, because ii am joining a few hugo themes into one and that is why ii have slightly different views setup. ii simply need to take the most recent one and evaluate against the older one, and then make a better and simpler one... haha... this should then work.

So visit yum/yum/:

  http://localhost:1313/yum/yum/

and see where this is rendered from.

It is rendered via the default type "_default".

Every folder you create inside `content`, is a "type".

A type of content one might say. Or a type of item.

The possible arbitrary types are all rendered with the _default/ templates.

So simply create all possible types in your theme and get different behavior based on the type of the data being viewed/rendered.

The content folder reflects the theme/layout folder, and also vice versa.

#05.06.2018 10:01:19 CodingSession::BEGIN

#04.06.2018 11:20:35 CodingSession::END

started working on the Ruby On Go website.
it's going to be part of the gem it self.
but still have some miles to run, before ii can deploy...

ii have been doing catching up with Hugo. when ii first worked with it, it was 0.14, now it is 0.42, so some things have changed, well not changed, just have even more options now...

after this week ii should be able to deploy the Ruby On Go website, and then on to spinpaintings.shop...

#04.06.2018 09:07:23 CodingSession::BEGIN

#01.06.2018 23:27:46 ComSession::END

after the quick morning commit session ii then took a test for a dayjob.

had a friend come around, so only got around to setup the travis build badge.

#01.06.2018 23:20:34 ComSession::BEGIN

#01.06.2018 10:33:16 CodingSession::END

commited most of the existing code.

#01.06.2018 09:03:43 CodingSession::BEGIN

#31.05.2018 23:23:11 CodingSession::END

preparing next commit some more...

nope can't commit yet, still have one more thingy to make more overridable.

not polished, but it will do.

#31.05.2018 22:05:16 CodingSession::BEGIN

#31.05.2018 19:46:01 CodingSession::END

am now preparing the panel and getting ready to start building out the rubyongo.org website with it self.

at #31.05.2018 16:50:39 the Panel UI loads nicely. right now the public folder for the Panel is inside the gem's lib folder, but ii think ii want to have the Panel's public combined with the static public, so that it can be modified by the framework user. it would be nice to be able to override, but right now ii don't see an out of box solution for having multiple public folders...

took a quick look at sinatra's handling of static file serving and it seems like it could easily be enhanced to allow multiple public folders... ii could also use [this rack middleware](https://github.com/rack/rack-contrib/blob/master/lib/rack/contrib/try_static.rb), so let's move on for now, and ii'll decide on this a bit later...

have it working at #31.05.2018 17:44:15, two public folders, the one from the user is preffered, this completes all override points. the panel can now be fully customized by the framework user.

ii can now make some plans... ii could now work on (probably in this order):

+ create the initial rubyongo website
+ add ansible scripts and setup deployment commands
+ deploy the initial rubyongo website
+ add and fixup the Mauler (MVP: be able to send emails from the deployed app)
+ finish and fixup the default theme (MVP: blog, shop, contact, about, pp, tc, sitemap)
+ add initial bitcoin payments support (MVP: generate your address, and the panel can check if payment went through)
+ add bitcoin merchant (MVP: configure a node to talk to, be able to generate addresses and confirm payments)
+ add the go backend example (MVP: jwt token authentication server and upload microservice)

ok, that's enough for a very long week(month ahead). at #31.05.2018 18:05:42 am looking at the sys scripts figuring out how to modify them for public usage. right now ii have them configured for the kitschmaster.com platform, but that platform is still private, so need to use github and that should do the trick.

so how to pull this one off. what should ii finish up first, before making the push to github?
darn, ii still need to commit my second commit. let me commit now at around #31.05.2018 18:08:33...

unfortunately, since ii upgraded Hugo yesterday, my initially developed theme is not fully functional,

running `hugo -v` reveals a bunch of warnings... and this is also a task:

+ capture output of the `hugo -v` command during publishing through the Panel UI --> Publish button.
  simply make the last result available for viewing via a link near the button.

most of the warnings are of this type: "Unable to locate layout for ...".
so am thinking ii need to revise and compare my theme with a newer one.

after some reading around, ii simply added this line to the config.toml:

    theme = "default"

and now the rendering worked.

am down to 3 warnings, which ii can resolve later:

WARN 2018/05/31 18:29:56 No translation bundle found for default language "en"
WARN 2018/05/31 18:29:56 Translation func for language en not found, use default.
WARN 2018/05/31 18:29:56 i18n not initialized, check that you have language file (in i18n) that matches the site language or the default language.

+ add language support to the backend?

let me check if the site works, and then do the commit dance.

ii have the first post. that should do it.

still editing details for the second commit... it's already at #31.05.2018 19:04:00.

ii should stop here and take a break until tomorrow.

second commit done, and another one to fix my typos...

and another one for a good measure.

ii also wrote this, but then deleted it from the README:

Ruby On Go can also serve dynamic content and run your microservices. Choose your favourite JS frontend framework, build your UI, create a Hugo theme with it and throw that into a Ruby On Go `theme` folder, deploy it to a cheap host, and then edit the content via the Panel UI, or let the owner edit the content by him self... get a small percentage from the bitcoin sales from each shop you create and job well done for everyone.

#31.05.2018 15:01:45 CodingSession::BEGIN

#28.05.2018 13:21:31 CodingSession::END

Coding... here's the current workflow when setting up a new site:

  `rog new my_new_site`
  `cd my_new_site`
  `rake test`
  `rog s` # start panel
  `hugo server --bind 0.0.0.0 --baseURL="http://192.168.1.111/"` # start static server

there is now a `gen` folder containing: Gemfile, Rakefile and example tests, all of which is copied into the new site.

so more or less, things are ready for basic development. now need to verify the panel works and settings are picked up and so forth...

should the command `rog start` also run the hugo static server? let's see how this would work in practice.

ii went with an additional command `rog h` to start up the hugo server...

#28.05.2018 10:07:06 CodingSession::BEGIN

#22.05.2018 17:29:56 CodingSession::END

Code reloading works, panel code can be overriden. Setting up the panel views...

Testing... have a small problem testing Guru creation - guessing a development DB needs to be setup...
The Guru is a DataMapper::Resource, so let's see...

The DB is currently set up with: `DataMapper.setup(:default, "sqlite://#{EXEC_PATH}/db.sqlite")`

Let's see what this path is during test. Yup it's fine: `sqlite:///Users/mihael/opensource/rubyongo/db.sqlite`
But still, when running this:

    guru = Rubyongo::Guru.first(:username => 'guru')

a nil is returned. Which is correct, since the default user is created from the config file, and there we have 'rubyongo' as the username. So seems like it already works, the question is, should there be a development DB with a different username/pass...

Well, there has to be a way to test the framework code and a way to test the framework user's code.

yup, there was.

#22.05.2018 12:54:55 CodingSession::BEGIN

#16.05.2018 18:55:04 CodingSession::END

coding all over, mostly just moving code around to make it work like a gem...

#16.05.2018 13:52:32 CodingSession::BEGIN

#15.05.2018 12:55:04 CodingSession::END

coding... took the initial code ii had built as a working prototype (used to deploy and edit http://atejas.org). And am now rewriting/rewiring it to be a gem.

ii will push to github.com/kitschmaster/rubyongo, but only after ii get the spinpaintings.shop setup with it.

#15.05.2018 09:52:32 CodingSession::BEGIN

#14.05.2018 12:11:10 ComSession::END

freaking month went by before ii took the chance and shot the paintings.

but ii now have the content, finally. ii ended up avoiding the shooting and doing so many other things.

ii have to make an over the spinning wheel setup. so ii can shoot the image while spinning. and forget about the photography studio.

taking super nice images of 59 paintings took the whole morning. and then one more afternoon to edit and cut out perfect rectangles from the analog images.

and now at #14.05.2018 10:48:12 ii realise ii did not edit 25 images at least. so doing it now...

getting back at the machine is so hard in these sunny days. little by little, and it'll get there.

never surrender.

the quality of the images is not very good. ii was shooting with a Canon PowerShot SX130IS. it's rated 12.1 mega pixels. lol

anyway, ii now want to build a real shop.

but ii want to document the steps this time.

and whilst ii document see what can be improved.

it is good ii did not touch the code for a long time.

ii now have the fresh mind and can critique my old code.

but first thing is first. kit.org does not sound well.

and so "Ruby On Go" was born. whooohooo!

and now let's see how ROG works. and let's also improve and inovate along the way...

one day ii should write an article on atejas.org with the title: atejas dam na rog?

how does google translate: "a te jas dam na rog?"

today ii bought rubyongo.org, and spinpaintings.shop for $16.90.

better make it happen now. :)

at #14.05.2018 11:25:36 ii have all 59 images edited to 1850x1850px.

right now the sys part of rog is not included in the repository. but we need it for any serious open sourcing.

just need to keep credentials out of it first. so that's a task:

+ move any credentials out of the repo.
 - sys/keys contains credentials.

#the ansible scripts

## roginit

after buying the domain, one can run the init script included in the sys folder.

name="$1@$2"
repo="$2"

`roginit rubyongo@rubyongo.org`

where repo equals "rubyongo.org".

this will then do the following:

1. check if `keys\rubyongo@rubyongo.org` already exists, and if so, stop
2. since the above key is not found, a ssh connection is made to the supplied argument and the folder `~/.ssh` is established and set up for ssh-access with your local`~/.ssh/id_rsa.pub` copied to `~/.ssh/authorized_keys` on the remote machine.
3. on the remote machine a ssh key is generated and
4. then the public part is fetched down locally and saved in the `keys` folder

have to run...

#14.05.2018 09:59:14 ComSession::BEGIN

#14.04.2018 08:28:59 ComSession::END

time is flying. ii have to cut down on some of the ideas and just start pushing through.

ii have setup a small DIY product shooting spot in my office
to create the content for the following two shops:

1. Potters paintings - spin paintings
2. Soča riverbed stone incense burners

need to generate a bitcoin address for each item.

also need to get the codebase into a documented state...

renamed the project from kit.org to kit/org. but today ii am renaming it to kitorg, for easy typing.

#14.04.2018 07:51:36 ComSession::BEGIN

#07.03.2018 12:10:31 ComSession::END

it seems like ii will have to run a full node, in order to be able to accept payments for any shop built with kit/org.

https://www.reddit.com/r/Bitcoin/comments/81h1oy/the_merchants_guide_to_accepting_bitcoin_directly/

https://en.bitcoin.it/wiki/Lazy_API

how to do it over at digitalocean: https://medium.com/signal-chain-weekly/how-im-running-a-bitcoin-full-node-on-digital-ocean-for-40-a-month-dfc328ba9604

#07.03.2018 10:10:25 ComSession::BEGIN

#05.03.2018 22:33:24 ComSession::END

let's say there's an item archetype:

+++
weight = ""
measures = ""
sku = ""
title = ""
date = ""
description = ""
author = ""
price = ""
shipping_price = ""
tax = ""
quantity = 1
assets = []
tags = []
categories = []
+++

now we want to automate the creation of this.

by writing the above it should be possible to create a form from it.

and then this form can be shown in the UI, for any device.

then artist uploads an image and fills out the rest and hits the sendit button.

a folder with the date is created and content .md file is created within, plus the assets are moved into.

this is not yet published? or should it be published? no it should not, so that QA can be done.
therefor after creating take the artist straigth to preview, and let him edit until he hits the publish button.

Archetyper.read theme/archetypes

In order to [read toml frontmatter, use this](https://github.com/jm/toml)

#05.03.2018 21:55:26 ComSession::BEGIN

#05.03.2018 00:19:41 ComSession::END

ii parted from my dayjob, but ii promised them ii will let them review this project. open source is for everyone, after all anyway! :)

[here's all about undoing with git](https://blog.github.com/2015-06-08-how-to-undo-almost-anything-with-git/)

and [here's a gem to deal with the dreamhost API](https://github.com/jerodsanto/dreamy). and we will soon have a very cool framework, that can run on cheep shared hosts, yet still look fast on the surface.

later adda a feature to push assets to CDN and voila, kit/org for all artists, very very cheeply and highly productive. and then some more.

#04.03.2018 22:40:50 ComSession::BEGIN

#15.02.2018 22:40:30 ComSession::END

what have ii done, ii set a date for me to deliver a plan to my dayjob company.

ii think ii have that plan. reviewing it now...

#15.02.2018 21:16:37 ComSession::BEGIN

#18.12.2017 23:43:34 ComSession::END

me, huh? today ii offered my code, well ii gave the second teaser to my dayjob company. maybe ii can get the company ii work for professionally to actually consider my product as a solution for their problematic client.

therefor, ii have to present it in a nice way and applicable to their use case. present the architectural benefits.

or maybe not?

have to decide.

#18.12.2017 19:51:12 ComSession::BEGIN

#17.06.2017 18:35:21 CodingSession::END

modernized the spec, have macos and linux option for sending email...

branch email_sending contains the mauler and the upgrades to the gemfile, incompatible changes with dreamhost.

need to get the panel stuff out of public folder, so that public can be fully regenerated by hugo.

seeing files in the current git branch under version control: `git ls-tree -r HEAD --name-only`

#17.06.2017 14:15:07 CodingSession::BEGIN

#09.06.2017 22:55:41 CodingSession::END

hocem zmagat. pa se tako nemocno pocutim. a naj kar rinem se naprej... itak.
ii want to win, but ii feel helpless, should ii progress... sure, a little at least.

http://www.binarytides.com/linux-mailx-command/

#09.06.2017 22:52:01 CodingSession::BEGIN

#02.02.2017 23:16:30 CodingSession::END

sprobal spec, in mi breaka app setup na dreamhostu. ne bo slo specifikacij pushat tja gor, je treba nek submodule al neki...
plus, `mail` je drugacen na osx kot na dreamhost linuxu, ma druge parametre, tako da ga nemren stestirat, osti jarej ki naj zaj.

a res ni nacina? kaj pa gmail gem, ki sem ga uporablo 2010?
is there no way to send emails from dreamhost with ruby... what about gmail gem?

#02.02.2017 20:16:24 CodingSession::BEGIN

#20.01.2017 01:05:09 CodingSession::END

added rspec for real testing to begin...

added Mauler initial class for sending emails via command line...

#20.01.2017 01:04:49 CodingSession::BEGIN

#13.12.2016 22:37:41 CodingSession::END

ruby config.ru works. but ruby kit.rb does not bind, and does not setup any routes? yup

always verify Settings when something does not work.

we have two Settings:

static site generator hugo settings: config.toml
sinatra settings: kit.yml

simpleCart settings are in hugo config.

checkout:

+ ime
+ priimek
+ email
+ address1
+ city
+ postcode
+ country
+ telephone
+ davcna
+ naziv podjetja

+ scripts.html: write function to read form values and send off to url
+ send email
+ log order

+ size, plus and minus buttons on Dodaj v kosarico

v item_content, dodas select,

+ add keywords: protivrezne, protiurezne

#13.12.2016 17:37:36 CodingSession::BEGIN

#24.11.2016 19:40:39 CodingSession::END

need gridshop_history.txt

+ stock
- stock

+ Item interface
+ simpleCart save customer / local storage
+ simpleCart send order

#24.11.2016 18:40:26 CodingSession::BEGIN

#09.11.2016 12:48:43 CodingSession::END

push code...

kitd?

#09.11.2016 11:25:19 CodingSession::BEGIN

#14.10.2016 21:20:09 CodingSession::END

contact form
contact list

#14.10.2016 13:26:40 CodingSession::BEGIN

#26.09.2016 23:26:10 CodingSession::END

sending mail? yes...

`mail -s "the process has been finished" abc@xyz.com<<EOM
  The process has finished successfully.
EOM`

#26.09.2016 20:59:45 CodingSession::BEGIN

#16.09.2016 19:10:28 CodingSession::END

using data with hugo:

        <ul id="og-grid" class="og-grid">
          {{ range $.Site.Data.items.items }}
          <li>
            <a href="{{.url}}" data-largesrc="{{.image}}" data-title="{{.title}}" data-description="{{.description }}">
              <img src="{{.thumb}}" alt="{{.alt}}"/>
            </a>
          </li>
          {{ end }}
        </ul>

ii set up mojerokavice.com!

runnning a sinatra app, one can use: `rackup`

#15.09.2016 16:20:03 CodingSession::BEGIN

#16.08.2016 20:49:46 CodingSession::END

golang needs to be in the path...

  export GOPATH=$HOME/go
  export PATH=$PATH:$GOROOT/bin:$GOPATH/bin

GOPATH is go's "workspace", where it downloads packages.

  export GOPATH=~/Mx/kit/kit.org/lib/gosrc/

#16.08.2016 20:30:56 CodingSession::BEGIN

#12.05.2016 11:08:21 CodingSession::END

testing... go test ./tests/api_tests/auth_middleware_test.go

where to put the settings for the backend JWT keys... settings/tests.json

  "PrivateKeyPath": "/home/vagrant/go/src/api.jwt.auth/settings/keys/private_key",
  "PublicKeyPath": "/home/vagrant/go/src/api.jwt.auth/settings/keys/public_key.pub",

replacing the redis client with sqlite... go get github.com/mattn/go-sqlite3

#12.05.2016 09:07:53 CodingSession::BEGIN

#11.05.2016 17:56:34 CodingSession::END

running the go wo package:
export APP_ADDR=0.0.0.0:8080
go run  go.wo

jwt auth + taking orders and pushing them into the db...

how to test...

#11.05.2016 11:06:37 CodingSession::BEGIN

#03.05.2016 17:49:59 CodingSession::END

shopping cart should look nice...

run hugo locally, but still accessible from locla wi-fi via iDevices...

  hugo server --bind 0.0.0.0 --baseURL="http://192.168.1.111/"


#20.04.2016 10:05:18 CodingSession::BEGIN

#19.04.2016 22:48:01 CodingSession::END

<script>
  (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
  (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
  m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
  })(window,document,'script','https://www.google-analytics.com/analytics.js','ga');

  ga('create', 'UA-76625974-1', 'auto');
  ga('send', 'pageview');

</script>

#19.04.2016 20:47:56 CodingSession::BEGIN

#11.04.2016 22:49:05 CodingSession::END

creating template for items...

can now edit site...

#11.04.2016 18:49:29 CodingSession::BEGIN

#09.04.2016 22:49:18 CodingSession::END
creating sys scripts:

kitinit atejas atejas.org
kitup atejas atejas.org

running sass: sass input.scss output.css

theme sass: `cd themes/_path && sass assets/sass/style.scss static/css/style.css`

watching: `sass --watch themes/_path/assets/sass:themes/_path/public/css`

publish button has to run sass generator as well, so publish is:

1. run assets precompilers
2. run hugo static genesis
3. update guru

#09.04.2016 09:44:18 CodingSession::BEGIN

#08.04.2016 20:44:05 CodingSession::END

looking at today's dedicated server prices:

+ 300/mo (1 leto 220/mo)

serverloft.eu

+ Xeon 6 cores ECC4 32GB 2x256GB SSD 1Gbit link 79/mo

server4you.com

Skylake SSD XL9
64GB DDR 4
intel Core i7-6700K
Skylake SSD XL9
Software-Raid 1
2x 250GB SSD $67 - can pay with paypal

this is not for everyone.

ii need to be able to deploy to cheap.

#08.04.2016 15:50:59 CodingSession::BEGIN

#24.03.2016 14:41:57 CodingSession::END

jstree is working nicely, now need a markdown editor...

https://github.com/jbt/markdown-editor

#24.03.2016 09:41:32 CodingSession::BEGIN

#23.03.2016 18:41:21 CodingSession::END

woke up early, being git pulled into this code... let's add uploading through sinatra...

btw, just think about the framework name, or the VIP name. sin at ra. the ra worshippers build our frameworks. how hard is it to write a ruby Rack enabled server... it's too easy, and the code is open, so let's sin at ra.

gem install sinatra-contrib to get extras, like `config_file 'config.yml'`

not using `require_relative 'atejas'` inside config.ru

instead of doing `run Sinatra::Application` ii am making it modular with

run Rack::URLMap.new({
  "/" => Pub,
  "/a" => Pro
})

rerun seems the way to go with Sinatra reloading code...

    gem install rerun

mu:~/Mx/kit/atejas.org> echo -e "HEAD / HTTP/1.0\n\n" | nc atejas.org 80
HTTP/1.1 200 OK
Date: Wed, 23 Mar 2016 08:56:53 GMT
Server: Apache
Last-Modified: Sat, 01 Nov 2014 04:18:40 GMT
ETag: "304-506c4687e0800"
Accept-Ranges: bytes
Content-Length: 772
Connection: close
Content-Type: text/html

[how to bypass basic auth](http://armoredcode.com/blog/bypassing-basic-authentication-in-php-applications/), which ii have implemented, and dont like...

run sinatra console: bundle exec irb -I. -r atejas.rb

#23.03.2016 08:01:31 CodingSession::BEGIN

#22.03.2016 23:59:13 CodingSession::END

got go for upload and serve atejas.org, but despite all speed and ease of setup, ii don't like google, and ii don't like the ugly satanic gopher... what about my dear ruby, can ii run 4.2 rails at dreamhost... yes ii can, but do ii want... there's swift...

https://github.com/tbuehlmann/sinatra-fileupload
https://github.com/shopmaker-com/html5-upload/
https://github.com/maca/sinatra-xhr-upload-example
http://recipes.sinatrarb.com/p/middleware/rack_auth_basic_and_digest

http://recipes.sinatrarb.com/p/middleware/rack_auth_basic_and_digest

#22.03.2016 11:53:04 CodingSession::BEGIN

#21.03.2016 15:32:39 CodingSession::END

added bulletproof image uploader to atejas.org, had to manually update git submodule...

tullibardine:~/atejas.org> cat .gitmodules
[submodule "src/bulletproof"]
  path = src/bulletproof
  url = https://github.com/samayo/bulletproof.git
tullibardine:~/atejas.org> git submodule init
Submodule 'src/bulletproof' (https://github.com/samayo/bulletproof.git) registered for path 'src/bulletproof'
tullibardine:~/atejas.org> git submodule update
Cloning into 'src/bulletproof'...
remote: Counting objects: 1475, done.
remote: Total 1475 (delta 0), reused 0 (delta 0), pack-reused 1475
Receiving objects: 100% (1475/1475), 784.71 KiB | 1008 KiB/s, done.
Resolving deltas: 100% (523/523), done.
Submodule path 'src/bulletproof': checked out 'd09fc36f4b195b672c5bce3aa00f87da83d173ac'
tullibardine:~/atejas.org>


[go for shared hosting](https://github.com/bsingr/golang-apache-fastcgi)

#21.03.2016 09:20:10 CodingSession::BEGIN

#15.03.2016 13:53:04 CodingSession::END

went with sinatra instead of rails, since Dreamhost is still running ruby 1.8.7.

mojerokavice.com
atejas.org

#15.03.2016 13:51:59 CodingSession::BEGIN

#08.09.2015 00:43:21 CodingSession::END

decided to go with hugo.

hugo is going to be the static site generator per artist,
rails is going to be the backsite, where the artist enter data.

a hug-o-rails web site generating program.

  hugo new site kitgo

installing this: https://github.com/digitalcraftsman/hugo-artists-theme

coding...

#07.09.2015 21:41:41 CodingSession::BEGIN

#20.04.2015 10:35:27 CodingSession::END

ii wish ii had a webshop framework... ii want the frontend to be fully static, ii want the content decoupled from backend code...

just reading https://www.digitalocean.com/community/tutorials/how-to-deploy-a-meteor-js-application-on-ubuntu-14-04-with-nginx...

#20.04.2015 10:35:16 CodingSession::BEGIN