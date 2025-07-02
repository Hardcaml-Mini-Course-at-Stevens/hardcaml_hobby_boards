let run_vivado_remotely_dot_template_dot_sh =
  "PROJECT_FILES=\"$PROJECT_NAME.v $PROJECT_NAME.tcl $PROJECT_NAME.xdc\"\n\
   VIVADO_COMMAND=\"vivado -mode batch -source $PROJECT_NAME.tcl\"\n\
   COPY_FILES_ON_COMPLETION=\"$PROJECT_NAME.bit $PROJECT_NAME.timing.rpt vivado.log\"\n\n\
   if [ $# -ne 1 ]; then\n\
  \  echo \"Usage: $0 <user@server_ip>\"\n\
  \  exit 1\n\
   fi\n\n\
   server_arg=\"$1\"\n\
   socket_file=\"/tmp/ssh_socket_$$\"\n\n\
   # Cleanup function\n\
   cleanup() {\n\
  \  ssh -S \"$socket_file\" -O exit \"$server_arg\" 2> /dev/null\n\
   }\n\n\
   echo \"Connecting to server, you may be prompted to authenticate...\"\n\n\
   # Create master SSH connection in background after auth\n\
   ssh -fNM -S \"$socket_file\" \"$server_arg\"\n\n\
   # Set cleanup to run on exit\n\
   trap cleanup EXIT\n\n\
   echo \"Checking for vivado on server...\"\n\n\
   # Check if vivado is available on server\n\
   if ! vivado_path=$(ssh -S \"$socket_file\" \"$server_arg\" \"which vivado\"); then\n\
  \  echo \"Error: vivado not found on server\"\n\
  \  exit 1\n\
   fi\n\n\
   echo \"Vivado path: $vivado_path\"\n\n\
   # Create temp directory on server\n\
   temp_dir=$(ssh -S \"$socket_file\" \"$server_arg\" \"mktemp -d\")\n\
   echo \"Server temp directory: $temp_dir\"\n\n\
   echo \"Copying project files to server...\"\n\n\
   # Copy project files\n\
   scp -o \"ControlPath=$socket_file\" $PROJECT_FILES \"$server_arg:$temp_dir/\"\n\n\
   echo \"Running vivado build...\"\n\n\
   # Run vivado command\n\
   if ! ssh -S \"$socket_file\" \"$server_arg\" \"cd $temp_dir && $VIVADO_COMMAND\"; then\n\
  \  echo \"Vivado build failed, but continuing to copy files...\"\n\
   fi\n\n\
   echo \"Copying build output files...\"\n\n\
   # Copy files that exist\n\
   for file in $COPY_FILES_ON_COMPLETION; do\n\
  \  if ssh -S \"$socket_file\" \"$server_arg\" \"test -f $temp_dir/$file\"; then\n\
  \    echo \"Copying $file\"\n\
  \    scp -o \"ControlPath=$socket_file\" \"$server_arg:$temp_dir/$file\" .\n\
  \  fi\n\
   done\n\n\
   echo \"Build completed, files copied back, SSH connection closed\"\n"
;;

let flash_dot_template_dot_tcl =
  "open_hw\n\
   connect_hw_server\n\
   open_hw_target\n\
   current_hw_device [lindex [get_hw_devices] 0]\n\
   set_property PROGRAM.FILE ${PROJECT_NAME}.bit [current_hw_device]\n\
   program_hw_devices [current_hw_device]\n\
   exit\n"
;;

let compile_dot_template_dot_tcl =
  "read_verilog ${PROJECT_NAME}.v\n\
   read_xdc ${PROJECT_NAME}.xdc\n\
   synth_design -top ${PROJECT_NAME}_top -part $FPGA_PART\n\
   opt_design\n\
   if {$DEBUG} { write_checkpoint -force ${PROJECT_NAME}.synth.dcp }\n\
   place_design\n\
   if {$DEBUG} { write_checkpoint -force ${PROJECT_NAME}.place.dcp }\n\
   route_design\n\
   if {$DEBUG} { write_checkpoint -force ${PROJECT_NAME}.route.dcp }\n\
   if {$DEBUG} { report_utilization -hierarchical -file ${PROJECT_NAME}.utilization.rpt }\n\
   report_timing_summary -file ${PROJECT_NAME}.timing.rpt\n\
   write_bitstream -force ${PROJECT_NAME}.bit\n\
   set WNS [get_property SLACK [get_timing_paths -max_paths 1 -nworst 1 -setup]]\n\
   puts \"WNS=$WNS\"\n"
;;
