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
  r.db("sample_db") |>
    d -> r.table(d, "authors") |>
    d -> r.insert(d, [{"name" => "chris", "items" => [{"first"=>"purse"}]}, {"name" => "maryann", "items" => [{"first"=>"shoes"}]} ]) |>
    d -> run(c, d) |> println

  r.disconnect(c)
end
