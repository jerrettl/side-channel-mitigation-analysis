#!/bin/bash

OUTPUT_FILE="results.csv"


if [ -z "$BLENDER_BENCHMARK_LOCATION" ]; then
	echo "You should specify the location of your Blender Open Data Benchmark script."
	echo "Example: BLENDER_BENCHMARK_LOCATION=\"/path/to/the/script/benchmark-launcher-cli\" $0"
	echo
	echo "Note: Before running, you should set up the \`benchmark-launcher-cli\` script with the following:"
	echo "        ./benchmark-launcher-cli blender download 4.0.0"
	echo "        ./benchmark-launcher-cli scenes download monster --blender-version 4.0.0"
	echo "(You may need to move to the folder that contains the script first.)"
	exit 1
fi

if ! [ -f "$OUTPUT_FILE" ]; then
	echo "Creating the result file..."
	echo "test,sysbench,passmark_cpu_single_thread,passmark_cpu_floating_point,passmark_memory_read,passmark_memory_write,blender,zip_compress,zip_decompress,boot_firmware,boot_loader,boot_kernel,boot_userspace,boot_total" > "$OUTPUT_FILE"
fi


test_number="$(cat "$OUTPUT_FILE" | wc -l)"
echo -n "$test_number" >> "$OUTPUT_FILE"
echo "Running test #$test_number..."
exec 3>&1


# Sysbench
echo "==> Sysbench"
sysbench="$(sysbench cpu run | tee /dev/fd/3)"

sysbench_result="$(echo "$sysbench" | grep 'events per second' | cut -d' ' -f9)"
echo "RESULT: $sysbench_result"
echo -n ",$sysbench_result" >> "$OUTPUT_FILE"


echo
echo "==> Passmark (CPU)"
passmark_cpu="$(passmark-performancetest -r 1)"

passmark_single_thread="$(cat results_cpu.yml | grep 'CPU_SINGLETHREAD' | cut -d' ' -f4)"
echo "Single thread: $passmark_single_thread"
echo -n ",$passmark_single_thread" >> "$OUTPUT_FILE"
passmark_floating_point="$(cat results_cpu.yml | grep 'CPU_FLOATINGPOINT_MATH' | cut -d' ' -f4)"
echo "Floating point: $passmark_floating_point"
echo -n ",$passmark_floating_point" >> "$OUTPUT_FILE"

echo
echo "==> Passmark (Memory)"
passmark_memory="$(passmark-performancetest -r 2)"

passmark_memory_read="$(cat results_memory.yml | grep 'ME_READ_S' | cut -d' ' -f4)"
echo "Memory read: $passmark_memory_read"
echo -n ",$passmark_memory_read" >> "$OUTPUT_FILE"
passmark_memory_write="$(cat results_memory.yml | grep 'ME_WRITE' | cut -d' ' -f4)"
echo "Memory write: $passmark_memory_write"
echo -n ",$passmark_memory_write" >> "$OUTPUT_FILE"



echo
echo "==> Blender Open Data Benchmark"
blender="$($BLENDER_BENCHMARK_LOCATION benchmark --blender-version 4.0.0 --device-type CPU --json monster | tee /dev/fd/3)"

blender_result="$(echo "$blender" | jq .[0].stats.total_render_time)"
echo "Blender result: $blender_result"
echo -n ",$blender_result" >> "$OUTPUT_FILE"



echo
echo "==> 7zip"
zip="$(7z b | tee /dev/fd/3)"

zip_result_compress="$(echo "$zip" | grep -E 'Avr' | awk '{print $3}')"
echo "7zip compress: $zip_result_compress"
echo -n ",$zip_result_compress" >> "$OUTPUT_FILE"
zip_result_decompress="$(echo "$zip" | grep -E 'Avr' | awk '{print $7}')"
echo "7zip decompress: $zip_result_decompress"
echo -n ",$zip_result_decompress" >> "$OUTPUT_FILE"




echo
echo "==> Boot time (systemd-analyze)"
boot_time="$(systemd-analyze | tee /dev/fd/3)"

systemd_times="$(systemd-analyze time | grep 'Startup finished' | sed -E 's/Startup finished in ([0-9.]*)s \(firmware\) \+ ([0-9.]*)s \(loader\) \+ ([0-9.]*)s \(kernel\) \+ ([0-9.]*)s \(userspace\) = ([0-9.]*)s/Firmware: \1\nLoader: \2\nKernel: \3\nUserspace: \4\nTotal: \5/')"
systemd_firmware="$(echo "$systemd_times" | grep Firmware | cut -d' ' -f2)"
echo "Boot time (firmware): $systemd_firmware"
echo -n ",$systemd_firmware" >> "$OUTPUT_FILE"
systemd_loader="$(echo "$systemd_times" | grep Loader | cut -d' ' -f2)"
echo "Boot time (loader): $systemd_loader"
echo -n ",$systemd_loader" >> "$OUTPUT_FILE"
systemd_kernel="$(echo "$systemd_times" | grep Kernel | cut -d' ' -f2)"
echo "Boot time (kernel): $systemd_kernel"
echo -n ",$systemd_kernel" >> "$OUTPUT_FILE"
systemd_userspace="$(echo "$systemd_times" | grep Userspace | cut -d' ' -f2)"
echo "Boot time (userspace): $systemd_userspace"
echo -n ",$systemd_userspace" >> "$OUTPUT_FILE"
systemd_total="$(echo "$systemd_times" | grep Total | cut -d' ' -f2)"
echo "Boot time (total): $systemd_total"
echo ",$systemd_total" >> "$OUTPUT_FILE"



echo
echo "Tests completed."
