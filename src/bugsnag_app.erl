-module(bugsnag_app).
-behavior(application).

% Application hooks
-export([start/2, stop/1]).

start(_Type, _Args) ->
  lager:debug("Starting bugsnag notifier"),
  ReleaseState = case application:get_env(bugsnag, release_state) of
    {ok, Value} -> Value;
    undefined -> undefined
  end,
  case application:get_env(bugsnag, api_key) of
    {ok, "ENTER_API_KEY"} -> {error, no_api_key};
    {ok, ApiKey} ->
      case application:get_env(bugsnag, error_logger) of
        {ok, true} ->
          error_logger:add_report_handler(bugsnag_error_logger);
        _ -> ok
      end,
      bugsnag_sup:start_link(ApiKey, ReleaseState);
    undefined -> {error, no_api_key}
  end.

stop(_State) ->
  lager:debug("Stopping bugsnag notifier"),
  ok.
