# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## 1.0.4 - 2019-4-16
### Fixed 
- converted any hyphens to underscores for consistency.

## 1.0.3
### Fixed
- bumping version to release to rubygems

## 1.0.2
### Fixed
- fixed issue cutting tags/releasing

## 1.0.1
### Fixed
- fixed release to rubygems

## 1.0.0
### Changed
- Now hosted on rubygems

## 0.4.4 - 2019-3-4
### Fixed
- encrypted data of any type should receive the null obfuscator, previously only encrypted sensitive data was receiving null_obfuscator

## 0.4.3 - 2019-2-28
### Fixed
- catch ActiveRecord::NoDatabaseError for activation on new apps

## 0.4.2 - 2019-2-23
### Fixed
- removed require 'pry' line that was breaking in prod.

## 0.4.1 - 2019-2-15
### Fixed
- lack of space after curly brace in generated migration created lint errors

## 0.4.0 - 2019-2-15
### Added
- Added null_obfuscator for encrypted columns
- Added encryption check for sensitive data type

## 0.3.0 - 2019-2-15
### Added
- Added annotations for address columns

## 0.2.0 - 2019-2-15
### Added
- Added sensitive data columns like SIN, SSN, TIN

## 0.1.1 - 2019-2-14
### Fixed
- CircleCi database issue fixed

## 0.1.0 - 2019-2-14
### Added
- Colorize output in dev env and produce more descriptive message.

## 0.0.1 - 2019-2-14
### Added
- Gem created
