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
    io:format("No Wombat Discovery plugin configuration found. ~n"),
    {noreply,State};

handle_info(start_discovery, State) ->
    case State of
        {state,{MyNode,MyCookie,RetryCount,RetryWait}} -> 
            io:format("Connecting to Wombat node: ~p ~n", [MyNode]),
            do_discover(MyNode, MyCookie, RetryCount, RetryWait);
        Conf -> io:format("invalid config: ~p ~n",[Conf])
    end,
    {noreply, State};

handle_info({try_again, Count}, State) ->
    case Count of
        0 -> io:format("No Wombat Discovery plugin configuration found. ~n");
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

do_discover(Node, Cookie, Count, Wait) ->
   io:format("Trying to connect to ~p ~n", [Node]),
    Reply = wombat_api:discover_me(Node, Cookie),
    case Reply of
      ok -> io:format("Node successfully added ~n");
      {error, already_added, Msg} -> io:format("Warning: ~p ~nStopping. ~n", [Msg]);
      {error, _Reason, Msg} -> io:format("Error: ~p ~nStopping. ~n", [Msg]);
      no_connection ->
        io:format("Wombat connection failed. Ensure the Wombat cookie is correct. ~nIf the node is already in Wombat, this may be OK. Retrying... ~n"),
        erlang:send_after(Wait,self(),{try_again, Count})
    end.



