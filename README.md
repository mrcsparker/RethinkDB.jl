# RethinkDB.jl

A _work in progress_ library for using [RethinkDB](https://rethinkdb.com) with [Julia](http://julialang.org)

## Installing

Right now, there is no package, so you need to include the source in your project

## RethinkDB API Coverage

This project is still in the early stages. ~50% of the RethinkDB API is covered,
but there is a lot that needs to be finished.

## Using the library

```julia
import RethinkDB
const r = RethinkDB

c = r.connect()

# My preferred way

r.db_create("test_db") |>
  d -> r.exec(c, d) |> println

r.db("test_db") |>
  d -> r.table_create(d, "test_table") |>
  d -> r.exec(c, d) |> println

r.db("test_table") |>
  d -> r.table_drop("foo") |>
  d -> r.exec(c, d) |> println

r.db("test_db") |>
  d -> r.table(d, "test_table") |>
  d -> r.filter(d, { "status" => "open"}) |>
  d -> r.distinct(d) |>
  d -> r.count(d) |>
  d -> exec(c, d) |> println

# Add a little js
r.db("test_db") |>
  d -> r.table(d, "test_table") |>
  d -> r.filter(d, r.js("(function(s) { return s.status === 'open'; })")) |>
  d -> r.exec(c, d) |> println

r.now() |>
  d -> r.date(d) |>
  d -> r.exec(c, d) |> println

# Or, if you prefer

db = r.db_create("test_db")
r.exec(c, db)

db = r.db("test_db")
r.table_create(db, "test_table")

```

## License

Apache 2.0
