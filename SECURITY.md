# Security policy

## Supported version

Security fixes currently target the latest version on the `main` branch.

## Reporting a vulnerability

Please use GitHub's private vulnerability reporting feature when it is available for this repository. Do not open a public issue containing exploit details, personal notes, credentials, or other sensitive data.

Include a concise impact description, reproduction steps, affected files or endpoints, and any suggested mitigation. You should receive an acknowledgement within seven days.

## Local data model

Later is designed for one user on one device and binds the server to the loopback interface. It accepts only local hostnames and same-origin browser requests.

Browser state is stored in local storage. Local storage is not encrypted and is accessible to other people using the same browser profile. The profile card is a local display preference, not an authenticated account. The application does not provide authorization or confidential multi-user storage. Do not use it for regulated or highly sensitive data.
