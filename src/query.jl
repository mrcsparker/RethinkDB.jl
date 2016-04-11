
include("query_macros.jl")

# Takes an integer representing a variable and returns the value stored
# in that variable.  It's the responsibility of the client to translate
# from their local representation of a variable to a unique _non-negative_
# integer for that variable.  (We do it this way instead of letting
# clients provide variable names as strings to discourage
# variable-capturing client libraries, and because it's more efficient
# VAR = 10; // !NUMBER -> DATUM
@reql_one(10, var, ReqlString)

# Takes some javascript code and executes it.
# JAVASCRIPT = 11; // STRING {timeout: !NUMBER} -> DATUM |
#                  // STRING {timeout: !NUMBER} -> Function(*)
@reql_one(11, javascript, ReqlString)
@reql_one(11, js, ReqlString)

# Takes a string and throws an error with that message.
# Inside of a `default` block, you can omit the first
# argument to rethrow whatever error you catch (this is most
# useful as an argument to the `default` filter optarg).
# ERROR = 12; // STRING -> Error | -> Error
@reql_one(12, error, ReqlString)

# Takes nothing and returns a reference to the implicit variable.
# IMPLICIT_VAR = 13; // -> DATUM
@reql_zero(14, implicit_var)

# Returns a reference to a database.
# DB = 14; // STRING -> Database
#@reql_string(14, db)
@reql_one(14, db, ReqlString)

# Returns a reference to a table.
# TABLE = 15; // Database, STRING, {read_mode:STRING, identifier_format:STRING} -> Table
#             // STRING, {read_mode:STRING, identifier_format:STRING} -> Table
@reql_one_two(15, table, ReqlTerm, ReqlString)
@reql_one(15, table, ReqlString)

# Gets a single element from a table by its primary or a secondary key.
# GET = 16; // Table, STRING -> SingleSelection | Table, NUMBER -> SingleSelection |
#           // Table, STRING -> NULL            | Table, NUMBER -> NULL |
@reql_one_two(16, get, ReqlTerm, ReqlString)
@reql_one_two(16, get, ReqlTerm, ReqlString)

# EQ = 17; // DATUM... -> BOOL
#@reql_datumarray(17, eq)
@reql_onearr(17, eq, ReqlDatum)

# NE = 18; // DATUM... -> BOOL
@reql_onearr(18, ne, ReqlDatum)

# LT = 19; // DATUM... -> BOOL
@reql_onearr(19, lt, ReqlDatum)

# LE = 20; // DATUM... -> BOOL
@reql_onearr(20, le, ReqlDatum)

# GT = 21; // DATUM... -> BOOL
@reql_onearr(21, gt, ReqlDatum)

# GE = 22; // DATUM... -> BOOL
@reql_onearr(22, ge, ReqlDatum)

# NOT = 23; // BOOL -> BOOL
@reql_one(23, not, ReqlBool)

# ADD can either add two numbers or concatenate two arrays.
# ADD = 24; // NUMBER... -> NUMBER | STRING... -> STRING
@reql_onearr(24, add, ReqlString)
#@reql_onearr(24, add, ReqlNumber)

# SUB = 25; // NUMBER... -> NUMBER
@reql_onearr(25, sub, ReqlNumber)

# MUL = 26; // NUMBER... -> NUMBER
@reql_onearr(26, mul, ReqlNumber)

# DIV = 27; // NUMBER... -> NUMBER
@reql_onearr(27, div, ReqlNumber)

# MOD = 28; // NUMBER, NUMBER -> NUMBER
@reql_one_two(28, mod, ReqlNumber, ReqlNumber)

# Append a single element to the end of an array (like `snoc`).
# APPEND = 29; // ARRAY, DATUM -> ARRAY
@reql_one_two(29, append, ReqlArray, ReqlDatum)

# SLICE = 30; // Sequence, NUMBER, NUMBER -> Sequence

