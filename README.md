# event_single

Ce front-end HTML permet d'interroger un broker rabbitmq, ce dernier devra mettre en œuvre les plugins gen_smtp et broker_email

Par le fichier Makefile

DEPS = rabbit_common rabbit gen_smtp $(PLUGINS) $(ADDITIONAL_PLUGINS)
dep_gen_smtp = git https://github.com/fulc927/gen_smtp/ master
dep_broker_email = git https://github.com/fulc927/broker_email/ main
BUILD_DEPS += gen_smtp broker_email

