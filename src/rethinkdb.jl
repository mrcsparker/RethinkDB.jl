module RethinkDB

import JSON

type RethinkDBConnection
  socket :: Base.TCPSocket
end

# TODO: handle error is not connected or incorrect handshake
function connect(server::AbstractString = "localhost", port::Int = 28015)
  c = RethinkDBConnection(Base.connect(server, port))
  handshake(c)
  c
end

function handshake(conn::RethinkDBConnection)
  # Version.V0_4
  version = UInt32(0x400c2d20)

  # Key Size
  key_size = UInt32(0)

  # Protocol.JSON
  protocol = UInt32(0x7e6970c7)

  handshake = pack_command([version, key_size, protocol])
  write(conn.socket, handshake)
  is_valid_handshake(conn)
end

function is_valid_handshake(conn::RethinkDBConnection)
  readstring(conn.socket) == "SUCCESS"
end

function readstring(sock::TCPSocket, msg = "")
  c = read(sock, UInt8)
  s = convert(Char, c)
  msg = string(msg, s)
  if (s == '\0')
    return chop(msg)
  else
    readstring(sock, msg)
  end
end

function pack_command(args...)
  o = Base.IOBuffer()
  for enc_val in args
    write(o, enc_val)
  end
  o.data
end

function disconnect(conn::RethinkDBConnection)
  close(conn.socket)
end

# Have to do the funky push! on arrays due to
# the deprecated [] auto-concatenation still
# enabled in Julia 0.4

function wrap(term)
  if ismatch(r"^Dict", string(typeof(term)))
    for k in Base.keys(term)
      term[k] = wrap(term[k])
    end
  end

  if ismatch(r"^Array", string(typeof(term)))
    p = []
    push!(p, 2)
    push!(p, term)
    return p
  end
  term
end

macro operate_on_zero_args(op_code::Int, name::Symbol)
  quote
    function $(esc(name))()
      retval = []
      push!(retval, $(op_code))
      retval
    end

    function $(esc(name))(query)
      retval = []
      push!(retval, $(op_code))

      sub = []
      push!(sub, query)

      push!(retval, sub)

      retval
    end
  end
end

macro operate_on_single_arg(op_code::Int, name::Symbol)
  quote
    function $(esc(name))(arg1)
      local retval = []
      push!(retval, $(op_code))

      local sub = []
      push!(sub, wrap(arg1))

      push!(retval, sub)

      retval
    end

    function $(esc(name))(query, arg1)
      retval = []
      push!(retval, $(op_code))

      sub = []
      push!(sub, query)
      push!(sub, wrap(arg1))

      push!(retval, sub)

      retval
    end
  end
end

macro operate_on_two_args(op_code::Int, name::Symbol)
  quote
    function $(esc(name))(arg1, arg2)
      retval = []
      push!(retval, $(op_code))

      sub = []
      push!(sub, wrap(arg1))
      push!(sub, wrap(arg2))

      push!(retval, sub)

      retval
    end

    function $(esc(name))(query, arg1, arg2)
      retval = []
      push!(retval, $(op_code))

      sub = []
      push!(sub, query)
      push!(sub, wrap(arg1))
      push!(sub, wrap(arg2))

      push!(retval, sub)

      retval
    end
  end
end

# VAR = 10; // !NUMBER -> DATUM
# JAVASCRIPT = 11; // STRING {timeout: !NUMBER} -> DATUM |
#                  // STRING {timeout: !NUMBER} -> Function(*)
@operate_on_single_arg(11, js)

# Takes a string and throws an error with that message.
# Inside of a `default` block, you can omit the first
# argument to rethrow whatever error you catch (this is most
# useful as an argument to the `default` filter optarg).
# ERROR = 12; // STRING -> Error | -> Error
@operate_on_single_arg(12, error)

# Takes nothing and returns a reference to the implicit variable.
# IMPLICIT_VAR = 13; // -> DATUM

# Returns a reference to a database.
# DB = 14; // STRING -> Database
@operate_on_single_arg(14, db)

# Returns a reference to a table.
# Database, STRING, {read_mode:STRING, identifier_format:STRING} -> Table
# STRING, {read_mode:STRING, identifier_format:STRING} -> Table
@operate_on_single_arg(15, table)

# 16, get
# 17, eq
# 18, ne
# 19, lt
# 20, le
# 21, gt
# 22, ge

# Simple DATUM Op
# NOT = 23; // BOOL -> BOOL
@operate_on_single_arg(23, not)

# 24, add
# 25, sub
# 26, mul
# 27, div
# 28, mod
# 29, append
# 30, slice
# 31, get_field
# 32, has_fields
# 33, pluck
# 34, without
# 35, merge
# 36, na
# 37, reduce
# 38, map
# 39, filter
# 40, concat_map
# 41, order_by

# Get all distinct elements of a sequence (like `uniq`).
# DISTINCT  = 42; // Sequence -> Sequence
@operate_on_single_arg(42, distinct)

# 43, count
# 44, union
# 45, nth
# 46, na
# 47, na
# 48, inner_join
# 49, outer_join
# 50, eq_join
# 51, coerce_to

