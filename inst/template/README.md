
# {{ name }}

> {{ title }}

[![Linux Build Status](https://travis-ci.org/{{ gh_username }}/{{ name }}.svg?branch=master)](https://travis-ci.org/{{ gh_username }}/{{ name}})
[![Windows Build status](https://ci.appveyor.com/api/projects/status/github/{{ gh_username }}/{{ name }}?svg=true)](https://ci.appveyor.com/project/{{ gh_username }}/{{ name }})
[![](http://www.r-pkg.org/badges/version/{{ name }})](http://www.r-pkg.org/pkg/{{ name }})
[![CRAN RStudio mirror downloads](http://cranlogs.r-pkg.org/badges/{{ name }})](http://www.r-pkg.org/pkg/{{ name }})


{{ description }}

## Installation

```r
devtools::install_packages("{{ gh_username }}/{{ name }}")
```

## Usage

```r
library({{ name }})
```

## License

{{ license }} © [{{ author }}](https://github.com/{{ gh_username }}).