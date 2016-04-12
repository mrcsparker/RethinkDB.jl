
include("query_macros.jl")

"""
A RQL datum, stored in `datum` below.

DATUM = 1;
"""
@reql_zero(1, datum,
  ReqlDatum)

"MAKE_ARRAY = 2; // DATUM... -> ARRAY"
@reql_onearr(2, make_array,
  ReqlDatum,
  ReqlArray)

# Compound types

"""
Takes an integer representing a variable and returns the value stored
in that variable.  It's the responsibility of the client to translate
from their local representation of a variable to a unique _non-negative_
integer for that variable.  (We do it this way instead of letting
clients provide variable names as strings to discourage
variable-capturing client libraries, and because it's more efficient

VAR = 10; // !NUMBER -> DATUM
"""
@reql_one(10, var,
  ReqlString,
  ReqlDatum)

"""
Takes some javascript code and executes it.

JAVASCRIPT = 11; // STRING {timeout: !NUMBER} -> DATUM |
                 // STRING {timeout: !NUMBER} -> Function(\*)
"""
@reql_one(11, javascript,
  ReqlString,
  ReqlDatum)

"alias for RethinkDB.javascript"
@reql_one(11, js,
  ReqlString,
  ReqlDatum)

"UUID = 169; // () -> DATUM"
@reql_zero(169, datum,
  ReqlDatum)

"""
Takes an HTTP URL and gets it.  If the get succeeds and
returns valid JSON, it is converted into a DATUM

HTTP = 153; // STRING {data: OBJECT | STRING,
            //         timeout: !NUMBER,
            //         method: STRING,
            //         params: OBJECT,
            //         header: OBJECT | ARRAY,
            //         attempts: NUMBER,
            //         redirects: NUMBER,
            //         verify: BOOL,
            //         page: FUNC | STRING,
            //         page_limit: NUMBER,
            //         auth: OBJECT,
            //         result_format: STRING,
            //         } -> STRING | STREAM
"""
@reql_one(153, http,
  ReqlString,
  ReqlString)

"""
Takes a string and throws an error with that message.
Inside of a `default` block, you can omit the first
argument to rethrow whatever error you catch (this is most
useful as an argument to the `default` filter optarg).

ERROR = 12; // STRING -> Error | -> Error
"""
@reql_one(12, error,
  ReqlString,
  ReqlError)

"""
Takes nothing and returns a reference to the implicit variable.

IMPLICIT_VAR = 13; // -> DATUM
"""
@reql_zero(13, implicit_var,
  ReqlDatum)

# Data Operators

"""
Returns a reference to a database.

DB = 14; // STRING -> Database
"""
@reql_one(14, db,
  ReqlString,
  ReqlDatabase)

"""
Returns a reference to a table.

TABLE = 15; // Database, STRING, {read_mode:STRING, identifier_format:STRING} -> Table
            // STRING, {read_mode:STRING, identifier_format:STRING} -> Table
"""
@reql_one_two(15, table,
  ReqlDatabase, ReqlString,
  ReqlTable)
@reql_one(15, table,
  ReqlString,
  ReqlTable)

"""
Gets a single element from a table by its primary or a secondary key.

GET = 16; // Table, STRING -> SingleSelection | Table, NUMBER -> SingleSelection |
          // Table, STRING -> NULL            | Table, NUMBER -> NULL |
"""
@reql_one_two(16, get,
  ReqlTable, ReqlString,
  ReqlSingleSelection)
@reql_one_two(16, get,
  ReqlTable, ReqlNumber,
  ReqlSingleSelection)

"GET_ALL = 78; // Table, DATUM..., {index:!STRING} => ARRAY"
@reql_one_twoarr(78, get_all,
  ReqlTable, ReqlDatum,
  ReqlArray)
@reql_one(78, get_all,
  ReqlTable,
  ReqlArray)

# Simple DATUM Ops

"EQ = 17; // DATUM... -> BOOL"
@reql_onearr(17, eq,
  ReqlDatum,
  ReqlBool)

"NE = 18; // DATUM... -> BOOL"
@reql_onearr(18, ne,
  ReqlDatum,
  ReqlBool)

"LT = 19; // DATUM... -> BOOL"
@reql_onearr(19, lt,
  ReqlDatum,
  ReqlBool)

"LE = 20; // DATUM... -> BOOL"
@reql_onearr(20, le,
  ReqlDatum,
  ReqlBool)

"GT = 21; // DATUM... -> BOOL"
@reql_onearr(21, gt,
  ReqlDatum,
  ReqlBool)

"GE = 22; // DATUM... -> BOOL"
@reql_onearr(22, ge,
  ReqlDatum,
  ReqlBool)

"NOT = 23; // BOOL -> BOOL"
@reql_one(23, not,
  ReqlBool,
  ReqlBool)

"""
ADD can either add two numbers or concatenate two arrays.

ADD = 24; // NUMBER... -> NUMBER | STRING... -> STRING
"""
@reql_onearr(24, add,
  ReqlNumber,
  ReqlNumber)
@reql_onearr(24, add,
  ReqlString,
  ReqlString)

"SUB = 25; // NUMBER... -> NUMBER"
@reql_onearr(25, sub,
  ReqlNumber,
  ReqlNumber)

"MUL = 26; // NUMBER... -> NUMBER"
@reql_onearr(26, mul,
  ReqlNumber,
  ReqlNumber)

"DIV = 27; // NUMBER... -> NUMBER"
@reql_onearr(27, div,
  ReqlNumber,
  ReqlNumber)

