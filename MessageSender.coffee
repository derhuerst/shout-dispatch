push =			require 'push-notify'





module.exports =



	_apn:		null
	_gcm:		null
	# _mpns:	null



	init: (apnCrt, apnKey, gcmKey) ->
		if not apnCrt then throw new Error 'No APNS certificate passed.'
		if not apnKey then throw new Error 'No APNS key passed.'
		@_apn = push.apn
			cert:		apnCrt
			key:		apnKey
		@_apn.on 'transmissionError', (err) ->
			console.error err.toString()

		if not gcmKey then throw new Error 'No GCM API key passed.'
		@_gcm = push.gcm
			apiKey:		gcmKey
			retries:	5
		@_gcm.on 'transmissionError', (err) ->
			console.error err.toString()

		# todo: mpns

		return this



	apn: (devices, group, text) ->
		for device in devices
			console.info 'apn', devices, group, text

		# todo: batch call possible?
		for device in devices
			@_apn.send
				token:	device
				alert:	group + ': ' + text

	gcm: (devices, group, text) ->
		for device in devices
			console.info 'gcm', devices, group, text

		if 'string' is typeof devices then devices = [devices]
		@_gcm.send
			registrationId:		devices
			notification:
				title:			group
				body:			text

	mpns: (devices, text) ->
		# todo
