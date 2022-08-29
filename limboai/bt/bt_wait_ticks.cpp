/* bt_wait_ticks.cpp */

#include "bt_wait_ticks.h"
#include "core/class_db.h"
#include "core/object.h"
#include "core/variant.h"

String BTWaitTicks::_generate_name() const {
	return vformat("WaitTicks x%d", num_ticks);
}

void BTWaitTicks::_enter() {
	_num_passed = 0;
}

int BTWaitTicks::_tick(float p_delta) {
	_num_passed += 1;
	if (_num_passed < num_ticks) {
		return RUNNING;
	} else {
		return SUCCESS;
	}
}

void BTWaitTicks::_bind_methods() {
	ClassDB::bind_method(D_METHOD("set_num_ticks", "p_value"), &BTWaitTicks::set_num_ticks);
	ClassDB::bind_method(D_METHOD("get_num_ticks"), &BTWaitTicks::get_num_ticks);

	ADD_PROPERTY(PropertyInfo(Variant::INT, "num_ticks"), "set_num_ticks", "get_num_ticks");
}
