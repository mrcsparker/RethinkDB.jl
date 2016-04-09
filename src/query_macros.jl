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

macro rqlgen_root(op_code::Int, name::Symbol)
  quote
    function $(esc(name))()
      local retval = []
      push!(retval, $(op_code))
      RQL(retval)
    end
  end
end

macro rqlgen_string(op_code::Int, name::Symbol)
  quote
    function $(esc(name))(t_string_1::AbstractString)
      local retval = []
      push!(retval, $(op_code))

      local sub = []
      push!(sub, t_string_1)

      push!(retval, sub)

      RQL(retval)
    end
  end
end

macro rqlgen_rql_string(op_code::Int, name::Symbol)
  quote
    function $(esc(name))(t_rql_1::RQL, t_string_2::AbstractString)
      local retval = []
      push!(retval, $(op_code))

      local sub = []
      push!(sub, t_rql_1.query)
      push!(sub, t_string_2)

      push!(retval, sub)

      RQL(retval)
    end
  end
end

macro rqlgen_rql_number(op_code::Int, name::Symbol)
  quote
    function $(esc(name))(t_rql_1::RQL, t_number_2::Int64)
      local retval = []
      push!(retval, $(op_code))

      local sub = []
      push!(sub, t_rql_1.query)
      push!(sub, t_number_2)

      push!(retval, sub)

      RQL(retval)
    end
  end
end

macro rqlgen_rql(op_code::Int, name::Symbol)
  quote
    function $(esc(name))(t_rql_1::RQL)
      local retval = []
      push!(retval, $(op_code))

      local sub = []
      push!(sub, t_rql_1.query)

      push!(retval, sub)

      RQL(retval)
    end
  end
end

macro rqlgen_rql_object(op_code::Int, name::Symbol)
  quote
    function $(esc(name))(t_rql_1::RQL, t_object_2::Int64)
      local retval = []
      push!(retval, $(op_code))

      local sub = []
      push!(sub, t_rql_1.query)
      push!(sub, wrap(t_object_2))

      push!(retval, sub)

      RQL(retval)
    end
  end
end

macro operate_on_zero_args(op_code::Int, name::Symbol)
  quote
    function $(esc(name))()
      retval = []
      push!(retval, $(op_code))
      RQL(retval)
    end

    function $(esc(name))(query)
      retval = []
      push!(retval, $(op_code))

      sub = []
      push!(sub, query)

      push!(retval, sub)

      RQL(retval)
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

      RQL(retval)
    end

    function $(esc(name))(query, arg1)
      retval = []
      push!(retval, $(op_code))

      sub = []
      push!(sub, query)
      push!(sub, wrap(arg1))

      push!(retval, sub)

      RQL(retval)
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

      RQL(retval)
    end

    function $(esc(name))(query, arg1, arg2)
      retval = []
      push!(retval, $(op_code))

      sub = []
      push!(sub, query)
      push!(sub, wrap(arg1))
      push!(sub, wrap(arg2))

      push!(retval, sub)

      RQL(retval)
    end
  end
end