# Get a particular field from an object, or map that over a
# sequence.
# GET_FIELD = 31; // OBJECT, STRING -> DATUM
#                 // | Sequence, STRING -> Sequence
@reql_one_two(31, get_field, ReqlObject, ReqlString)
@reql_one_two(31, get_field, ReqlArray, ReqlString)

# Check whether an object contains all the specified fields,
# or filters a sequence so that all objects inside of it
# contain all the specified fields.
# HAS_FIELDS = 32; // OBJECT, Pathspec... -> BOOL
@reql_one_two(32, has_fields, ReqlTerm, ReqlString)
@reql_one_two(32, has_fields, ReqlTerm, ReqlNumber)

# Get a subset of an object by selecting some attributes to preserve,
# or map that over a sequence.  (Both pick and pluck, polymorphic.)
# PLUCK = 33; // Sequence, Pathspec... -> Sequence | OBJECT, Pathspec... -> OBJECT
@reql_one_two(33, pluck, ReqlTerm, ReqlString)

# Get a subset of an object by selecting some attributes to discard, or
# map that over a sequence.  (Both unpick and without, polymorphic.)
# WITHOUT = 34; // Sequence, Pathspec... -> Sequence | OBJECT, Pathspec... -> OBJECT

# Merge objects (right-preferential)
# MERGE = 35; // OBJECT... -> OBJECT | Sequence -> Sequence

# Get all elements of a sequence between two values.
# Half-open by default, but the openness of either side can be
# changed by passing 'closed' or 'open for `right_bound` or
# `left_bound`.
# BETWEEN_DEPRECATED = 36; // Deprecated version of between, which allows `null` to specify unboundedness
#                          // With the newer version, clients should use `r.minval` and `r.maxval` for unboundedness

# REDUCE = 37; // Sequence, Function(2) -> DATUM

# MAP = 38; // Sequence, Function(1) -> Sequence
#           // The arity of the function should be
#           // Sequence..., Function(sizeof...(Sequence)) -> Sequence

# Filter a sequence with either a function or a shortcut
# object (see API docs for details).  The body of FILTER is
# wrapped in an implicit `.default(false)`, and you can
# change the default value by specifying the `default`
# optarg.  If you make the default `r.error`, all errors
# caught by `default` will be rethrown as if the `default`
# did not exist.
# FILTER = 39; // Sequence, Function(1), {default:DATUM} -> Sequence |
#              // Sequence, OBJECT, {default:DATUM} -> Sequence
@reql_one_two(39, filter, ReqlTerm, ReqlTerm)
@reql_one_two(39, filter, ReqlTerm, ReqlObject)

# Map a function over a sequence and then concatenate the results together.
# CONCAT_MAP = 40; // Sequence, Function(1) -> Sequence

# Order a sequence based on one or more attributes.
# ORDER_BY = 41; // Sequence, (!STRING | Ordering)..., {index: (!STRING | Ordering)} -> Sequence

# Get all distinct elements of a sequence (like `uniq`).
# DISTINCT = 42; // Sequence -> Sequence
@reql_one(42, distinct, ReqlTerm)

# Count the number of elements in a sequence, or only the elements that match
# a given filter.
# COUNT = 43; // Sequence -> NUMBER | Sequence, DATUM -> NUMBER | Sequence, Function(1) -> NUMBER
@reql_one(43, count, ReqlTerm)

# Take the union of multiple sequences (preserves duplicate elements! (use distinct)).
# UNION = 44; // Sequence... -> Sequence

# Get the Nth element of a sequence.
# NTH = 45; // Sequence, NUMBER -> DATUM
@reql_one_two(45, nth, ReqlTerm, ReqlNumber)

# // OBSOLETE_GROUPED_MAPREDUCE = 46;

#  // OBSOLETE_GROUPBY = 47;

# INNER_JOIN = 48; // Sequence, Sequence, Function(2) -> Sequence

# OUTER_JOIN = 49; // Sequence, Sequence, Function(2) -> Sequence

# An inner-join that does an equality comparison on two attributes.
# EQ_JOIN = 50; // Sequence, !STRING, Sequence, {index:!STRING} -> Sequence