"MOD = 28; // NUMBER, NUMBER -> NUMBER"
@reql_one_two(28, mod,
  ReqlNumber, ReqlNumber,
  ReqlNumber)

"FLOOR = 183;    // NUMBER -> NUMBER"
@reql_one(183, floor,
  ReqlNumber,
  ReqlNumber)

"CEIL = 184;     // NUMBER -> NUMBER"
@reql_one(184, ceil,
  ReqlNumber,
  ReqlNumber)

"ROUND = 185;    // NUMBER -> NUMBER"
@reql_one(185, round,
  ReqlNumber,
  ReqlNumber)

# DATUM Array Ops

"""
Append a single element to the end of an array (like `snoc`).

APPEND = 29; // ARRAY, DATUM -> ARRAY
"""
@reql_one_two(29, append,
  ReqlArray, ReqlDatum,
  ReqlArray)

"""
Prepend a single element to the end of an array (like `cons`).

PREPEND = 80; // ARRAY, DATUM -> ARRAY
"""
@reql_one_two(80, prepend,
  ReqlArray, ReqlDatum,
  ReqlArray)

"""
Remove the elements of one array from another array.

DIFFERENCE = 95; // ARRAY, ARRAY -> ARRAY
"""
@reql_one_two(95, difference,
  ReqlArray, ReqlArray,
  ReqlArray)

# DATUM Set Ops

#=
Set ops work on arrays. They don't use actual sets and thus have
performance characteristics you would expect from arrays rather than
from sets. All set operations have the post condition that they
array they return contains no duplicate values.
=#

"SET_INSERT = 88; // ARRAY, DATUM -> ARRAY"
@reql_one_two(88, set_insert,
  ReqlArray, ReqlDatum,
  ReqlArray)

"SET_INTERSECTION = 89; // ARRAY, ARRAY -> ARRAY"
@reql_one_two(89, set_intersection,
  ReqlArray, ReqlArray,
  ReqlArray)

"SET_UNION = 90; // ARRAY, ARRAY -> ARRAY"
@reql_one_two(90, set_union,
  ReqlArray, ReqlArray,
  ReqlArray)

"SET_DIFFERENCE = 91; // ARRAY, ARRAY -> ARRAY"
@reql_one_two(91, set_difference,
  ReqlArray, ReqlArray,
  ReqlArray)

"SLICE = 30; // Sequence, NUMBER, NUMBER -> Sequence"
@reql_one_two_three(30, slice,
  ReqlSequence, ReqlNumber, ReqlNumber,
  ReqlSequence)

"SKIP = 70; // Sequence, NUMBER -> Sequence"
@reql_one_two(70, skip,
  ReqlSequence, ReqlNumber,
  ReqlSequence)

"LIMIT = 71; // Sequence, NUMBER -> Sequence"
@reql_one_two(71, limit,
  ReqlSequence, ReqlNumber,
  ReqlSequence)

"OFFSETS_OF = 87; // Sequence, DATUM -> Sequence | Sequence, Function(1) -> Sequence"
@reql_one_two(87, offsets_of,
  ReqlSequence, ReqlDatum,
  ReqlSequence)
@reql_one_two(87, offsets_of,
  ReqlSequence, ReqlFunction1,
  ReqlSequence)

# TODO: Function or Datum
"CONTAINS = 93; // Sequence, (DATUM | Function(1))... -> BOOL"
@reql_one_twoarr(93, contains,
  ReqlSequence, ReqlDatum,
  ReqlBool)

# Stream/Object Ops

"""
Get a particular field from an object, or map that over a
sequence.

GET_FIELD = 31; // OBJECT, STRING -> DATUM
                // | Sequence, STRING -> Sequence
"""
@reql_one_two(31, get_field,
  ReqlObject, ReqlString,
  ReqlDatum)
@reql_one_two(31, get_field,
  ReqlSequence, ReqlString,
  ReqlSequence)

"""
Return an array containing the keys of the object.

KEYS = 94; // OBJECT -> ARRAY
"""
@reql_one(94, keys,
  ReqlObject,
  ReqlArray)

"""
Return an array containing the values of the object.

VALUES = 186; // OBJECT -> ARRAY
"""
@reql_one(186, values,
  ReqlObject,
  ReqlArray)

#=
TODO
Creates an object

OBJECT = 143; // STRING, DATUM, ... -> OBJECT
=#

"""
Check whether an object contains all the specified fields,
or filters a sequence so that all objects inside of it
contain all the specified fields.

HAS_FIELDS = 32; // OBJECT, Pathspec... -> BOOL
"""
@reql_one_two(32, has_fields,
  ReqlObject, ReqlPathSpec,
  ReqlBool)

#=
TODO
x.with_fields(...) <=> x.has_fields(...).pluck(...)
WITH_FIELDS = 96; // Sequence, Pathspec... -> Sequence
=#

"""
Get a subset of an object by selecting some attributes to preserve,
or map that over a sequence.  (Both pick and pluck, polymorphic.)

PLUCK = 33; // Sequence, Pathspec... -> Sequence | OBJECT, Pathspec... -> OBJECT
"""
@reql_one_twoarr(33, pluck,
  ReqlSequence, ReqlPathSpec,
  ReqlSequence)
@reql_one_twoarr(33, pluck,
  ReqlObject, ReqlPathSpec,
  ReqlObject)

#=
TODO
Get a subset of an object by selecting some attributes to discard, or
map that over a sequence.  (Both unpick and without, polymorphic.)
WITHOUT = 34; // Sequence, Pathspec... -> Sequence | OBJECT, Pathspec... -> OBJECT
=#

