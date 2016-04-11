# The RQL type hierarchy is as follows:
#   Top
#     DATUM
#       NULL
#       BOOL
#       NUMBER
#       STRING
#       OBJECT
#         SingleSelection
#       ARRAY
#     Sequence
#       ARRAY
#       Stream
#         StreamSelection
#           Table
#     Database
#     Function
#     Ordering - used only by ORDER_BY
#     Pathspec -- an object, string, or array that specifies a path
#   Error

type ReqlTerm
  value::Union{Nullable, Bool, Number, AbstractString, Array, Dict}
end

# typealias ReqlError
  # typealias ReqlPathSpec
  # typealias ReqlOrdering
  # typealias ReqlFunction
  # typealias ReqlDatabase
        # typealias ReqlTable
      # typealias ReqlStremSelection
    # typealias ReqlStream
    # ReqlArray -> defined
  type ReqlSequence
    value::Array
  end
    type ReqlArray
      value::Array
    end
        # typealias ReqlSingleSelection = Dict
    type ReqlObject
      value::Union{Dict, Array}
    end
    type ReqlString
      value::ByteString
    end
    type ReqlNumber
      value::Number
    end
    type ReqlBool
      value::Bool
    end
    type ReqlNull
      value::Nullable
    end
  type ReqlDatum
    value::Union{ReqlNull, ReqlBool, ReqlNumber, ReqlString, ReqlArray, Dict}
  end
type ReqlTop
  value::Union{ReqlDatum, ReqlSequence}
end
