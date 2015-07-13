import sys
import commands

if __name__ == "__main__":
    netstat = commands.getoutputs("netstat -natup | grep mysqld")
    print(netstat)