#=
TODO
Merge objects (right-preferential)
MERGE = 35; // OBJECT... -> OBJECT | Sequence -> Sequence
=#

# Sequence Ops

#=
Get all elements of a sequence between two values.
Half-open by default, but the openness of either side can be
changed by passing 'closed' or 'open for `right_bound` or
`left_bound`.
=#

#=
BETWEEN_DEPRECATED = 36; // Deprecated version of between, which allows `null` to specify unboundedness
                         // With the newer version, clients should use `r.minval` and `r.maxval` for unboundedness
=#

#=
TODO
 BETWEEN   = 182; // StreamSelection, DATUM, DATUM, {index:!STRING, right_bound:STRING, left_bound:STRING} -> StreamSelection
=#

#=
TODO
REDUCE = 37; // Sequence, Function(2) -> DATUM
=#

#=
TODO
MAP = 38; // Sequence, Function(1) -> Sequence
          // The arity of the function should be
          // Sequence..., Function(sizeof...(Sequence)) -> Sequence
=#

"""
Filter a sequence with either a function or a shortcut
object (see API docs for details).  The body of FILTER is
wrapped in an implicit `.default(false)`, and you can
change the default value by specifying the `default`
optarg.  If you make the default `r.error`, all errors
caught by `default` will be rethrown as if the `default`
did not exist.

FILTER = 39; // Sequence, Function(1), {default:DATUM} -> Sequence |
             // Sequence, OBJECT, {default:DATUM} -> Sequence
"""
@reql_one_two(39, filter,
  ReqlSequence, ReqlFunction1,
  ReqlSequence)
@reql_one_two(39, filter,
  ReqlSequence, ReqlObject,
  ReqlSequence)

#=
TODO
Map a function over a sequence and then concatenate the results together.

CONCAT_MAP = 40; // Sequence, Function(1) -> Sequence
=#

#=
TODO
Order a sequence based on one or more attributes.

ORDER_BY = 41; // Sequence, (!STRING | Ordering)..., {index: (!STRING | Ordering)} -> Sequence
=#

"""
Get all distinct elements of a sequence (like `uniq`).

DISTINCT = 42; // Sequence -> Sequence
"""
@reql_one(42, distinct,
  ReqlSequence,
  ReqlSequence)

"""
Count the number of elements in a sequence, or only the elements that match
a given filter.

COUNT = 43; // Sequence -> NUMBER | Sequence, DATUM -> NUMBER | Sequence, Function(1) -> NUMBER
"""
@reql_one(43, count,
  ReqlSequence,
  ReqlNumber)
@reql_one_two(43, count,
  ReqlSequence, ReqlDatum,
  ReqlNumber)
@reql_one_two(43, count,
  ReqlSequence, ReqlFunction,
  ReqlNumber)

"IS_EMPTY = 86; // Sequence -> BOOL"
@reql_one(86, is_empty,
  ReqlSequence,
  ReqlBool)

#=
TODO
Take the union of multiple sequences (preserves duplicate elements! (use distinct)).
UNION = 44; // Sequence... -> Sequence
=#

"""
Get the Nth element of a sequence.

NTH = 45; // Sequence, NUMBER -> DATUM
"""
@reql_one_two(45, nth,
  ReqlSequence, ReqlNumber,
  ReqlDatum)

"""
do NTH or GET_FIELD depending on target object

BRACKET = 170; // Sequence | OBJECT, NUMBER | STRING -> DATUM
"""
@reql_one_two(170, bracket,
  ReqlSequence, ReqlNumber,
  ReqlDatum)
@reql_one_two(170, bracket,
  ReqlSequence, ReqlString,
  ReqlDatum)
@reql_one_two(170, bracket,
    ReqlDatum, ReqlString,
    ReqlDatum)
@reql_one_two(170, bracket,
  ReqlObject, ReqlString,
  ReqlDatum)


# OBSOLETE_GROUPED_MAPREDUCE = 46;

# OBSOLETE_GROUPBY = 47;

#=
TODO
INNER_JOIN = 48; // Sequence, Sequence, Function(2) -> Sequence
=#

#=
TODO
OUTER_JOIN = 49; // Sequence, Sequence, Function(2) -> Sequence
=#

#=
TODO
An inner-join that does an equality comparison on two attributes.

EQ_JOIN = 50; // Sequence, !STRING, Sequence, {index:!STRING} -> Sequence
=#

"ZIP = 72; // Sequence -> Sequence"
@reql_one(72, zip,
  ReqlSequence,
  ReqlSequence)

"""
RANGE = 173; // -> Sequence                        [0, +inf)
             // NUMBER -> Sequence                 [0, a)
             // NUMBER, NUMBER -> Sequence         [a, b)
"""
@reql_zero(173, range,
  ReqlSequence)
@reql_one(173, range,
  ReqlNumber,
  ReqlSequence)
@reql_one_two(173, range,
  ReqlNumber, ReqlNumber,
  ReqlSequence)

# Array Ops

"""
Insert an element in to an array at a given index.

INSERT_AT = 82; // ARRAY, NUMBER, DATUM -> ARRAY
"""
@reql_one_two_three(82, insert_at,
  ReqlArray, ReqlNumber, ReqlDatum,
  ReqlArray)

"""
Remove an element at a given index from an array.

DELETE_AT = 83; // ARRAY, NUMBER -> ARRAY |
                // ARRAY, NUMBER, NUMBER -> ARRAY
"""
@reql_one_two(83, delete_at,
  ReqlArray, ReqlNumber,
  ReqlArray)
