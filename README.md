# RethinkDB.jl

A work in progress library for using RethinkDB with Julia

## Sample API call

```julia

c = RethinkDB.connect()

# My preferred way

db_create("test_db") |> d -> exec(c, d) |> println

db("test_db") |> d -> table_create(d, "test_table") |> d -> exec(c, d) |> println

db("test_table") |> d -> table_drop("foo") |> d -> exec(c, d) |> println

# Or, if you prefer

db = db_create("test_db")
exec(c, d)

db = db("test_db")
table_create(db, "test_table")

```
