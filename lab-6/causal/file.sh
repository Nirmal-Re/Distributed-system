procs = [:p1, :p2, :p3]
pids = Enum.map(procs, fn(p) -> CausalBroadcast.start(p, procs) end)
send(Enum.at(pids, 0), {:start_test, 2})
# send(Enum.at(pids, 1), {:broadcast, "hello world"})