# Returns the named type of a datum (e.g. TYPE_OF(true) = "BOOL")
# TYPE_OF = 52; // Top -> STRING
@operate_on_single_arg(52, type_of)

# Updates all the rows in a selection.  Calls its Function with the row
# to be updated, and then merges the result of that call.
# UPDATE = 53; // StreamSelection, Function(1), {non_atomic:BOOL, durability:STRING, return_changes:BOOL} -> OBJECT |
#              // SingleSelection, Function(1), {non_atomic:BOOL, durability:STRING, return_changes:BOOL} -> OBJECT |
#              // StreamSelection, OBJECT,      {non_atomic:BOOL, durability:STRING, return_changes:BOOL} -> OBJECT |
#              // SingleSelection, OBJECT,      {non_atomic:BOOL, durability:STRING, return_changes:BOOL} -> OBJECT
@operate_on_two_args(53, update)

# Deletes all the rows in a selection.
# DELETE = 54; // StreamSelection, {durability:STRING, return_changes:BOOL} -> OBJECT | SingleSelection -> OBJECT
@operate_on_single_arg(54, delete)

# 55, replace

# Inserts into a table.  If `conflict` is replace, overwrites
# entries with the same primary key.  If `conflict` is
# update, does an update on the entry.  If `conflict` is
# error, or is omitted, conflicts will trigger an error.
# INSERT = 56; // Table, OBJECT, {conflict:STRING, durability:STRING, return_changes:BOOL} -> OBJECT | Table, Sequence, {conflict:STRING, durability:STRING, return_changes:BOOL} -> OBJECT
@operate_on_single_arg(56, insert)

# Creates a database with a particular name.
# DB_CREATE = 57; // STRING -> OBJECT
@operate_on_single_arg(57, db_create)

# Drops a database with a particular name.
# DB_DROP = 58; // STRING -> OBJECT
@operate_on_single_arg(58, db_drop)

# Lists all the databases by name.  (Takes no arguments)
# DB_LIST = 59; // -> ARRAY
@operate_on_zero_args(59, db_list)

# Creates a table with a particular name in a particular
# database.  (You may omit the first argument to use the
# default database.)
# TABLE_CREATE = 60; // Database, STRING, {primary_key:STRING, shards:NUMBER, replicas:NUMBER, primary_replica_tag:STRING} -> OBJECT
#                    // Database, STRING, {primary_key:STRING, shards:NUMBER, replicas:OBJECT, primary_replica_tag:STRING} -> OBJECT
#                    // STRING, {primary_key:STRING, shards:NUMBER, replicas:NUMBER, primary_replica_tag:STRING} -> OBJECT
#                    // STRING, {primary_key:STRING, shards:NUMBER, replicas:OBJECT, primary_replica_tag:STRING} -> OBJECT
@operate_on_single_arg(60, table_create)

# Drops a table with a particular name from a particular
# database.  (You may omit the first argument to use the
# default database.)
# TABLE_DROP = 61; // Database, STRING -> OBJECT
#                  // STRING -> OBJECT
@operate_on_single_arg(61, table_drop)

# ZIP = 72; // Sequence -> Sequence
@operate_on_single_arg(72, zip)

# Indicates to ORDER_BY that this attribute is to be sorted in ascending order.
# ASC = 73; // !STRING -> Ordering

# Indicates to ORDER_BY that this attribute is to be sorted in descending order.
# DESC = 74; // !STRING -> Ordering

# Gets info about anything.  INFO is most commonly called on tables.
# INFO = 79; // Top -> OBJECT
@operate_on_single_arg(79, info)

# Select a number of elements from sequence with uniform distribution.
# SAMPLE = 81; // Sequence, NUMBER -> Sequence

# IS_EMPTY = 86; // Sequence -> BOOL
@operate_on_single_arg(86, is_empty)

# Evaluates its first argument.  If that argument returns
# NULL or throws an error related to the absence of an
# expected value (for instance, accessing a non-existent
# field or adding NULL to an integer), DEFAULT will either
# return its second argument or execute it if it's a
# function.  If the second argument is a function, it will be
# passed either the text of the error or NULL as its
# argument.
# DEFAULT = 92; // Top, Top -> Top

# Return an array containing the keys of the object.
# KEYS = 94; // OBJECT -> ARRAY
@operate_on_single_arg(94, keys)

# `a.match(b)` returns a match object if the string `a`
# matches the regular expression `b`.
# MATCH = 97; // STRING, STRING -> DATUM

# Parses its first argument as a json string and returns it as a
# datum.
# JSON = 98; // STRING -> DATUM
@operate_on_single_arg(98, json)

# Parses its first arguments as an ISO 8601 time and returns it as a
# datum.
# ISO8601 = 99; // STRING -> PSEUDOTYPE(TIME)
@operate_on_single_arg(99, iso8601)

# Prints a time as an ISO 8601 time.
# TO_ISO8601 = 100; // PSEUDOTYPE(TIME) -> STRING
@operate_on_single_arg(100, to_iso8601)

# Returns a time given seconds since epoch in UTC.
# EPOCH_TIME = 101; // NUMBER -> PSEUDOTYPE(TIME)
@operate_on_single_arg(101, epoch_time)

