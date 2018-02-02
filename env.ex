defmodule Env do

  def new() do
    []
  end

  def add(id, str, env) do
    [{id, str} | env]
  end

  def lookup(id, env) do
    List.keyfind(env, id, 0)
  end

  def remove(ids, env) do
    List.foldr(ids, env, fn id, env ->
      List.keydelete(env, id, 0)
    end)
  end


end