@reql_one_two_three(83, delete_at,
  ReqlArray, ReqlNumber, ReqlNumber,
  ReqlArray)

"""
Change the element at a given index of an array.

CHANGE_AT = 84; // ARRAY, NUMBER, DATUM -> ARRAY
"""
@reql_one_two_three(84, change_at,
  ReqlArray, ReqlNumber, ReqlDatum,
  ReqlArray)

"""
Splice one array in to another array.

SPLICE_AT = 85; // ARRAY, NUMBER, ARRAY -> ARRAY
"""
@reql_one_two_three(85, splice_at,
  ReqlArray, ReqlNumber, ReqlArray,
  ReqlArray)

# Type Ops

"""
Coerces a datum to a named type (e.g. "bool").
If you previously used `stream_to_array`, you should use this instead
with the type "array".

COERCE_TO = 51; // Top, STRING -> Top
"""
@reql_one_two(51, coerce_to,
  ReqlTop, ReqlString,
  ReqlTop)

"""
Returns the named type of a datum (e.g. TYPE_OF(true) = "BOOL")

TYPE_OF = 52; // Top -> STRING
"""
@reql_one(52, type_of,
  ReqlTop,
  ReqlString)

# Write Ops (the OBJECTs contain data about number of errors etc.)

"""
TODO: func
Updates all the rows in a selection.  Calls its Function with the row
to be updated, and then merges the result of that call.

UPDATE = 53; // StreamSelection, Function(1), {non_atomic:BOOL, durability:STRING, return_changes:BOOL} -> OBJECT |
             // SingleSelection, Function(1), {non_atomic:BOOL, durability:STRING, return_changes:BOOL} -> OBJECT |
             // StreamSelection, OBJECT,      {non_atomic:BOOL, durability:STRING, return_changes:BOOL} -> OBJECT |
             // SingleSelection, OBJECT,      {non_atomic:BOOL, durability:STRING, return_changes:BOOL} -> OBJECT
"""
@reql_one_two(53, update,
  ReqlStreamSelection, ReqlFunction1,
  ReqlObject)
@reql_one_two(53, update,
  ReqlSingleSelection, ReqlFunction1,
  ReqlObject)
@reql_one_two(53, update,
  ReqlStreamSelection, ReqlObject,
  ReqlObject)
@reql_one_two(53, update,
  ReqlSingleSelection, ReqlObject,
  ReqlObject)

"""
Deletes all the rows in a selection.

DELETE = 54; // StreamSelection, {durability:STRING, return_changes:BOOL} -> OBJECT | SingleSelection -> OBJECT
"""
@reql_one(54, delete,
  ReqlStreamSelection,
  ReqlObject)
@reql_one(54, delete,
  ReqlSingleSelection,
  ReqlObject)

#=
TODO
Replaces all the rows in a selection.  Calls its Function with the row
to be replaced, and then discards it and stores the result of that
call.

REPLACE = 55; // StreamSelection, Function(1), {non_atomic:BOOL, durability:STRING, return_changes:BOOL} -> OBJECT | SingleSelection, Function(1), {non_atomic:BOOL, durability:STRING, return_changes:BOOL} -> OBJECT
=#

"""
Inserts into a table.  If `conflict` is replace, overwrites
entries with the same primary key.  If `conflict` is
update, does an update on the entry.  If `conflict` is
error, or is omitted, conflicts will trigger an error.

INSERT = 56; // Table, OBJECT, {conflict:STRING, durability:STRING, return_changes:BOOL} -> OBJECT |
             // Table, Sequence, {conflict:STRING, durability:STRING, return_changes:BOOL} -> OBJECT
"""
@reql_one_two(56, insert,
  ReqlTable, ReqlObject,
  ReqlObject)
@reql_one_two(56, insert,
  ReqlTable, ReqlSequence,
  ReqlObject)

# Administrative OPs

"""
Creates a database with a particular name.

DB_CREATE = 57; // STRING -> OBJECT
"""
@reql_one(57, db_create,
  ReqlString,
  ReqlObject)

"""
Drops a database with a particular name.

DB_DROP = 58; // STRING -> OBJECT
"""
@reql_one(58, db_drop,
  ReqlString,
  ReqlObject)

"""
Lists all the databases by name.  (Takes no arguments)

DB_LIST = 59; // -> ARRAY
"""
@reql_zero(59, db_list,
  ReqlArray)

"""
Creates a table with a particular name in a particular
database.  (You may omit the first argument to use the
default database.)

TABLE_CREATE = 60; // Database, STRING, {primary_key:STRING, shards:NUMBER, replicas:NUMBER, primary_replica_tag:STRING} -> OBJECT
                   // Database, STRING, {primary_key:STRING, shards:NUMBER, replicas:OBJECT, primary_replica_tag:STRING} -> OBJECT
                   // STRING, {primary_key:STRING, shards:NUMBER, replicas:NUMBER, primary_replica_tag:STRING} -> OBJECT
                   // STRING, {primary_key:STRING, shards:NUMBER, replicas:OBJECT, primary_replica_tag:STRING} -> OBJECT
"""
@reql_one_two(60, table_create,
  ReqlDatabase, ReqlString,
  ReqlObject)
@reql_one(60, table_create,
  ReqlString,
  ReqlObject)

"""
Drops a table with a particular name from a particular
database.  (You may omit the first argument to use the
default database.)

TABLE_DROP = 61; // Database, STRING -> OBJECT
                 // STRING -> OBJECT
"""
@reql_one_two(61, table_drop,
  ReqlDatabase, ReqlString,
  ReqlObject)
