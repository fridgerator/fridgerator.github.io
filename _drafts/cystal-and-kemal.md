I've had my eye on the [crystal programming language](http://crystal-lang.org/) for a while now, and I have to say I'm pretty excited about it. Ruby syntax combined with the speed of a statically typed compiled language, common now.  It's compiler is now bootstrapped and [benchmarks](https://github.com/kostya/benchmarks) performances are impressive (yeah I know, benchmark scores don't matter).  I would suggest watching the video on the project's own [Bountysource page](https://salt.bountysource.com/teams/crystal-lang) for a more in-depth look into the language itself.  Here I plan on playing around mostly with the [Kemal framework](http://kemalcr.com/) (seriously those benchmarks though).

<img src="http://i.imgur.com/cjoXet6.png" width=500" />

There is already a decent collection of frameworks and libraries over at [Awesome Crystal](https://github.com/veelenga/awesome-crystal).  Database drivers, a [CSFML](http://www.sfml-dev.org/) wrapper, 3rd party api libraries, etc, and amongst those is Kemal.

Most of my experince is with Ruby, specifically Ruby on Rails.  I've also used both [Sinatra](http://www.sinatrarb.com/) and [Padrino](http://padrinorb.com/), and I enjoyed working with both of those.  I'm going to try and build in a bit of structure to the project: models in a `models` folder, controllers in a `controllers` folder, etc.  This will also be a single page application using [AngularJS](https://angularjs.org/) and Kemal as the JSON api.

<div class="clearfix">
<img src="http://i.imgur.com/NdsrdpE.jpg" height=200 style="float:right" />

Before we get started, I just want to throw this out there.  I'm double fisting New Belgium Ranger and a Mikes Harder Strawberry Lemonade because thats how I roll, gotta hit that <a href="https://xkcd.com/323/">Balmer Peak</a>
</div>

I'm assuming you already have Crystal installed, if not visit their [installation page](http://crystal-lang.org/docs/installation/index.html) follow the instructions per your platform.  I'm using Crystal 0.13.0.

If you want to check out the source for this project, i've stuck it in this repo [fridgerator/kemal_test](https://github.com/fridgerator/kemal_test).

Generating the project was easy enough, crystal has a built in project generator which creates a basic project structure for us `crystal init app kemal_test`.  Then add the require dependencies to the shards.yml file (`kemal`, `active_record`, and `postgres_adapter`).  [Shards](https://github.com/crystal-lang/shards) is a dependency manager similar to ruby gems and the `shard.yml` file looks like a cross between a `Gemfile` and a `package.json` file.  Pretty slick, the crystal project is in alpha stage still and already 13x easier to set up than any node.js application.

For data / domain models, I'm using [active_record.cr](https://github.com/waterlink/active_record.cr).

```ruby
class Post < ActiveRecord::Model
  adapter postgres

  primary id        : Int
  field title       : String
  field body        : String

  def to_h
    {
      id: id,
      title: title,
      body: body
    }
  end
end
```

I didn't use anything special for controllers, just Classes containing route definitions.

```ruby
class KemalTest::Controllers::PostsController
  before_all "/posts" do |env|
    env.response.content_type = "application/json"
  end

  get "/posts" do |env|
    posts = Post.all.map(&.to_h)
    posts.to_json
  end

  ...
end
```

Kemal serves up static files out of `/public`, so I threw my main.js, main.css and angular template files in that directory.