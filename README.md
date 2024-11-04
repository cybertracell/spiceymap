<img src="/IMG_0538.png" alt="banner" />

---

# $piceymap
## !! USE ETHICALLY PLEASE !!
### (ONLY USE THIS SCRIPT ON ENTITIES THAT ARE EITHER DEVICES THAT YOU OWN SUCH AS A HOME SERVER OR SOMETHING YOU HAVE AUTHORIZED PERMISSION TO TEST.)
### (THIS IS AN EARLY RELEASE OF THE SCRIPT, SO BE AWARE THAT THERE COULD BE SOME BUGS)

---
# A BASIC NETWORK MAPPER WITH AN AUTOMATIC TCP DUMP FEATURE.
This is a Network Analysis tool with training wheels! If you are looking for a time saving and essential solution for performing your network analysis, then look no further!

This tool will make it to where you will have to do the least amount of manual work in the command prompt as possible. This Bash Script has a basic/minimal user input design with many essential features, and like I stated previously… An automatic TCP Dumper that occurs after each network scan that is conducted. The goal in this project is to make a comprehensive, user friendly method of checking up on your network without having to spend too much time in the command prompt.

---

# INSTALLATION GUIDE
#### STEP 1: INSTALL REQUIRED TOOLS

$piceymap itself DOES NOT have a built in network mapper, TCP Dumping tool, or a TCP/UDP writing/receiving tool. It simply uses tools that already exist like nmap, tcpdump, and netcat to automate commands in a ‘select your choice’ format which is the highlight of this tool being user-friendly. If you download this Bash script without the tools installed, it WILL NOT work.

```bash
sudo apt install nmap
```
```bash
sudo apt install tcpdump
```
```bash
sudo apt install netcat-openbsd
```

#### STEP 2: MAKE SHELL SCRIPT AN EXECUTABLE

While we are still in the Terminal, we will make our way to the folder that has the spiceymap.sh file. We will enter the following commands to make this script execute in our terminal.

```bash
chmod +x spiceymap.sh
```
After you have done this, there are two ways to launch this script…
Like this,
↓↓↓

```bash
sudo ./spiceymap.sh
```
You can also use the bash method below but this method is mainly used for testing if a script specifically works in bash

```bash
sudo bash spiceymap.sh
```

If you are already familiar with the way nmap, tcpdump, and netcat works, and you understand the script then you are all set to go! If not, I suggest catching up on the tool’s documentation here

<ul>
  
<li> <a href="https://nmap.org/">nmap.org</a> </li>
<li> <a href="https://www.tcpdump.org/">tcpdump.org</a> </li>
<li> <a href="https://netcat.sourceforge.net/">netcat.org</a> </li>
  
</ul>

Or, proceed on reading the $PICEYMAP OVERVIEW section below to know in detail how each option works and what it does with the network you enter on each scan.

---

# $PICEYMAP OVERVIEW

As soon as you launch the shell program, you will be asked to put in an IP address (192.168.0.1/24 or, Your gateway is the default if nothing is typed in)

The input does also except web addresses (Example: http://scanme.nmap.org/) and not just IP addresses. However, it is worth noting that I have heavily tested this shell script on my home network and not any kind of website so keep that in mind as there could potentially be issues ahead in scanning websites.

Next the program will ask you to add a port (Optional).

Port scanning is good for finding vulnerabilities that can be exploited by an open port that can give you a entrance into a server.

 SCENARIO: You may conduct a network scan and search for open ports and port 23 (Telnet) could be open, which could give a hacker a way to remote access into the server system. Port scanning gives you an advantage so that you can view your ports and see what should be open and what should be closed, depending on the purpose of the server.

After the port scanning option, you will then see an option to enter a duration of how long you want your network scan to last. It ‘s intention is to be good for analytical purposes mainly.

Now you have your 4 options on what kind of network scan you would like to do…

#### OPTION 1
a basic network scan.
```bash
nmap -sn [address]
```
This is known as a “ping scan.” which can be used to check whether a host is up and performing without doing a full port scan. Now when is comes to this scan, using -p with it wouldn’t work the way you think it would since -sn disables port scanning. So if you decide to choose this option it’s best to skip port scanning.

#### OPTION 2
This is what's called a stealth scan.
```bash
nmap -sS [address]
```
This is option will perform a TCP SYN scan. This will send SYN packets to the target ports and wait for a response. This method is less detectable than a full TCP connect scan. Now if you were to select “yes” on the port scanning option at the beginning of running the script on this option, then it will help you determine which ports are open.

#### OPTION 3
This will basically send out different IP addresses to the target network.
```bash
nmap -D RND: [address]
```
This makes it more difficult for network administrators or security tools to trace the scan back to your real IP address, as they will see traffic coming from multiple sources. This option will send packets that appear to come from these decoys, in addition to your own IP address.
#### (THIS IS NOT FOOLPROOF, SOME ADVANCED NETWORKS CAN POTENTIALLY DETECT THE DECOYS)

#### OPTION 4 
The Idle scan
```bash
nmap -sI [zombie ip] [address]
```
This option is commonly chosen to discover hosts and services. You can also enter a “zombie ip” which will not reveal the scanner’s IP address. However, this is not a foolproof solution to some networks with advanced or well structured infrastructures may be able to detect you even with this method. But in the case of using this on your home network or a network you have authorized permission to use, This is a good way of seeing how good your security is and what to improve if needed.

#### NETWORK INTERFACE

Next you will be asked to enter an available network interface, Of course it should bring up all your interfaces but there is one thing to note if you go with the default method which is (default: any) as it gives a warning that says (Warning: interface names may be incorrect) so just keep that in mind. But if you do enter in an interface then it should work.

#### NETCAT SEND/RECEIVE MESSAGES

After that it will ask you if you want to use netcat for sending/receiving messages. Netcat is commonly used for testing the interaction of a network and just generally used for debugging network issues. It is up to you whether you want to use the Netcat option by doing the yes or no input.

### TCP TXT/PCAP FILES

Now, after you have experimented and have become familiar with the tool, you can now go into your folder and see that there is a ‘active_ips.txt’ which will show the active ips that were captured. You will also see a tcpdump file both in a .txt and .pcap format. The pcap format is going to be your best friend as this is a format that is compatible for Wireshark for going deeper into network analytics.
#### (THE FILES SHOULD BE FOUND IN THE SPICEYMAP FOLDER)

---

This is at least all of the essentials but I’m very sure that in the future when this script undergoes bug fixes and additional features that this documentation will go a lot more in depth.

Stay safe

-CyberTracell
