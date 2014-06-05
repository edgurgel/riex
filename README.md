# Riak Elixir Client

Elixir wrapper for riak-erlang-client

###Setup

#### Prerequisites

You should have at least one Riak node running. If you plan to use secondary indexes, you'll need to have the leveldb backend enabled:

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

#### In your Elixir application

Add this project as a depency in your mix.exs

```elixir
defp deps do
  [{ :'riak-elixir-client', github: "edgurgel/riak-elixir-client" }]
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

###Establishing a Riak connection

```elixir
{:ok, pid} = Riak.Connection.start_link('127.0.0.1', 8087) # Default values
```

###Save a value

```
o = RObj.create(bucket: "user", key: "my_key", data: "Drew Kerrigan")
Riak.put(pid, o)

```

###Find an object

```
o = Riak.find(pid, "user", "my_key")
```

###Update an object

```
o = %{o | data: "Something Else"}
Riak.put(pid, o)
```

###Delete an object

Using key

```elixir
Riak.delete(pid, "user", key)
```

Using object

```elixir
Riak.delete(pid, o)
```

####For a more functionality, check `test/` directory

###Run tests

```
MIX_ENV=test mix do deps.get, test
```

### License

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
