# Security policy

## Supported version

Security fixes currently target the latest version on the `main` branch.

## Reporting a vulnerability

Please use GitHub's private vulnerability reporting feature when it is available for this repository. Do not open a public issue containing exploit details, personal notes, credentials, or other sensitive data.

Include a concise impact description, reproduction steps, affected files or endpoints, and any suggested mitigation. You should receive an acknowledgement within seven days.

## Local data model

Later is designed for one user on one device. It binds its server to the loopback interface and stores browser state in local storage. Local storage is not encrypted and is accessible to other people using the same browser profile. The application does not provide accounts, authorization, multi-user isolation, or remote deployment hardening.
