procs = [:p1, :p2, :p3, :p4, :p5]
pids = Enum.map(procs, fn(p) -> EagerReliableBroadcast.start(p, procs, 1) end)
send(Enum.at(pids, 1), {:broadcast, "hello world"})

send(Enum.at(pids,3), {:data, :p2, 3, "hello mf"}) 