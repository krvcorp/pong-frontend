# Pong

We're building the future of college culture.

## Installation

TODO: Docker installation
TODO: Makefile commands

## Cloning

`git clone https://github.com/rau/pong.git`

## How to Run Server

`source env/bin/activate/`
`python3 manage.py makemigrations`
`python3 manage.py migrate`
`python3 manage.py runserver 8005`

## To Deactivate ENV

`deactivate`

## Current User Login Flow

1. User sends their phone number as a POST to /2fa-start/
2. User sends phone number and code to /2fa-finish/

## New User Registration Flow

1. User sends their phone number as a POST to /2fa-start/
2. User sends phone number and code to /2fa-finish/
3. User verifies email on frontend and sends email as a POST to /verify-email/
