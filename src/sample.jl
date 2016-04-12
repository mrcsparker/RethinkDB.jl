function do_ast()
  r = RethinkDB

  #=
  r.db_create("sample_db") |>
    println

  r.db("sample_db") |>
    d -> r.table_create(d, "authors") |>
    println

    cursor = r.db("sample_db") |>
      d -> r.table(d, "authors") |>
      d -> r.insert(d, [
        { "name"=>"William Adama", "tv_show"=>"Battlestar Galactica",
          "posts"=>[
            {"title"=>"Decommissioning speech", "content"=>"The Cylon War is long over..."},
            {"title"=>"We are at war", "content"=>"Moments ago, this ship received..."},
            {"title"=>"The new Earth", "content"=>"The discoveries of the past few days..."}
          ]
        },
        { "name"=>"Laura Roslin", "tv_show"=>"Battlestar Galactica",
          "posts"=>[
            {"title"=>"The oath of office", "content"=>"I, Laura Roslin, ..."},
            {"title"=>"They look like us", "content"=>"The Cylons have the ability..."}
          ]
        },
        { "name"=>"Jean-Luc Picard", "tv_show"=>"Star Trek TNG",
          "posts"=>[
            {"title"=>"Civil rights", "content"=>"There are some words I've known since..."}
          ]
        }
      ]) |> println

  r.db("sample_db") |>
    d -> r.table(d, "authors") |>
    d -> r.get_all(d) |>
    d -> r.filter(d, {"name" => "William Adama"}) |> println

  =#
  #=
  ruby
  [1,
    [39,[ // filter
      [15,["authors"]], // table
      [69,[ // func
        [2,[29]], // Array
        [17,[ // eq
          [170,[ // Bracket
            [10,[29]], // var
          "name"]],
        "William Adama"]]
      ]]
    ]],
  {}]

  js
  [1,
    [39,[ // filter
      [15,["authors"]], // table
      [69,[ // func
        [2,[0]], // Array
        [17,[ // eq
          [170,[ // Bracket
            [13,[]], // IMPLICIT_VAR
          "name"]],
        "William Adama"]]
      ]]
    ]]
  ]

  [39,[15,"authors"],[69,[],[17,[null,"name"],"William Adama"]]]
  =#

  println("")

  r.table("authors") |>
    d -> r.filter(d,
      r.func0(
        r.row("name") |> d -> r.eq(d, "William Adama")
      )
    ) |> to_ast |> JSON.json |> println

  #=
  r.table("marvel").get("IronMan").bracket("firstAppearance")

  [1,
    [170,[ // Bracket
      [16,[ // get
        [15,["marvel"]], // Table
      "IronMan"]],
    "firstAppearance"]]
  ]
  =#
  #r.table("marvel") |>
  #  d -> r.get(d, "IronMan") |>
  #  d -> r.bracket(d, "firstAppearance") |> println

  #=
  r.row("authors")
  [1,
    [170,[ // Bracket
      [13,[]], // IMPLICIT_VAR
    "authors"]]
  ]
  =#

  #r.implicit_var() |>
  #  d -> r.bracket(d, "authors") |> println

  #r.row("authors") |> println

end

function isarray(a::Array)
  true
end

function isarray(a)
  false
end

function isreql(a)
  try
    reql_type(typeof(a))
    true
  catch e
    false
  end
end

#=

[1,
  [39,[ // filter
    [15,["authors"]], // table
    [69,[ // func
      [2,[0]], // Array
      [17,[ // eq
        [170,[ // Bracket
          [13,[]], // IMPLICIT_VAR
        "name"]],
      "William Adama"]]
    ]]
  ]]
]

RethinkDB.ReqlSequence(39, // push()
  Any[
    RethinkDB.ReqlSequence(-1,
      RethinkDB.ReqlTable(15, Any[RethinkDB.ReqlString(-1, "authors")])
    ),

    RethinkDB.ReqlFunction1(-1,
      RethinkDB.ReqlTop(69,
        Any[
          RethinkDB.ReqlArray(2,Any[]),
          RethinkDB.ReqlTop(-1,
            RethinkDB.ReqlBool(17,
              Any[
                RethinkDB.ReqlDatum(170,
                  Any[
                    RethinkDB.ReqlDatum(13,Any[]),
                    RethinkDB.ReqlString(-1, "name")
                  ]),
                RethinkDB.ReqlDatum(-1, "William Adama")
              ]
            )
          )
        ]
      )
    )
  ]
)
=#

function to_ast(ast)
  local ret = []
  push!(ret, 1)
  push!(ret, _to_ast(ast))
  ret
end


function _to_ast(ast)

  if (isarray(ast))
    local tmp = []
    for i in ast
      push!(tmp, _to_ast(i))
    end
    return tmp
  end

  if (!isreql(ast))
    local tmp_not_reql = []
    push!(tmp_not_reql, ast)
    return tmp_not_reql
  end

  if ast.op_code != -1
    return [ast.op_code, _to_ast(ast.value)]
  else
    return _to_ast(ast.value)
  end
end
