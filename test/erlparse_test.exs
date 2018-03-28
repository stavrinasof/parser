defmodule ErlparseTest do
  use ExUnit.Case
  doctest Erlparse

  test "greets the world" do
    assert Erlparse.hello() == :world
  end
end