# Returns seconds since epoch in UTC given a time.
# TO_EPOCH_TIME = 102; // PSEUDOTYPE(TIME) -> NUMBER
@operate_on_single_arg(102, to_epoch_time)

# The time the query was received by the server.
# NOW = 103; // -> PSEUDOTYPE(TIME)
@operate_on_zero_args(103, now)

# Retrieves the date portion of a time.
# DATE = 106; // PSEUDOTYPE(TIME) -> PSEUDOTYPE(TIME)
@operate_on_single_arg(106, date)

# x.time_of_day == x.date - x
# TIME_OF_DAY = 126; // PSEUDOTYPE(TIME) -> NUMBER
@operate_on_single_arg(126, time_of_day)

# Returns the timezone of a time.
# TIMEZONE = 127; // PSEUDOTYPE(TIME) -> STRING
@operate_on_single_arg(127, timezone)

# YEAR = 128; // PSEUDOTYPE(TIME) -> NUMBER
@operate_on_single_arg(128, year)

# MONTH = 129; // PSEUDOTYPE(TIME) -> NUMBER
@operate_on_single_arg(129, month)

# DAY = 130; // PSEUDOTYPE(TIME) -> NUMBER
@operate_on_single_arg(130, day)

# DAY_OF_WEEK = 131; // PSEUDOTYPE(TIME) -> NUMBER
@operate_on_single_arg(131, day_of_week)

# DAY_OF_YEAR = 132; // PSEUDOTYPE(TIME) -> NUMBER
@operate_on_single_arg(132, day_of_year)

# HOURS = 133; // PSEUDOTYPE(TIME) -> NUMBER
@operate_on_single_arg(133, hours)

# MINUTES = 134; // PSEUDOTYPE(TIME) -> NUMBER
@operate_on_single_arg(134, minutes)

@operate_on_single_arg(135, seconds)

@operate_on_single_arg(137, literal)

# Change the case of a string.
# UPCASE   = 141; // STRING -> STRING
@operate_on_single_arg(141, upcase)

# Change the case of a string.
# DOWNCASE = 142; // STRING -> STRING
@operate_on_single_arg(142, downcase)

# 149, split

# UNGROUP = 150; // GROUPED_DATA -> ARRAY
@operate_on_single_arg(150, ungroup)

# Takes a range of numbers and returns a random number within the range
# RANDOM = 151; // NUMBER, NUMBER {float:BOOL} -> DATUM

# CHANGES = 152; // TABLE -> STREAM
@operate_on_single_arg(152, changes)


@operate_on_single_arg(153, http)

# ARGS = 154; // ARRAY -> SPECIAL (used to splice arguments)
@operate_on_single_arg(154, args)

# GEOJSON = 157; // OBJECT -> PSEUDOTYPE(GEOMETRY)
@operate_on_single_arg(157, geojson)

# TO_GEOJSON = 158; // PSEUDOTYPE(GEOMETRY) -> OBJECT
@operate_on_single_arg(158, to_geojson)

# FILL = 167; // PSEUDOTYPE(GEOMETRY) -> PSEUDOTYPE(GEOMETRY)
@operate_on_single_arg(167, fill)

@operate_on_single_arg(172, to_json)

@operate_on_single_arg(174, config)

@operate_on_single_arg(175, status)

@operate_on_single_arg(176, reconfigure)

@operate_on_single_arg(177, wait)

@operate_on_single_arg(179, rebalance)

@operate_on_single_arg(183, floor)

@operate_on_single_arg(184, ceil)

@operate_on_single_arg(185, round)

@operate_on_single_arg(186, values)

function exec(conn::RethinkDBConnection, q)
  j = JSON.json([1 ; Array[q]])
  send_command(conn, j)
end

function token()
  t = Array{UInt64}(1)
  t[1] = object_id(t)
  return t[1]
end

function send_command(conn::RethinkDBConnection, json)
  t = token()
  q = pack_command([ t, convert(UInt32, length(json)), json ])

  write(conn.socket, q)
  read_response(conn, t)
end

function read_response(conn::RethinkDBConnection, token)
  remote_token = read(conn.socket, UInt64)
  if remote_token != token
    return "Error"
  end

  len = read(conn.socket, UInt32)
  res = read(conn.socket, len)

  output = convert(UTF8String, res)
  JSON.parse(output)
end

function do_test()
  c = RethinkDB.connect()

  #db_create("tester") |> d -> exec(c, d) |> println
  #db_drop("tester") |> d -> exec(c, d) |> println
  #db_list() |> d -> exec(c, d) |> println

  db_create("test_db") |> d -> exec(c, d) |> println
  db("test_db") |> d -> table_create(d, "test_table") |> d -> exec(c, d) |> println
  #db("test_table") |> d -> table_drop("foo") |> d -> exec(c, d) |> println

  db("test_db") |>
    d -> table(d, "test_table") |>
    d -> insert(d, { "item" => [{"name" => "foo", "amount" => "22"}] }) |>
    d -> exec(c, d) |> println

  RethinkDB.disconnect(c)
end

end
