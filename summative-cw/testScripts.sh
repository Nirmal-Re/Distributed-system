procs = [:p1, :p2, :p3, :p4, :p5]
pids = Enum.map(procs, fn(p) -> EventualLeaderDetector.start(p, procs, 1) end)