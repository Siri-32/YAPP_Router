import os
import sys
import random

# Default testname
testname = "simple_test"
if len(sys.argv) > 1:
    testname = sys.argv[1]

# File list (compile order is important)
files = [
    "../../yapp/sv/yapp_if.sv",
    "../../channel/sv/channel_if.sv",
    "../../hbus/sv/hbus_if.sv",
    "../../Encrypted/yapp_router.svh",
    "top_dut.sv"
]

# Compile with vlog (with coverage flags)
cmd_vlog = "vlog -sv -cover bcest " + " ".join(files)
print("Running:", cmd_vlog)
os.system(cmd_vlog)

# -----------------------------------------
# Regression mode setup
# -----------------------------------------
tests = [
    "base_test",
    "simple_test",
    "test_uvc_integration",
    "virtual_seq_test",
    "test_router_yapp_cfg",
    "test_router_yapp_full_flow",
    "test_router_yapp_dist",
    "test_hif_api"
]

if testname == "regress":
    print("[Starting Full Regression...]")
    os.system("rm -rf logs ucdb coverage_html; mkdir -p logs ucdb")

    for t in tests:
        seed = random.randint(1, 2**31 - 1)
        log_file = f"logs/{t}.log"
        ucdb_file = f"ucdb/{t}.ucdb"

        cmd_vsim = (
            f"vsim -c work.top_dut -coverage "
            f"+UVM_TESTNAME={t} +UVM_VERBOSITY=UVM_MEDIUM -sv_seed {seed} "
            f"-do \"coverage save -onexit {ucdb_file}; run -all; quit\" "
        )

        print(f"\n[Running {t} with SEED={seed}]")
        os.system(f"{cmd_vsim} | tee {log_file}")

    # Merge coverage
    print("\n[Merging coverage files...]")
    os.system("vcover merge merged.ucdb ucdb/*.ucdb")

    # Generate HTML report
    print("\n[Generating HTML coverage report...]")
    os.system("vcover report -html -details -verbose -output coverage_html merged.ucdb")

    print("\n[Regression Completed. Open coverage_html/index.html to view report]")
else:
    # Single run logic
    seed = random.randint(1, 2**31 - 1)
    cmd_vsim = (
        f"vsim -c work.top_dut -coverage "
        f"+UVM_TESTNAME={testname} +UVM_VERBOSITY=UVM_HIGH -sv_seed {seed} "
        f"-do \"coverage save -onexit vsim.ucdb; run -all; quit\" "
    )

    print("Running:", cmd_vsim)
    os.system(cmd_vsim)

    # Generate report
    os.system("vcover report -html -details -verbose -output coverage_html vsim.ucdb")
    print("\n[Single run completed. Open coverage_html/index.html to view report]")
