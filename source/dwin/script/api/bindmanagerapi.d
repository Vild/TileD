module dwin.script.api.bindmanagerapi;

import dwin.log;
import dwin.script.utils;
import dwin.backend.bindmanager;

struct BindManagerAPI {
	void Init(BindManager bindManager) {
		this.bindManager = bindManager;
	}

	var Map(var, var[] args) {
		bindManager.Map(cast(string)args[0], delegate(bool v) { args[1](v); });

		return var.emptyObject;
	}

	var Unmap(var, var[] args) {
		bindManager.Unmap(cast(string)args[0]);

		return var.emptyObject;
	}

	var IsBinded(var, var[] args) {
		return var(bindManager.IsBinded(cast(string)args[0]));
	}

	BindManager bindManager;
	mixin ObjectWrapper;
}
