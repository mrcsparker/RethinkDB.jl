# The RQL type hierarchy is as follows:
# Top
type ReqlTop
  # t =  na
  op_code::Number
  value
end

function reql_type(a::Type{ReqlTop})
  Union{
    ReqlDatum,
      ReqlNull, Nullable,
      ReqlBool, Bool,
      ReqlNumber, Number,
      ReqlString, ByteString,
      ReqlObject, Associative,
        ReqlSingleSelection,
      ReqlArray, Array,
    ReqlSequence,
      ReqlArray, Array,
      ReqlStream,
        ReqlStreamSelection,
          ReqlTable,
    ReqlDatabase,
    ReqlFunction,ReqlFunction1,
    ReqlOrdering,
    ReqlPathSpec}
end

# Top/DATUM
type ReqlDatum
  # t =  na
  op_code::Number
  value
end

function reql_type(a::Type{ReqlDatum})
  Union{
    ReqlDatum,
      ReqlNull, Nullable,
      ReqlBool, Bool,
      ReqlNumber, Number,
      ReqlString, ByteString,
      ReqlObject, Associative,
        ReqlSingleSelection,
      ReqlArray, Array}
end

# Top/DATUM/NULL
type ReqlNull
  # t = 1
  # value::Nullable
  op_code::Number
  value
end

function reql_type(a::Type{ReqlNull})
  Nullable
end

# Top/DATUM/BOOL
type ReqlBool
  # t = 2
  # value::Bool
  op_code::Number
  value
end

function reql_type(a::Type{ReqlBool})
  Bool
end

# Top/DATUM/NUMBER
type ReqlNumber
  # t = 3
  # value::Number
  op_code::Number
  value
end

function reql_type(a::Type{ReqlNumber})
  Number
end

function reql_arr_type(a::Type{ReqlNumber})
  Union{Array{Int64},Array{Float64}}
end

function reql_arr_type(a)
  Array
end

# Top/DATUM/STRING
type ReqlString
  # t = 4
  # value::ByteString
  op_code::Number
  value
end

function reql_type(a::Type{ReqlString})
  ByteString
end

# Top/DATUM/OBJECT
type ReqlObject
  # t = 6
  # value::Associative
  op_code::Number
  value
end

function reql_type(a::Type{ReqlObject})
  Union{
    ReqlObject, Associative,
      ReqlSingleSelection}
end

# Top/DATUM/OBJECT/SingleSelection
type ReqlSingleSelection
  # t = na
  # value::Associative
  op_code::Number
  value
end

function reql_type(a::Type{ReqlSingleSelection})
  ReqlSingleSelection
end

# Top/DATUM/ARRAY
type ReqlArray
  # t = 5
  # value::Array
  op_code::Number
  value
end

function reql_type(a::Type{ReqlArray})
  Union{ReqlArray,Array}
end

# Top/Sequence
type ReqlSequence
  # t = na
  # value::Array
  op_code::Number
  value
end

function reql_type(a::Type{ReqlSequence})
  Union{
    ReqlSequence,
      ReqlArray, Array,
      ReqlStream,
        ReqlStreamSelection,
          ReqlTable}
end

# Top/Sequence/ARRAY
# type ReqlArray
#   t = 5
#   value::Array
#   value
# end

# Top/SequenceStream
type ReqlStream
  # t = na
  op_code::Number
  value
end

function reql_type(a::Type{ReqlStream})
  Union{
    ReqlStream,ReqlStreamSelection,ReqlTable}
end

# Top/SequenceStream/StreamSelection
type ReqlStreamSelection
  # t = na
  op_code::Number
  value
end

function reql_type(a::Type{ReqlStreamSelection})
  ReqlStreamSelection
end

# Top/SequenceStream/StreamSelection/Table
type ReqlTable
  # t = na
  op_code::Number
  value
end

function reql_type(a::Type{ReqlTable})
  ReqlTable
end

# Top/Database
type ReqlDatabase
  # t = na
  op_code::Number
  value
end

function reql_type(a::Type{ReqlDatabase})
  ReqlDatabase
end

# Top/Function
type ReqlFunction
  # t = na
  op_code::Number
  value
end

function reql_type(a::Type{ReqlFunction})
  ReqlFunction
end

# Top/Function
type ReqlFunction1
  # t = na
  op_code::Number
  value
end

function reql_type(a::Type{ReqlFunction1})
  ReqlFunction1
end

# Top/Ordering - used only by ORDER_BY
type ReqlOrdering
  # t = na
  op_code::Number
  value
end

function reql_type(a::Type{ReqlOrdering})
  ReqlOrdering
end

# Top/Pathspec -- an object, string, or array that specifies a path
type ReqlPathSpec
  # t = na
  op_code::Number
  value
end

function reql_type(a::Type{ReqlPathSpec})
  ReqlPathSpec
end

# Error
type ReqlError
  # t = na
  op_code::Number
  value
end

function reql_type(a::Type{ReqlError})
  ReqlError
end

type ReqlTime
  # t = na
  op_code::Number
  value
end

function reql_type(a::Type{ReqlTime})
  ReqlTime
end
