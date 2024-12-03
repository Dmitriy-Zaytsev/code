#!/usr/bin/env python3
import argparse
import nmap
import sys

sys.argv = ['sys.argv[0]', '-ip','10.100.27.10', '-port', '0' ]

ip_def = '10.100.27.10'
port_def = 0

def fun_ping(ip):
    print('The function fun_ping is read in the file mynmap.py')
    nm = nmap.PortScanner()
    try:
        #nm.scan(hosts=ip, arguments='-sP --min-hostgroup 128 --max-hostgroup 256 --min-parallelism 128 --max-parallelism 256 --min-rtt-timeout 0ms --max-rtt-timeout 100ms --initial-rtt-timeout 50ms --max-retries 1')
        nm.scan(hosts=ip, arguments='-sP --min-hostgroup 1 --max-hostgroup 256 --min-parallelism 1 --max-parallelism 256 --min-rtt-timeout 5ms --max-rtt-timeout 40ms --initial-rtt-timeout 20ms --max-retries 0')
        if nm[ip].state() == "up":
            print(f"{ip} is up.")
            return True
        else:
            print(f"{ip} is down or not responding.")
            return False
    except nmap.PortScannerError as e:
        print(f"Nmap error: {e}")
        return False
    except Exception as e:
        print(f"An unexpected error occurred: {e}")
        return False

def fun_tcp(ip,port):
    print('The function fun_ssh is read in the file mynmap.py')
    nm = nmap.PortScanner()
    try:
        nm.scan(hosts=ip, arguments='-n -PN -PS -PA -p T:'+str(port)+' --min-hostgroup 128 --max-hostgroup 256 --min-parallelism 128 --max-parallelism 256 --min-rtt-timeout 0ms --max-rtt-timeout 100ms --initial-rtt-timeout 50ms --max-retries 1')
        if nm[ip].has_tcp(port):
            port_state = nm[ip]['tcp'][port]['state']
            print("Port "+str(port)+" is "+str(port_state)+" on "+str(ip)+".")
        else:
            print("Port "+str(port)+" is not found on the "+str(ip)+".")
    
    except nmap.PortScannerError as e:
        print(f"Nmap error: {e}")
        return False
    except Exception as e:
        print(f"An unexpected error occurred: {e}")
        return False
    finally:
        try:
            if port_state == 'open': 
                return True
            else:
                 return False
        except:
            return False

if __name__ == '__main__':
    print('Launch file mynmap.py')
    parser = argparse.ArgumentParser(description='ICMP/TCP scan')
    parser.add_argument('--ip','-ip', type=str, default=ip_def, dest='ip',
                        help='IP address of the device (default: 10.100.27.10)')
    parser.add_argument('--port', '-port', type=int, default=port_def, dest='port',
                        help='Port scan (default: 0)')
    args = parser.parse_args()
    ip = args.ip
    port = args.port
    if port  != 0:
        fun_tcp(ip,port)
    else:
        fun_ping(ip)