# Coerces a datum to a named type (e.g. "bool").
# If you previously used `stream_to_array`, you should use this instead
# with the type "array".
# COERCE_TO = 51; // Top, STRING -> Top

# Returns the named type of a datum (e.g. TYPE_OF(true) = "BOOL")
# TYPE_OF = 52; // Top -> STRING

# Updates all the rows in a selection.  Calls its Function with the row
# to be updated, and then merges the result of that call.
# UPDATE = 53; // StreamSelection, Function(1), {non_atomic:BOOL, durability:STRING, return_changes:BOOL} -> OBJECT |
#              // SingleSelection, Function(1), {non_atomic:BOOL, durability:STRING, return_changes:BOOL} -> OBJECT |
#              // StreamSelection, OBJECT,      {non_atomic:BOOL, durability:STRING, return_changes:BOOL} -> OBJECT |
#              // SingleSelection, OBJECT,      {non_atomic:BOOL, durability:STRING, return_changes:BOOL} -> OBJECT
@reql_one_two(53, update, ReqlTerm, ReqlObject)

# Deletes all the rows in a selection.
# DELETE = 54; // StreamSelection, {durability:STRING, return_changes:BOOL} -> OBJECT | SingleSelection -> OBJECT
@reql_one(54, delete, ReqlTerm)

# Replaces all the rows in a selection.  Calls its Function with the row
# to be replaced, and then discards it and stores the result of that
# call.
# REPLACE = 55; // StreamSelection, Function(1), {non_atomic:BOOL, durability:STRING, return_changes:BOOL} -> OBJECT | SingleSelection, Function(1), {non_atomic:BOOL, durability:STRING, return_changes:BOOL} -> OBJECT

# Inserts into a table.  If `conflict` is replace, overwrites
# entries with the same primary key.  If `conflict` is
# update, does an update on the entry.  If `conflict` is
# error, or is omitted, conflicts will trigger an error.
# INSERT = 56; // Table, OBJECT, {conflict:STRING, durability:STRING, return_changes:BOOL} -> OBJECT | Table, Sequence, {conflict:STRING, durability:STRING, return_changes:BOOL} -> OBJECT
@reql_one_two(56, insert, ReqlTerm, ReqlObject)

# Creates a database with a particular name.
# DB_CREATE = 57; // STRING -> OBJECT
@reql_one(57, db_create, ReqlString)

# Drops a database with a particular name.
# DB_DROP = 58; // STRING -> OBJECT
@reql_one(58, db_drop, ReqlString)

# Lists all the databases by name.  (Takes no arguments)
# DB_LIST = 59; // -> ARRAY
@reql_zero(59, db_list)

# Creates a table with a particular name in a particular
# database.  (You may omit the first argument to use the
# default database.)
# TABLE_CREATE = 60; // Database, STRING, {primary_key:STRING, shards:NUMBER, replicas:NUMBER, primary_replica_tag:STRING} -> OBJECT
#                    // Database, STRING, {primary_key:STRING, shards:NUMBER, replicas:OBJECT, primary_replica_tag:STRING} -> OBJECT
#                    // STRING, {primary_key:STRING, shards:NUMBER, replicas:NUMBER, primary_replica_tag:STRING} -> OBJECT
#                    // STRING, {primary_key:STRING, shards:NUMBER, replicas:OBJECT, primary_replica_tag:STRING} -> OBJECT
@reql_one_two(60, table_create, ReqlTerm, ReqlString)
@reql_one(60, table_create, ReqlString)

# Drops a table with a particular name from a particular
# database.  (You may omit the first argument to use the
# default database.)
# TABLE_DROP = 61; // Database, STRING -> OBJECT
#                  // STRING -> OBJECT
@reql_one_two(61, table_drop, ReqlTerm, ReqlString)
@reql_one(61, table_drop, ReqlString)

