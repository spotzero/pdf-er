# PDF-er Docker Web Service

PDF-er provides a web service that when given a URL, returns the PDF version of that site with javascript having been executed.

## Motivation

It is trivial to generate a PDF from a web page that includes javascript rendered elements from the client side. You can get a PDF version of an entirely decoupled web application just by clicking "File" => "Print" and selecting "Print to PDF".

It is very very hard to generate a PDF of a decoupled web application server-side. It is deceptively easy to do it client-side because your browser and your operating system's printer sub-systems are working together to make is easy.

This project runs a container that uses X Virtual FrameBuffer, a browser, and CUPS to simulate the ease of client-side PDF generation, wrapped in a webservice to make it a server side backend application.

## Architecture

The following is an diagram of the elements this container uses to make PDF of web pages with client-side components:

{ Rust Web Server and API } --> { Bash script } --> { Xvfb } --> { Firefox } --> { CUPS Printing to PDF }
             ^____________________________________________________________________________/

## Setup

You can use the Makefile to build all the dependencies and create docker container.

To do this, just run ```make```

This has only been tested on Ubuntu, but should work on any Debian variant.

Make will affect your local environment and will install build dependencies and required toolchains.

Running ```make``` will do the following:

1. Install musl via apt (Rust build dependency)
2. Install Rust and the Rust build toolchain
3. Install Rust to use the nightly compiler
4. Install Rust's musl target so that the resulting binary can run in the docker container.
5. Compile the Rust web server (pdfserve).
6. Generate SSL certs for the service
7. Build the docker container

## Running

### Without SSL
docker run --rm -p 8080:8080 -e ROCKET_PORT=8080 spotzero/pdf-er

### With SSL
docker run -p 8443:8443 -e ROCKET_PORT=8443 -e SSL=1 spotzero/pdf-er

## Use behind an HTTP proxy

This container can run behind an HTTP proxy if the follow environment variables are set:

1. PROXY_USER="username"
2. PROXY_PASS="password"
3. PROXY_HOST="hostname:port"

## Using PDF-er

Simply made a get request to: ```https://<domain>:<port>/getpdf?url=<URL to print>```

*Examples:* If you container is listening on localhost:8443 and you want a PDF of Github's homepage, make a GET request to: ```https://localhost:8443/getpdf?url=https://github.com/```

## License

Code included is released under the GPL-3, see LICENSE.txt for details.

Bundled fonts are copyrighted by their respective creators.

