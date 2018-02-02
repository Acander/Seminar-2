defmodule Eager do

  #Evaluates expressions, returns a datastructure (value)
  def eval_expr({:atm, id}, _) do {:ok, id} end
  def eval_expr({:var, id}, env) do
    case Env.lookup(id, env) do #search through the environment
      nil ->
        :error
      {_, str} ->
        {:ok, str}
    end
  end
  def eval_expr({:cons, he, te}, env) do
    case eval_expr(he, env) do
      :error ->
        :error

      {:ok, hs} ->
        case eval_expr(te, env) do
          :error ->
            :error
          {:ok, ts} ->
            {:ok, [hs | ts]}
        end
      end
    end

    #Matches (x = :a;) a variable with
    #an expression (atom, variable)
    def eval_match(:ignore, _, env) do
      {:ok, env}
    end
    def eval_match({:atm, id}, id, env) do
      {:ok, env}
    end
    def eval_match({:var, id}, str, env) do
      case Env.lookup(id, env) do
        nil ->
          {:ok, Env.add(id, str, env)}
        {_, ^str} ->
          {:ok, env}
        {_, _} ->
          :fail
      end
    end
    def eval_match({:cons, hp, tp}, {:cons, {_, hs}, {_, ts}}, env) do
      case eval_match(hp, hs, env) do
        :fail ->
          :fail
        {:ok, env} ->
          eval_match(tp, ts, env)
      end
    end
    def eval_match(_, _, _) do
      :fail
    end

    #Evalueates a sequence (matchings and expressions, and
    #always ends with an expression).
    def eval(seq) do eval_seq(seq, []) end

    def eval_seq([exp], env) do
      eval_expr(exp, env)
    end
    def eval_seq([{:match, v, s} | restSeq], env) do
      case eval_expr(s, env) do
        :error ->
          :error
        {:ok, str} ->
          vars = extract_vars(v)
          env = Env.remove(vars, env)
          case eval_match(v, str, env) do
            :fail ->
              :error
            {:ok, extEnv} ->
              eval_seq(restSeq, extEnv)
          end
      end
    end

    def extract_vars(p) do extract_vars(p, []) end
    def extract_vars({:atm, _}, allVar) do allVar end
    def extract_vars(:ignore, allVar) do allVar end
    def extract_vars({:var, v}, allVar) do [v | allVar] end
    def extract_vars({:cons, f, s}, allVar) do extract_vars(f, extract_vars(s, allVar)) end

end
