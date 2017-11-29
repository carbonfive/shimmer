# Shimmer

An experimental Capybara driver for headless chrome.

Why? Headless Chrome via Selenium is about 2x slower than Poltergeist, which is a bummer. How fast could it be if we cut out the middleman and talked directly to Chromedriver, or Chrome? The goal of Shimmer is to figure that out.

# Benchmarks

There's a simple benchmark in place...

    cd benchmark
    ./benchmark

Which currently produces these results on my laptop:

```
Warming up --------------------------------------
         poltergeist     1.000  i/100ms
  selenium_webdriver     1.000  i/100ms
Calculating -------------------------------------
         poltergeist      7.114  (± 0.0%) i/s -    213.000  in  30.013084s
  selenium_webdriver      2.662  (± 0.0%) i/s -     80.000  in  30.069270s

Comparison:
         poltergeist:        7.1 i/s
  selenium_webdriver:        2.7 i/s - 2.67x  slower
``` 
