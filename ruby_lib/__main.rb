# require: "app"

$q = []
io = InputManager.new($stdin, $q)
Thread.new do
  while true
    $io.check_input_io
  end
end

App.current.run(io)