@reql_one(61, table_drop,
  ReqlString,
  ReqlObject)

"""
Lists all the tables in a particular database.  (You may
omit the first argument to use the default database.)

TABLE_LIST = 62; // Database -> ARRAY
                 //  -> ARRAY
"""
@reql_one(62, table_list,
  ReqlDatabase,
  ReqlArray)
@reql_zero(62, table_list,
  ReqlArray)

"""
Returns the row in the `rethinkdb.table_config` or `rethinkdb.db_config` table
that corresponds to the given database or table.
CONFIG  = 174; // Database -> SingleSelection
               // Table -> SingleSelection
"""
@reql_one(174, config,
  ReqlDatabase,
  ReqlTable)

"""
Returns the row in the `rethinkdb.table_status` table that corresponds to the
given table.

STATUS  = 175; // Table -> SingleSelection
"""
@reql_one(175, status,
  ReqlTable,
  ReqlSingleSelection)

"""
Called on a table, waits for that table to be ready for read/write operations.
Called on a database, waits for all of the tables in the database to be ready.
Returns the corresponding row or rows from the `rethinkdb.table_status` table.

WAIT    = 177; // Table -> OBJECT
               // Database -> OBJECT
"""
@reql_one(177, wait,
  ReqlTable,
  ReqlObject)
@reql_one(177, wait,
  ReqlDatabase,
  ReqlObject)

"""
Generates a new config for the given table, or all tables in the given database
The `shards` and `replicas` arguments are required. If `emergency_repair` is
specified, it will enter a completely different mode of repairing a table
which has lost half or more of its replicas.

RECONFIGURE   = 176; // Database|Table, {shards:NUMBER, replicas:NUMBER [,
                     //                  dry_run:BOOLEAN]
                     //                 } -> OBJECT
                     // Database|Table, {shards:NUMBER, replicas:OBJECT [,
                     //                  primary_replica_tag:STRING,
                     //                  nonvoting_replica_tags:ARRAY,
                     //                  dry_run:BOOLEAN]
                     //                 } -> OBJECT
                     // Table, {emergency_repair:STRING, dry_run:BOOLEAN} -> OBJECT
"""
@reql_one(176, reconfigure,
  ReqlDatabase,
  ReqlObject)
@reql_one(176, reconfigure,
  ReqlTable,
  ReqlObject)

"""
Balances the table's shards but leaves everything else the same. Can also be
applied to an entire database at once.

REBALANCE     = 179; // Table -> OBJECT
                     // Database -> OBJECT
"""
@reql_one(179, rebalance,
  ReqlTable,
  ReqlObject)
@reql_one(179, rebalance,
  ReqlTable,
  ReqlDatabase)

"""
Ensures that previously issued soft-durability writes are complete and
written to disk.

SYNC = 138; // Table -> OBJECT
"""
@reql_one(138, sync,
  ReqlTable,
  ReqlObject)

"""
Set global, database, or table-specific permissions

GRANT         = 188; //          -> OBJECT
                     // Database -> OBJECT
                     // Table    -> OBJECT
"""
@reql_zero(188, grant,
  ReqlObject)
@reql_one(188, grant,
  ReqlDatabase,
  ReqlObject)
@reql_one(188, grant,
  ReqlTable,
  ReqlObject)

# Secondary indexes OPs

#=
TODO
Creates a new secondary index with a particular name and definition.
INDEX_CREATE = 75; // Table, STRING, Function(1), {multi:BOOL} -> OBJECT
=#

"""
Drops a secondary index with a particular name from the specified table.

INDEX_DROP = 76; // Table, STRING -> OBJECT
"""
@reql_one_two(76, index_drop,
  ReqlTable, ReqlString,
  ReqlObject)

"""
Lists all secondary indexes on a particular table.

INDEX_LIST = 77; // Table -> ARRAY
"""
@reql_one(77, index_list,
  ReqlTable,
  ReqlArray)

"""
Gets information about whether or not a set of indexes are ready to
be accessed. Returns a list of objects that look like this:
{index:STRING, ready:BOOL[, progress:NUMBER]}

INDEX_STATUS = 139; // Table, STRING... -> ARRAY
"""
@reql_one_twoarr(139, index_status,
  ReqlTable, ReqlString,
  ReqlArray)

"""
Blocks until a set of indexes are ready to be accessed. Returns the
same values INDEX_STATUS.

INDEX_WAIT = 140; // Table, STRING... -> ARRAY
"""
@reql_one_twoarr(140, index_wait,
  ReqlTable, ReqlString,
  ReqlArray)

"""
Renames the given index to a new name

INDEX_RENAME = 156; // Table, STRING, STRING, {overwrite:BOOL} -> OBJECT
"""
@reql_one_two_three(156, index_rename,
  ReqlTable, ReqlString, ReqlString,
  ReqlObject)

# Control Operators

#=
TODO
Calls a function on data

FUNCALL = 64; // Function(*), DATUM... -> DATUM
=#

"""
Executes its first argument, and returns its second argument if it
got [true] or its third argument if it got [false] (like an `if`
statement).

BRANCH = 65; // BOOL, Top, Top -> Top
"""
@reql_one_two_three(65, branch,
  ReqlBool, ReqlTop, ReqlTop,
  ReqlTop)

"""
Returns true if any of its arguments returns true (short-circuits).

OR = 66; // BOOL... -> BOOL
"""
@reql_onearr(66, or,
  ReqlBool,
  ReqlBool)

