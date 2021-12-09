# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

* Added: decorated relations now can be called using "find", "empty?" and "find_by" methods
* Added/Changed/Deprecated/Removed/Fixed/Security: YOUR CHANGE HERE

## [2.0.0](2021-12-03)

* Added: support for generating multiple schema dumps with `rake graphql_rails:schema:dump`.
* Added: support for using chainable syntax for input attributes.
* Changed: changed default `predicate method type from `Boolean` to `Boolean!`
* Changed: changed error message when trying to paginate not supported types
* Added: support defining graphql-ruby types as strings.

## [1.2.4](2021-05-05)

* Fixed: Dynamic types definition where type A references type B referencing type A.

## [1.2.3](2021-04-12)

* Fixed: Total count on paginated resources

## [1.2.2](2021-02-19)

* Fixed: Incorrect type resolution for required list type fields in model declaration.

## [1.2.1](2021-02-17)

* Fixed: Incorrect scalar types resolution is fixed. No more `type mismatch between ID / ID`

## [1.2.0](2021-02-15)

* Added: `options` argument to model level attribute. Allows disabling automatic camelCase
* Fixed: methods with complex input arguments receives `Hash` instances instead of `GraphQL::Schema::InputObject`
* Fixed: Using `ActiveSupport::ParameterFilter` (Rails 6.1), if it is defined, instead of `ActionDispatch::Http::ParameterFilter`
* Changed: graphql version is now `1.12` which may require system-wide changes.
* Fixed: improved connection wrapper for pagination to work.
* Fixed: implementation of `total` field is no longer missing when using pagination.


## [1.0.0](2020-02-07)

* Added: "required" and "optional" flags for attribute
* Added: grouped routes
* Added: added argument to model.attribute
* Added: added graphql_context to model
* Removed: `action.can_return_nil` was removed, because it does no affect anymore
* Removed: default `action` model was removed. Now each action must have `returns` part
* Added: default router added. No need to assign value to constant on Router.draw
* Added: default action added. Now actions can have custom defaults
* Added: default controller model added. Now actions can be defined in more dynamic way
* Added: install generator. Now it's possible to generate boilerplate code

## [0.8.0] (2019-09-03)

* Added: permit_input action config with extended list of permitted input options
* Added: model decorators
* Added: controller action instrumentation [@povilasjurcys](https://github.com/povilasjurcys)
* Added: sentry and lograge integrations
* Added: required: true flag for permitted attributes, inputs and model attributes

## 0.7.0 (2019-05-15)

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
