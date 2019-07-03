document = "ith 😅icame d de 😅fhi🤖n my miAnthat d ou tn tThe   aCome d woe hnt  😅fiththrough  One 😅"
result   = "ith 😅came took the Jabberwock e🤖n my m 💃iAnthat Long nthe The aCome Callay d wthe 💃osnack And e hn😅hrouback One👻uffish 😅"

ops = OT.Text.new([
  5, %{"d" => 1}, 5, %{"d" => 3}, "took the Jabberwock ", 1, %{"d" => 5}, 7, " 💃",
  8, %{"d" => 6}, "Long ", 1, "the ", %{"d" => 2}, 4, %{"d" => 2}, 6, "Callay ",
  3, "the 💃", 1, "snack And ", 4, "😅", %{"d" => 9}, 4, "back ", %{"d" => 4}, 3, %{"d" => 1}, "👻uffish "
])

{:ok, ^result} = OT.Text.apply(ops, document)
^result = OT.Text.apply_old(ops, document)

Benchee.run(
  %{
    "new" => fn -> {:ok, ^result} = OT.Text.apply(ops, document) end,
    "old" => fn -> ^result = OT.Text.apply_old(ops, document) end
  },
  time: 10,
  memory_time: 2
)
