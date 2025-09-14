import os
import sys

# Default testname
testname = "test1"
if len(sys.argv) > 1:
    testname = sys.argv[1]

# File list (compile order is important)
files = [
    "../sv/yapp_if.sv",
    "../../Encrypted/yapp_router.svh", 
    "top_dut.sv"
]

# Compile with vlog
cmd_vlog = "vlog " + " ".join(files)
print("Running:", cmd_vlog)
os.system(cmd_vlog)

# Run simulation with vsim
cmd_vsim = (
    f"vsim -c work.top_dut "
    f"+UVM_TESTNAME={testname} "
    f"+UVM_VERBOSITY=UVM_HIGH "
    f"-do \"run -all; quit\""
)
print("Running:", cmd_vsim)
os.system(cmd_vsim)