"""
Returns true if all of its arguments return true (short-circuits).

AND = 67; // BOOL... -> BOOL
"""
@reql_onearr(67, and,
  ReqlBool,
  ReqlBool)

#=
TODO
Calls its Function with each entry in the sequence
and executes the array of terms that Function returns.

FOR_EACH = 68; // Sequence, Function(1) -> OBJECT
=#

# Special Terms

"""
An anonymous function.  Takes an array of numbers representing
variables (see [VAR] above), and a [Term] to execute with those in
scope.  Returns a function that may be passed an array of arguments,
then executes the Term with those bound to the variable names.  The
user will never construct this directly.  We use it internally for
things like `map` which take a function.  The "arity" of a [Function] is
the number of arguments it takes.
For example, here's what `_X_.map{|x| x+2}` turns into:

```
Term {
   type = MAP;
   args = [_X_,
           Term {
             type = Function;
             args = [Term {
                       type = DATUM;
                       datum = Datum {
                         type = R_ARRAY;
                         r_array = [Datum { type = R_NUM; r_num = 1; }];
                       };
                     },
                     Term {
                       type = ADD;
                       args = [Term {
                                 type = VAR;
                                 args = [Term {
                                           type = DATUM;
                                           datum = Datum { type = R_NUM;
                                                           r_num = 1};
                                         }];
                               },
                               Term {
                                 type = DATUM;
                                 datum = Datum { type = R_NUM; r_num = 2; };
                               }];
                     }];
           }];
```

FUNC = 69; // ARRAY, Top -> ARRAY -> Top
"""
@reql_one_two(69, func,
  ReqlArray, ReqlTop,
  ReqlTop)

"""
Indicates to ORDER_BY that this attribute is to be sorted in ascending order.

ASC = 73; // !STRING -> Ordering
"""
@reql_one(73, asc,
  ReqlNumber,
  ReqlOrdering)

"""
Indicates to ORDER_BY that this attribute is to be sorted in descending order.

DESC = 74; // !STRING -> Ordering
"""
@reql_one(74, desc,
  ReqlNumber,
  ReqlOrdering)

"""
Gets info about anything.  INFO is most commonly called on tables.

INFO = 79; // Top -> OBJECT
"""
@reql_one(79, info,
  ReqlTop,
  ReqlObject)

"""
`a.match(b)` returns a match object if the string `a`
matches the regular expression `b`.

MATCH = 97; // STRING, STRING -> DATUM
"""
@reql_one_two(97, match,
  ReqlString, ReqlString,
  ReqlDatum)

"""
Change the case of a string.

UPCASE   = 141; // STRING -> STRING
"""
@reql_one(141, upcase,
  ReqlString,
  ReqlString)

"""
Change the case of a string.

DOWNCASE = 142; // STRING -> STRING
"""
@reql_one(142, downcase,
  ReqlString,
  ReqlString)

"""
Select a number of elements from sequence with uniform distribution.

SAMPLE = 81; // Sequence, NUMBER -> Sequence
"""
@reql_one_two(81, sample,
  ReqlSequence, ReqlNumber,
  ReqlSequence)

"""
Evaluates its first argument.  If that argument returns
NULL or throws an error related to the absence of an
expected value (for instance, accessing a non-existent
field or adding NULL to an integer), DEFAULT will either
return its second argument or execute it if it's a
function.  If the second argument is a function, it will be
passed either the text of the error or NULL as its
argument.

DEFAULT = 92; // Top, Top -> Top
"""
@reql_one_two(92, default,
  ReqlTop, ReqlTop,
  ReqlTop)

"""
Parses its first argument as a json string and returns it as a
datum.

JSON = 98; // STRING -> DATUM
"""
@reql_one(98, json,
  ReqlString,
  ReqlDatum)

"""
Returns the datum as a JSON string.
N.B.: we would really prefer this be named TO_JSON and that exists as
an alias in Python and JavaScript drivers; however it conflicts with the
standard `to_json` method defined by Ruby's standard json library.
TO_JSON_STRING = 172; // DATUM -> STRING
"""
@reql_one(172, to_json_string,
  ReqlDatum,
  ReqlString)

"""
Parses its first arguments as an ISO 8601 time and returns it as a
datum.

ISO8601 = 99; // STRING -> PSEUDOTYPE(TIME)
"""
@reql_one(99, iso8601,
  ReqlString,
  ReqlTime)

"""
Prints a time as an ISO 8601 time.

TO_ISO8601 = 100; // PSEUDOTYPE(TIME) -> STRING
"""
@reql_one(100, to_iso8601,
  ReqlTime,
  ReqlString)

"""
Returns a time given seconds since epoch in UTC.

EPOCH_TIME = 101; // NUMBER -> PSEUDOTYPE(TIME)
"""
@reql_one(101, epoch_time,
  ReqlNumber,
  ReqlTime)

"""
Returns seconds since epoch in UTC given a time.

TO_EPOCH_TIME = 102; // PSEUDOTYPE(TIME) -> NUMBER
"""
@reql_one(102, to_epoch_time,
  ReqlTime,
  ReqlNumber)

"""
The time the query was received by the server.

NOW = 103; // -> PSEUDOTYPE(TIME)
"""
@reql_zero(103, now,
  ReqlTime)

"""
Puts a time into an ISO 8601 timezone.

IN_TIMEZONE = 104; // PSEUDOTYPE(TIME), STRING -> PSEUDOTYPE(TIME)
"""
@reql_one_two(104, in_timezone,
  ReqlTime, ReqlString,
  ReqlTime)