# Lists all the tables in a particular database.  (You may
# omit the first argument to use the default database.)
# TABLE_LIST = 62; // Database -> ARRAY
#                  //  -> ARRAY
@reql_one(62, table_list, ReqlTerm)
@reql_zero(62, table_list)

# NA = 63

# Calls a function on data
# FUNCALL = 64; // Function(*), DATUM... -> DATUM

# Executes its first argument, and returns its second argument if it
# got [true] or its third argument if it got [false] (like an `if`
# statement).
# BRANCH = 65; // BOOL, Top, Top -> Top

# Returns true if any of its arguments returns true (short-circuits).
# OR = 66; // BOOL... -> BOOL

# Returns true if all of its arguments return true (short-circuits).
# AND = 67; // BOOL... -> BOOL

# Calls its Function with each entry in the sequence
# and executes the array of terms that Function returns.
# FOR_EACH = 68; // Sequence, Function(1) -> OBJECT

# FUNC = 69; // ARRAY, Top -> ARRAY -> Top
@reql_one_two(69, func, ReqlArray, ReqlTop)

# SKIP = 70; // Sequence, NUMBER -> Sequence
@reql_one_two(70, skip, ReqlTerm, ReqlNumber)

# LIMIT = 71; // Sequence, NUMBER -> Sequence
@reql_one_two(71, limit, ReqlTerm, ReqlNumber)

# ZIP = 72; // Sequence -> Sequence
@reql_one(72, zip, ReqlTerm)

# Indicates to ORDER_BY that this attribute is to be sorted in ascending order.
# ASC = 73; // !STRING -> Ordering
@reql_one(73, asc, ReqlNumber)

# Indicates to ORDER_BY that this attribute is to be sorted in descending order.
# DESC = 74; // !STRING -> Ordering

# Creates a new secondary index with a particular name and definition.
# INDEX_CREATE = 75; // Table, STRING, Function(1), {multi:BOOL} -> OBJECT
@reql_one_two(75, index_create, ReqlTerm, ReqlString)

# Drops a secondary index with a particular name from the specified table.
# INDEX_DROP = 76; // Table, STRING -> OBJECT
@reql_one_two(76, index_drop, ReqlTerm, ReqlString)

# Lists all secondary indexes on a particular table.
# INDEX_LIST = 77; // Table -> ARRAY
@reql_one(77, index_list, ReqlTerm)

# GET_ALL = 78; // Table, DATUM..., {index:!STRING} => ARRAY

# Gets info about anything.  INFO is most commonly called on tables.
# INFO = 79; // Top -> OBJECT
@reql_one(79, info, ReqlTerm)

# Prepend a single element to the end of an array (like `cons`).
# PREPEND = 80; // ARRAY, DATUM -> ARRAY
@reql_one_two(80, prepend, ReqlArray, ReqlDatum)

# Select a number of elements from sequence with uniform distribution.
# SAMPLE = 81; // Sequence, NUMBER -> Sequence
@reql_one_two(81, sample, ReqlArray, ReqlNumber)

# Insert an element in to an array at a given index.
# INSERT_AT = 82; // ARRAY, NUMBER, DATUM -> ARRAY
@reql_one_two_three(82, insert_at, ReqlArray, ReqlNumber, ReqlDatum)

# Remove an element at a given index from an array.
# DELETE_AT = 83; // ARRAY, NUMBER -> ARRAY |
#                 // ARRAY, NUMBER, NUMBER -> ARRAY
@reql_one_two(83, delete_at, ReqlArray, ReqlNumber)
@reql_one_two_three(83, delete_at, ReqlArray, ReqlNumber, ReqlNumber)

# Change the element at a given index of an array.
# CHANGE_AT = 84; // ARRAY, NUMBER, DATUM -> ARRAY

# Splice one array in to another array.
# SPLICE_AT = 85; // ARRAY, NUMBER, ARRAY -> ARRAY

# IS_EMPTY = 86; // Sequence -> BOOL

# OFFSETS_OF = 87; // Sequence, DATUM -> Sequence | Sequence, Function(1) -> Sequence

