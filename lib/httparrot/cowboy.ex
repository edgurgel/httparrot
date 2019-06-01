defmodule HTTParrot.Cowboy do
  defmacro __using__(opts) do
    methods = Keyword.get(opts, :methods, [])

    quote bind_quoted: [methods: methods] do
      def init(req, state) do
        {:cowboy_rest, req, state}
      end

      def allowed_methods(req, state) do
        {unquote(methods), req, state}
      end
    end
  end
end
