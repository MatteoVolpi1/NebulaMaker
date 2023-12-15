# NebulaMaker.sh

## Introduction

NebulaMaker.sh is a straightforward script designed to streamline the creation of Nebula network configuration files and certificates. The script organizes generated files neatly into individual folders named after each host.

## Prerequisites

To run NebulaMaker.sh you need the following 3 files:

1. <config_file>: simple txt file containing the Nebula network info, "hosts" file is an example. It should include:
     - (optional) Lighthouse config data on the first line. "lighthouse: " keyword needed. It currently supports only 1 lighthouse.
     - host's data, one per line separated by commas. It supports multiple security_groups.
         example line: hostname,NebIP,security_groups
      
2. config_template.yaml: This file serves as the template for Nebula configuration. The script will automatically insert data into the "static_host_map" anchor and firewall outbound rules.
   
3. NebulaMaker.sh: script that does all that good stuff, it requires the path to the <config_file> as a parameter.
   
## Usage

```bash
./NebulaMaker.sh <config_file>
```

## License

Feel free to do whatever you want with this script 🌌
