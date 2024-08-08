# CheckThatHeader

A tool for checking **low hanging fruit** issues such as _Missing Content-Security-Policy, Permissions-Policy, Referrer-Policy, X-Content-Type-Options, Strict-Transport-Security and X-Frame-Options_ on headers using **wget** with a twist of **nmap**.
  
# Installation

```
git clone https://github.com/evanricafort/CheckThatHeader.git && cd CheckThatHeader && sudo chmod +x checkthatheader.sh && sudo ./checkthatheader.sh -h
```

# Usage

Usage: ./checkthatheader.sh **-u** _<SINGLE_TARGET>_ | **-t** _<MULTIPLE_TARGET/SUBNET>_
