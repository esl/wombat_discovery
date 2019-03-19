%%%-------------------------------------------------------------------
%% @doc wombat_discovery top level supervisor.
%% @end
%%%-------------------------------------------------------------------

-module(wombat_discovery_sup).

-behaviour(supervisor).

%% API
-export([start_link/0]).

%% Supervisor callbacks
-export([init/1]).

-define(SERVER, ?MODULE).

%%====================================================================
%% API functions
%%====================================================================

start_link() ->
    supervisor:start_link({local, ?SERVER}, ?MODULE, []).

%%====================================================================
%% Supervisor callbacks
%%====================================================================

init([]) ->
    {ok, {{one_for_one, 5, 10},
          [
          child(automatic_connector, start_link, [])
          ]}}.

%%%=============================================================================
%%% Internal functions
%%%=============================================================================

-spec child(Mod :: module(),
            Fun :: atom(),
            Args :: [term()]) -> supervisor:child_spec().
child(Mod, Fun, Args) ->
    {Mod, {Mod, Fun, Args}, permanent, 5000, worker, [Mod]}.
