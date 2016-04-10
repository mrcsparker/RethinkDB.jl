# Have to do the funky push! on arrays due to
# the deprecated [] auto-concatenation still
# enabled in Julia 0.4

include("types.jl")

function wrap_reql_object(o)
  if ismatch(r"^Array", string(typeof(o)))
    for k in 1:length(o)
      o[k] = wrap_reql_object(o[k])
    end
    p = []
    push!(p, 2)
    push!(p, o)
    return p
  end

  if ismatch(r"^Dict", string(typeof(o)))
    for k in Base.keys(o)
      o[k] = wrap_reql_object(o[k])
    end
    return o
  end

  o
end

macro reql_zero(op_code::Int, name::Symbol)
  quote
    function $(esc(name))()
      local retval = []
      push!(retval, $op_code)
      ReqlTerm(retval)
    end
  end
end

macro reql_one(op_code::Int, name::Symbol, T1)
  quote
    function $(esc(name))(arg1::$T1)
      local retval = []
      push!(retval, $op_code)

      local sub = []
      push!(sub, arg1)

      push!(retval, sub)

      ReqlTerm(retval)
    end
  end
end

macro reql_onearr(op_code::Int, name::Symbol, T1)
  quote
    function $(esc(name))(arg1::$T1...)
      local retval = []
      push!(retval, $op_code)

      local sub = []
      for i in arg1
        push!(sub, i)
      end

      push!(retval, sub)

      ReqlTerm(retval)
    end
  end
end

macro reql_two(op_code::Int, name::Symbol, T1, T2)
  quote
    function $(esc(name))(arg1::$T1, arg2::$T2)
      local retval = []
      push!(retval, $op_code)

      local sub = []
      push!(sub, arg1)
      push!(sub, arg2)

      push!(retval, sub)

      ReqlTerm(retval)
    end
  end
end

macro reql_three(op_code::Int, name::Symbol, T1, T2, T3)
  quote
    function $(esc(name))(arg1::$T1, arg2::$T2, arg3::$T3)
      local retval = []
      push!(retval, $op_code)

      local sub = []
      push!(sub, arg1)
      push!(sub, arg2)
      push!(sub, arg3)

      push!(retval, sub)

      ReqlTerm(retval)
    end
  end
end

macro reql_object(op_code::Int, name::Symbol)
  quote
    function $(esc(name))(object)
      local retval = []
      push!(retval, $(op_code))

      local sub = []
      push!(sub, wrap_reql_object(object))

      push!(retval, sub)

      ReqlTerm(retval)
    end
  end
end

macro reql_term_object(op_code::Int, name::Symbol)
  quote
    function $(esc(name))(term::ReqlTerm, object)
      local retval = []
      push!(retval, $(op_code))

      local sub = []
      push!(sub, term)
      push!(sub, wrap_reql_object(object))

      push!(retval, sub)

      ReqlTerm(retval)
    end
  end
end
