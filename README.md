# Booth Agent
[![Build Status](https://secure.travis-ci.org/ClearElection/booth-agent.svg)](http://travis-ci.org/ClearElection/booth-agent)
[![Coverage Status](https://img.shields.io/coveralls/ClearElection/booth-agent.svg)](https://coveralls.io/r/ClearElection/booth-agent)


A basic rails app that acts as a booth agent for an online election:

*  Given a valid authentication token for an election,
*  Provides a blank ballot with unique ID,
*  Accepts a request to cast that ballot when it's filled out.
*  When the polls are closed, freely provides the election returns data.

That is, it implements the API schema [schemas/api/booth-agent-v0.0.schema.json](https://github.com/ClearElection/clear-election-sdk-ruby/blob/master/schemas/api/booth-agent-0.0.schema.json)

This is intended for testing and as an example.


#### TODO:

* Convert the core into a rails engine which can be used in apps that have their own custom code for authorization, data retention, etc.




