#!/bin/bash
# Created by Matteo Volpi, Nov 2023

[ "$#" -ne 1 ] && (echo "Usage: $0 <filename>" 1>&2) && exit 1

config_file="$1"
is_lighthouse_present=0

# Path to the template file
template_file="config_template.yaml"

[ ! -f "$config_file" ] && (echo "Error: the specified configuration file '$config_file' is not found." 1>&2) && exit 1

first_line=$(head -n 1 "$config_file")

if [[ "$first_line" == "lighthouse:"* ]]; then
    is_lighthouse_present=1
    nebula_lighthouse_ip=$(echo "$first_line" | awk -F '[,:]' '{print $2}' | xargs)
    real_lighthouse_ip=$(echo "$first_line" | awk -F '[,:]' '{print $3}' | xargs)
    real_lighthouse_port=$(echo "$first_line" | awk -F '[,:]' '{print $4}' | xargs)

    echo "Lighthouse -> Nebula IP: $nebula_lighthouse_ip, Real IP: $real_lighthouse_ip:$real_lighthouse_port"
else
    echo "Warning! No lighthouses configured, this hosts will only be able to initiate tunnels with static_host_map entries"
fi

grep -v "lighthouse" "$config_file" | while IFS=, read -r host_name host_ip_info groups; do
    host_directory="$host_name"
    mkdir -p "$host_directory"

   nebula-cert sign -name "$host_name" -ip "$host_ip_info" --groups "$groups" -out-crt "$host_directory/host.crt" -out-key "$host_directory/host.key"

   if [ "$is_lighthouse_present" -eq 1 ]; then
       sed -e "s|\$nebula_lighthouse_ip: \['\$real_lighthouse_ip:\$real_lighthouse_port'\]|$nebula_lighthouse_ip: ['$real_lighthouse_ip:$real_lighthouse_port']|; s|\(\$nebula_lighthouse_ip\)|$nebula_lighthouse_ip|g" "$template_file" > "$host_directory/temp_config.yaml"

       awk -v groups="$groups" '/# groups will be dynamically added here/ {gsub(/[\[\]]/, "", groups); gsub(",", "\n        - ", groups); print "      groups:\n        - " groups; next} 1' "$host_directory/temp_config.yaml" > "$host_directory/config.yaml"

       rm "$host_directory/temp_config.yaml"
   else
       sed -e "s|\$nebula_lighthouse_ip: \['\$real_lighthouse_ip:\$real_lighthouse_port'\]||; s|\(\$nebula_lighthouse_ip\)|$nebula_lighthouse_ip|g" "$template_file" > "$host_directory/config.yaml"
   fi

    echo "Directory with config files created for $host_name"
done
