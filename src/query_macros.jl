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
  if typeof(o) != ReqlObject && typeof(o) != ReqlSequence
    return o
  end

  _wrap(o.value)
  o
end

function convert_type(from, to)
  if typeof(from) == to
    return from
  end
  to(-1, from)
end

function convert_arr_type(from, to)
  new_arr = []

  for i in 1:length(from)
    if typeof(from[i]) == to
      push!(new_arr, from[i])
    else
      push!(new_arr, to(-1, from[i]))
    end
  end
  new_arr
end

macro reql_zero(op_code::Int, name::Symbol, RET)
  quote
    function $(esc(name))()
      $(RET)($op_code, [])
    end
  end
end

macro reql_one(op_code::Int, name::Symbol, T1, RET)

  quote
    function $(esc(name))(arg1::$(reql_type(eval(T1))))

      arg1 = convert_type(arg1, $T1)

      local retval = []
      push!(retval, wrap(arg1))

      $(RET)($op_code, retval)
    end
  end
end

macro reql_onearr(op_code::Int, name::Symbol, T1, RET)
  quote
    function $(esc(name))(arg1::$(reql_type(eval(T1)))...)

      arg1 = convert_arr_type(arg1, $T1)

      local retval = []
      for i in arg1
        push!(retval, wrap(i))
      end

      $(RET)($op_code, retval)
    end
  end
end

macro reql_one_two(op_code::Int, name::Symbol, T1, T2, RET)
  quote
    function $(esc(name))(arg1::$(reql_type(eval(T1))), arg2::$(reql_type(eval(T2))))

      arg1 = convert_type(arg1, $T1)
      arg2 = convert_type(arg2, $T2)

      local retval = []
      push!(retval, wrap(arg1))
      push!(retval, wrap(arg2))

      $(RET)($op_code, retval)
    end
  end
end

macro reql_one_twoarr(op_code::Int, name::Symbol, T1, T2, RET)
  quote
    function $(esc(name))(arg1::$(reql_type(eval(T1))), arg2::$(reql_arr_type(eval(T2))))

      arg1 = convert_type(arg1, $T1)
      arg2 = convert_arr_type(arg2, $T2)

      local retval = []
      push!(retval, wrap(arg1))
      for i in arg2
        push!(retval, wrap(i))
      end

      $(RET)($op_code, retval)
    end
  end
end

macro reql_one_two_three(op_code::Int, name::Symbol, T1, T2, T3, RET)
  quote
    function $(esc(name))(arg1::$(reql_type(eval(T1))), arg2::$(reql_type(eval(T2))), arg3::$(reql_type(eval(T3))))

      arg1 = convert_type(arg1, $T1)
      arg2 = convert_type(arg2, $T2)
      arg3 = convert_type(arg3, $T3)

      local retval = []
      push!(retval, wrap(arg1))
      push!(retval, wrap(arg2))
      push!(retval, wrap(arg3))

      $(RET)($op_code, retval)
    end
  end
end
