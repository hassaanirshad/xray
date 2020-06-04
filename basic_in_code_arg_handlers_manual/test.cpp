#include "xray/xray_interface.h"
#include "xray/xray_log_interface.h"
#include <cassert>
#include <cstdio>
#include <stddef.h>
#include <fstream>
#include <iostream>

using namespace std;

void func_with_no_args();
void func_with_one_int_arg(int a);
void func_with_one_charp_arg(const char *str);
void func_with_two_mixed_args(int a, const char *str);
void func_should_not_be_present();

[[clang::xray_never_instrument]]
void handle_all(int32_t function_id, XRayEntryType entry_type){
	uintptr_t address;
	address = __xray_function_address(function_id);
	printf("*** handle_all([int32_t function_id]=[%d] (addr=%lx), [XRayEntryType entry_type]=[%d])\n", function_id, address, entry_type);
}

[[clang::xray_never_instrument]]
void handle_arg_charp(int32_t function_id, XRayEntryType entry_type, uint64_t arg){
	printf("*** handle_arg([int32_t function_id]=[%d], [XRayEntryType entry_type]=[%d], [uint64_t arg]=(char *)[%s])\n", function_id, entry_type, (const char *)arg);
}

[[clang::xray_never_instrument]]
void handle_arg_int(int32_t function_id, XRayEntryType entry_type, uint64_t arg){
	printf("*** handle_arg([int32_t function_id]=[%d], [XRayEntryType entry_type]=[%d], [uint64_t arg]=[%lu])\n", function_id, entry_type, arg);
}

[[clang::xray_always_instrument]]
void func_with_no_args(){
	printf("func_with_no_args\n");
}

[[clang::xray_always_instrument, clang::xray_log_args(1)]]
void func_with_one_int_arg(int a){
	printf("func_with_one_int_arg([int a]=[%d])\n", a);
}

[[clang::xray_always_instrument, clang::xray_log_args(1)]]
void func_with_one_charp_arg(const char *str){
	printf("func_with_one_charp_arg([char *str]=[%s] (%p) (%lu))\n", str, str, (uint64_t)&str);
}

[[clang::xray_always_instrument, clang::xray_log_args(2)]]
void func_with_two_mixed_args(int a, const char *str){
	printf("func_with_two_mixed_args([int a]=[%d], [char *str]=[%s] (%p))\n", a, str, str);
}

[[clang::xray_never_instrument]]
void func_should_not_be_present(){
	printf("func_should_not_be_present\n");
	}

int main(int argc, char *argv[]){
	const char *str;
	str = "helloworld";

	// Body start

	__xray_set_handler(handle_all);

	__xray_set_handler_arg1(handle_arg_int);

	func_with_no_args();
	func_with_one_int_arg(10);

	__xray_set_handler_arg1(handle_arg_charp);

	func_with_one_charp_arg(str);

	__xray_set_handler_arg1(handle_arg_int);

	func_with_two_mixed_args(11, str);
	func_should_not_be_present();

	__xray_remove_handler_arg1();

	__xray_remove_handler();

	// Body end

	return 0;
}