# SET_INSERT = 88; // ARRAY, DATUM -> ARRAY

# SET_INTERSECTION = 89; // ARRAY, ARRAY -> ARRAY

# SET_UNION = 90; // ARRAY, ARRAY -> ARRAY

# SET_DIFFERENCE = 91; // ARRAY, ARRAY -> ARRAY

# Evaluates its first argument.  If that argument returns
# NULL or throws an error related to the absence of an
# expected value (for instance, accessing a non-existent
# field or adding NULL to an integer), DEFAULT will either
# return its second argument or execute it if it's a
# function.  If the second argument is a function, it will be
# passed either the text of the error or NULL as its
# argument.
# DEFAULT = 92; // Top, Top -> Top

# CONTAINS = 93; // Sequence, (DATUM | Function(1))... -> BOOL

# Return an array containing the keys of the object.
# KEYS = 94; // OBJECT -> ARRAY
@reql_one(94, keys, ReqlObject)

# Remove the elements of one array from another array.
# DIFFERENCE = 95; // ARRAY, ARRAY -> ARRAY

# x.with_fields(...) <=> x.has_fields(...).pluck(...)
# WITH_FIELDS = 96; // Sequence, Pathspec... -> Sequence

# `a.match(b)` returns a match object if the string `a`
# matches the regular expression `b`.
# MATCH = 97; // STRING, STRING -> DATUM
@reql_one_two(97, match, ReqlString, ReqlString)

# Parses its first argument as a json string and returns it as a
# datum.
# JSON = 98; // STRING -> DATUM
@reql_one(98, json, ReqlString)

# Parses its first arguments as an ISO 8601 time and returns it as a
# datum.
# ISO8601 = 99; // STRING -> PSEUDOTYPE(TIME)
@reql_one(99, iso8601, ReqlString)

# Prints a time as an ISO 8601 time.
# TO_ISO8601 = 100; // PSEUDOTYPE(TIME) -> STRING
@reql_one(100, to_iso8601, ReqlTerm)

# Returns a time given seconds since epoch in UTC.
# EPOCH_TIME = 101; // NUMBER -> PSEUDOTYPE(TIME)
@reql_one(101, epoch_time, ReqlTerm)

# Returns seconds since epoch in UTC given a time.
# TO_EPOCH_TIME = 102; // PSEUDOTYPE(TIME) -> NUMBER
@reql_one(102, to_epoch_time, ReqlTerm)

# The time the query was received by the server.
# NOW = 103; // -> PSEUDOTYPE(TIME)
@reql_zero(103, now)

# Puts a time into an ISO 8601 timezone.
# IN_TIMEZONE = 104; // PSEUDOTYPE(TIME), STRING -> PSEUDOTYPE(TIME)

# a.during(b, c) returns whether a is in the range [b, c)
# DURING = 105; // PSEUDOTYPE(TIME), PSEUDOTYPE(TIME), PSEUDOTYPE(TIME) -> BOOL

# Retrieves the date portion of a time.
# DATE = 106; // PSEUDOTYPE(TIME) -> PSEUDOTYPE(TIME)
@reql_one(106, date, ReqlTerm)

# MONDAY = 107;    // -> 1

# TUESDAY = 108;   // -> 2

# WEDNESDAY = 109; // -> 3

# THURSDAY = 110;  // -> 4

# FRIDAY = 111;    // -> 5

# SATURDAY = 112;  // -> 6

# SUNDAY = 113;    // -> 7

# JANUARY = 114;   // -> 1

# FEBRUARY = 115;  // -> 2

# MARCH = 116;     // -> 3

# APRIL = 117;     // -> 4

# MAY = 118;       // -> 5

# JUNE = 119;      // -> 6

# JULY = 120;      // -> 7

# AUGUST = 121;    // -> 8

# SEPTEMBER = 122; // -> 9

# OCTOBER = 123;   // -> 10

# NOVEMBER = 124;  // -> 11

# DECEMBER = 125;  // -> 12

