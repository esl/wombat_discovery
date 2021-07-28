%%%-------------------------------------------------------------------
%% @doc wombat_discovery public API
%% @end
%%%-------------------------------------------------------------------

-module(wombat_discovery_app).
-copyright("2019, Erlang Solutions Ltd.").

-include_lib("kernel/include/logger.hrl").

-behaviour(application).

%% Application callbacks
-export([start/2, stop/1, load_config/0]).

%%====================================================================
%% API
%%====================================================================

start(_StartType, _StartArgs) ->
    ok = ?LOG_INFO("Starting wombat_discovery..."),
    wombat_discovery_sup:start_link().

%%--------------------------------------------------------------------

stop(_State) ->
    ok.

%%====================================================================
%% Internal functions
%%====================================================================

-spec load_config() -> no_config | {atom(), atom(), integer() , integer()}.
load_config() ->

    SysNodeName = os:getenv("WOMBAT_NODENAME"),
    SysCookie = os:getenv("WOMBAT_COOKIE"),

    AppNodeName = application:get_env(wombat_discovery,wombat_nodename,undefined),
    AppCookie = application:get_env(wombat_discovery,wombat_cookie, wombat),

    RetryCount = application:get_env(wombat_discovery,retry_count, 20),
    RetryWait = application:get_env(wombat_discovery,retry_wait, 30000),

    case [{SysNodeName,SysCookie},{AppNodeName,AppCookie}] of
        [{false,false},{undefined,_}] -> no_config;
        [{SysNodeName,SysCookie}, _ ] when SysNodeName /= false ->
            Cookie = case SysCookie of
                         false -> wombat;
                         _ -> list_to_atom(SysCookie)
                     end,
            {list_to_atom(SysNodeName),Cookie,RetryCount,RetryWait};
        [_,{Nodename,Cookie}] -> {Nodename,Cookie,RetryCount,RetryWait}
    end.

