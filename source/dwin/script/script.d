module dwin.script.script;

import std.stdio;
import std.file;
import std.string;
import std.algorithm.iteration;
import dwin.dwin;
import arsd.script;
public import dwin.script.utils;

import dwin.script.api;
import dwin.log;

class Script {
public:
	this(DWin dwin) {
		engineAPI.Init(dwin.Engine);
		logAPI.Init();
		bindManagerAPI.Init(dwin.Engine.BindManager);

		env = var.emptyObject;
		env.BindManager = bindManagerAPI.Get();
		env.Engine = engineAPI.Get();
		env.Info = infoAPI.Get();
		env.Log = logAPI.Get();
		env.System = systemAPI.Get();

		foreach (file; dirEntries("scripts/", SpanMode.breadth).filter!(f => f.name.endsWith(".ds"))) {
			Log.MainLogger.Info("Loading script: %s", file);
			runFile(File(file, "r"));
		}
	}

	~this() {
	}

	void RunCtors() {
		foreach (idx, ctor; infoAPI.Ctors)
			ctor();
	}

	void RunDtors() {
		foreach (idx, dtor; infoAPI.Dtors)
			dtor();
	}

	void opDispatch(string func, string callerFile = __FILE__, int callerLine = __LINE__, Args...)(Args args) {
		import std.traits : isSomeString, isBasicType;
		import std.conv : to;

		string line = func ~ "(";
		foreach (idx, arg; args) {
			static if (idx)
				line ~= ", ";
			static if (isSomeString!(typeof(arg)))
				line ~= "\"" ~ arg ~ "\"";
			else static if (isBasicType!(typeof(arg)))
				line ~= to!string(arg);
			else {
				//XXX: Hack to show why the function could not be called!
				pragma(msg, callerFile, "(", callerLine,
						",1): Error: Script Function: " ~ func ~ ", Unsupported argument type: " ~ typeof(arg).stringof);
				static assert(0, "Unsupported argument type: " ~ typeof(arg).stringof);
			}
		}
		line ~= ");";
		run(line);
	}

private:
	var env;

	BindManagerAPI bindManagerAPI;
	EngineAPI engineAPI;
	InfoAPI infoAPI;
	LogAPI logAPI;
	SystemAPI systemAPI;

	void run(string str) {
		try {
			interpret(str, env);
		}
		catch (Exception e) { // "No such property" throws a object.Exception
			Log.MainLogger.Error("%s", e.msg);
		}
	}

	void runFile(File file) {
		try {
			interpretFile(file, env);
		}
		catch (Exception e) { // "No such property" throws a object.Exception
			Log.MainLogger.Error("%s", e.msg);
		}
	}
}
