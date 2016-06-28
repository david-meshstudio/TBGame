-module(c2s_server).
-export([start/0]).

start() ->
	inets:stop(),
	application:ensure_started(inets),
	inets:start(httpd, [
			{modules, [mod_esi]},
			{port, 8367},
			{server_name, "test"},
			{document_root, "www"},
			{server_root, "www"},
			{erl_script_alias, {"/api", [c2s_controller]}}
		]),
	dets:open_file(memberMap,[{access,read_write}]),
	dets:open_file(mapGrid,[{access,read_write},{type,bag}]).
