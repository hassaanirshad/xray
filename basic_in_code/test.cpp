#include "xray/xray_interface.h"
#include "xray/xray_log_interface.h"
#include <cassert>
#include <cstdio>

using namespace std;

void func_with_no_args();
void func_with_one_int_arg(int a);
void func_with_one_charp_arg(const char *str);
void func_with_two_mixed_args(int a, const char *str);
void func_should_not_be_present();

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

	func_with_no_args();
	func_with_one_int_arg(10);
	func_with_one_charp_arg(str);
	func_with_two_mixed_args(11, str);
	func_should_not_be_present();

	return 0;
}
