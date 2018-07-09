defimpl Inspect, for: Csvm.FarmProc do
  def inspect(data, opts) do
    "#FarmProc<[#{Csvm.FarmProc.get_status(data)}] #{
      inspect(Csvm.FarmProc.get_pc_ptr(data))
    }>"
  end
end
