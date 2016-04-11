# Have to do the funky push! on arrays due to
# the deprecated [] auto-concatenation still
# enabled in Julia 0.4

include("types.jl")

function _wrap(w)

  if ismatch(r"^Array", string(typeof(w)))
    for k in 1:length(w)
      w[k] = _wrap(w[k])
    end
    p = []
    push!(p, 2)
    push!(p, w)
    return p
  end

  if ismatch(r"^Dict", string(typeof(w)))
    for k in Base.keys(w)
      w[k] = _wrap(w[k])
    end
    return w
  end

  w
end

function wrap(o)
  if typeof(o) != ReqlObject
    return o.value
  end
  _wrap(o.value)
end

function convert_type(from, to)
  if typeof(from) == to
    return from
  end
  to(from)
end

function convert_arr_type(from, to)
  for i in 1:length(from)
    if typeof(from[i]) != to
      from[i] = to(from)
    end
  end
  from
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
    function $(esc(name))(arg1)

      arg1 = convert_type(arg1, $T1)

      local retval = []
      push!(retval, $op_code)

      local sub = []
      push!(sub, wrap(arg1))

      push!(retval, sub)

      ReqlTerm(retval)
    end
  end
end

macro reql_onearr(op_code::Int, name::Symbol, T1)
  quote
    function $(esc(name))(arg1...)

      arg1 = convert_arr_type(arg1, $T1)

      local retval = []
      push!(retval, $op_code)

      local sub = []
      for i in arg1
        push!(sub, wrap(i))
      end

      push!(retval, sub)

      ReqlTerm(retval)
    end
  end
end

macro reql_one_two(op_code::Int, name::Symbol, T1, T2)
  quote
    function $(esc(name))(arg1, arg2)

      arg1 = convert_type(arg1, $T1)
      arg2 = convert_type(arg2, $T2)

      local retval = []
      push!(retval, $op_code)

      local sub = []
      push!(sub, wrap(arg1))
      push!(sub, wrap(arg2))

      push!(retval, sub)

      ReqlTerm(retval)
    end
  end
end

macro reql_one_twoarr(op_code::Int, name::Symbol, T1, T2)
  quote
    function $(esc(name))(arg1, arg2...)

      arg1 = convert_type(arg1, $T1)
      arg2 = convert_arr_type(arg2, $T2)

      local retval = []
      push!(retval, $op_code)

      local sub = []
      push!(sub, wrap(arg1))
      push!(sub, wrap(arg2))

      push!(retval, sub)

      ReqlTerm(retval)
    end
  end
end

macro reql_one_two_three(op_code::Int, name::Symbol, T1, T2, T3)
  quote
    function $(esc(name))(arg1, arg2, arg3)

      arg1 = convert_type(arg1, $T1)
      arg2 = convert_type(arg2, $T2)
      arg3 = convert_type(arg3, $T3)

      local retval = []
      push!(retval, $op_code)

      local sub = []
      push!(sub, wrap(arg1))
      push!(sub, wrap(arg2))
      push!(sub, wrap(arg3))

      push!(retval, sub)

      ReqlTerm(retval)
    end
  end
end
