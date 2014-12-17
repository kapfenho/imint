OIM JSON Interface
==================

_Nitty-gritty interface for Oracle Identity Manager_

This service acts as a JSON interface to the main OIM entities. The requests are
forwarded to the Identity Managers API (Java API). The error codes are
mapped to HTTP return codes (as far as possible). While the service can
also run independently, it is designed for deploying to a WebLogic
server instance close to Identity Manager itself. Authentication and
authorization services of infrastructure are used in this deployment
scenario.


### Supported objects

* User
* Organization
* Role

Related objects:

* User password
* User assigned roles

### Advantages

* quicker and more responsive development tools can be used
* no Java necessary any more
* simple JSON interface can be called via command line or from browser


## Interface Usage

The interface is [RESTful](http://www.restapitutorial.com/lessons/httpmethods.html):

    HTTP verb /entity/<id>

For your convenience (and to to prevent users gonna kill us) we've added
one access path in addition to OIMs surrogat (ID): the user login name. While
you access a user by its ID like

    HTTP GET /user/12345

you can get the same object by its login name with

    HTTP GET /login/jdean

_For organization/role calls replace user with organization/role._
_Additional info: [REST API Tutorial](http://www.restapitutorial.com/lessons/httpmethods.html)_

### User

| Command                                   | Function                                           |
| ----------------------------------------- | -------------------------------------------------- |
| HTTP GET /user/attributes                 | Helper: get all available user attributes          |
| HTTP GET /user/<id>                       | Get user by ID                                     |
| HTTP GET /user                            | List all users                                     |
| HTTP GET /user?First Name=Horst           | Search by attribute                                |
| HTTP POST /user                           | Create/add user (plus body)                        |
| HTTP PUT /user/<id>                       | Change/update user (plus body)                     |
| HTTP DELETE /user/<id>                    | Delete/remove user (status change in OIM)          |
| HTTP GET /user/<id>/entitlements          | Returns all user entitlements                      |
| HTTP GET /user/<id>/entitlements/<eid>    | Returns entitlement <eid> of user <id>             |
| HTTP PUT /user/<id>/entitlements/<eid>    | Revoke entitlement <eid> from user <id>            |

### User Password

| Command                                   | Function                                           |
| ----------------------------------------- | -------------------------------------------------- |
| HTTP PUT /user/<id>/password              | Set new password for user <id>                     |
| HTTP GET /login/<login>                   | Get user by login (case insensitive)               |
| HTTP PUT /login/<login>/password          | Set new password for user with <login>             |

### Organization

| Command                                   | Function                                           |
| ----------------------------------------- | -------------------------------------------------- |
| HTTP GET /organization/attributes         | Helper: get all available organization attributes  |
| HTTP GET /organization/<id>               | Get organization by ID                             |
| HTTP GET /organization                    | List all organizations                             |
| HTTP GET /organization?First Name=Horst   | Search by attribute                                |
| HTTP POST /organization                   | Create/add organization (plus body)                |
| HTTP PUT /organization/<id>               | Change/update organization (plus body)             |
| HTTP DELETE /organization/<id>            | Delete/remove organization (status change in OIM)  |

### Role

| Command                                   | Function                                           |
| ----------------------------------------- | -------------------------------------------------- |
| HTTP GET /role/attributes                 | Helper: get all available role attributes          |
| HTTP GET /role/<id>                       | Get role by ID                                     |
| HTTP GET /role                            | List all roles                                     |
| HTTP GET /role?Role Name=Admin            | Search by attribute                                |
| HTTP POST /role                           | Create/add role (plus body)                        |
| HTTP PUT /role/<id>                       | Change/update role (plus body)                     |
| HTTP DELETE /role/<id>                    | Delete/remove role (status change in OIM)          |
| HTTP GET /role/<id>/members               | Get all members of role with ID                    |


### Sample Calls

Suppose you run your local dev-instance on port 8080:

```
# get all users
curl -X GET http://localhost:8080/user

# get user by id
curl -X GET http://localhost:8080/user/1

# get user by attr
curl -X GET 'http://localhost:8080/user?First Name=John'

# add user
curl -X POST -d '{ "First Name": "Tom", "Last Name": "Tiger", "User Login": "TTIGER", "act_key": 1, "Role": "Full-Time" }' http://localhost:8080/user

# update user
curl -X PUT  -d '{"First Name": "James", "Display Name": "James Tiger"}' http://localhost:8080/user/1

# delete user
curl -X DELETE http://localhost:8080/user/1

# update user
curl -X PUT -d '{ "password": "mysecret", "notify_racf": "false" }' http://localhost:8080/user/1/password

# check if user is assigned to a role, check http return code
curl -X GET http://localhost:8080/user/4711/role?ugp_key=17
```


## Installation

### Requirements

* [JDK >= 1.7](http://www.oracle.com/technetwork/java/javase/downloads/index.html)
* [JRuby >= 1.7.16](http://www.jruby.org)
* [Bundler](http://bundler.io)
* A service user in OIM, create manually with permissions....


### Configuration

Check out project, then create your config files from shipped templates:

In `imint.yml` is you specify the runtime configuration of Imint. This
is where the OIM user, password and connection URL go.

For automated deployment you configure your environment in
`config/environment.yml`. This file is under version control.

```
cp config/imint.yml.example config/imint.yml
cp setup/imint.prop.example setup/imint.prop
```

### Tasks

All operation tasks are implemented as rake tasks. List all available
tasks with 

    rake -T

### Setup Tasks

```
$ bundle install                  # get ruby gems
$ rake -T                         # list all rake tasks
$ rake getjars                    # get big jar files (not included in
                                  #   project), curl https
$ vi config/imint.yml             # configure your runtime settings

$ rake test                       # run tests

```

* Checksum of Java Libs (JAR)

```
$ shasum -a 256 *
9e8d01f172301b966f1f404aa6fc0bdbec478ae9197256ad95bfcad1ef927601  commons-logging.jar
50967dbc8091f295a6bfb5590067d4ed8c3cedad1e429cf5f79e46df4210cfd6  eclipselink.jar
cea1efa410b6429ef443afe93046b94f6cf27268118065abbb4f371757e8d805  jrf-api.jar
1b5b13ff70d1468aeffd5b20093b30971be4ca8d2c2e42838fbb7cff582c1ab6  oimclient.jar
ef18c546b6721256e7c3adecb1dd5fa2aca1ec024df64448b676c5e9dcc84c4b  spring.jar
c6fdeb87f62896e79cdbcd45fe46aecb5ba55451a8c8ab83b7d36161620f254f  wlfullclient.jar
```


### Build, Deploy and Run

```
# configure deployment
$ vi config/environments.yml      # configure your env for deployment
$ vi setup/imint.prop             # copy this file to app server,
                                  # used in deploy task
$ sh setup/init.sh                # run this only on first deployment to 
                                  #   create necessary files and 
                                  #   directories on the server

# build
$ rake build[0.1.2]               # build version 0.1.2 -> imint.war

# deploy
$ rake deploy[production]         # deploy to weblogic

# run
$ rake server                     # run local app

# helpers
$ rake extract                    # unpack war file for inspection
$ rake clean                      # remove temporary files
$ rake clobber                    # remove temporary and production files
```

Client

```
$ curl -X GET http://localhost:8080/organization/1
[
  {
    "parent_key": 3,
    "Organization Status": "Active",
    "Parent Organization Name": "Top",
    "Organization Name": "Xellerate Users",
    "act_key": 1,
    "Organization Customer Type": "System"
  }
]
```


## Additional Information

### Listing of User Attributes

```
"Accessibility Mode"
"Automatically Delete On"
"Color Contrast"
"Common Name Generated"
"Common Name"
"Country"
"Currency"
"Date Format"
"Department Number"
"Description"
"Display Name"
"Email"
"Embedded Help"
"Employee Number"
"End Date"
"FA Language"
"FA Party Id"
"FA Person Id"
"FA Territory"
"FA User Id"
"Fax"
"First Name"
"Font Size"
"Full Name"
"Generation Qualifier"
"Hire Date"
"Home Phone"
"Home Postal Address"
"Initials"
"LDAP DN"
"LDAP GUID"
"LDAP Organization Unit"
"LDAP Organization"
"Last Name"
"Locality Name"
"Locked On"
"Manager Display Name"
"Manager Name"
"Manually Locked"
"Middle Name"
"Mobile"
"Non MT User Login"
"Number Format"
"PO Box"
"Pager"
"Password Generated"
"Postal Address"
"Postal Code"
"Role"
"Start Date"
"State"
"Status"
"Street"
"Telephone Number"
"Tenant GUID"
"Tenant Name"
"Time Format"
"Title"
"User Login"
"User Name Preferred Language"
"Xellerate Type"
"act_key"
"usr_change_pwd_at_next_logon"
"usr_create"
"usr_createby"
"usr_created"
"usr_data_level"
"usr_deprovisioned_date"
"usr_deprovisioning_date"
"usr_disabled"
"usr_key"
"usr_locale"
"usr_locked"
"usr_login_attempts_ctr"
"usr_manager_key"
"usr_password"
"usr_policy_update"
"usr_provisioned_date"
"usr_provisioning_date"
"usr_pwd_cant_change"
"usr_pwd_e xpire_date"
"usr_pwd_expired"
"usr_pwd_min_age_date"
"usr_pwd_must_change"
"usr_pwd_never_expires"
"usr_pwd_reset_attempts_ ctr"
"usr_pwd_warn_date"
"usr_pwd_warned"
"usr_timezone"
"usr_update"
"usr_updateby"
```

