# Shimmer

An experimental Capybara driver for headless chrome.

Why? Headless Chrome via Selenium is about 2x slower than Poltergeist, which is a bummer. How fast could it be if we cut out the middleman and talked directly to Chromedriver, or Chrome? The goal of Shimmer is to figure that out.

# Setup

Install [`chrome-protocol-proxy`](https://github.com/wendigo/chrome-protocol-proxy) to see wire traffic over the remote debugging socket.

    $ go get -u github.com/wendigo/chrome-protocol-proxy

# Before running the test suite (benchmark)

   1. Be sure to start up the proxy in a separate window before beginning the benchmark suite.

       $ chrome-protocol-proxy

   (By default, the proxy listens on port 9223 and forwards traffic to the Chrome child process, listening on port 9222)

   2. Be sure to close Google Chrome completely - having any other open Chrome window or process will interfere with the runner.

# Benchmarks

There's a simple benchmark in place...

    cd benchmark
    ./benchmark

Which currently produces these results on my laptop:

```
Warming up --------------------------------------
         poltergeist     1.000  i/100ms
     headless_chrome     1.000  i/100ms
              chrome     1.000  i/100ms
Calculating -------------------------------------
         poltergeist     7.153  (± 0.0%) i/s -    215.000  in  30.127967s
     headless_chrome     2.668  (± 0.0%) i/s -     80.000  in  30.000791s
              chrome     2.440  (± 0.0%) i/s -     74.000  in  30.344067s

Comparison:
         poltergeist:    7.2 i/s
     headless_chrome:    2.7 i/s - 2.68x  slower
              chrome:    2.4 i/s - 2.93x  slower
``` 
