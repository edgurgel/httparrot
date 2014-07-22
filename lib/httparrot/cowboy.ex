defmodule HTTParrot.Cowboy do
  defmacro __using__(opts) do
    methods = Keyword.get(opts, :methods, [])

    quote bind_quoted: [methods: methods] do
      def init(_transport, _req, _opts) do
        {:upgrade, :protocol, :cowboy_rest}
      end

      def allowed_methods(req, state) do
        {unquote(methods), req, state}
      end
    end
  end
end
