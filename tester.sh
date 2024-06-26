#!/bin/bash

OUTPUT_FILE="results.csv"


if [ -z "$PASSMARK_LOCATION" ]; then
	# Assume that Passmark is in the PATH as `passmark-performancetest`.
 	PASSMARK_LOCATION="passmark-performancetest"
fi

exec 3>&1

boot_time="$(systemd-analyze)"
boot_time_processed="$(echo "$boot_time" | grep 'Startup finished' | sed -E 's/Startup finished in (.*) = ([0-9.]*s)/\1\n\2 (total)/;s/\s+\+\s+/\n/g' | sed -E 's/([0-9.]+)s\s*\((.+)\)/\2 \1/' | sed -E 's/([0-9.]+)ms\s*\((.+)\)/\2 0.\1/')"

# Create CSV file headers.
if ! [ -f "$OUTPUT_FILE" ]; then
	echo "Creating the result file..."
	echo -n "test,cmdline,sysbench,passmark_cpu_single_thread,passmark_cpu_floating_point,passmark_memory_read,passmark_memory_write,encrypt_aes_cbc,encrypt_aes_xts,zip_compress,zip_decompress" > "$OUTPUT_FILE"

	# Add in the headers for the boot stages.
	echo "$boot_time_processed" | while read line
	do
		boot_name="$(echo "$line" | cut -d' ' -f1)"
		echo -n ",boot_$boot_name" >> "$OUTPUT_FILE"
	done

	echo >> "$OUTPUT_FILE"
fi



test_number="$(cat "$OUTPUT_FILE" | wc -l)"
echo -n "$test_number" >> "$OUTPUT_FILE"
echo "Running test #$test_number..."


# Take a note of the boot parameters.
cmdline="$(cat /proc/cmdline)"
echo -n ",\"$cmdline\"" >> "$OUTPUT_FILE"


# Sysbench
echo "==> Sysbench"
sysbench="$(sysbench cpu run | tee /dev/fd/3)"

sysbench_result="$(echo "$sysbench" | grep 'events per second' | cut -d' ' -f9)"
echo "RESULT: $sysbench_result"
echo -n ",$sysbench_result" >> "$OUTPUT_FILE"


echo
echo "==> Passmark (CPU)"
passmark_cpu="$("$PASSMARK_LOCATION" -r 1)"

passmark_single_thread="$(cat results_cpu.yml | grep 'CPU_SINGLETHREAD' | cut -d' ' -f4)"
echo "Single thread: $passmark_single_thread"
echo -n ",$passmark_single_thread" >> "$OUTPUT_FILE"
passmark_floating_point="$(cat results_cpu.yml | grep 'CPU_FLOATINGPOINT_MATH' | cut -d' ' -f4)"
echo "Floating point: $passmark_floating_point"
echo -n ",$passmark_floating_point" >> "$OUTPUT_FILE"

echo
echo "==> Passmark (Memory)"
passmark_memory="$("$PASSMARK_LOCATION" -r 2)"

passmark_memory_read="$(cat results_memory.yml | grep 'ME_READ_S' | cut -d' ' -f4)"
echo "Memory read: $passmark_memory_read"
echo -n ",$passmark_memory_read" >> "$OUTPUT_FILE"
passmark_memory_write="$(cat results_memory.yml | grep 'ME_WRITE' | cut -d' ' -f4)"
echo "Memory write: $passmark_memory_write"
echo -n ",$passmark_memory_write" >> "$OUTPUT_FILE"



echo
echo "==> cryptsetup (aes-cbc)"
encrypt_aes_cbc="$(cryptsetup benchmark --cipher aes-cbc | tee /dev/fd/3)"

encrypt_aes_cbc_result="$(echo "$encrypt_aes_cbc" | grep 'aes-cbc' | awk '{print $3}')"
echo "Encrypt aes-cbc: $encrypt_aes_cbc_result"
echo -n ",$encrypt_aes_cbc_result" >> "$OUTPUT_FILE"


echo
echo "==> cryptsetup (aes-xts)"
encrypt_aes_xts="$(cryptsetup benchmark --cipher aes-xts | tee /dev/fd/3)"
encrypt_aes_xts_result="$(echo "$encrypt_aes_xts" | grep 'aes-xts' | awk '{print $3}')"
echo "Encrypt aes-xts: $encrypt_aes_xts_result"
echo -n ",$encrypt_aes_xts_result" >> "$OUTPUT_FILE"



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
echo "$boot_time"
echo
echo "$boot_time_processed" | while read line
do
	boot_name="$(echo "$line" | cut -d' ' -f1)"
	boot_length="$(echo "$line" | cut -d' ' -f2)"
	echo "Boot time ($boot_name): $boot_length"
	echo -n ",$boot_length" >> "$OUTPUT_FILE"
done
echo >> "$OUTPUT_FILE"


echo
echo "Tests completed."
