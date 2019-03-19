# Wombat Discovery Plugin

## What is Wombat?

Wombat is a monitoring tool for Erlang and Elixir based applications and products like RabbitMQ, Riak, Cowboy, MongooseIM. Read more on its website at https://www.erlang-solutions.com/products/wombatoam.html. It provides you with an on-premises monitoring solution which collects many metrics from the BEAM VM and even custom metrics from the application.

## Wombat Discovery Plugin

As Wombat is installed near the application it is hard to orchestrate the discovery of containers or other dynamic applications. This plugin provides a way to automatically add the new node to Wombat.

## Installation

This package only works on Elang nodes. 

## Usage

The plugin can be configured multiple ways, the easiest way is to define two environment variables:
`WOMBAT_NODENAME` should be the Erlang nodename of Wombat, for example `wombat@static.host`.
`WOMBAT_COOKIE` should be the cookie of Wombat, by default it's `wombat`.

The other way is to configure the `wombat_discovery` application in the sys.config file, for example:

```elang
[
  { wombat_discovery, [
  	{wombat_nodename, 'wombat@127.0.0.1'},
  	{wombat_cookie, wombat},
  	{retry_count, 20},
  	{retry_wait, 30000}
  ]}
]
  ```

Build
-----

    $ rebar3 release
