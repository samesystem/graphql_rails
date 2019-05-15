# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

* Added/Changed/Deprecated/Removed/Fixed/Security: YOUR CHANGE HERE

* Added: input type now accepts `enum` param which allows create enum fields
* Added: routes now accepts `suffix: true` flag which generates GraphQL field with appended action name to the end of resource name

## 0.6.0 (2019-04-29)

* Breaking change: controller params are always underscored [@povilasjurcys](https://github.com/povilasjurcys).
* Breaking change: cursor in paginated responses has plain index value by default [@povilasjurcys](https://github.com/povilasjurcys).
* Fixed: do not crash when testing paginated actions [@povilasjurcys](https://github.com/povilasjurcys).

## 0.5.2 (2019-04-24)

* Fixed: do not crash when using Connection types in non Ruby on Rails project [@povilasjurcys](https://github.com/povilasjurcys).

## 0.5.1 (2019-04-10)

* Fixed: controller action hooks context [@povilasjurcys](https://github.com/povilasjurcys).
* Added: options for controller actions [@vastas1996](https://github.com/vastas1996).

## 0.5.0 (2019-04-03)

* Added: GraphQL input type generators [@povilasjurcys](https://github.com/povilasjurcys).
* Added: CHANGELOG [@povilasjurcys](https://github.com/povilasjurcys).
* Fixed: GraphQL word typos in documentation and code [@povilasjurcys](https://github.com/povilasjurcys).
