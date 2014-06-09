# Riex [![Build Status](https://travis-ci.org/edgurgel/riex.svg?branch=master)](https://travis-ci.org/edgurgel/riex)

Elixir wrapper based on [riak-elixir-client](https://github.com/drewkerrigan/riak-elixir-client)

Differences:

* Pool of connections using [pooler](http://github.com/seth/pooler)
* Organization of source and tests;
* Riex.Object is a struct;

#Setup

## Prerequisites

You should have at least one Riex node running. If you plan to use secondary indexes, you'll need to have the leveldb backend enabled:

`app.config` in version 1.4.x-

```
[
    ...
    {riak_kv, [
        {storage_backend, riak_kv_eleveldb_backend},
        ...
            ]},
    ...
].
```

or `riak.conf` in version 2.x.x+

```
...
storage_backend = leveldb
...
```

## In your Elixir application

Add this project as a depency in your mix.exs

```elixir
defp deps do
  [{ :riex, github: "edgurgel/riex" }]
end
```

Install dependencies

```
mix deps.get
```

Compile

```
mix
```

# Usage

You can pass the pid of the established connection or just use the pool (provided by pooler)

Check `config/config.exs` for more info on the pool configuration.

Any call to Riex can omit the pid if you want to use the pool.

For example:

```elixir
Riex.delete(pid, "user", key)

Riex.delete("user", key)
```

##Establishing a Riex connection

```elixir
{:ok, pid} = Riex.Connection.start_link('127.0.0.1', 8087) # Default values
```

##Save a value

```elixir
o = Riex.Object.create(bucket: "user", key: "my_key", data: "Drew Kerrigan")
Riex.put(pid, o)
```

##Find an object

```elixir
o = Riex.find(pid, "user", "my_key")
```

##Update an object

```elixir
o = %{o | data: "Something Else"}
Riex.put(pid, o)
```

##Delete an object

Using key

```elixir
Riex.delete(pid, "user", key)
```

Using object

```elixir
Riex.delete(pid, o)
```

For a more functionality, check `test/` directory

##Tests

```
MIX_ENV=test mix do deps.get, test
```

# License

    Copyright 2012-2013 Drew Kerrigan.
    Copyright 2014 Eduardo Gurgel.

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
