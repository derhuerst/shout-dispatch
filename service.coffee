redis =			require 'redis'
async =			require 'async'

Dispatcher =	require './Dispatcher'





# todo
apnCrt = 'abc'
apnKey = 'abc'
gcmKey = 'AIzaSyBBh4ddPa96rQQNxqiq_qQj7sq1JdsNQUQ'   # todo: replace by own; shamelessly taken from https://simple-push-demo.appspot.com/

systems =
	ios:		'apn'
	osx:		'apn'
	safari:		'apn'
	android:	'gcm'
	chrome:		'gcm'
	windows:	'mpns'
	wp:			'mpns'

sub = redis.createClient()
client = redis.createClient()
dispatcher = Object.create(Dispatcher).init apnCrt, apnKey, gcmKey

sub.on 'message', (channel, key) ->
	groupId = key.split(':')[1]
	tokens =
		apn:	[]
		gcm:	[]
		mpns:	[]

	client.get key, (err, message) ->
		if err then return   # todo: error handling
		message = JSON.parse(message).b

		# get every user in the group
		client.keys "u:#{groupId}:*", (err, keys) ->
			if err then return   # todo: error handling
			async.eachLimit keys, 50, ((key, cb) ->

				# todo: use [redis transactions](http://redis.io/topics/transactions) or at least [redis pipelining](http://redis.io/topics/pipelining)
				client.get key, (err, user) ->
					if err then return   # todo: error handling
					user = JSON.parse user
					tokens[systems[user.s]].push user.t
					cb()

			), () ->
				dispatcher.apn tokens.apn, groupId, message
				dispatcher.gcm tokens.gcm, groupId, message
				dispatcher.mpns tokens.mpns, groupId, message

sub.subscribe 'm'   # `m` is for messages
