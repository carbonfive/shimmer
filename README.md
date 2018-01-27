# Shimmer

An experimental Capybara driver for headless chrome.

Why? Headless Chrome via Selenium is about 2x slower than Poltergeist, which is a bummer. How fast could it be if we cut out the middleman and talked directly to Chromedriver, or Chrome? The goal of Shimmer is to figure that out.

## Setup

Install [`chrome-protocol-proxy`](https://github.com/wendigo/chrome-protocol-proxy) to see wire traffic over the remote debugging socket.

    $ go get -u github.com/wendigo/chrome-protocol-proxy

## Usage in Capybara

In your application's Capybara setup block (oftentimes, `spec/support/capybara.rb`), add the following:

```ruby
# First, register the driver
Capybara.register_driver :shimmer do |app|
  Capybara::Shimmer::Driver.new(app)
end

# If you want to run shimmer for all specs
Capybara.default_driver = :shimmer

# Only run shimmer for JS-based tests
Capybara.javascript_driver = :shimmer
```

### Extended options

You can pass extended options to further configure Shimmer:

```ruby
Capybara.register_driver :shimmer do |app|
  Capybara::Shimmer::Driver.new(
    app,
    headless: true, # To run Chrome headlessly
    window_width: <WIDTH_IN_PIXELS>, # Default: 1920
    window_height: <HEIGHT_IN_PIXELS>, # Default: 1080
    port: <DEVTOOLS_PORT>, # Default: 9222
    host: <DEVTOOLS_HOST>,  # Remote Chrome DevTools host (default localhost)
    proxy: true # Start Chrome on 9223, but use chrome-protocol-proxy on 9222
  )
end
```

### Before running the test suite (benchmark)

   1. Be sure to start up the proxy in a separate window before beginning the benchmark suite.

        $ chrome-protocol-proxy

   (By default, the proxy listens on port 9223 and forwards traffic to the Chrome child process, listening on port 9222)

   2. Be sure to close Google Chrome completely - having any other open Chrome window or process will interfere with the runner.

## Debugging/giving it a whirl

You can play with the driver in a console session by simply launching it with:

    $ ./bin/console

This automatically instantiates a `Capybara::Shimmer::Driver` at `driver` in your interactive session:

    [1] pry(main)> driver.visit('http://www.google.com')
    [2] pry(main)> driver.find_css('input[aria-label=Search]').first.set('Bitcoin')

The console can also be run headlessly with the `--headless` flag:

    $ ./bin/console --headless

## Benchmarks

There's a simple benchmark in place...

    cd benchmark
    ./benchmark

Which currently produces these results on my laptop:

```
Calculating -------------------------------------
    headless_shimmer      2.023  (± 0.0%) i/s -     61.000  in  30.423677s
             shimmer      0.965  (± 0.0%) i/s -     29.000  in  30.120099s
         poltergeist      3.372  (± 0.0%) i/s -    101.000  in  30.041906s
              chrome      0.721  (± 0.0%) i/s -     22.000  in  30.583263s
     headless_chrome      0.926  (± 0.0%) i/s -     28.000  in  30.272857s

Comparison:
         poltergeist:        3.4 i/s
    headless_shimmer:        2.0 i/s - 1.67x  slower
             shimmer:        1.0 i/s - 3.50x  slower
     headless_chrome:        0.9 i/s - 3.64x  slower
              chrome:        0.7 i/s - 4.68x  slower
``` 

## Profiling

Profiling is important to understanding the root causes of slowdowns between different drivers.

The recommended way to profile test runs is to use the `profile_driver` script.

    $ ./benchmark/profile_driver <NAME_OF_DRIVER>

Driver may be either `headless_chrome`, `chrome`, `headless_shimmer`, `shimmer`, or `poltergeist`.

A `callgrind`-compatible file will be generated in the `tmp/` directory. (It can also generate hundreds of partial files to support its run - you can safely ignore those.) Recommend you use `qcachegrind` to view and analyze the results.

First, install `qcachegrind`:

    $ brew install qcachegrind

Then open a call profile to analyze the results:

    $ qcachegrind tmp/headless_shimmer.callgrind.out.42062
