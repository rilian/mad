-module(mad).
-copyright('Maxim Sokhatsky').
-compile(export_all).
-export([main/1]).

main([]) -> help();
main(Params) ->
%    io:format("Bundle: ~p~n\r",[escript:script_name()]),

    {Other,FP} = mad_utils:fold_params(Params),
%    io:format("Params: ~p~n\r",[FP]),
    case Other == [] of
         true -> skip;
         false -> io:format("Unknown Command or Parameter ~p~n\r",[Other]), help() end,

    Cwd = mad_utils:cwd(),
    ConfigFile = "rebar.config",
    ConfigFileAbs = filename:join(Cwd, ConfigFile),
    Conf = mad_utils:consult(ConfigFileAbs),
    Conf1 = mad_script:script(ConfigFileAbs, Conf, ""),

    Fun = fun({Name,Par}) -> ?MODULE:Name(Cwd, ConfigFile, Conf1, Par) end,
    lists:foreach(Fun, FP).

%% fetch dependencies
deps(Cwd, ConfigFile, Conf, Params) ->
    io:format("Deps Params: ~p~n",[Params]),
    case mad_utils:get_value(deps, Conf, []) of
        [] -> ok;
        Deps ->
            Cache = mad_utils:get_value(deps_dir, Conf, deps_fetch),
            case Cache of
                deps_fetch -> skip;
                Dir -> file:make_dir(Dir) end,
            FetchDir = mad_utils:get_value(deps_dir, Conf, ["deps"]),
            file:make_dir(FetchDir),
            mad_deps:fetch(Cwd, Conf, ConfigFile, Deps)
    end.

%% compile dependencies and the app
compile(Cwd, ConfigFile, Conf, Params) ->
    io:format("Compile Params: ~p~n\r",[Params]),
    mad_compile:'compile-deps'(Cwd, ConfigFile, Conf),
    mad_compile:'compile-apps'(Cwd, ConfigFile, Conf).

%% reltool apps resolving
plan(_Cwd,_ConfigFileName,_Config,Params) ->
    io:format("Plan Params: ~p~n",[Params]),
    mad_plan:main([]).

repl(_Cwd,_ConfigFileName,_Config,Params) ->
    io:format("Repl Params: ~p~n",[Params]),
    mad_repl:main(Params).

bundle(_Cwd,_ConfigFileName,_Config,Params) ->
    io:format("Tool Params: ~p~n",[Params]),
    Name = case Params of [] -> mad_utils:cwd(); E -> E end,
    mad_bundle:main(filename:basename(Name)).

up(_Cwd,_ConfigFileName,_Config,Params) ->
    io:format("Up Params: ~p~n",[Params]),
    mad_deps:up(Params).

app(_Cwd,_ConfigFileName,_Config,Params) ->
    io:format("Create App Params: ~p~n",[Params]),
    mad_create:app(Params).

lib(_Cwd,_ConfigFileName,_Config,Params) ->
    io:format("Create Lib Params: ~p~n",[Params]),
    mad_create:lib(Params).

start(_Cwd,_ConfigFileName,_Config,Params) ->
    io:format("Start Params: ~p~n",[Params]),
    mad_run:start(Params).

attach(_Cwd,_ConfigFileName,_Config,Params) ->
%    io:format("Attach Params: ~p~n",[Params]),
    mad_run:attach(Params).

clean(_Cwd,_ConfigFileName,_Config,Params) ->
    io:format("Clean Params: ~p~n",[Params]),
    mad_run:clean(Params).

stop(_Cwd,_ConfigFileName,_Config,Params) ->
    io:format("Stop Params: ~p~n",[Params]),
    mad_run:stop(Params).

release(_Cwd,_ConfigFileName,_Config,Params) ->
    io:format("Release Params: ~p~n",[Params]),
    mad_release:main(Params).

static(_Cwd,_ConfigFileName,Config,Params) ->
    io:format("Compile Static Params: ~p~n",[Params]),
    mad_static:main(Config, Params).

help(Reason, Data) -> help(io_lib:format("~s ~p", [Reason, Data])).
help(Msg) -> io:format("Error: ~s~n~n", [Msg]), help().
help() ->
    io:format("VXZ MAD Build Tool version 1.0~n"),
    io:format("BNF: ~n"),
    io:format("    invoke := mad params~n"),
    io:format("    params := [] | run params ~n"),
    io:format("       run := command [ help | options ]~n"),
    io:format("       cmd := app | lib | deps | compile | release | bundle~n"),
    io:format("              clean | start | stop | attach | repl ~n"),
    halt().
