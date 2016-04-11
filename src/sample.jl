function do_test()
  r = RethinkDB

  c = r.connect()

  #db_create("tester") |> d -> exec(c, d) |> println
  #db_drop("tester") |> d -> exec(c, d) |> println
  #db_list() |> d -> exec(c, d) |> println

  #db_create("test_db") |> d -> exec(c, d) |> println
  #db("test_db") |> d -> table_create(d, "test_table") |> d -> exec(c, d) |> println
  #db("test_table") |> d -> table_drop("foo") |> d -> exec(c, d) |> println

  #db("test_db") |>
  #  d -> table(d, "test_table") |>
  #  d -> insert(d, { "status" => "open", "item" => [{"name" => "foo", "amount" => "22"}] }) |>
  #  d -> exec(c, d) |> println

  r.db("test_db") |>
    d -> r.table(d, "test_table") |>
    d -> r.filter(d, { "status" => "open"}) |>
    d -> r.skip(d, 3) |>
    d -> r.has_fields(d, "xxx") |>
    d -> r.exec(c, d) |> println

  #now() |>
  #  d -> date(d) |>
  #  d -> exec(c, d) |> println

  #db("test_db") |>
  #  d -> table(d, "test_table") |>
  #  sync |> println

  r.db("test_db") |>
    d -> r.table(d, "test_table") |>
    d -> r.filter(d, r.js("(function(s) { return s.status === 'open'; })")) |>
    d -> r.exec(c, d) |> println

  r.db("test_db") |>
    d -> r.config(d) |> println

  r.disconnect(c)
end

function do_tour()
  r = RethinkDB

  c = r.connect()

  # Create a new DB
  r.db_create("sample_db") |>
    d -> run(c, d) |> println

  # Create a new table
  r.db("sample_db") |>
    d -> r.table_create(d, "authors") |>
    d -> run(c, d) |> println

  # Insert data
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
    ]) |>
    d -> run(c, d)

    local pk = ""

    for k in cursor["generated_keys"]
      println("key: ", k)
      pk = k
    end

    # All documents in a table
    local cursor = r.db("sample_db") |> d -> r.table(d, "authors") |> d -> run(c, d)
    for k in cursor
      n = length(k["posts"])
      println("Name: ", k["name"], " \t\t  TV Show: ", k["tv_show"], "\t\t Posts: ", n)
    end

    # Filter documents based on a condition
    cursor = r.db("sample_db") |> d -> r.table(d, "authors") |> d -> run(c, d)

    # Filter documents based on a condition
    cursor = r.db("sample_db") |>
      d -> r.table(d, "authors") |>
      d -> r.filter(d, {"name" => "William Adama"}) |>
      d -> run(c, d)
    #println(cursor)

    # [1,
    #   [39, [
    #     [15, [
    #       [14,["sample_db"]],
    #     "authors"]],
    #     [69, [                       # func
    #       [2,[7]],                   # MAKE_ARRAY[7]
    #       [17,[                      # eq
    #         [170,[[10,[7]],"name"]], # BRACKET [VAR] "name"
    #       "William Adama"]]]]]]

    #cursor = r.db("sample_db") |>
    #  d -> r.table(d, "authors") |>
    #  d -> r.filter(d, r.eq(r.row("name"), "William Adama")) |>
    #  d -> run(c, d)
    #println(cursor)


    # Retrieve documents by primary key
    cursor = r.db("sample_db") |>
      d -> r.table(d, "authors") |>
      d -> r.get(d, pk) |>
      d -> run(c, d)
    println(cursor)

  r.disconnect(c)
end
