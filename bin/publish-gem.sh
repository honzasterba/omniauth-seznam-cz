#!/bin/bash

rm *.gem
gem build omniauth-seznam-cz.gemspec
gem push omniauth-seznam-cz-*.gem
