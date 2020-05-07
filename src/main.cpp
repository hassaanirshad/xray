#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

#include "xray/xray_interface.h"
#include "xray/xray_log_interface.h"

/*[[clang::xray_never_instrument]] void coverage_handler(int32_t fid,
                                                       XRayEntryType) {
  thread_local bool patching = false;
  if (patching) return;
  patching = true;
  function_ids.insert(fid);
  __xray_unpatch_function(fid);
  patching = false;
}*/

void t(int a, char *s);
void v(int a, char *s);

[[ clang::xray_always_instrument, clang::xray_log_args(1) ]]
void __attribute__((noinline)) t(int a, char *s){
	printf("[t\t\t]hello, %d, %s\n", a, s);
}
[[ clang::xray_always_instrument, clang::xray_log_args(1) ]]
void __attribute__((noinline)) v(int a, char *s){
	printf("[v\t\t]hello, %d, %s\n", a, s);
}
[[ clang::xray_always_instrument, clang::xray_log_args(1) ]]
int main(int argc, char *argv[]){
	__xray_log_select_mode("xray-fdr");
	__xray_log_init_mode("xray-fdr", "func_duration_threshold_us=0 grace_period_ms=1 no_file_flush=false");
	__xray_patch();


	printf("[main\t\t]hello, %d, %s\n", atoi(argv[1]), argv[2]);
	printf("[main\t\t]mode=%s\n", __xray_log_get_current_mode());
	t(atoi(argv[1]), argv[2]);
	t(atoi(argv[1]), argv[2]);
	t(atoi(argv[1]), argv[2]);
	v(atoi(argv[1]), argv[2]);

	__xray_log_finalize();
	__xray_unpatch();
	__xray_log_flushLog();

	return -1;
}
