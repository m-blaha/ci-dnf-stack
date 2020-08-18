@no_installroot
@destructive
Feature: Respect main config options


Scenario: microdnf downloads zchunk metadata, enabled by default
Given I copy repository "simple-base" for modification
  And I use repository "simple-base" as http
  And I start capturing outbound HTTP requests
  And I execute "createrepo_c --simple-md-filenames --zck /{context.dnf.repos[simple-base].path}"
 When I execute microdnf with args "install labirinto"
 Then the exit code is 0
  And HTTP log contains
      """
      GET /repodata/primary.xml.zck
      """


@bz1851841
@bz1779104
Scenario: microdnf ignores zchunk metadata if disabled
Given I copy repository "simple-base" for modification
  And I use repository "simple-base" as http
  And I start capturing outbound HTTP requests
  And I execute "createrepo_c --simple-md-filenames --zck /{context.dnf.repos[simple-base].path}"
  And I configure dnf with
      | key    | value |
      | zchunk | False |
 When I execute microdnf with args "install labirinto"
 Then the exit code is 0
  And HTTP log contains
      """
      GET /repodata/primary.xml.gz
      """


@bz1866253
Scenario: microdnf respects --config option
Given I use repository "simple-base"
  And I create file "/test/microdnf.conf" with
      """
      [main]
      exclude=labirinto
      """
 When I execute microdnf with args "--config {context.dnf.installroot}/test/microdnf.conf install labirinto"
 Then the exit code is 1
  And stderr contains "error: No package matches 'labirinto'"
  And stdout is empty