"""
a.during(b, c) returns whether a is in the range [b, c)

DURING = 105; // PSEUDOTYPE(TIME), PSEUDOTYPE(TIME), PSEUDOTYPE(TIME) -> BOOL
"""
@reql_one_two_three(105, during,
  ReqlTime, ReqlTime, ReqlTime,
  ReqlBool)

"""
Retrieves the date portion of a time.

DATE = 106; // PSEUDOTYPE(TIME) -> PSEUDOTYPE(TIME)
"""
@reql_one(106, date,
  ReqlTime,
  ReqlTime)

"""
x.time_of_day == x.date - x

TIME_OF_DAY = 126; // PSEUDOTYPE(TIME) -> NUMBER
"""
@reql_one(126, time_of_day,
  ReqlTime,
  ReqlNumber)

"""
Returns the timezone of a time.

TIMEZONE = 127; // PSEUDOTYPE(TIME) -> STRING
"""
@reql_one(127, timezone,
  ReqlTime,
  ReqlString)

# These access the various components of a time.

"YEAR = 128; // PSEUDOTYPE(TIME) -> NUMBER"
@reql_one(128, year,
  ReqlTime,
  ReqlNumber)

"MONTH = 129; // PSEUDOTYPE(TIME) -> NUMBER"
@reql_one(129, month,
  ReqlTime,
  ReqlNumber)

"DAY = 130; // PSEUDOTYPE(TIME) -> NUMBER"
@reql_one(130, day,
  ReqlTime,
  ReqlNumber)

"DAY_OF_WEEK = 131; // PSEUDOTYPE(TIME) -> NUMBER"
@reql_one(131, day_of_week,
  ReqlTime,
  ReqlNumber)

"DAY_OF_YEAR = 132; // PSEUDOTYPE(TIME) -> NUMBER"
@reql_one(132, day_of_year,
  ReqlTime,
  ReqlNumber)

"HOURS = 133; // PSEUDOTYPE(TIME) -> NUMBER"
@reql_one(133, hours,
  ReqlTime,
  ReqlNumber)

"MINUTES = 134; // PSEUDOTYPE(TIME) -> NUMBER"
@reql_one(134, minutes,
  ReqlTime,
  ReqlNumber)

"SECONDS = 135; // PSEUDOTYPE(TIME) -> NUMBER"
@reql_one(135, seconds,
  ReqlTime,
  ReqlNumber)

#=
TODO
Construct a time from a date and optional timezone or a
date+time and optional timezone.

TIME = 136; // NUMBER, NUMBER, NUMBER, STRING -> PSEUDOTYPE(TIME) |
            // NUMBER, NUMBER, NUMBER, NUMBER, NUMBER, NUMBER, STRING -> PSEUDOTYPE(TIME) |
=#

# Constants for ISO 8601 days of the week.

"MONDAY = 107;    // -> 1"
@reql_zero(107, monday,
  ReqlNumber)

"TUESDAY = 108;   // -> 2"
@reql_zero(108, tuesday,
  ReqlNumber)

"WEDNESDAY = 109; // -> 3"
@reql_zero(109, wednesday,
  ReqlNumber)

"THURSDAY = 110;  // -> 4"
@reql_zero(110, thursday,
  ReqlNumber)

"FRIDAY = 111;    // -> 5"
@reql_zero(111, friday,
  ReqlNumber)

"SATURDAY = 112;  // -> 6"
@reql_zero(112, saturday,
  ReqlNumber)

"SUNDAY = 113;    // -> 7"
@reql_zero(113, sunday,
  ReqlNumber)

# Constants for ISO 8601 months.

"JANUARY = 114;   // -> 1"
@reql_zero(114, january,
  ReqlNumber)

"FEBRUARY = 115;  // -> 2"
@reql_zero(115, february,
  ReqlNumber)

"MARCH = 116;     // -> 3"
@reql_zero(116, march,
  ReqlNumber)

"APRIL = 117;     // -> 4"
@reql_zero(117, april,
  ReqlNumber)

"MAY = 118;       // -> 5"
@reql_zero(118, may,
  ReqlNumber)

"JUNE = 119;      // -> 6"
@reql_zero(119, june,
  ReqlNumber)

"JULY = 120;      // -> 7"
@reql_zero(120, july,
  ReqlNumber)

"AUGUST = 121;    // -> 8"
@reql_zero(121, august,
  ReqlNumber)

"SEPTEMBER = 122; // -> 9"
@reql_zero(122, september,
  ReqlNumber)

"OCTOBER = 123;   // -> 10"
@reql_zero(123, october,
  ReqlNumber)

"NOVEMBER = 124;  // -> 11"
@reql_zero(124, november,
  ReqlNumber)

"DECEMBER = 125;  // -> 12"
@reql_zero(125, december,
  ReqlNumber)

#=
TODO
Indicates to MERGE to replace, or remove in case of an empty literal, the
other object rather than merge it.

LITERAL = 137; // -> Merging
               // JSON -> Merging
=#

#=
"GROUP = 144; // SEQUENCE, STRING -> GROUPED_SEQUENCE | SEQUENCE, FUNCTION -> GROUPED_SEQUENCE"
@reql_one_two(144, group,
  ReqlSequence, ReqlString,
  ReqlSequence)

"SUM = 145; // SEQUENCE, STRING -> GROUPED_SEQUENCE | SEQUENCE, FUNCTION -> GROUPED_SEQUENCE"
@reql_one_two(145, sum, ReqlArray, ReqlString)

