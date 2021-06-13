PROJECT = event_single
PROJECT_DESCRIPTION = New project
PROJECT_VERSION = 0.1.0

DEPS = cowboy turtle gproc jiffy
dep_cowboy_commit = 2.8.0
dep_turtle = git https://github.com/fulc927/turtle master
#dep_gproc = git https://github.com/uwiger/gproc/ 0.9.0
dep_jiffy = git https://github.com/davisp/jiffy 1.0.8
DEP_PLUGINS = cowboy turtle gproc jiffy

include erlang.mk
