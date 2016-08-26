---
layout: post
title:  "Authentication From Devise To A Django Database"
date:   2016-08-25 15:28:08 -0600
comments: true
disqus_url: "http://fridgerator.github.io/2016/08/26/authentication-from-devise-to-a-django-database.html"
disqus_identifier: "/2016/08/26/authentication-from-devise-to-a-django-database.html"
---

Because of the awesomeness of the [Rails Admin](https://github.com/sferik/rails_admin) gem I recently had to connect a rails app using [Devise](https://github.com/plataformatec/devise) to an existing Django application database.  Django comes with a barebones admin much like padrino, and I'm sure there are Python libraries to extend the functionality of it.  But I already know how to use Rails Admin and the process of creating a new rails app, getting the rails admin gem in and deploying on an ec2 instance through elastic beanstalk takes literally 5 minutes.

Obligatory beer pic. (this stuff is my jam lately, and comes in a 15 pack)

![beer again](http://i.imgur.com/bd2bApn.jpg)

I should specify I'm using Rails 5.0, the Django application is 1.8.4

My first instinct was to reverse-engineer the Django authentication method to figure out the hashing scheme, then replicate it in Rails.  Fortunately enough, after some hellacious googling I came across this tasty little gem [pbkdf2_password_hasher](https://github.com/aherve/pbkdf2-password-hasher).  [aherve](pbkdf2_password_hasher) had already done the heaving lifting for me!  Cheers bro.

Here's what my User model looks like:

```ruby
class User < ApplicationRecord
	self.table_name = 'auth_user'

	devise :database_authenticatable, :registerable,
		:recoverable, :rememberable, :trackable, :validatable

	attr_accessor :encrypted_password, :current_sign_in_at, :remember_created_at, :last_sign_in_at,
		:current_sign_in_ip, :last_sign_in_ip, :sign_in_count

	def valid_password?(pwd)
		Pbkdf2PasswordHasher.check_password(pwd, self[:password])
	end

	def encrypted_password
		self[:password]
	end

	def encrypted_password=(pwd);end
end
```

Booyakasha.

![booyakasha](http://minnesotaconnected.com/wp-content/uploads/2014/02/Da-Ali-G-Show-Returns-to-Television.png)

 Any fields that Devise might be trying to access that don't exist, I simply added a `attr_accessor` for, except `encrypted_password` which I had to map to the existing hashed password field, in our case `password`.

 I had to override Devise `valid_password?` method to return the result of the pbkdf2_password_hasher `Pbkdf2PasswordHasher.check_password` method.

 Hope this helps somebody.