"AVG = 146; // SEQUENCE, STRING -> GROUPED_SEQUENCE | SEQUENCE, FUNCTION -> GROUPED_SEQUENCE"
@reql_one_two(146, avg, ReqlArray, ReqlString)

"MIN = 147; // SEQUENCE, STRING -> GROUPED_SEQUENCE | SEQUENCE, FUNCTION -> GROUPED_SEQUENCE"
@reql_one_two(147, min, ReqlArray, ReqlString)

"MAX = 148; // SEQUENCE, STRING -> GROUPED_SEQUENCE | SEQUENCE, FUNCTION -> GROUPED_SEQUENCE"
@reql_one_two(148, max, ReqlArray, ReqlString)
=#

"""
`str.split()` splits on whitespace
`str.split(" ")` splits on spaces only
`str.split(" ", 5)` splits on spaces with at most 5 results
`str.split(nil, 5)` splits on whitespace with at most 5 results

SPLIT = 149; // STRING -> ARRAY | STRING, STRING -> ARRAY | STRING, STRING, NUMBER -> ARRAY | STRING, NULL, NUMBER -> ARRAY
"""
@reql_one(149, split,
  ReqlString,
  ReqlArray)
@reql_one_two(149, split,
  ReqlString, ReqlString,
  ReqlArray)
@reql_one_two_three(149, split,
  ReqlString, ReqlString, ReqlNumber,
  ReqlArray)
@reql_one_two_three(149, split,
  ReqlString, ReqlNull, ReqlNumber,
  ReqlArray)

#=
TODO
UNGROUP = 150; // GROUPED_DATA -> ARRAY
=#

"""
Takes a range of numbers and returns a random number within the range

RANDOM = 151; // NUMBER, NUMBER {float:BOOL} -> DATUM
"""
@reql_one_two(151, random,
  ReqlNumber, ReqlNumber,
  ReqlDatum)

#=
"CHANGES = 152; // TABLE -> STREAM"
@reql_one(152, changes, ReqlTerm)
=#

#=
"ARGS = 154; // ARRAY -> SPECIAL (used to splice arguments)"
@reql_one(154, args, ReqlArray)
=#

# BINARY is client-only at the moment, it is not supported on the server
# BINARY = 155; // STRING -> PSEUDOTYPE(BINARY)

#=
"GEOJSON = 157;           // OBJECT -> PSEUDOTYPE(GEOMETRY)"
@reql_one(157, geojson, ReqlObject)

"TO_GEOJSON = 158;        // PSEUDOTYPE(GEOMETRY) -> OBJECT"
@reql_one(158, to_geojson, ReqlTerm)

"POINT = 159;             // NUMBER, NUMBER -> PSEUDOTYPE(GEOMETRY)"
@reql_one_two(159, point, ReqlNumber, ReqlNumber)
=#

#=
TODO
LINE = 160;              // (ARRAY | PSEUDOTYPE(GEOMETRY))... -> PSEUDOTYPE(GEOMETRY)
=#

#=
TODO
POLYGON = 161;           // (ARRAY | PSEUDOTYPE(GEOMETRY))... -> PSEUDOTYPE(GEOMETRY)
=#

#=
"DISTANCE = 162;          // PSEUDOTYPE(GEOMETRY), PSEUDOTYPE(GEOMETRY) {geo_system:STRING, unit:STRING} -> NUMBER"
@reql_one_two(162, distance, ReqlTerm, ReqlTerm)

"INTERSECTS = 163;        // PSEUDOTYPE(GEOMETRY), PSEUDOTYPE(GEOMETRY) -> BOOL"
@reql_one_two(163, intersects, ReqlTerm, ReqlTerm)

"INCLUDES = 164;          // PSEUDOTYPE(GEOMETRY), PSEUDOTYPE(GEOMETRY) -> BOOL"
@reql_one_two(164, includes, ReqlTerm, ReqlTerm)

"CIRCLE = 165;            // PSEUDOTYPE(GEOMETRY), NUMBER {num_vertices:NUMBER, geo_system:STRING, unit:STRING, fill:BOOL} -> PSEUDOTYPE(GEOMETRY)"
@reql_one(165, distance, ReqlTerm)

"GET_INTERSECTING = 166;  // TABLE, PSEUDOTYPE(GEOMETRY) {index:!STRING} -> StreamSelection"
@reql_one_two(166, get_intersecting, ReqlTerm, ReqlTerm)

"FILL = 167;              // PSEUDOTYPE(GEOMETRY) -> PSEUDOTYPE(GEOMETRY)"
@reql_one(167, fill, ReqlTerm)

"GET_NEAREST = 168;       // TABLE, PSEUDOTYPE(GEOMETRY) {index:!STRING, max_results:NUM, max_dist:NUM, geo_system:STRING, unit:STRING} -> ARRAY"
@reql_one_two(168, get_nearest, ReqlTerm, ReqlTerm)

"POLYGON_SUB = 171;       // PSEUDOTYPE(GEOMETRY), PSEUDOTYPE(GEOMETRY) -> PSEUDOTYPE(GEOMETRY)"
@reql_one_two(171, polygon_sub, ReqlTerm, ReqlTerm)

# Constants for specifying key ranges

"MINVAL = 180;"
@reql_zero(180, minval)

"MAXVAL = 181;"
@reql_zero(181, maxval)
=#

function row(s::ByteString)
  implicit_var() |>
    d -> bracket(d, s)
end

@reql_one_two(69, func,
  ReqlArray, ReqlTop,
  ReqlTop)

function func0(f)
  o = func(make_array(), f)
  ReqlFunction1(-1, o)
end
