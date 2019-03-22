-module(automatic_connector).

-behaviour(gen_server).

-export([start_link/0]).
-export([init/1, handle_info/2, handle_call/3, handle_cast/2,do_discover/4]).

-record(state, {discovery_config}).

start_link() ->
    Discovery_config = wombat_discovery_app:load_config(),
    gen_server:start_link({local, automatic_connector}, automatic_connector, Discovery_config,[]).

init(Args) ->
    State = #state{discovery_config = Args},
    self() ! start_discovery,
    {ok, State}.

handle_info(start_discovery, {State, no_conig}) ->
    lager:info("No Wombat Discovery plugin configuration found."),
    {noreply,State};

handle_info(start_discovery, State) ->
    case State of
        {state,{MyNode,MyCookie,RetryCount,RetryWait}} -> 
            lager:info("Connecting to Wombat node: ~p", [MyNode]),
            do_discover(MyNode, MyCookie, RetryCount, RetryWait);
        Conf -> lager:info("invalid config: ~p",[Conf])
    end,
    {noreply, State};

handle_info({try_again, Count}, State) ->
    case Count of
        0 -> lager:info("No Wombat Discovery plugin configuration found.");
        _ -> {state,{Node, Cookie, _, Wait}} = State,
             do_discover(Node,Cookie,Count-1,Wait)
    end,
    {noreply, State};

handle_info(_Msg,State) ->
    {noreply, State}.

handle_call(_Msg, _From, State) ->
    {reply, ok, State}.

handle_cast(_Msg, State) ->
    {noreply,State}.

-spec do_discover(Node::atom(),Cookie::atom(),Count::integer(),Wait::integer()) -> ok | reference().
do_discover(Node, Cookie, Count, Wait) ->
   lager:info("Trying to connect to ~p", [Node]),
    Reply = wombat_api:discover_me(Node, Cookie),
    case Reply of
      ok -> 
            lager:info("Node successfully added"), ok;
      {error, already_added, Msg} -> 
            lager:warning("Warning: ~p", [Msg]), 
            lager:warning("Stopping..."), warning;
      {error, _Reason, Msg} -> 
            lager:error("Error: ~p", [Msg]), 
            lager:error("Stopping."), warning;
      no_connection ->
            lager:info("Wombat connection failed. Ensure the Wombat cookie is correct."),
            lager:info("If the node is already in Wombat, this may be OK. Retrying..."),
            erlang:send_after(Wait,self(),{try_again, Count})
    end.



