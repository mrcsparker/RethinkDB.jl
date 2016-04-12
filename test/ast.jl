module TestAst
  using Base.Test
  import JSON
  using RethinkDB

  r = RethinkDB

  t1 = r.db("bookstore") |>
    r.to_ast |> JSON.json
  @test t1 == "[1,[14,[\"bookstore\"]]]"

  t1 = r.table("authors") |>
    r.to_ast |> JSON.json
  @test t1 == "[1,[15,[\"authors\"]]]"

  t1 = r.db("bookstore") |>
    d -> r.table(d, "authors") |>
    r.to_ast |> JSON.json
  @test t1 == "[1,[15,[[14,[\"bookstore\"]],\"authors\"]]]"
end
