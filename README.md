# RPCIV (Tool to interact with RPC)

This interactive tool acts as a user-friendly interface for RPCClient, a command-line client used to interact with the RPC (Remote Procedure Call) service on Windows systems. Through this tool, you can connect to a remote server and execute predefined commands to enumerate users, groups, domains, and system configurations in an organized manner.

> [!IMPORTANT]
> It is necessary to have RPCClient installed on the system for the tool to function properly.

---

## Table of Contents

1. [Description](#description)
2. [Requirements](#requirements)
4. [Installation](#installation)
5. [Usage](#usage)
6. [Contributions](#contributions)

---

## Description

The use of `RPCClient` can be a bit overwhelming, which is why I decided to create this tool. It consolidates the most commonly used commands when enumerating the RPC protocol, and through an interactive prompt, you can execute different commands via **RPC**. The tool essentially uses rpcclient to return the results, however, thanks to the intuitive commands in `rpciv`, you avoid having to memorize numerous commands. It even improves efficiency, as it automates many series of commands that we would normally need to execute to obtain the same results.

The main purpose that led me to create this tool was to learn how to use `rpcclient` more professionally. At the moment, it includes some of its main functions, but it will be updated over time with additional commands that may be useful.

---

## Requirements

The only requirement to use this tool is to have `rpcclient` installed.

```bash
sudo apt install smbclient -y && rpcclient --version
```

---

## Installation

Installation steps:

2. Clone this repository:
   
   ```bash
   git clone https://github.com/h3g0c1v/rpciv
   ```
3. Access the directory:
   
   ```bash
   cd rpciv
   ```
4. Run the tool:
   
   ```bash
   ./rpciv.sh -h
   ```

Once all the previous steps are completed, we should see the tool's help panel.

---

## Usage

To display the main help panel of the tool, we will run it with `-h`.

```bash
./rpciv.sh -h
```

![image](https://github.com/user-attachments/assets/567a5646-d0fd-4ba9-9703-4767db81d285)

To connect to the RPC service, we will need to specify:

- To perform a null session, we will use `-n`:

  ```bash
  ./rpciv.sh -n
  ```
  
- In case of having credentials, we will specify the username (`-u`) and the password (`-p`):

  ```bash
  ./rpciv.sh -u USERNAME -p PASSWORD
  ```

If we connect with a _null session_, the prompt will show that we are logged in as _ANONYMOUS LOGON_:

![image](https://github.com/user-attachments/assets/4f0bcf2d-f877-4b94-b0ef-eec2e4a03cfa)

When we connect as a user, we will see the username in our _prompt_:

![image](https://github.com/user-attachments/assets/0765f932-54a2-4337-94e8-36c7eebe587d)

### Command Panel

When we are connected to the tool, we can see the help panel with the `help` command.

![image](https://github.com/user-attachments/assets/0e6c4d54-d044-49cb-a930-b34094b2f916)

In this way, you can list all the available commands in the tool. These commands are designed to be very intuitive and easy to remember.

### Clear and Exit

Of course, typical commands like `clear` to clear the screen and `exit` to exit the program exist and can be used.

### Who am I

With `whoami`, we will list the name of the user we are logged in as.

![image](https://github.com/user-attachments/assets/2dee8ba8-df75-438c-9e3c-a75c0e1a9c8a)

### Changing the Prompt

The type of prompt shown is configurable, and you can choose from the available options with `list prompts`.

![image](https://github.com/user-attachments/assets/22e78bb4-5067-4b5c-8fbc-2950ee1c87ba)

Each one is identified by a number seen on the left side of each prompt. If we want to change it, we simply specify the corresponding number with `prompt`.

![image](https://github.com/user-attachments/assets/748534e5-4843-4970-a524-f251023f72bd)

### Listing Available Users and Groups

To execute the `enumdomusers` command, this tool has `show users` or `s u` to list the available users in the domain.

![image](https://github.com/user-attachments/assets/71b0593c-06ff-4832-b674-4b30edd6284b)

And if we want to list the groups like `enumdomgroups`, we have `show groups` or `s g`.

![image](https://github.com/user-attachments/assets/e81d38db-81fd-4c7f-9e94-e8841df39828)

### Listing User and Group Descriptions

To see the descriptions of users, we can list them with `show users description` or `s u d`. This command only shows users that have a description, so those without one will not be displayed.

![image](https://github.com/user-attachments/assets/49c4997f-c266-4f52-ac39-173805c18676)

Similarly, we can do the same with groups using `show groups description` or `s g d`.

![image](https://github.com/user-attachments/assets/eae3e468-b748-4f36-91ea-bdd780b4c7a2)

### Viewing Group Members

To see the members of a specific group, we will run `show group members` or `s g m` followed by the desired group. For example, if we want to see the members of the Domain Admins group, we would execute the command as follows:

![image](https://github.com/user-attachments/assets/fa5314b5-0089-44d8-8dbd-d23d04c0aa70)

### Obtaining a User's SID

For many types of attacks, it is necessary to know the _SID_ of the user we are targeting, so I added the command `show user sid` or `s u s`, where we will specify the username whose SID we want to query.

![image](https://github.com/user-attachments/assets/e059211b-d5f5-49da-906f-321381bf263a)

### Viewing Domain Information

Sometimes, it's also interesting to know domain information like its name, SID, and trust relationships. For this, we have two commands:

- `show domain info` or `s d i` --> Lists information like the **domain name** and its **SID**.
- `show trusted domains` or `s t d` --> Shows the trust relationships configured for the domain.

An example of executing both commands could be as follows:

![image](https://github.com/user-attachments/assets/bceef0e8-12e4-4d6a-bd14-c3ee6dbe578f)

In this case, we can see that the domain is `HTB`, its corresponding SID, and that it has no trust relationships.

> [!NOTE]
> If there had been any trust relationship with another domain, it would have been displayed.

---

### Contributions

I am excited to receive any contributions! If you would like to contribute or share your ideas, feel free to contact me through my [LinkedIn](https://www.linkedin.com/in/h%C3%A9ctor-civantos-cid-aka-hegociv-5ab997212/).

---