# x.time_of_day == x.date - x
# TIME_OF_DAY = 126; // PSEUDOTYPE(TIME) -> NUMBER
@reql_one(126, time_of_day, ReqlTerm)

# Returns the timezone of a time.
# TIMEZONE = 127; // PSEUDOTYPE(TIME) -> STRING
@reql_one(127, timezone, ReqlTerm)

# YEAR = 128; // PSEUDOTYPE(TIME) -> NUMBER
@reql_one(128, year, ReqlTerm)

# MONTH = 129; // PSEUDOTYPE(TIME) -> NUMBER
@reql_one(129, month, ReqlTerm)

# DAY = 130; // PSEUDOTYPE(TIME) -> NUMBER
@reql_one(130, day, ReqlTerm)

# DAY_OF_WEEK = 131; // PSEUDOTYPE(TIME) -> NUMBER
@reql_one(131, day_of_week, ReqlTerm)

# DAY_OF_YEAR = 132; // PSEUDOTYPE(TIME) -> NUMBER
@reql_one(132, day_of_year, ReqlTerm)

# HOURS = 133; // PSEUDOTYPE(TIME) -> NUMBER
@reql_one(133, hours, ReqlTerm)

# MINUTES = 134; // PSEUDOTYPE(TIME) -> NUMBER
@reql_one(134, minutes, ReqlTerm)

# SECONDS = 135; // PSEUDOTYPE(TIME) -> NUMBER
@reql_one(135, seconds, ReqlTerm)

# Construct a time from a date and optional timezone or a
# date+time and optional timezone.
# TIME = 136; // NUMBER, NUMBER, NUMBER, STRING -> PSEUDOTYPE(TIME) |
#             // NUMBER, NUMBER, NUMBER, NUMBER, NUMBER, NUMBER, STRING -> PSEUDOTYPE(TIME) |

# Indicates to MERGE to replace, or remove in case of an empty literal, the
# other object rather than merge it.
# LITERAL = 137; // -> Merging
#                // JSON -> Merging

# Ensures that previously issued soft-durability writes are complete and
# written to disk.
# SYNC = 138; // Table -> OBJECT
@reql_one(138, sync, ReqlTerm)

# Gets information about whether or not a set of indexes are ready to
# be accessed. Returns a list of objects that look like this:
# {index:STRING, ready:BOOL[, progress:NUMBER]}
# INDEX_STATUS = 139; // Table, STRING... -> ARRAY

# Blocks until a set of indexes are ready to be accessed. Returns the
# same values INDEX_STATUS.
# INDEX_WAIT = 140; // Table, STRING... -> ARRAY

# Change the case of a string.
# UPCASE   = 141; // STRING -> STRING
@reql_one(141, upcase, ReqlString)

# Change the case of a string.
# DOWNCASE = 142; // STRING -> STRING
@reql_one(142, downcase, ReqlString)

# Creates an object
# OBJECT = 143; // STRING, DATUM, ... -> OBJECT


# UNGROUP = 150; // GROUPED_DATA -> ARRAY

# Takes a range of numbers and returns a random number within the range
# RANDOM = 151; // NUMBER, NUMBER {float:BOOL} -> DATUM

# CHANGES = 152; // TABLE -> STREAM
@reql_one(152, changes, ReqlTerm)

# ARGS = 154; // ARRAY -> SPECIAL (used to splice arguments)

# GEOJSON = 157; // OBJECT -> PSEUDOTYPE(GEOMETRY)

# TO_GEOJSON = 158; // PSEUDOTYPE(GEOMETRY) -> OBJECT

# FILL = 167; // PSEUDOTYPE(GEOMETRY) -> PSEUDOTYPE(GEOMETRY)

# Returns the row in the `rethinkdb.table_config` or `rethinkdb.db_config` table
# that corresponds to the given database or table.
# CONFIG  = 174; // Database -> SingleSelection
#                // Table -> SingleSelection
@reql_one(174, config, ReqlTerm)
