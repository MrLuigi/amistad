# amistad

Amistad adds friendships management into a rails 3.0 application. it supports ActiveRecord 3.0.x, Mongoid 3.0.x and MongoMapper 0.12.0.

This custom version is based upon the original Amistad vers. 0.9.2 and simply adds 3 sharing boolean flags to the Friendship model (currently, only for ActiveRecord: the MongoDB/MongoMapper implementation is still missing in the current version).
 

## Installation

Add the following line in your Gemfile:

    gem 'amistad'

Then run:

    bundle install


## Usage

Refer to the [wiki pages](https://github.com/raw1z/amistad/wiki) for usage and friendships management documentation.


## Notes on this Custom Version

Customized for Goggles Framework vers. >= 4.00.200

Usage for quick reference (ActiveRecord only):

	> rails generate amistad:install
	> rake db:migrate

	class User < ActiveRecord::Base  
  	  include Amistad::FriendModel
	end

Any User requesting a friendship is considered a _"friendable"_.

Any User accepting a friendship is considered a _"friend"_.

Any created and persisted Friendship instance can be blocked by another User and it can have a _"pending"_ status until approved. 


### Friendship model added/modified methods

Additional fields:

	- shares_passages (:default => false, :null => false)
	- shares_trainings (:default => false, :null => false)
	- shares_calendars (:default => false, :null => false)


### Friend model added/modified methods

Check out the sources or the generated RDocs for detailed info about the following methods.

#### Basic friendship request/response methods:

	- Friend#invite(user, shares_passages = false, shares_trainings = false, shares_calendars = false)
	- Friend#approve(user, shares_passages = false, shares_trainings = false, shares_calendars = false)

#### Altered checker/matcher:

	- Friend#==  # => for testing friend identity

#### Wildcard friendship metod getter:

	- Friend#friends( filter_passage_share = nil, filter_training_share = nil, filter_calendar_share = nil )

#### Returning filtered lists of friends:

	- Friend#friends_sharing_passages
	- Friend#friends_sharing_trainings
	- Friend#friends_sharing_calendars

#### Setters for sharing attributes:

	- Friend#set_share_passages_with( user, is_enabled = true )
	- Friend#set_share_trainings_with( user, is_enabled = true )
	- Friend#set_share_calendar_with( user, is_enabled = true )

#### Bi-directional getters for sharing attributes:

	- Friend#is_sharing_passages_with?(user)
	- Friend#is_sharing_trainings_with?(user)
	- Friend#is_sharing_calendars_with?(user)


## Testing

There are rake tasks available which allow you to run the activerecord tests for three rdbms:

    rake spec:activerecord:sqlite
    rake spec:activerecord:mysql
    rake spec:activerecord:postgresql

In order to run these tasks you need to create a confiuration file for the databases connections:

    spec/support/activerecord/database.yml

    sqlite:
      adapter: "sqlite3"
      database: ":memory:"

    mysql:
      adapter: mysql2
      encoding: utf8
      database: <name of mysql database>
      username: <username>
      password: <password>

    postgresql:
      adapter: postgresql
      encoding: unicode
      database: <name of postgresql database>
      username: <username>
      password: <password>

Of course there are some tasks for running mongodb orms based tests:

    rake spec:mongoid
    rake spec:mongo_mapper

The default rake tasks runs the ActiveRecord tests for the three rdbms followed by the Mongoid tests.


## Contributors

* David Czarnecki : block friendships (and many other improvements)
* Adrian Dulić : unblock friendships (and many other improvements)

## Note on Patches/Pull Requests

* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it. This is important so I don't break it in a future version unintentionally.
* Commit, do not mess with rakefile, version, or history. (if you want to have your own version, that is fine but bump version in a commit by itself I can ignore when I pull)
* Send me a pull request. Bonus points for topic branches.

## Copyright

Copyright © 2010 Rawane ZOSSOU. See LICENSE for details.
