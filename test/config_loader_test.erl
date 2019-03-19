-module(config_loader_test).
-include_lib("eunit/include/eunit.hrl").

-export([]).

unset() ->
	application:unset_env(wombat_discovery,wombat_nodename),
	application:unset_env(wombat_discovery,wombat_cookie),
	application:unset_env(wombat_discovery,retry_wait),
	application:unset_env(wombat_discovery,retry_count),
	os:unsetenv("WOMBAT_NODENAME"),
	os:unsetenv("WOMBAT_COOKIE").

app_set() ->
	application:set_env(wombat_discovery,wombat_nodename,app_nodename),
	application:set_env(wombat_discovery,wombat_cookie,app_cookie).

sys_set() ->
	os:putenv("WOMBAT_NODENAME", "sys_nodename"),
	os:putenv("WOMBAT_COOKIE", "sys_cookie").

no_config_test() ->
	unset(),
	?assertMatch(no_config,wombat_discovery_app:load_config()).

aplication_env_config_test() ->
	unset(),
	app_set(),
	Return = {app_nodename,app_cookie,20,30000},
	?assertMatch(Return,wombat_discovery_app:load_config()).

system_env_config_test() ->
	unset(),
	sys_set(),
	Return = {sys_nodename,sys_cookie,20,30000},
	?assertMatch(Return,wombat_discovery_app:load_config()).

no_cookie_application_env_config_test() ->
	unset(),
	application:set_env(wombat_discovery,wombat_nodename,app_nodename),
	Return = {app_nodename,wombat,20,30000},
	?assertMatch(Return,wombat_discovery_app:load_config()).

no_cookie_system_env_config_test() ->
	unset(),
	os:putenv("WOMBAT_NODENAME", "sys_nodename"),
	Return = {sys_nodename,wombat,20,30000},
	?assertMatch(Return,wombat_discovery_app:load_config()).

priority_config_test() ->
	unset(),
	app_set(),
	sys_set(),
	Return = {sys_nodename,sys_cookie,20,30000},
	?assertMatch(Return,wombat_discovery_app:load_config()).

retry_wait_and_retry_count_default_config_test() ->
	unset(),
	app_set(),
	Return = {app_nodename,app_cookie,20,30000},
	?assertMatch(Return,wombat_discovery_app:load_config()).

retry_wait_and_retry_count_config_test() ->
	unset(),
	app_set(),
	application:set_env(wombat_discovery,retry_wait,20),
	application:set_env(wombat_discovery,retry_count,1),
	Return = {app_nodename,app_cookie,1,20},
	?assertMatch(Return,wombat_discovery_app:load_config()).

