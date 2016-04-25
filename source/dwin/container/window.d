module dwin.container.window;

import dwin.container.container;
import dwin.data.geometry;
import dwin.data.borderstyle;
import dwin.data.changed;

abstract class Window : Container {
public:
	this(string name, Geometry geom, Container parent, BorderStyle borderStyle, double splitRatio) {
		super(name, geom, parent, borderStyle, splitRatio);
	}

	override void Update() {
		super.Update();
		visible.clear;
	}

	abstract void Focus();
	
	void Show() {
		visible = true;
	}

	void Hide() {
		visible = false;
	}

	@property bool Visible() {
		return visible;
	}

	@property override bool Dirty() {
		return super.Dirty || visible.changed;
	}
	
protected:
	//string class_;
	//string instance;
	Changed!bool visible;
	bool urgent;
}
